import Foundation

/// ReleaseV010LiveMonitoringSurfaceCategory 固定 GH-534 Dashboard 可展示的 release live evidence 分组。
///
/// 这些分组只对应 GitHub release queue 已完成 issue 的 read-model summary，不代表 Dashboard
/// 可以直接持有 runtime object、adapter、broker session、OMS store 或任何 live command surface。
public enum ReleaseV010LiveMonitoringSurfaceCategory: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case connectionHealth = "connection health"
    case accountPrivateStream = "account / private stream status"
    case traderEMA = "Trader / EMA proposal"
    case riskGate = "RiskEngine pre-trade gate"
    case executionLifecycle = "ExecutionEngine / OMS lifecycle"
    case brokerFill = "execution report / broker fill"
    case portfolioReconciliation = "Portfolio reconciliation"
}

/// ReleaseV010LiveMonitoringSurfaceStatus 固定 GH-534 surface 的只读状态标签。
public enum ReleaseV010LiveMonitoringSurfaceStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case readModelAvailable = "read-model available"
    case staleOrBlockedAuditable = "stale / blocked auditable"
    case proposalReady = "proposal ready"
    case gateEvidenceReady = "gate evidence ready"
    case lifecycleEvidenceReady = "lifecycle evidence ready"
    case fillEvidenceReady = "fill evidence ready"
    case projectionEvidenceReady = "projection evidence ready"
}

/// ReleaseV010LiveMonitoringSurfaceEvidenceItem 是 GH-534 Dashboard surface 的单条只读 evidence 行。
///
/// item 只保留上游 issue、anchor、状态和摘要文字；它不包含 raw private payload、listenKey value、
/// production secret、runtime object、broker state、order form 或任何可执行命令。
public struct ReleaseV010LiveMonitoringSurfaceEvidenceItem: Codable, Equatable, Sendable {
    public let itemID: String
    public let sourceIssueID: String
    public let category: ReleaseV010LiveMonitoringSurfaceCategory
    public let status: ReleaseV010LiveMonitoringSurfaceStatus
    public let title: String
    public let summary: String
    public let sourceAnchor: String
    public let readModelOnly: Bool
    public let consumesRuntimeObject: Bool
    public let opensNetworkConnection: Bool
    public let exposesAccountPayload: Bool
    public let providesCommandSurface: Bool
    public let providesTradingButton: Bool
    public let authorizesTradingExecution: Bool

    public init(
        itemID: String,
        sourceIssueID: String,
        category: ReleaseV010LiveMonitoringSurfaceCategory,
        status: ReleaseV010LiveMonitoringSurfaceStatus,
        title: String,
        summary: String,
        sourceAnchor: String,
        readModelOnly: Bool = true,
        consumesRuntimeObject: Bool = false,
        opensNetworkConnection: Bool = false,
        exposesAccountPayload: Bool = false,
        providesCommandSurface: Bool = false,
        providesTradingButton: Bool = false,
        authorizesTradingExecution: Bool = false
    ) {
        self.itemID = itemID
        self.sourceIssueID = sourceIssueID
        self.category = category
        self.status = status
        self.title = title
        self.summary = summary
        self.sourceAnchor = sourceAnchor
        self.readModelOnly = readModelOnly
        self.consumesRuntimeObject = consumesRuntimeObject
        self.opensNetworkConnection = opensNetworkConnection
        self.exposesAccountPayload = exposesAccountPayload
        self.providesCommandSurface = providesCommandSurface
        self.providesTradingButton = providesTradingButton
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public var itemBoundaryHeld: Bool {
        sourceIssueID.hasPrefix("GH-")
            && sourceAnchor.isEmpty == false
            && readModelOnly
            && consumesRuntimeObject == false
            && opensNetworkConnection == false
            && exposesAccountPayload == false
            && providesCommandSurface == false
            && providesTradingButton == false
            && authorizesTradingExecution == false
    }
}

/// ReleaseV010LiveMonitoringSurfaceReadModel 是 GH-534 Dashboard 的 release v0.1.0 live evidence 输入。
///
/// 该 read model 汇总 #526、#528、#529、#530、#531、#532 和 #533 的 read-model evidence
/// identity，用于 Dashboard 报告区观察 connection health、account/private stream、Trader/EMA、
/// RiskEngine、ExecutionEngine 和 Portfolio 状态。它不直接消费任何 release runtime object。
/// `GH-534-DASHBOARD-LIVE-MONITORING-SURFACE`
public struct ReleaseV010LiveMonitoringSurfaceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let evidenceItems: [ReleaseV010LiveMonitoringSurfaceEvidenceItem]
    public let validationAnchors: [String]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        evidenceItems: [ReleaseV010LiveMonitoringSurfaceEvidenceItem] = Self.requiredEvidenceItems,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.evidenceItems = evidenceItems.sorted {
            $0.itemID < $1.itemID
        }
        self.validationAnchors = validationAnchors
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && evidenceItems.count == Self.requiredEvidenceItems.count
            && evidenceItems.allSatisfy(\.itemBoundaryHeld)
            && Set(evidenceItems.map(\.category)) == Set(ReleaseV010LiveMonitoringSurfaceCategory.allCases)
            && validationAnchors == Self.requiredValidationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-534-DASHBOARD-LIVE-MONITORING-SURFACE",
        "GH-534-CONNECTION-HEALTH-READ-MODEL",
        "GH-534-ACCOUNT-PRIVATE-STREAM-STATUS",
        "GH-534-TRADER-EMA-RISK-EXECUTION-PORTFOLIO-SUMMARY",
        "GH-534-READ-MODEL-ONLY-NO-COMMAND-SURFACE",
        "TVM-RELEASE-V010-DASHBOARD-LIVE-MONITORING-SURFACE"
    ]

    public static let requiredEvidenceItems = [
        ReleaseV010LiveMonitoringSurfaceEvidenceItem(
            itemID: "gh-534-01-connection-health",
            sourceIssueID: "GH-526",
            category: .connectionHealth,
            status: .staleOrBlockedAuditable,
            title: "Connection health",
            summary: "Private stream freshness can be shown as read-model-only fresh / stale / blocked evidence.",
            sourceAnchor: "GH-526-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-RUNTIME"
        ),
        ReleaseV010LiveMonitoringSurfaceEvidenceItem(
            itemID: "gh-534-02-account-private-stream",
            sourceIssueID: "GH-526",
            category: .accountPrivateStream,
            status: .readModelAvailable,
            title: "Account and private stream status",
            summary: "Account / balance / position snapshots are represented as redacted read-model records.",
            sourceAnchor: "TVM-RELEASE-V010-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT"
        ),
        ReleaseV010LiveMonitoringSurfaceEvidenceItem(
            itemID: "gh-534-03-trader-ema",
            sourceIssueID: "GH-528",
            category: .traderEMA,
            status: .proposalReady,
            title: "Trader / EMA proposal",
            summary: "EMA proposal evidence is visible as risk-consumable read model, not as an execution command.",
            sourceAnchor: "GH-528-EMA-STRATEGY-PROPOSAL-RUNTIME"
        ),
        ReleaseV010LiveMonitoringSurfaceEvidenceItem(
            itemID: "gh-534-04-risk-gate",
            sourceIssueID: "GH-529",
            category: .riskGate,
            status: .gateEvidenceReady,
            title: "RiskEngine pre-trade gate",
            summary: "Risk allow / reject / blocked decisions are summarized without bypassing the gate.",
            sourceAnchor: "GH-529-RISKENGINE-PRE-TRADE-GATE"
        ),
        ReleaseV010LiveMonitoringSurfaceEvidenceItem(
            itemID: "gh-534-05-execution-lifecycle",
            sourceIssueID: "GH-530",
            category: .executionLifecycle,
            status: .lifecycleEvidenceReady,
            title: "ExecutionEngine / OMS lifecycle",
            summary: "OMS lifecycle states are shown as evidence only; Dashboard does not submit, cancel or replace orders.",
            sourceAnchor: "GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE"
        ),
        ReleaseV010LiveMonitoringSurfaceEvidenceItem(
            itemID: "gh-534-06-broker-fill",
            sourceIssueID: "GH-532",
            category: .brokerFill,
            status: .fillEvidenceReady,
            title: "Execution report / broker fill",
            summary: "Normalized broker fill parser evidence is summarized without raw production execution reports.",
            sourceAnchor: "GH-532-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER"
        ),
        ReleaseV010LiveMonitoringSurfaceEvidenceItem(
            itemID: "gh-534-07-portfolio-reconciliation",
            sourceIssueID: "GH-533",
            category: .portfolioReconciliation,
            status: .projectionEvidenceReady,
            title: "Portfolio reconciliation",
            summary: "Matched / mismatched / stale / blocked reconciliation states are visible as Portfolio projection evidence.",
            sourceAnchor: "GH-533-EXECUTION-ACCOUNT-PORTFOLIO-RECONCILIATION"
        )
    ]
}

/// ReleaseV010LiveMonitoringSurfaceViewModel 是 GH-534 Dashboard 可渲染的 release live summary。
///
/// ViewModel 只输出 label、count、summary 和 forbidden flags；它不提供 secret editor、
/// broker connect、trading button、live command、order form 或 runtime reconnect action。
public struct ReleaseV010LiveMonitoringSurfaceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let issueID: String
    public let matrixID: String
    public let evidenceIDs: [String]
    public let sourceIssueIDs: [String]
    public let categoryLabels: [String]
    public let statusLabels: [String]
    public let titles: [String]
    public let summaries: [String]
    public let sourceAnchors: [String]
    public let validationAnchors: [String]
    public let evidenceCount: Int
    public let connectionHealthCount: Int
    public let accountPrivateStreamStatusCount: Int
    public let traderEMARiskExecutionPortfolioSummaryCount: Int
    public let reportSummary: String
    public let dashboardPanelSummaries: [String]
    public let readModelOnlyBoundaryHeld: Bool
    public let consumesRuntimeObject: Bool
    public let opensNetworkConnection: Bool
    public let exposesAccountPayload: Bool
    public let providesCommandSurface: Bool
    public let providesTradingButton: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesSecretEditor: Bool
    public let connectsBroker: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: ReleaseV010LiveMonitoringSurfaceReadModel) {
        let evidenceItems = readModel.evidenceItems
        let consumesRuntimeObject = evidenceItems.contains(where: \.consumesRuntimeObject)
        let opensNetworkConnection = evidenceItems.contains(where: \.opensNetworkConnection)
        let exposesAccountPayload = evidenceItems.contains(where: \.exposesAccountPayload)
        let providesCommandSurface = evidenceItems.contains(where: \.providesCommandSurface)
        let providesTradingButton = evidenceItems.contains(where: \.providesTradingButton)
        let authorizesTradingExecution = evidenceItems.contains(where: \.authorizesTradingExecution)

        self.source = readModel.source
        self.issueID = "GH-534"
        self.matrixID = "TVM-RELEASE-V010-DASHBOARD-LIVE-MONITORING-SURFACE"
        self.evidenceIDs = evidenceItems.map(\.itemID)
        self.sourceIssueIDs = evidenceItems.map(\.sourceIssueID).uniquePreservingOrder()
        self.categoryLabels = evidenceItems.map { $0.category.rawValue }
        self.statusLabels = evidenceItems.map { $0.status.rawValue }.uniquePreservingOrder()
        self.titles = evidenceItems.map(\.title)
        self.summaries = evidenceItems.map(\.summary)
        self.sourceAnchors = evidenceItems.map(\.sourceAnchor).uniquePreservingOrder()
        self.validationAnchors = readModel.validationAnchors
        self.evidenceCount = evidenceItems.count
        self.connectionHealthCount = evidenceItems.filter { $0.category == .connectionHealth }.count
        self.accountPrivateStreamStatusCount = evidenceItems.filter { $0.category == .accountPrivateStream }.count
        self.traderEMARiskExecutionPortfolioSummaryCount = evidenceItems.filter {
            [
                .traderEMA,
                .riskGate,
                .executionLifecycle,
                .brokerFill,
                .portfolioReconciliation
            ].contains($0.category)
        }.count
        self.reportSummary = [
            "Release v0.1.0 live monitoring surface",
            "evidence=\(evidenceItems.count)",
            "sources=\(evidenceItems.map(\.sourceIssueID).uniquePreservingOrder().joined(separator: "+"))",
            "boundary=\(readModel.readModelOnlyBoundaryHeld)"
        ].joined(separator: "; ")
        self.dashboardPanelSummaries = evidenceItems.map {
            "\($0.title): \($0.status.rawValue)"
        }
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && consumesRuntimeObject == false
            && opensNetworkConnection == false
            && exposesAccountPayload == false
            && providesCommandSurface == false
            && providesTradingButton == false
            && authorizesTradingExecution == false
        self.consumesRuntimeObject = consumesRuntimeObject
        self.opensNetworkConnection = opensNetworkConnection
        self.exposesAccountPayload = exposesAccountPayload
        self.providesCommandSurface = providesCommandSurface
        self.providesTradingButton = providesTradingButton
        self.providesLiveCommand = false
        self.exposesOrderForm = false
        self.exposesSecretEditor = false
        self.connectsBroker = false
        self.authorizesLiveTrading = false
        self.authorizesTradingExecution = authorizesTradingExecution
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
