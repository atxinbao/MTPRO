import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV0210CanaryOMSEventKind 固定 GH-1282 可写入本地 OMS evidence log 的事件类型。
///
/// 这些事件只串起 GH-1280 submit evidence、GH-1281 cancel / rollback evidence 和 GH-1282
/// reconciliation evidence；它们不是 production OMS runtime event，不代表 broker payload，也不授权
/// 后续 command surface。
public enum ReleaseV0210CanaryOMSEventKind:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case submitRequest = "submit request"
    case submitAccepted = "submit accepted"
    case statusResponse = "status response"
    case cancelRequest = "cancel request"
    case cancelOutcome = "cancel outcome"
    case rollbackGuard = "rollback guard"
    case reconciliation = "reconciliation"
}

/// ReleaseV0210CanaryOMSReconciliationOutcome 描述 GH-1282 对账输出。
///
/// `matched` 只表示本地 redacted lifecycle event log、status response、cancel outcome 和
/// reconciliation evidence 可以重构同一笔 canary 生命周期；它不代表真实 broker 对账或 Portfolio runtime
/// mutation。
public enum ReleaseV0210CanaryOMSReconciliationOutcome:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case matched
    case rejected
}

/// ReleaseV0210CanaryOMSReconciliationRejectReason 是 GH-1282 fail-closed 原因。
///
/// 任一上游 cancel guard、event log、status response、cancel outcome 或 reconciliation evidence 缺失时，
/// lifecycle reconstruction 都必须 fail closed。
public enum ReleaseV0210CanaryOMSReconciliationRejectReason:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamCancelRejected = "upstream cancel rejected"
    case eventLogMissing = "event log missing"
    case lifecycleEventsIncomplete = "lifecycle events incomplete"
    case statusResponseMissing = "status response missing"
    case cancelOutcomeMissing = "cancel outcome missing"
    case reconciliationEvidenceMissing = "reconciliation evidence missing"
    case redactedEvidenceMissing = "redacted evidence missing"
}

/// ReleaseV0210CanaryOMSEventLogEntry 是 GH-1282 的单条本地 OMS event log 证据。
///
/// Entry 只保存 redacted digest、source evidence ID、sequence 和 event kind。它不保存 raw order id、
/// raw status payload、raw cancel payload、raw broker payload、credential value 或 endpoint response。
public struct ReleaseV0210CanaryOMSEventLogEntry:
    Codable, Equatable, Sendable
{
    public let entryID: Identifier
    public let issueID: Identifier
    public let sourceIssueID: Identifier
    public let sourceEvidenceID: Identifier
    public let sequence: Int
    public let kind: ReleaseV0210CanaryOMSEventKind
    public let symbol: String
    public let redactedEvidenceDigest: String
    public let localOMSState: String
    public let brokerStatus: String
    public let readOptimized: Bool
    public let redactedEvidenceOnly: Bool
    public let deterministicReplayable: Bool
    public let rawOrderIDPersisted: Bool
    public let rawStatusPayloadPersisted: Bool
    public let rawCancelPayloadPersisted: Bool
    public let rawBrokerPayloadPersisted: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public var entryHeld: Bool {
        issueID.rawValue == "GH-1282"
            && Self.allowedSourceIssues.contains(sourceIssueID.rawValue)
            && sequence > 0
            && symbol == Self.requiredSymbol
            && redactedEvidenceDigest.hasPrefix(Self.requiredRedactedDigestPrefix)
            && localOMSState.isEmpty == false
            && brokerStatus.isEmpty == false
            && entryID == Self.deterministicID(
                sequence: sequence,
                kind: kind,
                sourceIssueID: sourceIssueID,
                sourceEvidenceID: sourceEvidenceID
            )
            && readOptimized
            && redactedEvidenceOnly
            && deterministicReplayable
            && forbiddenCapabilitiesClosed
    }

    public var forbiddenCapabilitiesClosed: Bool {
        rawOrderIDPersisted == false
            && rawStatusPayloadPersisted == false
            && rawCancelPayloadPersisted == false
            && rawBrokerPayloadPersisted == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-1282"),
        sourceIssueID: Identifier,
        sourceEvidenceID: Identifier,
        sequence: Int,
        kind: ReleaseV0210CanaryOMSEventKind,
        symbol: String = Self.requiredSymbol,
        redactedEvidenceDigest: String? = nil,
        localOMSState: String,
        brokerStatus: String,
        readOptimized: Bool = true,
        redactedEvidenceOnly: Bool = true,
        deterministicReplayable: Bool = true,
        rawOrderIDPersisted: Bool = false,
        rawStatusPayloadPersisted: Bool = false,
        rawCancelPayloadPersisted: Bool = false,
        rawBrokerPayloadPersisted: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let resolvedDigest = redactedEvidenceDigest
            ?? Self.redactedDigest(sequence: sequence, kind: kind)
        let resolvedEntryID = Self.deterministicID(
            sequence: sequence,
            kind: kind,
            sourceIssueID: sourceIssueID,
            sourceEvidenceID: sourceEvidenceID
        )

        try Self.validateRequired(
            issueID: issueID,
            sourceIssueID: sourceIssueID,
            sequence: sequence,
            symbol: symbol,
            redactedEvidenceDigest: resolvedDigest,
            localOMSState: localOMSState,
            brokerStatus: brokerStatus,
            readOptimized: readOptimized,
            redactedEvidenceOnly: redactedEvidenceOnly,
            deterministicReplayable: deterministicReplayable
        )
        try Self.validateForbiddenFlags(
            rawOrderIDPersisted: rawOrderIDPersisted,
            rawStatusPayloadPersisted: rawStatusPayloadPersisted,
            rawCancelPayloadPersisted: rawCancelPayloadPersisted,
            rawBrokerPayloadPersisted: rawBrokerPayloadPersisted,
            productionEndpointConnected: productionEndpointConnected,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.entryID = resolvedEntryID
        self.issueID = issueID
        self.sourceIssueID = sourceIssueID
        self.sourceEvidenceID = sourceEvidenceID
        self.sequence = sequence
        self.kind = kind
        self.symbol = symbol
        self.redactedEvidenceDigest = resolvedDigest
        self.localOMSState = localOMSState
        self.brokerStatus = brokerStatus
        self.readOptimized = readOptimized
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.deterministicReplayable = deterministicReplayable
        self.rawOrderIDPersisted = rawOrderIDPersisted
        self.rawStatusPayloadPersisted = rawStatusPayloadPersisted
        self.rawCancelPayloadPersisted = rawCancelPayloadPersisted
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicID(
        sequence: Int,
        kind: ReleaseV0210CanaryOMSEventKind,
        sourceIssueID: Identifier,
        sourceEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            [
                "gh-1282-v0210-canary-oms-event-log-entry",
                "\(sequence)",
                kind.rawValue,
                sourceIssueID.rawValue,
                sourceEvidenceID.rawValue
            ].joined(separator: ":"),
            field: "releaseV0210.canaryOMS.eventLog.entryID"
        )
    }

    public static func redactedDigest(
        sequence: Int,
        kind: ReleaseV0210CanaryOMSEventKind
    ) -> String {
        "\(requiredRedactedDigestPrefix):\(sequence):\(kind.rawValue)"
    }

    public static let requiredSymbol = "BTCUSDT"
    public static let requiredRedactedDigestPrefix = "sha256:gh-1282-redacted-oms-event"
    public static let allowedSourceIssues = ["GH-1280", "GH-1281", "GH-1282"]
    public static let requiredLifecycleKinds: [ReleaseV0210CanaryOMSEventKind] = [
        .submitRequest,
        .submitAccepted,
        .statusResponse,
        .cancelRequest,
        .cancelOutcome,
        .rollbackGuard,
        .reconciliation
    ]
}

private extension ReleaseV0210CanaryOMSEventLogEntry {
    static func validateRequired(
        issueID: Identifier,
        sourceIssueID: Identifier,
        sequence: Int,
        symbol: String,
        redactedEvidenceDigest: String,
        localOMSState: String,
        brokerStatus: String,
        readOptimized: Bool,
        redactedEvidenceOnly: Bool,
        deterministicReplayable: Bool
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1282", "GH-1282", issueID.rawValue),
            ("sourceIssueID", allowedSourceIssues.contains(sourceIssueID.rawValue), allowedSourceIssues.joined(separator: ","), sourceIssueID.rawValue),
            ("sequence", sequence > 0, "positive sequence", "\(sequence)"),
            ("symbol", symbol == requiredSymbol, requiredSymbol, symbol),
            ("redactedEvidenceDigest", redactedEvidenceDigest.hasPrefix(requiredRedactedDigestPrefix), requiredRedactedDigestPrefix, redactedEvidenceDigest),
            ("localOMSState", localOMSState.isEmpty == false, "non-empty local OMS state", "empty"),
            ("brokerStatus", brokerStatus.isEmpty == false, "non-empty broker status", "empty"),
            ("readOptimized", readOptimized, "true", "\(readOptimized)"),
            ("redactedEvidenceOnly", redactedEvidenceOnly, "true", "\(redactedEvidenceOnly)"),
            ("deterministicReplayable", deterministicReplayable, "true", "\(deterministicReplayable)")
        ]

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryOMS.eventLog.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateForbiddenFlags(
        rawOrderIDPersisted: Bool,
        rawStatusPayloadPersisted: Bool,
        rawCancelPayloadPersisted: Bool,
        rawBrokerPayloadPersisted: Bool,
        productionEndpointConnected: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("rawOrderIDPersisted", rawOrderIDPersisted),
            ("rawStatusPayloadPersisted", rawStatusPayloadPersisted),
            ("rawCancelPayloadPersisted", rawCancelPayloadPersisted),
            ("rawBrokerPayloadPersisted", rawBrokerPayloadPersisted),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.canaryOMS.eventLog.\(field)"
            )
        }
    }
}

/// ReleaseV0210CanaryOMSReconciliationPolicy 描述 GH-1282 本地 OMS event log
/// 与 reconciliation evidence 的输入开关。
///
/// Policy 只表达 evidence 是否存在和是否 redacted；禁止 broad OMS rollout、raw payload、
/// Futures / OKX reconciliation、production endpoint、production secret 和 production cutover。
public struct ReleaseV0210CanaryOMSReconciliationPolicy:
    Codable, Equatable, Sendable
{
    public let policyID: Identifier
    public let eventLogPersisted: Bool
    public let statusResponseEvidenceStored: Bool
    public let cancelOutcomeEvidenceStored: Bool
    public let reconciliationEvidenceStored: Bool
    public let redactedEvidenceStored: Bool
    public let reconciliationDigest: String
    public let rawOrderIDPersisted: Bool
    public let rawStatusPayloadPersisted: Bool
    public let rawCancelPayloadPersisted: Bool
    public let rawBrokerPayloadPersisted: Bool
    public let broadProductionOMSRuntimeEnabled: Bool
    public let futuresReconciliationEnabled: Bool
    public let okxReconciliationEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var policyHeld: Bool {
        eventLogPersisted
            && statusResponseEvidenceStored
            && cancelOutcomeEvidenceStored
            && reconciliationEvidenceStored
            && redactedEvidenceHeld
            && forbiddenCapabilitiesClosed
    }

    public var redactedEvidenceHeld: Bool {
        redactedEvidenceStored
            && reconciliationDigest.hasPrefix(Self.requiredReconciliationDigestPrefix)
    }

    public var forbiddenCapabilitiesClosed: Bool {
        rawOrderIDPersisted == false
            && rawStatusPayloadPersisted == false
            && rawCancelPayloadPersisted == false
            && rawBrokerPayloadPersisted == false
            && broadProductionOMSRuntimeEnabled == false
            && futuresReconciliationEnabled == false
            && okxReconciliationEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionEndpointConnected == false
            && productionBrokerConnectionEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        policyID: Identifier = Identifier.constant("gh-1282-v0210-canary-oms-reconciliation-policy"),
        eventLogPersisted: Bool = true,
        statusResponseEvidenceStored: Bool = true,
        cancelOutcomeEvidenceStored: Bool = true,
        reconciliationEvidenceStored: Bool = true,
        redactedEvidenceStored: Bool = true,
        reconciliationDigest: String = Self.requiredReconciliationDigest,
        rawOrderIDPersisted: Bool = false,
        rawStatusPayloadPersisted: Bool = false,
        rawCancelPayloadPersisted: Bool = false,
        rawBrokerPayloadPersisted: Bool = false,
        broadProductionOMSRuntimeEnabled: Bool = false,
        futuresReconciliationEnabled: Bool = false,
        okxReconciliationEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try Self.validateForbiddenFlags(
            rawOrderIDPersisted: rawOrderIDPersisted,
            rawStatusPayloadPersisted: rawStatusPayloadPersisted,
            rawCancelPayloadPersisted: rawCancelPayloadPersisted,
            rawBrokerPayloadPersisted: rawBrokerPayloadPersisted,
            broadProductionOMSRuntimeEnabled: broadProductionOMSRuntimeEnabled,
            futuresReconciliationEnabled: futuresReconciliationEnabled,
            okxReconciliationEnabled: okxReconciliationEnabled,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.policyID = policyID
        self.eventLogPersisted = eventLogPersisted
        self.statusResponseEvidenceStored = statusResponseEvidenceStored
        self.cancelOutcomeEvidenceStored = cancelOutcomeEvidenceStored
        self.reconciliationEvidenceStored = reconciliationEvidenceStored
        self.redactedEvidenceStored = redactedEvidenceStored
        self.reconciliationDigest = reconciliationDigest
        self.rawOrderIDPersisted = rawOrderIDPersisted
        self.rawStatusPayloadPersisted = rawStatusPayloadPersisted
        self.rawCancelPayloadPersisted = rawCancelPayloadPersisted
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.broadProductionOMSRuntimeEnabled = broadProductionOMSRuntimeEnabled
        self.futuresReconciliationEnabled = futuresReconciliationEnabled
        self.okxReconciliationEnabled = okxReconciliationEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210CanaryOMSReconciliationPolicy
    {
        try ReleaseV0210CanaryOMSReconciliationPolicy()
    }

    public static func eventLogMissingFixture() throws
        -> ReleaseV0210CanaryOMSReconciliationPolicy
    {
        try ReleaseV0210CanaryOMSReconciliationPolicy(eventLogPersisted: false)
    }

    public static func statusResponseMissingFixture() throws
        -> ReleaseV0210CanaryOMSReconciliationPolicy
    {
        try ReleaseV0210CanaryOMSReconciliationPolicy(statusResponseEvidenceStored: false)
    }

    public static func cancelOutcomeMissingFixture() throws
        -> ReleaseV0210CanaryOMSReconciliationPolicy
    {
        try ReleaseV0210CanaryOMSReconciliationPolicy(cancelOutcomeEvidenceStored: false)
    }

    public static func reconciliationMissingFixture() throws
        -> ReleaseV0210CanaryOMSReconciliationPolicy
    {
        try ReleaseV0210CanaryOMSReconciliationPolicy(reconciliationEvidenceStored: false)
    }

    public static func redactionMissingFixture() throws
        -> ReleaseV0210CanaryOMSReconciliationPolicy
    {
        try ReleaseV0210CanaryOMSReconciliationPolicy(redactedEvidenceStored: false)
    }

    public static let requiredReconciliationDigestPrefix =
        "sha256:gh-1282-redacted-canary-reconciliation"
    public static let requiredReconciliationDigest =
        "sha256:gh-1282-redacted-canary-reconciliation:BTCUSDT:matched"
}

private extension ReleaseV0210CanaryOMSReconciliationPolicy {
    static func validateForbiddenFlags(
        rawOrderIDPersisted: Bool,
        rawStatusPayloadPersisted: Bool,
        rawCancelPayloadPersisted: Bool,
        rawBrokerPayloadPersisted: Bool,
        broadProductionOMSRuntimeEnabled: Bool,
        futuresReconciliationEnabled: Bool,
        okxReconciliationEnabled: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("rawOrderIDPersisted", rawOrderIDPersisted),
            ("rawStatusPayloadPersisted", rawStatusPayloadPersisted),
            ("rawCancelPayloadPersisted", rawCancelPayloadPersisted),
            ("rawBrokerPayloadPersisted", rawBrokerPayloadPersisted),
            ("broadProductionOMSRuntimeEnabled", broadProductionOMSRuntimeEnabled),
            ("futuresReconciliationEnabled", futuresReconciliationEnabled),
            ("okxReconciliationEnabled", okxReconciliationEnabled),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.canaryOMS.reconciliation.\(field)"
            )
        }
    }
}

/// ReleaseV0210CanaryOMSReconciliationDecision 是 GH-1282 的本地 lifecycle
/// reconstruction 判定。
///
/// Decision 必须消费 GH-1281 cancel / rollback guard evidence。只有上游 cancel authorized、
/// event log sequence 完整、status response、cancel outcome、reconciliation 和 redacted evidence 全部
/// 存在时，才输出 matched lifecycle evidence。
public struct ReleaseV0210CanaryOMSReconciliationDecision:
    Codable, Equatable, Sendable
{
    public let decisionID: Identifier
    public let policy: ReleaseV0210CanaryOMSReconciliationPolicy
    public let upstreamCancelEvidenceID: Identifier
    public let upstreamCancelDecisionID: Identifier
    public let upstreamCancelOutcome: ReleaseV0210ControlledCanaryCancelRollbackOutcome
    public let outcome: ReleaseV0210CanaryOMSReconciliationOutcome
    public let rejectReasons: [ReleaseV0210CanaryOMSReconciliationRejectReason]
    public let eventLogEntries: [ReleaseV0210CanaryOMSEventLogEntry]
    public let eventKinds: [ReleaseV0210CanaryOMSEventKind]
    public let eventLogPersisted: Bool
    public let eventSequenceStrict: Bool
    public let canaryLifecycleReconstructable: Bool
    public let statusResponseRecorded: Bool
    public let cancelOutcomeRecorded: Bool
    public let reconciliationEvidenceRecorded: Bool
    public let reconciliationDigest: String
    public let forwardsToReadOnlyStatusSurface: Bool
    public let broadProductionOMSRuntimeEnabled: Bool
    public let futuresReconciliationEnabled: Bool
    public let okxReconciliationEnabled: Bool
    public let rawBrokerPayloadPersisted: Bool
    public let productionCutoverAuthorized: Bool

    public var decisionHeld: Bool {
        rejectReasons == Self.expectedRejectReasons(
            policy: policy,
            upstreamCancelOutcome: upstreamCancelOutcome,
            eventLogEntries: eventLogEntries
        )
            && matchedOrRejectedStateHeld
            && policy.forbiddenCapabilitiesClosed
            && forbiddenCapabilitiesClosed
    }

    public var matchedOrRejectedStateHeld: Bool {
        if rejectReasons.isEmpty {
            return outcome == .matched
                && eventLogPersisted
                && eventSequenceStrict
                && canaryLifecycleReconstructable
                && statusResponseRecorded
                && cancelOutcomeRecorded
                && reconciliationEvidenceRecorded
                && reconciliationDigest.hasPrefix(
                    ReleaseV0210CanaryOMSReconciliationPolicy.requiredReconciliationDigestPrefix
                )
                && forwardsToReadOnlyStatusSurface
        }

        return outcome == .rejected
            && canaryLifecycleReconstructable == false
            && forwardsToReadOnlyStatusSurface == false
    }

    public var forbiddenCapabilitiesClosed: Bool {
        broadProductionOMSRuntimeEnabled == false
            && futuresReconciliationEnabled == false
            && okxReconciliationEnabled == false
            && rawBrokerPayloadPersisted == false
            && productionCutoverAuthorized == false
    }

    public init(
        policy: ReleaseV0210CanaryOMSReconciliationPolicy,
        upstreamCancelEvidence: ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence,
        upstreamCancelDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision? = nil,
        eventLogEntries: [ReleaseV0210CanaryOMSEventLogEntry]? = nil,
        broadProductionOMSRuntimeEnabled: Bool = false,
        futuresReconciliationEnabled: Bool = false,
        okxReconciliationEnabled: Bool = false,
        rawBrokerPayloadPersisted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard upstreamCancelEvidence.evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryOMS.upstreamCancelEvidence",
                expected: "GH-1281 cancel rollback evidence held",
                actual: upstreamCancelEvidence.issueID.rawValue
            )
        }
        try Self.validateForbiddenFlags(
            broadProductionOMSRuntimeEnabled: broadProductionOMSRuntimeEnabled,
            futuresReconciliationEnabled: futuresReconciliationEnabled,
            okxReconciliationEnabled: okxReconciliationEnabled,
            rawBrokerPayloadPersisted: rawBrokerPayloadPersisted,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        let resolvedCancelDecision = upstreamCancelDecision
            ?? upstreamCancelEvidence.acceptedDecision
        let resolvedEventLogEntries = try eventLogEntries
            ?? Self.deterministicEventLogEntries(
                policy: policy,
                upstreamCancelEvidence: upstreamCancelEvidence
            )
        let reasons = Self.expectedRejectReasons(
            policy: policy,
            upstreamCancelOutcome: resolvedCancelDecision.outcome,
            eventLogEntries: resolvedEventLogEntries
        )
        let matched = reasons.isEmpty

        self.policy = policy
        self.upstreamCancelEvidenceID = upstreamCancelEvidence.evidenceID
        self.upstreamCancelDecisionID = resolvedCancelDecision.decisionID
        self.upstreamCancelOutcome = resolvedCancelDecision.outcome
        self.outcome = matched ? .matched : .rejected
        self.rejectReasons = reasons
        self.eventLogEntries = resolvedEventLogEntries
        self.eventKinds = resolvedEventLogEntries.map(\.kind)
        self.eventLogPersisted = policy.eventLogPersisted && resolvedEventLogEntries.isEmpty == false
        self.eventSequenceStrict = Self.eventSequenceHeld(resolvedEventLogEntries)
        self.canaryLifecycleReconstructable = matched
        self.statusResponseRecorded = policy.statusResponseEvidenceStored
            && resolvedEventLogEntries.contains { $0.kind == .statusResponse }
        self.cancelOutcomeRecorded = policy.cancelOutcomeEvidenceStored
            && resolvedEventLogEntries.contains { $0.kind == .cancelOutcome }
        self.reconciliationEvidenceRecorded = policy.reconciliationEvidenceStored
            && resolvedEventLogEntries.contains { $0.kind == .reconciliation }
        self.reconciliationDigest = policy.reconciliationDigest
        self.forwardsToReadOnlyStatusSurface = matched
        self.broadProductionOMSRuntimeEnabled = broadProductionOMSRuntimeEnabled
        self.futuresReconciliationEnabled = futuresReconciliationEnabled
        self.okxReconciliationEnabled = okxReconciliationEnabled
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.decisionID = Self.deterministicID(
            policy: policy,
            upstreamCancelDecision: resolvedCancelDecision,
            outcome: matched ? .matched : .rejected
        )
    }

    public static func expectedRejectReasons(
        policy: ReleaseV0210CanaryOMSReconciliationPolicy,
        upstreamCancelOutcome: ReleaseV0210ControlledCanaryCancelRollbackOutcome,
        eventLogEntries: [ReleaseV0210CanaryOMSEventLogEntry]
    ) -> [ReleaseV0210CanaryOMSReconciliationRejectReason] {
        var reasons: [ReleaseV0210CanaryOMSReconciliationRejectReason] = []
        if upstreamCancelOutcome != .authorized {
            reasons.append(.upstreamCancelRejected)
        }
        if policy.eventLogPersisted == false || eventLogEntries.isEmpty {
            reasons.append(.eventLogMissing)
        }
        if eventSequenceHeld(eventLogEntries) == false {
            reasons.append(.lifecycleEventsIncomplete)
        }
        if policy.statusResponseEvidenceStored == false
            || eventLogEntries.contains(where: { $0.kind == .statusResponse }) == false
        {
            reasons.append(.statusResponseMissing)
        }
        if policy.cancelOutcomeEvidenceStored == false
            || eventLogEntries.contains(where: { $0.kind == .cancelOutcome }) == false
        {
            reasons.append(.cancelOutcomeMissing)
        }
        if policy.reconciliationEvidenceStored == false
            || eventLogEntries.contains(where: { $0.kind == .reconciliation }) == false
        {
            reasons.append(.reconciliationEvidenceMissing)
        }
        if policy.redactedEvidenceHeld == false
            || eventLogEntries.allSatisfy(\.redactedEvidenceOnly) == false
        {
            reasons.append(.redactedEvidenceMissing)
        }
        return reasons
    }

    public static func eventSequenceHeld(
        _ entries: [ReleaseV0210CanaryOMSEventLogEntry]
    ) -> Bool {
        guard entries.isEmpty == false else { return false }

        return entries.map(\.sequence) == Array(1...entries.count)
            && entries.map(\.kind) == ReleaseV0210CanaryOMSEventLogEntry.requiredLifecycleKinds
            && entries.allSatisfy(\.entryHeld)
    }

    public static func deterministicEventLogEntries(
        policy: ReleaseV0210CanaryOMSReconciliationPolicy,
        upstreamCancelEvidence: ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence
    ) throws -> [ReleaseV0210CanaryOMSEventLogEntry] {
        guard policy.eventLogPersisted else { return [] }

        let submitEvidenceID = upstreamCancelEvidence.upstreamSubmitEvidence.evidenceID
        let cancelEvidenceID = upstreamCancelEvidence.evidenceID
        let reconciliationEvidenceID = Identifier.constant(
            "gh-1282-v0210-redacted-canary-reconciliation-evidence"
        )

        return try [
            ReleaseV0210CanaryOMSEventLogEntry(
                sourceIssueID: Identifier.constant("GH-1280"),
                sourceEvidenceID: submitEvidenceID,
                sequence: 1,
                kind: .submitRequest,
                localOMSState: "pendingSubmit",
                brokerStatus: "requestEvidenceCreated"
            ),
            ReleaseV0210CanaryOMSEventLogEntry(
                sourceIssueID: Identifier.constant("GH-1280"),
                sourceEvidenceID: submitEvidenceID,
                sequence: 2,
                kind: .submitAccepted,
                localOMSState: "submitted",
                brokerStatus: "redactedSubmitAcceptedEvidence"
            ),
            ReleaseV0210CanaryOMSEventLogEntry(
                sourceIssueID: Identifier.constant("GH-1282"),
                sourceEvidenceID: reconciliationEvidenceID,
                sequence: 3,
                kind: .statusResponse,
                localOMSState: "working",
                brokerStatus: "redactedStatusResponse"
            ),
            ReleaseV0210CanaryOMSEventLogEntry(
                sourceIssueID: Identifier.constant("GH-1281"),
                sourceEvidenceID: cancelEvidenceID,
                sequence: 4,
                kind: .cancelRequest,
                localOMSState: "pendingCancel",
                brokerStatus: "redactedCancelRequestEvidence"
            ),
            ReleaseV0210CanaryOMSEventLogEntry(
                sourceIssueID: Identifier.constant("GH-1281"),
                sourceEvidenceID: cancelEvidenceID,
                sequence: 5,
                kind: .cancelOutcome,
                localOMSState: "cancelled",
                brokerStatus: "redactedCancelOutcomeEvidence"
            ),
            ReleaseV0210CanaryOMSEventLogEntry(
                sourceIssueID: Identifier.constant("GH-1281"),
                sourceEvidenceID: cancelEvidenceID,
                sequence: 6,
                kind: .rollbackGuard,
                localOMSState: "cancelledRollbackGuarded",
                brokerStatus: "statusRollbackGuarded"
            ),
            ReleaseV0210CanaryOMSEventLogEntry(
                sourceIssueID: Identifier.constant("GH-1282"),
                sourceEvidenceID: reconciliationEvidenceID,
                sequence: 7,
                kind: .reconciliation,
                localOMSState: "reconciled",
                brokerStatus: "matchedRedactedLifecycle"
            )
        ]
    }

    public static func deterministicID(
        policy: ReleaseV0210CanaryOMSReconciliationPolicy,
        upstreamCancelDecision: ReleaseV0210ControlledCanaryCancelRollbackDecision,
        outcome: ReleaseV0210CanaryOMSReconciliationOutcome
    ) -> Identifier {
        .constant(
            [
                "gh-1282-v0210-canary-oms-reconciliation-decision",
                upstreamCancelDecision.decisionID.rawValue,
                policy.reconciliationDigest,
                outcome.rawValue
            ].joined(separator: ":"),
            field: "releaseV0210.canaryOMS.reconciliation.decisionID"
        )
    }

    public static let requiredValidationAnchors = [
        "GH-1282-VERIFY-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION",
        "TVM-RELEASE-V0210-CANARY-OMS-EVENT-LOG-RECONCILIATION",
        "V0210-010-OMS-EVENT-LOG",
        "V0210-010-CANARY-LIFECYCLE-EVENTS",
        "V0210-010-STATUS-RESPONSES",
        "V0210-010-CANCEL-OUTCOMES",
        "V0210-010-RECONCILIATION-EVIDENCE",
        "V0210-010-REDACTED-EVIDENCE",
        "V0210-010-NO-BROAD-OMS-ROLLOUT",
        "V0210-010-NO-PRODUCTION-CUTOVER"
    ]
}

private extension ReleaseV0210CanaryOMSReconciliationDecision {
    static func validateForbiddenFlags(
        broadProductionOMSRuntimeEnabled: Bool,
        futuresReconciliationEnabled: Bool,
        okxReconciliationEnabled: Bool,
        rawBrokerPayloadPersisted: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("broadProductionOMSRuntimeEnabled", broadProductionOMSRuntimeEnabled),
            ("futuresReconciliationEnabled", futuresReconciliationEnabled),
            ("okxReconciliationEnabled", okxReconciliationEnabled),
            ("rawBrokerPayloadPersisted", rawBrokerPayloadPersisted),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.canaryOMS.reconciliation.\(field)"
            )
        }
    }
}

/// ReleaseV0210CanaryOMSEventLogReconciliationEvidence 是 GH-1282 的 stage
/// evidence。
///
/// Evidence 证明 GH-1280 / GH-1281 后，系统能用 redacted OMS event log 与 reconciliation
/// evidence 重构单笔 Binance Spot canary 生命周期。它不扩大到 production OMS runtime，不读原始 broker
/// payload，不连接 production endpoint，不暴露命令 UI，也不授权 production cutover。
public struct ReleaseV0210CanaryOMSEventLogReconciliationEvidence:
    Codable, Equatable, Sendable
{
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let upstreamCancelEvidence: ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence
    public let matchedDecision: ReleaseV0210CanaryOMSReconciliationDecision
    public let upstreamRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision
    public let eventLogRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision
    public let statusRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision
    public let cancelOutcomeRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision
    public let reconciliationRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision
    public let redactionRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let omsEventLogRequired: Bool
    public let statusResponseRequired: Bool
    public let cancelOutcomeRequired: Bool
    public let reconciliationEvidenceRequired: Bool
    public let redactedEvidenceRequired: Bool
    public let canaryLifecycleReconstructionRequired: Bool
    public let readOnlyStatusSurfaceIsDownstreamOnly: Bool
    public let broadProductionOMSRuntimeEnabled: Bool
    public let futuresReconciliationEnabled: Bool
    public let okxReconciliationEnabled: Bool
    public let rawOrderIDPersisted: Bool
    public let rawStatusPayloadPersisted: Bool
    public let rawCancelPayloadPersisted: Bool
    public let rawBrokerPayloadPersisted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1282"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1280", "GH-1281"]
            && downstreamIssueID.rawValue == "GH-1283"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && namespaceHeld
            && upstreamCancelEvidence.evidenceHeld
            && decisionEvidenceHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && requiredControlsHeld
            && forbiddenCapabilitiesClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
    }

    public var requiredControlsHeld: Bool {
        omsEventLogRequired
            && statusResponseRequired
            && cancelOutcomeRequired
            && reconciliationEvidenceRequired
            && redactedEvidenceRequired
            && canaryLifecycleReconstructionRequired
            && readOnlyStatusSurfaceIsDownstreamOnly
    }

    public var decisionEvidenceHeld: Bool {
        matchedDecision.decisionHeld
            && matchedDecision.outcome == .matched
            && matchedDecision.eventKinds == ReleaseV0210CanaryOMSEventLogEntry.requiredLifecycleKinds
            && matchedDecision.canaryLifecycleReconstructable
            && upstreamRejectedDecision.rejectReasons == [.upstreamCancelRejected]
            && eventLogRejectedDecision.rejectReasons.contains(.eventLogMissing)
            && eventLogRejectedDecision.rejectReasons.contains(.lifecycleEventsIncomplete)
            && statusRejectedDecision.rejectReasons == [.statusResponseMissing]
            && cancelOutcomeRejectedDecision.rejectReasons == [.cancelOutcomeMissing]
            && reconciliationRejectedDecision.rejectReasons == [.reconciliationEvidenceMissing]
            && redactionRejectedDecision.rejectReasons == [.redactedEvidenceMissing]
            && [
                upstreamRejectedDecision,
                eventLogRejectedDecision,
                statusRejectedDecision,
                cancelOutcomeRejectedDecision,
                reconciliationRejectedDecision,
                redactionRejectedDecision
            ].allSatisfy {
                $0.decisionHeld
                    && $0.outcome == .rejected
                    && $0.canaryLifecycleReconstructable == false
                    && $0.forwardsToReadOnlyStatusSurface == false
            }
    }

    public var forbiddenCapabilitiesClosed: Bool {
        broadProductionOMSRuntimeEnabled == false
            && futuresReconciliationEnabled == false
            && okxReconciliationEnabled == false
            && rawOrderIDPersisted == false
            && rawStatusPayloadPersisted == false
            && rawCancelPayloadPersisted == false
            && rawBrokerPayloadPersisted == false
            && productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionEndpointConnected == false
            && productionBrokerConnectionEnabled == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1282-release-v0.21.0-canary-oms-event-log-reconciliation-evidence"),
        issueID: Identifier = Identifier.constant("GH-1282"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-1280"),
            Identifier.constant("GH-1281")
        ],
        downstreamIssueID: Identifier = Identifier.constant("GH-1283"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamCancelEvidence: ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        omsEventLogRequired: Bool = true,
        statusResponseRequired: Bool = true,
        cancelOutcomeRequired: Bool = true,
        reconciliationEvidenceRequired: Bool = true,
        redactedEvidenceRequired: Bool = true,
        canaryLifecycleReconstructionRequired: Bool = true,
        readOnlyStatusSurfaceIsDownstreamOnly: Bool = true,
        broadProductionOMSRuntimeEnabled: Bool = false,
        futuresReconciliationEnabled: Bool = false,
        okxReconciliationEnabled: Bool = false,
        rawOrderIDPersisted: Bool = false,
        rawStatusPayloadPersisted: Bool = false,
        rawCancelPayloadPersisted: Bool = false,
        rawBrokerPayloadPersisted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        createsTagOrRelease: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let resolvedCancelEvidence = try upstreamCancelEvidence
            ?? ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence.deterministicFixture()
        let matched = try ReleaseV0210CanaryOMSReconciliationDecision(
            policy: .deterministicFixture(),
            upstreamCancelEvidence: resolvedCancelEvidence
        )
        let upstreamRejected = try ReleaseV0210CanaryOMSReconciliationDecision(
            policy: .deterministicFixture(),
            upstreamCancelEvidence: resolvedCancelEvidence,
            upstreamCancelDecision: resolvedCancelEvidence.approvalRejectedDecision
        )
        let eventLogRejected = try ReleaseV0210CanaryOMSReconciliationDecision(
            policy: .eventLogMissingFixture(),
            upstreamCancelEvidence: resolvedCancelEvidence
        )
        let statusRejected = try ReleaseV0210CanaryOMSReconciliationDecision(
            policy: .statusResponseMissingFixture(),
            upstreamCancelEvidence: resolvedCancelEvidence
        )
        let cancelOutcomeRejected = try ReleaseV0210CanaryOMSReconciliationDecision(
            policy: .cancelOutcomeMissingFixture(),
            upstreamCancelEvidence: resolvedCancelEvidence
        )
        let reconciliationRejected = try ReleaseV0210CanaryOMSReconciliationDecision(
            policy: .reconciliationMissingFixture(),
            upstreamCancelEvidence: resolvedCancelEvidence
        )
        let redactionRejected = try ReleaseV0210CanaryOMSReconciliationDecision(
            policy: .redactionMissingFixture(),
            upstreamCancelEvidence: resolvedCancelEvidence
        )

        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueIDs: upstreamIssueIDs,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: tradingEnvironment,
            upstreamCancelEvidence: resolvedCancelEvidence,
            matchedDecision: matched,
            upstreamRejectedDecision: upstreamRejected,
            eventLogRejectedDecision: eventLogRejected,
            statusRejectedDecision: statusRejected,
            cancelOutcomeRejectedDecision: cancelOutcomeRejected,
            reconciliationRejectedDecision: reconciliationRejected,
            redactionRejectedDecision: redactionRejected,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            omsEventLogRequired: omsEventLogRequired,
            statusResponseRequired: statusResponseRequired,
            cancelOutcomeRequired: cancelOutcomeRequired,
            reconciliationEvidenceRequired: reconciliationEvidenceRequired,
            redactedEvidenceRequired: redactedEvidenceRequired,
            canaryLifecycleReconstructionRequired: canaryLifecycleReconstructionRequired,
            readOnlyStatusSurfaceIsDownstreamOnly: readOnlyStatusSurfaceIsDownstreamOnly
        )
        try Self.validateForbiddenFlags(
            broadProductionOMSRuntimeEnabled: broadProductionOMSRuntimeEnabled,
            futuresReconciliationEnabled: futuresReconciliationEnabled,
            okxReconciliationEnabled: okxReconciliationEnabled,
            rawOrderIDPersisted: rawOrderIDPersisted,
            rawStatusPayloadPersisted: rawStatusPayloadPersisted,
            rawCancelPayloadPersisted: rawCancelPayloadPersisted,
            rawBrokerPayloadPersisted: rawBrokerPayloadPersisted,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            productionEndpointConnected: productionEndpointConnected,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            createsTagOrRelease: createsTagOrRelease,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.upstreamCancelEvidence = resolvedCancelEvidence
        self.matchedDecision = matched
        self.upstreamRejectedDecision = upstreamRejected
        self.eventLogRejectedDecision = eventLogRejected
        self.statusRejectedDecision = statusRejected
        self.cancelOutcomeRejectedDecision = cancelOutcomeRejected
        self.reconciliationRejectedDecision = reconciliationRejected
        self.redactionRejectedDecision = redactionRejected
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.omsEventLogRequired = omsEventLogRequired
        self.statusResponseRequired = statusResponseRequired
        self.cancelOutcomeRequired = cancelOutcomeRequired
        self.reconciliationEvidenceRequired = reconciliationEvidenceRequired
        self.redactedEvidenceRequired = redactedEvidenceRequired
        self.canaryLifecycleReconstructionRequired = canaryLifecycleReconstructionRequired
        self.readOnlyStatusSurfaceIsDownstreamOnly = readOnlyStatusSurfaceIsDownstreamOnly
        self.broadProductionOMSRuntimeEnabled = broadProductionOMSRuntimeEnabled
        self.futuresReconciliationEnabled = futuresReconciliationEnabled
        self.okxReconciliationEnabled = okxReconciliationEnabled
        self.rawOrderIDPersisted = rawOrderIDPersisted
        self.rawStatusPayloadPersisted = rawStatusPayloadPersisted
        self.rawCancelPayloadPersisted = rawCancelPayloadPersisted
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws
        -> ReleaseV0210CanaryOMSEventLogReconciliationEvidence
    {
        try ReleaseV0210CanaryOMSEventLogReconciliationEvidence()
    }

    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredValidationAnchors =
        ReleaseV0210CanaryOMSReconciliationDecision.requiredValidationAnchors
    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1282ReleaseV0210CanaryOMSEventLogReconciliationEvidence",
        "bash checks/verify-v0.21.0-canary-oms-event-log-reconciliation.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV0210CanaryOMSEventLogReconciliationEvidence {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueIDs: [Identifier],
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        tradingEnvironment: ReleaseV0181TradingEnvironment,
        upstreamCancelEvidence: ReleaseV0210ControlledCanaryCancelRollbackGuardEvidence,
        matchedDecision: ReleaseV0210CanaryOMSReconciliationDecision,
        upstreamRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision,
        eventLogRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision,
        statusRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision,
        cancelOutcomeRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision,
        reconciliationRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision,
        redactionRejectedDecision: ReleaseV0210CanaryOMSReconciliationDecision,
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("issueID", issueID.rawValue == "GH-1282", "GH-1282", issueID.rawValue),
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == ["GH-1280", "GH-1281"], "GH-1280,GH-1281", upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("downstreamIssueID", downstreamIssueID.rawValue == "GH-1283", "GH-1283", downstreamIssueID.rawValue),
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName, ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.21.0", "v0.21.0", releaseVersion),
            ("venueID", venueID == .binance, ReleaseV0181VenueID.binance.rawValue, venueID.rawValue),
            ("productKind", productKind == .spot, ReleaseV0181ProductKind.spot.rawValue, productKind.rawValue),
            ("tradingEnvironment", tradingEnvironment == .productionLive, ReleaseV0181TradingEnvironment.productionLive.rawValue, tradingEnvironment.rawValue),
            ("upstreamCancelEvidence", upstreamCancelEvidence.evidenceHeld, "GH-1281 cancel rollback evidence held", upstreamCancelEvidence.issueID.rawValue),
            ("matchedDecision", matchedDecision.decisionHeld && matchedDecision.outcome == .matched, "matched canary OMS reconciliation", matchedDecision.outcome.rawValue),
            ("upstreamRejectedDecision", upstreamRejectedDecision.rejectReasons == [.upstreamCancelRejected], "upstream cancel rejection", upstreamRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("eventLogRejectedDecision", eventLogRejectedDecision.rejectReasons.contains(.eventLogMissing), "event log rejection", eventLogRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("statusRejectedDecision", statusRejectedDecision.rejectReasons == [.statusResponseMissing], "status response rejection", statusRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("cancelOutcomeRejectedDecision", cancelOutcomeRejectedDecision.rejectReasons == [.cancelOutcomeMissing], "cancel outcome rejection", cancelOutcomeRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("reconciliationRejectedDecision", reconciliationRejectedDecision.rejectReasons == [.reconciliationEvidenceMissing], "reconciliation rejection", reconciliationRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("redactionRejectedDecision", redactionRejectedDecision.rejectReasons == [.redactedEvidenceMissing], "redaction rejection", redactionRejectedDecision.rejectReasons.map(\.rawValue).joined(separator: ",")),
            ("validationAnchors", validationAnchors == requiredValidationAnchors, requiredValidationAnchors.joined(separator: ","), validationAnchors.joined(separator: ",")),
            ("requiredValidationCommands", requiredValidationCommands == Self.requiredValidationCommands, Self.requiredValidationCommands.joined(separator: ","), requiredValidationCommands.joined(separator: ","))
        ]

        for (field, passed, expected, actual) in checks where passed == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryOMS.evidence.\(field)",
                expected: expected,
                actual: actual
            )
        }
    }

    static func validateRequiredTrueFlags(
        omsEventLogRequired: Bool,
        statusResponseRequired: Bool,
        cancelOutcomeRequired: Bool,
        reconciliationEvidenceRequired: Bool,
        redactedEvidenceRequired: Bool,
        canaryLifecycleReconstructionRequired: Bool,
        readOnlyStatusSurfaceIsDownstreamOnly: Bool
    ) throws {
        for (field, value) in [
            ("omsEventLogRequired", omsEventLogRequired),
            ("statusResponseRequired", statusResponseRequired),
            ("cancelOutcomeRequired", cancelOutcomeRequired),
            ("reconciliationEvidenceRequired", reconciliationEvidenceRequired),
            ("redactedEvidenceRequired", redactedEvidenceRequired),
            ("canaryLifecycleReconstructionRequired", canaryLifecycleReconstructionRequired),
            ("readOnlyStatusSurfaceIsDownstreamOnly", readOnlyStatusSurfaceIsDownstreamOnly)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryOMS.evidence.\(field)",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        broadProductionOMSRuntimeEnabled: Bool,
        futuresReconciliationEnabled: Bool,
        okxReconciliationEnabled: Bool,
        rawOrderIDPersisted: Bool,
        rawStatusPayloadPersisted: Bool,
        rawCancelPayloadPersisted: Bool,
        rawBrokerPayloadPersisted: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        productionEndpointConnected: Bool,
        productionBrokerConnectionEnabled: Bool,
        createsTagOrRelease: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("broadProductionOMSRuntimeEnabled", broadProductionOMSRuntimeEnabled),
            ("futuresReconciliationEnabled", futuresReconciliationEnabled),
            ("okxReconciliationEnabled", okxReconciliationEnabled),
            ("rawOrderIDPersisted", rawOrderIDPersisted),
            ("rawStatusPayloadPersisted", rawStatusPayloadPersisted),
            ("rawCancelPayloadPersisted", rawCancelPayloadPersisted),
            ("rawBrokerPayloadPersisted", rawBrokerPayloadPersisted),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("createsTagOrRelease", createsTagOrRelease),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0210.canaryOMS.evidence.\(field)"
            )
        }
    }
}
