import Foundation

/// ReleaseV0100DashboardProductionReadinessCenterPanel 固定 GH-890 可展示的生产就绪中心卡片。
///
/// 这些卡片只把 v0.10.0 已完成的 readiness evidence 汇总到 Dashboard。它们不是
/// trading button、order form、live command、broker command、endpoint connection 或 production cutover。
public enum ReleaseV0100DashboardProductionReadinessCenterPanel:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case readinessOverview = "readiness-overview"
    case environmentProfile = "environment-profile"
    case secretReadiness = "secret-readiness"
    case endpointPolicy = "endpoint-policy"
    case riskCapitalLimits = "risk-capital-limits"
    case killSwitchNoTrade = "kill-switch-no-trade"
    case commandSurfaceDisabled = "command-surface-disabled"
    case shadowDryRunParity = "shadow-dry-run-parity"
    case approvalWorkflow = "approval-workflow"
    case readinessBundle = "readiness-bundle"
}

/// ReleaseV0110DashboardReadinessArtifactState 是 Dashboard 对 v0.11 本地 readiness artifact 的只读展示状态。
///
/// 状态只来自本地 manifest / bundle validation 结果；即使状态为 `valid`，也只代表本地 evidence
/// integrity 通过，不代表 production cutover、endpoint connection、secret read 或真实订单授权。
public enum ReleaseV0110DashboardReadinessArtifactState:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case notEvaluated = "not-evaluated"
    case valid
    case blocked
    case stale
    case missing
    case invalid
    case checksumMismatch = "checksum-mismatch"

    public var dashboardStatusLabel: String {
        "readiness-\(rawValue)"
    }
}

/// ReleaseV0110DashboardProductionReadinessCenterArtifactStateAnchors 固定 GH-919 的验证锚点。
///
/// GH-919 只把本地 manifest / bundle validation JSON 映射到 Dashboard read model；
/// 不新增 trading button、order form、live command、endpoint connection 或 production cutover。
public enum ReleaseV0110DashboardProductionReadinessCenterArtifactStateAnchors {
    public static let validationAnchors = [
        "GH-919-VERIFY-V0110-DASHBOARD-REAL-ARTIFACT-STATE",
        "TVM-RELEASE-V0110-DASHBOARD-REAL-ARTIFACT-STATE",
        "V0110-007-DASHBOARD-REAL-ARTIFACT-STATE",
        "V0110-007-LOCAL-MANIFEST-BUNDLE-STATE",
        "V0110-007-MISSING-CORRUPT-STALE-CHECKSUM-MISMATCH",
        "V0110-007-NO-STATIC-EVIDENCE-EXISTS",
        "V0110-007-READ-ONLY-NO-PRODUCTION-CUTOVER"
    ]
}

/// ReleaseV0110DashboardReadinessArtifactStateInput 是 Dashboard 可消费的本地 artifact 状态行。
///
/// 该类型故意保留在 Dashboard target 内，避免 Dashboard 直接依赖 ExecutionClient / FutureGate。
/// 调用方可以从 v0.11 manifest JSON 或 bundle validation JSON 解码出这些只读字段，再映射到卡片。
public struct ReleaseV0110DashboardReadinessArtifactStateInput:
    Codable,
    Equatable,
    Sendable
{
    public let artifactID: String
    public let relativePath: String
    public let state: ReleaseV0110DashboardReadinessArtifactState
    public let evidenceExists: Bool
    public let checksumReference: String
    public let checksumMatches: Bool
    public let stateReason: String

    public var fileName: String {
        relativePath.split(separator: "/").last.map(String.init) ?? relativePath
    }

    public var inputHeld: Bool {
        artifactID.isEmpty == false
            && Self.isSafeRelativePath(relativePath)
            && stateReason.isEmpty == false
            && checksumReference.hasPrefix("sha256:")
            && stateEvidenceHeld
    }

    public init(
        artifactID: String,
        relativePath: String,
        state: ReleaseV0110DashboardReadinessArtifactState,
        evidenceExists: Bool,
        checksumReference: String,
        checksumMatches: Bool,
        stateReason: String
    ) {
        self.artifactID = artifactID
        self.relativePath = relativePath
        self.state = state
        self.evidenceExists = evidenceExists
        self.checksumReference = checksumReference
        self.checksumMatches = checksumMatches
        self.stateReason = stateReason
    }

    private var stateEvidenceHeld: Bool {
        switch state {
        case .valid:
            evidenceExists && checksumMatches
        case .checksumMismatch:
            evidenceExists && checksumMatches == false
        case .missing, .notEvaluated:
            evidenceExists == false && checksumMatches == false
        case .blocked, .stale, .invalid:
            true
        }
    }

    private static func isSafeRelativePath(_ path: String) -> Bool {
        path.isEmpty == false
            && path.hasPrefix("/") == false
            && path.contains("..") == false
    }
}

/// ReleaseV0110DashboardReadinessBundleStateInput 是 Dashboard 对 bundle validation 的只读摘要。
///
/// 它只记录本地 validation state、required / manifest artifact set 和生产能力禁用证据。
public struct ReleaseV0110DashboardReadinessBundleStateInput:
    Codable,
    Equatable,
    Sendable
{
    public let state: ReleaseV0110DashboardReadinessArtifactState
    public let policyVersion: String
    public let stateReason: String
    public let requiredArtifactIDs: [String]
    public let manifestArtifactIDs: [String]
    public let missingRequiredArtifactIDs: [String]
    public let unexpectedArtifactIDs: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var inputHeld: Bool {
        policyVersion.isEmpty == false
            && stateReason.isEmpty == false
            && requiredArtifactIDs.isEmpty == false
            && requiredArtifactIDs.allSatisfy { $0.isEmpty == false }
            && manifestArtifactIDs.allSatisfy { $0.isEmpty == false }
            && missingRequiredArtifactIDs.allSatisfy { $0.isEmpty == false }
            && unexpectedArtifactIDs.allSatisfy { $0.isEmpty == false }
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        state: ReleaseV0110DashboardReadinessArtifactState,
        policyVersion: String,
        stateReason: String,
        requiredArtifactIDs: [String],
        manifestArtifactIDs: [String] = [],
        missingRequiredArtifactIDs: [String] = [],
        unexpectedArtifactIDs: [String] = [],
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.state = state
        self.policyVersion = policyVersion
        self.stateReason = stateReason
        self.requiredArtifactIDs = requiredArtifactIDs
        self.manifestArtifactIDs = manifestArtifactIDs
        self.missingRequiredArtifactIDs = missingRequiredArtifactIDs
        self.unexpectedArtifactIDs = unexpectedArtifactIDs
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV0100DashboardProductionReadinessCenterCard 是单个 Dashboard readiness 卡片。
///
/// Card 只保存 source issue、artifact 名称、redacted checksum reference 和展示状态。
/// 它不保存 secret value、raw listenKey、raw private payload、endpoint URL、broker response
/// 或订单 payload，因此可以安全进入 Dashboard smoke 和 AppTests 的 deterministic fixture。
public struct ReleaseV0100DashboardProductionReadinessCenterCard:
    Codable,
    Equatable,
    Sendable
{
    public let panel: ReleaseV0100DashboardProductionReadinessCenterPanel
    public let sourceIssueID: String
    public let title: String
    public let statusLabel: String
    public let evidenceArtifact: String
    public let checksumReference: String
    public let artifactValidationState: ReleaseV0110DashboardReadinessArtifactState
    public let artifactStateReason: String
    public let artifactEvidenceExists: Bool
    public let artifactChecksumMatches: Bool
    public let localArtifactStateBound: Bool
    public let dashboardVisible: Bool
    public let readModelOnly: Bool
    public let redactionHeld: Bool
    public let dependencyEvidenceSatisfied: Bool
    public let productionCutoverAuthorized: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let submitCancelReplaceVisible: Bool
    public let brokerCommandCreated: Bool
    public let testnetOrderSubmissionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool

    public var cardHeld: Bool {
        Self.requiredPanels.contains(panel)
            && Self.requiredIssueIDs.contains(sourceIssueID)
            && title.isEmpty == false
            && statusLabel == artifactValidationState.dashboardStatusLabel
            && Self.allowedArtifactNames.contains(evidenceArtifact)
            && checksumReference.hasPrefix("sha256:")
            && artifactStateReason.isEmpty == false
            && localArtifactStateBound
            && artifactEvidenceStateHeld
            && dashboardVisible
            && readModelOnly
            && redactionHeld
            && dependencyEvidenceSatisfied
            && productionCutoverAuthorized == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && submitCancelReplaceVisible == false
            && brokerCommandCreated == false
            && testnetOrderSubmissionEnabled == false
            && productionOrderSubmissionEnabled == false
    }

    public init(
        panel: ReleaseV0100DashboardProductionReadinessCenterPanel,
        sourceIssueID: String,
        title: String,
        evidenceArtifact: String,
        checksumReference: String,
        artifactValidationState: ReleaseV0110DashboardReadinessArtifactState = .notEvaluated,
        artifactStateReason: String = "local readiness artifact state not evaluated",
        artifactEvidenceExists: Bool = false,
        artifactChecksumMatches: Bool = false,
        localArtifactStateBound: Bool = true,
        statusLabel: String? = nil,
        dashboardVisible: Bool = true,
        readModelOnly: Bool = true,
        redactionHeld: Bool = true,
        dependencyEvidenceSatisfied: Bool = true,
        productionCutoverAuthorized: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        submitCancelReplaceVisible: Bool = false,
        brokerCommandCreated: Bool = false,
        testnetOrderSubmissionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false
    ) {
        self.panel = panel
        self.sourceIssueID = sourceIssueID
        self.title = title
        self.statusLabel = statusLabel ?? artifactValidationState.dashboardStatusLabel
        self.evidenceArtifact = evidenceArtifact
        self.checksumReference = checksumReference
        self.artifactValidationState = artifactValidationState
        self.artifactStateReason = artifactStateReason
        self.artifactEvidenceExists = artifactEvidenceExists
        self.artifactChecksumMatches = artifactChecksumMatches
        self.localArtifactStateBound = localArtifactStateBound
        self.dashboardVisible = dashboardVisible
        self.readModelOnly = readModelOnly
        self.redactionHeld = redactionHeld
        self.dependencyEvidenceSatisfied = dependencyEvidenceSatisfied
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.submitCancelReplaceVisible = submitCancelReplaceVisible
        self.brokerCommandCreated = brokerCommandCreated
        self.testnetOrderSubmissionEnabled = testnetOrderSubmissionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
    }

    public func applying(
        localArtifactState state: ReleaseV0110DashboardReadinessArtifactStateInput
    ) -> ReleaseV0100DashboardProductionReadinessCenterCard {
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: panel,
            sourceIssueID: sourceIssueID,
            title: title,
            evidenceArtifact: evidenceArtifact,
            checksumReference: state.checksumReference,
            artifactValidationState: state.state,
            artifactStateReason: state.stateReason,
            artifactEvidenceExists: state.evidenceExists,
            artifactChecksumMatches: state.checksumMatches,
            localArtifactStateBound: state.inputHeld,
            dashboardVisible: dashboardVisible,
            readModelOnly: readModelOnly,
            redactionHeld: redactionHeld,
            dependencyEvidenceSatisfied: dependencyEvidenceSatisfied,
            productionCutoverAuthorized: productionCutoverAuthorized,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretRead: productionSecretRead,
            productionEndpointConnected: productionEndpointConnected,
            brokerEndpointConnected: brokerEndpointConnected,
            tradingButtonVisible: tradingButtonVisible,
            orderFormVisible: orderFormVisible,
            liveCommandVisible: liveCommandVisible,
            submitCancelReplaceVisible: submitCancelReplaceVisible,
            brokerCommandCreated: brokerCommandCreated,
            testnetOrderSubmissionEnabled: testnetOrderSubmissionEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled
        )
    }

    private var artifactEvidenceStateHeld: Bool {
        switch artifactValidationState {
        case .valid:
            artifactEvidenceExists && artifactChecksumMatches
        case .checksumMismatch:
            artifactEvidenceExists && artifactChecksumMatches == false
        case .missing, .notEvaluated:
            artifactEvidenceExists == false && artifactChecksumMatches == false
        case .blocked, .stale, .invalid:
            true
        }
    }

    public static let requiredPanels = ReleaseV0100DashboardProductionReadinessCenterPanel.allCases

    public static let requiredIssueIDs = [
        "GH-878",
        "GH-880",
        "GH-881",
        "GH-882",
        "GH-883",
        "GH-884",
        "GH-885",
        "GH-886",
        "GH-888",
        "GH-887"
    ]

    public static let allowedArtifactNames = [
        "production-readiness-overview.json",
        "production-environment-profile.json",
        "secret-readiness.json",
        "endpoint-policy-readiness.json",
        "capital-exposure-limits.json",
        "kill-switch-no-trade-readiness.json",
        "dashboard-production-surface-disabled.json",
        "shadow-dry-run-parity.json",
        "cutover-approval-workflow.json",
        "production-readiness-bundle.json"
    ]
}

/// ReleaseV0100DashboardProductionReadinessCenterViewModel 是 GH-890 Dashboard 生产就绪中心。
///
/// ViewModel 只展示 Environment / Secret / Endpoint / Risk / Kill Switch / Command Surface /
/// Shadow Dry-run / Approval / Bundle evidence 的状态。所有 forbidden capability 默认 false，
/// Dashboard 只能作为 read-model-only center，不能变成 Live PRO Console 或交易控制面。
public struct ReleaseV0100DashboardProductionReadinessCenterViewModel:
    Codable,
    Equatable,
    Sendable
{
    public let issueID: String
    public let upstreamIssueIDs: [String]
    public let previousIssueID: String
    public let downstreamIssueID: String
    public let releaseVersion: String
    public let source: ViewModelSourceContract
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let readinessCards: [ReleaseV0100DashboardProductionReadinessCenterCard]
    public let localArtifactStateSource: String
    public let bundleValidationState: ReleaseV0110DashboardReadinessArtifactState
    public let bundleValidationReason: String
    public let localArtifactStateBound: Bool
    public let readinessOverviewVisible: Bool
    public let environmentProfileVisible: Bool
    public let secretReadinessVisible: Bool
    public let endpointPolicyVisible: Bool
    public let riskCapitalLimitsVisible: Bool
    public let killSwitchNoTradeVisible: Bool
    public let commandSurfaceDisabledVisible: Bool
    public let shadowDryRunParityVisible: Bool
    public let approvalWorkflowVisible: Bool
    public let readinessBundleVisible: Bool
    public let incidentRollbackEvidenceReferenced: Bool
    public let dashboardSmokeRequired: Bool
    public let readModelOnly: Bool
    public let dashboardDependsOnDataClientTarget: Bool
    public let dashboardDependsOnDatabaseRuntime: Bool
    public let credentialValueVisible: Bool
    public let rawListenKeyVisible: Bool
    public let rawPrivatePayloadVisible: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let productionCommandEnabled: Bool
    public let submitCancelReplaceVisible: Bool
    public let testnetOrderSubmissionEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let readinessApprovalConvertedToTradingPermission: Bool
    public let boundaryHeld: Bool

    public var panelNames: [String] {
        readinessCards.map { $0.panel.rawValue }
    }

    public var evidenceArtifactNames: [String] {
        readinessCards.map(\.evidenceArtifact)
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.10 readiness center cards", value: "\(readinessCards.count)"),
            DashboardShellMetric(label: "Readiness center panels", value: panelNames.joined(separator: ",")),
            DashboardShellMetric(label: "Readiness evidence", value: localArtifactStateSource),
            DashboardShellMetric(label: "Readiness artifact states", value: artifactStateSummary),
            DashboardShellMetric(label: "Readiness bundle state", value: bundleValidationState.rawValue),
            DashboardShellMetric(label: "Production command", value: productionCommandEnabled ? "enabled" : "disabled"),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Readiness panels: \(panelNames.joined(separator: ", "))",
            "Source issues: \(readinessCards.map(\.sourceIssueID).joined(separator: ", "))",
            "Evidence artifacts: \(evidenceArtifactNames.joined(separator: ", "))",
            "Local artifact states: \(artifactStateSummary)",
            "Bundle validation state: \(bundleValidationState.rawValue)",
            "Bundle validation reason: \(bundleValidationReason)",
            "Incident rollback evidence: incident_rollback_readiness.json",
            "Dashboard smoke: required",
            "Credential values: none",
            "Raw listenKey: none",
            "Raw private payload: none",
            "Endpoint connection: none",
            "Broker connection: none",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Submit / cancel / replace: none",
            "Production command: none",
            "Production cutover: none",
            "Dashboard v0.10 production readiness center boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        issueID: String = "GH-890",
        upstreamIssueIDs: [String] = ["GH-887", "GH-888", "GH-889"],
        previousIssueID: String = "GH-889",
        downstreamIssueID: String = "GH-891",
        releaseVersion: String = "v0.10.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        readinessCards: [ReleaseV0100DashboardProductionReadinessCenterCard] = Self.defaultReadinessCards,
        localArtifactStateSource: String = "local-artifact-state-not-evaluated",
        bundleValidationState: ReleaseV0110DashboardReadinessArtifactState = .notEvaluated,
        bundleValidationReason: String = "bundle validation not evaluated",
        localArtifactStateBound: Bool = true,
        readinessOverviewVisible: Bool = true,
        environmentProfileVisible: Bool = true,
        secretReadinessVisible: Bool = true,
        endpointPolicyVisible: Bool = true,
        riskCapitalLimitsVisible: Bool = true,
        killSwitchNoTradeVisible: Bool = true,
        commandSurfaceDisabledVisible: Bool = true,
        shadowDryRunParityVisible: Bool = true,
        approvalWorkflowVisible: Bool = true,
        readinessBundleVisible: Bool = true,
        incidentRollbackEvidenceReferenced: Bool = true,
        dashboardSmokeRequired: Bool = true,
        readModelOnly: Bool = true,
        dashboardDependsOnDataClientTarget: Bool = false,
        dashboardDependsOnDatabaseRuntime: Bool = false,
        credentialValueVisible: Bool = false,
        rawListenKeyVisible: Bool = false,
        rawPrivatePayloadVisible: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        productionCommandEnabled: Bool = false,
        submitCancelReplaceVisible: Bool = false,
        testnetOrderSubmissionEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        readinessApprovalConvertedToTradingPermission: Bool = false
    ) {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.releaseVersion = releaseVersion
        self.source = source
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.readinessCards = readinessCards
        self.localArtifactStateSource = localArtifactStateSource
        self.bundleValidationState = bundleValidationState
        self.bundleValidationReason = bundleValidationReason
        self.localArtifactStateBound = localArtifactStateBound
        self.readinessOverviewVisible = readinessOverviewVisible
        self.environmentProfileVisible = environmentProfileVisible
        self.secretReadinessVisible = secretReadinessVisible
        self.endpointPolicyVisible = endpointPolicyVisible
        self.riskCapitalLimitsVisible = riskCapitalLimitsVisible
        self.killSwitchNoTradeVisible = killSwitchNoTradeVisible
        self.commandSurfaceDisabledVisible = commandSurfaceDisabledVisible
        self.shadowDryRunParityVisible = shadowDryRunParityVisible
        self.approvalWorkflowVisible = approvalWorkflowVisible
        self.readinessBundleVisible = readinessBundleVisible
        self.incidentRollbackEvidenceReferenced = incidentRollbackEvidenceReferenced
        self.dashboardSmokeRequired = dashboardSmokeRequired
        self.readModelOnly = readModelOnly
        self.dashboardDependsOnDataClientTarget = dashboardDependsOnDataClientTarget
        self.dashboardDependsOnDatabaseRuntime = dashboardDependsOnDatabaseRuntime
        self.credentialValueVisible = credentialValueVisible
        self.rawListenKeyVisible = rawListenKeyVisible
        self.rawPrivatePayloadVisible = rawPrivatePayloadVisible
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.productionCommandEnabled = productionCommandEnabled
        self.submitCancelReplaceVisible = submitCancelReplaceVisible
        self.testnetOrderSubmissionEnabled = testnetOrderSubmissionEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.readinessApprovalConvertedToTradingPermission =
            readinessApprovalConvertedToTradingPermission
        self.boundaryHeld = issueID == "GH-890"
            && upstreamIssueIDs == ["GH-887", "GH-888", "GH-889"]
            && previousIssueID == "GH-889"
            && downstreamIssueID == "GH-891"
            && releaseVersion == "v0.10.0"
            && source.isReadModelOnly
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && readinessCards.map(\.panel) == ReleaseV0100DashboardProductionReadinessCenterPanel.allCases
            && readinessCards.allSatisfy(\.cardHeld)
            && localArtifactStateSource.isEmpty == false
            && bundleValidationReason.isEmpty == false
            && localArtifactStateBound
            && readinessOverviewVisible
            && environmentProfileVisible
            && secretReadinessVisible
            && endpointPolicyVisible
            && riskCapitalLimitsVisible
            && killSwitchNoTradeVisible
            && commandSurfaceDisabledVisible
            && shadowDryRunParityVisible
            && approvalWorkflowVisible
            && readinessBundleVisible
            && incidentRollbackEvidenceReferenced
            && dashboardSmokeRequired
            && readModelOnly
            && dashboardDependsOnDataClientTarget == false
            && dashboardDependsOnDatabaseRuntime == false
            && credentialValueVisible == false
            && rawListenKeyVisible == false
            && rawPrivatePayloadVisible == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && productionCommandEnabled == false
            && submitCancelReplaceVisible == false
            && testnetOrderSubmissionEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && readinessApprovalConvertedToTradingPermission == false
    }

    public static var deterministicFixture: ReleaseV0100DashboardProductionReadinessCenterViewModel {
        ReleaseV0100DashboardProductionReadinessCenterViewModel()
    }

    public static func localArtifactStateFixture(
        artifactStates: [ReleaseV0110DashboardReadinessArtifactStateInput],
        bundleState: ReleaseV0110DashboardReadinessBundleStateInput,
        source: String = "local-readiness-artifacts"
    ) -> ReleaseV0100DashboardProductionReadinessCenterViewModel {
        let statesByFileName = Dictionary(uniqueKeysWithValues: artifactStates.map { ($0.fileName, $0) })
        let cards = defaultReadinessCards.map { card -> ReleaseV0100DashboardProductionReadinessCenterCard in
            guard let state = statesByFileName[card.evidenceArtifact] else {
                return card.applying(
                    localArtifactState: ReleaseV0110DashboardReadinessArtifactStateInput(
                        artifactID: "missing-\(card.evidenceArtifact)",
                        relativePath: card.evidenceArtifact,
                        state: .missing,
                        evidenceExists: false,
                        checksumReference: card.checksumReference,
                        checksumMatches: false,
                        stateReason: "missing local readiness artifact"
                    )
                )
            }
            return card.applying(localArtifactState: state)
        }
        return ReleaseV0100DashboardProductionReadinessCenterViewModel(
            readinessCards: cards,
            localArtifactStateSource: source,
            bundleValidationState: bundleState.state,
            bundleValidationReason: bundleState.stateReason,
            localArtifactStateBound: bundleState.inputHeld && cards.allSatisfy(\.cardHeld)
        )
    }

    public static func artifactStates(fromReadinessManifestJSON data: Data)
        throws -> [ReleaseV0110DashboardReadinessArtifactStateInput]
    {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let manifest = try decoder.decode(ReadinessManifestDTO.self, from: data)
        guard manifest.productionCapabilitiesDisabled else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Dashboard refuses manifest with production capability enabled"
                )
            )
        }
        return manifest.entries.map { entry in
            ReleaseV0110DashboardReadinessArtifactStateInput(
                artifactID: entry.artifactID,
                relativePath: entry.relativePath,
                state: ReleaseV0110DashboardReadinessArtifactState(rawValue: entry.validationState) ?? .invalid,
                evidenceExists: entry.evidenceExists,
                checksumReference: entry.checksum,
                checksumMatches: entry.validationState == ReleaseV0110DashboardReadinessArtifactState.valid.rawValue,
                stateReason: entry.stateReason
            )
        }
    }

    public static func bundleState(fromBundleValidationJSON data: Data)
        throws -> ReleaseV0110DashboardReadinessBundleStateInput
    {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let result = try decoder.decode(BundleValidationDTO.self, from: data)
        return ReleaseV0110DashboardReadinessBundleStateInput(
            state: ReleaseV0110DashboardReadinessArtifactState(rawValue: result.state) ?? .invalid,
            policyVersion: result.policyVersion,
            stateReason: result.stateReason,
            requiredArtifactIDs: result.requiredArtifactIDs,
            manifestArtifactIDs: result.manifestArtifactIDs,
            missingRequiredArtifactIDs: result.missingRequiredArtifactIDs,
            unexpectedArtifactIDs: result.unexpectedArtifactIDs,
            productionTradingEnabledByDefault: result.productionTradingEnabledByDefault,
            productionSecretRead: result.productionSecretRead,
            productionEndpointConnected: result.productionEndpointConnected,
            brokerEndpointConnected: result.brokerEndpointConnected,
            productionOrderSubmitted: result.productionOrderSubmitted,
            testnetOrderSubmissionAllowed: result.testnetOrderSubmissionAllowed,
            productionCutoverAuthorized: result.productionCutoverAuthorized
        )
    }

    private var artifactStateSummary: String {
        readinessCards
            .map { "\($0.evidenceArtifact)=\($0.artifactValidationState.rawValue)" }
            .joined(separator: ",")
    }

    private struct ReadinessManifestDTO: Decodable {
        let entries: [Entry]
        let productionTradingEnabledByDefault: Bool
        let productionSecretRead: Bool
        let productionEndpointConnected: Bool
        let brokerEndpointConnected: Bool
        let productionOrderSubmitted: Bool
        let testnetOrderSubmissionAllowed: Bool
        let productionCutoverAuthorized: Bool

        var productionCapabilitiesDisabled: Bool {
            productionTradingEnabledByDefault == false
                && productionSecretRead == false
                && productionEndpointConnected == false
                && brokerEndpointConnected == false
                && productionOrderSubmitted == false
                && testnetOrderSubmissionAllowed == false
                && productionCutoverAuthorized == false
        }

        struct Entry: Decodable {
            let artifactID: String
            let relativePath: String
            let checksum: String
            let validationState: String
            let evidenceExists: Bool
            let stateReason: String
        }
    }

    private struct BundleValidationDTO: Decodable {
        let policyVersion: String
        let state: String
        let requiredArtifactIDs: [String]
        let manifestArtifactIDs: [String]
        let missingRequiredArtifactIDs: [String]
        let unexpectedArtifactIDs: [String]
        let stateReason: String
        let productionTradingEnabledByDefault: Bool
        let productionSecretRead: Bool
        let productionEndpointConnected: Bool
        let brokerEndpointConnected: Bool
        let productionOrderSubmitted: Bool
        let testnetOrderSubmissionAllowed: Bool
        let productionCutoverAuthorized: Bool
    }

    public static let requiredValidationAnchors = [
        "GH-890-VERIFY-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER",
        "TVM-RELEASE-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER",
        "V0100-013-DASHBOARD-PRODUCTION-READINESS-CENTER",
        "V0100-013-READINESS-OVERVIEW",
        "V0100-013-ENVIRONMENT-PROFILE",
        "V0100-013-SECRET-READINESS",
        "V0100-013-ENDPOINT-POLICY",
        "V0100-013-RISK-CAPITAL-LIMITS",
        "V0100-013-KILL-SWITCH-NO-TRADE",
        "V0100-013-COMMAND-SURFACE-DISABLED",
        "V0100-013-SHADOW-DRY-RUN-PARITY",
        "V0100-013-APPROVAL-WORKFLOW",
        "V0100-013-READINESS-BUNDLE",
        "V0100-013-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND",
        "V0100-013-NO-SUBMIT-CANCEL-REPLACE",
        "V0100-013-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH890DashboardProductionReadinessCenterShowsReadinessWithoutCommands",
        "swift test --filter TargetGraphTests/testGH890DashboardProductionReadinessCenterIsAnchoredInV0100Guards",
        "bash checks/verify-v0.10.0-dashboard-production-readiness-center.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultReadinessCards = [
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .readinessOverview,
            sourceIssueID: "GH-878",
            title: "Readiness Overview",
            evidenceArtifact: "production-readiness-overview.json",
            checksumReference: "sha256:gh890-readiness-overview"
        ),
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .environmentProfile,
            sourceIssueID: "GH-880",
            title: "Environment Profile",
            evidenceArtifact: "production-environment-profile.json",
            checksumReference: "sha256:gh890-environment-profile"
        ),
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .secretReadiness,
            sourceIssueID: "GH-881",
            title: "Secret Readiness",
            evidenceArtifact: "secret-readiness.json",
            checksumReference: "sha256:gh890-secret-readiness"
        ),
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .endpointPolicy,
            sourceIssueID: "GH-882",
            title: "Endpoint Policy",
            evidenceArtifact: "endpoint-policy-readiness.json",
            checksumReference: "sha256:gh890-endpoint-policy"
        ),
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .riskCapitalLimits,
            sourceIssueID: "GH-883",
            title: "Risk / Capital Limits",
            evidenceArtifact: "capital-exposure-limits.json",
            checksumReference: "sha256:gh890-risk-capital"
        ),
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .killSwitchNoTrade,
            sourceIssueID: "GH-884",
            title: "Kill Switch / No-trade",
            evidenceArtifact: "kill-switch-no-trade-readiness.json",
            checksumReference: "sha256:gh890-kill-switch-no-trade"
        ),
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .commandSurfaceDisabled,
            sourceIssueID: "GH-885",
            title: "Command Surface Disabled",
            evidenceArtifact: "dashboard-production-surface-disabled.json",
            checksumReference: "sha256:gh890-command-surface"
        ),
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .shadowDryRunParity,
            sourceIssueID: "GH-886",
            title: "Shadow Dry-run Parity",
            evidenceArtifact: "shadow-dry-run-parity.json",
            checksumReference: "sha256:gh890-shadow-dry-run"
        ),
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .approvalWorkflow,
            sourceIssueID: "GH-888",
            title: "Approval Workflow",
            evidenceArtifact: "cutover-approval-workflow.json",
            checksumReference: "sha256:gh890-approval-workflow"
        ),
        ReleaseV0100DashboardProductionReadinessCenterCard(
            panel: .readinessBundle,
            sourceIssueID: "GH-887",
            title: "Readiness Bundle",
            evidenceArtifact: "production-readiness-bundle.json",
            checksumReference: "sha256:gh890-readiness-bundle"
        )
    ]
}
