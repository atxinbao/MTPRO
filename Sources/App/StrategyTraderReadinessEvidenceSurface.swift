import Foundation

/// StrategyTraderReadinessEvidenceSurfaceTraceItem 是 MTP-160 的 Events 只读行。
///
/// Trace item 只保存已经由 MTP-154 至 MTP-159 固定的 readiness anchor、surface 和摘要。
/// 它不携带 Strategy runtime、Trader runtime、Execution Client request、broker command、
/// Runtime object、Adapter request、account payload、broker state、order form 或 live command。
public struct StrategyTraderReadinessEvidenceSurfaceTraceItem: Codable, Equatable, Sendable {
    public let traceID: String
    public let surface: String
    public let title: String
    public let summary: String
    public let evidenceID: String
    public let sourceAnchor: String

    public init(
        traceID: String,
        surface: String,
        title: String,
        summary: String,
        evidenceID: String,
        sourceAnchor: String
    ) {
        self.traceID = traceID
        self.surface = surface
        self.title = title
        self.summary = summary
        self.evidenceID = evidenceID
        self.sourceAnchor = sourceAnchor
    }
}

/// StrategyTraderReadinessEvidenceSurfaceRecord 是 MTP-160 的最小 readiness evidence row。
///
/// Row 只引用当前 Project 已完成 issue 的合同 anchor，并把 identity、role、read-model input、
/// proposal isolation 和 forbidden capability coverage 压缩成 display summary。它不会把
/// proposal 或 readiness state 转换成 executable order command、broker request 或 UI action。
public struct StrategyTraderReadinessEvidenceSurfaceRecord: Codable, Equatable, Sendable {
    public let issueID: String
    public let evidenceID: String
    public let sourceAnchor: String
    public let category: String
    public let displayState: String
    public let summary: String
    public let readModelOnlyBoundaryHeld: Bool
    public let nonExecutionBoundaryHeld: Bool

    public init(
        issueID: String,
        evidenceID: String,
        sourceAnchor: String,
        category: String,
        displayState: String = "readiness evidence",
        summary: String,
        readModelOnlyBoundaryHeld: Bool = true,
        nonExecutionBoundaryHeld: Bool = true
    ) {
        self.issueID = issueID
        self.evidenceID = evidenceID
        self.sourceAnchor = sourceAnchor
        self.category = category
        self.displayState = displayState
        self.summary = summary
        self.readModelOnlyBoundaryHeld = readModelOnlyBoundaryHeld
        self.nonExecutionBoundaryHeld = nonExecutionBoundaryHeld
    }
}

/// StrategyTraderReadinessEvidenceSurfaceReadModel 是 MTP-160 的 App 层只读输入。
///
/// 该 read model 只组合 MTP-154 至 MTP-159 的 deterministic contract evidence，供
/// Workbench、Report 和 Events 展示 Strategy / Trader readiness。它不读取真实账户、不连接
/// broker、不访问 Persistence schema、不调用 Runtime / Adapter，也不创建 Strategy Console、
/// Live PRO Console、trading button、live command 或 order form。
public struct StrategyTraderReadinessEvidenceSurfaceReadModel: Equatable, Sendable {
    public static let contractAnchor = "MTP-160-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE"
    public static let sourceChainAnchor = "MTP-160-STRATEGY-READINESS-SOURCE-CHAIN"
    public static let boundaryAnchor = "MTP-160-NO-COMMAND-RUNTIME-SCHEMA-ACCOUNT-BOUNDARY"
    public static let validationAnchor = "MTP-160-STRATEGY-TRADER-READINESS-SURFACE-VALIDATION"

    public let source: ViewModelSourceContract
    public let records: [StrategyTraderReadinessEvidenceSurfaceRecord]
    public let instanceIdentityLabels: [String]
    public let lifecycleStateLabels: [String]
    public let roleLabels: [String]
    public let readModelInputLabels: [String]
    public let proposalIsolationLabels: [String]
    public let forbiddenCapabilityLabels: [String]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        records: [StrategyTraderReadinessEvidenceSurfaceRecord] = Self.deterministicRecords,
        instanceIdentityLabels: [String] = Self.requiredInstanceIdentityLabels,
        lifecycleStateLabels: [String] = Self.requiredLifecycleStateLabels,
        roleLabels: [String] = Self.requiredRoleLabels,
        readModelInputLabels: [String] = Self.requiredReadModelInputLabels,
        proposalIsolationLabels: [String] = Self.requiredProposalIsolationLabels,
        forbiddenCapabilityLabels: [String] = Self.requiredForbiddenCapabilityLabels,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.records = records
        self.instanceIdentityLabels = instanceIdentityLabels
        self.lifecycleStateLabels = lifecycleStateLabels
        self.roleLabels = roleLabels
        self.readModelInputLabels = readModelInputLabels
        self.proposalIsolationLabels = proposalIsolationLabels
        self.forbiddenCapabilityLabels = forbiddenCapabilityLabels
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && records.count == Self.deterministicRecords.count
            && records.allSatisfy(\.readModelOnlyBoundaryHeld)
            && records.allSatisfy(\.nonExecutionBoundaryHeld)
            && instanceIdentityLabels == Self.requiredInstanceIdentityLabels
            && lifecycleStateLabels == Self.requiredLifecycleStateLabels
            && roleLabels == Self.requiredRoleLabels
            && readModelInputLabels == Self.requiredReadModelInputLabels
            && proposalIsolationLabels == Self.requiredProposalIsolationLabels
            && forbiddenCapabilityLabels == Self.requiredForbiddenCapabilityLabels
    }

    public static let requiredInstanceIdentityLabels = [
        "Strategy Instance identity",
        "Trader Instance identity"
    ]

    public static let requiredLifecycleStateLabels = [
        "configured",
        "ready",
        "blocked",
        "inactive",
        "simulation-only"
    ]

    public static let requiredRoleLabels = [
        "quoter readiness role",
        "hedger readiness role"
    ]

    public static let requiredReadModelInputLabels = [
        "account read-model input",
        "portfolio read-model input",
        "risk read-model input"
    ]

    public static let requiredProposalIsolationLabels = [
        "paper/live-neutral proposal",
        "proposal-to-command isolation",
        "forbidden command field guard"
    ]

    public static let requiredForbiddenCapabilityLabels = [
        "Strategy -> Execution Client blocked",
        "broker command blocked",
        "OMS / real order lifecycle blocked",
        "Live PRO Console blocked",
        "trading button blocked",
        "live command blocked",
        "order form blocked",
        "signed/account endpoint and listenKey blocked"
    ]

    public static let deterministicRecords = [
        StrategyTraderReadinessEvidenceSurfaceRecord(
            issueID: "MTP-154",
            evidenceID: "mtp-154-strategy-trader-readiness-terminology",
            sourceAnchor: "MTP-154-STRATEGY-TRADER-INSTANCE-READINESS-TERMINOLOGY",
            category: "terminology / boundary",
            summary: "Strategy Instance、Trader Instance、proposal 和 readiness evidence 只表达 non-execution baseline"
        ),
        StrategyTraderReadinessEvidenceSurfaceRecord(
            issueID: "MTP-155",
            evidenceID: "mtp-155-strategy-trader-lifecycle-identity",
            sourceAnchor: "MTP-155-STRATEGY-TRADER-LIFECYCLE-IDENTITY",
            category: "lifecycle / identity",
            summary: "configured / ready / blocked / inactive / simulation-only 只表示 readiness state"
        ),
        StrategyTraderReadinessEvidenceSurfaceRecord(
            issueID: "MTP-156",
            evidenceID: "mtp-156-quoter-hedger-role-taxonomy",
            sourceAnchor: "MTP-156-QUOTER-HEDGER-ROLE-TAXONOMY",
            category: "role taxonomy",
            summary: "quoter / hedger 是 structural readiness role，不是 order generation engine"
        ),
        StrategyTraderReadinessEvidenceSurfaceRecord(
            issueID: "MTP-157",
            evidenceID: "mtp-157-account-portfolio-risk-read-model-input",
            sourceAnchor: "MTP-157-ACCOUNT-PORTFOLIO-RISK-READ-MODEL-INPUT",
            category: "read-model input",
            summary: "account / portfolio / risk input 只能来自 Read Model / ViewModel boundary"
        ),
        StrategyTraderReadinessEvidenceSurfaceRecord(
            issueID: "MTP-158",
            evidenceID: "mtp-158-paper-live-neutral-proposal-isolation",
            sourceAnchor: "MTP-158-PAPER-LIVE-NEUTRAL-PROPOSAL-CONTRACT",
            category: "proposal isolation",
            summary: "paper/live-neutral proposal 不升级为 executable order command、broker command 或 OMS order"
        ),
        StrategyTraderReadinessEvidenceSurfaceRecord(
            issueID: "MTP-159",
            evidenceID: "mtp-159-forbidden-command-capability-tests",
            sourceAnchor: "MTP-159-FORBIDDEN-CAPABILITY-TESTS-VALIDATION",
            category: "forbidden capability tests",
            summary: "Strategy / Trader readiness 禁止 Execution Client、broker、OMS 和 UI command surface"
        )
    ]
}

/// StrategyTraderReadinessEvidenceSurfaceViewModel 是 MTP-160 的 Workbench / Report / Events 快照。
///
/// ViewModel 只输出 readiness evidence、source anchors、report summary、dashboard panel summary 和
/// event trace。所有 capability flags 必须保持 false，证明该 surface 只消费 App Read Model /
/// ViewModel，不暴露 Runtime、Adapter、schema、account payload、broker state 或任何 command。
public struct StrategyTraderReadinessEvidenceSurfaceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let issueID: String
    public let matrixID: String
    public let records: [StrategyTraderReadinessEvidenceSurfaceRecord]
    public let evidenceIDs: [String]
    public let sourceAnchors: [String]
    public let categories: [String]
    public let instanceIdentityLabels: [String]
    public let lifecycleStateLabels: [String]
    public let roleLabels: [String]
    public let readModelInputLabels: [String]
    public let proposalIsolationLabels: [String]
    public let forbiddenCapabilityLabels: [String]
    public let reportSummary: String
    public let dashboardPanelSummaries: [String]
    public let eventTraceItems: [StrategyTraderReadinessEvidenceSurfaceTraceItem]
    public let recordCount: Int
    public let eventTraceItemCount: Int
    public let consumesOnlyReadModelViewModel: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesStrategyConsole: Bool
    public let exposesLivePROConsole: Bool
    public let providesTradingButton: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesRuntimeObject: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesAdapterRequest: Bool
    public let exposesAccountPayload: Bool
    public let exposesBrokerState: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let runsStrategyRuntime: Bool
    public let runsTraderRuntime: Bool
    public let runsExecutionRuntime: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let readsRealAccount: Bool
    public let readsRealPosition: Bool
    public let readsRealBalance: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let readsRealPnL: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: StrategyTraderReadinessEvidenceSurfaceReadModel) {
        let records = readModel.records
        let evidenceIDs = records.map(\.evidenceID)
        let sourceAnchors = records.map(\.sourceAnchor)
        let categories = records.map(\.category)
        let reportSummary = [
            "Strategy / Trader readiness read-model-only surface",
            "records=\(records.count)",
            "roles=\(readModel.roleLabels.joined(separator: "+"))",
            "inputs=\(readModel.readModelInputLabels.joined(separator: "+"))",
            "forbidden=\(readModel.forbiddenCapabilityLabels.count)"
        ].joined(separator: "; ")
        let dashboardPanelSummaries = [
            "Instance identity: \(readModel.instanceIdentityLabels.joined(separator: "+"))",
            "Lifecycle states: \(readModel.lifecycleStateLabels.joined(separator: "+"))",
            "Roles: \(readModel.roleLabels.joined(separator: "+"))",
            "Read-model inputs: \(readModel.readModelInputLabels.joined(separator: "+"))",
            "Proposal isolation: \(readModel.proposalIsolationLabels.joined(separator: "+"))",
            "Forbidden capabilities: \(readModel.forbiddenCapabilityLabels.joined(separator: "+"))"
        ]
        let eventTraceItems = records.map { record in
            StrategyTraderReadinessEvidenceSurfaceTraceItem(
                traceID: "mtp-160-\(record.issueID.lowercased())",
                surface: "strategy trader readiness read-model-only",
                title: "\(record.issueID) \(record.category) readiness evidence",
                summary: record.summary,
                evidenceID: record.evidenceID,
                sourceAnchor: record.sourceAnchor
            )
        }

        self.source = readModel.source
        self.issueID = "MTP-160"
        self.matrixID = "TVM-STRATEGY-TRADER-INSTANCE-READINESS"
        self.records = records
        self.evidenceIDs = evidenceIDs
        self.sourceAnchors = sourceAnchors
        self.categories = categories
        self.instanceIdentityLabels = readModel.instanceIdentityLabels
        self.lifecycleStateLabels = readModel.lifecycleStateLabels
        self.roleLabels = readModel.roleLabels
        self.readModelInputLabels = readModel.readModelInputLabels
        self.proposalIsolationLabels = readModel.proposalIsolationLabels
        self.forbiddenCapabilityLabels = readModel.forbiddenCapabilityLabels
        self.reportSummary = reportSummary
        self.dashboardPanelSummaries = dashboardPanelSummaries
        self.eventTraceItems = eventTraceItems
        self.recordCount = records.count
        self.eventTraceItemCount = eventTraceItems.count
        self.consumesOnlyReadModelViewModel = true
        self.exposesStrategyConsole = false
        self.exposesLivePROConsole = false
        self.providesTradingButton = false
        self.providesLiveCommand = false
        self.exposesOrderForm = false
        self.exposesRuntimeObject = false
        self.exposesDatabaseSchema = false
        self.exposesAdapterRequest = false
        self.exposesAccountPayload = false
        self.exposesBrokerState = false
        self.callsSignedEndpoint = false
        self.callsAccountEndpoint = false
        self.createsListenKey = false
        self.runsStrategyRuntime = false
        self.runsTraderRuntime = false
        self.runsExecutionRuntime = false
        self.connectsBroker = false
        self.implementsLiveExecutionAdapter = false
        self.implementsOMS = false
        self.readsRealAccount = false
        self.readsRealPosition = false
        self.readsRealBalance = false
        self.readsMargin = false
        self.readsLeverage = false
        self.readsRealPnL = false
        self.providesCommandSurface = false
        self.providesOrderLevelCommand = false
        self.authorizesLiveTrading = false
        self.authorizesTradingExecution = false
        self.requiredValidationDependsOnNetwork = false
        self.lastAppliedSequence = readModel.lastAppliedSequence
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && records.count == 6
            && eventTraceItems.count == 6
            && consumesOnlyReadModelViewModel
            && exposesStrategyConsole == false
            && exposesLivePROConsole == false
            && providesTradingButton == false
            && providesLiveCommand == false
            && exposesOrderForm == false
            && exposesRuntimeObject == false
            && exposesDatabaseSchema == false
            && exposesAdapterRequest == false
            && exposesAccountPayload == false
            && exposesBrokerState == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && runsStrategyRuntime == false
            && runsTraderRuntime == false
            && runsExecutionRuntime == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && readsRealAccount == false
            && readsRealPosition == false
            && readsRealBalance == false
            && readsMargin == false
            && readsLeverage == false
            && readsRealPnL == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
    }
}
