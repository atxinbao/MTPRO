import Core
import Foundation

/// AccountPositionBalanceReadModelOnlySurfaceTraceItem 是 MTP-138 的 Event Timeline 只读行。
///
/// Trace item 只保存已经进入 App read model 的 snapshot / evidence identity、surface 和 summary。
/// 它不携带 account endpoint payload、broker state、Runtime object、adapter request、order form、
/// live command 或任何可触发真实账户连接的操作。
public struct AccountPositionBalanceReadModelOnlySurfaceTraceItem: Codable, Equatable, Sendable {
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

private extension Array where Element == String {
    func uniquePreservingOrder() -> [String] {
        var seen = Set<String>()
        var values: [String] = []
        for value in self where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}

/// AccountPositionBalanceReadModelOnlySurfaceReadModel 是 MTP-138 的 App 层只读输入。
///
/// 该 read model 只消费 MTP-137 的 deterministic fixture contract，并把 account / position /
/// balance evidence 暴露为 Workbench、Report 和 Events 可展示的稳定输入。它不读取真实账户、
/// 不读取 SQLite / DuckDB schema、不调用 Runtime / Adapter，也不创建 account connect 或 broker connect。
public struct AccountPositionBalanceReadModelOnlySurfaceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let fixture: AccountPositionBalanceReadModelOnlyFixtureContract
    public let blockedStateLabels: [String]
    public let staleStateLabels: [String]
    public let simulatedStateLabels: [String]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        fixture: AccountPositionBalanceReadModelOnlyFixtureContract = .deterministicFixture,
        blockedStateLabels: [String] = Self.requiredBlockedStateLabels,
        staleStateLabels: [String] = Self.requiredStaleStateLabels,
        simulatedStateLabels: [String] = Self.requiredSimulatedStateLabels,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.fixture = fixture
        self.blockedStateLabels = blockedStateLabels
        self.staleStateLabels = staleStateLabels
        self.simulatedStateLabels = simulatedStateLabels
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && fixture.fixtureContractBoundaryHeld
            && blockedStateLabels == Self.requiredBlockedStateLabels
            && staleStateLabels == Self.requiredStaleStateLabels
            && simulatedStateLabels == Self.requiredSimulatedStateLabels
    }

    public static let requiredBlockedStateLabels = [
        "account connect blocked",
        "broker connect blocked",
        "API key input blocked",
        "secret storage blocked",
        "Live PRO Console blocked",
        "trading button blocked",
        "live command blocked",
        "order form blocked"
    ]

    public static let requiredStaleStateLabels = [
        "stale account evidence display only",
        "stale position evidence display only",
        "stale balance evidence display only"
    ]

    public static let requiredSimulatedStateLabels = [
        "fixture account evidence",
        "simulated position exposure evidence",
        "paper / simulated balance interpretation"
    ]
}

/// AccountPositionBalanceReadModelOnlySurfaceRecordViewModel 是 MTP-138 单条 evidence row。
///
/// Row 只复制 fixture contract 中允许展示的 identity、source、freshness 和 read-model field
/// names；不会展开 payload、schema、Runtime object、adapter request 或 broker state。
public struct AccountPositionBalanceReadModelOnlySurfaceRecordViewModel: Codable, Equatable, Sendable {
    public let component: String
    public let snapshotID: String
    public let evidenceID: String
    public let sourceIdentity: String
    public let observedAt: Int
    public let sourceWatermark: String
    public let freshnessStatus: ScenarioReplayFreshnessStatus
    public let readModelFields: [String]
    public let summary: String

    public init(record: AccountPositionBalanceReadModelOnlyFixtureRecord) {
        self.component = record.component.rawValue
        self.snapshotID = record.snapshotID
        self.evidenceID = record.evidenceID
        self.sourceIdentity = record.sourceIdentity
        self.observedAt = record.observedAt
        self.sourceWatermark = record.sourceWatermark
        self.freshnessStatus = record.freshnessStatus
        self.readModelFields = record.readModelFields
        self.summary = "\(record.component.rawValue): source=\(record.sourceIdentity); freshness=\(record.freshnessStatus.rawValue); fields=\(record.readModelFields.joined(separator: "+"))"
    }
}

/// AccountPositionBalanceReadModelOnlySurfaceViewModel 是 MTP-138 的 Dashboard / Report / Events 快照。
///
/// ViewModel 只输出 fixture / paper / simulated / read-model-only evidence surface 和 forbidden UI flags。
/// 它不提供 API key 输入、secret storage、account connect、broker connect、Live PRO Console、
/// trading button、order form、live command、adapter、Runtime、schema、signed/account endpoint 或真实订单授权。
public struct AccountPositionBalanceReadModelOnlySurfaceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let issueID: String
    public let matrixID: String
    public let fixtureVersion: String
    public let checksum: String
    public let sourceIdentity: String
    public let sourceWatermark: String
    public let records: [AccountPositionBalanceReadModelOnlySurfaceRecordViewModel]
    public let componentLabels: [String]
    public let snapshotIDs: [String]
    public let evidenceIDs: [String]
    public let freshnessStatuses: [ScenarioReplayFreshnessStatus]
    public let readModelFieldNames: [String]
    public let blockedStateLabels: [String]
    public let staleStateLabels: [String]
    public let simulatedStateLabels: [String]
    public let reportSummary: String
    public let dashboardPanelSummaries: [String]
    public let eventTraceItems: [AccountPositionBalanceReadModelOnlySurfaceTraceItem]
    public let recordCount: Int
    public let eventTraceItemCount: Int
    public let consumesOnlyReadModelViewModel: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesAPIKeyInput: Bool
    public let storesSecret: Bool
    public let providesBrokerConnect: Bool
    public let providesAccountConnect: Bool
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
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let readsRealAccount: Bool
    public let syncsBrokerPosition: Bool
    public let readsRealPnL: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: AccountPositionBalanceReadModelOnlySurfaceReadModel) {
        let fixture = readModel.fixture
        let records = fixture.records.map(AccountPositionBalanceReadModelOnlySurfaceRecordViewModel.init)
        let componentLabels = records.map(\.component)
        let snapshotIDs = records.map(\.snapshotID)
        let evidenceIDs = records.map(\.evidenceID)
        let freshnessStatuses = records.map(\.freshnessStatus)
        let readModelFieldNames = records
            .flatMap(\.readModelFields)
            .uniquePreservingOrder()
        let sourceIdentity = records.first?.sourceIdentity ?? AccountPositionBalanceReadModelOnlyFixtureRecord.requiredSourceIdentity
        let sourceWatermark = records.first?.sourceWatermark ?? AccountPositionBalanceReadModelOnlyFixtureRecord.requiredSourceWatermark
        let reportSummary = "Account / position / balance read-model-only surface: records=\(records.count); fixture=\(fixture.fixtureVersion.rawValue); source=\(sourceIdentity); freshness=\(freshnessStatuses.map(\.rawValue).uniquePreservingOrder().joined(separator: "+"))"
        let dashboardPanelSummaries = [
            "Account evidence: \(records.first { $0.component == AccountPositionBalanceReadModelOnlyFixtureComponent.accountSnapshot.rawValue }?.evidenceID ?? "n/a")",
            "Position exposure: \(records.first { $0.component == AccountPositionBalanceReadModelOnlyFixtureComponent.positionSnapshot.rawValue }?.evidenceID ?? "n/a")",
            "Balance interpretation: \(records.first { $0.component == AccountPositionBalanceReadModelOnlyFixtureComponent.balanceSnapshot.rawValue }?.evidenceID ?? "n/a")",
            "Blocked UI: \(readModel.blockedStateLabels.joined(separator: "+"))"
        ]
        let eventTraceItems = records.map { record in
            AccountPositionBalanceReadModelOnlySurfaceTraceItem(
                traceID: "mtp-138-\(record.component.replacingOccurrences(of: " ", with: "-"))",
                surface: "account / position / balance read-model-only",
                title: "\(record.component.capitalized) read-model-only evidence",
                summary: record.summary,
                evidenceID: record.evidenceID,
                sourceAnchor: "MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE"
            )
        }

        self.source = readModel.source
        self.issueID = "MTP-138"
        self.matrixID = "TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY"
        self.fixtureVersion = fixture.fixtureVersion.rawValue
        self.checksum = fixture.checksum
        self.sourceIdentity = sourceIdentity
        self.sourceWatermark = sourceWatermark
        self.records = records
        self.componentLabels = componentLabels
        self.snapshotIDs = snapshotIDs
        self.evidenceIDs = evidenceIDs
        self.freshnessStatuses = freshnessStatuses
        self.readModelFieldNames = readModelFieldNames
        self.blockedStateLabels = readModel.blockedStateLabels
        self.staleStateLabels = readModel.staleStateLabels
        self.simulatedStateLabels = readModel.simulatedStateLabels
        self.reportSummary = reportSummary
        self.dashboardPanelSummaries = dashboardPanelSummaries
        self.eventTraceItems = eventTraceItems
        self.recordCount = records.count
        self.eventTraceItemCount = eventTraceItems.count
        self.consumesOnlyReadModelViewModel = true
        self.exposesAPIKeyInput = false
        self.storesSecret = false
        self.providesBrokerConnect = false
        self.providesAccountConnect = false
        self.exposesLivePROConsole = false
        self.providesTradingButton = false
        self.providesLiveCommand = false
        self.exposesOrderForm = false
        self.exposesRuntimeObject = false
        self.exposesDatabaseSchema = false
        self.exposesAdapterRequest = false
        self.exposesAccountPayload = false
        self.exposesBrokerState = false
        self.callsSignedEndpoint = fixture.callsSignedEndpoint
        self.callsAccountEndpoint = fixture.callsAccountEndpoint
        self.createsListenKey = fixture.createsListenKey
        self.connectsBroker = fixture.importsBrokerPayload || fixture.syncsBrokerPosition
        self.implementsLiveExecutionAdapter = false
        self.implementsOMS = false
        self.implementsRealOrderLifecycle = false
        self.readsRealAccount = fixture.readsRealAccount
        self.syncsBrokerPosition = fixture.syncsBrokerPosition
        self.readsRealPnL = fixture.readsRealPnL
        self.readsMargin = fixture.readsMargin
        self.readsLeverage = fixture.readsLeverage
        self.providesCommandSurface = false
        self.providesOrderLevelCommand = false
        self.authorizesLiveTrading = false
        self.authorizesTradingExecution = false
        self.requiredValidationDependsOnNetwork = false
        self.lastAppliedSequence = readModel.lastAppliedSequence
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && records.count == 3
            && eventTraceItems.count == 3
            && consumesOnlyReadModelViewModel
            && exposesAPIKeyInput == false
            && storesSecret == false
            && providesBrokerConnect == false
            && providesAccountConnect == false
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
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && readsRealAccount == false
            && syncsBrokerPosition == false
            && readsRealPnL == false
            && readsMargin == false
            && readsLeverage == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
    }
}
