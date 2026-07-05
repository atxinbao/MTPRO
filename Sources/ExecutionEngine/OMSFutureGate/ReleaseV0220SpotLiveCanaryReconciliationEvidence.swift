import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV0220SpotLiveCanaryReconciliationState 固定 GH-1316 的
/// Binance Spot canary OMS / exchange / account reconciliation 分类。
public enum ReleaseV0220SpotLiveCanaryReconciliationState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case matched
    case pending
    case ambiguous
    case rejected
    case cancelled
    case fillLike = "fill-like"
}

/// ReleaseV0220SpotLiveCanaryReconciliationNextAction 描述 GH-1316 artifact
/// 必须给 operator 留下的下一步动作。
public enum ReleaseV0220SpotLiveCanaryReconciliationNextAction:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case noActionTerminal = "no action terminal"
    case continueMonitoring = "continue monitoring"
    case operatorReview = "operator review"
    case doNotRetrySubmit = "do not retry submit"
    case stopAndEscalate = "stop and escalate"
}

/// ReleaseV0220SpotLiveCanaryReconciliationRejectReason 是 GH-1316 的
/// fail-closed / operator review 分类。
public enum ReleaseV0220SpotLiveCanaryReconciliationRejectReason:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case missingExchangeEvidence = "missing exchange evidence"
    case ambiguousExchangeState = "ambiguous exchange state"
    case localOnlyAssumptionRejected = "local-only assumption rejected"
    case missingOMSLogEvidence = "missing OMS log evidence"
    case rawPayloadPersisted = "raw payload persisted"
    case rawCredentialValuePersisted = "raw credential value persisted"
    case signaturePersisted = "signature persisted"
    case futuresReconciliationEnabled = "futures reconciliation enabled"
    case okxReconciliationEnabled = "OKX reconciliation enabled"
    case dashboardTradingCommandEnabled = "dashboard trading command enabled"
    case productionCutoverAuthorized = "production cutover authorized"
}

/// ReleaseV0220SpotLiveCanaryReconciliationArtifact 是 GH-1316 的单条脱敏
/// reconciliation artifact。它必须同时引用 OMS event log、exchange order status 和
/// signed account evidence；如果 exchange/account/order evidence 缺失或状态含糊，
/// artifact 必须 fail closed 并给出 operator next action。
public struct ReleaseV0220SpotLiveCanaryReconciliationArtifact:
    Codable, Equatable, Sendable
{
    public let artifactID: Identifier
    public let state: ReleaseV0220SpotLiveCanaryReconciliationState
    public let nextAction: ReleaseV0220SpotLiveCanaryReconciliationNextAction
    public let runID: Identifier
    public let clientOrderID: Identifier
    public let exchangeOrderID: Identifier
    public let omsEventLogEvidencePresent: Bool
    public let exchangeOrderStatusEvidencePresent: Bool
    public let signedAccountEvidencePresent: Bool
    public let localOnlyAssumptionRejected: Bool
    public let failClosed: Bool
    public let rejectReasons: [ReleaseV0220SpotLiveCanaryReconciliationRejectReason]
    public let redactedOMSReference: String
    public let redactedExchangeStatusReference: String
    public let redactedAccountReference: String
    public let redactedArtifactReference: String
    public let rawPayloadPersisted: Bool
    public let rawCredentialValuePersisted: Bool
    public let signaturePersisted: Bool
    public let futuresReconciliationEnabled: Bool
    public let okxReconciliationEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var namespaceHeld: Bool {
        runID == Self.requiredRunID
            && clientOrderID == Self.requiredClientOrderID
            && exchangeOrderID == Self.requiredExchangeOrderID
    }

    public var evidenceReferencesRedacted: Bool {
        [
            redactedOMSReference,
            redactedExchangeStatusReference,
            redactedAccountReference,
            redactedArtifactReference
        ].allSatisfy(Self.redactedReferenceHeld)
    }

    public var exchangeEvidenceHeld: Bool {
        omsEventLogEvidencePresent
            && exchangeOrderStatusEvidencePresent
            && signedAccountEvidencePresent
    }

    public var forbiddenCapabilitiesClosed: Bool {
        rawPayloadPersisted == false
            && rawCredentialValuePersisted == false
            && signaturePersisted == false
            && futuresReconciliationEnabled == false
            && okxReconciliationEnabled == false
            && dashboardTradingCommandEnabled == false
            && productionCutoverAuthorized == false
    }

    public var artifactHeld: Bool {
        namespaceHeld
            && evidenceReferencesRedacted
            && forbiddenCapabilitiesClosed
            && localOnlyAssumptionRejected
            && stateRuleHeld
    }

    public var failClosedArtifactHeld: Bool {
        artifactHeld
            && failClosed
            && rejectReasons.isEmpty == false
            && nextAction != .noActionTerminal
    }

    public var stateRuleHeld: Bool {
        switch state {
        case .matched:
            return exchangeEvidenceHeld
                && failClosed == false
                && rejectReasons.isEmpty
                && nextAction == .noActionTerminal
        case .pending:
            return exchangeEvidenceHeld
                && failClosed == false
                && rejectReasons.isEmpty
                && nextAction == .continueMonitoring
        case .ambiguous:
            return failClosed
                && rejectReasons.contains(.ambiguousExchangeState)
                && nextAction == .operatorReview
        case .rejected:
            return exchangeEvidenceHeld
                && failClosed
                && nextAction == .doNotRetrySubmit
        case .cancelled:
            return exchangeEvidenceHeld
                && failClosed == false
                && rejectReasons.isEmpty
                && nextAction == .noActionTerminal
        case .fillLike:
            return exchangeEvidenceHeld
                && failClosed == false
                && rejectReasons.isEmpty
                && nextAction == .operatorReview
        }
    }

    public init(
        artifactID: Identifier? = nil,
        state: ReleaseV0220SpotLiveCanaryReconciliationState,
        nextAction: ReleaseV0220SpotLiveCanaryReconciliationNextAction,
        runID: Identifier = Self.requiredRunID,
        clientOrderID: Identifier = Self.requiredClientOrderID,
        exchangeOrderID: Identifier = Self.requiredExchangeOrderID,
        omsEventLogEvidencePresent: Bool = true,
        exchangeOrderStatusEvidencePresent: Bool = true,
        signedAccountEvidencePresent: Bool = true,
        localOnlyAssumptionRejected: Bool = true,
        failClosed: Bool = false,
        rejectReasons: [ReleaseV0220SpotLiveCanaryReconciliationRejectReason] = [],
        redactedOMSReference: String = Self.redactedReference(scope: "oms-log"),
        redactedExchangeStatusReference: String = Self.redactedReference(scope: "exchange-status"),
        redactedAccountReference: String = Self.redactedReference(scope: "signed-account"),
        redactedArtifactReference: String = Self.redactedReference(scope: "artifact"),
        rawPayloadPersisted: Bool = false,
        rawCredentialValuePersisted: Bool = false,
        signaturePersisted: Bool = false,
        futuresReconciliationEnabled: Bool = false,
        okxReconciliationEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try Self.validateForbiddenFlags(
            rawPayloadPersisted: rawPayloadPersisted,
            rawCredentialValuePersisted: rawCredentialValuePersisted,
            signaturePersisted: signaturePersisted,
            futuresReconciliationEnabled: futuresReconciliationEnabled,
            okxReconciliationEnabled: okxReconciliationEnabled,
            dashboardTradingCommandEnabled: dashboardTradingCommandEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.artifactID = artifactID ?? Identifier.constant(
            "gh-1316-v0220-reconciliation-\(state.rawValue)",
            field: "releaseV0220.reconciliation.artifactID"
        )
        self.state = state
        self.nextAction = nextAction
        self.runID = runID
        self.clientOrderID = clientOrderID
        self.exchangeOrderID = exchangeOrderID
        self.omsEventLogEvidencePresent = omsEventLogEvidencePresent
        self.exchangeOrderStatusEvidencePresent = exchangeOrderStatusEvidencePresent
        self.signedAccountEvidencePresent = signedAccountEvidencePresent
        self.localOnlyAssumptionRejected = localOnlyAssumptionRejected
        self.failClosed = failClosed
        self.rejectReasons = rejectReasons
        self.redactedOMSReference = redactedOMSReference
        self.redactedExchangeStatusReference = redactedExchangeStatusReference
        self.redactedAccountReference = redactedAccountReference
        self.redactedArtifactReference = redactedArtifactReference
        self.rawPayloadPersisted = rawPayloadPersisted
        self.rawCredentialValuePersisted = rawCredentialValuePersisted
        self.signaturePersisted = signaturePersisted
        self.futuresReconciliationEnabled = futuresReconciliationEnabled
        self.okxReconciliationEnabled = okxReconciliationEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func matchedFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationArtifact
    {
        try ReleaseV0220SpotLiveCanaryReconciliationArtifact(
            state: .matched,
            nextAction: .noActionTerminal
        )
    }

    public static func pendingFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationArtifact
    {
        try ReleaseV0220SpotLiveCanaryReconciliationArtifact(
            state: .pending,
            nextAction: .continueMonitoring
        )
    }

    public static func ambiguousFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationArtifact
    {
        try ReleaseV0220SpotLiveCanaryReconciliationArtifact(
            state: .ambiguous,
            nextAction: .operatorReview,
            failClosed: true,
            rejectReasons: [.ambiguousExchangeState]
        )
    }

    public static func rejectedFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationArtifact
    {
        try ReleaseV0220SpotLiveCanaryReconciliationArtifact(
            state: .rejected,
            nextAction: .doNotRetrySubmit,
            failClosed: true
        )
    }

    public static func cancelledFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationArtifact
    {
        try ReleaseV0220SpotLiveCanaryReconciliationArtifact(
            state: .cancelled,
            nextAction: .noActionTerminal
        )
    }

    public static func fillLikeFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationArtifact
    {
        try ReleaseV0220SpotLiveCanaryReconciliationArtifact(
            state: .fillLike,
            nextAction: .operatorReview
        )
    }

    public static func missingExchangeEvidenceFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationArtifact
    {
        try ReleaseV0220SpotLiveCanaryReconciliationArtifact(
            state: .ambiguous,
            nextAction: .stopAndEscalate,
            exchangeOrderStatusEvidencePresent: false,
            signedAccountEvidencePresent: false,
            failClosed: true,
            rejectReasons: [.missingExchangeEvidence]
        )
    }

    public static func localOnlyRejectedFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationArtifact
    {
        try ReleaseV0220SpotLiveCanaryReconciliationArtifact(
            state: .ambiguous,
            nextAction: .stopAndEscalate,
            omsEventLogEvidencePresent: true,
            exchangeOrderStatusEvidencePresent: false,
            signedAccountEvidencePresent: false,
            failClosed: true,
            rejectReasons: [.missingExchangeEvidence, .localOnlyAssumptionRejected]
        )
    }

    public static func missingOMSEventLogFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationArtifact
    {
        try ReleaseV0220SpotLiveCanaryReconciliationArtifact(
            state: .ambiguous,
            nextAction: .stopAndEscalate,
            omsEventLogEvidencePresent: false,
            failClosed: true,
            rejectReasons: [.missingOMSLogEvidence]
        )
    }

    public static func redactedReference(scope: String) -> String {
        "\(requiredRedactedReferencePrefix):\(scope) runID=<redacted> clientOrderId=<redacted> exchangeOrderId=<redacted>"
    }

    public static func redactedReferenceHeld(_ reference: String) -> Bool {
        reference.hasPrefix(requiredRedactedReferencePrefix)
            && reference.contains("<redacted>")
            && reference.lowercased().contains("raw") == false
            && reference.lowercased().contains("secret") == false
            && reference.lowercased().contains("signature") == false
    }

    public static let requiredRedactedReferencePrefix = "redacted-reconciliation:gh-1316"
    public static let requiredRunID = ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy.requiredRunID
    public static let requiredClientOrderID =
        ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy.requiredClientOrderID
    public static let requiredExchangeOrderID =
        ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy.requiredExchangeOrderID
}

private extension ReleaseV0220SpotLiveCanaryReconciliationArtifact {
    static func validateForbiddenFlags(
        rawPayloadPersisted: Bool,
        rawCredentialValuePersisted: Bool,
        signaturePersisted: Bool,
        futuresReconciliationEnabled: Bool,
        okxReconciliationEnabled: Bool,
        dashboardTradingCommandEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("rawPayloadPersisted", rawPayloadPersisted),
            ("rawCredentialValuePersisted", rawCredentialValuePersisted),
            ("signaturePersisted", signaturePersisted),
            ("futuresReconciliationEnabled", futuresReconciliationEnabled),
            ("okxReconciliationEnabled", okxReconciliationEnabled),
            ("dashboardTradingCommandEnabled", dashboardTradingCommandEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0220.reconciliation.\(field)"
            )
        }
    }
}

/// ReleaseV0220SpotLiveCanaryReconciliationEvidence 是 GH-1316 的聚合证据。
/// 它把 GH-1312 signed account read-only preflight、GH-1315 OMS event log 和 exchange
/// order status evidence 收成一个 redacted reconciliation artifact matrix。
public struct ReleaseV0220SpotLiveCanaryReconciliationEvidence:
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
    public let upstreamSignedAccountPreflight:
        ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight
    public let upstreamOMSEventLog: ReleaseV0220SpotLiveCanaryOMSEventLogEvidence
    public let matchedArtifact: ReleaseV0220SpotLiveCanaryReconciliationArtifact
    public let pendingArtifact: ReleaseV0220SpotLiveCanaryReconciliationArtifact
    public let ambiguousArtifact: ReleaseV0220SpotLiveCanaryReconciliationArtifact
    public let rejectedArtifact: ReleaseV0220SpotLiveCanaryReconciliationArtifact
    public let cancelledArtifact: ReleaseV0220SpotLiveCanaryReconciliationArtifact
    public let fillLikeArtifact: ReleaseV0220SpotLiveCanaryReconciliationArtifact
    public let missingExchangeEvidenceArtifact: ReleaseV0220SpotLiveCanaryReconciliationArtifact
    public let localOnlyRejectedArtifact: ReleaseV0220SpotLiveCanaryReconciliationArtifact
    public let missingOMSEventLogArtifact: ReleaseV0220SpotLiveCanaryReconciliationArtifact
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let localOnlyAssumptionsRejected: Bool
    public let ambiguousOrMissingExchangeEvidenceFailsClosed: Bool
    public let redactedReconciliationArtifactRequired: Bool
    public let nextOperatorActionRequired: Bool
    public let productionTradingEnabledByDefault: Bool
    public let futuresReconciliationEnabled: Bool
    public let okxReconciliationEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1316"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1312", "GH-1315"]
            && downstreamIssueIDs.map(\.rawValue) == ["GH-1317"]
            && canonicalQueueRange == "GH-1309..GH-1320"
            && releaseVersion == "v0.22.0"
            && namespaceHeld
            && upstreamSignedAccountPreflight.preflightHeld
            && upstreamOMSEventLog.evidenceHeld
            && reconciliationArtifactsHeld
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

    public var reconciliationArtifactsHeld: Bool {
        matchedArtifact.artifactHeld
            && pendingArtifact.artifactHeld
            && ambiguousArtifact.failClosedArtifactHeld
            && rejectedArtifact.artifactHeld
            && cancelledArtifact.artifactHeld
            && fillLikeArtifact.artifactHeld
            && missingExchangeEvidenceArtifact.failClosed
            && missingExchangeEvidenceArtifact.rejectReasons.contains(.missingExchangeEvidence)
            && localOnlyRejectedArtifact.failClosed
            && localOnlyRejectedArtifact.rejectReasons.contains(.localOnlyAssumptionRejected)
            && missingOMSEventLogArtifact.failClosed
            && missingOMSEventLogArtifact.rejectReasons.contains(.missingOMSLogEvidence)
    }

    public var requiredControlsHeld: Bool {
        localOnlyAssumptionsRejected
            && ambiguousOrMissingExchangeEvidenceFailsClosed
            && redactedReconciliationArtifactRequired
            && nextOperatorActionRequired
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && futuresReconciliationEnabled == false
            && okxReconciliationEnabled == false
            && dashboardTradingCommandEnabled == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1316-release-v0.22.0-reconciliation-evidence"),
        issueID: Identifier = Identifier.constant("GH-1316"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1312"), Identifier.constant("GH-1315")],
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1317")],
        canonicalQueueRange: String = "GH-1309..GH-1320",
        releaseVersion: String = "v0.22.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamSignedAccountPreflight:
            ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight? = nil,
        upstreamOMSEventLog: ReleaseV0220SpotLiveCanaryOMSEventLogEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        localOnlyAssumptionsRejected: Bool = true,
        ambiguousOrMissingExchangeEvidenceFailsClosed: Bool = true,
        redactedReconciliationArtifactRequired: Bool = true,
        nextOperatorActionRequired: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        futuresReconciliationEnabled: Bool = false,
        okxReconciliationEnabled: Bool = false,
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
        self.upstreamSignedAccountPreflight = try upstreamSignedAccountPreflight
            ?? ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight
                .deterministicFixture()
        self.upstreamOMSEventLog = try upstreamOMSEventLog
            ?? ReleaseV0220SpotLiveCanaryOMSEventLogEvidence.deterministicFixture()
        self.matchedArtifact = try ReleaseV0220SpotLiveCanaryReconciliationArtifact
            .matchedFixture()
        self.pendingArtifact = try ReleaseV0220SpotLiveCanaryReconciliationArtifact
            .pendingFixture()
        self.ambiguousArtifact = try ReleaseV0220SpotLiveCanaryReconciliationArtifact
            .ambiguousFixture()
        self.rejectedArtifact = try ReleaseV0220SpotLiveCanaryReconciliationArtifact
            .rejectedFixture()
        self.cancelledArtifact = try ReleaseV0220SpotLiveCanaryReconciliationArtifact
            .cancelledFixture()
        self.fillLikeArtifact = try ReleaseV0220SpotLiveCanaryReconciliationArtifact
            .fillLikeFixture()
        self.missingExchangeEvidenceArtifact = try ReleaseV0220SpotLiveCanaryReconciliationArtifact
            .missingExchangeEvidenceFixture()
        self.localOnlyRejectedArtifact = try ReleaseV0220SpotLiveCanaryReconciliationArtifact
            .localOnlyRejectedFixture()
        self.missingOMSEventLogArtifact = try ReleaseV0220SpotLiveCanaryReconciliationArtifact
            .missingOMSEventLogFixture()
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.localOnlyAssumptionsRejected = localOnlyAssumptionsRejected
        self.ambiguousOrMissingExchangeEvidenceFailsClosed =
            ambiguousOrMissingExchangeEvidenceFailsClosed
        self.redactedReconciliationArtifactRequired = redactedReconciliationArtifactRequired
        self.nextOperatorActionRequired = nextOperatorActionRequired
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.futuresReconciliationEnabled = futuresReconciliationEnabled
        self.okxReconciliationEnabled = okxReconciliationEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.reconciliation",
                expected: "redacted OMS exchange account reconciliation evidence",
                actual: "invalid reconciliation evidence"
            )
        }
    }

    public static func deterministicFixture() throws
        -> ReleaseV0220SpotLiveCanaryReconciliationEvidence
    {
        try ReleaseV0220SpotLiveCanaryReconciliationEvidence()
    }

    public static let requiredValidationAnchors = [
        "GH-1316-VERIFY-V0220-RECONCILIATION-EVIDENCE",
        "TVM-RELEASE-V0220-RECONCILIATION-EVIDENCE",
        "V0220-008-BLOCKED-BY-GH1312-GH1315",
        "V0220-008-OMS-EXCHANGE-STATUS-ACCOUNT-RECONCILIATION",
        "V0220-008-MATCHED-PENDING-AMBIGUOUS-REJECTED-CANCELLED-FILL-LIKE",
        "V0220-008-REDACTED-RECONCILIATION-ARTIFACT",
        "V0220-008-MISSING-EXCHANGE-EVIDENCE-FAILS-CLOSED",
        "V0220-008-AMBIGUOUS-STATE-FAILS-CLOSED",
        "V0220-008-NEXT-OPERATOR-ACTION",
        "V0220-008-NO-FUTURES-OKX",
        "V0220-008-NO-DASHBOARD-TRADING-CONTROLS",
        "V0220-008-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1316ReleaseV0220ReconcilesOMSWithSignedAccountAndOrderStatusEvidence",
        "bash checks/verify-v0.22.0-reconciliation-evidence.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/verify-v0.21.0.sh",
        "bash checks/run.sh"
    ]
}
