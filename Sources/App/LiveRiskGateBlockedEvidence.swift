import Foundation
import Core

/// LiveRiskGateBlockedEvidenceViewItem 是 App 层可展示的单项 Live Risk gate 阻断证据。
///
/// 该类型只复制 Core `LiveRiskGateBlockedEvidenceItem` 的 gate、reason 和只读边界旗标；
/// 它不携带账户、broker position、margin、risk decision、command payload 或交易按钮状态。
public struct LiveRiskGateBlockedEvidenceViewItem: Codable, Equatable, Sendable {
    public let evidenceID: String
    public let gate: LiveRiskGateBlockedGate
    public let blockedReasons: [LiveRiskGateBlockedReason]
    public let blockedReasonLabels: [String]
    public let sourceAnchors: [String]
    public let isBlocked: Bool
    public let evaluatesRisk: Bool
    public let emitsCommand: Bool
    public let readsAccountState: Bool
    public let readsBrokerPosition: Bool
    public let exposesSchema: Bool
    public let readsAdapter: Bool
    public let invokesRuntimeControl: Bool
    public let authorizesLiveRiskDecision: Bool

    public init(item: Core.LiveRiskGateBlockedEvidenceItem) {
        self.evidenceID = "mtp-87-\(item.gate.rawValue.slugID())-blocked"
        self.gate = item.gate
        self.blockedReasons = item.blockedReasons
        self.blockedReasonLabels = item.blockedReasons.map(\.rawValue)
        self.sourceAnchors = item.sourceAnchors
        self.isBlocked = item.isBlocked
        self.evaluatesRisk = item.evaluatesRisk
        self.emitsCommand = item.emitsCommand
        self.readsAccountState = item.readsAccountState
        self.readsBrokerPosition = item.readsBrokerPosition
        self.exposesSchema = item.exposesSchema
        self.readsAdapter = item.readsAdapter
        self.invokesRuntimeControl = item.invokesRuntimeControl
        self.authorizesLiveRiskDecision = item.authorizesLiveRiskDecision
    }

    /// boundaryHeld 汇总单项 gate 的只读阻断边界，确保 App 展示不回流成风控执行入口。
    public var boundaryHeld: Bool {
        isBlocked
            && evaluatesRisk == false
            && emitsCommand == false
            && readsAccountState == false
            && readsBrokerPosition == false
            && exposesSchema == false
            && readsAdapter == false
            && invokesRuntimeControl == false
            && authorizesLiveRiskDecision == false
    }
}

/// LiveRiskGateBlockedEvidenceReadModel 汇总 MTP-87 可进入 App 的 Live Risk blocked evidence。
///
/// 输入只能来自 Core `LiveRiskGateBlockedEvidence` deterministic fixture 或等价只读模型。
/// App 只做排序、计数和 ViewModel 派生，不读取 secret、signed/account endpoint、账户、
/// broker position、margin、PnL、Runtime、Persistence 或任何 real pre-trade risk 能力。
public struct LiveRiskGateBlockedEvidenceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let evidence: Core.LiveRiskGateBlockedEvidence
    public let items: [LiveRiskGateBlockedEvidenceViewItem]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        evidence: Core.LiveRiskGateBlockedEvidence = .deterministicFixture,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.evidence = evidence
        self.items = evidence.blockedItems
            .map(LiveRiskGateBlockedEvidenceViewItem.init)
            .sortedByLiveRiskGate()
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && evidence.blockedEvidenceBoundaryHeld
            && items.allSatisfy(\.boundaryHeld)
    }
}

/// LiveRiskGateBlockedEvidenceViewModel 是 Dashboard / Report / Event Timeline 的只读风险阻断快照。
///
/// ViewModel 只输出 gate、blocked reason、deterministic snapshot 和边界旗标。它不提供
/// risk command、position command、order form、trading button、账户读取或 pre-trade
/// allow / reject runtime。
public struct LiveRiskGateBlockedEvidenceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let contractID: String
    public let issueID: String
    public let items: [LiveRiskGateBlockedEvidenceViewItem]
    public let blockedGateCount: Int
    public let blockedGateLabels: [String]
    public let blockedReasonLabels: [String]
    public let sourceAnchors: [String]
    public let deterministicSnapshot: [String]
    public let allRiskGatesBlocked: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesPersistenceSchema: Bool
    public let readsAdapter: Bool
    public let invokesRuntimeControl: Bool
    public let providesCommandSurface: Bool
    public let providesRiskCommandSurface: Bool
    public let providesPositionManagementCommand: Bool
    public let exposesOrderForm: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveRiskDecision: Bool
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
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let readsRealPnL: Bool
    public let readsRealAccountEquity: Bool
    public let evaluatesRealOrderNotionalLimit: Bool
    public let countsLiveOrderFrequency: Bool
    public let evaluatesRealLossLimit: Bool
    public let evaluatesRealDrawdownLimit: Bool
    public let evaluatesRealPreTradeAllow: Bool
    public let evaluatesRealPreTradeReject: Bool
    public let runsCircuitBreakerRuntime: Bool
    public let entersNoTradeStateRuntime: Bool
    public let mutatesBrokerSessionState: Bool
    public let runsStopTradingCommand: Bool
    public let runsEmergencyStopCommand: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: LiveRiskGateBlockedEvidenceReadModel) {
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
        let providesCommandSurface = evidence.providesCommandSurface
            || items.contains(where: \.emitsCommand)
        let authorizesLiveRiskDecision = items.contains(where: \.authorizesLiveRiskDecision)
            || evidence.evaluatesRealPreTradeAllow
            || evidence.evaluatesRealPreTradeReject
            || evidence.runsCircuitBreakerRuntime
            || evidence.entersNoTradeStateRuntime
        let authorizesLiveTrading = source.providesLiveOrderAction
            || evidence.authorizesLiveTrading
            || authorizesLiveRiskDecision

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
        self.allRiskGatesBlocked = evidence.allRiskGatesBlocked
            && items.allSatisfy(\.isBlocked)
        self.exposesPersistenceSchema = exposesPersistenceSchema
        self.readsAdapter = readsAdapter
        self.invokesRuntimeControl = invokesRuntimeControl
        self.providesCommandSurface = providesCommandSurface
        self.providesRiskCommandSurface = evidence.providesRiskCommandSurface
        self.providesPositionManagementCommand = evidence.providesPositionManagementCommand
        self.exposesOrderForm = evidence.exposesOrderForm
        self.providesTradingButton = evidence.providesTradingButton
        self.authorizesLiveRiskDecision = authorizesLiveRiskDecision
        self.authorizesLiveTrading = authorizesLiveTrading
        self.authorizesTradingExecution = authorizesLiveTrading
        self.readsAPIKey = evidence.readsAPIKey
        self.storesSecret = evidence.storesSecret
        self.usesSignedEndpoint = evidence.usesSignedEndpoint
        self.callsAccountEndpoint = evidence.callsAccountEndpoint
        self.createsListenKey = evidence.createsListenKey
        self.instantiatesBrokerExecutionAdapter = evidence.instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = evidence.instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = evidence.implementsLiveExecutionAdapter
        self.readsRealAccountBalance = evidence.readsRealAccountBalance
        self.syncsBrokerPosition = evidence.syncsBrokerPosition
        self.readsMargin = evidence.readsMargin
        self.readsLeverage = evidence.readsLeverage
        self.readsRealPnL = evidence.readsRealPnL
        self.readsRealAccountEquity = evidence.readsRealAccountEquity
        self.evaluatesRealOrderNotionalLimit = evidence.evaluatesRealOrderNotionalLimit
        self.countsLiveOrderFrequency = evidence.countsLiveOrderFrequency
        self.evaluatesRealLossLimit = evidence.evaluatesRealLossLimit
        self.evaluatesRealDrawdownLimit = evidence.evaluatesRealDrawdownLimit
        self.evaluatesRealPreTradeAllow = evidence.evaluatesRealPreTradeAllow
        self.evaluatesRealPreTradeReject = evidence.evaluatesRealPreTradeReject
        self.runsCircuitBreakerRuntime = evidence.runsCircuitBreakerRuntime
        self.entersNoTradeStateRuntime = evidence.entersNoTradeStateRuntime
        self.mutatesBrokerSessionState = evidence.mutatesBrokerSessionState
        self.runsStopTradingCommand = evidence.runsStopTradingCommand
        self.runsEmergencyStopCommand = evidence.runsEmergencyStopCommand
        self.requiredValidationDependsOnNetwork = evidence.requiredValidationDependsOnNetwork
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && exposesPersistenceSchema == false
            && readsAdapter == false
            && invokesRuntimeControl == false
            && providesCommandSurface == false
            && providesRiskCommandSurface == false
            && providesPositionManagementCommand == false
            && exposesOrderForm == false
            && providesTradingButton == false
            && authorizesLiveRiskDecision == false
            && authorizesLiveTrading == false
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && readsRealAccountBalance == false
            && syncsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && readsRealPnL == false
            && readsRealAccountEquity == false
            && evaluatesRealOrderNotionalLimit == false
            && countsLiveOrderFrequency == false
            && evaluatesRealLossLimit == false
            && evaluatesRealDrawdownLimit == false
            && evaluatesRealPreTradeAllow == false
            && evaluatesRealPreTradeReject == false
            && runsCircuitBreakerRuntime == false
            && entersNoTradeStateRuntime == false
            && mutatesBrokerSessionState == false
            && runsStopTradingCommand == false
            && runsEmergencyStopCommand == false
            && requiredValidationDependsOnNetwork == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element == LiveRiskGateBlockedEvidenceViewItem {
    func sortedByLiveRiskGate() -> [LiveRiskGateBlockedEvidenceViewItem] {
        let gateOrder = Dictionary(
            uniqueKeysWithValues: LiveRiskGateBlockedGate.allCases.enumerated().map {
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
