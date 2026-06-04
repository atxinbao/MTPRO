import Core
import Foundation

/// LiveMonitoringReadOnlyConsoleV2TraceItem 是 MTP-152 的 Workbench / Events 只读行。
///
/// Trace item 只保存 MTP-148 至 MTP-151 已完成合同中的 evidence identity、surface 和摘要；
/// 它不携带 endpoint URL、listenKey、account payload、broker state、Runtime object、adapter request、
/// order form、trading button 或任何可执行 live command。
public struct LiveMonitoringReadOnlyConsoleV2TraceItem: Codable, Equatable, Sendable {
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

/// LiveMonitoringReadOnlyConsoleV2SurfaceReadModel 是 MTP-152 的 App 层只读输入。
///
/// 该 read model 只组合 MTP-148 source identity、MTP-149 simulation gate health、
/// MTP-150 connection readiness explanation 和 MTP-151 forbidden capability tests。
/// 它不读取真实账户、不连接 private stream、不访问 Persistence schema、不调用 Runtime / Adapter，
/// 也不创建 Live PRO Console、trading button、live command 或 order form。
public struct LiveMonitoringReadOnlyConsoleV2SurfaceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let sourceIdentity: LiveMonitoringSourceIdentityContract
    public let simulationGateHealth: LiveMonitoringSimulationGateHealthContract
    public let connectionReadiness: LiveMonitoringConnectionReadinessExplanationContract
    public let forbiddenCapabilityTests: LiveMonitoringForbiddenCapabilityTestContract
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        sourceIdentity: LiveMonitoringSourceIdentityContract = .deterministicFixture,
        simulationGateHealth: LiveMonitoringSimulationGateHealthContract = .deterministicFixture,
        connectionReadiness: LiveMonitoringConnectionReadinessExplanationContract = .deterministicFixture,
        forbiddenCapabilityTests: LiveMonitoringForbiddenCapabilityTestContract = .deterministicFixture,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.sourceIdentity = sourceIdentity
        self.simulationGateHealth = simulationGateHealth
        self.connectionReadiness = connectionReadiness
        self.forbiddenCapabilityTests = forbiddenCapabilityTests
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && sourceIdentity.sourceIdentityBoundaryHeld
            && simulationGateHealth.simulationGateHealthBoundaryHeld
            && connectionReadiness.connectionReadinessExplanationBoundaryHeld
            && forbiddenCapabilityTests.forbiddenCapabilityTestBoundaryHeld
    }
}

/// LiveMonitoringReadOnlyConsoleV2SurfaceViewModel 是 MTP-152 的 Report / Workbench / Events 快照。
///
/// ViewModel 只输出 monitoring source identity、freshness、blocked / stale / missing explanation、
/// forbidden capability coverage 和 event trace。所有 capability flags 必须保持 false，以证明
/// Workbench / Report / Events 只消费 Read Model / ViewModel，不暴露 Runtime、Adapter、schema、
/// account payload、broker state 或任何 live command。
public struct LiveMonitoringReadOnlyConsoleV2SurfaceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let issueID: String
    public let matrixID: String
    public let sourceIdentityChecksum: String
    public let simulationGateHealthChecksum: String
    public let connectionReadinessChecksum: String
    public let forbiddenCapabilityChecksum: String
    public let sourceIdentities: [String]
    public let sourceLayerLabels: [String]
    public let sourceStatusLabels: [String]
    public let sourceFreshnessLabels: [String]
    public let sourceEvidenceOrigins: [String]
    public let healthEvidenceIDs: [String]
    public let healthStatusLabels: [String]
    public let freshnessStatusLabels: [String]
    public let freshnessExplanationLabels: [String]
    public let readinessEvidenceIDs: [String]
    public let readinessStateLabels: [String]
    public let readinessDisplaySemantics: [String]
    public let readinessExplanations: [String]
    public let blockedExplanationIDs: [String]
    public let staleExplanationIDs: [String]
    public let missingExplanationIDs: [String]
    public let forbiddenTestIDs: [String]
    public let forbiddenTestDomainLabels: [String]
    public let forbiddenAssertionLabels: [String]
    public let sourceIdentityRecordCount: Int
    public let healthEvidenceCount: Int
    public let readinessExplanationCount: Int
    public let forbiddenTestCaseCount: Int
    public let reportSummary: String
    public let dashboardPanelSummaries: [String]
    public let eventTraceItems: [LiveMonitoringReadOnlyConsoleV2TraceItem]
    public let eventTraceItemCount: Int
    public let consumesOnlyReadModelViewModel: Bool
    public let readModelOnlyBoundaryHeld: Bool
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
    public let opensPrivateWebSocket: Bool
    public let runsPrivateStreamRuntime: Bool
    public let runsAccountSnapshotRuntime: Bool
    public let createsConnectionManager: Bool
    public let opensRuntimeConnection: Bool
    public let implementsLiveReadiness: Bool
    public let runsLiveMonitoringRuntime: Bool
    public let connectsBroker: Bool
    public let connectsExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let readsRealAccount: Bool
    public let readsRealPosition: Bool
    public let readsRealBalance: Bool
    public let readsRealPnL: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: LiveMonitoringReadOnlyConsoleV2SurfaceReadModel) {
        let sourceIdentity = readModel.sourceIdentity
        let simulationGateHealth = readModel.simulationGateHealth
        let connectionReadiness = readModel.connectionReadiness
        let forbiddenCapabilityTests = readModel.forbiddenCapabilityTests
        let sourceRecords = sourceIdentity.sourceRecords
        let healthItems = simulationGateHealth.healthEvidenceItems
        let readinessItems = connectionReadiness.explanationItems
        let forbiddenCases = forbiddenCapabilityTests.testCases

        let sourceIdentities = sourceRecords.map(\.sourceIdentity)
        let sourceLayerLabels = sourceRecords.map { $0.layer.rawValue }
        let sourceStatusLabels = sourceRecords.map { $0.sourceStatus.rawValue }.uniquePreservingOrder()
        let sourceFreshnessLabels = sourceRecords.map { $0.freshnessSemantics.rawValue }
            .uniquePreservingOrder()
        let sourceEvidenceOrigins = sourceRecords
            .flatMap { $0.evidenceOrigins.map(\.rawValue) }
            .uniquePreservingOrder()
        let healthStatusLabels = healthItems.map { $0.healthStatus.rawValue }
        let freshnessStatusLabels = healthItems.map { $0.freshnessStatus.rawValue }
        let freshnessExplanationLabels = healthItems.map { $0.freshnessExplanation.rawValue }
        let readinessStateLabels = readinessItems.map { $0.readinessState.rawValue }
        let readinessDisplaySemantics = readinessItems.map { $0.displaySemantics.rawValue }
        let readinessExplanations = readinessItems.map(\.explanation)
        let blockedExplanationIDs = readinessItems
            .filter { $0.readinessState == .blocked }
            .map(\.evidenceID)
        let staleExplanationIDs = readinessItems
            .filter { $0.readinessState == .stale }
            .map(\.evidenceID)
        let missingExplanationIDs = readinessItems
            .filter { $0.readinessState == .missing }
            .map(\.evidenceID)
        let forbiddenTestIDs = forbiddenCases.map(\.testID)
        let forbiddenTestDomainLabels = forbiddenCases.map { $0.domain.rawValue }
            .uniquePreservingOrder()
        let forbiddenAssertionLabels = forbiddenCases.map { $0.assertion.rawValue }

        let reportSummary = [
            "Live Monitoring Read-only Console v2 surface",
            "sources=\(sourceRecords.count)",
            "health=\(healthStatusLabels.joined(separator: "+"))",
            "readiness=\(readinessStateLabels.joined(separator: "+"))",
            "forbiddenTests=\(forbiddenCases.count)",
            "checksum=\(connectionReadiness.checksum)"
        ].joined(separator: "; ")
        let dashboardPanelSummaries = [
            "Source identity: \(sourceLayerLabels.joined(separator: "+"))",
            "Freshness: \(freshnessStatusLabels.joined(separator: "+"))",
            "Readiness explanations: \(readinessStateLabels.joined(separator: "+"))",
            "Blocked / stale / missing: \(blockedExplanationIDs.count)/\(staleExplanationIDs.count)/\(missingExplanationIDs.count)",
            "Forbidden capability tests: \(forbiddenCases.count)"
        ]
        let eventTraceItems = [
            LiveMonitoringReadOnlyConsoleV2TraceItem(
                traceID: "mtp-152-source-identity",
                surface: "live monitoring v2 source identity read-model-only",
                title: "Live Monitoring v2 source identity evidence",
                summary: "sources=\(sourceIdentities.joined(separator: "+")); statuses=\(sourceStatusLabels.joined(separator: "+"))",
                evidenceID: sourceIdentity.contractID.rawValue,
                sourceAnchor: "MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE"
            ),
            LiveMonitoringReadOnlyConsoleV2TraceItem(
                traceID: "mtp-152-simulation-gate-health",
                surface: "live monitoring v2 simulation gate health read-model-only",
                title: "Live Monitoring v2 simulation gate health evidence",
                summary: "health=\(healthStatusLabels.joined(separator: "+")); freshness=\(freshnessStatusLabels.joined(separator: "+"))",
                evidenceID: simulationGateHealth.contractID.rawValue,
                sourceAnchor: "MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE"
            ),
            LiveMonitoringReadOnlyConsoleV2TraceItem(
                traceID: "mtp-152-connection-readiness",
                surface: "live monitoring v2 connection readiness explanation read-model-only",
                title: "Live Monitoring v2 readiness / stale / blocked / missing evidence",
                summary: "readiness=\(readinessStateLabels.joined(separator: "+")); explanations=\(readinessItems.count)",
                evidenceID: connectionReadiness.contractID.rawValue,
                sourceAnchor: "MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE"
            ),
            LiveMonitoringReadOnlyConsoleV2TraceItem(
                traceID: "mtp-152-forbidden-capability-tests",
                surface: "live monitoring v2 forbidden capability coverage read-model-only",
                title: "Live Monitoring v2 forbidden endpoint runtime broker UI command tests",
                summary: "domains=\(forbiddenTestDomainLabels.joined(separator: "+")); testCases=\(forbiddenCases.count)",
                evidenceID: forbiddenCapabilityTests.contractID.rawValue,
                sourceAnchor: "MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE"
            )
        ]

        let exposesLivePROConsole = forbiddenCapabilityTests.exposesLivePROConsole
        let providesTradingButton = sourceIdentity.exposesTradingButton
            || simulationGateHealth.exposesTradingButton
            || connectionReadiness.exposesTradingButton
            || forbiddenCapabilityTests.exposesTradingButton
        let providesLiveCommand = sourceIdentity.exposesLiveCommand
            || simulationGateHealth.exposesLiveCommand
            || connectionReadiness.exposesLiveCommand
            || forbiddenCapabilityTests.exposesLiveCommand
        let exposesOrderForm = sourceIdentity.exposesOrderForm
            || simulationGateHealth.exposesOrderForm
            || connectionReadiness.exposesOrderForm
            || forbiddenCapabilityTests.exposesOrderForm
        let exposesRuntimeObject = sourceIdentity.exposesRuntimeObject
            || simulationGateHealth.exposesRuntimeObject
            || connectionReadiness.exposesRuntimeObject
        let exposesDatabaseSchema = sourceIdentity.exposesDatabaseSchema
            || simulationGateHealth.exposesPersistenceSchema
            || connectionReadiness.exposesPersistenceSchema
        let exposesAdapterRequest = sourceIdentity.exposesAdapterRequest
            || simulationGateHealth.exposesAdapterRequest
            || connectionReadiness.exposesAdapterRequest
        let exposesAccountPayload = sourceIdentity.exposesAccountPayload
            || simulationGateHealth.exposesAccountPayload
            || connectionReadiness.exposesAccountPayload
        let exposesBrokerState = sourceIdentity.exposesBrokerState
            || simulationGateHealth.exposesBrokerState
            || connectionReadiness.exposesBrokerState
        let callsSignedEndpoint = sourceIdentity.callsSignedEndpoint
            || simulationGateHealth.callsSignedEndpoint
            || connectionReadiness.callsSignedEndpoint
            || forbiddenCapabilityTests.callsSignedEndpoint
        let callsAccountEndpoint = sourceIdentity.callsAccountEndpoint
            || simulationGateHealth.callsAccountEndpoint
            || connectionReadiness.callsAccountEndpoint
            || forbiddenCapabilityTests.callsAccountEndpoint
        let createsListenKey = sourceIdentity.createsListenKey
            || simulationGateHealth.createsListenKey
            || connectionReadiness.createsListenKey
            || forbiddenCapabilityTests.createsListenKey
        let opensPrivateWebSocket = sourceIdentity.opensPrivateWebSocket
            || simulationGateHealth.opensPrivateWebSocket
            || connectionReadiness.opensPrivateWebSocket
            || forbiddenCapabilityTests.opensPrivateWebSocket
        let runsPrivateStreamRuntime = sourceIdentity.runsPrivateStreamRuntime
            || simulationGateHealth.runsPrivateStreamRuntime
            || connectionReadiness.runsPrivateStreamRuntime
            || forbiddenCapabilityTests.runsPrivateStreamRuntime
        let runsAccountSnapshotRuntime = sourceIdentity.runsAccountSnapshotRuntime
            || simulationGateHealth.runsAccountSnapshotRuntime
            || connectionReadiness.runsAccountSnapshotRuntime
            || forbiddenCapabilityTests.runsAccountSnapshotRuntime
        let createsConnectionManager = connectionReadiness.createsConnectionManager
            || forbiddenCapabilityTests.createsConnectionManager
        let opensRuntimeConnection = connectionReadiness.opensRuntimeConnection
            || forbiddenCapabilityTests.opensRuntimeConnection
        let implementsLiveReadiness = connectionReadiness.implementsLiveReadiness
            || forbiddenCapabilityTests.implementsLiveReadiness
        let runsLiveMonitoringRuntime = connectionReadiness.runsLiveMonitoringRuntime
            || forbiddenCapabilityTests.runsLiveMonitoringRuntime
        let connectsBroker = sourceIdentity.connectsBrokerAdapter
            || simulationGateHealth.connectsBrokerAdapter
            || connectionReadiness.connectsBrokerAdapter
            || forbiddenCapabilityTests.connectsBrokerAdapter
        let connectsExchangeExecutionAdapter = sourceIdentity.connectsExchangeExecutionAdapter
            || simulationGateHealth.connectsExchangeExecutionAdapter
            || connectionReadiness.connectsExchangeExecutionAdapter
            || forbiddenCapabilityTests.connectsExchangeExecutionAdapter
        let implementsLiveExecutionAdapter = sourceIdentity.implementsLiveExecutionAdapter
            || simulationGateHealth.implementsLiveExecutionAdapter
            || connectionReadiness.implementsLiveExecutionAdapter
            || forbiddenCapabilityTests.implementsLiveExecutionAdapter
        let implementsOMS = sourceIdentity.implementsOMS
            || simulationGateHealth.implementsOMS
            || connectionReadiness.implementsOMS
            || forbiddenCapabilityTests.implementsOMS
        let readsRealAccount = sourceIdentity.readsRealAccount
            || simulationGateHealth.readsRealAccount
            || connectionReadiness.readsRealAccount
            || forbiddenCapabilityTests.readsRealAccount
        let readsRealPosition = sourceIdentity.readsRealPosition
            || simulationGateHealth.readsRealPosition
            || connectionReadiness.readsRealPosition
        let readsRealBalance = sourceIdentity.readsRealBalance
            || simulationGateHealth.readsRealBalance
            || connectionReadiness.readsRealBalance
        let providesOrderLevelCommand = connectionReadiness.writesRealOrder
            || simulationGateHealth.writesRealOrder
            || forbiddenCapabilityTests.exposesOrderForm
        let providesCommandSurface = providesOrderLevelCommand
            || providesTradingButton
            || providesLiveCommand
            || exposesOrderForm
            || exposesLivePROConsole
        let authorizesLiveTrading = providesCommandSurface
            || connectsBroker
            || implementsLiveExecutionAdapter
            || implementsOMS
        let authorizesTradingExecution = authorizesLiveTrading
            || providesOrderLevelCommand

        self.source = readModel.source
        self.issueID = "MTP-152"
        self.matrixID = LiveMonitoringSourceIdentityContract.requiredMatrixID
        self.sourceIdentityChecksum = sourceIdentity.checksum
        self.simulationGateHealthChecksum = simulationGateHealth.checksum
        self.connectionReadinessChecksum = connectionReadiness.checksum
        self.forbiddenCapabilityChecksum = forbiddenCapabilityTests.checksum
        self.sourceIdentities = sourceIdentities
        self.sourceLayerLabels = sourceLayerLabels
        self.sourceStatusLabels = sourceStatusLabels
        self.sourceFreshnessLabels = sourceFreshnessLabels
        self.sourceEvidenceOrigins = sourceEvidenceOrigins
        self.healthEvidenceIDs = healthItems.map(\.evidenceID)
        self.healthStatusLabels = healthStatusLabels
        self.freshnessStatusLabels = freshnessStatusLabels
        self.freshnessExplanationLabels = freshnessExplanationLabels
        self.readinessEvidenceIDs = readinessItems.map(\.evidenceID)
        self.readinessStateLabels = readinessStateLabels
        self.readinessDisplaySemantics = readinessDisplaySemantics
        self.readinessExplanations = readinessExplanations
        self.blockedExplanationIDs = blockedExplanationIDs
        self.staleExplanationIDs = staleExplanationIDs
        self.missingExplanationIDs = missingExplanationIDs
        self.forbiddenTestIDs = forbiddenTestIDs
        self.forbiddenTestDomainLabels = forbiddenTestDomainLabels
        self.forbiddenAssertionLabels = forbiddenAssertionLabels
        self.sourceIdentityRecordCount = sourceRecords.count
        self.healthEvidenceCount = healthItems.count
        self.readinessExplanationCount = readinessItems.count
        self.forbiddenTestCaseCount = forbiddenCases.count
        self.reportSummary = reportSummary
        self.dashboardPanelSummaries = dashboardPanelSummaries
        self.eventTraceItems = eventTraceItems
        self.eventTraceItemCount = eventTraceItems.count
        self.consumesOnlyReadModelViewModel = true
        self.exposesLivePROConsole = exposesLivePROConsole
        self.providesTradingButton = providesTradingButton
        self.providesLiveCommand = providesLiveCommand
        self.exposesOrderForm = exposesOrderForm
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesAdapterRequest = exposesAdapterRequest
        self.exposesAccountPayload = exposesAccountPayload
        self.exposesBrokerState = exposesBrokerState
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.runsPrivateStreamRuntime = runsPrivateStreamRuntime
        self.runsAccountSnapshotRuntime = runsAccountSnapshotRuntime
        self.createsConnectionManager = createsConnectionManager
        self.opensRuntimeConnection = opensRuntimeConnection
        self.implementsLiveReadiness = implementsLiveReadiness
        self.runsLiveMonitoringRuntime = runsLiveMonitoringRuntime
        self.connectsBroker = connectsBroker
        self.connectsExchangeExecutionAdapter = connectsExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.readsRealAccount = readsRealAccount
        self.readsRealPosition = readsRealPosition
        self.readsRealBalance = readsRealBalance
        self.readsRealPnL = false
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.authorizesLiveTrading = authorizesLiveTrading
        self.authorizesTradingExecution = authorizesTradingExecution
        self.requiredValidationDependsOnNetwork = false
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && consumesOnlyReadModelViewModel
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
            && opensPrivateWebSocket == false
            && runsPrivateStreamRuntime == false
            && runsAccountSnapshotRuntime == false
            && createsConnectionManager == false
            && opensRuntimeConnection == false
            && implementsLiveReadiness == false
            && runsLiveMonitoringRuntime == false
            && connectsBroker == false
            && connectsExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && readsRealAccount == false
            && readsRealPosition == false
            && readsRealBalance == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}
