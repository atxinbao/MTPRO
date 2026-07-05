import DomainModel
import Foundation

// GH-1318 read-only live canary evidence surface anchors:
// GH-1318-VERIFY-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE
// TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE
// V0220-010-BLOCKED-BY-GH1317
// V0220-010-LIVE-CANARY-EVIDENCE-CHAIN
// V0220-010-APPROVAL-PREFLIGHT-SUBMIT-STATUS-CANCEL-OMS-RECONCILIATION
// V0220-010-FAILURE-CLASS-NEXT-ACTION
// V0220-010-READ-ONLY-DASHBOARD-CLI
// V0220-010-REDACTION-FAILURE-STATES-VISIBLE
// V0220-010-NO-TRADING-COMMANDS
// V0220-010-NO-FUTURES-OKX
// V0220-010-NO-PRODUCTION-CUTOVER

/// GH-1318 Dashboard / CLI surface 展示的 live canary evidence 区域。
public enum ReleaseV0220SpotLiveCanaryEvidenceSurfaceArea:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case approval = "approval"
    case signedAccountPreflight = "signed-account-preflight"
    case submitTransport = "submit-transport"
    case statusCancelTransport = "status-cancel-transport"
    case omsEventLog = "oms-event-log"
    case reconciliation = "reconciliation"
    case failureClassification = "failure-classification"
    case rollbackDrill = "rollback-drill"
    case redactionBoundary = "redaction-boundary"
}

/// GH-1318 每个只读 evidence row 的状态。
public enum ReleaseV0220SpotLiveCanaryEvidenceSurfaceState:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case ready
    case approved
    case submitted = "submitted-live-canary"
    case cancelled
    case reconciled
    case failClosed = "fail-closed"
    case redacted
}

/// ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow 是 Dashboard / CLI 的单条只读行。
///
/// Row 只能展示 redacted evidence digest、failure class 和 next action；它不能启用
/// trading button、order form、live command 或 submit / cancel / replace 命令。
public struct ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow:
    Codable, Equatable, Sendable
{
    public let area: ReleaseV0220SpotLiveCanaryEvidenceSurfaceArea
    public let sourceIssueID: String
    public let state: ReleaseV0220SpotLiveCanaryEvidenceSurfaceState
    public let gateLabel: String
    public let statusSummary: String
    public let redactedEvidenceDigest: String
    public let failureClassLabels: [String]
    public let nextActionLabels: [String]
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
    public let rawBrokerPayloadPersisted: Bool
    public let productionCutoverAuthorized: Bool

    public var rowHeld: Bool {
        areaExpectedStateHeld
            && sourceIssueID.hasPrefix("GH-")
            && gateLabel.isEmpty == false
            && statusSummary.isEmpty == false
            && redactedEvidenceDigest.hasPrefix("sha256:gh-1318-")
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
            && rawBrokerPayloadPersisted == false
            && productionCutoverAuthorized == false
    }

    private var areaExpectedStateHeld: Bool {
        switch area {
        case .approval:
            return state == .approved
        case .signedAccountPreflight:
            return state == .ready
        case .submitTransport:
            return state == .submitted
        case .statusCancelTransport:
            return state == .cancelled
        case .omsEventLog:
            return state == .ready
        case .reconciliation:
            return state == .reconciled
        case .failureClassification:
            return state == .failClosed
        case .rollbackDrill:
            return state == .failClosed
        case .redactionBoundary:
            return state == .redacted
        }
    }

    public init(
        area: ReleaseV0220SpotLiveCanaryEvidenceSurfaceArea,
        sourceIssueID: String,
        state: ReleaseV0220SpotLiveCanaryEvidenceSurfaceState,
        gateLabel: String,
        statusSummary: String,
        redactedEvidenceDigest: String? = nil,
        failureClassLabels: [String] = [],
        nextActionLabels: [String] = [],
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
        rawBrokerPayloadPersisted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.area = area
        self.sourceIssueID = sourceIssueID
        self.state = state
        self.gateLabel = gateLabel
        self.statusSummary = statusSummary
        self.redactedEvidenceDigest = redactedEvidenceDigest
            ?? "sha256:gh-1318-\(area.rawValue)-redacted"
        self.failureClassLabels = failureClassLabels
        self.nextActionLabels = nextActionLabels
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
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard rowHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.liveCanaryEvidenceSurface.row.\(area.rawValue)",
                expected: "read-only redacted evidence row with no command surface",
                actual: statusSummary
            )
        }
    }
}

/// ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface 是 GH-1318 的 Dashboard / CLI
/// 共享只读 surface。
///
/// 它引用 GH-1317 failure rollback drill 和 GH-1316 reconciliation 的稳定摘要，
/// 并把 approval、preflight、submit、status/cancel、OMS、reconciliation、
/// failure class 和 next action 投影给 operator inspection。该 surface 不构造
/// 上游大对象，也不提供任何交易命令入口。
public struct ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface:
    Codable, Equatable, Sendable
{
    public static let cliCommand = "canary-live-evidence"

    public let surfaceID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let failureClassLabels: [String]
    public let nextActionLabels: [String]
    public let rollbackCommandLabels: [String]
    public let reconciliationEvidenceHeld: Bool
    public let matchedExchangeOrderID: String
    public let matchedOMSReference: String
    public let reconciliationArtifactReference: String
    public let rows: [ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let surfaceHeld: Bool
    public let productionTradingEnabledByDefault: Bool
    public let futuresEnabled: Bool
    public let okxEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let submitCancelReplaceEnabled: Bool
    public let rawOrderIDVisible: Bool
    public let rawBrokerPayloadVisible: Bool
    public let rawBrokerPayloadPersisted: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var boundaryHeld: Bool {
        surfaceHeld
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && futuresEnabled == false
            && okxEnabled == false
            && dashboardTradingCommandEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && submitCancelReplaceEnabled == false
            && rawOrderIDVisible == false
            && rawBrokerPayloadVisible == false
            && rawBrokerPayloadPersisted == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public var stateLabels: [String] {
        Self.uniqueStable(rows.map { $0.state.rawValue })
    }

    public var gateLabels: [String] {
        Self.uniqueStable(rows.map(\.gateLabel))
    }

    public var approvalVisible: Bool {
        rows.contains { $0.area == .approval && $0.visibleInDashboard && $0.visibleInCLI }
    }

    public var preflightVisible: Bool {
        rows.contains { $0.area == .signedAccountPreflight && $0.visibleInDashboard && $0.visibleInCLI }
    }

    public var submitVisible: Bool {
        rows.contains { $0.area == .submitTransport && $0.visibleInDashboard && $0.visibleInCLI }
    }

    public var statusCancelVisible: Bool {
        rows.contains { $0.area == .statusCancelTransport && $0.visibleInDashboard && $0.visibleInCLI }
    }

    public var omsVisible: Bool {
        rows.contains { $0.area == .omsEventLog && $0.visibleInDashboard && $0.visibleInCLI }
    }

    public var reconciliationVisible: Bool {
        rows.contains { $0.area == .reconciliation && $0.visibleInDashboard && $0.visibleInCLI }
    }

    public var failureStatesVisible: Bool {
        failureClassLabels == Self.requiredFailureClassLabels
            && rows.contains { $0.area == .failureClassification && $0.failureClassLabels == failureClassLabels }
    }

    public var nextActionsVisible: Bool {
        rows.contains { $0.area == .failureClassification && $0.nextActionLabels == nextActionLabels }
    }

    public var rollbackEvidenceVisible: Bool {
        rows.contains { $0.area == .rollbackDrill && $0.failureClassLabels.contains("kill-switch") }
            && rows.contains { $0.area == .rollbackDrill && $0.failureClassLabels.contains("no-trade") }
            && rollbackCommandLabels == Self.requiredRollbackCommandLabels
    }

    public init(
        surfaceID: Identifier = Identifier.constant("gh-1318-release-v0.22.0-dashboard-cli-live-canary-evidence-surface"),
        issueID: Identifier = Identifier.constant("GH-1318"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1317")],
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1319")],
        canonicalQueueRange: String = "GH-1309..GH-1320",
        releaseVersion: String = "v0.22.0",
        failureClassLabels: [String] = Self.requiredFailureClassLabels,
        nextActionLabels: [String] = Self.requiredNextActionLabels,
        rollbackCommandLabels: [String] = Self.requiredRollbackCommandLabels,
        reconciliationEvidenceHeld: Bool = true,
        matchedExchangeOrderID: String = Self.requiredMatchedExchangeOrderID,
        matchedOMSReference: String = Self.requiredMatchedOMSReference,
        reconciliationArtifactReference: String = Self.requiredReconciliationArtifactReference,
        rows: [ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow]? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        futuresEnabled: Bool = false,
        okxEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        rawOrderIDVisible: Bool = false,
        rawBrokerPayloadVisible: Bool = false,
        rawBrokerPayloadPersisted: Bool = false,
        createsTagOrRelease: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        let resolvedRows = try rows ?? Self.defaultRows(
            failureLabels: failureClassLabels,
            nextActions: nextActionLabels
        )
        let resolvedSurfaceHeld = Self.validateSurface(
            issueID: issueID,
            blockedByIssueIDs: blockedByIssueIDs,
            downstreamIssueIDs: downstreamIssueIDs,
            canonicalQueueRange: canonicalQueueRange,
            releaseVersion: releaseVersion,
            failureClassLabels: failureClassLabels,
            nextActionLabels: nextActionLabels,
            rollbackCommandLabels: rollbackCommandLabels,
            reconciliationEvidenceHeld: reconciliationEvidenceHeld,
            matchedExchangeOrderID: matchedExchangeOrderID,
            matchedOMSReference: matchedOMSReference,
            reconciliationArtifactReference: reconciliationArtifactReference,
            rows: resolvedRows,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            futuresEnabled: futuresEnabled,
            okxEnabled: okxEnabled,
            dashboardTradingCommandEnabled: dashboardTradingCommandEnabled,
            tradingButtonVisible: tradingButtonVisible,
            orderFormVisible: orderFormVisible,
            liveCommandVisible: liveCommandVisible,
            submitCancelReplaceEnabled: submitCancelReplaceEnabled,
            rawOrderIDVisible: rawOrderIDVisible,
            rawBrokerPayloadVisible: rawBrokerPayloadVisible,
            rawBrokerPayloadPersisted: rawBrokerPayloadPersisted,
            createsTagOrRelease: createsTagOrRelease,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.surfaceID = surfaceID
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.releaseVersion = releaseVersion
        self.failureClassLabels = failureClassLabels
        self.nextActionLabels = nextActionLabels
        self.rollbackCommandLabels = rollbackCommandLabels
        self.reconciliationEvidenceHeld = reconciliationEvidenceHeld
        self.matchedExchangeOrderID = matchedExchangeOrderID
        self.matchedOMSReference = matchedOMSReference
        self.reconciliationArtifactReference = reconciliationArtifactReference
        self.rows = resolvedRows
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.surfaceHeld = resolvedSurfaceHeld
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.futuresEnabled = futuresEnabled
        self.okxEnabled = okxEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.rawOrderIDVisible = rawOrderIDVisible
        self.rawBrokerPayloadVisible = rawBrokerPayloadVisible
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard resolvedSurfaceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.liveCanaryEvidenceSurface",
                expected: "read-only dashboard and CLI evidence surface",
                actual: "invalid live canary evidence surface"
            )
        }
    }

    public static func deterministicFixture() throws
        -> ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface
    {
        try ReleaseV0220SpotLiveCanaryReadOnlyEvidenceSurface()
    }

    public static func deterministicRows() throws -> [ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow] {
        try defaultRows(
            failureLabels: requiredFailureClassLabels,
            nextActions: requiredNextActionLabels
        )
    }

    public static let requiredValidationAnchors = [
        "GH-1318-VERIFY-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE",
        "TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE",
        "V0220-010-BLOCKED-BY-GH1317",
        "V0220-010-LIVE-CANARY-EVIDENCE-CHAIN",
        "V0220-010-APPROVAL-PREFLIGHT-SUBMIT-STATUS-CANCEL-OMS-RECONCILIATION",
        "V0220-010-FAILURE-CLASS-NEXT-ACTION",
        "V0220-010-READ-ONLY-DASHBOARD-CLI",
        "V0220-010-REDACTION-FAILURE-STATES-VISIBLE",
        "V0220-010-NO-TRADING-COMMANDS",
        "V0220-010-NO-FUTURES-OKX",
        "V0220-010-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH1318DashboardCLILiveCanaryEvidenceSurfaceShowsCanaryEvidenceWithoutCommands",
        "swift test --filter TargetGraphTests/testGH1318ReleaseV0220DashboardCLILiveCanaryEvidenceSurface",
        "bash checks/verify-v0.22.0-dashboard-cli-live-canary-evidence-surface.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/verify-v0.21.0.sh",
        "bash checks/run.sh"
    ]

    public static let requiredFailureClassLabels = [
        "auth",
        "endpoint",
        "risk",
        "kill-switch",
        "no-trade",
        "submit",
        "cancel",
        "status",
        "reconciliation",
        "artifact"
    ]

    public static let requiredNextActionLabels = [
        "refresh credential reference",
        "correct endpoint policy",
        "stop and escalate",
        "keep kill switch active",
        "keep no-trade active",
        "do not retry submit",
        "query status then reconcile",
        "operator review",
        "rebuild artifact bundle"
    ]

    public static let requiredFailureClassOutputLines = [
        "failureClass=auth;nextAction=refresh credential reference;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true",
        "failureClass=endpoint;nextAction=correct endpoint policy;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true",
        "failureClass=risk;nextAction=stop and escalate;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true",
        "failureClass=kill-switch;nextAction=keep kill switch active;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true",
        "failureClass=no-trade;nextAction=keep no-trade active;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true",
        "failureClass=submit;nextAction=do not retry submit;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true",
        "failureClass=cancel;nextAction=query status then reconcile;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true",
        "failureClass=status;nextAction=query status then reconcile;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true",
        "failureClass=reconciliation;nextAction=operator review;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true",
        "failureClass=artifact;nextAction=rebuild artifact bundle;failClosed=true;blocksSubmit=true;blocksCancel=true;requiresOperatorAction=true;redactedEvidenceRequired=true"
    ]

    public static let requiredRollbackCommandLabels =
        ReleaseV0220SpotLiveCanaryRollbackCommandKind.allCases.map(\.rawValue)

    public static let requiredMatchedExchangeOrderID =
        ReleaseV0220SpotLiveCanaryStatusCancelTransportPolicy.requiredExchangeOrderID.rawValue

    public static let requiredMatchedOMSReference =
        ReleaseV0220SpotLiveCanaryReconciliationArtifact.redactedReference(scope: "oms-log")

    public static let requiredReconciliationArtifactReference =
        ReleaseV0220SpotLiveCanaryReconciliationArtifact.redactedReference(scope: "artifact")

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.liveCanaryEvidenceSurface.cliCommand",
                expected: cliCommand,
                actual: arguments.joined(separator: " ")
            )
        }
        guard arguments.count <= 2,
              arguments.count == 1
                  || ["status", "failures", "rollback", "reconciliation"].contains(Self.argument(arguments, at: 1) ?? "")
        else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.liveCanaryEvidenceSurface.arguments",
                expected: "\(cliCommand) [status|failures|rollback|reconciliation]",
                actual: arguments.joined(separator: " ")
            )
        }
        switch Self.argument(arguments, at: 1) ?? "status" {
        case "status":
            return Self.statusOutput(
                rows: try deterministicRows(),
                validationAnchors: requiredValidationAnchors,
                releaseVersion: "v0.22.0",
                boundaryHeld: true
            )
        case "failures":
            return Self.failuresOutput(
                failureClassLabels: requiredFailureClassLabels,
                nextActionLabels: requiredNextActionLabels,
                failureStatesVisible: true,
                nextActionsVisible: true,
                boundaryHeld: true
            )
        case "rollback":
            return Self.rollbackOutput(
                rollbackCommandLabels: requiredRollbackCommandLabels,
                rollbackEvidenceVisible: true,
                boundaryHeld: true
            )
        case "reconciliation":
            return Self.reconciliationOutput(
                reconciliationVisible: true,
                reconciliationEvidenceHeld: true,
                matchedExchangeOrderID: requiredMatchedExchangeOrderID,
                matchedOMSReference: requiredMatchedOMSReference,
                reconciliationArtifactReference: requiredReconciliationArtifactReference,
                boundaryHeld: true
            )
        default:
            preconditionFailure("guard above restricts live canary evidence arguments")
        }
    }

    public func statusOutput() -> String {
        Self.statusOutput(
            rows: rows,
            validationAnchors: validationAnchors,
            releaseVersion: releaseVersion,
            boundaryHeld: boundaryHeld
        )
    }

    private static func statusOutput(
        rows: [ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow],
        validationAnchors: [String],
        releaseVersion: String,
        boundaryHeld: Bool
    ) -> String {
        let stateLabels = uniqueStable(rows.map { $0.state.rawValue })
        let gateLabels = uniqueStable(rows.map(\.gateLabel))
        let approvalVisible = rows.contains { $0.area == .approval && $0.visibleInDashboard && $0.visibleInCLI }
        let preflightVisible = rows.contains { $0.area == .signedAccountPreflight && $0.visibleInDashboard && $0.visibleInCLI }
        let submitVisible = rows.contains { $0.area == .submitTransport && $0.visibleInDashboard && $0.visibleInCLI }
        let statusCancelVisible = rows.contains { $0.area == .statusCancelTransport && $0.visibleInDashboard && $0.visibleInCLI }
        let omsVisible = rows.contains { $0.area == .omsEventLog && $0.visibleInDashboard && $0.visibleInCLI }
        let reconciliationVisible = rows.contains { $0.area == .reconciliation && $0.visibleInDashboard && $0.visibleInCLI }
        let failureStatesVisible =
            rows.contains {
                $0.area == .failureClassification
                    && $0.failureClassLabels == requiredFailureClassLabels
            }
        let nextActionsVisible =
            rows.contains {
                $0.area == .failureClassification
                    && $0.nextActionLabels == requiredNextActionLabels
            }

        return ([
            "mtpro \(Self.cliCommand) status",
            "issue=GH-1318",
            "validationAnchor=TVM-RELEASE-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE",
            "verificationAnchor=GH-1318-VERIFY-V0220-DASHBOARD-CLI-LIVE-CANARY-EVIDENCE-SURFACE",
            "requiredAnchors=\(validationAnchors.joined(separator: ","))",
            "releaseVersion=\(releaseVersion)",
            "surfaceRows=\(rows.count)",
            "states=\(stateLabels.joined(separator: ","))",
            "gates=\(gateLabels.joined(separator: ","))",
            "approvalVisible=\(approvalVisible)",
            "preflightVisible=\(preflightVisible)",
            "submitVisible=\(submitVisible)",
            "statusCancelVisible=\(statusCancelVisible)",
            "omsVisible=\(omsVisible)",
            "reconciliationVisible=\(reconciliationVisible)",
            "failureStatesVisible=\(failureStatesVisible)",
            "nextActionsVisible=\(nextActionsVisible)"
        ] + rows.map { row in
            [
                "row=\(row.area.rawValue)",
                "issue=\(row.sourceIssueID)",
                "state=\(row.state.rawValue)",
                "gate=\(row.gateLabel)",
                "digest=\(row.redactedEvidenceDigest)",
                "summary=\(row.statusSummary)"
            ].joined(separator: ";")
        } + Self.closedCapabilityLines(boundaryHeld: boundaryHeld)).joined(separator: "\n")
    }

    public func failuresOutput() -> String {
        Self.failuresOutput(
            failureClassLabels: failureClassLabels,
            nextActionLabels: nextActionLabels,
            failureStatesVisible: failureStatesVisible,
            nextActionsVisible: nextActionsVisible,
            boundaryHeld: boundaryHeld
        )
    }

    private static func failuresOutput(
        failureClassLabels: [String],
        nextActionLabels: [String],
        failureStatesVisible: Bool,
        nextActionsVisible: Bool,
        boundaryHeld: Bool
    ) -> String {
        ([
            "mtpro \(Self.cliCommand) failures",
            "issue=GH-1318",
            "sourceIssue=GH-1317",
            "failureClasses=\(failureClassLabels.joined(separator: ","))",
            "nextActions=\(nextActionLabels.joined(separator: ","))"
        ] + Self.requiredFailureClassOutputLines + [
            "failureStatesVisible=\(failureStatesVisible)",
            "nextActionsVisible=\(nextActionsVisible)"
        ] + Self.closedCapabilityLines(boundaryHeld: boundaryHeld)).joined(separator: "\n")
    }

    public func rollbackOutput() -> String {
        Self.rollbackOutput(
            rollbackCommandLabels: rollbackCommandLabels,
            rollbackEvidenceVisible: rollbackEvidenceVisible,
            boundaryHeld: boundaryHeld
        )
    }

    private static func rollbackOutput(
        rollbackCommandLabels: [String],
        rollbackEvidenceVisible: Bool,
        boundaryHeld: Bool
    ) -> String {
        return ([
            "mtpro \(Self.cliCommand) rollback",
            "issue=GH-1318",
            "sourceIssue=GH-1317",
            "rollbackCommands=\(rollbackCommandLabels.joined(separator: ","))",
            "rollbackEvidenceVisible=\(rollbackEvidenceVisible)"
        ] + rollbackCommandLabels.map { command in
            [
                "command=\(command)",
                "killSwitchActive=true",
                "noTradeActive=true",
                "blockedBeforeTransport=true",
                "blockedBeforeBrokerGateway=true",
                "rollbackEvidenceRecorded=true",
                "operatorNextAction=stop and escalate",
                "unintendedSubmitSent=false",
                "unintendedCancelSent=false",
                "rawBrokerPayloadPersisted=false"
            ].joined(separator: ";")
        } + Self.closedCapabilityLines(boundaryHeld: boundaryHeld)).joined(separator: "\n")
    }

    public func reconciliationOutput() -> String {
        Self.reconciliationOutput(
            reconciliationVisible: reconciliationVisible,
            reconciliationEvidenceHeld: reconciliationEvidenceHeld,
            matchedExchangeOrderID: matchedExchangeOrderID,
            matchedOMSReference: matchedOMSReference,
            reconciliationArtifactReference: reconciliationArtifactReference,
            boundaryHeld: boundaryHeld
        )
    }

    private static func reconciliationOutput(
        reconciliationVisible: Bool,
        reconciliationEvidenceHeld: Bool,
        matchedExchangeOrderID: String,
        matchedOMSReference: String,
        reconciliationArtifactReference: String,
        boundaryHeld: Bool
    ) -> String {
        return ([
            "mtpro \(Self.cliCommand) reconciliation",
            "issue=GH-1318",
            "sourceIssue=GH-1316",
            "reconciliationEvidenceVisible=\(reconciliationVisible)",
            "upstreamEvidenceHeld=\(reconciliationEvidenceHeld)",
            "matchedExchangeOrderID=\(matchedExchangeOrderID)",
            "matchedOMSReference=\(matchedOMSReference)",
            "reconciliationArtifactReference=\(reconciliationArtifactReference)"
        ] + Self.closedCapabilityLines(boundaryHeld: boundaryHeld)).joined(separator: "\n")
    }

    private static func closedCapabilityLines(boundaryHeld: Bool) -> [String] {
        [
            "dashboardReadOnly=true",
            "cliReadOnly=true",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "submitCancelReplaceEnabled=false",
            "futuresEnabled=false",
            "okxEnabled=false",
            "rawOrderIDVisible=false",
            "rawBrokerPayloadVisible=false",
            "rawBrokerPayloadPersisted=false",
            "productionCutoverAuthorized=false",
            "productionTradingEnabledByDefault=false",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    private static func validateSurface(
        issueID: Identifier,
        blockedByIssueIDs: [Identifier],
        downstreamIssueIDs: [Identifier],
        canonicalQueueRange: String,
        releaseVersion: String,
        failureClassLabels: [String],
        nextActionLabels: [String],
        rollbackCommandLabels: [String],
        reconciliationEvidenceHeld: Bool,
        matchedExchangeOrderID: String,
        matchedOMSReference: String,
        reconciliationArtifactReference: String,
        rows: [ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow],
        validationAnchors: [String],
        requiredValidationCommands: [String],
        productionTradingEnabledByDefault: Bool,
        futuresEnabled: Bool,
        okxEnabled: Bool,
        dashboardTradingCommandEnabled: Bool,
        tradingButtonVisible: Bool,
        orderFormVisible: Bool,
        liveCommandVisible: Bool,
        submitCancelReplaceEnabled: Bool,
        rawOrderIDVisible: Bool,
        rawBrokerPayloadVisible: Bool,
        rawBrokerPayloadPersisted: Bool,
        createsTagOrRelease: Bool,
        productionCutoverAuthorized: Bool
    ) -> Bool {
        let failureStatesVisible =
            failureClassLabels == Self.requiredFailureClassLabels
                && rows.contains {
                    $0.area == .failureClassification
                        && $0.failureClassLabels == failureClassLabels
                }
        let nextActionsVisible = rows.contains {
            $0.area == .failureClassification
                && $0.nextActionLabels == nextActionLabels
        }
        let rollbackEvidenceVisible =
            rows.contains { $0.area == .rollbackDrill && $0.failureClassLabels.contains("kill-switch") }
                && rows.contains { $0.area == .rollbackDrill && $0.failureClassLabels.contains("no-trade") }
                && rollbackCommandLabels == Self.requiredRollbackCommandLabels
        let forbiddenCapabilitiesClosed =
            productionTradingEnabledByDefault == false
                && futuresEnabled == false
                && okxEnabled == false
                && dashboardTradingCommandEnabled == false
                && tradingButtonVisible == false
                && orderFormVisible == false
                && liveCommandVisible == false
                && submitCancelReplaceEnabled == false
                && rawOrderIDVisible == false
                && rawBrokerPayloadVisible == false
                && rawBrokerPayloadPersisted == false
                && createsTagOrRelease == false
                && productionCutoverAuthorized == false

        return issueID.rawValue == "GH-1318"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1317"]
            && downstreamIssueIDs.map(\.rawValue) == ["GH-1319"]
            && canonicalQueueRange == "GH-1309..GH-1320"
            && releaseVersion == "v0.22.0"
            && failureClassLabels == Self.requiredFailureClassLabels
            && nextActionLabels == Self.requiredNextActionLabels
            && rollbackCommandLabels == Self.requiredRollbackCommandLabels
            && reconciliationEvidenceHeld
            && matchedExchangeOrderID == Self.requiredMatchedExchangeOrderID
            && matchedOMSReference == Self.requiredMatchedOMSReference
            && reconciliationArtifactReference == Self.requiredReconciliationArtifactReference
            && rows.map(\.area) == ReleaseV0220SpotLiveCanaryEvidenceSurfaceArea.allCases
            && rows.allSatisfy(\.rowHeld)
            && failureStatesVisible
            && nextActionsVisible
            && rollbackEvidenceVisible
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && forbiddenCapabilitiesClosed
    }

    private static func defaultRows(
        failureLabels: [String],
        nextActions: [String]
    ) throws -> [ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow] {
        return try [
            ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow(
                area: .approval,
                sourceIssueID: "GH-1309",
                state: .approved,
                gateLabel: "operator-approval-run-lock",
                statusSummary: "operator approval and one-run lock evidence visible"
            ),
            ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow(
                area: .signedAccountPreflight,
                sourceIssueID: "GH-1311",
                state: .ready,
                gateLabel: "signed-account-preflight",
                statusSummary: "signed account preflight evidence is redacted and inspectable"
            ),
            ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow(
                area: .submitTransport,
                sourceIssueID: "GH-1313",
                state: .submitted,
                gateLabel: "single-live-submit-transport",
                statusSummary: "one-shot Spot canary submit transport evidence is visible without command controls"
            ),
            ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow(
                area: .statusCancelTransport,
                sourceIssueID: "GH-1314",
                state: .cancelled,
                gateLabel: "status-cancel-transport",
                statusSummary: "status and cancel transport evidence is visible as read-only rows"
            ),
            ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow(
                area: .omsEventLog,
                sourceIssueID: "GH-1315",
                state: .ready,
                gateLabel: "oms-event-log",
                statusSummary: "OMS evidence log digest is visible without raw broker payload"
            ),
            ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow(
                area: .reconciliation,
                sourceIssueID: "GH-1316",
                state: .reconciled,
                gateLabel: "reconciliation-evidence",
                statusSummary: "reconciliation evidence is visible with redacted matched digest"
            ),
            ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow(
                area: .failureClassification,
                sourceIssueID: "GH-1317",
                state: .failClosed,
                gateLabel: "failure-class-next-action",
                statusSummary: "fail-closed failure classes and deterministic next actions are visible",
                failureClassLabels: failureLabels,
                nextActionLabels: nextActions
            ),
            ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow(
                area: .rollbackDrill,
                sourceIssueID: "GH-1317",
                state: .failClosed,
                gateLabel: "kill-switch-no-trade-rollback",
                statusSummary: "kill switch and no-trade rollback drill blocks submit and cancel before transport",
                failureClassLabels: ["kill-switch", "no-trade"],
                nextActionLabels: ["stop and escalate"]
            ),
            ReleaseV0220SpotLiveCanaryEvidenceSurfaceRow(
                area: .redactionBoundary,
                sourceIssueID: "GH-1318",
                state: .redacted,
                gateLabel: "dashboard-cli-redaction",
                statusSummary: "raw order id and raw broker payload remain hidden from Dashboard and CLI"
            )
        ]
    }

    private static func uniqueStable(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        return values.filter { seen.insert($0).inserted }
    }

    private static func argument(_ arguments: [String], at index: Int) -> String? {
        guard arguments.indices.contains(index) else {
            return nil
        }
        return arguments[index]
    }
}
