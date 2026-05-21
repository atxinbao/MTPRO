import Foundation
import Core

/// LiveMonitoringEvidenceReadModel 是 MTP-72 接入 Dashboard / Report 的稳定 App 输入。
///
/// 该 read model 只接收 Core 层 MTP-69 / MTP-70 / MTP-71 已验证的 deterministic evidence，
/// 不启动 live runtime，不读取 Runtime object、adapter request、SQLite / DuckDB schema、API key、
/// secret 或 account payload，也不创建任何 live command / 交易按钮 / stop control。
public struct LiveMonitoringEvidenceReadModel: Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let monitoringEvidence: LiveLatencyErrorDegradedMonitoringEvidenceReadModel
    public let lastAppliedSequence: Int?

    public init(
        source: ViewModelSourceContract = ViewModelSourceContract(),
        monitoringEvidence: LiveLatencyErrorDegradedMonitoringEvidenceReadModel = .deterministicFixture,
        lastAppliedSequence: Int? = nil
    ) {
        self.source = source
        self.monitoringEvidence = monitoringEvidence
        self.lastAppliedSequence = lastAppliedSequence
    }

    public var runtimeHealth: LiveRuntimeHealthReadModel {
        monitoringEvidence.streamEvidence.runtimeHealth
    }

    public var streamEvidence: LiveStreamMonitoringEvidenceReadModel {
        monitoringEvidence.streamEvidence
    }

    public var readModelOnlyBoundaryHeld: Bool {
        source.isReadModelOnly
            && monitoringEvidence.readModelOnlyBoundaryHeld
    }
}

/// LiveMonitoringEvidenceViewModel 是 MTP-72 的 Dashboard / Report 只读展示快照。
///
/// ViewModel 只派生 health、connection、stream、latency、error 和 degraded state 的摘要字段；
/// 它不提供按钮、表单、order-level command、risk command、position command、incident command、
/// reconnect、stop control、production telemetry 或真实交易授权。
public struct LiveMonitoringEvidenceViewModel: Codable, Equatable, Sendable {
    public let source: ViewModelSourceContract
    public let readModelID: String
    public let issueID: String
    public let runtimeHealthStatus: LiveMonitoringStatus
    public let connectionCount: Int
    public let connectionKinds: [String]
    public let connectionStatusLabels: [String]
    public let streamEvidenceCount: Int
    public let marketStreamEvidenceCount: Int
    public let orderStreamEvidenceCount: Int
    public let streamKinds: [String]
    public let streamStatusLabels: [String]
    public let orderStreamEvidenceKindLabels: [String]
    public let latencyEvidenceCount: Int
    public let latencyScopes: [String]
    public let latencyBucketLabels: [String]
    public let errorEvidenceCount: Int
    public let errorCodes: [String]
    public let errorStatusLabels: [String]
    public let degradedStateEvidenceCount: Int
    public let degradedStateScopes: [String]
    public let degradedStateStatusLabels: [String]
    public let degradedStateReasons: [String]
    public let sourceAnchors: [String]
    public let updatedAt: Date
    public let readModelOnlyBoundaryHeld: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesRuntimeObject: Bool
    public let exposesAdapterSurface: Bool
    public let providesCommandSurface: Bool
    public let providesOrderLevelCommand: Bool
    public let providesTradingButton: Bool
    public let providesRiskCommand: Bool
    public let providesPositionCommand: Bool
    public let providesAlertingCommand: Bool
    public let providesPagingCommand: Bool
    public let providesReconnectCommand: Bool
    public let providesStopControl: Bool
    public let providesLiveRiskControl: Bool
    public let triggersIncidentCommand: Bool
    public let triggersAutoRecovery: Bool
    public let usesProductionTelemetry: Bool
    public let usesExternalMetricsService: Bool
    public let opensNetworkConnection: Bool
    public let readsAPIKey: Bool
    public let readsSecret: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let readsAccountPayload: Bool
    public let instantiatesBrokerAdapter: Bool
    public let implementsRealOrderStateMachine: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let lastAppliedSequence: Int?

    public init(readModel: LiveMonitoringEvidenceReadModel) {
        let source = readModel.source
        let monitoring = readModel.monitoringEvidence
        let stream = monitoring.streamEvidence
        let runtimeHealth = stream.runtimeHealth
        let connections = runtimeHealth.connections
        let streamItems = stream.streamEvidence
        let latencyItems = monitoring.latencyEvidence
        let errorItems = monitoring.errorEvidence
        let degradedItems = monitoring.degradedStateEvidence

        let exposesDatabaseSchema = source.exposesDatabaseTables
            || source.exposesORMModels
            || runtimeHealth.exposesSQLiteSchema
            || runtimeHealth.exposesDuckDBSchema
            || stream.exposesSQLiteSchema
            || stream.exposesDuckDBSchema
            || monitoring.exposesSQLiteSchema
            || monitoring.exposesDuckDBSchema
            || connections.contains { $0.exposesSQLiteSchema || $0.exposesDuckDBSchema }
            || streamItems.contains { $0.exposesSQLiteSchema || $0.exposesDuckDBSchema }
        let exposesRuntimeObject = source.exposesRuntimeObjects
            || runtimeHealth.exposesRuntimeObject
            || stream.exposesRuntimeObject
            || monitoring.exposesRuntimeObject
            || connections.contains(where: \.exposesRuntimeObject)
            || streamItems.contains(where: \.exposesRuntimeObject)
        let exposesAdapterSurface = source.callsBinanceAdapter
            || runtimeHealth.exposesAdapterSurface
            || stream.exposesAdapterSurface
            || monitoring.exposesAdapterSurface
            || connections.contains(where: \.exposesAdapterSurface)
            || streamItems.contains(where: \.exposesAdapterSurface)
        let readsAPIKey = runtimeHealth.readsAPIKey
            || stream.readsAPIKey
            || monitoring.readsAPIKey
            || connections.contains(where: \.readsAPIKey)
            || streamItems.contains(where: \.readsAPIKey)
        let readsSecret = runtimeHealth.readsSecret
            || stream.readsSecret
            || monitoring.readsSecret
            || connections.contains(where: \.readsSecret)
            || streamItems.contains(where: \.readsSecret)
        let callsSignedEndpoint = runtimeHealth.callsSignedEndpoint
            || stream.callsSignedEndpoint
            || monitoring.callsSignedEndpoint
            || connections.contains(where: \.callsSignedEndpoint)
            || streamItems.contains(where: \.callsSignedEndpoint)
        let callsAccountEndpoint = runtimeHealth.callsAccountEndpoint
            || stream.callsAccountEndpoint
            || monitoring.callsAccountEndpoint
            || connections.contains(where: \.callsAccountEndpoint)
            || streamItems.contains(where: \.callsAccountEndpoint)
        let createsListenKey = runtimeHealth.createsListenKey
            || stream.createsListenKey
            || monitoring.createsListenKey
            || connections.contains(where: \.createsListenKey)
            || streamItems.contains(where: \.createsListenKey)
        let readsAccountPayload = runtimeHealth.readsAccountPayload
            || stream.readsAccountPayload
            || monitoring.readsAccountPayload
            || connections.contains(where: \.readsAccountPayload)
            || streamItems.contains(where: \.readsAccountPayload)
        let instantiatesBrokerAdapter = runtimeHealth.instantiatesBrokerAdapter
            || stream.instantiatesBrokerAdapter
            || monitoring.instantiatesBrokerAdapter
            || connections.contains(where: \.instantiatesBrokerAdapter)
            || streamItems.contains(where: \.instantiatesBrokerAdapter)
        let implementsRealOrderStateMachine = stream.implementsRealOrderStateMachine
            || streamItems.contains(where: \.implementsRealOrderStateMachine)
        let opensNetworkConnection = runtimeHealth.opensNetworkConnection
            || stream.opensMarketWebSocket
            || stream.opensPrivateUserDataStream
            || monitoring.opensNetworkConnection
            || connections.contains(where: \.hasActiveNetworkConnection)
            || streamItems.contains { $0.hasActiveMarketStream || $0.hasActiveOrderStream }
            || streamItems.contains { $0.opensMarketWebSocket || $0.opensPrivateUserDataStream }
            || latencyItems.contains(where: \.opensNetworkConnection)
        let usesProductionTelemetry = monitoring.usesProductionTelemetry
            || latencyItems.contains(where: \.usesProductionTelemetry)
        let usesExternalMetricsService = monitoring.usesExternalMetricsService
            || latencyItems.contains(where: \.usesExternalMetricsService)
        let providesAlertingCommand = monitoring.providesAlertingCommand
            || latencyItems.contains(where: \.providesAlertingCommand)
            || errorItems.contains(where: \.providesAlertingCommand)
        let providesPagingCommand = monitoring.providesPagingCommand
            || latencyItems.contains(where: \.providesPagingCommand)
            || errorItems.contains(where: \.providesPagingCommand)
        let providesReconnectCommand = monitoring.providesReconnectCommand
            || connections.contains(where: \.providesReconnectCommand)
            || latencyItems.contains(where: \.providesReconnectCommand)
            || errorItems.contains(where: \.providesReconnectCommand)
        let providesStopControl = monitoring.providesStopControl
            || latencyItems.contains(where: \.providesStopControl)
            || errorItems.contains(where: \.providesStopControl)
            || degradedItems.contains(where: \.providesStopControl)
        let providesLiveRiskControl = monitoring.providesLiveRiskControl
            || degradedItems.contains(where: \.providesLiveRiskControl)
        let triggersIncidentCommand = monitoring.triggersIncidentCommand
            || errorItems.contains(where: \.triggersIncidentCommand)
            || degradedItems.contains(where: \.triggersIncidentCommand)
        let triggersAutoRecovery = monitoring.triggersAutoRecovery
            || errorItems.contains(where: \.triggersAutoRecovery)
            || degradedItems.contains(where: \.triggersAutoRecovery)
        let providesOrderLevelCommand = stream.providesOrderCommand
            || stream.submitsRealOrder
            || stream.cancelsRealOrder
            || stream.replacesRealOrder
            || streamItems.contains(where: \.providesOrderCommand)
            || streamItems.contains(where: \.submitsRealOrder)
            || streamItems.contains(where: \.cancelsRealOrder)
            || streamItems.contains(where: \.replacesRealOrder)
        let providesCommandSurface = runtimeHealth.providesCommandSurface
            || stream.providesCommandSurface
            || monitoring.providesCommandSurface
            || providesOrderLevelCommand
            || providesAlertingCommand
            || providesPagingCommand
            || providesReconnectCommand
            || providesStopControl
            || providesLiveRiskControl
            || triggersIncidentCommand
        let authorizesLiveTrading = runtimeHealth.authorizesLiveTrading
            || stream.authorizesLiveTrading
            || monitoring.authorizesLiveTrading
            || connections.contains(where: \.authorizesLiveTrading)
            || streamItems.contains(where: \.authorizesLiveTrading)
            || latencyItems.contains(where: \.authorizesLiveTrading)
            || errorItems.contains(where: \.authorizesLiveTrading)
            || degradedItems.contains(where: \.authorizesLiveTrading)
        let authorizesTradingExecution = source.providesLiveOrderAction
            || runtimeHealth.authorizesTradingExecution
            || stream.authorizesTradingExecution
            || monitoring.authorizesTradingExecution
            || connections.contains(where: \.authorizesTradingExecution)
            || streamItems.contains(where: \.authorizesTradingExecution)
            || latencyItems.contains(where: \.authorizesTradingExecution)
            || errorItems.contains(where: \.authorizesTradingExecution)
            || degradedItems.contains(where: \.authorizesTradingExecution)
        let requiredValidationDependsOnNetwork = runtimeHealth.requiredValidationDependsOnNetwork
            || stream.requiredValidationDependsOnNetwork
            || monitoring.requiredValidationDependsOnNetwork
            || streamItems.contains(where: \.requiredValidationDependsOnNetwork)
            || latencyItems.contains(where: \.requiredValidationDependsOnNetwork)
            || errorItems.contains(where: \.requiredValidationDependsOnNetwork)
        let providesTradingButton = false
        let providesRiskCommand = false
        let providesPositionCommand = false

        self.source = source
        self.readModelID = monitoring.readModelID.rawValue
        self.issueID = monitoring.issueID.rawValue
        self.runtimeHealthStatus = runtimeHealth.status
        self.connectionCount = connections.count
        self.connectionKinds = connections.map(\.connectionKind.rawValue).uniquePreservingOrder()
        self.connectionStatusLabels = connections.map(\.status.rawValue).uniquePreservingOrder()
        self.streamEvidenceCount = streamItems.count
        self.marketStreamEvidenceCount = stream.marketStreamEvidenceCount
        self.orderStreamEvidenceCount = stream.orderStreamEvidenceCount
        self.streamKinds = streamItems.map(\.streamKind.rawValue).uniquePreservingOrder()
        self.streamStatusLabels = streamItems.map(\.status.rawValue).uniquePreservingOrder()
        self.orderStreamEvidenceKindLabels = stream.orderStreamEvidenceKinds
            .map(\.rawValue)
            .uniquePreservingOrder()
        self.latencyEvidenceCount = latencyItems.count
        self.latencyScopes = latencyItems.map(\.scope.rawValue).uniquePreservingOrder()
        self.latencyBucketLabels = monitoring.latencyBuckets
            .map(\.rawValue)
            .uniquePreservingOrder()
        self.errorEvidenceCount = errorItems.count
        self.errorCodes = monitoring.errorCodes.uniquePreservingOrder()
        self.errorStatusLabels = errorItems.map(\.status.rawValue).uniquePreservingOrder()
        self.degradedStateEvidenceCount = degradedItems.count
        self.degradedStateScopes = degradedItems.map(\.scope.rawValue).uniquePreservingOrder()
        self.degradedStateStatusLabels = monitoring.degradedStateStatuses
            .map(\.rawValue)
            .uniquePreservingOrder()
        self.degradedStateReasons = degradedItems.map(\.reason)
        self.sourceAnchors = (
            runtimeHealth.sourceAnchors
                + stream.sourceAnchors
                + monitoring.sourceAnchors
                + connections.flatMap(\.sourceAnchors)
                + streamItems.flatMap(\.sourceAnchors)
                + latencyItems.flatMap(\.sourceAnchors)
                + errorItems.flatMap(\.sourceAnchors)
                + degradedItems.flatMap(\.sourceAnchors)
        ).uniqueSortedStrings()
        self.updatedAt = monitoring.updatedAt
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesAdapterSurface = exposesAdapterSurface
        self.providesCommandSurface = providesCommandSurface
        self.providesOrderLevelCommand = providesOrderLevelCommand
        self.providesTradingButton = providesTradingButton
        self.providesRiskCommand = providesRiskCommand
        self.providesPositionCommand = providesPositionCommand
        self.providesAlertingCommand = providesAlertingCommand
        self.providesPagingCommand = providesPagingCommand
        self.providesReconnectCommand = providesReconnectCommand
        self.providesStopControl = providesStopControl
        self.providesLiveRiskControl = providesLiveRiskControl
        self.triggersIncidentCommand = triggersIncidentCommand
        self.triggersAutoRecovery = triggersAutoRecovery
        self.usesProductionTelemetry = usesProductionTelemetry
        self.usesExternalMetricsService = usesExternalMetricsService
        self.opensNetworkConnection = opensNetworkConnection
        self.readsAPIKey = readsAPIKey
        self.readsSecret = readsSecret
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.readsAccountPayload = readsAccountPayload
        self.instantiatesBrokerAdapter = instantiatesBrokerAdapter
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.authorizesLiveTrading = authorizesLiveTrading
        self.authorizesTradingExecution = authorizesTradingExecution
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.readModelOnlyBoundaryHeld = readModel.readModelOnlyBoundaryHeld
            && exposesDatabaseSchema == false
            && exposesRuntimeObject == false
            && exposesAdapterSurface == false
            && providesCommandSurface == false
            && providesOrderLevelCommand == false
            && providesTradingButton == false
            && providesRiskCommand == false
            && providesPositionCommand == false
            && providesAlertingCommand == false
            && providesPagingCommand == false
            && providesReconnectCommand == false
            && providesStopControl == false
            && providesLiveRiskControl == false
            && triggersIncidentCommand == false
            && triggersAutoRecovery == false
            && usesProductionTelemetry == false
            && usesExternalMetricsService == false
            && opensNetworkConnection == false
            && readsAPIKey == false
            && readsSecret == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && readsAccountPayload == false
            && instantiatesBrokerAdapter == false
            && implementsRealOrderStateMachine == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
        self.lastAppliedSequence = readModel.lastAppliedSequence
    }
}

private extension Array where Element == String {
    func uniqueSortedStrings() -> [String] {
        Array(Set(self)).sorted()
    }

    func uniquePreservingOrder() -> [String] {
        var seen = Set<String>()
        var values: [String] = []
        for value in self where seen.insert(value).inserted {
            values.append(value)
        }
        return values
    }
}
