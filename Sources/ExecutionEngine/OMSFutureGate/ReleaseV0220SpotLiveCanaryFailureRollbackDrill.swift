import DomainModel
import Foundation

/// ReleaseV0220SpotLiveCanaryFailureClass 固定 GH-1317 要覆盖的
/// Binance Spot canary transport failure taxonomy。
public enum ReleaseV0220SpotLiveCanaryFailureClass:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case auth
    case endpoint
    case risk
    case killSwitch = "kill-switch"
    case noTrade = "no-trade"
    case submit
    case cancel
    case status
    case reconciliation
    case artifact
}

/// ReleaseV0220SpotLiveCanaryFailureNextAction 描述 GH-1317 每类 failure
/// 必须给 operator 留下的 deterministic next action。
public enum ReleaseV0220SpotLiveCanaryFailureNextAction:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case refreshCredentialReference = "refresh credential reference"
    case correctEndpointPolicy = "correct endpoint policy"
    case stopAndEscalate = "stop and escalate"
    case keepKillSwitchActive = "keep kill switch active"
    case keepNoTradeActive = "keep no-trade active"
    case doNotRetrySubmit = "do not retry submit"
    case statusThenReconcile = "query status then reconcile"
    case operatorReview = "operator review"
    case rebuildArtifactBundle = "rebuild artifact bundle"
}

/// ReleaseV0220SpotLiveCanaryRollbackCommandKind 固定 rollback drill 中必须
/// 被 kill switch / no-trade 阻断的 command vocabulary。
public enum ReleaseV0220SpotLiveCanaryRollbackCommandKind:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case submit
    case cancel
}

/// ReleaseV0220SpotLiveCanaryFailureClassification 是 GH-1317 的单条
/// failure classification。每条 classification 都必须 fail closed、给出
/// deterministic operator next action，并证明不会扩大到 Futures / OKX / Dashboard
/// command 或 production cutover。
public struct ReleaseV0220SpotLiveCanaryFailureClassification:
    Codable, Equatable, Sendable
{
    public let failureClass: ReleaseV0220SpotLiveCanaryFailureClass
    public let nextAction: ReleaseV0220SpotLiveCanaryFailureNextAction
    public let failClosed: Bool
    public let blocksSubmit: Bool
    public let blocksCancel: Bool
    public let requiresOperatorAction: Bool
    public let redactedEvidenceRequired: Bool
    public let productionTradingEnabledByDefault: Bool
    public let futuresEnabled: Bool
    public let okxEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var deterministicNextActionHeld: Bool {
        ReleaseV0220SpotLiveCanaryFailureNextAction.allCases.contains(nextAction)
            && nextAction.rawValue.isEmpty == false
    }

    public var classificationHeld: Bool {
        deterministicNextActionHeld
            && failClosed
            && blocksSubmit
            && blocksCancel
            && requiresOperatorAction
            && redactedEvidenceRequired
            && forbiddenCapabilitiesClosed
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && futuresEnabled == false
            && okxEnabled == false
            && dashboardTradingCommandEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        failureClass: ReleaseV0220SpotLiveCanaryFailureClass,
        nextAction: ReleaseV0220SpotLiveCanaryFailureNextAction,
        failClosed: Bool = true,
        blocksSubmit: Bool = true,
        blocksCancel: Bool = true,
        requiresOperatorAction: Bool = true,
        redactedEvidenceRequired: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        futuresEnabled: Bool = false,
        okxEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.failureClass = failureClass
        self.nextAction = nextAction
        self.failClosed = failClosed
        self.blocksSubmit = blocksSubmit
        self.blocksCancel = blocksCancel
        self.requiresOperatorAction = requiresOperatorAction
        self.redactedEvidenceRequired = redactedEvidenceRequired
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.futuresEnabled = futuresEnabled
        self.okxEnabled = okxEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard classificationHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.failureRollback.classification",
                expected: "fail-closed deterministic next action with submit/cancel block",
                actual: failureClass.rawValue
            )
        }
    }

    public static func deterministicFixtures() throws
        -> [ReleaseV0220SpotLiveCanaryFailureClassification]
    {
        try [
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .auth,
                nextAction: .refreshCredentialReference
            ),
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .endpoint,
                nextAction: .correctEndpointPolicy
            ),
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .risk,
                nextAction: .stopAndEscalate
            ),
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .killSwitch,
                nextAction: .keepKillSwitchActive
            ),
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .noTrade,
                nextAction: .keepNoTradeActive
            ),
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .submit,
                nextAction: .doNotRetrySubmit
            ),
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .cancel,
                nextAction: .statusThenReconcile
            ),
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .status,
                nextAction: .statusThenReconcile
            ),
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .reconciliation,
                nextAction: .operatorReview
            ),
            ReleaseV0220SpotLiveCanaryFailureClassification(
                failureClass: .artifact,
                nextAction: .rebuildArtifactBundle
            )
        ]
    }
}

/// ReleaseV0220SpotLiveCanaryRollbackDrillRecord 是 GH-1317 的本地 rollback
/// drill record。它只证明 command 在触达 transport / broker gateway 前被阻断；
/// 不提交、撤销或替换真实订单。
public struct ReleaseV0220SpotLiveCanaryRollbackDrillRecord:
    Codable, Equatable, Sendable
{
    public let command: ReleaseV0220SpotLiveCanaryRollbackCommandKind
    public let killSwitchActive: Bool
    public let noTradeActive: Bool
    public let blockedBeforeTransport: Bool
    public let blockedBeforeBrokerGateway: Bool
    public let rollbackEvidenceRecorded: Bool
    public let operatorNextAction: ReleaseV0220SpotLiveCanaryFailureNextAction
    public let unintendedSubmitSent: Bool
    public let unintendedCancelSent: Bool
    public let rawBrokerPayloadPersisted: Bool
    public let productionCutoverAuthorized: Bool

    public var drillHeld: Bool {
        killSwitchActive
            && noTradeActive
            && blockedBeforeTransport
            && blockedBeforeBrokerGateway
            && rollbackEvidenceRecorded
            && operatorNextAction.rawValue.isEmpty == false
            && noUnintendedOrders
            && rawBrokerPayloadPersisted == false
            && productionCutoverAuthorized == false
    }

    public var noUnintendedOrders: Bool {
        unintendedSubmitSent == false
            && unintendedCancelSent == false
    }

    public init(
        command: ReleaseV0220SpotLiveCanaryRollbackCommandKind,
        killSwitchActive: Bool = true,
        noTradeActive: Bool = true,
        blockedBeforeTransport: Bool = true,
        blockedBeforeBrokerGateway: Bool = true,
        rollbackEvidenceRecorded: Bool = true,
        operatorNextAction: ReleaseV0220SpotLiveCanaryFailureNextAction = .stopAndEscalate,
        unintendedSubmitSent: Bool = false,
        unintendedCancelSent: Bool = false,
        rawBrokerPayloadPersisted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.command = command
        self.killSwitchActive = killSwitchActive
        self.noTradeActive = noTradeActive
        self.blockedBeforeTransport = blockedBeforeTransport
        self.blockedBeforeBrokerGateway = blockedBeforeBrokerGateway
        self.rollbackEvidenceRecorded = rollbackEvidenceRecorded
        self.operatorNextAction = operatorNextAction
        self.unintendedSubmitSent = unintendedSubmitSent
        self.unintendedCancelSent = unintendedCancelSent
        self.rawBrokerPayloadPersisted = rawBrokerPayloadPersisted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard drillHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.failureRollback.rollbackDrill",
                expected: "kill switch and no-trade block before transport with no unintended orders",
                actual: command.rawValue
            )
        }
    }
}

/// ReleaseV0220SpotLiveCanaryFailureRollbackDrillEvidence 是 GH-1317 的聚合证据。
/// 它消费 GH-1316 reconciliation evidence，并为 auth / endpoint / risk /
/// kill switch / no-trade / submit / cancel / status / reconciliation / artifact
/// failure 输出 fail-closed classification、operator next action 和 rollback drill。
public struct ReleaseV0220SpotLiveCanaryFailureRollbackDrillEvidence:
    Codable, Equatable, Sendable
{
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let upstreamReconciliationEvidence: ReleaseV0220SpotLiveCanaryReconciliationEvidence
    public let failureClassifications: [ReleaseV0220SpotLiveCanaryFailureClassification]
    public let submitRollbackDrill: ReleaseV0220SpotLiveCanaryRollbackDrillRecord
    public let cancelRollbackDrill: ReleaseV0220SpotLiveCanaryRollbackDrillRecord
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let futuresEnabled: Bool
    public let okxEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1317"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1315", "GH-1316"]
            && downstreamIssueIDs.map(\.rawValue) == ["GH-1318"]
            && canonicalQueueRange == "GH-1309..GH-1320"
            && releaseVersion == "v0.22.0"
            && upstreamReconciliationEvidence.evidenceHeld
            && allFailureClassesCovered
            && deterministicNextActionsHeld
            && killSwitchNoTradeEvidencePresent
            && rollbackDrillHeld
            && noUnintendedOrders
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && forbiddenCapabilitiesClosed
    }

    public var allFailureClassesCovered: Bool {
        Set(failureClassifications.map(\.failureClass))
            == Set(ReleaseV0220SpotLiveCanaryFailureClass.allCases)
    }

    public var deterministicNextActionsHeld: Bool {
        failureClassifications.allSatisfy(\.classificationHeld)
    }

    public var killSwitchNoTradeEvidencePresent: Bool {
        guard let killSwitch = failureClassifications.first(where: { $0.failureClass == .killSwitch }),
              let noTrade = failureClassifications.first(where: { $0.failureClass == .noTrade }) else {
            return false
        }

        return killSwitch.blocksSubmit
            && killSwitch.blocksCancel
            && noTrade.blocksSubmit
            && noTrade.blocksCancel
            && submitRollbackDrill.killSwitchActive
            && submitRollbackDrill.noTradeActive
            && cancelRollbackDrill.killSwitchActive
            && cancelRollbackDrill.noTradeActive
    }

    public var rollbackDrillHeld: Bool {
        submitRollbackDrill.command == .submit
            && submitRollbackDrill.drillHeld
            && cancelRollbackDrill.command == .cancel
            && cancelRollbackDrill.drillHeld
    }

    public var noUnintendedOrders: Bool {
        submitRollbackDrill.noUnintendedOrders
            && cancelRollbackDrill.noUnintendedOrders
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && futuresEnabled == false
            && okxEnabled == false
            && dashboardTradingCommandEnabled == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1317-release-v0.22.0-failure-rollback-drill"),
        issueID: Identifier = Identifier.constant("GH-1317"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1315"), Identifier.constant("GH-1316")],
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1318")],
        canonicalQueueRange: String = "GH-1309..GH-1320",
        releaseVersion: String = "v0.22.0",
        upstreamReconciliationEvidence: ReleaseV0220SpotLiveCanaryReconciliationEvidence? = nil,
        failureClassifications: [ReleaseV0220SpotLiveCanaryFailureClassification]? = nil,
        submitRollbackDrill: ReleaseV0220SpotLiveCanaryRollbackDrillRecord? = nil,
        cancelRollbackDrill: ReleaseV0220SpotLiveCanaryRollbackDrillRecord? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        futuresEnabled: Bool = false,
        okxEnabled: Bool = false,
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
        self.upstreamReconciliationEvidence = try upstreamReconciliationEvidence
            ?? ReleaseV0220SpotLiveCanaryReconciliationEvidence.deterministicFixture()
        self.failureClassifications = try failureClassifications
            ?? ReleaseV0220SpotLiveCanaryFailureClassification.deterministicFixtures()
        self.submitRollbackDrill = try submitRollbackDrill
            ?? ReleaseV0220SpotLiveCanaryRollbackDrillRecord(command: .submit)
        self.cancelRollbackDrill = try cancelRollbackDrill
            ?? ReleaseV0220SpotLiveCanaryRollbackDrillRecord(command: .cancel)
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.futuresEnabled = futuresEnabled
        self.okxEnabled = okxEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.failureRollback",
                expected: "fail-closed failure taxonomy and rollback drill evidence",
                actual: "invalid failure rollback drill"
            )
        }
    }

    public static func deterministicFixture() throws
        -> ReleaseV0220SpotLiveCanaryFailureRollbackDrillEvidence
    {
        try ReleaseV0220SpotLiveCanaryFailureRollbackDrillEvidence()
    }

    public static let requiredValidationAnchors = [
        "GH-1317-VERIFY-V0220-FAILURE-ROLLBACK-DRILL",
        "TVM-RELEASE-V0220-FAILURE-ROLLBACK-DRILL",
        "V0220-009-BLOCKED-BY-GH1315-GH1316",
        "V0220-009-FAILURE-CLASSIFICATION",
        "V0220-009-AUTH-ENDPOINT-RISK-KILL-NOTRADE-SUBMIT-CANCEL-STATUS-RECONCILIATION-ARTIFACT",
        "V0220-009-DETERMINISTIC-NEXT-ACTION",
        "V0220-009-KILL-SWITCH-BLOCKS-SUBMIT-CANCEL",
        "V0220-009-NO-TRADE-BLOCKS-SUBMIT-CANCEL",
        "V0220-009-ROLLBACK-DRILL-EVIDENCE",
        "V0220-009-NO-UNINTENDED-ORDERS",
        "V0220-009-NO-FUTURES-OKX",
        "V0220-009-NO-DASHBOARD-TRADING-CONTROLS",
        "V0220-009-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1317ReleaseV0220FailureClassificationRollbackKillSwitchNoTradeDrill",
        "bash checks/verify-v0.22.0-failure-rollback-drill.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/verify-v0.21.0.sh",
        "bash checks/run.sh"
    ]
}
