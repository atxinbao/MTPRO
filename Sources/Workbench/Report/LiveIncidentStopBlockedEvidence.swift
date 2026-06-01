import Foundation
import Core

/// LiveIncidentStopBlockedEvidenceViewItem 是 App 层可展示的单项 audit / incident / stop 阻断证据。
///
/// 该类型只复制 Core `LiveIncidentStopBlockedEvidenceItem` 的 gate、reason 和只读边界旗标；
/// 它不携带 stop command、restore decision、Runtime object、adapter request、broker payload、
/// Live PRO Console 状态或任何可以触发生产停机 / 恢复的控制能力。
public struct LiveIncidentStopBlockedEvidenceViewItem: Codable, Equatable, Sendable {
    public let evidenceID: String
    public let gate: LiveIncidentStopBlockedGate
    public let blockedReasons: [LiveIncidentStopBlockedReason]
    public let blockedReasonLabels: [String]
    public let sourceAnchors: [String]
    public let isBlocked: Bool
    public let emitsCommand: Bool
    public let exposesSchema: Bool
    public let readsAdapter: Bool
    public let invokesRuntimeControl: Bool
    public let authorizesIncidentStopControl: Bool

    public init(item: Core.LiveIncidentStopBlockedEvidenceItem) {
        self.evidenceID = "mtp-94-\(item.gate.rawValue.slugID())-blocked"
        self.gate = item.gate
        self.blockedReasons = item.blockedReasons
        self.blockedReasonLabels = item.blockedReasons.map(\.rawValue)
        self.sourceAnchors = item.sourceAnchors
        self.isBlocked = item.isBlocked
        self.emitsCommand = item.emitsCommand
        self.exposesSchema = item.exposesSchema
        self.readsAdapter = item.readsAdapter
        self.invokesRuntimeControl = item.invokesRuntimeControl
        self.authorizesIncidentStopControl = item.authorizesIncidentStopControl
    }

    /// boundaryHeld 汇总单项 gate 的只读阻断边界，确保展示不会反向变成停机 / 恢复控制入口。
    public var boundaryHeld: Bool {
        isBlocked
            && emitsCommand == false
            && exposesSchema == false
            && readsAdapter == false
            && invokesRuntimeControl == false
            && authorizesIncidentStopControl == false
    }
}

/// LiveIncidentStopBlockedEvidenceReadModel 汇总 MTP-94 可接入 App 的 incident / stop blocked evidence。
///
/// 输入只能来自 Core `LiveIncidentStopBlockedEvidence` deterministic fixture 或等价只读模型。
/// App 只做排序、计数和 ViewModel 派生，不读取 secret、signed/account endpoint、broker、
/// Runtime、Persistence，也不生成 incident replay、stop、shutdown 或 restore command。
public struct LiveIncidentStopBlockedEvidenceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let evidence: Core.LiveIncidentStopBlockedEvidence
    public let items: [LiveIncidentStopBlockedEvidenceViewItem]
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        evidence: Core.LiveIncidentStopBlockedEvidence = .deterministicFixture,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.evidence = evidence
        self.items = evidence.blockedItems
            .map(LiveIncidentStopBlockedEvidenceViewItem.init)
            .sortedByIncidentStopGate()
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && evidence.blockedEvidenceBoundaryHeld
            && items.allSatisfy(\.boundaryHeld)
    }
}

/// LiveIncidentStopBlockedEvidenceViewModel 是 Dashboard / Report / Event Timeline 的只读阻断快照。
///
/// ViewModel 只输出 blocked gate、blocked reason、source anchor、deterministic snapshot 和禁区旗标。
/// 它不提供 Live PRO Console、stop button、trading button、incident replay runtime、emergency stop、
/// shutdown、restore、production operations 或 live command。
public struct LiveIncidentStopBlockedEvidenceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let contractID: String
    public let issueID: String
    public let items: [LiveIncidentStopBlockedEvidenceViewItem]
    public let blockedGateCount: Int
    public let blockedGateLabels: [String]
    public let blockedReasonLabels: [String]
    public let sourceAnchors: [String]
    public let deterministicSnapshot: [String]
    public let allIncidentStopGatesBlocked: Bool
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesPersistenceSchema: Bool
    public let readsAdapter: Bool
    public let invokesRuntimeControl: Bool
    public let providesCommandSurface: Bool
    public let providesIncidentReplay: Bool
    public let providesStopControl: Bool
    public let providesEmergencyStopCommand: Bool
    public let providesShutdownCommand: Bool
    public let providesRestoreCommand: Bool
    public let exposesLiveProConsole: Bool
    public let providesStopButton: Bool
    public let providesTradingButton: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let executesBrokerAction: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderStateMachine: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool
    public let runsAuditTrailRuntime: Bool
    public let runsIncidentReplayRuntime: Bool
    public let runsProductionOperations: Bool
    public let mutatesBrokerSessionState: Bool
    public let resumesLiveRuntime: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: LiveIncidentStopBlockedEvidenceReadModel) {
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
        let authorizesIncidentStopControl = items.contains(where: \.authorizesIncidentStopControl)
            || evidence.providesIncidentReplay
            || evidence.providesStopControl
            || evidence.providesEmergencyStopCommand
            || evidence.providesShutdownCommand
            || evidence.providesRestoreCommand
            || evidence.runsAuditTrailRuntime
            || evidence.runsIncidentReplayRuntime
            || evidence.runsProductionOperations
            || evidence.mutatesBrokerSessionState
            || evidence.resumesLiveRuntime
        let authorizesLiveTrading = source.providesLiveOrderAction
            || evidence.authorizesLiveTrading
            || authorizesIncidentStopControl

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
        self.allIncidentStopGatesBlocked = evidence.allIncidentStopGatesBlocked
            && items.allSatisfy(\.isBlocked)
        self.exposesPersistenceSchema = exposesPersistenceSchema
        self.readsAdapter = readsAdapter
        self.invokesRuntimeControl = invokesRuntimeControl
        self.providesCommandSurface = providesCommandSurface
        self.providesIncidentReplay = evidence.providesIncidentReplay
        self.providesStopControl = evidence.providesStopControl
        self.providesEmergencyStopCommand = evidence.providesEmergencyStopCommand
        self.providesShutdownCommand = evidence.providesShutdownCommand
        self.providesRestoreCommand = evidence.providesRestoreCommand
        self.exposesLiveProConsole = evidence.exposesLiveProConsole
        self.providesStopButton = evidence.providesStopButton
        self.providesTradingButton = evidence.providesTradingButton
        self.authorizesLiveTrading = authorizesLiveTrading
        self.authorizesTradingExecution = authorizesLiveTrading
        self.readsAPIKey = evidence.readsAPIKey
        self.storesSecret = evidence.storesSecret
        self.usesSignedEndpoint = evidence.usesSignedEndpoint
        self.callsAccountEndpoint = evidence.callsAccountEndpoint
        self.createsListenKey = evidence.createsListenKey
        self.executesBrokerAction = evidence.executesBrokerAction
        self.implementsLiveExecutionAdapter = evidence.implementsLiveExecutionAdapter
        self.implementsOMS = evidence.implementsOMS
        self.implementsRealOrderStateMachine = evidence.implementsRealOrderStateMachine
        self.consumesExecutionReport = evidence.consumesExecutionReport
        self.recordsBrokerFill = evidence.recordsBrokerFill
        self.performsReconciliation = evidence.performsReconciliation
        self.runsAuditTrailRuntime = evidence.runsAuditTrailRuntime
        self.runsIncidentReplayRuntime = evidence.runsIncidentReplayRuntime
        self.runsProductionOperations = evidence.runsProductionOperations
        self.mutatesBrokerSessionState = evidence.mutatesBrokerSessionState
        self.resumesLiveRuntime = evidence.resumesLiveRuntime
        self.requiredValidationDependsOnNetwork = evidence.requiredValidationDependsOnNetwork
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && exposesPersistenceSchema == false
            && readsAdapter == false
            && invokesRuntimeControl == false
            && providesCommandSurface == false
            && providesIncidentReplay == false
            && providesStopControl == false
            && providesEmergencyStopCommand == false
            && providesShutdownCommand == false
            && providesRestoreCommand == false
            && exposesLiveProConsole == false
            && providesStopButton == false
            && providesTradingButton == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && executesBrokerAction == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderStateMachine == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
            && runsAuditTrailRuntime == false
            && runsIncidentReplayRuntime == false
            && runsProductionOperations == false
            && mutatesBrokerSessionState == false
            && resumesLiveRuntime == false
            && requiredValidationDependsOnNetwork == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element == LiveIncidentStopBlockedEvidenceViewItem {
    func sortedByIncidentStopGate() -> [LiveIncidentStopBlockedEvidenceViewItem] {
        let gateOrder = Dictionary(
            uniqueKeysWithValues: LiveIncidentStopBlockedGate.allCases.enumerated().map {
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
