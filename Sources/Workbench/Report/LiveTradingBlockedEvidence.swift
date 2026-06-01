import Foundation
import Core

/// LiveTradingBlockedEvidenceItem 是 App 层可展示的单项 Live blocked evidence。
///
/// 该类型只复制 Core `LiveBlockedEvidence` 中允许进入 Dashboard / Report / Event Timeline 的
/// 稳定字段；它不持有 API key、adapter instance、Runtime object、SQLite / DuckDB schema、
/// broker order id 或任何可触发真实交易的 command surface。
public struct LiveTradingBlockedEvidenceItem: Codable, Equatable, Sendable {
    public let evidenceID: String
    public let gate: LiveTradingFoundationGate
    public let capability: LiveBlockedCapability
    public let evidenceKind: LiveBlockedEvidenceKind
    public let sourceAnchors: [String]
    public let status: LiveReadinessStatus
    public let isBlocked: Bool
    public let isReadModelOnly: Bool
    public let providesCommandSurface: Bool
    public let authorizesLiveTrading: Bool
    public let exposesAdapterSurface: Bool
    public let exposesRuntimeObject: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let requiresAPIKey: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerAdapter: Bool
    public let representsRealOrderLifecycle: Bool

    public init(evidence: LiveBlockedEvidence, status: LiveReadinessStatus) {
        self.evidenceID = evidence.evidenceID.rawValue
        self.gate = evidence.gate
        self.capability = evidence.capability
        self.evidenceKind = evidence.evidenceKind
        self.sourceAnchors = evidence.sourceAnchors
        self.status = status
        self.isBlocked = evidence.isBlocked
        self.isReadModelOnly = evidence.isReadModelOnly
        self.providesCommandSurface = evidence.providesCommandSurface
        self.authorizesLiveTrading = evidence.authorizesLiveTrading
        self.exposesAdapterSurface = evidence.exposesAdapterSurface
        self.exposesRuntimeObject = evidence.exposesRuntimeObject
        self.exposesSQLiteSchema = evidence.exposesSQLiteSchema
        self.exposesDuckDBSchema = evidence.exposesDuckDBSchema
        self.requiresAPIKey = evidence.requiresAPIKey
        self.usesSignedEndpoint = evidence.usesSignedEndpoint
        self.callsAccountEndpoint = evidence.callsAccountEndpoint
        self.createsListenKey = evidence.createsListenKey
        self.instantiatesBrokerAdapter = evidence.instantiatesBrokerAdapter
        self.representsRealOrderLifecycle = evidence.representsRealOrderLifecycle
    }

    /// boundaryHeld 汇总 Dashboard 可展示 Live blocked evidence 的禁区检查结果。
    public var boundaryHeld: Bool {
        isBlocked
            && status == .blocked
            && isReadModelOnly
            && providesCommandSurface == false
            && authorizesLiveTrading == false
            && exposesAdapterSurface == false
            && exposesRuntimeObject == false
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && requiresAPIKey == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerAdapter == false
            && representsRealOrderLifecycle == false
    }
}

/// LiveTradingBlockedEvidenceReadModel 汇总 MTP-66 可接入 App 的 Live blocked evidence。
///
/// 输入只能来自 Core `LiveReadiness` 这类 read-model-only 合同。App 层只排序、聚合并保留
/// source contract，不读取 secret、不调用 signed / account endpoint、不连接 broker，也不触发
/// Runtime、Persistence 或外部交易系统 side effect。
public struct LiveTradingBlockedEvidenceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let readiness: LiveReadiness
    public let items: [LiveTradingBlockedEvidenceItem]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        readiness: LiveReadiness = LiveReadiness.deterministicFixture,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.readiness = readiness
        self.items = readiness.blockedEvidence
            .map { LiveTradingBlockedEvidenceItem(evidence: $0, status: readiness.status) }
            .sortedByLiveBlockedEvidence()
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && readiness.liveReadinessBoundaryHeld
            && items.allSatisfy(\.boundaryHeld)
    }
}

/// LiveTradingBlockedEvidenceViewModel 是 Dashboard / Report / Event Timeline 可编码的展示快照。
///
/// ViewModel 只派生计数、标签、gate 和 boundary flags；它不提供 live command、交易按钮、
/// 表单、order-level command、adapter / Runtime / schema 暴露或真实交易授权。
public struct LiveTradingBlockedEvidenceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let readinessID: String
    public let issueID: String
    public let status: LiveReadinessStatus
    public let items: [LiveTradingBlockedEvidenceItem]
    public let blockedEvidenceCount: Int
    public let blockedCapabilityLabels: [String]
    public let blockedGateLabels: [String]
    public let sourceAnchors: [String]
    public let allLiveGatesBlocked: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterSurface: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let supportsQueryLanguage: Bool
    public let authorizesLiveTrading: Bool
    public let touchesBrokerAction: Bool
    public let authorizesTradingExecution: Bool
    public let readsAPIKey: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerAdapter: Bool
    public let representsRealOrderLifecycle: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: LiveTradingBlockedEvidenceReadModel) {
        let source = readModel.source
        let readiness = readModel.readiness
        let items = readModel.items
        let exposesDatabaseSchema = source.exposesDatabaseTables
            || source.exposesORMModels
            || items.contains { $0.exposesSQLiteSchema || $0.exposesDuckDBSchema }
        let exposesRuntimeObject = source.exposesRuntimeObjects
            || items.contains(where: \.exposesRuntimeObject)
        let exposesAdapterSurface = source.callsBinanceAdapter
            || items.contains(where: \.exposesAdapterSurface)
        let providesCommandSurface = items.contains(where: \.providesCommandSurface)
        let providesOrderLevelCommand = false
        let supportsQueryLanguage = false
        let authorizesLiveTrading = items.contains(where: \.authorizesLiveTrading)
            || readiness.authorizesLiveTrading
        let touchesBrokerAction = items.contains(where: \.instantiatesBrokerAdapter)
            || readiness.instantiatesBrokerAdapter
        let authorizesTradingExecution = source.providesLiveOrderAction
            || authorizesLiveTrading
            || items.contains(where: \.representsRealOrderLifecycle)
            || readiness.representsRealOrderLifecycle

        self.source = source
        self.readinessID = readiness.readinessID.rawValue
        self.issueID = readiness.issueID.rawValue
        self.status = readiness.status
        self.items = items
        self.blockedEvidenceCount = items.count
        self.blockedCapabilityLabels = items.map(\.capability.rawValue)
        self.blockedGateLabels = items.map(\.gate.rawValue).uniqueSortedStrings()
        self.sourceAnchors = items.flatMap(\.sourceAnchors).uniqueSortedStrings()
        self.allLiveGatesBlocked = readiness.allLiveGatesBlocked
            && items.allSatisfy(\.isBlocked)
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterSurface = exposesAdapterSurface
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.supportsQueryLanguage = supportsQueryLanguage
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesBrokerAction = touchesBrokerAction
        self.authorizesTradingExecution = authorizesTradingExecution
        self.readsAPIKey = readiness.readsAPIKey || items.contains(where: \.requiresAPIKey)
        self.usesSignedEndpoint = readiness.usesSignedEndpoint
            || items.contains(where: \.usesSignedEndpoint)
        self.callsAccountEndpoint = readiness.callsAccountEndpoint
            || items.contains(where: \.callsAccountEndpoint)
        self.createsListenKey = readiness.createsListenKey
            || items.contains(where: \.createsListenKey)
        self.instantiatesBrokerAdapter = readiness.instantiatesBrokerAdapter
            || items.contains(where: \.instantiatesBrokerAdapter)
        self.representsRealOrderLifecycle = readiness.representsRealOrderLifecycle
            || items.contains(where: \.representsRealOrderLifecycle)
        self.requiredValidationDependsOnNetwork = readiness.requiredValidationDependsOnNetwork
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterSurface == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && supportsQueryLanguage == false
            && authorizesLiveTrading == false
            && touchesBrokerAction == false
            && authorizesTradingExecution == false
            && readsAPIKey == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerAdapter == false
            && representsRealOrderLifecycle == false
            && requiredValidationDependsOnNetwork == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element == LiveTradingBlockedEvidenceItem {
    func sortedByLiveBlockedEvidence() -> [LiveTradingBlockedEvidenceItem] {
        let capabilityOrder = Dictionary(
            uniqueKeysWithValues: LiveBlockedCapability.allCases.enumerated().map {
                ($0.element, $0.offset)
            }
        )
        return sorted { lhs, rhs in
            if lhs.capability != rhs.capability {
                return (capabilityOrder[lhs.capability] ?? Int.max)
                    < (capabilityOrder[rhs.capability] ?? Int.max)
            }
            return lhs.evidenceID < rhs.evidenceID
        }
    }
}

private extension Array where Element == String {
    func uniqueSortedStrings() -> [String] {
        Array(Set(self)).sorted()
    }
}
