import DomainModel
import Foundation

/// ReleaseV0200ProductionShadowRiskReadinessComponent 固定 GH-1247 的可见 readiness 组件。
///
/// 这些组件只表达 Binance Spot production-shadow 的 operator-visible evidence，不代表可执行
/// RiskEngine runtime、kill switch runtime、no-trade runtime 或任何订单命令入口。
public enum ReleaseV0200ProductionShadowRiskReadinessComponent: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case riskEngine = "risk-engine"
    case killSwitch = "kill-switch"
    case noTradeState = "no-trade-state"
}

/// ReleaseV0200ProductionShadowRiskReadinessState 描述 GH-1247 的 fail-closed 状态。
public enum ReleaseV0200ProductionShadowRiskReadinessState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case riskGateVisibleFailClosed = "risk-gate-visible-fail-closed"
    case killSwitchBlockedVisible = "kill-switch-blocked-visible"
    case noTradeBlockedVisible = "no-trade-blocked-visible"
}

/// ReleaseV0200ProductionShadowRiskReadinessFailureClass 固定 #1247 的失败分类。
public enum ReleaseV0200ProductionShadowRiskReadinessFailureClass: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case tradingAuthorizationWithheld = "trading authorization withheld"
    case killSwitchActiveBlocksOrders = "kill switch active blocks orders"
    case noTradeActiveBlocksOrders = "no-trade active blocks orders"
}

/// ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence 表达单个 readiness 组件的本地证据。
///
/// Evidence 只保存 redacted summary、fail-closed state 和 upstream policy references。它不读取 secret，
/// 不连接 endpoint，不创建 order intent，不调用 submit / cancel / replace，也不允许 Dashboard 或 CLI 绕过
/// Risk / kill switch / no-trade gate。
public struct ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let component: ReleaseV0200ProductionShadowRiskReadinessComponent
    public let state: ReleaseV0200ProductionShadowRiskReadinessState
    public let failureClass: ReleaseV0200ProductionShadowRiskReadinessFailureClass
    public let redactedEvidenceSummary: String
    public let accountSnapshotRedactionPolicyHeld: Bool
    public let noOrderCapabilityGuardHeld: Bool
    public let operatorVisible: Bool
    public let failClosed: Bool
    public let tradingAuthorizationGranted: Bool
    public let orderIntentCreated: Bool
    public let submitCancelReplaceEnabled: Bool
    public let riskBypassAllowed: Bool
    public let killSwitchBypassAllowed: Bool
    public let noTradeBypassAllowed: Bool

    public var readinessEvidenceHeld: Bool {
        Self.expectedState(component: component) == state
            && Self.expectedFailureClass(component: component) == failureClass
            && Self.isRedactedEvidenceSummary(
                redactedEvidenceSummary,
                component: component,
                state: state
            )
            && accountSnapshotRedactionPolicyHeld
            && noOrderCapabilityGuardHeld
            && operatorVisible
            && failClosed
            && forbiddenTradingSideEffectsHeld
    }

    public var forbiddenTradingSideEffectsHeld: Bool {
        tradingAuthorizationGranted == false
            && orderIntentCreated == false
            && submitCancelReplaceEnabled == false
            && riskBypassAllowed == false
            && killSwitchBypassAllowed == false
            && noTradeBypassAllowed == false
    }

    public init(
        evidenceID: Identifier? = nil,
        component: ReleaseV0200ProductionShadowRiskReadinessComponent,
        state: ReleaseV0200ProductionShadowRiskReadinessState? = nil,
        failureClass: ReleaseV0200ProductionShadowRiskReadinessFailureClass? = nil,
        redactedEvidenceSummary: String? = nil,
        accountSnapshotRedactionPolicyHeld: Bool = true,
        noOrderCapabilityGuardHeld: Bool = true,
        operatorVisible: Bool = true,
        failClosed: Bool = true,
        tradingAuthorizationGranted: Bool = false,
        orderIntentCreated: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        riskBypassAllowed: Bool = false,
        killSwitchBypassAllowed: Bool = false,
        noTradeBypassAllowed: Bool = false
    ) throws {
        let resolvedState = state ?? Self.expectedState(component: component)
        let resolvedFailure = failureClass ?? Self.expectedFailureClass(component: component)
        let resolvedSummary = redactedEvidenceSummary ?? Self.defaultEvidenceSummary(
            component: component,
            state: resolvedState
        )
        let resolvedID = evidenceID ?? Self.deterministicID(component: component, state: resolvedState)
        try Self.validate(
            component: component,
            state: resolvedState,
            failureClass: resolvedFailure,
            redactedEvidenceSummary: resolvedSummary,
            accountSnapshotRedactionPolicyHeld: accountSnapshotRedactionPolicyHeld,
            noOrderCapabilityGuardHeld: noOrderCapabilityGuardHeld,
            operatorVisible: operatorVisible,
            failClosed: failClosed,
            tradingAuthorizationGranted: tradingAuthorizationGranted,
            orderIntentCreated: orderIntentCreated,
            submitCancelReplaceEnabled: submitCancelReplaceEnabled,
            riskBypassAllowed: riskBypassAllowed,
            killSwitchBypassAllowed: killSwitchBypassAllowed,
            noTradeBypassAllowed: noTradeBypassAllowed
        )
        self.evidenceID = resolvedID
        self.component = component
        self.state = resolvedState
        self.failureClass = resolvedFailure
        self.redactedEvidenceSummary = resolvedSummary
        self.accountSnapshotRedactionPolicyHeld = accountSnapshotRedactionPolicyHeld
        self.noOrderCapabilityGuardHeld = noOrderCapabilityGuardHeld
        self.operatorVisible = operatorVisible
        self.failClosed = failClosed
        self.tradingAuthorizationGranted = tradingAuthorizationGranted
        self.orderIntentCreated = orderIntentCreated
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.riskBypassAllowed = riskBypassAllowed
        self.killSwitchBypassAllowed = killSwitchBypassAllowed
        self.noTradeBypassAllowed = noTradeBypassAllowed
    }

    public static func deterministicFixtures() throws -> [ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence] {
        [
            try ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence(component: .riskEngine),
            try ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence(component: .killSwitch),
            try ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence(component: .noTradeState)
        ]
    }

    public static let summaryPrefix = "risk-readiness=<visible-fail-closed>"
    public static let authorizationMarker = "trading-authorization=<withheld>"
    public static let orderMarker = "orders=<blocked>"
    public static let bypassMarker = "bypass=<blocked>"

    public static func expectedState(
        component: ReleaseV0200ProductionShadowRiskReadinessComponent
    ) -> ReleaseV0200ProductionShadowRiskReadinessState {
        switch component {
        case .riskEngine:
            .riskGateVisibleFailClosed
        case .killSwitch:
            .killSwitchBlockedVisible
        case .noTradeState:
            .noTradeBlockedVisible
        }
    }

    public static func expectedFailureClass(
        component: ReleaseV0200ProductionShadowRiskReadinessComponent
    ) -> ReleaseV0200ProductionShadowRiskReadinessFailureClass {
        switch component {
        case .riskEngine:
            .tradingAuthorizationWithheld
        case .killSwitch:
            .killSwitchActiveBlocksOrders
        case .noTradeState:
            .noTradeActiveBlocksOrders
        }
    }

    public static func defaultEvidenceSummary(
        component: ReleaseV0200ProductionShadowRiskReadinessComponent,
        state: ReleaseV0200ProductionShadowRiskReadinessState
    ) -> String {
        [
            summaryPrefix,
            "component=\(component.rawValue)",
            "state=\(state.rawValue)",
            authorizationMarker,
            orderMarker,
            bypassMarker
        ].joined(separator: "; ")
    }

    public static func deterministicID(
        component: ReleaseV0200ProductionShadowRiskReadinessComponent,
        state: ReleaseV0200ProductionShadowRiskReadinessState
    ) -> Identifier {
        .constant(
            [
                "gh-1247-v0200-risk-kill-switch-no-trade",
                component.rawValue,
                state.rawValue
            ].joined(separator: ":"),
            field: "releaseV0200.riskKillSwitchNoTrade.evidenceID"
        )
    }
}

private extension ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence {
    static func validate(
        component: ReleaseV0200ProductionShadowRiskReadinessComponent,
        state: ReleaseV0200ProductionShadowRiskReadinessState,
        failureClass: ReleaseV0200ProductionShadowRiskReadinessFailureClass,
        redactedEvidenceSummary: String,
        accountSnapshotRedactionPolicyHeld: Bool,
        noOrderCapabilityGuardHeld: Bool,
        operatorVisible: Bool,
        failClosed: Bool,
        tradingAuthorizationGranted: Bool,
        orderIntentCreated: Bool,
        submitCancelReplaceEnabled: Bool,
        riskBypassAllowed: Bool,
        killSwitchBypassAllowed: Bool,
        noTradeBypassAllowed: Bool
    ) throws {
        guard accountSnapshotRedactionPolicyHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.riskKillSwitchNoTrade.accountSnapshotRedactionPolicyHeld",
                expected: "GH-1245 account snapshot redaction policy held",
                actual: "false"
            )
        }
        guard noOrderCapabilityGuardHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.riskKillSwitchNoTrade.noOrderCapabilityGuardHeld",
                expected: "GH-1246 no-order capability guard held",
                actual: "false"
            )
        }
        guard operatorVisible else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.riskKillSwitchNoTrade.operatorVisible",
                expected: "operator-visible blocked state",
                actual: "false"
            )
        }
        guard failClosed else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.riskKillSwitchNoTrade.failClosed",
                expected: "fail-closed readiness evidence",
                actual: "false"
            )
        }
        guard state == expectedState(component: component),
              failureClass == expectedFailureClass(component: component),
              isRedactedEvidenceSummary(redactedEvidenceSummary, component: component, state: state) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.riskKillSwitchNoTrade.componentEvidence",
                expected: "\(expectedState(component: component).rawValue) / \(expectedFailureClass(component: component).rawValue)",
                actual: "\(state.rawValue) / \(failureClass.rawValue)"
            )
        }
        for (field, value) in [
            ("tradingAuthorizationGranted", tradingAuthorizationGranted),
            ("orderIntentCreated", orderIntentCreated),
            ("submitCancelReplaceEnabled", submitCancelReplaceEnabled),
            ("riskBypassAllowed", riskBypassAllowed),
            ("killSwitchBypassAllowed", killSwitchBypassAllowed),
            ("noTradeBypassAllowed", noTradeBypassAllowed)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.riskKillSwitchNoTrade.\(field)"
            )
        }
    }

    static func isRedactedEvidenceSummary(
        _ summary: String,
        component: ReleaseV0200ProductionShadowRiskReadinessComponent,
        state: ReleaseV0200ProductionShadowRiskReadinessState
    ) -> Bool {
        summary.contains(summaryPrefix)
            && summary.contains("component=\(component.rawValue)")
            && summary.contains("state=\(state.rawValue)")
            && summary.contains(authorizationMarker)
            && summary.contains(orderMarker)
            && summary.contains(bypassMarker)
            && summary.localizedCaseInsensitiveContains("account id") == false
            && summary.localizedCaseInsensitiveContains("balance=") == false
            && summary.localizedCaseInsensitiveContains("symbol=") == false
            && summary.localizedCaseInsensitiveContains("quantity=") == false
            && summary.localizedCaseInsensitiveContains("orderid") == false
            && summary.localizedCaseInsensitiveContains("api key") == false
            && summary.localizedCaseInsensitiveContains("secret") == false
            && summary.localizedCaseInsensitiveContains("signature=") == false
            && summary.localizedCaseInsensitiveContains("endpoint=") == false
            && summary.localizedCaseInsensitiveContains("/api/v3/order") == false
    }
}

/// ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness 是 GH-1247 的风险阻断证据合同。
///
/// 它继承 #1245 的 redacted account snapshot policy 和 #1246 的 no-order guard，只证明
/// RiskEngine readiness、kill switch active、no-trade active 能被 operator 看到且继续 fail closed。
/// 它不授权交易，不打开 Dashboard command，不创建 live command，也不创建 tag / GitHub Release。
public struct ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness: Codable, Equatable, Sendable {
    public let readinessID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let accountSnapshotRedactionPolicy: ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy
    public let noOrderCapabilityGuard: ReleaseV0200ProductionShadowNoOrderCapabilityGuard
    public let componentEvidence: [ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretValueRead: Bool
    public let productionEndpointConnected: Bool
    public let signedOrderMaterialGenerated: Bool
    public let orderEndpointTouched: Bool
    public let endpointConnectionOpened: Bool
    public let tradingAuthorizationGranted: Bool
    public let orderIntentCreated: Bool
    public let submitCancelReplaceEnabled: Bool
    public let riskBypassAllowed: Bool
    public let killSwitchBypassAllowed: Bool
    public let noTradeBypassAllowed: Bool
    public let dashboardTradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let spotCanaryEnabled: Bool
    public let futuresRuntimeEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let createsTagOrRelease: Bool

    public var readinessHeld: Bool {
        issueID.rawValue == "GH-1247"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-1245", "GH-1246"]
            && downstreamIssueID.rawValue == "GH-1248"
            && canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange
            && projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName
            && releaseVersion == "v0.20.0"
            && accountSnapshotRedactionPolicy.policyHeld
            && noOrderCapabilityGuard.guardHeld
            && componentEvidenceHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
    }

    public var componentEvidenceHeld: Bool {
        componentEvidence.count == ReleaseV0200ProductionShadowRiskReadinessComponent.allCases.count
            && Set(componentEvidence.map(\.component)) == Set(ReleaseV0200ProductionShadowRiskReadinessComponent.allCases)
            && Set(componentEvidence.map(\.state)) == Set(ReleaseV0200ProductionShadowRiskReadinessState.allCases)
            && componentEvidence.allSatisfy(\.readinessEvidenceHeld)
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretValueRead == false
            && productionEndpointConnected == false
            && signedOrderMaterialGenerated == false
            && orderEndpointTouched == false
            && endpointConnectionOpened == false
            && tradingAuthorizationGranted == false
            && orderIntentCreated == false
            && submitCancelReplaceEnabled == false
            && riskBypassAllowed == false
            && killSwitchBypassAllowed == false
            && noTradeBypassAllowed == false
            && dashboardTradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && spotCanaryEnabled == false
            && futuresRuntimeEnabled == false
            && okxActiveImplementationEnabled == false
            && productionCutoverAuthorized == false
            && createsTagOrRelease == false
    }

    public init(
        readinessID: Identifier = Identifier.constant("gh-1247-release-v0.20.0-risk-kill-switch-no-trade-readiness"),
        issueID: Identifier = Identifier.constant("GH-1247"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1245"), Identifier.constant("GH-1246")],
        downstreamIssueID: Identifier = Identifier.constant("GH-1248"),
        canonicalQueueRange: String = ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
        projectName: String = ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
        releaseVersion: String = "v0.20.0",
        accountSnapshotRedactionPolicy: ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy? = nil,
        noOrderCapabilityGuard: ReleaseV0200ProductionShadowNoOrderCapabilityGuard? = nil,
        componentEvidence: [ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence]? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretValueRead: Bool = false,
        productionEndpointConnected: Bool = false,
        signedOrderMaterialGenerated: Bool = false,
        orderEndpointTouched: Bool = false,
        endpointConnectionOpened: Bool = false,
        tradingAuthorizationGranted: Bool = false,
        orderIntentCreated: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        riskBypassAllowed: Bool = false,
        killSwitchBypassAllowed: Bool = false,
        noTradeBypassAllowed: Bool = false,
        dashboardTradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        spotCanaryEnabled: Bool = false,
        futuresRuntimeEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        createsTagOrRelease: Bool = false
    ) throws {
        let resolvedSnapshotPolicy = try accountSnapshotRedactionPolicy
            ?? ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy.deterministicFixture()
        let resolvedNoOrderGuard = try noOrderCapabilityGuard
            ?? ReleaseV0200ProductionShadowNoOrderCapabilityGuard.deterministicFixture()
        let resolvedComponentEvidence = try componentEvidence
            ?? ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence.deterministicFixtures()
        try Self.validateRequired(
            issueID: issueID,
            upstreamIssueIDs: upstreamIssueIDs,
            downstreamIssueID: downstreamIssueID,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            accountSnapshotRedactionPolicy: resolvedSnapshotPolicy,
            noOrderCapabilityGuard: resolvedNoOrderGuard,
            componentEvidence: resolvedComponentEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretValueRead: productionSecretValueRead,
            productionEndpointConnected: productionEndpointConnected,
            signedOrderMaterialGenerated: signedOrderMaterialGenerated,
            orderEndpointTouched: orderEndpointTouched,
            endpointConnectionOpened: endpointConnectionOpened,
            tradingAuthorizationGranted: tradingAuthorizationGranted,
            orderIntentCreated: orderIntentCreated,
            submitCancelReplaceEnabled: submitCancelReplaceEnabled,
            riskBypassAllowed: riskBypassAllowed,
            killSwitchBypassAllowed: killSwitchBypassAllowed,
            noTradeBypassAllowed: noTradeBypassAllowed,
            dashboardTradingButtonEnabled: dashboardTradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            spotCanaryEnabled: spotCanaryEnabled,
            futuresRuntimeEnabled: futuresRuntimeEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            createsTagOrRelease: createsTagOrRelease
        )
        self.readinessID = readinessID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.accountSnapshotRedactionPolicy = resolvedSnapshotPolicy
        self.noOrderCapabilityGuard = resolvedNoOrderGuard
        self.componentEvidence = resolvedComponentEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretValueRead = productionSecretValueRead
        self.productionEndpointConnected = productionEndpointConnected
        self.signedOrderMaterialGenerated = signedOrderMaterialGenerated
        self.orderEndpointTouched = orderEndpointTouched
        self.endpointConnectionOpened = endpointConnectionOpened
        self.tradingAuthorizationGranted = tradingAuthorizationGranted
        self.orderIntentCreated = orderIntentCreated
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.riskBypassAllowed = riskBypassAllowed
        self.killSwitchBypassAllowed = killSwitchBypassAllowed
        self.noTradeBypassAllowed = noTradeBypassAllowed
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.spotCanaryEnabled = spotCanaryEnabled
        self.futuresRuntimeEnabled = futuresRuntimeEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.createsTagOrRelease = createsTagOrRelease
    }

    public static let requiredValidationAnchors = [
        "GH-1247-VERIFY-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS",
        "TVM-RELEASE-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS",
        "V0200-009-BINANCE-SPOT-PRODUCTION-SHADOW-RISK-READINESS",
        "V0200-009-RISK-GATE-VISIBLE-FAIL-CLOSED",
        "V0200-009-KILL-SWITCH-BLOCKED-VISIBLE",
        "V0200-009-NO-TRADE-BLOCKED-VISIBLE",
        "V0200-009-NO-TRADING-AUTHORIZATION",
        "V0200-009-NO-ORDER-CAPABILITY-BYPASS",
        "V0200-009-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1247ReleaseV0200RiskKillSwitchNoTradeReadiness",
        "bash checks/verify-v0.20.0-risk-kill-switch-no-trade-readiness.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicFixture() throws -> ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness {
        try ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness()
    }
}

private extension ReleaseV0200ProductionShadowRiskKillSwitchNoTradeReadiness {
    static func validateRequired(
        issueID: Identifier,
        upstreamIssueIDs: [Identifier],
        downstreamIssueID: Identifier,
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        accountSnapshotRedactionPolicy: ReleaseV0200ProductionShadowAccountSnapshotRedactionPolicy,
        noOrderCapabilityGuard: ReleaseV0200ProductionShadowNoOrderCapabilityGuard,
        componentEvidence: [ReleaseV0200ProductionShadowRiskKillSwitchNoTradeEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        guard issueID.rawValue == "GH-1247" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.riskKillSwitchNoTrade.issueID",
                expected: "GH-1247",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-1245", "GH-1246"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.riskKillSwitchNoTrade.upstreamIssueIDs",
                expected: "GH-1245,GH-1246",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard downstreamIssueID.rawValue == "GH-1248",
              canonicalQueueRange == ReleaseV0200ProductionShadowEnvironmentProfile.requiredCanonicalQueueRange,
              projectName == ReleaseV0200ProductionShadowReadOnlyLiveReadinessContract.requiredProjectName,
              releaseVersion == "v0.20.0",
              accountSnapshotRedactionPolicy.policyHeld,
              noOrderCapabilityGuard.guardHeld,
              validationAnchors == requiredValidationAnchors,
              requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.riskKillSwitchNoTrade.requiredContract",
                expected: "v0.20.0 risk / kill switch / no-trade readiness contract",
                actual: issueID.rawValue
            )
        }
        guard componentEvidence.count == ReleaseV0200ProductionShadowRiskReadinessComponent.allCases.count,
              Set(componentEvidence.map(\.component)) == Set(ReleaseV0200ProductionShadowRiskReadinessComponent.allCases),
              Set(componentEvidence.map(\.state)) == Set(ReleaseV0200ProductionShadowRiskReadinessState.allCases),
              componentEvidence.allSatisfy(\.readinessEvidenceHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0200.riskKillSwitchNoTrade.componentEvidence",
                expected: "risk / kill switch / no-trade visible fail-closed evidence",
                actual: "\(componentEvidence.count)"
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretValueRead: Bool,
        productionEndpointConnected: Bool,
        signedOrderMaterialGenerated: Bool,
        orderEndpointTouched: Bool,
        endpointConnectionOpened: Bool,
        tradingAuthorizationGranted: Bool,
        orderIntentCreated: Bool,
        submitCancelReplaceEnabled: Bool,
        riskBypassAllowed: Bool,
        killSwitchBypassAllowed: Bool,
        noTradeBypassAllowed: Bool,
        dashboardTradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        spotCanaryEnabled: Bool,
        futuresRuntimeEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        productionCutoverAuthorized: Bool,
        createsTagOrRelease: Bool
    ) throws {
        for (field, value) in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionEndpointConnected", productionEndpointConnected),
            ("signedOrderMaterialGenerated", signedOrderMaterialGenerated),
            ("orderEndpointTouched", orderEndpointTouched),
            ("endpointConnectionOpened", endpointConnectionOpened),
            ("tradingAuthorizationGranted", tradingAuthorizationGranted),
            ("orderIntentCreated", orderIntentCreated),
            ("submitCancelReplaceEnabled", submitCancelReplaceEnabled),
            ("riskBypassAllowed", riskBypassAllowed),
            ("killSwitchBypassAllowed", killSwitchBypassAllowed),
            ("noTradeBypassAllowed", noTradeBypassAllowed),
            ("dashboardTradingButtonEnabled", dashboardTradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("spotCanaryEnabled", spotCanaryEnabled),
            ("futuresRuntimeEnabled", futuresRuntimeEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("createsTagOrRelease", createsTagOrRelease)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0200.riskKillSwitchNoTrade.\(field)"
            )
        }
    }
}
