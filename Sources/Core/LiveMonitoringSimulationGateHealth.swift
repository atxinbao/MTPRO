import Foundation

/// LiveMonitoringSimulationGateHealthStatus 固定 MTP-149 可以展示的 simulation gate health 状态。
///
/// 这些状态只解释 MTP-144 本地 freshness fixture 是否可作为 monitoring read model evidence 展示。
/// 它们不是真实账户健康、broker 连接健康、private stream 状态或 live connection status。
public enum LiveMonitoringSimulationGateHealthStatus:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case nominal = "nominal simulated gate health evidence"
    case stale = "stale simulated gate health evidence"
    case blocked = "blocked simulated gate health evidence"
    case missing = "missing simulated gate health evidence"
}

/// LiveMonitoringSimulationGateFreshnessExplanation 固定 MTP-149 的 freshness 解释规则。
///
/// 解释值只来自 fixture / simulated / read-model-only evidence；它们不会触发 reconnect、refresh、
/// listenKey、account endpoint、private WebSocket、broker sync 或任何 live command。
public enum LiveMonitoringSimulationGateFreshnessExplanation:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case withinThreshold = "fresh simulated fixture is within stale threshold"
    case thresholdExceeded = "stale simulated fixture exceeded stale threshold"
    case blockedByBoundary = "blocked simulated fixture is boundary-held evidence"
    case fixtureInputMissing = "missing simulated fixture input is absent evidence"
}

/// LiveMonitoringSimulationGateHealthForbiddenCapability 列出 MTP-149 必须拒绝的误用能力。
///
/// 这些值只作为合同、focused tests 和 PR evidence 的禁止项。当前合同不能实现 runtime、
/// endpoint、payload、schema、broker state、交易命令或真实账户资料通道。
public enum LiveMonitoringSimulationGateHealthForbiddenCapability:
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

/// LiveMonitoringSimulationGateHealthEvidenceItem 是 MTP-149 的单条 health / freshness evidence。
///
/// Item 只把 MTP-148 monitoring source identity 与 MTP-144 freshness fixture 串成只读展示证据。
/// 它不保存 endpoint、listenKey、真实 account payload、Adapter request、Runtime object、
/// SQLite / DuckDB schema 或 broker state，避免 health 被误读为真实连接健康。
public struct LiveMonitoringSimulationGateHealthEvidenceItem: Codable, Equatable, Sendable {
    public let freshnessStatus: SimulatedAccountSnapshotFreshnessEvidenceStatus
    public let healthStatus: LiveMonitoringSimulationGateHealthStatus
    public let evidenceID: String
    public let monitoringSourceIdentity: String
    public let sourceEvidenceOrigins: [LiveMonitoringSourceEvidenceOrigin]
    public let sourceIdentityChecksum: String
    public let freshnessEvidenceID: String
    public let freshnessEvidenceChecksum: String
    public let freshnessExplanation: LiveMonitoringSimulationGateFreshnessExplanation
    public let blockedDisplaySemantics: String
    public let readModelFields: [String]

    public var canonicalLine: String {
        [
            freshnessStatus.rawValue,
            healthStatus.rawValue,
            evidenceID,
            monitoringSourceIdentity,
            sourceEvidenceOrigins.map(\.rawValue).joined(separator: "+"),
            sourceIdentityChecksum,
            freshnessEvidenceID,
            freshnessEvidenceChecksum,
            freshnessExplanation.rawValue,
            blockedDisplaySemantics,
            readModelFields.joined(separator: "+")
        ].joined(separator: "|")
    }

    public var simulationGateHealthBoundaryHeld: Bool {
        self == Self.requiredItem(for: freshnessStatus)
            && containsForbiddenExposureText(Self.forbiddenExposureFieldTokens) == false
    }

    public var fixtureSimulatedReadModelOnly: Bool {
        sourceEvidenceOrigins == Self.requiredSourceEvidenceOrigins
            && monitoringSourceIdentity == Self.requiredMonitoringSourceIdentity
            && sourceIdentityChecksum == Self.requiredSourceIdentityChecksum
            && freshnessEvidenceChecksum == Self.requiredFreshnessEvidenceChecksum
    }

    public init(
        freshnessStatus: SimulatedAccountSnapshotFreshnessEvidenceStatus,
        healthStatus: LiveMonitoringSimulationGateHealthStatus? = nil,
        evidenceID: String? = nil,
        monitoringSourceIdentity: String = Self.requiredMonitoringSourceIdentity,
        sourceEvidenceOrigins: [LiveMonitoringSourceEvidenceOrigin] = Self.requiredSourceEvidenceOrigins,
        sourceIdentityChecksum: String = Self.requiredSourceIdentityChecksum,
        freshnessEvidenceID: String? = nil,
        freshnessEvidenceChecksum: String = Self.requiredFreshnessEvidenceChecksum,
        freshnessExplanation: LiveMonitoringSimulationGateFreshnessExplanation? = nil,
        blockedDisplaySemantics: String? = nil,
        readModelFields: [String] = Self.requiredReadModelFields
    ) throws {
        let resolvedHealthStatus = healthStatus ?? Self.requiredHealthStatus(for: freshnessStatus)
        let resolvedEvidenceID = evidenceID ?? Self.requiredEvidenceID(for: freshnessStatus)
        let resolvedFreshnessEvidenceID =
            freshnessEvidenceID ?? Self.requiredFreshnessEvidenceID(for: freshnessStatus)
        let resolvedFreshnessExplanation =
            freshnessExplanation ?? Self.requiredFreshnessExplanation(for: freshnessStatus)
        let resolvedBlockedDisplaySemantics =
            blockedDisplaySemantics ?? Self.requiredBlockedDisplaySemantics(for: freshnessStatus)
        try Self.validate(
            freshnessStatus: freshnessStatus,
            healthStatus: resolvedHealthStatus,
            evidenceID: resolvedEvidenceID,
            monitoringSourceIdentity: monitoringSourceIdentity,
            sourceEvidenceOrigins: sourceEvidenceOrigins,
            sourceIdentityChecksum: sourceIdentityChecksum,
            freshnessEvidenceID: resolvedFreshnessEvidenceID,
            freshnessEvidenceChecksum: freshnessEvidenceChecksum,
            freshnessExplanation: resolvedFreshnessExplanation,
            blockedDisplaySemantics: resolvedBlockedDisplaySemantics,
            readModelFields: readModelFields
        )

        self.freshnessStatus = freshnessStatus
        self.healthStatus = resolvedHealthStatus
        self.evidenceID = resolvedEvidenceID
        self.monitoringSourceIdentity = monitoringSourceIdentity
        self.sourceEvidenceOrigins = sourceEvidenceOrigins
        self.sourceIdentityChecksum = sourceIdentityChecksum
        self.freshnessEvidenceID = resolvedFreshnessEvidenceID
        self.freshnessEvidenceChecksum = freshnessEvidenceChecksum
        self.freshnessExplanation = resolvedFreshnessExplanation
        self.blockedDisplaySemantics = resolvedBlockedDisplaySemantics
        self.readModelFields = readModelFields
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            freshnessStatus: try container.decode(
                SimulatedAccountSnapshotFreshnessEvidenceStatus.self,
                forKey: .freshnessStatus
            ),
            healthStatus: try container.decode(LiveMonitoringSimulationGateHealthStatus.self, forKey: .healthStatus),
            evidenceID: try container.decode(String.self, forKey: .evidenceID),
            monitoringSourceIdentity: try container.decode(String.self, forKey: .monitoringSourceIdentity),
            sourceEvidenceOrigins: try container.decode(
                [LiveMonitoringSourceEvidenceOrigin].self,
                forKey: .sourceEvidenceOrigins
            ),
            sourceIdentityChecksum: try container.decode(String.self, forKey: .sourceIdentityChecksum),
            freshnessEvidenceID: try container.decode(String.self, forKey: .freshnessEvidenceID),
            freshnessEvidenceChecksum: try container.decode(String.self, forKey: .freshnessEvidenceChecksum),
            freshnessExplanation: try container.decode(
                LiveMonitoringSimulationGateFreshnessExplanation.self,
                forKey: .freshnessExplanation
            ),
            blockedDisplaySemantics: try container.decode(String.self, forKey: .blockedDisplaySemantics),
            readModelFields: try container.decode([String].self, forKey: .readModelFields)
        )
    }

    public func containsForbiddenExposureText(_ forbiddenTokens: [String]) -> Bool {
        let searchable = [
            evidenceID,
            monitoringSourceIdentity,
            sourceEvidenceOrigins.map(\.rawValue).joined(separator: "|"),
            sourceIdentityChecksum,
            freshnessEvidenceID,
            freshnessEvidenceChecksum,
            freshnessExplanation.rawValue,
            blockedDisplaySemantics,
            readModelFields.joined(separator: "|")
        ]
            .joined(separator: "|")
            .lowercased()

        return forbiddenTokens.contains { token in
            searchable.contains(token.lowercased())
        }
    }

    public static let requiredMonitoringSourceIdentityRecord =
        LiveMonitoringSourceIdentityRecord.requiredRecord(for: .l32PrivateStreamAccountSnapshotSimulationGate)
    public static let requiredMonitoringSourceIdentity = requiredMonitoringSourceIdentityRecord.sourceIdentity
    public static let requiredSourceEvidenceOrigins = requiredMonitoringSourceIdentityRecord.evidenceOrigins
    public static let requiredSourceIdentityChecksum = LiveMonitoringSourceIdentityContract.requiredChecksum
    public static let requiredFreshnessEvidenceChecksum =
        SimulatedAccountSnapshotFreshnessEvidenceContract.requiredChecksum
    public static let requiredReadModelFields = [
        "simulationGateHealthEvidenceId",
        "monitoringSourceIdentity",
        "freshnessEvidenceId",
        "freshnessStatus",
        "healthStatus",
        "freshnessExplanation",
        "blockedDisplaySemantics",
        "sourceIdentityChecksum",
        "freshnessEvidenceChecksum",
        "checksum"
    ]
    public static let forbiddenExposureFieldTokens = [
        "payload",
        "schema",
        "runtime",
        "endpoint",
        "listenkey",
        "secret",
        "adapterrequest",
        "adapter-request",
        "accountendpoint",
        "account-endpoint",
        "accountpayload",
        "account-payload",
        "privatewebsocket",
        "private-websocket",
        "sqlite",
        "duckdb",
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
        for freshnessStatus: SimulatedAccountSnapshotFreshnessEvidenceStatus
    ) -> LiveMonitoringSimulationGateHealthEvidenceItem {
        do {
            return try LiveMonitoringSimulationGateHealthEvidenceItem(freshnessStatus: freshnessStatus)
        } catch {
            preconditionFailure("MTP-149 simulation gate health evidence item must be valid: \(error)")
        }
    }

    public static func requiredHealthStatus(
        for freshnessStatus: SimulatedAccountSnapshotFreshnessEvidenceStatus
    ) -> LiveMonitoringSimulationGateHealthStatus {
        switch freshnessStatus {
        case .fresh:
            return .nominal
        case .stale:
            return .stale
        case .blocked:
            return .blocked
        case .missing:
            return .missing
        }
    }

    public static func requiredEvidenceID(
        for freshnessStatus: SimulatedAccountSnapshotFreshnessEvidenceStatus
    ) -> String {
        switch freshnessStatus {
        case .fresh:
            return "live-monitoring-simulation-gate-health|fixture|mtp-149-fresh|001"
        case .stale:
            return "live-monitoring-simulation-gate-health|fixture|mtp-149-stale|001"
        case .blocked:
            return "live-monitoring-simulation-gate-health|fixture|mtp-149-blocked|001"
        case .missing:
            return "live-monitoring-simulation-gate-health|fixture|mtp-149-missing|001"
        }
    }

    public static func requiredFreshnessEvidenceID(
        for freshnessStatus: SimulatedAccountSnapshotFreshnessEvidenceStatus
    ) -> String {
        SimulatedAccountSnapshotFreshnessEvidenceItem.requiredEvidenceID(for: freshnessStatus)
    }

    public static func requiredFreshnessExplanation(
        for freshnessStatus: SimulatedAccountSnapshotFreshnessEvidenceStatus
    ) -> LiveMonitoringSimulationGateFreshnessExplanation {
        switch freshnessStatus {
        case .fresh:
            return .withinThreshold
        case .stale:
            return .thresholdExceeded
        case .blocked:
            return .blockedByBoundary
        case .missing:
            return .fixtureInputMissing
        }
    }

    public static func requiredBlockedDisplaySemantics(
        for freshnessStatus: SimulatedAccountSnapshotFreshnessEvidenceStatus
    ) -> String {
        switch freshnessStatus {
        case .fresh:
            return "display nominal read-only evidence because simulated freshness is within threshold"
        case .stale:
            return "display stale read-only evidence because simulated freshness exceeded threshold"
        case .blocked:
            return "display boundary-held read-only evidence without reconnect or recovery action"
        case .missing:
            return "display absent read-only evidence without fallback action"
        }
    }

    private static func validate(
        freshnessStatus: SimulatedAccountSnapshotFreshnessEvidenceStatus,
        healthStatus: LiveMonitoringSimulationGateHealthStatus,
        evidenceID: String,
        monitoringSourceIdentity: String,
        sourceEvidenceOrigins: [LiveMonitoringSourceEvidenceOrigin],
        sourceIdentityChecksum: String,
        freshnessEvidenceID: String,
        freshnessEvidenceChecksum: String,
        freshnessExplanation: LiveMonitoringSimulationGateFreshnessExplanation,
        blockedDisplaySemantics: String,
        readModelFields: [String]
    ) throws {
        guard healthStatus == Self.requiredHealthStatus(for: freshnessStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(freshnessStatus.rawValue).healthStatus",
                expected: Self.requiredHealthStatus(for: freshnessStatus).rawValue,
                actual: healthStatus.rawValue
            )
        }
        guard evidenceID == Self.requiredEvidenceID(for: freshnessStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(freshnessStatus.rawValue).evidenceID",
                expected: Self.requiredEvidenceID(for: freshnessStatus),
                actual: evidenceID
            )
        }
        guard monitoringSourceIdentity == Self.requiredMonitoringSourceIdentity else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "monitoringSourceIdentity",
                expected: Self.requiredMonitoringSourceIdentity,
                actual: monitoringSourceIdentity
            )
        }
        guard sourceEvidenceOrigins == Self.requiredSourceEvidenceOrigins else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceEvidenceOrigins",
                expected: Self.requiredSourceEvidenceOrigins.map(\.rawValue).joined(separator: ","),
                actual: sourceEvidenceOrigins.map(\.rawValue).joined(separator: ",")
            )
        }
        guard sourceIdentityChecksum == Self.requiredSourceIdentityChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceIdentityChecksum",
                expected: Self.requiredSourceIdentityChecksum,
                actual: sourceIdentityChecksum
            )
        }
        guard freshnessEvidenceID == Self.requiredFreshnessEvidenceID(for: freshnessStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(freshnessStatus.rawValue).freshnessEvidenceID",
                expected: Self.requiredFreshnessEvidenceID(for: freshnessStatus),
                actual: freshnessEvidenceID
            )
        }
        guard freshnessEvidenceChecksum == Self.requiredFreshnessEvidenceChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "freshnessEvidenceChecksum",
                expected: Self.requiredFreshnessEvidenceChecksum,
                actual: freshnessEvidenceChecksum
            )
        }
        guard freshnessExplanation == Self.requiredFreshnessExplanation(for: freshnessStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(freshnessStatus.rawValue).freshnessExplanation",
                expected: Self.requiredFreshnessExplanation(for: freshnessStatus).rawValue,
                actual: freshnessExplanation.rawValue
            )
        }
        guard blockedDisplaySemantics == Self.requiredBlockedDisplaySemantics(for: freshnessStatus) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(freshnessStatus.rawValue).blockedDisplaySemantics",
                expected: Self.requiredBlockedDisplaySemantics(for: freshnessStatus),
                actual: blockedDisplaySemantics
            )
        }
        if Self.containsForbiddenExposureText(
            in: [
                evidenceID,
                monitoringSourceIdentity,
                sourceEvidenceOrigins.map(\.rawValue).joined(separator: "|"),
                sourceIdentityChecksum,
                freshnessEvidenceID,
                freshnessEvidenceChecksum,
                freshnessExplanation.rawValue,
                blockedDisplaySemantics,
                readModelFields.joined(separator: "|")
            ],
            forbiddenTokens: Self.forbiddenExposureFieldTokens
        ) {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("simulationGateHealthEvidence.payload")
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

/// LiveMonitoringSimulationGateHealthContract 是 MTP-149 的 deterministic health evidence 合同。
///
/// 合同复用 MTP-148 monitoring source identity 与 MTP-144 freshness evidence，并把 fresh / stale /
/// blocked / missing 固定成 simulation gate health 展示语义。它不代表真实账户健康、真实 broker
/// 连接、private stream runtime 或 live connection status，也不暴露 payload、schema 或 Runtime。
public struct LiveMonitoringSimulationGateHealthContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let matrixID: String
    public let sourceIdentityContractID: Identifier
    public let sourceIdentityChecksum: String
    public let freshnessEvidenceContractID: Identifier
    public let freshnessEvidenceChecksum: String
    public let healthEvidenceItems: [LiveMonitoringSimulationGateHealthEvidenceItem]
    public let allowedFreshnessStatuses: [SimulatedAccountSnapshotFreshnessEvidenceStatus]
    public let allowedHealthStatuses: [LiveMonitoringSimulationGateHealthStatus]
    public let checksum: String
    public let checksumMatchedCanonicalPreimage: Bool
    public let fixtureSimulatedReadModelOnly: Bool
    public let forbiddenCapabilities: [LiveMonitoringSimulationGateHealthForbiddenCapability]
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let opensPrivateWebSocket: Bool
    public let runsPrivateStreamRuntime: Bool
    public let runsAccountSnapshotRuntime: Bool
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

    public var simulationGateHealthBoundaryHeld: Bool {
        matrixID == Self.requiredMatrixID
            && sourceIdentityContractID == Self.requiredSourceIdentityContractID
            && sourceIdentityChecksum == Self.requiredSourceIdentityChecksum
            && freshnessEvidenceContractID == Self.requiredFreshnessEvidenceContractID
            && freshnessEvidenceChecksum == Self.requiredFreshnessEvidenceChecksum
            && healthEvidenceItems == Self.requiredHealthEvidenceItems
            && healthEvidenceItems.allSatisfy(\.simulationGateHealthBoundaryHeld)
            && allowedFreshnessStatuses == Self.requiredAllowedFreshnessStatuses
            && allowedHealthStatuses == Self.requiredAllowedHealthStatuses
            && checksum == Self.requiredChecksum
            && checksumMatchedCanonicalPreimage
            && fixtureSimulatedReadModelOnly
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && forbiddenFlagsAreFalse
    }

    public var canonicalPreimage: String {
        Self.canonicalPreimage(for: healthEvidenceItems)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-149-live-monitoring-simulation-gate-health"),
        issueID: Identifier = try! Identifier("MTP-149"),
        matrixID: String = Self.requiredMatrixID,
        sourceIdentityContractID: Identifier = Self.requiredSourceIdentityContractID,
        sourceIdentityChecksum: String = Self.requiredSourceIdentityChecksum,
        freshnessEvidenceContractID: Identifier = Self.requiredFreshnessEvidenceContractID,
        freshnessEvidenceChecksum: String = Self.requiredFreshnessEvidenceChecksum,
        healthEvidenceItems: [LiveMonitoringSimulationGateHealthEvidenceItem] = Self.requiredHealthEvidenceItems,
        allowedFreshnessStatuses: [SimulatedAccountSnapshotFreshnessEvidenceStatus] =
            Self.requiredAllowedFreshnessStatuses,
        allowedHealthStatuses: [LiveMonitoringSimulationGateHealthStatus] = Self.requiredAllowedHealthStatuses,
        checksum: String? = nil,
        checksumMatchedCanonicalPreimage: Bool = true,
        fixtureSimulatedReadModelOnly: Bool = true,
        forbiddenCapabilities: [LiveMonitoringSimulationGateHealthForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        opensPrivateWebSocket: Bool = false,
        runsPrivateStreamRuntime: Bool = false,
        runsAccountSnapshotRuntime: Bool = false,
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
        let providedChecksum = checksum ?? Self.checksum(for: healthEvidenceItems)
        try Self.validate(
            matrixID: matrixID,
            sourceIdentityContractID: sourceIdentityContractID,
            sourceIdentityChecksum: sourceIdentityChecksum,
            freshnessEvidenceContractID: freshnessEvidenceContractID,
            freshnessEvidenceChecksum: freshnessEvidenceChecksum,
            healthEvidenceItems: healthEvidenceItems,
            allowedFreshnessStatuses: allowedFreshnessStatuses,
            allowedHealthStatuses: allowedHealthStatuses,
            checksum: providedChecksum,
            checksumMatchedCanonicalPreimage: checksumMatchedCanonicalPreimage,
            fixtureSimulatedReadModelOnly: fixtureSimulatedReadModelOnly,
            forbiddenCapabilities: forbiddenCapabilities
        )
        try Self.validateForbiddenFlags(
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            opensPrivateWebSocket: opensPrivateWebSocket,
            runsPrivateStreamRuntime: runsPrivateStreamRuntime,
            runsAccountSnapshotRuntime: runsAccountSnapshotRuntime,
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
        self.freshnessEvidenceContractID = freshnessEvidenceContractID
        self.freshnessEvidenceChecksum = freshnessEvidenceChecksum
        self.healthEvidenceItems = healthEvidenceItems
        self.allowedFreshnessStatuses = allowedFreshnessStatuses
        self.allowedHealthStatuses = allowedHealthStatuses
        self.checksum = providedChecksum
        self.checksumMatchedCanonicalPreimage = checksumMatchedCanonicalPreimage
        self.fixtureSimulatedReadModelOnly = fixtureSimulatedReadModelOnly
        self.forbiddenCapabilities = forbiddenCapabilities
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.runsPrivateStreamRuntime = runsPrivateStreamRuntime
        self.runsAccountSnapshotRuntime = runsAccountSnapshotRuntime
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
            freshnessEvidenceContractID: try container.decode(Identifier.self, forKey: .freshnessEvidenceContractID),
            freshnessEvidenceChecksum: try container.decode(String.self, forKey: .freshnessEvidenceChecksum),
            healthEvidenceItems: try container.decode(
                [LiveMonitoringSimulationGateHealthEvidenceItem].self,
                forKey: .healthEvidenceItems
            ),
            allowedFreshnessStatuses: try container.decode(
                [SimulatedAccountSnapshotFreshnessEvidenceStatus].self,
                forKey: .allowedFreshnessStatuses
            ),
            allowedHealthStatuses: try container.decode(
                [LiveMonitoringSimulationGateHealthStatus].self,
                forKey: .allowedHealthStatuses
            ),
            checksum: try container.decode(String.self, forKey: .checksum),
            checksumMatchedCanonicalPreimage: try container.decode(
                Bool.self,
                forKey: .checksumMatchedCanonicalPreimage
            ),
            fixtureSimulatedReadModelOnly: try container.decode(Bool.self, forKey: .fixtureSimulatedReadModelOnly),
            forbiddenCapabilities: try container.decode(
                [LiveMonitoringSimulationGateHealthForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            opensPrivateWebSocket: try container.decode(Bool.self, forKey: .opensPrivateWebSocket),
            runsPrivateStreamRuntime: try container.decode(Bool.self, forKey: .runsPrivateStreamRuntime),
            runsAccountSnapshotRuntime: try container.decode(Bool.self, forKey: .runsAccountSnapshotRuntime),
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
            freshnessEvidenceChecksum,
            checksum,
            healthEvidenceItems.map(\.canonicalLine).joined(separator: "|")
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
    public static let requiredFreshnessEvidenceContractID =
        SimulatedAccountSnapshotFreshnessEvidenceContract.deterministicFixture.contractID
    public static let requiredFreshnessEvidenceChecksum =
        SimulatedAccountSnapshotFreshnessEvidenceContract.requiredChecksum
    public static let requiredAllowedFreshnessStatuses = SimulatedAccountSnapshotFreshnessEvidenceStatus.allCases
    public static let requiredAllowedHealthStatuses = LiveMonitoringSimulationGateHealthStatus.allCases
    public static let requiredForbiddenCapabilities =
        LiveMonitoringSimulationGateHealthForbiddenCapability.allCases

    public static let requiredHealthEvidenceItems: [LiveMonitoringSimulationGateHealthEvidenceItem] = {
        SimulatedAccountSnapshotFreshnessEvidenceStatus.allCases.map {
            LiveMonitoringSimulationGateHealthEvidenceItem.requiredItem(for: $0)
        }
    }()

    public static let requiredChecksum = checksum(for: requiredHealthEvidenceItems)

    public static let deterministicFixture: LiveMonitoringSimulationGateHealthContract = {
        do {
            return try LiveMonitoringSimulationGateHealthContract()
        } catch {
            preconditionFailure("MTP-149 live monitoring simulation gate health contract must be valid: \(error)")
        }
    }()

    public static func canonicalPreimage(
        for healthEvidenceItems: [LiveMonitoringSimulationGateHealthEvidenceItem]
    ) -> String {
        healthEvidenceItems.map(\.canonicalLine).joined(separator: "\n")
    }

    public static func checksum(
        for healthEvidenceItems: [LiveMonitoringSimulationGateHealthEvidenceItem]
    ) -> String {
        ScenarioReplayChecksumEvidence.checksum(forCanonicalPreimage: canonicalPreimage(for: healthEvidenceItems))
    }

    private var forbiddenFlagsAreFalse: Bool {
        callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && opensPrivateWebSocket == false
            && runsPrivateStreamRuntime == false
            && runsAccountSnapshotRuntime == false
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
        freshnessEvidenceContractID: Identifier,
        freshnessEvidenceChecksum: String,
        healthEvidenceItems: [LiveMonitoringSimulationGateHealthEvidenceItem],
        allowedFreshnessStatuses: [SimulatedAccountSnapshotFreshnessEvidenceStatus],
        allowedHealthStatuses: [LiveMonitoringSimulationGateHealthStatus],
        checksum: String,
        checksumMatchedCanonicalPreimage: Bool,
        fixtureSimulatedReadModelOnly: Bool,
        forbiddenCapabilities: [LiveMonitoringSimulationGateHealthForbiddenCapability]
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
        guard freshnessEvidenceContractID == Self.requiredFreshnessEvidenceContractID else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "freshnessEvidenceContractID",
                expected: Self.requiredFreshnessEvidenceContractID.rawValue,
                actual: freshnessEvidenceContractID.rawValue
            )
        }
        guard freshnessEvidenceChecksum == Self.requiredFreshnessEvidenceChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "freshnessEvidenceChecksum",
                expected: Self.requiredFreshnessEvidenceChecksum,
                actual: freshnessEvidenceChecksum
            )
        }
        guard healthEvidenceItems == Self.requiredHealthEvidenceItems else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "healthEvidenceItems",
                expected: Self.requiredHealthEvidenceItems.map(\.freshnessStatus.rawValue).joined(separator: ","),
                actual: healthEvidenceItems.map(\.freshnessStatus.rawValue).joined(separator: ",")
            )
        }
        guard healthEvidenceItems.allSatisfy(\.simulationGateHealthBoundaryHeld) else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("simulationGateHealthBoundaryHeld")
        }
        guard allowedFreshnessStatuses == Self.requiredAllowedFreshnessStatuses else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "allowedFreshnessStatuses",
                expected: Self.requiredAllowedFreshnessStatuses.map(\.rawValue).joined(separator: ","),
                actual: allowedFreshnessStatuses.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedHealthStatuses == Self.requiredAllowedHealthStatuses else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "allowedHealthStatuses",
                expected: Self.requiredAllowedHealthStatuses.map(\.rawValue).joined(separator: ","),
                actual: allowedHealthStatuses.map(\.rawValue).joined(separator: ",")
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
        guard fixtureSimulatedReadModelOnly else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("fixtureSimulatedReadModelOnly")
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
