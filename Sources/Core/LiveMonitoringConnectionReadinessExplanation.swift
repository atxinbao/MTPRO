import DomainModel
import Foundation

/// LiveMonitoringConnectionReadinessExplanationState 固定 MTP-150 可以展示的 readiness 解释状态。
///
/// 这些状态只解释 MTP-148 source identity 与 MTP-149 health evidence 的只读含义。
/// 它们不是连接状态机，不表示真实连接已建立，也不会触发 endpoint、listenKey、broker 或交易命令。
public enum LiveMonitoringConnectionReadinessExplanationState:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case readiness = "readiness explanation from simulated evidence"
    case stale = "stale explanation from simulated evidence"
    case blocked = "blocked explanation from boundary evidence"
    case missing = "missing explanation from absent evidence"
}

/// LiveMonitoringConnectionReadinessDisplaySemantics 固定 Workbench / Report 可使用的展示语义。
///
/// 展示语义只给 MTP-152 的 read-model-only surface 提供稳定输入；它不暴露 Runtime object、
/// Adapter request、SQLite / DuckDB schema、account payload 或 broker state。
public enum LiveMonitoringConnectionReadinessDisplaySemantics:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case readinessReadOnly = "display readiness explanation as read-only simulated evidence"
    case staleReadOnly = "display stale explanation as read-only simulated evidence"
    case blockedReadOnly = "display blocked explanation as boundary-held evidence"
    case missingReadOnly = "display missing explanation as absent evidence"
}

/// LiveMonitoringConnectionReadinessForbiddenCapability 列出 MTP-150 必须拒绝的越界能力。
///
/// 这些禁止项只作为合同和 focused tests 的证据。MTP-150 不实现 connection manager、runtime、
/// endpoint、private stream、broker adapter、Live PRO Console 或任何 live command。
public enum LiveMonitoringConnectionReadinessForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case signedEndpointCall = "signed endpoint call"
    case accountEndpointCall = "account endpoint call"
    case listenKeyCreation = "listenKey creation"
    case privateWebSocketRuntime = "private WebSocket runtime"
    case privateStreamRuntime = "private stream runtime"
    case accountSnapshotRuntime = "account snapshot runtime"
    case connectionManagerImplementation = "connection manager implementation"
    case runtimeConnectionOpening = "runtime connection opening"
    case liveReadinessImplementation = "live readiness implementation"
    case liveMonitoringRuntime = "Live Monitoring runtime"
    case realAccountRead = "real account read"
    case realPositionRead = "real position read"
    case realBalanceRead = "real balance read"
    case realAccountPayloadConsumption = "real account payload consumption"
    case accountPayloadExposure = "account payload exposure"
    case brokerStateExposure = "broker state exposure"
    case adapterRequestExposure = "adapter request exposure"
    case runtimeObjectExposure = "Runtime object exposure"
    case persistenceSchemaExposure = "SQLite / DuckDB schema exposure"
    case brokerAdapterConnection = "broker adapter connection"
    case exchangeExecutionAdapterConnection = "exchange execution adapter connection"
    case liveExecutionAdapterImplementation = "LiveExecutionAdapter implementation"
    case omsImplementation = "OMS implementation"
    case liveCommandExposure = "live command exposure"
    case tradingButtonExposure = "trading button exposure"
    case orderFormExposure = "order form exposure"
    case realOrderWrite = "real order write"
}

/// LiveMonitoringConnectionReadinessExplanationItem 是 MTP-150 的单条 readiness explanation evidence。
///
/// Item 只把 MTP-149 health status 映射成 Workbench / Report 可展示的解释文案和状态。
/// 它不保存或生成 endpoint、listenKey、private stream、broker、真实账户 payload 或任何连接对象。
public struct LiveMonitoringConnectionReadinessExplanationItem: Codable, Equatable, Sendable {
    public let healthStatus: LiveMonitoringSimulationGateHealthStatus
    public let readinessState: LiveMonitoringConnectionReadinessExplanationState
    public let evidenceID: String
    public let healthEvidenceID: String
    public let healthEvidenceChecksum: String
    public let sourceIdentityChecksum: String
    public let explanation: String
    public let displaySemantics: LiveMonitoringConnectionReadinessDisplaySemantics
    public let reportSemantics: String
    public let boundarySemantics: String
    public let readModelFields: [String]

    public var canonicalLine: String {
        [
            healthStatus.rawValue,
            readinessState.rawValue,
            evidenceID,
            healthEvidenceID,
            healthEvidenceChecksum,
            sourceIdentityChecksum,
            explanation,
            displaySemantics.rawValue,
            reportSemantics,
            boundarySemantics,
            readModelFields.joined(separator: "+")
        ].joined(separator: "|")
    }

    public var connectionReadinessExplanationBoundaryHeld: Bool {
        self == Self.requiredItem(for: healthStatus)
            && containsForbiddenExposureText(Self.forbiddenExposureFieldTokens) == false
    }

    public var derivedFromSimulationGateHealth: Bool {
        healthEvidenceID == Self.requiredHealthEvidenceID(for: healthStatus)
            && healthEvidenceChecksum == Self.requiredHealthEvidenceChecksum
            && sourceIdentityChecksum == Self.requiredSourceIdentityChecksum
    }

    public init(
        healthStatus: LiveMonitoringSimulationGateHealthStatus,
        readinessState: LiveMonitoringConnectionReadinessExplanationState? = nil,
        evidenceID: String? = nil,
        healthEvidenceID: String? = nil,
        healthEvidenceChecksum: String = Self.requiredHealthEvidenceChecksum,
        sourceIdentityChecksum: String = Self.requiredSourceIdentityChecksum,
        explanation: String? = nil,
        displaySemantics: LiveMonitoringConnectionReadinessDisplaySemantics? = nil,
        reportSemantics: String? = nil,
        boundarySemantics: String? = nil,
        readModelFields: [String] = Self.requiredReadModelFields
    ) throws {
        let resolvedReadinessState = readinessState ?? Self.requiredReadinessState(for: healthStatus)
        let resolvedEvidenceID = evidenceID ?? Self.requiredEvidenceID(for: healthStatus)
        let resolvedHealthEvidenceID = healthEvidenceID ?? Self.requiredHealthEvidenceID(for: healthStatus)
        let resolvedExplanation = explanation ?? Self.requiredExplanation(for: healthStatus)
        let resolvedDisplaySemantics = displaySemantics ?? Self.requiredDisplaySemantics(for: healthStatus)
        let resolvedReportSemantics = reportSemantics ?? Self.requiredReportSemantics(for: healthStatus)
        let resolvedBoundarySemantics = boundarySemantics ?? Self.requiredBoundarySemantics(for: healthStatus)
        try Self.validate(
            healthStatus: healthStatus,
            readinessState: resolvedReadinessState,
            evidenceID: resolvedEvidenceID,
            healthEvidenceID: resolvedHealthEvidenceID,
            healthEvidenceChecksum: healthEvidenceChecksum,
            sourceIdentityChecksum: sourceIdentityChecksum,
            explanation: resolvedExplanation,
            displaySemantics: resolvedDisplaySemantics,
            reportSemantics: resolvedReportSemantics,
            boundarySemantics: resolvedBoundarySemantics,
            readModelFields: readModelFields
        )

        self.healthStatus = healthStatus
        self.readinessState = resolvedReadinessState
        self.evidenceID = resolvedEvidenceID
        self.healthEvidenceID = resolvedHealthEvidenceID
        self.healthEvidenceChecksum = healthEvidenceChecksum
        self.sourceIdentityChecksum = sourceIdentityChecksum
        self.explanation = resolvedExplanation
        self.displaySemantics = resolvedDisplaySemantics
        self.reportSemantics = resolvedReportSemantics
        self.boundarySemantics = resolvedBoundarySemantics
        self.readModelFields = readModelFields
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            healthStatus: try container.decode(LiveMonitoringSimulationGateHealthStatus.self, forKey: .healthStatus),
            readinessState: try container.decode(
                LiveMonitoringConnectionReadinessExplanationState.self,
                forKey: .readinessState
            ),
            evidenceID: try container.decode(String.self, forKey: .evidenceID),
            healthEvidenceID: try container.decode(String.self, forKey: .healthEvidenceID),
            healthEvidenceChecksum: try container.decode(String.self, forKey: .healthEvidenceChecksum),
            sourceIdentityChecksum: try container.decode(String.self, forKey: .sourceIdentityChecksum),
            explanation: try container.decode(String.self, forKey: .explanation),
            displaySemantics: try container.decode(
                LiveMonitoringConnectionReadinessDisplaySemantics.self,
                forKey: .displaySemantics
            ),
            reportSemantics: try container.decode(String.self, forKey: .reportSemantics),
            boundarySemantics: try container.decode(String.self, forKey: .boundarySemantics),
            readModelFields: try container.decode([String].self, forKey: .readModelFields)
        )
    }

    public func containsForbiddenExposureText(_ forbiddenTokens: [String]) -> Bool {
        let searchable = [
            evidenceID,
            healthEvidenceID,
            healthEvidenceChecksum,
            sourceIdentityChecksum,
            explanation,
            displaySemantics.rawValue,
            reportSemantics,
            boundarySemantics,
            readModelFields.joined(separator: "|")
        ]
            .joined(separator: "|")
            .lowercased()

        return forbiddenTokens.contains { token in
            searchable.contains(token.lowercased())
        }
    }

    public static let requiredHealthEvidenceChecksum = LiveMonitoringSimulationGateHealthContract.requiredChecksum
    public static let requiredSourceIdentityChecksum = LiveMonitoringSourceIdentityContract.requiredChecksum
    public static let requiredReadModelFields = [
        "connectionReadinessExplanationId",
        "healthEvidenceId",
        "healthStatus",
        "readinessState",
        "displaySemantics",
        "reportSemantics",
        "boundarySemantics",
        "sourceIdentityChecksum",
        "healthEvidenceChecksum",
        "checksum"
    ]
    public static let forbiddenExposureFieldTokens = [
        "payload",
        "schema",
        "runtimeobject",
        "runtime-object",
        "adapterrequest",
        "adapter-request",
        "endpoint",
        "listenkey",
        "privatewebsocket",
        "private-websocket",
        "brokerstate",
        "broker-state",
        "realaccount",
        "real-account",
        "realposition",
        "real-position",
        "realbalance",
        "real-balance",
        "realpnl",
        "real-pnl",
        "runtimeconnection",
        "runtime-connection",
        "connectionmanager",
        "connection-manager",
        "connected",
        "established",
        "liveexecutionadapter",
        "live-execution-adapter",
        "tradingbutton",
        "trading-button",
        "livecommand",
        "live-command",
        "orderform",
        "order-form"
    ]

    public static func requiredItem(
        for healthStatus: LiveMonitoringSimulationGateHealthStatus
    ) -> LiveMonitoringConnectionReadinessExplanationItem {
        do {
            return try LiveMonitoringConnectionReadinessExplanationItem(healthStatus: healthStatus)
        } catch {
            preconditionFailure("MTP-150 connection readiness explanation item must be valid: \(error)")
        }
    }

    public static func requiredReadinessState(
        for healthStatus: LiveMonitoringSimulationGateHealthStatus
    ) -> LiveMonitoringConnectionReadinessExplanationState {
        switch healthStatus {
        case .nominal:
            return .readiness
        case .stale:
            return .stale
        case .blocked:
            return .blocked
        case .missing:
            return .missing
        }
    }

    public static func requiredEvidenceID(
        for healthStatus: LiveMonitoringSimulationGateHealthStatus
    ) -> String {
        switch healthStatus {
        case .nominal:
            return "live-monitoring-readiness-explanation|fixture|mtp-150-readiness|001"
        case .stale:
            return "live-monitoring-readiness-explanation|fixture|mtp-150-stale|001"
        case .blocked:
            return "live-monitoring-readiness-explanation|fixture|mtp-150-blocked|001"
        case .missing:
            return "live-monitoring-readiness-explanation|fixture|mtp-150-missing|001"
        }
    }

    public static func requiredHealthEvidenceID(
        for healthStatus: LiveMonitoringSimulationGateHealthStatus
    ) -> String {
        LiveMonitoringSimulationGateHealthEvidenceItem.requiredEvidenceID(
            for: requiredFreshnessStatus(for: healthStatus)
        )
    }

    public static func requiredFreshnessStatus(
        for healthStatus: LiveMonitoringSimulationGateHealthStatus
    ) -> SimulatedAccountSnapshotFreshnessEvidenceStatus {
        switch healthStatus {
        case .nominal:
            return .fresh
        case .stale:
            return .stale
        case .blocked:
            return .blocked
        case .missing:
            return .missing
        }
    }

    public static func requiredExplanation(
        for healthStatus: LiveMonitoringSimulationGateHealthStatus
    ) -> String {
        switch healthStatus {
        case .nominal:
            return "simulated gate evidence is current enough for read-only readiness explanation"
        case .stale:
            return "simulated gate evidence is stale and must be shown as stale read-only explanation"
        case .blocked:
            return "boundary evidence blocks readiness interpretation and only a blocked explanation may be shown"
        case .missing:
            return "required simulated evidence is absent and only a missing explanation may be shown"
        }
    }

    public static func requiredDisplaySemantics(
        for healthStatus: LiveMonitoringSimulationGateHealthStatus
    ) -> LiveMonitoringConnectionReadinessDisplaySemantics {
        switch healthStatus {
        case .nominal:
            return .readinessReadOnly
        case .stale:
            return .staleReadOnly
        case .blocked:
            return .blockedReadOnly
        case .missing:
            return .missingReadOnly
        }
    }

    public static func requiredReportSemantics(
        for healthStatus: LiveMonitoringSimulationGateHealthStatus
    ) -> String {
        switch healthStatus {
        case .nominal:
            return "report readiness explanation as derived simulated evidence"
        case .stale:
            return "report stale readiness explanation as derived simulated evidence"
        case .blocked:
            return "report blocked readiness explanation as boundary-held evidence"
        case .missing:
            return "report missing readiness explanation as absent evidence"
        }
    }

    public static func requiredBoundarySemantics(
        for healthStatus: LiveMonitoringSimulationGateHealthStatus
    ) -> String {
        switch healthStatus {
        case .nominal:
            return "show explanation only and keep live session closed"
        case .stale:
            return "show stale explanation only and do not refresh from a live source"
        case .blocked:
            return "show blocked explanation only and do not offer recovery action"
        case .missing:
            return "show missing explanation only and do not use fallback source"
        }
    }

    private static func validate(
        healthStatus: LiveMonitoringSimulationGateHealthStatus,
        readinessState: LiveMonitoringConnectionReadinessExplanationState,
        evidenceID: String,
        healthEvidenceID: String,
        healthEvidenceChecksum: String,
        sourceIdentityChecksum: String,
        explanation: String,
        displaySemantics: LiveMonitoringConnectionReadinessDisplaySemantics,
        reportSemantics: String,
        boundarySemantics: String,
        readModelFields: [String]
    ) throws {
        guard readinessState == Self.requiredReadinessState(for: healthStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(healthStatus.rawValue).readinessState",
                expected: Self.requiredReadinessState(for: healthStatus).rawValue,
                actual: readinessState.rawValue
            )
        }
        guard evidenceID == Self.requiredEvidenceID(for: healthStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(healthStatus.rawValue).evidenceID",
                expected: Self.requiredEvidenceID(for: healthStatus),
                actual: evidenceID
            )
        }
        guard healthEvidenceID == Self.requiredHealthEvidenceID(for: healthStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(healthStatus.rawValue).healthEvidenceID",
                expected: Self.requiredHealthEvidenceID(for: healthStatus),
                actual: healthEvidenceID
            )
        }
        guard healthEvidenceChecksum == Self.requiredHealthEvidenceChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "healthEvidenceChecksum",
                expected: Self.requiredHealthEvidenceChecksum,
                actual: healthEvidenceChecksum
            )
        }
        guard sourceIdentityChecksum == Self.requiredSourceIdentityChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceIdentityChecksum",
                expected: Self.requiredSourceIdentityChecksum,
                actual: sourceIdentityChecksum
            )
        }
        if Self.containsForbiddenExposureText(
            in: [
                evidenceID,
                healthEvidenceID,
                healthEvidenceChecksum,
                sourceIdentityChecksum,
                explanation,
                displaySemantics.rawValue,
                reportSemantics,
                boundarySemantics,
                readModelFields.joined(separator: "|")
            ],
            forbiddenTokens: Self.forbiddenExposureFieldTokens
        ) {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("connectionReadinessExplanation.payload")
        }
        guard explanation == Self.requiredExplanation(for: healthStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(healthStatus.rawValue).explanation",
                expected: Self.requiredExplanation(for: healthStatus),
                actual: explanation
            )
        }
        guard displaySemantics == Self.requiredDisplaySemantics(for: healthStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(healthStatus.rawValue).displaySemantics",
                expected: Self.requiredDisplaySemantics(for: healthStatus).rawValue,
                actual: displaySemantics.rawValue
            )
        }
        guard reportSemantics == Self.requiredReportSemantics(for: healthStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(healthStatus.rawValue).reportSemantics",
                expected: Self.requiredReportSemantics(for: healthStatus),
                actual: reportSemantics
            )
        }
        guard boundarySemantics == Self.requiredBoundarySemantics(for: healthStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(healthStatus.rawValue).boundarySemantics",
                expected: Self.requiredBoundarySemantics(for: healthStatus),
                actual: boundarySemantics
            )
        }
        if Self.containsForbiddenExposureText(
            in: [
                evidenceID,
                healthEvidenceID,
                healthEvidenceChecksum,
                sourceIdentityChecksum,
                explanation,
                displaySemantics.rawValue,
                reportSemantics,
                boundarySemantics,
                readModelFields.joined(separator: "|")
            ],
            forbiddenTokens: Self.forbiddenExposureFieldTokens
        ) {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("connectionReadinessExplanation.payload")
        }
        guard readModelFields == Self.requiredReadModelFields else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "readModelFields",
                expected: Self.requiredReadModelFields.joined(separator: ","),
                actual: readModelFields.joined(separator: ",")
            )
        }
    }

    private static func containsForbiddenExposureText(
        in values: [String],
        forbiddenTokens: [String]
    ) -> Bool {
        let searchable = values.joined(separator: "|").lowercased()
        return forbiddenTokens.contains { token in
            searchable.contains(token.lowercased())
        }
    }
}

/// LiveMonitoringConnectionReadinessExplanationContract 是 MTP-150 的 deterministic explanation 合同。
///
/// 合同只从 MTP-148 source identity 与 MTP-149 health evidence 派生 readiness / stale / blocked /
/// missing 解释。它不是 live readiness implementation，也不创建 connection manager、endpoint、
/// private stream、broker adapter、Live PRO Console、trading button、live command 或 order form。
public struct LiveMonitoringConnectionReadinessExplanationContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let matrixID: String
    public let sourceIdentityContractID: Identifier
    public let sourceIdentityChecksum: String
    public let simulationGateHealthContractID: Identifier
    public let simulationGateHealthChecksum: String
    public let explanationItems: [LiveMonitoringConnectionReadinessExplanationItem]
    public let allowedHealthStatuses: [LiveMonitoringSimulationGateHealthStatus]
    public let allowedReadinessStates: [LiveMonitoringConnectionReadinessExplanationState]
    public let allowedDisplaySemantics: [LiveMonitoringConnectionReadinessDisplaySemantics]
    public let checksum: String
    public let checksumMatchedCanonicalPreimage: Bool
    public let readModelOnlyNoRuntimeConnectionBoundaryHeld: Bool
    public let forbiddenCapabilities: [LiveMonitoringConnectionReadinessForbiddenCapability]
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
    public let readsRealAccount: Bool
    public let readsRealPosition: Bool
    public let readsRealBalance: Bool
    public let consumesRealAccountPayload: Bool
    public let exposesAccountPayload: Bool
    public let exposesBrokerState: Bool
    public let exposesAdapterRequest: Bool
    public let exposesRuntimeObject: Bool
    public let exposesPersistenceSchema: Bool
    public let connectsBrokerAdapter: Bool
    public let connectsExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let exposesLiveCommand: Bool
    public let exposesTradingButton: Bool
    public let exposesOrderForm: Bool
    public let writesRealOrder: Bool

    public var connectionReadinessExplanationBoundaryHeld: Bool {
        matrixID == Self.requiredMatrixID
            && sourceIdentityContractID == Self.requiredSourceIdentityContractID
            && sourceIdentityChecksum == Self.requiredSourceIdentityChecksum
            && simulationGateHealthContractID == Self.requiredSimulationGateHealthContractID
            && simulationGateHealthChecksum == Self.requiredSimulationGateHealthChecksum
            && explanationItems == Self.requiredExplanationItems
            && explanationItems.allSatisfy(\.connectionReadinessExplanationBoundaryHeld)
            && explanationItems.allSatisfy(\.derivedFromSimulationGateHealth)
            && allowedHealthStatuses == Self.requiredAllowedHealthStatuses
            && allowedReadinessStates == Self.requiredAllowedReadinessStates
            && allowedDisplaySemantics == Self.requiredAllowedDisplaySemantics
            && checksum == Self.requiredChecksum
            && checksumMatchedCanonicalPreimage
            && readModelOnlyNoRuntimeConnectionBoundaryHeld
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && forbiddenFlagsAreFalse
    }

    public var canonicalPreimage: String {
        Self.canonicalPreimage(for: explanationItems)
    }

    public init(
        contractID: Identifier = Identifier.constant("mtp-150-live-monitoring-connection-readiness-explanation"),
        issueID: Identifier = Identifier.constant("MTP-150"),
        matrixID: String = Self.requiredMatrixID,
        sourceIdentityContractID: Identifier = Self.requiredSourceIdentityContractID,
        sourceIdentityChecksum: String = Self.requiredSourceIdentityChecksum,
        simulationGateHealthContractID: Identifier = Self.requiredSimulationGateHealthContractID,
        simulationGateHealthChecksum: String = Self.requiredSimulationGateHealthChecksum,
        explanationItems: [LiveMonitoringConnectionReadinessExplanationItem] = Self.requiredExplanationItems,
        allowedHealthStatuses: [LiveMonitoringSimulationGateHealthStatus] = Self.requiredAllowedHealthStatuses,
        allowedReadinessStates: [LiveMonitoringConnectionReadinessExplanationState] =
            Self.requiredAllowedReadinessStates,
        allowedDisplaySemantics: [LiveMonitoringConnectionReadinessDisplaySemantics] =
            Self.requiredAllowedDisplaySemantics,
        checksum: String? = nil,
        checksumMatchedCanonicalPreimage: Bool = true,
        readModelOnlyNoRuntimeConnectionBoundaryHeld: Bool = true,
        forbiddenCapabilities: [LiveMonitoringConnectionReadinessForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        opensPrivateWebSocket: Bool = false,
        runsPrivateStreamRuntime: Bool = false,
        runsAccountSnapshotRuntime: Bool = false,
        createsConnectionManager: Bool = false,
        opensRuntimeConnection: Bool = false,
        implementsLiveReadiness: Bool = false,
        runsLiveMonitoringRuntime: Bool = false,
        readsRealAccount: Bool = false,
        readsRealPosition: Bool = false,
        readsRealBalance: Bool = false,
        consumesRealAccountPayload: Bool = false,
        exposesAccountPayload: Bool = false,
        exposesBrokerState: Bool = false,
        exposesAdapterRequest: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesPersistenceSchema: Bool = false,
        connectsBrokerAdapter: Bool = false,
        connectsExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        exposesLiveCommand: Bool = false,
        exposesTradingButton: Bool = false,
        exposesOrderForm: Bool = false,
        writesRealOrder: Bool = false
    ) throws {
        let providedChecksum = checksum ?? Self.checksum(for: explanationItems)
        try Self.validate(
            matrixID: matrixID,
            sourceIdentityContractID: sourceIdentityContractID,
            sourceIdentityChecksum: sourceIdentityChecksum,
            simulationGateHealthContractID: simulationGateHealthContractID,
            simulationGateHealthChecksum: simulationGateHealthChecksum,
            explanationItems: explanationItems,
            allowedHealthStatuses: allowedHealthStatuses,
            allowedReadinessStates: allowedReadinessStates,
            allowedDisplaySemantics: allowedDisplaySemantics,
            checksum: providedChecksum,
            checksumMatchedCanonicalPreimage: checksumMatchedCanonicalPreimage,
            readModelOnlyNoRuntimeConnectionBoundaryHeld: readModelOnlyNoRuntimeConnectionBoundaryHeld,
            forbiddenCapabilities: forbiddenCapabilities
        )
        try Self.validateForbiddenFlags(
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            opensPrivateWebSocket: opensPrivateWebSocket,
            runsPrivateStreamRuntime: runsPrivateStreamRuntime,
            runsAccountSnapshotRuntime: runsAccountSnapshotRuntime,
            createsConnectionManager: createsConnectionManager,
            opensRuntimeConnection: opensRuntimeConnection,
            implementsLiveReadiness: implementsLiveReadiness,
            runsLiveMonitoringRuntime: runsLiveMonitoringRuntime,
            readsRealAccount: readsRealAccount,
            readsRealPosition: readsRealPosition,
            readsRealBalance: readsRealBalance,
            consumesRealAccountPayload: consumesRealAccountPayload,
            exposesAccountPayload: exposesAccountPayload,
            exposesBrokerState: exposesBrokerState,
            exposesAdapterRequest: exposesAdapterRequest,
            exposesRuntimeObject: exposesRuntimeObject,
            exposesPersistenceSchema: exposesPersistenceSchema,
            connectsBrokerAdapter: connectsBrokerAdapter,
            connectsExchangeExecutionAdapter: connectsExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            exposesLiveCommand: exposesLiveCommand,
            exposesTradingButton: exposesTradingButton,
            exposesOrderForm: exposesOrderForm,
            writesRealOrder: writesRealOrder
        )

        self.contractID = contractID
        self.issueID = issueID
        self.matrixID = matrixID
        self.sourceIdentityContractID = sourceIdentityContractID
        self.sourceIdentityChecksum = sourceIdentityChecksum
        self.simulationGateHealthContractID = simulationGateHealthContractID
        self.simulationGateHealthChecksum = simulationGateHealthChecksum
        self.explanationItems = explanationItems
        self.allowedHealthStatuses = allowedHealthStatuses
        self.allowedReadinessStates = allowedReadinessStates
        self.allowedDisplaySemantics = allowedDisplaySemantics
        self.checksum = providedChecksum
        self.checksumMatchedCanonicalPreimage = checksumMatchedCanonicalPreimage
        self.readModelOnlyNoRuntimeConnectionBoundaryHeld = readModelOnlyNoRuntimeConnectionBoundaryHeld
        self.forbiddenCapabilities = forbiddenCapabilities
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
        self.readsRealAccount = readsRealAccount
        self.readsRealPosition = readsRealPosition
        self.readsRealBalance = readsRealBalance
        self.consumesRealAccountPayload = consumesRealAccountPayload
        self.exposesAccountPayload = exposesAccountPayload
        self.exposesBrokerState = exposesBrokerState
        self.exposesAdapterRequest = exposesAdapterRequest
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesPersistenceSchema = exposesPersistenceSchema
        self.connectsBrokerAdapter = connectsBrokerAdapter
        self.connectsExchangeExecutionAdapter = connectsExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.exposesLiveCommand = exposesLiveCommand
        self.exposesTradingButton = exposesTradingButton
        self.exposesOrderForm = exposesOrderForm
        self.writesRealOrder = writesRealOrder
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            matrixID: try container.decode(String.self, forKey: .matrixID),
            sourceIdentityContractID: try container.decode(Identifier.self, forKey: .sourceIdentityContractID),
            sourceIdentityChecksum: try container.decode(String.self, forKey: .sourceIdentityChecksum),
            simulationGateHealthContractID: try container.decode(
                Identifier.self,
                forKey: .simulationGateHealthContractID
            ),
            simulationGateHealthChecksum: try container.decode(String.self, forKey: .simulationGateHealthChecksum),
            explanationItems: try container.decode(
                [LiveMonitoringConnectionReadinessExplanationItem].self,
                forKey: .explanationItems
            ),
            allowedHealthStatuses: try container.decode(
                [LiveMonitoringSimulationGateHealthStatus].self,
                forKey: .allowedHealthStatuses
            ),
            allowedReadinessStates: try container.decode(
                [LiveMonitoringConnectionReadinessExplanationState].self,
                forKey: .allowedReadinessStates
            ),
            allowedDisplaySemantics: try container.decode(
                [LiveMonitoringConnectionReadinessDisplaySemantics].self,
                forKey: .allowedDisplaySemantics
            ),
            checksum: try container.decode(String.self, forKey: .checksum),
            checksumMatchedCanonicalPreimage: try container.decode(
                Bool.self,
                forKey: .checksumMatchedCanonicalPreimage
            ),
            readModelOnlyNoRuntimeConnectionBoundaryHeld: try container.decode(
                Bool.self,
                forKey: .readModelOnlyNoRuntimeConnectionBoundaryHeld
            ),
            forbiddenCapabilities: try container.decode(
                [LiveMonitoringConnectionReadinessForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            opensPrivateWebSocket: try container.decode(Bool.self, forKey: .opensPrivateWebSocket),
            runsPrivateStreamRuntime: try container.decode(Bool.self, forKey: .runsPrivateStreamRuntime),
            runsAccountSnapshotRuntime: try container.decode(Bool.self, forKey: .runsAccountSnapshotRuntime),
            createsConnectionManager: try container.decode(Bool.self, forKey: .createsConnectionManager),
            opensRuntimeConnection: try container.decode(Bool.self, forKey: .opensRuntimeConnection),
            implementsLiveReadiness: try container.decode(Bool.self, forKey: .implementsLiveReadiness),
            runsLiveMonitoringRuntime: try container.decode(Bool.self, forKey: .runsLiveMonitoringRuntime),
            readsRealAccount: try container.decode(Bool.self, forKey: .readsRealAccount),
            readsRealPosition: try container.decode(Bool.self, forKey: .readsRealPosition),
            readsRealBalance: try container.decode(Bool.self, forKey: .readsRealBalance),
            consumesRealAccountPayload: try container.decode(Bool.self, forKey: .consumesRealAccountPayload),
            exposesAccountPayload: try container.decode(Bool.self, forKey: .exposesAccountPayload),
            exposesBrokerState: try container.decode(Bool.self, forKey: .exposesBrokerState),
            exposesAdapterRequest: try container.decode(Bool.self, forKey: .exposesAdapterRequest),
            exposesRuntimeObject: try container.decode(Bool.self, forKey: .exposesRuntimeObject),
            exposesPersistenceSchema: try container.decode(Bool.self, forKey: .exposesPersistenceSchema),
            connectsBrokerAdapter: try container.decode(Bool.self, forKey: .connectsBrokerAdapter),
            connectsExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .connectsExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            exposesLiveCommand: try container.decode(Bool.self, forKey: .exposesLiveCommand),
            exposesTradingButton: try container.decode(Bool.self, forKey: .exposesTradingButton),
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm),
            writesRealOrder: try container.decode(Bool.self, forKey: .writesRealOrder)
        )
    }

    public func containsForbiddenExposureText(_ forbiddenTokens: [String]) -> Bool {
        let searchable = [
            matrixID,
            sourceIdentityChecksum,
            simulationGateHealthChecksum,
            checksum,
            explanationItems.map(\.canonicalLine).joined(separator: "|")
        ]
            .joined(separator: "|")
            .lowercased()

        return forbiddenTokens.contains { token in
            searchable.contains(token.lowercased())
        }
    }

    public static let requiredMatrixID = "TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2"
    public static let requiredSourceIdentityContractID =
        LiveMonitoringSourceIdentityContract.deterministicFixture.contractID
    public static let requiredSourceIdentityChecksum = LiveMonitoringSourceIdentityContract.requiredChecksum
    public static let requiredSimulationGateHealthContractID =
        LiveMonitoringSimulationGateHealthContract.deterministicFixture.contractID
    public static let requiredSimulationGateHealthChecksum =
        LiveMonitoringSimulationGateHealthContract.requiredChecksum
    public static let requiredAllowedHealthStatuses = LiveMonitoringSimulationGateHealthStatus.allCases
    public static let requiredAllowedReadinessStates = LiveMonitoringConnectionReadinessExplanationState.allCases
    public static let requiredAllowedDisplaySemantics = LiveMonitoringConnectionReadinessDisplaySemantics.allCases
    public static let requiredForbiddenCapabilities =
        LiveMonitoringConnectionReadinessForbiddenCapability.allCases

    public static let requiredExplanationItems: [LiveMonitoringConnectionReadinessExplanationItem] = {
        LiveMonitoringSimulationGateHealthStatus.allCases.map {
            LiveMonitoringConnectionReadinessExplanationItem.requiredItem(for: $0)
        }
    }()

    public static let requiredChecksum = checksum(for: requiredExplanationItems)

    public static let deterministicFixture: LiveMonitoringConnectionReadinessExplanationContract = {
        do {
            return try LiveMonitoringConnectionReadinessExplanationContract()
        } catch {
            preconditionFailure("MTP-150 live monitoring connection readiness explanation must be valid: \(error)")
        }
    }()

    public static func canonicalPreimage(
        for explanationItems: [LiveMonitoringConnectionReadinessExplanationItem]
    ) -> String {
        explanationItems.map(\.canonicalLine).joined(separator: "\n")
    }

    public static func checksum(
        for explanationItems: [LiveMonitoringConnectionReadinessExplanationItem]
    ) -> String {
        ScenarioReplayChecksumEvidence.checksum(forCanonicalPreimage: canonicalPreimage(for: explanationItems))
    }

    private var forbiddenFlagsAreFalse: Bool {
        callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && opensPrivateWebSocket == false
            && runsPrivateStreamRuntime == false
            && runsAccountSnapshotRuntime == false
            && createsConnectionManager == false
            && opensRuntimeConnection == false
            && implementsLiveReadiness == false
            && runsLiveMonitoringRuntime == false
            && readsRealAccount == false
            && readsRealPosition == false
            && readsRealBalance == false
            && consumesRealAccountPayload == false
            && exposesAccountPayload == false
            && exposesBrokerState == false
            && exposesAdapterRequest == false
            && exposesRuntimeObject == false
            && exposesPersistenceSchema == false
            && connectsBrokerAdapter == false
            && connectsExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && exposesLiveCommand == false
            && exposesTradingButton == false
            && exposesOrderForm == false
            && writesRealOrder == false
    }

    private static func validate(
        matrixID: String,
        sourceIdentityContractID: Identifier,
        sourceIdentityChecksum: String,
        simulationGateHealthContractID: Identifier,
        simulationGateHealthChecksum: String,
        explanationItems: [LiveMonitoringConnectionReadinessExplanationItem],
        allowedHealthStatuses: [LiveMonitoringSimulationGateHealthStatus],
        allowedReadinessStates: [LiveMonitoringConnectionReadinessExplanationState],
        allowedDisplaySemantics: [LiveMonitoringConnectionReadinessDisplaySemantics],
        checksum: String,
        checksumMatchedCanonicalPreimage: Bool,
        readModelOnlyNoRuntimeConnectionBoundaryHeld: Bool,
        forbiddenCapabilities: [LiveMonitoringConnectionReadinessForbiddenCapability]
    ) throws {
        guard matrixID == Self.requiredMatrixID else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "matrixID",
                expected: Self.requiredMatrixID,
                actual: matrixID
            )
        }
        guard sourceIdentityContractID == Self.requiredSourceIdentityContractID else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceIdentityContractID",
                expected: Self.requiredSourceIdentityContractID.rawValue,
                actual: sourceIdentityContractID.rawValue
            )
        }
        guard sourceIdentityChecksum == Self.requiredSourceIdentityChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceIdentityChecksum",
                expected: Self.requiredSourceIdentityChecksum,
                actual: sourceIdentityChecksum
            )
        }
        guard simulationGateHealthContractID == Self.requiredSimulationGateHealthContractID else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "simulationGateHealthContractID",
                expected: Self.requiredSimulationGateHealthContractID.rawValue,
                actual: simulationGateHealthContractID.rawValue
            )
        }
        guard simulationGateHealthChecksum == Self.requiredSimulationGateHealthChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "simulationGateHealthChecksum",
                expected: Self.requiredSimulationGateHealthChecksum,
                actual: simulationGateHealthChecksum
            )
        }
        guard explanationItems == Self.requiredExplanationItems else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "explanationItems",
                expected: Self.requiredExplanationItems.map(\.healthStatus.rawValue).joined(separator: ","),
                actual: explanationItems.map(\.healthStatus.rawValue).joined(separator: ",")
            )
        }
        guard explanationItems.allSatisfy(\.connectionReadinessExplanationBoundaryHeld) else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("connectionReadinessExplanationBoundaryHeld")
        }
        guard explanationItems.allSatisfy(\.derivedFromSimulationGateHealth) else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("derivedFromSimulationGateHealth")
        }
        guard allowedHealthStatuses == Self.requiredAllowedHealthStatuses else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "allowedHealthStatuses",
                expected: Self.requiredAllowedHealthStatuses.map(\.rawValue).joined(separator: ","),
                actual: allowedHealthStatuses.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedReadinessStates == Self.requiredAllowedReadinessStates else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "allowedReadinessStates",
                expected: Self.requiredAllowedReadinessStates.map(\.rawValue).joined(separator: ","),
                actual: allowedReadinessStates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedDisplaySemantics == Self.requiredAllowedDisplaySemantics else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "allowedDisplaySemantics",
                expected: Self.requiredAllowedDisplaySemantics.map(\.rawValue).joined(separator: ","),
                actual: allowedDisplaySemantics.map(\.rawValue).joined(separator: ",")
            )
        }
        guard checksum == Self.requiredChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "checksum",
                expected: Self.requiredChecksum,
                actual: checksum
            )
        }
        guard checksumMatchedCanonicalPreimage else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "checksumMatchedCanonicalPreimage",
                expected: "true",
                actual: "false"
            )
        }
        guard readModelOnlyNoRuntimeConnectionBoundaryHeld else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("readModelOnlyNoRuntimeConnectionBoundaryHeld")
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        opensPrivateWebSocket: Bool,
        runsPrivateStreamRuntime: Bool,
        runsAccountSnapshotRuntime: Bool,
        createsConnectionManager: Bool,
        opensRuntimeConnection: Bool,
        implementsLiveReadiness: Bool,
        runsLiveMonitoringRuntime: Bool,
        readsRealAccount: Bool,
        readsRealPosition: Bool,
        readsRealBalance: Bool,
        consumesRealAccountPayload: Bool,
        exposesAccountPayload: Bool,
        exposesBrokerState: Bool,
        exposesAdapterRequest: Bool,
        exposesRuntimeObject: Bool,
        exposesPersistenceSchema: Bool,
        connectsBrokerAdapter: Bool,
        connectsExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        exposesLiveCommand: Bool,
        exposesTradingButton: Bool,
        exposesOrderForm: Bool,
        writesRealOrder: Bool
    ) throws {
        let forbiddenFlags = [
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("opensPrivateWebSocket", opensPrivateWebSocket),
            ("runsPrivateStreamRuntime", runsPrivateStreamRuntime),
            ("runsAccountSnapshotRuntime", runsAccountSnapshotRuntime),
            ("createsConnectionManager", createsConnectionManager),
            ("opensRuntimeConnection", opensRuntimeConnection),
            ("implementsLiveReadiness", implementsLiveReadiness),
            ("runsLiveMonitoringRuntime", runsLiveMonitoringRuntime),
            ("readsRealAccount", readsRealAccount),
            ("readsRealPosition", readsRealPosition),
            ("readsRealBalance", readsRealBalance),
            ("consumesRealAccountPayload", consumesRealAccountPayload),
            ("exposesAccountPayload", exposesAccountPayload),
            ("exposesBrokerState", exposesBrokerState),
            ("exposesAdapterRequest", exposesAdapterRequest),
            ("exposesRuntimeObject", exposesRuntimeObject),
            ("exposesPersistenceSchema", exposesPersistenceSchema),
            ("connectsBrokerAdapter", connectsBrokerAdapter),
            ("connectsExchangeExecutionAdapter", connectsExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("exposesLiveCommand", exposesLiveCommand),
            ("exposesTradingButton", exposesTradingButton),
            ("exposesOrderForm", exposesOrderForm),
            ("writesRealOrder", writesRealOrder)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveMonitoringConsoleForbiddenCapability(capability.0)
        }
    }
}
