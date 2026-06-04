import Foundation
import Core

/// LiveExecutionControlBlockedEvidenceViewItem 是 App 层可展示的单项执行控制阻断证据。
///
/// 该类型只复制 Core `LiveExecutionControlBlockedEvidenceItem` 的 gate、reason 和只读边界旗标；
/// 它不携带 command 参数、adapter request、persistence schema、runtime object、broker order id
/// 或任何可以触发真实 submit / cancel / replace 的交易能力。
public struct LiveExecutionControlBlockedEvidenceViewItem: Codable, Equatable, Sendable {
    public let evidenceID: String
    public let gate: LiveExecutionControlBlockedGate
    public let blockedReasons: [LiveExecutionControlBlockedReason]
    public let blockedReasonLabels: [String]
    public let sourceAnchors: [String]
    public let isBlocked: Bool
    public let canExecute: Bool
    public let emitsCommand: Bool
    public let exposesSchema: Bool
    public let readsAdapter: Bool
    public let invokesRuntimeControl: Bool
    public let authorizesLiveExecution: Bool

    public init(item: Core.LiveExecutionControlBlockedEvidenceItem) {
        self.evidenceID = "mtp-79-\(item.gate.rawValue.slugID())-blocked"
        self.gate = item.gate
        self.blockedReasons = item.blockedReasons
        self.blockedReasonLabels = item.blockedReasons.map(\.rawValue)
        self.sourceAnchors = item.sourceAnchors
        self.isBlocked = item.isBlocked
        self.canExecute = item.canExecute
        self.emitsCommand = item.emitsCommand
        self.exposesSchema = item.exposesSchema
        self.readsAdapter = item.readsAdapter
        self.invokesRuntimeControl = item.invokesRuntimeControl
        self.authorizesLiveExecution = item.authorizesLiveExecution
    }

    /// boundaryHeld 汇总单项 gate 的只读阻断边界，确保展示层不会反向变成执行入口。
    public var boundaryHeld: Bool {
        isBlocked
            && canExecute == false
            && emitsCommand == false
            && exposesSchema == false
            && readsAdapter == false
            && invokesRuntimeControl == false
            && authorizesLiveExecution == false
    }
}

/// LiveExecutionControlBlockedEvidenceReadModel 汇总 MTP-80 可接入 App 的 execution-control 阻断证据。
///
/// 输入只能来自 Core `LiveExecutionControlBlockedEvidence` deterministic fixture 或等价只读模型。
/// App 层只做排序、计数和 ViewModel 派生，不读取 secret、不访问 signed / account endpoint、
/// 不连接 broker，也不调用 Runtime、Persistence 或任何真实交易系统。
public struct LiveExecutionControlBlockedEvidenceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let evidence: Core.LiveExecutionControlBlockedEvidence
    public let items: [LiveExecutionControlBlockedEvidenceViewItem]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        evidence: Core.LiveExecutionControlBlockedEvidence = .deterministicFixture,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.evidence = evidence
        self.items = evidence.blockedItems
            .map(LiveExecutionControlBlockedEvidenceViewItem.init)
            .sortedByExecutionControlGate()
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && evidence.blockedEvidenceBoundaryHeld
            && items.allSatisfy(\.boundaryHeld)
    }
}

/// LiveExecutionControlBlockedEvidenceViewModel 是 Dashboard / Report / Event Timeline 可编码展示快照。
///
/// ViewModel 只输出 blocked gate、blocked reason、deterministic snapshot 和边界旗标。所有 command、
/// order form、order-level UI、adapter、Runtime、schema、secret、signed endpoint 和真实交易授权
/// 都必须保持 false。
public struct LiveExecutionControlBlockedEvidenceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let contractID: String
    public let issueID: String
    public let items: [LiveExecutionControlBlockedEvidenceViewItem]
    public let blockedGateCount: Int
    public let blockedGateLabels: [String]
    public let blockedReasonLabels: [String]
    public let sourceAnchors: [String]
    public let deterministicSnapshot: [String]
    public let allExecutionControlGatesBlocked: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesPersistenceSchema: Bool
    public let readsAdapter: Bool
    public let invokesRuntimeControl: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveExecution: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsRealOrderStateMachine: Bool
    public let implementsOMS: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool
    public let executesIncidentFallback: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: LiveExecutionControlBlockedEvidenceReadModel) {
        let source = readModel.source
        let evidence = readModel.evidence
        let items = readModel.items
        let exposesPersistenceSchema = source.exposesDatabaseTables
            || source.exposesORMModels
            || evidence.exposesPersistenceSchema
            || items.contains(where: \.exposesSchema)
        let readsAdapter = source.callsBinanceAdapter
            || evidence.readsAdapter
            || items.contains(where: \.readsAdapter)
        let invokesRuntimeControl = source.exposesRuntimeObjects
            || evidence.invokesRuntimeControl
            || items.contains(where: \.invokesRuntimeControl)
        let providesOrderLevelCommand = evidence.exposesOrderLevelCommandUI
            || evidence.submitsRealOrder
            || evidence.cancelsRealOrder
            || evidence.replacesRealOrder
            || items.contains(where: \.canExecute)
            || items.contains(where: \.emitsCommand)
        let providesCommandSurface = evidence.providesCommandSurface
            || providesOrderLevelCommand
        let authorizesLiveExecution = items.contains(where: \.authorizesLiveExecution)
            || evidence.submitsRealOrder
            || evidence.cancelsRealOrder
            || evidence.replacesRealOrder
            || evidence.consumesExecutionReport
            || evidence.recordsBrokerFill
            || evidence.performsReconciliation
            || evidence.executesIncidentFallback
        let authorizesLiveTrading = source.providesLiveOrderAction
            || authorizesLiveExecution
        let authorizesTradingExecution = authorizesLiveTrading

        self.source = source
        self.contractID = evidence.contractID.rawValue
        self.issueID = evidence.issueID.rawValue
        self.items = items
        self.blockedGateCount = items.count
        self.blockedGateLabels = items.map(\.gate.rawValue)
        self.blockedReasonLabels = items
            .flatMap(\.blockedReasonLabels)
            .uniquePreservingOrder()
        self.sourceAnchors = evidence.sourceAnchors
        self.deterministicSnapshot = evidence.deterministicSnapshot
        self.allExecutionControlGatesBlocked = evidence.allExecutionControlGatesBlocked
            && items.allSatisfy(\.isBlocked)
        self.exposesPersistenceSchema = exposesPersistenceSchema
        self.readsAdapter = readsAdapter
        self.invokesRuntimeControl = invokesRuntimeControl
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.exposesOrderForm = evidence.exposesOrderForm
        self.exposesOrderLevelCommandUI = evidence.exposesOrderLevelCommandUI
        self.providesTradingButton = evidence.providesTradingButton
        self.authorizesLiveExecution = authorizesLiveExecution
        self.authorizesLiveTrading = authorizesLiveTrading
        self.authorizesTradingExecution = authorizesTradingExecution
        self.readsAPIKey = evidence.readsAPIKey
        self.storesSecret = evidence.storesSecret
        self.usesSignedEndpoint = evidence.usesSignedEndpoint
        self.callsAccountEndpoint = evidence.callsAccountEndpoint
        self.createsListenKey = evidence.createsListenKey
        self.instantiatesBrokerExecutionAdapter = evidence.instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = evidence.instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = evidence.implementsLiveExecutionAdapter
        self.implementsRealOrderStateMachine = evidence.implementsRealOrderStateMachine
        self.implementsOMS = evidence.implementsOMS
        self.submitsRealOrder = evidence.submitsRealOrder
        self.cancelsRealOrder = evidence.cancelsRealOrder
        self.replacesRealOrder = evidence.replacesRealOrder
        self.consumesExecutionReport = evidence.consumesExecutionReport
        self.recordsBrokerFill = evidence.recordsBrokerFill
        self.performsReconciliation = evidence.performsReconciliation
        self.executesIncidentFallback = evidence.executesIncidentFallback
        self.requiredValidationDependsOnNetwork = evidence.requiredValidationDependsOnNetwork
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && exposesPersistenceSchema == false
            && readsAdapter == false
            && invokesRuntimeControl == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && exposesOrderForm == false
            && exposesOrderLevelCommandUI == false
            && providesTradingButton == false
            && authorizesLiveExecution == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsRealOrderStateMachine == false
            && implementsOMS == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
            && executesIncidentFallback == false
            && requiredValidationDependsOnNetwork == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element == LiveExecutionControlBlockedEvidenceViewItem {
    func sortedByExecutionControlGate() -> [LiveExecutionControlBlockedEvidenceViewItem] {
        let gateOrder = Dictionary(
            uniqueKeysWithValues: LiveExecutionControlBlockedGate.allCases.enumerated().map {
                ($0.element, $0.offset)
            }
        )
        return sorted { lhs, rhs in
            if lhs.gate != rhs.gate {
                return (gateOrder[lhs.gate] ?? Int.max) < (gateOrder[rhs.gate] ?? Int.max)
            }
            return lhs.evidenceID < rhs.evidenceID
        }
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

private extension String {
    func slugID() -> String {
        lowercased()
            .split { $0 == " " || $0 == "/" }
            .joined(separator: "-")
    }
}
