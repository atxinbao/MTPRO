import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV0220SpotLiveCanaryOMSEventKind 固定 GH-1315 的 OMS event log
/// 事件类型。它只描述 Binance Spot canary submit ack、status、cancel 和终态证据，
/// 不表达 Futures / OKX、Dashboard 交易控件或 production cutover。
public enum ReleaseV0220SpotLiveCanaryOMSEventKind:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case submitAck = "submit ack"
    case statusObservation = "status observation"
    case cancelRequest = "cancel request"
    case cancelAck = "cancel ack"
    case cancelReject = "cancel reject"
    case terminalState = "terminal state"
    case ambiguousState = "ambiguous state"
}

/// ReleaseV0220SpotLiveCanaryOMSEventLogRejectReason 是 GH-1315 的
/// append-only OMS event log fail-closed 分类。
public enum ReleaseV0220SpotLiveCanaryOMSEventLogRejectReason:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamSubmitTransportMissing = "upstream submit transport missing"
    case upstreamStatusCancelTransportMissing = "upstream status cancel transport missing"
    case missingSubmitAck = "missing submit ack"
    case missingStatusObservation = "missing status observation"
    case missingCancelRequest = "missing cancel request"
    case missingCancelOutcome = "missing cancel outcome"
    case missingTerminalState = "missing terminal state"
    case missingAmbiguousStateEvidence = "missing ambiguous state evidence"
    case outOfOrderLifecycle = "out-of-order lifecycle"
    case sequenceGap = "sequence gap"
    case correlationMismatch = "correlation mismatch"
    case causationMismatch = "causation mismatch"
    case rawPayloadPersisted = "raw payload persisted"
    case rawCredentialValuePersisted = "raw credential value persisted"
    case signaturePersisted = "signature persisted"
    case futuresExecutionEnabled = "futures execution enabled"
    case okxActiveImplementationEnabled = "okx active implementation enabled"
    case dashboardTradingCommandEnabled = "dashboard trading command enabled"
    case productionCutoverAuthorized = "production cutover authorized"
}

/// ReleaseV0220SpotLiveCanaryOMSEventLogEntry 是 GH-1315 append-only OMS
/// event log 的单条脱敏事件。事件只保存 redacted evidence reference 和 correlation /
/// causation identifiers，不保存 raw exchange ack、raw status、raw cancel payload、secret
/// 或 signature。
public struct ReleaseV0220SpotLiveCanaryOMSEventLogEntry:
    Codable, Equatable, Sendable
{
    public let sequence: Int
    public let eventID: Identifier
    public let eventKind: ReleaseV0220SpotLiveCanaryOMSEventKind
    public let runID: Identifier
    public let clientOrderID: Identifier
    public let exchangeOrderID: Identifier
    public let correlationID: Identifier
    public let causationID: Identifier
    public let redactedEvidenceReference: String
    public let replayable: Bool
    public let requiresReconciliation: Bool
    public let rawPayloadPersisted: Bool
    public let rawCredentialValuePersisted: Bool
    public let signaturePersisted: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var redactedReferenceHeld: Bool {
        redactedEvidenceReference.hasPrefix(Self.requiredRedactedReferencePrefix)
            && redactedEvidenceReference.contains("<redacted>")
            && redactedEvidenceReference.lowercased().contains("signature=") == false
            && redactedEvidenceReference.lowercased().contains("secret") == false
            && redactedEvidenceReference.lowercased().contains("raw") == false
    }

    public var namespaceHeld: Bool {
        runID == Self.requiredRunID
            && clientOrderID == Self.requiredClientOrderID
            && exchangeOrderID == Self.requiredExchangeOrderID
            && correlationID == Self.requiredCorrelationID
    }

    public var forbiddenCapabilitiesClosed: Bool {
        rawPayloadPersisted == false
            && rawCredentialValuePersisted == false
            && signaturePersisted == false
            && futuresExecutionEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingCommandEnabled == false
            && productionCutoverAuthorized == false
    }

    public var entryHeld: Bool {
        sequence > 0
            && namespaceHeld
            && redactedReferenceHeld
            && replayable
            && forbiddenCapabilitiesClosed
    }

    public init(
        sequence: Int,
        eventKind: ReleaseV0220SpotLiveCanaryOMSEventKind,
        eventID: Identifier? = nil,
        runID: Identifier = Self.requiredRunID,
        clientOrderID: Identifier = Self.requiredClientOrderID,
        exchangeOrderID: Identifier = Self.requiredExchangeOrderID,
        correlationID: Identifier = Self.requiredCorrelationID,
        causationID: Identifier = Self.requiredRootCausationID,
        redactedEvidenceReference: String? = nil,
        replayable: Bool = true,
        requiresReconciliation: Bool = false,
        rawPayloadPersisted: Bool = false,
        rawCredentialValuePersisted: Bool = false,
        signaturePersisted: Bool = false,
        futuresExecutionEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try Self.validateForbiddenFlags(
            rawPayloadPersisted: rawPayloadPersisted,
            rawCredentialValuePersisted: rawCredentialValuePersisted,
            signaturePersisted: signaturePersisted,
            futuresExecutionEnabled: futuresExecutionEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardTradingCommandEnabled: dashboardTradingCommandEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.sequence = sequence
        self.eventID = eventID ?? Self.deterministicEventID(sequence: sequence, eventKind: eventKind)
        self.eventKind = eventKind
        self.runID = runID
        self.clientOrderID = clientOrderID
        self.exchangeOrderID = exchangeOrderID
        self.correlationID = correlationID
        self.causationID = causationID
        self.redactedEvidenceReference = redactedEvidenceReference
            ?? Self.redactedEvidenceReference(sequence: sequence, eventKind: eventKind)
        self.replayable = replayable
        self.requiresReconciliation = requiresReconciliation
        self.rawPayloadPersisted = rawPayloadPersisted
        self.rawCredentialValuePersisted = rawCredentialValuePersisted
        self.signaturePersisted = signaturePersisted
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func acceptedLifecycleEntries() throws -> [ReleaseV0220SpotLiveCanaryOMSEventLogEntry] {
        let submit = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry(
            sequence: 1,
            eventKind: .submitAck,
            causationID: Self.requiredRootCausationID
        )
        let status = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry(
            sequence: 2,
            eventKind: .statusObservation,
            causationID: submit.eventID
        )
        let cancelRequest = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry(
            sequence: 3,
            eventKind: .cancelRequest,
            causationID: status.eventID
        )
        let cancelAck = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry(
            sequence: 4,
            eventKind: .cancelAck,
            causationID: cancelRequest.eventID
        )
        let terminal = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry(
            sequence: 5,
            eventKind: .terminalState,
            causationID: cancelAck.eventID
        )
        let ambiguous = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry(
            sequence: 6,
            eventKind: .ambiguousState,
            causationID: terminal.eventID,
            requiresReconciliation: true
        )
        return [submit, status, cancelRequest, cancelAck, terminal, ambiguous]
    }

    public static func deterministicEventID(
        sequence: Int,
        eventKind: ReleaseV0220SpotLiveCanaryOMSEventKind
    ) -> Identifier {
        .constant(
            "gh-1315-v0220-oms-event-\(sequence)-\(eventKind.rawValue)",
            field: "releaseV0220.omsEventLog.eventID"
        )
    }

    public static func redactedEvidenceReference(
        sequence: Int,
        eventKind: ReleaseV0220SpotLiveCanaryOMSEventKind
    ) -> String {
        "\(requiredRedactedReferencePrefix) seq=\(sequence) kind=\(eventKind.rawValue) runID=<redacted> clientOrderId=<redacted> exchangeOrderId=<redacted>"
    }

    public static let requiredRedactedReferencePrefix = "redacted-oms-event:gh-1315"
    public static let requiredRunID = ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy.requiredRunID
    public static let requiredClientOrderID =
        ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy.requiredClientOrderID
    public static let requiredExchangeOrderID =
        ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy.requiredExchangeOrderID
    public static let requiredCorrelationID = Identifier.constant(
        "gh-1315-v0220-oms-event-log-correlation",
        field: "releaseV0220.omsEventLog.correlationID"
    )
    public static let requiredRootCausationID = Identifier.constant(
        "gh-1315-v0220-oms-event-log-root-causation",
        field: "releaseV0220.omsEventLog.causationID"
    )
}

private extension ReleaseV0220SpotLiveCanaryOMSEventLogEntry {
    static func validateForbiddenFlags(
        rawPayloadPersisted: Bool,
        rawCredentialValuePersisted: Bool,
        signaturePersisted: Bool,
        futuresExecutionEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardTradingCommandEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("rawPayloadPersisted", rawPayloadPersisted),
            ("rawCredentialValuePersisted", rawCredentialValuePersisted),
            ("signaturePersisted", signaturePersisted),
            ("futuresExecutionEnabled", futuresExecutionEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardTradingCommandEnabled", dashboardTradingCommandEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0220.omsEventLog.\(field)"
            )
        }
    }
}

/// ReleaseV0220SpotLiveCanaryOMSEventLog 是 GH-1315 的 append-only OMS event log
/// 证据集合。它按 sequence 校验事件顺序，并用 correlation / causation identifiers
/// 证明 submit ack、status、cancel、terminal 和 ambiguous evidence 属于同一 canary run。
public struct ReleaseV0220SpotLiveCanaryOMSEventLog:
    Codable, Equatable, Sendable
{
    public let logID: Identifier
    public let entries: [ReleaseV0220SpotLiveCanaryOMSEventLogEntry]
    public let rejectReasons: [ReleaseV0220SpotLiveCanaryOMSEventLogRejectReason]

    public var acceptedLogHeld: Bool {
        rejectReasons.isEmpty
            && entries.count == 6
            && entries.allSatisfy(\.entryHeld)
            && replayEventKinds == Self.requiredReplayEventKinds
            && entries.last?.requiresReconciliation == true
    }

    public var failClosedLogHeld: Bool {
        rejectReasons.isEmpty == false
            && entries.allSatisfy(\.forbiddenCapabilitiesClosed)
    }

    public var replayEventKinds: [ReleaseV0220SpotLiveCanaryOMSEventKind] {
        entries.map(\.eventKind)
    }

    public init(
        logID: Identifier = Identifier.constant("gh-1315-v0220-oms-event-log"),
        entries: [ReleaseV0220SpotLiveCanaryOMSEventLogEntry]
    ) {
        self.logID = logID
        self.entries = entries
        self.rejectReasons = Self.expectedRejectReasons(entries: entries)
    }

    public static func acceptedFixture() throws -> ReleaseV0220SpotLiveCanaryOMSEventLog {
        ReleaseV0220SpotLiveCanaryOMSEventLog(
            entries: try ReleaseV0220SpotLiveCanaryOMSEventLogEntry.acceptedLifecycleEntries()
        )
    }

    public static func missingStatusFixture() throws -> ReleaseV0220SpotLiveCanaryOMSEventLog {
        let entries = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry.acceptedLifecycleEntries()
        return ReleaseV0220SpotLiveCanaryOMSEventLog(
            entries: entries.filter { $0.eventKind != .statusObservation }
        )
    }

    public static func missingCancelOutcomeFixture() throws -> ReleaseV0220SpotLiveCanaryOMSEventLog {
        let entries = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry.acceptedLifecycleEntries()
        return ReleaseV0220SpotLiveCanaryOMSEventLog(
            entries: entries.filter { $0.eventKind != .cancelAck && $0.eventKind != .cancelReject }
        )
    }

    public static func outOfOrderFixture() throws -> ReleaseV0220SpotLiveCanaryOMSEventLog {
        var entries = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry.acceptedLifecycleEntries()
        entries.swapAt(1, 2)
        return ReleaseV0220SpotLiveCanaryOMSEventLog(entries: entries)
    }

    public static func correlationMismatchFixture() throws -> ReleaseV0220SpotLiveCanaryOMSEventLog {
        var entries = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry.acceptedLifecycleEntries()
        let mismatched = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry(
            sequence: entries[2].sequence,
            eventKind: entries[2].eventKind,
            eventID: entries[2].eventID,
            correlationID: Identifier.constant(
                "gh-1315-v0220-oms-event-log-mismatched-correlation",
                field: "releaseV0220.omsEventLog.correlationID"
            ),
            causationID: entries[2].causationID,
            redactedEvidenceReference: entries[2].redactedEvidenceReference
        )
        entries[2] = mismatched
        return ReleaseV0220SpotLiveCanaryOMSEventLog(entries: entries)
    }

    public static func rawPayloadRejectedFixture() throws -> ReleaseV0220SpotLiveCanaryOMSEventLog {
        let rawEntry = try ReleaseV0220SpotLiveCanaryOMSEventLogEntry(
            sequence: 1,
            eventKind: .submitAck,
            redactedEvidenceReference: "raw exchange ack payload"
        )
        return ReleaseV0220SpotLiveCanaryOMSEventLog(entries: [rawEntry])
    }

    public static func expectedRejectReasons(
        entries: [ReleaseV0220SpotLiveCanaryOMSEventLogEntry]
    ) -> [ReleaseV0220SpotLiveCanaryOMSEventLogRejectReason] {
        var reasons: [ReleaseV0220SpotLiveCanaryOMSEventLogRejectReason] = []
        let kinds = entries.map(\.eventKind)
        if kinds.contains(.submitAck) == false {
            reasons.append(.missingSubmitAck)
        }
        if kinds.contains(.statusObservation) == false {
            reasons.append(.missingStatusObservation)
        }
        if kinds.contains(.cancelRequest) == false {
            reasons.append(.missingCancelRequest)
        }
        if kinds.contains(.cancelAck) == false && kinds.contains(.cancelReject) == false {
            reasons.append(.missingCancelOutcome)
        }
        if kinds.contains(.terminalState) == false {
            reasons.append(.missingTerminalState)
        }
        if kinds.contains(.ambiguousState) == false {
            reasons.append(.missingAmbiguousStateEvidence)
        }

        let expectedSequences = Array(1...entries.count)
        if entries.map(\.sequence) != expectedSequences {
            reasons.append(.sequenceGap)
        }
        if kinds != Self.requiredReplayEventKinds {
            reasons.append(.outOfOrderLifecycle)
        }
        if Set(entries.map(\.correlationID)).count > 1 {
            reasons.append(.correlationMismatch)
        }
        if Self.causationChainHeld(entries: entries) == false {
            reasons.append(.causationMismatch)
        }
        if entries.contains(where: { $0.redactedReferenceHeld == false || $0.rawPayloadPersisted }) {
            reasons.append(.rawPayloadPersisted)
        }
        if entries.contains(where: \.rawCredentialValuePersisted) {
            reasons.append(.rawCredentialValuePersisted)
        }
        if entries.contains(where: \.signaturePersisted) {
            reasons.append(.signaturePersisted)
        }
        if entries.contains(where: \.futuresExecutionEnabled) {
            reasons.append(.futuresExecutionEnabled)
        }
        if entries.contains(where: \.okxActiveImplementationEnabled) {
            reasons.append(.okxActiveImplementationEnabled)
        }
        if entries.contains(where: \.dashboardTradingCommandEnabled) {
            reasons.append(.dashboardTradingCommandEnabled)
        }
        if entries.contains(where: \.productionCutoverAuthorized) {
            reasons.append(.productionCutoverAuthorized)
        }
        return reasons
    }

    public static func causationChainHeld(
        entries: [ReleaseV0220SpotLiveCanaryOMSEventLogEntry]
    ) -> Bool {
        guard let first = entries.first else {
            return false
        }
        guard first.causationID == ReleaseV0220SpotLiveCanaryOMSEventLogEntry.requiredRootCausationID else {
            return false
        }
        guard entries.count > 1 else {
            return true
        }
        for index in entries.indices.dropFirst() where entries[index].causationID != entries[index - 1].eventID {
            return false
        }
        return true
    }

    public static let requiredReplayEventKinds: [ReleaseV0220SpotLiveCanaryOMSEventKind] = [
        .submitAck,
        .statusObservation,
        .cancelRequest,
        .cancelAck,
        .terminalState,
        .ambiguousState
    ]
}

/// ReleaseV0220SpotLiveCanaryOMSEventLogEvidence 是 GH-1315 的 OMS event log
/// 证据合同。它证明 GH-1313 submit ack 与 GH-1314 status / cancel evidence 已进入
/// 同一个 append-only、redacted、replayable OMS event log。
public struct ReleaseV0220SpotLiveCanaryOMSEventLogEvidence:
    Codable, Equatable, Sendable
{
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let upstreamSubmitTransport: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence
    public let upstreamStatusCancelTransport: ReleaseV0220SpotLiveCanaryStatusCancelTransportEvidence
    public let acceptedEventLog: ReleaseV0220SpotLiveCanaryOMSEventLog
    public let missingStatusObservationLog: ReleaseV0220SpotLiveCanaryOMSEventLog
    public let missingCancelOutcomeLog: ReleaseV0220SpotLiveCanaryOMSEventLog
    public let outOfOrderLifecycleLog: ReleaseV0220SpotLiveCanaryOMSEventLog
    public let correlationMismatchLog: ReleaseV0220SpotLiveCanaryOMSEventLog
    public let rawPayloadRejectedLog: ReleaseV0220SpotLiveCanaryOMSEventLog
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let appendOnlyOrderingRequired: Bool
    public let correlationCausationIDsRequired: Bool
    public let redactedReplayableEvidenceRequired: Bool
    public let missingOrOutOfOrderLifecycleFailsClosed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1315"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1313", "GH-1314"]
            && downstreamIssueIDs.map(\.rawValue) == ["GH-1316"]
            && canonicalQueueRange == "GH-1309..GH-1320"
            && releaseVersion == "v0.22.0"
            && namespaceHeld
            && upstreamSubmitTransport.evidenceHeld
            && upstreamStatusCancelTransport.evidenceHeld
            && eventLogsHeld
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

    public var eventLogsHeld: Bool {
        acceptedEventLog.acceptedLogHeld
            && missingStatusObservationLog.rejectReasons.contains(.missingStatusObservation)
            && missingCancelOutcomeLog.rejectReasons.contains(.missingCancelOutcome)
            && outOfOrderLifecycleLog.rejectReasons.contains(.outOfOrderLifecycle)
            && correlationMismatchLog.rejectReasons.contains(.correlationMismatch)
            && rawPayloadRejectedLog.rejectReasons.contains(.rawPayloadPersisted)
            && [
                missingStatusObservationLog,
                missingCancelOutcomeLog,
                outOfOrderLifecycleLog,
                correlationMismatchLog,
                rawPayloadRejectedLog
            ].allSatisfy(\.failClosedLogHeld)
    }

    public var requiredControlsHeld: Bool {
        appendOnlyOrderingRequired
            && correlationCausationIDsRequired
            && redactedReplayableEvidenceRequired
            && missingOrOutOfOrderLifecycleFailsClosed
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && futuresExecutionEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingCommandEnabled == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1315-release-v0.22.0-oms-event-log-evidence"),
        issueID: Identifier = Identifier.constant("GH-1315"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1313"), Identifier.constant("GH-1314")],
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1316")],
        canonicalQueueRange: String = "GH-1309..GH-1320",
        releaseVersion: String = "v0.22.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamSubmitTransport: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence? = nil,
        upstreamStatusCancelTransport: ReleaseV0220SpotLiveCanaryStatusCancelTransportEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        appendOnlyOrderingRequired: Bool = true,
        correlationCausationIDsRequired: Bool = true,
        redactedReplayableEvidenceRequired: Bool = true,
        missingOrOutOfOrderLifecycleFailsClosed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        futuresExecutionEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        createsTagOrRelease: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.evidenceID = evidenceID
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.releaseVersion = releaseVersion
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.upstreamSubmitTransport = try upstreamSubmitTransport
            ?? ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence.deterministicFixture()
        self.upstreamStatusCancelTransport = try upstreamStatusCancelTransport
            ?? ReleaseV0220SpotLiveCanaryStatusCancelTransportEvidence.deterministicFixture()
        self.acceptedEventLog = try ReleaseV0220SpotLiveCanaryOMSEventLog.acceptedFixture()
        self.missingStatusObservationLog = try ReleaseV0220SpotLiveCanaryOMSEventLog
            .missingStatusFixture()
        self.missingCancelOutcomeLog = try ReleaseV0220SpotLiveCanaryOMSEventLog
            .missingCancelOutcomeFixture()
        self.outOfOrderLifecycleLog = try ReleaseV0220SpotLiveCanaryOMSEventLog
            .outOfOrderFixture()
        self.correlationMismatchLog = try ReleaseV0220SpotLiveCanaryOMSEventLog
            .correlationMismatchFixture()
        self.rawPayloadRejectedLog = try ReleaseV0220SpotLiveCanaryOMSEventLog
            .rawPayloadRejectedFixture()
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.appendOnlyOrderingRequired = appendOnlyOrderingRequired
        self.correlationCausationIDsRequired = correlationCausationIDsRequired
        self.redactedReplayableEvidenceRequired = redactedReplayableEvidenceRequired
        self.missingOrOutOfOrderLifecycleFailsClosed = missingOrOutOfOrderLifecycleFailsClosed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.omsEventLog",
                expected: "append-only redacted OMS event log evidence",
                actual: "invalid OMS event log evidence"
            )
        }
    }

    public static func deterministicFixture() throws
        -> ReleaseV0220SpotLiveCanaryOMSEventLogEvidence
    {
        try ReleaseV0220SpotLiveCanaryOMSEventLogEvidence()
    }

    public static let requiredValidationAnchors = [
        "GH-1315-VERIFY-V0220-OMS-EVIDENCE-LOG",
        "TVM-RELEASE-V0220-OMS-EVIDENCE-LOG",
        "V0220-007-BLOCKED-BY-GH1313-GH1314",
        "V0220-007-APPEND-ONLY-OMS-EVENT-LOG",
        "V0220-007-SUBMIT-ACK-STATUS-CANCEL-TERMINAL-EVENTS",
        "V0220-007-CORRELATION-CAUSATION-IDS",
        "V0220-007-REDACTED-REPLAYABLE-EVIDENCE",
        "V0220-007-REJECTS-MISSING-OUT-OF-ORDER-LIFECYCLE",
        "V0220-007-NO-FUTURES-OKX",
        "V0220-007-NO-DASHBOARD-TRADING-CONTROLS",
        "V0220-007-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1315ReleaseV0220OMSEventLogPersistsExchangeAckStatusCancelEvidence",
        "bash checks/verify-v0.22.0-oms-evidence-log.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/verify-v0.21.0.sh",
        "bash checks/run.sh"
    ]
}
