import DomainModel
import ExecutionClient
import Foundation

// GH-1283 static contract boundary:
// cliCommand=canary-status
// dashboardCanaryStatusRows=canary-state,gate-stack,risk-decision,order-lifecycle,cancel-rollback,reconciliation,redaction-boundary
// dashboardCanaryStatusStates=ready,accepted,cancelled,reconciled,fail-closed
// dashboardCanaryStatusReadOnly=true
// cliCanaryStatusReadOnly=true
// tradingButtonVisible=false
// orderFormVisible=false
// liveCommandVisible=false
// submitCancelReplaceEnabled=false
// productionTradingEnabledByDefault=false
// productionSecretValueRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionCutoverAuthorized=false
// GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
// TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE
// V0210-011-DASHBOARD-CLI-CANARY-STATUS
// V0210-011-CANARY-STATE-GATES
// V0210-011-RISK-ORDER-CANCEL-RECONCILIATION
// V0210-011-READ-ONLY-NO-COMMANDS
// V0210-011-NO-PRODUCTION-CUTOVER

/// ReleaseV0210CanaryStatusArea 固定 GH-1283 Dashboard / CLI 只读面展示的 canary 区域。
///
/// 这些区域只把 GH-1278..GH-1282 的 deterministic evidence 投影为 operator 可读状态；
/// 它们不表示新的 runtime component，也不创建 live command、订单表单或生产切换入口。
public enum ReleaseV0210CanaryStatusArea:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case canaryState = "canary-state"
    case gateStack = "gate-stack"
    case riskDecision = "risk-decision"
    case orderLifecycle = "order-lifecycle"
    case cancelRollback = "cancel-rollback"
    case reconciliation
    case redactionBoundary = "redaction-boundary"
}

/// ReleaseV0210CanaryStatusState 是 GH-1283 允许展示的只读状态集合。
public enum ReleaseV0210CanaryStatusState:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case ready
    case accepted
    case cancelled
    case reconciled
    case failClosed = "fail-closed"
}

/// ReleaseV0210CanaryStatusEventRow 是 GH-1283 CLI events 输出使用的小型 event snapshot。
///
/// 它从 GH-1282 event log 复制 operator 需要观察的 redacted 字段，避免 CLI surface 持有
/// 整棵 GH-1282 evidence value，从而保持 async CLI route 的栈占用稳定。
public struct ReleaseV0210CanaryStatusEventRow:
    Codable,
    Equatable,
    Sendable
{
    public let sequence: Int
    public let kind: String
    public let sourceIssueID: String
    public let localOMSState: String
    public let brokerStatus: String
    public let redactedEvidenceOnly: Bool
    public let rawOrderIDVisible: Bool
    public let rawBrokerPayloadVisible: Bool

    public var rowHeld: Bool {
        sequence > 0
            && kind.isEmpty == false
            && sourceIssueID.hasPrefix("GH-")
            && localOMSState.isEmpty == false
            && brokerStatus.isEmpty == false
            && redactedEvidenceOnly
            && rawOrderIDVisible == false
            && rawBrokerPayloadVisible == false
    }

    public init(
        sequence: Int,
        kind: String,
        sourceIssueID: String,
        localOMSState: String,
        brokerStatus: String,
        redactedEvidenceOnly: Bool = true,
        rawOrderIDVisible: Bool = false,
        rawBrokerPayloadVisible: Bool = false
    ) {
        self.sequence = sequence
        self.kind = kind
        self.sourceIssueID = sourceIssueID
        self.localOMSState = localOMSState
        self.brokerStatus = brokerStatus
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.rawOrderIDVisible = rawOrderIDVisible
        self.rawBrokerPayloadVisible = rawBrokerPayloadVisible
    }

    public init(entry: ReleaseV0210CanaryOMSEventLogEntry) {
        self.sequence = entry.sequence
        self.kind = entry.kind.rawValue
        self.sourceIssueID = entry.sourceIssueID.rawValue
        self.localOMSState = entry.localOMSState
        self.brokerStatus = entry.brokerStatus
        self.redactedEvidenceOnly = entry.redactedEvidenceOnly
        self.rawOrderIDVisible = false
        self.rawBrokerPayloadVisible = false
    }
}

/// ReleaseV0210CanaryStatusReconciliationSnapshot 是 GH-1283 reconciliation 输出的小型快照。
public struct ReleaseV0210CanaryStatusReconciliationSnapshot:
    Codable,
    Equatable,
    Sendable
{
    public let matchedOutcome: String
    public let rejectedOutcomes: [String]
    public let matchedDigest: String
    public let canaryLifecycleReconstructable: Bool
    public let statusResponseRecorded: Bool
    public let cancelOutcomeRecorded: Bool
    public let reconciliationEvidenceRecorded: Bool
    public let productionCutoverAuthorized: Bool

    public var snapshotHeld: Bool {
        matchedOutcome == ReleaseV0210CanaryOMSReconciliationOutcome.matched.rawValue
            && rejectedOutcomes.contains(ReleaseV0210CanaryOMSReconciliationOutcome.rejected.rawValue)
            && matchedDigest.hasPrefix(
                ReleaseV0210CanaryOMSReconciliationPolicy.requiredReconciliationDigestPrefix
            )
            && canaryLifecycleReconstructable
            && statusResponseRecorded
            && cancelOutcomeRecorded
            && reconciliationEvidenceRecorded
            && productionCutoverAuthorized == false
    }

    public init(
        matchedOutcome: String = ReleaseV0210CanaryOMSReconciliationOutcome.matched.rawValue,
        rejectedOutcomes: [String] = [ReleaseV0210CanaryOMSReconciliationOutcome.rejected.rawValue],
        matchedDigest: String = ReleaseV0210CanaryOMSReconciliationPolicy.requiredReconciliationDigest,
        canaryLifecycleReconstructable: Bool = true,
        statusResponseRecorded: Bool = true,
        cancelOutcomeRecorded: Bool = true,
        reconciliationEvidenceRecorded: Bool = true,
        productionCutoverAuthorized: Bool = false
    ) {
        self.matchedOutcome = matchedOutcome
        self.rejectedOutcomes = rejectedOutcomes.uniqueStable()
        self.matchedDigest = matchedDigest
        self.canaryLifecycleReconstructable = canaryLifecycleReconstructable
        self.statusResponseRecorded = statusResponseRecorded
        self.cancelOutcomeRecorded = cancelOutcomeRecorded
        self.reconciliationEvidenceRecorded = reconciliationEvidenceRecorded
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(evidence: ReleaseV0210CanaryOMSEventLogReconciliationEvidence) {
        self.matchedOutcome = evidence.matchedDecision.outcome.rawValue
        self.rejectedOutcomes = [
            evidence.upstreamRejectedDecision.outcome.rawValue,
            evidence.eventLogRejectedDecision.outcome.rawValue,
            evidence.statusRejectedDecision.outcome.rawValue,
            evidence.cancelOutcomeRejectedDecision.outcome.rawValue,
            evidence.reconciliationRejectedDecision.outcome.rawValue,
            evidence.redactionRejectedDecision.outcome.rawValue
        ].uniqueStable()
        self.matchedDigest = evidence.matchedDecision.reconciliationDigest
        self.canaryLifecycleReconstructable = evidence.matchedDecision.canaryLifecycleReconstructable
        self.statusResponseRecorded = evidence.matchedDecision.statusResponseRecorded
        self.cancelOutcomeRecorded = evidence.matchedDecision.cancelOutcomeRecorded
        self.reconciliationEvidenceRecorded = evidence.matchedDecision.reconciliationEvidenceRecorded
        self.productionCutoverAuthorized = evidence.matchedDecision.productionCutoverAuthorized
    }
}

/// ReleaseV0210CanaryStatusRow 是 Dashboard / CLI 共用的只读 canary status row。
///
/// Row 只保存 redacted digest、source issue、gate label 和人类可读摘要；禁止保存 raw order id、
/// raw broker payload、credential value、endpoint response 或任何可执行 command。
public struct ReleaseV0210CanaryStatusRow: Codable, Equatable, Sendable {
    public let area: ReleaseV0210CanaryStatusArea
    public let sourceIssueID: String
    public let state: ReleaseV0210CanaryStatusState
    public let gateLabel: String
    public let statusSummary: String
    public let redactedEvidenceDigest: String
    public let visibleInDashboard: Bool
    public let visibleInCLI: Bool
    public let readOnly: Bool
    public let commandSurfaceEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let submitCancelReplaceEnabled: Bool
    public let rawOrderIDVisible: Bool
    public let rawBrokerPayloadVisible: Bool
    public let productionCutoverAuthorized: Bool

    public var rowHeld: Bool {
        sourceIssueID.hasPrefix("GH-")
            && Self.expectedState(for: area) == state
            && gateLabel.isEmpty == false
            && statusSummary.isEmpty == false
            && redactedEvidenceDigest.hasPrefix(Self.requiredDigestPrefix)
            && visibleInDashboard
            && visibleInCLI
            && readOnly
            && commandSurfaceEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && submitCancelReplaceEnabled == false
            && rawOrderIDVisible == false
            && rawBrokerPayloadVisible == false
            && productionCutoverAuthorized == false
    }

    public init(
        area: ReleaseV0210CanaryStatusArea,
        sourceIssueID: String,
        state: ReleaseV0210CanaryStatusState,
        gateLabel: String,
        statusSummary: String,
        redactedEvidenceDigest: String? = nil,
        visibleInDashboard: Bool = true,
        visibleInCLI: Bool = true,
        readOnly: Bool = true,
        commandSurfaceEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        rawOrderIDVisible: Bool = false,
        rawBrokerPayloadVisible: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.area = area
        self.sourceIssueID = sourceIssueID
        self.state = state
        self.gateLabel = gateLabel
        self.statusSummary = statusSummary
        self.redactedEvidenceDigest = redactedEvidenceDigest ?? Self.redactedDigest(for: area)
        self.visibleInDashboard = visibleInDashboard
        self.visibleInCLI = visibleInCLI
        self.readOnly = readOnly
        self.commandSurfaceEnabled = commandSurfaceEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.rawOrderIDVisible = rawOrderIDVisible
        self.rawBrokerPayloadVisible = rawBrokerPayloadVisible
        self.productionCutoverAuthorized = productionCutoverAuthorized
        try Self.validate(self)
    }

    public static func expectedState(
        for area: ReleaseV0210CanaryStatusArea
    ) -> ReleaseV0210CanaryStatusState {
        switch area {
        case .canaryState, .gateStack:
            .ready
        case .riskDecision, .orderLifecycle:
            .accepted
        case .cancelRollback:
            .cancelled
        case .reconciliation:
            .reconciled
        case .redactionBoundary:
            .failClosed
        }
    }

    public static func redactedDigest(for area: ReleaseV0210CanaryStatusArea) -> String {
        "\(requiredDigestPrefix):\(area.rawValue)"
    }

    public static let requiredDigestPrefix = "sha256:gh-1283-redacted-canary-status"

    private static func validate(_ row: ReleaseV0210CanaryStatusRow) throws {
        guard row.rowHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryStatus.row.\(row.area.rawValue)",
                expected: "read-only canary status row with redacted evidence and no command surface",
                actual: row.statusSummary
            )
        }
    }
}

/// ReleaseV0210CanaryStatusReadOnlySurface 是 GH-1283 的 Dashboard / CLI 共享状态面。
///
/// Surface 消费 GH-1282 redacted OMS event log / reconciliation evidence，并将 canary state、
/// gates、risk decision、order lifecycle、cancel / rollback 和 reconciliation 投影成只读状态。
/// CLI 与 Dashboard 只能 inspect 这些 row；任何交易按钮、订单表单、live command、submit /
/// cancel / replace、secret 读取、endpoint 连接或 production cutover 都必须保持关闭。
public struct ReleaseV0210CanaryStatusReadOnlySurface:
    Codable,
    Equatable,
    Sendable
{
    public static let cliCommand = "canary-status"

    public let surfaceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let upstreamReconciliationEvidenceID: Identifier
    public let eventRows: [ReleaseV0210CanaryStatusEventRow]
    public let reconciliationSnapshot: ReleaseV0210CanaryStatusReconciliationSnapshot
    public let rows: [ReleaseV0210CanaryStatusRow]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let upstreamEvidenceHeldSnapshot: Bool
    public let surfaceHeldSnapshot: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let signedOrderMaterialGenerated: Bool
    public let accountEndpointConnected: Bool
    public let orderEndpointTouched: Bool
    public let submitCancelReplaceEnabled: Bool
    public let dashboardTradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let rawOrderIDVisible: Bool
    public let rawBrokerPayloadVisible: Bool
    public let realOrderSent: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var surfaceHeld: Bool {
        surfaceHeldSnapshot
    }

    public var upstreamEvidenceHeld: Bool {
        upstreamEvidenceHeldSnapshot
    }

    public var boundaryHeld: Bool {
        surfaceHeld
            && rows.allSatisfy(\.rowHeld)
            && forbiddenCapabilitiesClosed
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && signedOrderMaterialGenerated == false
            && accountEndpointConnected == false
            && orderEndpointTouched == false
            && submitCancelReplaceEnabled == false
            && dashboardTradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && rawOrderIDVisible == false
            && rawBrokerPayloadVisible == false
            && realOrderSent == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public var stateLabels: [String] {
        ReleaseV0210CanaryStatusState.allCases
            .filter { state in rows.contains { $0.state == state } }
            .map(\.rawValue)
    }

    public var gateLabels: [String] {
        rows.map(\.gateLabel).uniqueStable()
    }

    public var lifecycleEventLabels: [String] {
        eventRows.map(\.kind)
    }

    public var reconciliationLabels: [String] {
        ([reconciliationSnapshot.matchedOutcome] + reconciliationSnapshot.rejectedOutcomes).uniqueStable()
    }

    public init(
        surfaceID: Identifier = Identifier.constant("gh-1283-release-v0.21.0-dashboard-cli-canary-status-surface"),
        issueID: Identifier = Identifier.constant("GH-1283"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-1280"),
            Identifier.constant("GH-1281"),
            Identifier.constant("GH-1282")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-1282"),
        downstreamIssueID: Identifier = Identifier.constant("GH-1284"),
        canonicalQueueRange: String = ReleaseV0210CanaryOMSEventLogReconciliationEvidence.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName,
        releaseVersion: String = "v0.21.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamReconciliationEvidence: ReleaseV0210CanaryOMSEventLogReconciliationEvidence? = nil,
        rows: [ReleaseV0210CanaryStatusRow]? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        signedOrderMaterialGenerated: Bool = false,
        accountEndpointConnected: Bool = false,
        orderEndpointTouched: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        dashboardTradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        rawOrderIDVisible: Bool = false,
        rawBrokerPayloadVisible: Bool = false,
        realOrderSent: Bool = false,
        createsTagOrRelease: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let resolvedEvidenceID: Identifier
        let resolvedEventRows: [ReleaseV0210CanaryStatusEventRow]
        let resolvedReconciliationSnapshot: ReleaseV0210CanaryStatusReconciliationSnapshot
        let resolvedEvidenceHeld: Bool

        if let upstreamReconciliationEvidence {
            resolvedEvidenceID = upstreamReconciliationEvidence.evidenceID
            resolvedEventRows = upstreamReconciliationEvidence.matchedDecision.eventLogEntries.map {
                ReleaseV0210CanaryStatusEventRow(entry: $0)
            }
            resolvedReconciliationSnapshot = ReleaseV0210CanaryStatusReconciliationSnapshot(
                evidence: upstreamReconciliationEvidence
            )
            resolvedEvidenceHeld = upstreamReconciliationEvidence.evidenceHeld
                && upstreamReconciliationEvidence.matchedDecision.forwardsToReadOnlyStatusSurface
        } else {
            // GH-1283 默认 fixture 只保存 GH-1282 的 compact redacted snapshot，避免 CLI
            // route 持有上游完整 evidence graph 导致 async task 栈占用失控。
            resolvedEvidenceID = Self.requiredUpstreamReconciliationEvidenceID
            resolvedEventRows = Self.defaultEventRows
            resolvedReconciliationSnapshot = Self.defaultReconciliationSnapshot
            resolvedEvidenceHeld = true
        }

        let resolvedRows = try rows ?? Self.defaultRows()
        let resolvedUpstreamEvidenceHeld = resolvedEvidenceHeld
            && resolvedEventRows.map(\.sequence) == Array(1...resolvedEventRows.count)
            && resolvedEventRows.allSatisfy(\.rowHeld)
            && resolvedReconciliationSnapshot.snapshotHeld
        let resolvedSurfaceHeld = issueID.rawValue == "GH-1283"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1280", "GH-1281", "GH-1282"]
            && previousIssueID.rawValue == "GH-1282"
            && downstreamIssueID.rawValue == "GH-1284"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == ReleaseV0210SpotControlledProductionCanaryContract.requiredProjectName
            && releaseVersion == "v0.21.0"
            && venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
            && resolvedUpstreamEvidenceHeld
            && resolvedRows.map(\.area) == ReleaseV0210CanaryStatusArea.allCases
            && resolvedRows.allSatisfy(\.rowHeld)
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands

        self.surfaceID = surfaceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.upstreamReconciliationEvidenceID = resolvedEvidenceID
        self.eventRows = resolvedEventRows
        self.reconciliationSnapshot = resolvedReconciliationSnapshot
        self.rows = resolvedRows
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.upstreamEvidenceHeldSnapshot = resolvedUpstreamEvidenceHeld
        self.surfaceHeldSnapshot = resolvedSurfaceHeld
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.signedOrderMaterialGenerated = signedOrderMaterialGenerated
        self.accountEndpointConnected = accountEndpointConnected
        self.orderEndpointTouched = orderEndpointTouched
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.dashboardTradingButtonVisible = dashboardTradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.rawOrderIDVisible = rawOrderIDVisible
        self.rawBrokerPayloadVisible = rawBrokerPayloadVisible
        self.realOrderSent = realOrderSent
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized
        try validate()
    }

    public static let requiredCanonicalQueueRange = "GH-1273..GH-1286"
    public static let requiredUpstreamReconciliationEvidenceID =
        Identifier.constant("gh-1282-release-v0.21.0-canary-oms-event-log-reconciliation-evidence")

    public static let requiredValidationAnchors = [
        "GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE",
        "TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE",
        "V0210-011-DASHBOARD-CLI-CANARY-STATUS",
        "V0210-011-CANARY-STATE-GATES",
        "V0210-011-RISK-ORDER-CANCEL-RECONCILIATION",
        "V0210-011-READ-ONLY-NO-COMMANDS",
        "V0210-011-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH1283DashboardCLIReadOnlyCanaryStatusSurfaceShowsCanaryEvidenceWithoutCommands",
        "swift test --filter TargetGraphTests/testGH1283ReleaseV0210DashboardCLIReadOnlyCanaryStatusSurface",
        "bash checks/verify-v0.21.0-dashboard-cli-canary-status-surface.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static var defaultEventRows: [ReleaseV0210CanaryStatusEventRow] {
        [
            ReleaseV0210CanaryStatusEventRow(
                sequence: 1,
                kind: ReleaseV0210CanaryOMSEventKind.submitRequest.rawValue,
                sourceIssueID: "GH-1280",
                localOMSState: "pending-submit",
                brokerStatus: "not-sent"
            ),
            ReleaseV0210CanaryStatusEventRow(
                sequence: 2,
                kind: ReleaseV0210CanaryOMSEventKind.submitAccepted.rawValue,
                sourceIssueID: "GH-1280",
                localOMSState: "accepted",
                brokerStatus: "accepted"
            ),
            ReleaseV0210CanaryStatusEventRow(
                sequence: 3,
                kind: ReleaseV0210CanaryOMSEventKind.statusResponse.rawValue,
                sourceIssueID: "GH-1280",
                localOMSState: "status-confirmed",
                brokerStatus: "status-redacted"
            ),
            ReleaseV0210CanaryStatusEventRow(
                sequence: 4,
                kind: ReleaseV0210CanaryOMSEventKind.cancelRequest.rawValue,
                sourceIssueID: "GH-1281",
                localOMSState: "pending-cancel",
                brokerStatus: "cancel-request-redacted"
            ),
            ReleaseV0210CanaryStatusEventRow(
                sequence: 5,
                kind: ReleaseV0210CanaryOMSEventKind.cancelOutcome.rawValue,
                sourceIssueID: "GH-1281",
                localOMSState: "cancelled",
                brokerStatus: "cancelled"
            ),
            ReleaseV0210CanaryStatusEventRow(
                sequence: 6,
                kind: ReleaseV0210CanaryOMSEventKind.rollbackGuard.rawValue,
                sourceIssueID: "GH-1281",
                localOMSState: "rollback-guard-held",
                brokerStatus: "no-follow-up-order"
            ),
            ReleaseV0210CanaryStatusEventRow(
                sequence: 7,
                kind: ReleaseV0210CanaryOMSEventKind.reconciliation.rawValue,
                sourceIssueID: "GH-1282",
                localOMSState: "reconciled",
                brokerStatus: "matched-redacted"
            )
        ]
    }

    public static var defaultReconciliationSnapshot: ReleaseV0210CanaryStatusReconciliationSnapshot {
        ReleaseV0210CanaryStatusReconciliationSnapshot()
    }

    public static func deterministicFixture() throws -> ReleaseV0210CanaryStatusReadOnlySurface {
        try ReleaseV0210CanaryStatusReadOnlySurface()
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryStatus.cliCommand",
                expected: cliCommand,
                actual: arguments.joined(separator: " ")
            )
        }
        guard arguments.count <= 2,
              arguments.count == 1 || ["status", "events", "reconciliation"].contains(arguments[safe: 1] ?? "") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryStatus.arguments",
                expected: "\(cliCommand) [status|events|reconciliation]",
                actual: arguments.joined(separator: " ")
            )
        }
        let surface = try deterministicFixture()
        switch arguments[safe: 1] ?? "status" {
        case "status":
            return surface.statusOutput()
        case "events":
            return surface.eventsOutput()
        case "reconciliation":
            return surface.reconciliationOutput()
        default:
            preconditionFailure("guard above restricts canary status arguments")
        }
    }

    public func statusOutput() -> String {
        ([
            "mtpro \(Self.cliCommand) status",
            "issue=GH-1283",
            "validationAnchor=TVM-RELEASE-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE",
            "verificationAnchor=GH-1283-VERIFY-V0210-DASHBOARD-CLI-CANARY-STATUS-SURFACE",
            "requiredAnchors=\(validationAnchors.joined(separator: ","))",
            "releaseVersion=\(releaseVersion)",
            "projectName=\(projectName)",
            "surfaceRows=\(rows.count)",
            "states=\(stateLabels.joined(separator: ","))",
            "gates=\(gateLabels.joined(separator: ","))",
            "lifecycleEvents=\(lifecycleEventLabels.joined(separator: ","))",
            "reconciliation=\(reconciliationSnapshot.matchedOutcome)"
        ] + rows.map { row in
            [
                "row=\(row.area.rawValue)",
                "issue=\(row.sourceIssueID)",
                "state=\(row.state.rawValue)",
                "gate=\(row.gateLabel)",
                "digest=\(row.redactedEvidenceDigest)",
                "summary=\(row.statusSummary)"
            ].joined(separator: ";")
        } + [
            "dashboardReadOnly=true",
            "cliReadOnly=true",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "submitCancelReplaceEnabled=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretValueRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "rawOrderIDVisible=false",
            "rawBrokerPayloadVisible=false",
            "productionCutoverAuthorized=false",
            "realOrderSent=false",
            "boundaryHeld=\(boundaryHeld)"
        ]).joined(separator: "\n")
    }

    public func eventsOutput() -> String {
        ([
            "mtpro \(Self.cliCommand) events",
            "issue=GH-1283",
            "sourceIssue=GH-1282",
            "eventRows=\(eventRows.count)"
        ] + eventRows.map { row in
            [
                "sequence=\(row.sequence)",
                "kind=\(row.kind)",
                "sourceIssue=\(row.sourceIssueID)",
                "localOMSState=\(row.localOMSState)",
                "brokerStatus=\(row.brokerStatus)",
                "redactedEvidenceOnly=\(row.redactedEvidenceOnly)",
                "rawOrderIDVisible=false",
                "rawBrokerPayloadVisible=false"
            ].joined(separator: ";")
        } + [
            "dashboardReadOnly=true",
            "cliReadOnly=true",
            "boundaryHeld=\(boundaryHeld)"
        ]).joined(separator: "\n")
    }

    public func reconciliationOutput() -> String {
        [
            "mtpro \(Self.cliCommand) reconciliation",
            "issue=GH-1283",
            "sourceIssue=GH-1282",
            "matchedOutcome=\(reconciliationSnapshot.matchedOutcome)",
            "matchedDigest=\(reconciliationSnapshot.matchedDigest)",
            "rejectedOutcomes=\(reconciliationLabels.joined(separator: ","))",
            "canaryLifecycleReconstructable=\(reconciliationSnapshot.canaryLifecycleReconstructable)",
            "statusResponseRecorded=\(reconciliationSnapshot.statusResponseRecorded)",
            "cancelOutcomeRecorded=\(reconciliationSnapshot.cancelOutcomeRecorded)",
            "reconciliationEvidenceRecorded=\(reconciliationSnapshot.reconciliationEvidenceRecorded)",
            "rawOrderIDVisible=false",
            "rawBrokerPayloadVisible=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=\(boundaryHeld)"
        ].joined(separator: "\n")
    }

    private static func defaultRows() throws -> [ReleaseV0210CanaryStatusRow] {
        try [
            ReleaseV0210CanaryStatusRow(
                area: .canaryState,
                sourceIssueID: "GH-1274",
                state: .ready,
                gateLabel: "environment",
                statusSummary: "binance spot canary profile visible"
            ),
            ReleaseV0210CanaryStatusRow(
                area: .gateStack,
                sourceIssueID: "GH-1278",
                state: .ready,
                gateLabel: "hard-limit",
                statusSummary: "symbol, notional, quantity, order type and count gates held"
            ),
            ReleaseV0210CanaryStatusRow(
                area: .riskDecision,
                sourceIssueID: "GH-1279",
                state: .accepted,
                gateLabel: "risk-kill-notrade",
                statusSummary: "RiskEngine, kill switch, no-trade, approval and hard-limit gates accepted"
            ),
            ReleaseV0210CanaryStatusRow(
                area: .orderLifecycle,
                sourceIssueID: "GH-1280",
                state: .accepted,
                gateLabel: "single-submit-evidence",
                statusSummary: "single approved canary submit request evidence is redacted and inspectable"
            ),
            ReleaseV0210CanaryStatusRow(
                area: .cancelRollback,
                sourceIssueID: "GH-1281",
                state: .cancelled,
                gateLabel: "cancel-rollback",
                statusSummary: "controlled cancel evidence and rollback guard are visible"
            ),
            ReleaseV0210CanaryStatusRow(
                area: .reconciliation,
                sourceIssueID: "GH-1282",
                state: .reconciled,
                gateLabel: "oms-reconciliation",
                statusSummary: "redacted OMS event log matched lifecycle with reconciliation digest"
            ),
            ReleaseV0210CanaryStatusRow(
                area: .redactionBoundary,
                sourceIssueID: "GH-1282",
                state: .failClosed,
                gateLabel: "no-command-redaction",
                statusSummary: "raw order id, raw broker payload, commands and cutover remain hidden"
            )
        ]
    }

    private func validate() throws {
        guard boundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0210.canaryStatus.surface",
                expected: "Dashboard / CLI canary status surface held with no command surface",
                actual: issueID.rawValue
            )
        }
    }
}

private extension Array where Element == String {
    func uniqueStable() -> [String] {
        var seen: Set<String> = []
        return filter { seen.insert($0).inserted }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
