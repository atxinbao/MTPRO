import DomainModel
import ExecutionClient
import Foundation

/// L4OMSBrokerPortfolioReconciliationStatus 固定 GH-466 reconciliation evidence 的四类结果。
///
/// 这些状态只描述本地 deterministic sandbox 对账证据，不代表 production reconciliation runtime、
/// broker statement reconciliation、真实账户 PnL 或自动修复流程。
public enum L4OMSBrokerPortfolioReconciliationStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case matched
    case mismatched
    case stale
    case missing
}

/// L4OMSBrokerPortfolioReconciliationPath 固定 GH-466 必须覆盖的 sandbox 对账路径。
///
/// Path 绑定 GH-460 report kind 和 GH-462 OMS trigger。它不读取 production broker report，也不触发
/// Portfolio mutation、reconciliation job 或 Live command surface。
public enum L4OMSBrokerPortfolioReconciliationPath: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case fill
    case partialFill = "partial fill"
    case cancel
    case reject

    public var expectedReportKind: L4ExecutionClientSandboxReportKind {
        switch self {
        case .fill:
            .fill
        case .partialFill:
            .partialFill
        case .cancel:
            .cancelAcknowledgement
        case .reject:
            .reject
        }
    }

    public var expectedTrigger: L4OMSOrderLifecycleTrigger {
        switch self {
        case .fill:
            .sandboxFillReport
        case .partialFill:
            .sandboxPartialFillReport
        case .cancel:
            .sandboxCancelAcknowledgement
        case .reject:
            .sandboxRejectReport
        }
    }

    public var expectedTerminalState: L4OMSOrderLifecycleState {
        switch self {
        case .fill:
            .filled
        case .partialFill:
            .partiallyFilled
        case .cancel:
            .cancelled
        case .reject:
            .rejected
        }
    }
}

/// L4OMSBrokerPortfolioReconciliationField 固定 GH-466 对账时允许比较的字段。
///
/// 字段全部来自 GH-460 normalized sandbox report、GH-462 local OMS state 和本地 projection snapshot。
/// 它们不包含 raw broker payload、account endpoint payload、secret、真实账户余额或 broker position。
public enum L4OMSBrokerPortfolioReconciliationField: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case clientOrderID = "client order id"
    case omsLifecycleState = "OMS lifecycle state"
    case brokerReportStatus = "broker report status"
    case filledQuantity = "filled quantity"
    case remainingQuantity = "remaining quantity"
    case projectionSequence = "projection sequence"
}

/// L4OMSBrokerPortfolioReconciliationReason 固定 GH-466 mismatch / stale / missing 的审计原因。
///
/// Reason 只用于 deterministic evidence 和后续 audit trail 输入，不执行 repair，不触发 broker read。
public enum L4OMSBrokerPortfolioReconciliationReason: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case none
    case omsProjectionStateMismatch = "OMS / projection state mismatch"
    case brokerProjectionQuantityMismatch = "broker / projection quantity mismatch"
    case projectionStaleSequence = "projection stale sequence"
    case portfolioProjectionMissing = "portfolio projection missing"
}

/// L4OMSBrokerPortfolioReconciliationForbiddenCapability 枚举 GH-466 必须继续关闭的能力。
///
/// GH-466 只输出 local evidence；它不消费 production broker report、不读取真实账户、不计算 real PnL、
/// 不写 Portfolio runtime，也不暴露 Live PRO Console 或修复命令。
public enum L4OMSBrokerPortfolioReconciliationForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionBrokerReportConsumed = "production broker report consumed"
    case rawBrokerPayloadRead = "raw broker payload read"
    case realAccountRead = "real account read"
    case realPnLProduced = "real PnL produced"
    case portfolioRuntimeMutated = "Portfolio runtime mutated"
    case reconciliationRuntimeEnabled = "reconciliation runtime enabled"
    case repairCommandProduced = "repair command produced"
    case callsExecutionClient = "calls ExecutionClient"
    case touchesBrokerGateway = "touches broker gateway"
    case exposesLiveCommandSurface = "exposes Live command surface"
}

/// L4PortfolioProjectionReconciliationSnapshot 是 GH-466 用于对账的本地 portfolio projection snapshot。
///
/// Snapshot 只能来自 normalized sandbox report / OMS transition evidence。它不读取 raw broker payload、
/// 不读取真实账户、不同步 broker position、不计算 real PnL，也不写 Portfolio runtime。
public struct L4PortfolioProjectionReconciliationSnapshot: Codable, Equatable, Sendable {
    public let projectionID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let sourceTransitionID: Identifier
    public let sourceReportEventID: Identifier
    public let clientOrderID: Identifier
    public let path: L4OMSBrokerPortfolioReconciliationPath
    public let projectedState: L4OMSOrderLifecycleState
    public let projectedFilledQuantity: String
    public let projectedRemainingQuantity: String
    public let projectionSequence: Int
    public let sourceIsNormalizedSandboxReport: Bool
    public let readsRawBrokerPayload: Bool
    public let readsRealAccount: Bool
    public let computesRealPnL: Bool
    public let mutatesPortfolioRuntime: Bool

    public var projectionBoundaryHeld: Bool {
        issueID.rawValue == "GH-466"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-460", "GH-462"]
            && projectedFilledQuantity.isEmpty == false
            && projectedRemainingQuantity.isEmpty == false
            && projectionSequence > 0
            && sourceIsNormalizedSandboxReport
            && readsRawBrokerPayload == false
            && readsRealAccount == false
            && computesRealPnL == false
            && mutatesPortfolioRuntime == false
    }

    public init(
        projectionID: Identifier,
        issueID: Identifier = Identifier.constant("GH-466"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-460"),
            Identifier.constant("GH-462")
        ],
        sourceTransitionID: Identifier,
        sourceReportEventID: Identifier,
        clientOrderID: Identifier,
        path: L4OMSBrokerPortfolioReconciliationPath,
        projectedState: L4OMSOrderLifecycleState,
        projectedFilledQuantity: String,
        projectedRemainingQuantity: String,
        projectionSequence: Int,
        sourceIsNormalizedSandboxReport: Bool = true,
        readsRawBrokerPayload: Bool = false,
        readsRealAccount: Bool = false,
        computesRealPnL: Bool = false,
        mutatesPortfolioRuntime: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-466" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-466",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-460", "GH-462"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-460,GH-462",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        for requiredField in [
            ("projectedFilledQuantity", projectedFilledQuantity),
            ("projectedRemainingQuantity", projectedRemainingQuantity)
        ] where requiredField.1.isEmpty {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredField.0,
                expected: "non-empty GH-466 projection value",
                actual: "empty"
            )
        }
        guard projectionSequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "projectionSequence",
                expected: "positive projection sequence",
                actual: "\(projectionSequence)"
            )
        }
        guard sourceIsNormalizedSandboxReport else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("sourceIsNormalizedSandboxReport")
        }
        for forbiddenFlag in [
            ("readsRawBrokerPayload", readsRawBrokerPayload),
            ("readsRealAccount", readsRealAccount),
            ("computesRealPnL", computesRealPnL),
            ("mutatesPortfolioRuntime", mutatesPortfolioRuntime)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.projectionID = projectionID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.sourceTransitionID = sourceTransitionID
        self.sourceReportEventID = sourceReportEventID
        self.clientOrderID = clientOrderID
        self.path = path
        self.projectedState = projectedState
        self.projectedFilledQuantity = projectedFilledQuantity
        self.projectedRemainingQuantity = projectedRemainingQuantity
        self.projectionSequence = projectionSequence
        self.sourceIsNormalizedSandboxReport = sourceIsNormalizedSandboxReport
        self.readsRawBrokerPayload = readsRawBrokerPayload
        self.readsRealAccount = readsRealAccount
        self.computesRealPnL = computesRealPnL
        self.mutatesPortfolioRuntime = mutatesPortfolioRuntime
    }
}

/// L4OMSBrokerPortfolioReconciliationRecord 是 GH-466 的单条 OMS / report / projection 对账证据。
///
/// Record 只比较 local OMS transition、normalized sandbox report 和本地 projection snapshot。它不启动
/// production reconciliation，不读 raw broker payload，不执行 repair，也不暴露 command surface。
public struct L4OMSBrokerPortfolioReconciliationRecord: Codable, Equatable, Sendable {
    public let recordID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let path: L4OMSBrokerPortfolioReconciliationPath
    public let status: L4OMSBrokerPortfolioReconciliationStatus
    public let omsTransition: L4OMSLocalOrderTransitionRecord
    public let brokerReportEvent: L4ExecutionClientSandboxParsedReportEvent?
    public let portfolioProjection: L4PortfolioProjectionReconciliationSnapshot?
    public let comparedFields: [L4OMSBrokerPortfolioReconciliationField]
    public let reasons: [L4OMSBrokerPortfolioReconciliationReason]
    public let deterministicAuditEvidence: Bool
    public let productionBrokerReportConsumed: Bool
    public let rawBrokerPayloadRead: Bool
    public let realAccountRead: Bool
    public let portfolioRuntimeMutated: Bool
    public let repairCommandProduced: Bool
    public let exposesLiveCommandSurface: Bool

    public var recordBoundaryHeld: Bool {
        issueID.rawValue == "GH-466"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-460", "GH-462", "GH-463"]
            && omsTransition.transitionBoundaryHeld
            && omsTransition.trigger == path.expectedTrigger
            && comparedFields == Self.requiredComparedFields
            && statusReasonBoundaryHeld
            && reportAndProjectionBoundaryHeld
            && deterministicAuditEvidence
            && allForbiddenFlagsRemainClosed
    }

    private var reportAndProjectionBoundaryHeld: Bool {
        switch status {
        case .missing:
            brokerReportEvent?.parsedEventBoundaryHeld == true && portfolioProjection == nil
        case .matched, .mismatched, .stale:
            brokerReportEvent?.parsedEventBoundaryHeld == true
                && brokerReportEvent?.reportKind == path.expectedReportKind
                && portfolioProjection?.projectionBoundaryHeld == true
        }
    }

    private var statusReasonBoundaryHeld: Bool {
        switch status {
        case .matched:
            reasons == [.none] && projectionMatchesOMSAndBroker
        case .mismatched:
            reasons.contains(.omsProjectionStateMismatch) || reasons.contains(.brokerProjectionQuantityMismatch)
        case .stale:
            reasons == [.projectionStaleSequence]
                && (portfolioProjection?.projectionSequence ?? Int.max) < omsTransition.toRecord.sequence
        case .missing:
            reasons == [.portfolioProjectionMissing] && portfolioProjection == nil
        }
    }

    private var projectionMatchesOMSAndBroker: Bool {
        guard let brokerReportEvent, let portfolioProjection else {
            return false
        }
        return portfolioProjection.clientOrderID == brokerReportEvent.clientOrderID
            && portfolioProjection.projectedState == path.expectedTerminalState
            && portfolioProjection.projectedState == omsTransition.toRecord.state
            && portfolioProjection.projectedFilledQuantity == brokerReportEvent.filledQuantity
            && portfolioProjection.projectedRemainingQuantity == brokerReportEvent.remainingQuantity
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            productionBrokerReportConsumed,
            rawBrokerPayloadRead,
            realAccountRead,
            portfolioRuntimeMutated,
            repairCommandProduced,
            exposesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        recordID: Identifier,
        issueID: Identifier = Identifier.constant("GH-466"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-460"),
            Identifier.constant("GH-462"),
            Identifier.constant("GH-463")
        ],
        path: L4OMSBrokerPortfolioReconciliationPath,
        status: L4OMSBrokerPortfolioReconciliationStatus,
        omsTransition: L4OMSLocalOrderTransitionRecord,
        brokerReportEvent: L4ExecutionClientSandboxParsedReportEvent?,
        portfolioProjection: L4PortfolioProjectionReconciliationSnapshot?,
        comparedFields: [L4OMSBrokerPortfolioReconciliationField] = Self.requiredComparedFields,
        reasons: [L4OMSBrokerPortfolioReconciliationReason],
        deterministicAuditEvidence: Bool = true,
        productionBrokerReportConsumed: Bool = false,
        rawBrokerPayloadRead: Bool = false,
        realAccountRead: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        repairCommandProduced: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-466" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-466",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-460", "GH-462", "GH-463"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-460,GH-462,GH-463",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard omsTransition.transitionBoundaryHeld && omsTransition.trigger == path.expectedTrigger else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "omsTransition",
                expected: path.expectedTrigger.rawValue,
                actual: omsTransition.trigger.rawValue
            )
        }
        guard comparedFields == Self.requiredComparedFields else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "comparedFields",
                expected: Self.requiredComparedFields.map(\.rawValue).joined(separator: ","),
                actual: comparedFields.map(\.rawValue).joined(separator: ",")
            )
        }
        guard deterministicAuditEvidence else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("deterministicAuditEvidence")
        }
        for forbiddenFlag in [
            ("productionBrokerReportConsumed", productionBrokerReportConsumed),
            ("rawBrokerPayloadRead", rawBrokerPayloadRead),
            ("realAccountRead", realAccountRead),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("repairCommandProduced", repairCommandProduced),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.recordID = recordID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.path = path
        self.status = status
        self.omsTransition = omsTransition
        self.brokerReportEvent = brokerReportEvent
        self.portfolioProjection = portfolioProjection
        self.comparedFields = comparedFields
        self.reasons = reasons
        self.deterministicAuditEvidence = deterministicAuditEvidence
        self.productionBrokerReportConsumed = productionBrokerReportConsumed
        self.rawBrokerPayloadRead = rawBrokerPayloadRead
        self.realAccountRead = realAccountRead
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.repairCommandProduced = repairCommandProduced
        self.exposesLiveCommandSurface = exposesLiveCommandSurface

        guard recordBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "recordBoundaryHeld",
                expected: "\(status.rawValue) \(path.rawValue) reconciliation boundary held",
                actual: "mismatch"
            )
        }
    }

    public static let requiredComparedFields: [L4OMSBrokerPortfolioReconciliationField] = [
        .clientOrderID,
        .omsLifecycleState,
        .brokerReportStatus,
        .filledQuantity,
        .remainingQuantity,
        .projectionSequence
    ]
}

/// L4OMSBrokerPortfolioReconciliationEvidence 汇总 GH-466 sandbox reconciliation evidence。
///
/// Evidence 覆盖 matched / mismatched / stale / missing，以及 partial fill、cancel、reject 对账路径。
/// 它只作为后续 audit trail / incident replay 输入，不实现 production reconciliation runtime。
public struct L4OMSBrokerPortfolioReconciliationEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let parserEvidence: L4ExecutionClientSandboxReportReplayEvidence
    public let localTransitionEvidence: L4OMSLocalOrderTransitionEvidence
    public let sandboxPathEvidence: L4ExecutionEngineSandboxPathEvidence
    public let records: [L4OMSBrokerPortfolioReconciliationRecord]
    public let forbiddenCapabilities: [L4OMSBrokerPortfolioReconciliationForbiddenCapability]
    public let validationAnchors: [String]
    public let matchedMismatchedStaleMissingCovered: Bool
    public let partialFillCancelRejectCovered: Bool
    public let portfolioProjectionAvoidsBrokerPayload: Bool
    public let productionBrokerReportFutureGated: Bool
    public let deterministicAuditEvidence: Bool
    public let productionReconciliationEnabled: Bool
    public let realPnLProduced: Bool
    public let exposesLiveCommandSurface: Bool

    public var reconciliationEvidenceHeld: Bool {
        issueID.rawValue == "GH-466"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-460", "GH-462", "GH-463"]
            && parserEvidence.reportParserEvidenceHeld
            && localTransitionEvidence.transitionEvidenceHeld
            && sandboxPathEvidence.sandboxPathEvidenceHeld
            && records.allSatisfy(\.recordBoundaryHeld)
            && Set(records.map(\.status)) == Set(L4OMSBrokerPortfolioReconciliationStatus.allCases)
            && Set(records.map(\.path)).isSuperset(of: Self.requiredPaths)
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && matchedMismatchedStaleMissingCovered
            && partialFillCancelRejectCovered
            && portfolioProjectionAvoidsBrokerPayload
            && productionBrokerReportFutureGated
            && deterministicAuditEvidence
            && productionReconciliationEnabled == false
            && realPnLProduced == false
            && exposesLiveCommandSurface == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-466-oms-broker-portfolio-reconciliation-evidence"),
        issueID: Identifier = Identifier.constant("GH-466"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-460"),
            Identifier.constant("GH-462"),
            Identifier.constant("GH-463")
        ],
        parserEvidence: L4ExecutionClientSandboxReportReplayEvidence,
        localTransitionEvidence: L4OMSLocalOrderTransitionEvidence,
        sandboxPathEvidence: L4ExecutionEngineSandboxPathEvidence,
        records: [L4OMSBrokerPortfolioReconciliationRecord],
        forbiddenCapabilities: [L4OMSBrokerPortfolioReconciliationForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        matchedMismatchedStaleMissingCovered: Bool = true,
        partialFillCancelRejectCovered: Bool = true,
        portfolioProjectionAvoidsBrokerPayload: Bool = true,
        productionBrokerReportFutureGated: Bool = true,
        deterministicAuditEvidence: Bool = true,
        productionReconciliationEnabled: Bool = false,
        realPnLProduced: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-466" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-466",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-460", "GH-462", "GH-463"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-460,GH-462,GH-463",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard parserEvidence.reportParserEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserEvidence",
                expected: "GH-460 parser evidence held",
                actual: "mismatch"
            )
        }
        guard localTransitionEvidence.transitionEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "localTransitionEvidence",
                expected: "GH-462 local transition evidence held",
                actual: "mismatch"
            )
        }
        guard sandboxPathEvidence.sandboxPathEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxPathEvidence",
                expected: "GH-463 sandbox path evidence held",
                actual: "mismatch"
            )
        }
        guard records.allSatisfy(\.recordBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "records",
                expected: "all GH-466 reconciliation records held",
                actual: "mismatch"
            )
        }
        guard Set(records.map(\.status)) == Set(L4OMSBrokerPortfolioReconciliationStatus.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "records.status",
                expected: L4OMSBrokerPortfolioReconciliationStatus.allCases.map(\.rawValue).joined(separator: ","),
                actual: records.map { $0.status.rawValue }.joined(separator: ",")
            )
        }
        guard Set(records.map(\.path)).isSuperset(of: Self.requiredPaths) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "records.path",
                expected: Self.requiredPaths.map(\.rawValue).sorted().joined(separator: ","),
                actual: Set(records.map(\.path)).map(\.rawValue).sorted().joined(separator: ",")
            )
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
        for requiredFlag in [
            ("matchedMismatchedStaleMissingCovered", matchedMismatchedStaleMissingCovered),
            ("partialFillCancelRejectCovered", partialFillCancelRejectCovered),
            ("portfolioProjectionAvoidsBrokerPayload", portfolioProjectionAvoidsBrokerPayload),
            ("productionBrokerReportFutureGated", productionBrokerReportFutureGated),
            ("deterministicAuditEvidence", deterministicAuditEvidence)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("productionReconciliationEnabled", productionReconciliationEnabled),
            ("realPnLProduced", realPnLProduced),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.parserEvidence = parserEvidence
        self.localTransitionEvidence = localTransitionEvidence
        self.sandboxPathEvidence = sandboxPathEvidence
        self.records = records
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.matchedMismatchedStaleMissingCovered = matchedMismatchedStaleMissingCovered
        self.partialFillCancelRejectCovered = partialFillCancelRejectCovered
        self.portfolioProjectionAvoidsBrokerPayload = portfolioProjectionAvoidsBrokerPayload
        self.productionBrokerReportFutureGated = productionBrokerReportFutureGated
        self.deterministicAuditEvidence = deterministicAuditEvidence
        self.productionReconciliationEnabled = productionReconciliationEnabled
        self.realPnLProduced = realPnLProduced
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static let requiredPaths: Set<L4OMSBrokerPortfolioReconciliationPath> = [
        .partialFill,
        .cancel,
        .reject
    ]

    public static let requiredForbiddenCapabilities = L4OMSBrokerPortfolioReconciliationForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-466-OMS-BROKER-PORTFOLIO-RECONCILIATION",
        "GH-466-RECONCILIATION-FIELD-MATRIX",
        "GH-466-MATCHED-MISMATCHED-STALE-MISSING-EVIDENCE",
        "GH-466-PARTIAL-CANCEL-REJECT-PATHS",
        "GH-466-PORTFOLIO-PROJECTION-NO-BROKER-PAYLOAD",
        "TVM-L4-OMS-BROKER-PORTFOLIO-RECONCILIATION"
    ]
}

/// L4OMSBrokerPortfolioReconciliationRuntime 生成 GH-466 deterministic sandbox reconciliation evidence。
///
/// Runtime 名称只表示本地 evidence builder；它不启用 production reconciliation，不读取真实 broker account，
/// 不计算 real PnL，不调用 ExecutionClient，也不写 Portfolio runtime。
public struct L4OMSBrokerPortfolioReconciliationRuntime: Codable, Equatable, Sendable {
    public let runtimeID: Identifier
    public let parserEvidence: L4ExecutionClientSandboxReportReplayEvidence
    public let localTransitionEvidence: L4OMSLocalOrderTransitionEvidence
    public let sandboxPathEvidence: L4ExecutionEngineSandboxPathEvidence
    public let productionReconciliationEnabled: Bool
    public let productionBrokerReportConsumed: Bool
    public let rawBrokerPayloadRead: Bool
    public let realAccountRead: Bool
    public let realPnLProduced: Bool
    public let portfolioRuntimeMutated: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let exposesLiveCommandSurface: Bool

    public var runtimeBoundaryHeld: Bool {
        parserEvidence.reportParserEvidenceHeld
            && localTransitionEvidence.transitionEvidenceHeld
            && sandboxPathEvidence.sandboxPathEvidenceHeld
            && productionReconciliationEnabled == false
            && productionBrokerReportConsumed == false
            && rawBrokerPayloadRead == false
            && realAccountRead == false
            && realPnLProduced == false
            && portfolioRuntimeMutated == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && exposesLiveCommandSurface == false
    }

    public init(
        runtimeID: Identifier = Identifier.constant("gh-466-oms-broker-portfolio-reconciliation-runtime"),
        parserEvidence: L4ExecutionClientSandboxReportReplayEvidence? = nil,
        localTransitionEvidence: L4OMSLocalOrderTransitionEvidence? = nil,
        sandboxPathEvidence: L4ExecutionEngineSandboxPathEvidence? = nil,
        productionReconciliationEnabled: Bool = false,
        productionBrokerReportConsumed: Bool = false,
        rawBrokerPayloadRead: Bool = false,
        realAccountRead: Bool = false,
        realPnLProduced: Bool = false,
        portfolioRuntimeMutated: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        let resolvedParserEvidence = try parserEvidence
            ?? L4ExecutionClientSandboxReportParser.deterministicFixture().deterministicReplayEvidence()
        let resolvedTransitionEvidence = try localTransitionEvidence
            ?? L4OMSLocalOrderTransitionEvidenceBuilder.deterministicFixture().deterministicEvidence()
        let resolvedSandboxPathEvidence = try sandboxPathEvidence
            ?? L4ExecutionEngineSandboxPathCoordinator.deterministicFixture().deterministicEvidence()

        guard resolvedParserEvidence.reportParserEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserEvidence",
                expected: "GH-460 parser evidence held",
                actual: "mismatch"
            )
        }
        guard resolvedTransitionEvidence.transitionEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "localTransitionEvidence",
                expected: "GH-462 local transition evidence held",
                actual: "mismatch"
            )
        }
        guard resolvedSandboxPathEvidence.sandboxPathEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxPathEvidence",
                expected: "GH-463 sandbox path evidence held",
                actual: "mismatch"
            )
        }
        for forbiddenFlag in [
            ("productionReconciliationEnabled", productionReconciliationEnabled),
            ("productionBrokerReportConsumed", productionBrokerReportConsumed),
            ("rawBrokerPayloadRead", rawBrokerPayloadRead),
            ("realAccountRead", realAccountRead),
            ("realPnLProduced", realPnLProduced),
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.runtimeID = runtimeID
        self.parserEvidence = resolvedParserEvidence
        self.localTransitionEvidence = resolvedTransitionEvidence
        self.sandboxPathEvidence = resolvedSandboxPathEvidence
        self.productionReconciliationEnabled = productionReconciliationEnabled
        self.productionBrokerReportConsumed = productionBrokerReportConsumed
        self.rawBrokerPayloadRead = rawBrokerPayloadRead
        self.realAccountRead = realAccountRead
        self.realPnLProduced = realPnLProduced
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static func deterministicFixture() throws -> L4OMSBrokerPortfolioReconciliationRuntime {
        try L4OMSBrokerPortfolioReconciliationRuntime()
    }

    public func deterministicEvidence() throws -> L4OMSBrokerPortfolioReconciliationEvidence {
        guard runtimeBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runtimeBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        let partial = try makeRecord(path: .partialFill, status: .matched)
        let cancel = try makeRecord(path: .cancel, status: .mismatched)
        let reject = try makeRecord(path: .reject, status: .stale)
        let fill = try makeRecord(path: .fill, status: .missing)
        return try L4OMSBrokerPortfolioReconciliationEvidence(
            parserEvidence: parserEvidence,
            localTransitionEvidence: localTransitionEvidence,
            sandboxPathEvidence: sandboxPathEvidence,
            records: [partial, cancel, reject, fill]
        )
    }

    private func makeRecord(
        path: L4OMSBrokerPortfolioReconciliationPath,
        status: L4OMSBrokerPortfolioReconciliationStatus
    ) throws -> L4OMSBrokerPortfolioReconciliationRecord {
        let transition = try transition(for: path)
        let event = try event(for: path.expectedReportKind)
        let projection = try projection(for: path, status: status, transition: transition, event: event)
        return try L4OMSBrokerPortfolioReconciliationRecord(
            recordID: Identifier.constant("gh-466-\(status.rawValue)-\(path.rawValue)-reconciliation"),
            path: path,
            status: status,
            omsTransition: transition,
            brokerReportEvent: event,
            portfolioProjection: projection,
            reasons: reasons(for: status)
        )
    }

    private func projection(
        for path: L4OMSBrokerPortfolioReconciliationPath,
        status: L4OMSBrokerPortfolioReconciliationStatus,
        transition: L4OMSLocalOrderTransitionRecord,
        event: L4ExecutionClientSandboxParsedReportEvent
    ) throws -> L4PortfolioProjectionReconciliationSnapshot? {
        if status == .missing {
            return nil
        }
        let projectedState: L4OMSOrderLifecycleState
        let filledQuantity: String
        let remainingQuantity: String
        let projectionSequence: Int

        switch status {
        case .matched:
            projectedState = transition.toRecord.state
            filledQuantity = event.filledQuantity
            remainingQuantity = event.remainingQuantity
            projectionSequence = transition.toRecord.sequence
        case .mismatched:
            projectedState = .submitted
            filledQuantity = event.filledQuantity
            remainingQuantity = event.remainingQuantity
            projectionSequence = transition.toRecord.sequence
        case .stale:
            projectedState = transition.toRecord.state
            filledQuantity = event.filledQuantity
            remainingQuantity = event.remainingQuantity
            projectionSequence = max(1, transition.toRecord.sequence - 1)
        case .missing:
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "projection",
                expected: "missing reconciliation status returns nil projection before switch",
                actual: "projection requested"
            )
        }

        return try L4PortfolioProjectionReconciliationSnapshot(
            projectionID: Identifier.constant("gh-466-\(status.rawValue)-\(path.rawValue)-projection"),
            sourceTransitionID: transition.transitionID,
            sourceReportEventID: event.eventID,
            clientOrderID: event.clientOrderID,
            path: path,
            projectedState: projectedState,
            projectedFilledQuantity: filledQuantity,
            projectedRemainingQuantity: remainingQuantity,
            projectionSequence: projectionSequence
        )
    }

    private func reasons(
        for status: L4OMSBrokerPortfolioReconciliationStatus
    ) -> [L4OMSBrokerPortfolioReconciliationReason] {
        switch status {
        case .matched:
            [.none]
        case .mismatched:
            [.omsProjectionStateMismatch]
        case .stale:
            [.projectionStaleSequence]
        case .missing:
            [.portfolioProjectionMissing]
        }
    }

    private func transition(
        for path: L4OMSBrokerPortfolioReconciliationPath
    ) throws -> L4OMSLocalOrderTransitionRecord {
        guard let transition = localTransitionEvidence.transitions.first(where: { $0.trigger == path.expectedTrigger }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "transition",
                expected: path.expectedTrigger.rawValue,
                actual: localTransitionEvidence.transitions.map { $0.trigger.rawValue }.joined(separator: ",")
            )
        }
        return transition
    }

    private func event(
        for kind: L4ExecutionClientSandboxReportKind
    ) throws -> L4ExecutionClientSandboxParsedReportEvent {
        guard let event = parserEvidence.parsedEvents.first(where: { $0.reportKind == kind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "brokerReportEvent",
                expected: kind.rawValue,
                actual: parserEvidence.parsedEvents.map { $0.reportKind.rawValue }.joined(separator: ",")
            )
        }
        return event
    }
}
