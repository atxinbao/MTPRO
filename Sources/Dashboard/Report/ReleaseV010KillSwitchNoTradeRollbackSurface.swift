import Foundation

/// ReleaseV010KillSwitchControlState 固定 GH-536 release command hard gate 状态。
///
/// 这些状态只用于 Dashboard / Report 的 deterministic evidence：它们说明 submit / cancel / replace
/// 在 release v0.1.0 默认被 no-trade、kill switch 和 rollback gate 阻断，不代表真实运行时开关、
/// broker emergency API、Live PRO Console command 或 production cutover 授权。
public enum ReleaseV010KillSwitchControlState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case globalNoTradeActive = "global no-trade active"
    case killSwitchActive = "kill switch active"
    case rollbackRequired = "rollback required"
    case operatorReviewRequired = "operator review required"
    case productionTradingDisabled = "production trading disabled"
}

/// ReleaseV010KillSwitchBlockedActionEvidence 是 GH-536 单个 command action 的阻断证据。
///
/// 每条证据都必须绑定 GH-535 controlled command surface，并把 submit / cancel / replace 固定为
/// no-trade + kill switch blocked。它不读取 secret、不打开 production endpoint、不调用 ExecutionClient、
/// 不连接 broker、不提交真实订单，也不允许自动恢复。
public struct ReleaseV010KillSwitchBlockedActionEvidence: Codable, Equatable, Sendable {
    public let action: ReleaseV010ControlledCommandAction
    public let states: [ReleaseV010KillSwitchControlState]
    public let blockingReasons: [String]
    public let rollbackEvidenceID: String
    public let operatorEvidenceID: String
    public let sourceAnchors: [String]
    public let commandEntryVisible: Bool
    public let commandEntryEnabled: Bool
    public let blockedByGlobalNoTrade: Bool
    public let blockedByKillSwitch: Bool
    public let rollbackEvidenceRequired: Bool
    public let operatorEvidenceRequired: Bool
    public let readsSecret: Bool
    public let opensProductionEndpoint: Bool
    public let connectsBroker: Bool
    public let callsExecutionClient: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesExecutionEngine: Bool
    public let bypassesOMS: Bool
    public let bypassesKillSwitch: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let triggersAutoRecovery: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool

    public init(
        action: ReleaseV010ControlledCommandAction,
        states: [ReleaseV010KillSwitchControlState] = Self.requiredStates,
        blockingReasons: [String]? = nil,
        rollbackEvidenceID: String? = nil,
        operatorEvidenceID: String? = nil,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        commandEntryVisible: Bool = true,
        commandEntryEnabled: Bool = false,
        blockedByGlobalNoTrade: Bool = true,
        blockedByKillSwitch: Bool = true,
        rollbackEvidenceRequired: Bool = true,
        operatorEvidenceRequired: Bool = true,
        readsSecret: Bool = false,
        opensProductionEndpoint: Bool = false,
        connectsBroker: Bool = false,
        callsExecutionClient: Bool = false,
        bypassesRiskEngine: Bool = false,
        bypassesExecutionEngine: Bool = false,
        bypassesOMS: Bool = false,
        bypassesKillSwitch: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        triggersAutoRecovery: Bool = false,
        authorizesLiveTrading: Bool = false,
        authorizesTradingExecution: Bool = false
    ) {
        self.action = action
        self.states = states
        self.blockingReasons = blockingReasons
            ?? [
                "\(action.rawValue) is blocked by release v0.1.0 global no-trade mode.",
                "\(action.rawValue) requires an explicit kill switch pass before any execution path.",
                "\(action.rawValue) requires auditable rollback and operator evidence before recovery."
            ]
        self.rollbackEvidenceID = rollbackEvidenceID ?? "gh-536-\(action.rawValue)-rollback-evidence"
        self.operatorEvidenceID = operatorEvidenceID ?? "gh-536-\(action.rawValue)-operator-evidence"
        self.sourceAnchors = sourceAnchors
        self.commandEntryVisible = commandEntryVisible
        self.commandEntryEnabled = commandEntryEnabled
        self.blockedByGlobalNoTrade = blockedByGlobalNoTrade
        self.blockedByKillSwitch = blockedByKillSwitch
        self.rollbackEvidenceRequired = rollbackEvidenceRequired
        self.operatorEvidenceRequired = operatorEvidenceRequired
        self.readsSecret = readsSecret
        self.opensProductionEndpoint = opensProductionEndpoint
        self.connectsBroker = connectsBroker
        self.callsExecutionClient = callsExecutionClient
        self.bypassesRiskEngine = bypassesRiskEngine
        self.bypassesExecutionEngine = bypassesExecutionEngine
        self.bypassesOMS = bypassesOMS
        self.bypassesKillSwitch = bypassesKillSwitch
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.triggersAutoRecovery = triggersAutoRecovery
        self.authorizesLiveTrading = authorizesLiveTrading
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public var actionBoundaryHeld: Bool {
        states == Self.requiredStates
            && blockingReasons.count == 3
            && rollbackEvidenceID.hasPrefix("gh-536-\(action.rawValue)")
            && operatorEvidenceID.hasPrefix("gh-536-\(action.rawValue)")
            && sourceAnchors == Self.requiredSourceAnchors
            && commandEntryVisible
            && commandEntryEnabled == false
            && blockedByGlobalNoTrade
            && blockedByKillSwitch
            && rollbackEvidenceRequired
            && operatorEvidenceRequired
            && forbiddenCapabilitiesRemainClosed
    }

    public var forbiddenCapabilitiesRemainClosed: Bool {
        [
            readsSecret,
            opensProductionEndpoint,
            connectsBroker,
            callsExecutionClient,
            bypassesRiskEngine,
            bypassesExecutionEngine,
            bypassesOMS,
            bypassesKillSwitch,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder,
            triggersAutoRecovery,
            authorizesLiveTrading,
            authorizesTradingExecution
        ].allSatisfy { $0 == false }
    }

    public static let requiredStates: [ReleaseV010KillSwitchControlState] = [
        .globalNoTradeActive,
        .killSwitchActive,
        .rollbackRequired,
        .operatorReviewRequired,
        .productionTradingDisabled
    ]

    public static let requiredSourceAnchors = [
        "GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE",
        "GH-531-BINANCE-TESTNET-SUBMIT-CANCEL-REPLACE",
        "GH-535-DASHBOARD-CONTROLLED-COMMAND-SURFACE",
        "GH-536-KILL-SWITCH-NO-TRADE-ROLLBACK-CONTROLS"
    ]
}

/// ReleaseV010RollbackOperatorEvidence 是 GH-536 rollback 和 operator review 的审计证据。
///
/// 该证据只说明 rollback plan 已可展示、operator evidence 已可追溯，并且恢复不能自动发生。
/// 它不执行 rollback、不提交 cancel / replace、不调用 broker emergency endpoint，也不授权 production trading。
public struct ReleaseV010RollbackOperatorEvidence: Codable, Equatable, Sendable {
    public let rollbackPlanID: String
    public let incidentEvidenceID: String
    public let operatorEvidenceID: String
    public let auditTrailAnchor: String
    public let recoveryBoundary: [ReleaseV010KillSwitchControlState]
    public let rollbackPlanVisible: Bool
    public let operatorEvidenceRecorded: Bool
    public let manualReviewRequired: Bool
    public let noAutomaticRecovery: Bool
    public let productionTradingDisabledByDefault: Bool
    public let executesRollback: Bool
    public let callsExecutionClient: Bool
    public let connectsBroker: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let authorizesTradingExecution: Bool

    public init(
        rollbackPlanID: String = "gh-536-release-v010-rollback-plan",
        incidentEvidenceID: String = "gh-536-release-v010-incident-stop-evidence",
        operatorEvidenceID: String = "gh-536-release-v010-operator-review-evidence",
        auditTrailAnchor: String = "GH-536-ROLLBACK-OPERATOR-EVIDENCE",
        recoveryBoundary: [ReleaseV010KillSwitchControlState] = Self.requiredRecoveryBoundary,
        rollbackPlanVisible: Bool = true,
        operatorEvidenceRecorded: Bool = true,
        manualReviewRequired: Bool = true,
        noAutomaticRecovery: Bool = true,
        productionTradingDisabledByDefault: Bool = true,
        executesRollback: Bool = false,
        callsExecutionClient: Bool = false,
        connectsBroker: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        authorizesTradingExecution: Bool = false
    ) {
        self.rollbackPlanID = rollbackPlanID
        self.incidentEvidenceID = incidentEvidenceID
        self.operatorEvidenceID = operatorEvidenceID
        self.auditTrailAnchor = auditTrailAnchor
        self.recoveryBoundary = recoveryBoundary
        self.rollbackPlanVisible = rollbackPlanVisible
        self.operatorEvidenceRecorded = operatorEvidenceRecorded
        self.manualReviewRequired = manualReviewRequired
        self.noAutomaticRecovery = noAutomaticRecovery
        self.productionTradingDisabledByDefault = productionTradingDisabledByDefault
        self.executesRollback = executesRollback
        self.callsExecutionClient = callsExecutionClient
        self.connectsBroker = connectsBroker
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public var rollbackBoundaryHeld: Bool {
        rollbackPlanID == "gh-536-release-v010-rollback-plan"
            && incidentEvidenceID == "gh-536-release-v010-incident-stop-evidence"
            && operatorEvidenceID == "gh-536-release-v010-operator-review-evidence"
            && auditTrailAnchor == "GH-536-ROLLBACK-OPERATOR-EVIDENCE"
            && recoveryBoundary == Self.requiredRecoveryBoundary
            && rollbackPlanVisible
            && operatorEvidenceRecorded
            && manualReviewRequired
            && noAutomaticRecovery
            && productionTradingDisabledByDefault
            && [
                executesRollback,
                callsExecutionClient,
                connectsBroker,
                submitsRealOrder,
                cancelsRealOrder,
                replacesRealOrder,
                authorizesTradingExecution
            ].allSatisfy { $0 == false }
    }

    public static let requiredRecoveryBoundary: [ReleaseV010KillSwitchControlState] = [
        .rollbackRequired,
        .operatorReviewRequired,
        .productionTradingDisabled
    ]
}

/// ReleaseV010KillSwitchNoTradeRollbackSurfaceReadModel 是 GH-536 Dashboard / Report 输入。
///
/// 它把 #535 controlled command action 映射为 no-trade、kill switch 和 rollback evidence 的只读状态。
/// `GH-536-KILL-SWITCH-NO-TRADE-ROLLBACK-CONTROLS`
public struct ReleaseV010KillSwitchNoTradeRollbackSurfaceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let blockedActions: [ReleaseV010KillSwitchBlockedActionEvidence]
    public let rollbackEvidence: ReleaseV010RollbackOperatorEvidence
    public let validationAnchors: [String]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        blockedActions: [ReleaseV010KillSwitchBlockedActionEvidence] = Self.requiredBlockedActions,
        rollbackEvidence: ReleaseV010RollbackOperatorEvidence = ReleaseV010RollbackOperatorEvidence(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.blockedActions = blockedActions.sorted {
            $0.action.rawValue < $1.action.rawValue
        }
        self.rollbackEvidence = rollbackEvidence
        self.validationAnchors = validationAnchors
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var killSwitchNoTradeRollbackBoundaryHeld: Bool {
        source.isReadModelOnly
            && blockedActions.count == ReleaseV010ControlledCommandAction.allCases.count
            && blockedActions.map(\.action) == ReleaseV010ControlledCommandAction.allCases.sorted {
                $0.rawValue < $1.rawValue
            }
            && blockedActions.allSatisfy(\.actionBoundaryHeld)
            && rollbackEvidence.rollbackBoundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-536-KILL-SWITCH-NO-TRADE-ROLLBACK-CONTROLS",
        "GH-536-GLOBAL-NO-TRADE-MODE",
        "GH-536-SUBMIT-CANCEL-REPLACE-BLOCKED",
        "GH-536-ROLLBACK-OPERATOR-EVIDENCE",
        "GH-536-NO-PRODUCTION-DEFAULT",
        "TVM-RELEASE-V010-KILL-SWITCH-NO-TRADE-ROLLBACK"
    ]

    public static let requiredBlockedActions = ReleaseV010ControlledCommandAction.allCases.map {
        ReleaseV010KillSwitchBlockedActionEvidence(action: $0)
    }
}

/// ReleaseV010KillSwitchNoTradeRollbackSurfaceViewModel 是 GH-536 Dashboard 可展示摘要。
///
/// ViewModel 可以展示哪些 command 被阻断、rollback evidence 是否可审计、production 是否仍默认关闭；
/// 它不能把 kill switch 证据提升为真实 stop command、rollback command、broker action 或 order form。
public struct ReleaseV010KillSwitchNoTradeRollbackSurfaceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let issueID: String
    public let matrixID: String
    public let blockedActionLabels: [String]
    public let stateLabels: [String]
    public let blockingReasons: [String]
    public let rollbackEvidenceIDs: [String]
    public let operatorEvidenceIDs: [String]
    public let sourceAnchors: [String]
    public let validationAnchors: [String]
    public let blockedActionCount: Int
    public let globalNoTradeActive: Bool
    public let killSwitchActive: Bool
    public let submitCancelReplaceBlocked: Bool
    public let rollbackEvidenceAuditable: Bool
    public let operatorEvidenceRequired: Bool
    public let noAutomaticRecovery: Bool
    public let productionTradingDisabledByDefault: Bool
    public let commandSurfaceVisible: Bool
    public let commandSurfaceEnabled: Bool
    public let reportSummary: String
    public let dashboardPanelSummaries: [String]
    public let killSwitchNoTradeRollbackBoundaryHeld: Bool
    public let providesCommandSurface: Bool
    public let providesTradingButton: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesSecretEditor: Bool
    public let readsSecret: Bool
    public let opensProductionEndpoint: Bool
    public let connectsBroker: Bool
    public let callsExecutionClient: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesExecutionEngine: Bool
    public let bypassesOMS: Bool
    public let bypassesKillSwitch: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let triggersAutoRecovery: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: ReleaseV010KillSwitchNoTradeRollbackSurfaceReadModel) {
        let actions = readModel.blockedActions
        let rollbackEvidence = readModel.rollbackEvidence

        self.source = readModel.source
        self.issueID = "GH-536"
        self.matrixID = "TVM-RELEASE-V010-KILL-SWITCH-NO-TRADE-ROLLBACK"
        self.blockedActionLabels = actions.map(\.action.rawValue)
        self.stateLabels = actions.flatMap(\.states).map(\.rawValue).uniquePreservingOrder()
        self.blockingReasons = actions.flatMap(\.blockingReasons)
        self.rollbackEvidenceIDs = ([rollbackEvidence.rollbackPlanID] + actions.map(\.rollbackEvidenceID))
            .uniquePreservingOrder()
        self.operatorEvidenceIDs = ([rollbackEvidence.operatorEvidenceID] + actions.map(\.operatorEvidenceID))
            .uniquePreservingOrder()
        self.sourceAnchors = actions.flatMap(\.sourceAnchors).uniquePreservingOrder()
        self.validationAnchors = readModel.validationAnchors
        self.blockedActionCount = actions.count
        self.globalNoTradeActive = actions.allSatisfy(\.blockedByGlobalNoTrade)
        self.killSwitchActive = actions.allSatisfy(\.blockedByKillSwitch)
        self.submitCancelReplaceBlocked = blockedActionLabels == ["cancel", "replace", "submit"]
            && actions.allSatisfy { action in
                action.commandEntryEnabled == false
                    && action.blockedByGlobalNoTrade
                    && action.blockedByKillSwitch
            }
        self.rollbackEvidenceAuditable = rollbackEvidence.rollbackBoundaryHeld
            && actions.allSatisfy(\.rollbackEvidenceRequired)
        self.operatorEvidenceRequired = rollbackEvidence.operatorEvidenceRecorded
            && actions.allSatisfy(\.operatorEvidenceRequired)
        self.noAutomaticRecovery = rollbackEvidence.noAutomaticRecovery
            && actions.allSatisfy { $0.triggersAutoRecovery == false }
        self.productionTradingDisabledByDefault = rollbackEvidence.productionTradingDisabledByDefault
        self.commandSurfaceVisible = actions.allSatisfy(\.commandEntryVisible)
        self.commandSurfaceEnabled = actions.contains(where: \.commandEntryEnabled)
        self.reportSummary = [
            "Release v0.1.0 kill switch / no-trade / rollback controls",
            "blockedActions=\(actions.count)",
            "globalNoTrade=active",
            "rollback=auditable"
        ].joined(separator: "; ")
        self.dashboardPanelSummaries = actions.map {
            "\($0.action.rawValue): no-trade + kill switch blocked"
        }
        self.killSwitchNoTradeRollbackBoundaryHeld = readModel.killSwitchNoTradeRollbackBoundaryHeld
            && globalNoTradeActive
            && killSwitchActive
            && submitCancelReplaceBlocked
            && rollbackEvidenceAuditable
            && operatorEvidenceRequired
            && noAutomaticRecovery
            && productionTradingDisabledByDefault
        self.providesCommandSurface = commandSurfaceVisible
        self.providesTradingButton = false
        self.providesLiveCommand = false
        self.exposesOrderForm = false
        self.exposesSecretEditor = false
        self.readsSecret = actions.contains(where: \.readsSecret)
        self.opensProductionEndpoint = actions.contains(where: \.opensProductionEndpoint)
        self.connectsBroker = actions.contains(where: \.connectsBroker)
        self.callsExecutionClient = actions.contains(where: \.callsExecutionClient)
        self.bypassesRiskEngine = actions.contains(where: \.bypassesRiskEngine)
        self.bypassesExecutionEngine = actions.contains(where: \.bypassesExecutionEngine)
        self.bypassesOMS = actions.contains(where: \.bypassesOMS)
        self.bypassesKillSwitch = actions.contains(where: \.bypassesKillSwitch)
        self.submitsRealOrder = actions.contains(where: \.submitsRealOrder)
        self.cancelsRealOrder = actions.contains(where: \.cancelsRealOrder)
        self.replacesRealOrder = actions.contains(where: \.replacesRealOrder)
        self.triggersAutoRecovery = actions.contains(where: \.triggersAutoRecovery)
            || rollbackEvidence.noAutomaticRecovery == false
        self.authorizesLiveTrading = actions.contains(where: \.authorizesLiveTrading)
        self.authorizesTradingExecution = actions.contains(where: \.authorizesTradingExecution)
            || rollbackEvidence.authorizesTradingExecution
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element: Hashable {
    func uniquePreservingOrder() -> [Element] {
        var seen = Set<Element>()
        var values: [Element] = []
        for value in self where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}
