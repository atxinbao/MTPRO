import Foundation

/// ReleaseV0140ReadOnlyExecutionDashboardStage 固定 GH-1041 Dashboard 可展示的执行闭环阶段。
///
/// 这些阶段只映射 GH-1040 execution event log 的只读证据链；它们不是 command handler、
/// broker adapter、生产 endpoint 连接或真实订单生命周期授权。
public enum ReleaseV0140ReadOnlyExecutionDashboardStage:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case strategySignal = "strategy-signal"
    case orderIntent = "order-intent"
    case riskCheck = "risk-check"
    case binanceTestnetExecution = "binance-testnet-execution"
    case omsEventLog = "oms-event-log"
    case reconciliation = "reconciliation"
    case dashboardStatus = "dashboard-status"
}

/// ReleaseV0140ReadOnlyExecutionDashboardLogInput 是 Dashboard 消费 GH-1040 的只读输入摘要。
///
/// 该输入只携带 redacted evidence ID、事件数量和产品/策略范围标签，避免 Dashboard target
/// 直接依赖 ExecutionEngine target 或运行 adapter。所有字段都必须来自已落仓的 event log /
/// read model evidence，而不是运行时对象、broker payload 或生产命令。
public struct ReleaseV0140ReadOnlyExecutionDashboardLogInput:
    Codable,
    Equatable,
    Sendable
{
    public let sourceEvidenceType: String
    public let runID: String
    public let executionLogID: String
    public let sourcePipelineReportID: String
    public let sourceOrderEventStreamID: String
    public let sourceReconciliationReportID: String
    public let entryCount: Int
    public let orderIntentIDs: [String]
    public let localOrderIDs: [String]
    public let riskDecisionIDs: [String]
    public let adapterEvidenceIDs: [String]
    public let omsStoreIDs: [String]
    public let stateSnapshotIDs: [String]
    public let reconciliationReportIDs: [String]
    public let productTypes: [String]
    public let strategyScopeLabels: [String]
    public let redactedEvidenceOnly: Bool
    public let testnetEvidenceOnly: Bool
    public let independentlyInspectable: Bool
    public let readOptimized: Bool

    public var inputHeld: Bool {
        sourceEvidenceType == "ReleaseV0140ExecutionEventLogReport"
            && runID.isEmpty == false
            && executionLogID.isEmpty == false
            && sourcePipelineReportID.isEmpty == false
            && sourceOrderEventStreamID.isEmpty == false
            && sourceReconciliationReportID.isEmpty == false
            && entryCount == ReleaseV0140ReadOnlyExecutionDashboardStage.allCases.count
            && orderIntentIDs.isEmpty == false
            && localOrderIDs.isEmpty == false
            && riskDecisionIDs.isEmpty == false
            && adapterEvidenceIDs.isEmpty == false
            && omsStoreIDs.isEmpty == false
            && stateSnapshotIDs.isEmpty == false
            && reconciliationReportIDs == [sourceReconciliationReportID]
            && productTypes == ["spot", "usd-m-perpetual"]
            && strategyScopeLabels == ["ema", "rsi"]
            && redactedEvidenceOnly
            && testnetEvidenceOnly
            && independentlyInspectable
            && readOptimized
    }

    public init(
        sourceEvidenceType: String = "ReleaseV0140ExecutionEventLogReport",
        runID: String = "gh-1040-execution-event-log-run",
        executionLogID: String = "gh-1040-execution-event-log:deterministic-fixture",
        sourcePipelineReportID: String = "gh-1037-signal-to-execution-pipeline-report",
        sourceOrderEventStreamID: String = "gh-1032-order-event-stream",
        sourceReconciliationReportID: String = "gh-1036-reconciliation-report",
        entryCount: Int = ReleaseV0140ReadOnlyExecutionDashboardStage.allCases.count,
        orderIntentIDs: [String] = ["gh-1025-order-intent"],
        localOrderIDs: [String] = ["gh-1031-local-order"],
        riskDecisionIDs: [String] = ["gh-1034-risk-decision"],
        adapterEvidenceIDs: [String] = ["gh-1029-binance-testnet-adapter-evidence"],
        omsStoreIDs: [String] = ["gh-1031-oms-store"],
        stateSnapshotIDs: [String] = ["gh-1033-oms-state-snapshot"],
        reconciliationReportIDs: [String] = ["gh-1036-reconciliation-report"],
        productTypes: [String] = ["spot", "usd-m-perpetual"],
        strategyScopeLabels: [String] = ["ema", "rsi"],
        redactedEvidenceOnly: Bool = true,
        testnetEvidenceOnly: Bool = true,
        independentlyInspectable: Bool = true,
        readOptimized: Bool = true
    ) {
        self.sourceEvidenceType = sourceEvidenceType
        self.runID = runID
        self.executionLogID = executionLogID
        self.sourcePipelineReportID = sourcePipelineReportID
        self.sourceOrderEventStreamID = sourceOrderEventStreamID
        self.sourceReconciliationReportID = sourceReconciliationReportID
        self.entryCount = entryCount
        self.orderIntentIDs = orderIntentIDs
        self.localOrderIDs = localOrderIDs
        self.riskDecisionIDs = riskDecisionIDs
        self.adapterEvidenceIDs = adapterEvidenceIDs
        self.omsStoreIDs = omsStoreIDs
        self.stateSnapshotIDs = stateSnapshotIDs
        self.reconciliationReportIDs = reconciliationReportIDs
        self.productTypes = productTypes
        self.strategyScopeLabels = strategyScopeLabels
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.independentlyInspectable = independentlyInspectable
        self.readOptimized = readOptimized
    }
}

/// ReleaseV0140ReadOnlyExecutionDashboardRow 是 GH-1041 Dashboard 的单行执行状态。
///
/// Row 只保存 stage、status、source evidence ID 和可读摘要；它不保存原始执行 payload，
/// 不暴露 order form，也不能触发 submit / cancel / replace。
public struct ReleaseV0140ReadOnlyExecutionDashboardRow:
    Codable,
    Equatable,
    Sendable
{
    public let stage: ReleaseV0140ReadOnlyExecutionDashboardStage
    public let status: String
    public let sourceEvidenceID: String
    public let summary: String
    public let sequence: Int
    public let visibleInDashboard: Bool
    public let readOnly: Bool
    public let commandHandlerBound: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let submitCancelReplaceEnabled: Bool

    public var rowHeld: Bool {
        sequence > 0
            && status == "read-only-visible"
            && sourceEvidenceID.isEmpty == false
            && summary.isEmpty == false
            && visibleInDashboard
            && readOnly
            && commandHandlerBound == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && submitCancelReplaceEnabled == false
    }

    public init(
        stage: ReleaseV0140ReadOnlyExecutionDashboardStage,
        sourceEvidenceID: String,
        summary: String,
        sequence: Int,
        status: String = "read-only-visible",
        visibleInDashboard: Bool = true,
        readOnly: Bool = true,
        commandHandlerBound: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false
    ) {
        self.stage = stage
        self.status = status
        self.sourceEvidenceID = sourceEvidenceID
        self.summary = summary
        self.sequence = sequence
        self.visibleInDashboard = visibleInDashboard
        self.readOnly = readOnly
        self.commandHandlerBound = commandHandlerBound
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
    }
}

/// ReleaseV0140ReadOnlyExecutionDashboardSurfaceViewModel 是 GH-1041 的只读执行 Dashboard。
///
/// Surface 只消费 GH-1040 已生成的 execution event log / read model 摘要，展示 testnet
/// closed loop 的状态、生命周期、reconciliation 和 production boundary 证据。它不依赖
/// ExecutionEngine target，不创建 Dashboard command surface，不提供 trading button / order form，
/// 也不授权生产 endpoint、生产 secret 或真实订单。
public struct ReleaseV0140ReadOnlyExecutionDashboardSurfaceViewModel:
    Codable,
    Equatable,
    Sendable
{
    public let issueID: String
    public let upstreamIssueIDs: [String]
    public let previousIssueID: String
    public let releaseVersion: String
    public let source: ViewModelSourceContract
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let logInput: ReleaseV0140ReadOnlyExecutionDashboardLogInput
    public let rows: [ReleaseV0140ReadOnlyExecutionDashboardRow]
    public let closedLoopStagesVisible: Bool
    public let orderLifecycleVisible: Bool
    public let reconciliationVisible: Bool
    public let eventLogEvidenceVisible: Bool
    public let readOnly: Bool
    public let dashboardDependsOnExecutionEngineTarget: Bool
    public let dashboardCommandSurfaceEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let submitCancelReplaceEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let boundaryHeld: Bool

    public var visibleRowCount: Int {
        rows.count
    }

    public var stageLabels: [String] {
        rows.map(\.stage.rawValue)
    }

    public var statusLabels: [String] {
        rows.map(\.status)
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.14 execution dashboard rows", value: "\(visibleRowCount)"),
            DashboardShellMetric(label: "v0.14 execution log entries", value: "\(logInput.entryCount)"),
            DashboardShellMetric(label: "v0.14 order intents", value: "\(logInput.orderIntentIDs.count)"),
            DashboardShellMetric(label: "v0.14 reconciliation", value: logInput.sourceReconciliationReportID),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Run ID: \(logInput.runID)",
            "Execution log: \(logInput.executionLogID)",
            "Pipeline report: \(logInput.sourcePipelineReportID)",
            "Order event stream: \(logInput.sourceOrderEventStreamID)",
            "Reconciliation report: \(logInput.sourceReconciliationReportID)",
            "Stages: \(stageLabels.joined(separator: ", "))",
            "Statuses: \(statusLabels.joined(separator: ", "))",
            "Source evidence IDs: \(rows.map(\.sourceEvidenceID).joined(separator: ", "))",
            "Product types: \(logInput.productTypes.joined(separator: ", "))",
            "Strategy scope: \(logInput.strategyScopeLabels.joined(separator: ", "))",
            "Dashboard command surface: none",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Submit / cancel / replace: none",
            "Production endpoint: none",
            "Production boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        issueID: String = "GH-1041",
        upstreamIssueIDs: [String] = ["GH-1040"],
        previousIssueID: String = "GH-1040",
        releaseVersion: String = "v0.14.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        logInput: ReleaseV0140ReadOnlyExecutionDashboardLogInput =
            ReleaseV0140ReadOnlyExecutionDashboardLogInput(),
        rows: [ReleaseV0140ReadOnlyExecutionDashboardRow] = Self.defaultRows,
        closedLoopStagesVisible: Bool = true,
        orderLifecycleVisible: Bool = true,
        reconciliationVisible: Bool = true,
        eventLogEvidenceVisible: Bool = true,
        readOnly: Bool = true,
        dashboardDependsOnExecutionEngineTarget: Bool = false,
        dashboardCommandSurfaceEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.releaseVersion = releaseVersion
        self.source = source
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.logInput = logInput
        self.rows = rows
        self.closedLoopStagesVisible = closedLoopStagesVisible
        self.orderLifecycleVisible = orderLifecycleVisible
        self.reconciliationVisible = reconciliationVisible
        self.eventLogEvidenceVisible = eventLogEvidenceVisible
        self.readOnly = readOnly
        self.dashboardDependsOnExecutionEngineTarget = dashboardDependsOnExecutionEngineTarget
        self.dashboardCommandSurfaceEnabled = dashboardCommandSurfaceEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionSubmitCancelReplaceEnabled = productionSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.boundaryHeld = source.isReadModelOnly
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && logInput.inputHeld
            && rows.map(\.stage) == ReleaseV0140ReadOnlyExecutionDashboardStage.allCases
            && rows.map(\.sequence) == Array(1...ReleaseV0140ReadOnlyExecutionDashboardStage.allCases.count)
            && rows.allSatisfy(\.rowHeld)
            && closedLoopStagesVisible
            && orderLifecycleVisible
            && reconciliationVisible
            && eventLogEvidenceVisible
            && readOnly
            && dashboardDependsOnExecutionEngineTarget == false
            && dashboardCommandSurfaceEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && submitCancelReplaceEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public static var deterministicFixture: ReleaseV0140ReadOnlyExecutionDashboardSurfaceViewModel {
        ReleaseV0140ReadOnlyExecutionDashboardSurfaceViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-1041-READ-ONLY-EXECUTION-DASHBOARD",
        "GH-1041-EXECUTION-STATUS-SURFACE",
        "GH-1041-NO-DASHBOARD-COMMANDS",
        "TVM-RELEASE-V0140-READ-ONLY-EXECUTION-DASHBOARD"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH1041DashboardReadOnlyExecutionSurfaceShowsClosedLoopEvidenceWithoutCommands",
        "swift test --filter TargetGraphTests/testGH1041DashboardReadOnlyExecutionSurfaceIsAnchoredInV0140Guards",
        "bash checks/verify-v0.14.0-read-only-execution-dashboard.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultRows = [
        ReleaseV0140ReadOnlyExecutionDashboardRow(
            stage: .strategySignal,
            sourceEvidenceID: "gh-1037-strategy-signal",
            summary: "EMA / RSI signal envelope accepted for testnet closed loop",
            sequence: 1
        ),
        ReleaseV0140ReadOnlyExecutionDashboardRow(
            stage: .orderIntent,
            sourceEvidenceID: "gh-1025-order-intent",
            summary: "OrderIntent mapped for Binance spot and USD-M perpetual scope",
            sequence: 2
        ),
        ReleaseV0140ReadOnlyExecutionDashboardRow(
            stage: .riskCheck,
            sourceEvidenceID: "gh-1034-risk-decision",
            summary: "RiskEngine pre-trade gate allowed deterministic testnet intent",
            sequence: 3
        ),
        ReleaseV0140ReadOnlyExecutionDashboardRow(
            stage: .binanceTestnetExecution,
            sourceEvidenceID: "gh-1029-binance-testnet-adapter-evidence",
            summary: "ExecutionEngine mapped intent to Binance testnet evidence only",
            sequence: 4
        ),
        ReleaseV0140ReadOnlyExecutionDashboardRow(
            stage: .omsEventLog,
            sourceEvidenceID: "gh-1032-order-event-stream",
            summary: "OMS local order and event log evidence linked to the run",
            sequence: 5
        ),
        ReleaseV0140ReadOnlyExecutionDashboardRow(
            stage: .reconciliation,
            sourceEvidenceID: "gh-1036-reconciliation-report",
            summary: "Reconciliation report matched OMS state and broker evidence IDs",
            sequence: 6
        ),
        ReleaseV0140ReadOnlyExecutionDashboardRow(
            stage: .dashboardStatus,
            sourceEvidenceID: "gh-1040-execution-event-log:deterministic-fixture",
            summary: "Dashboard displays closed-loop status as read-only evidence",
            sequence: 7
        )
    ]
}
