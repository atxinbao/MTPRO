import Foundation

/// LiveMonitoringStatus 固定 MTP-69 允许进入最小 health / connection read model 的状态分类。
///
/// 这些值只用于 read-model-only evidence。`healthy` 只是后续观察值的展示标签，不代表当前已启动
/// live runtime、建立真实连接、完成 signed endpoint gate 或授权真实交易。
public enum LiveMonitoringStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case healthy = "healthy"
    case blocked = "blocked"
    case disconnected = "disconnected"
    case degraded = "degraded"
    case unavailable = "unavailable"
}

/// LiveConnectionKind 定义 MTP-69 最小 connection status read model 覆盖的连接类别。
///
/// public market data 仍只能来自 public read-only 边界；future private user data 和 future broker
/// session 只能作为 blocked / unavailable evidence 出现，不能创建 listenKey、private WebSocket、
/// broker session 或 execution venue connection。
public enum LiveConnectionKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case publicMarketData = "public market data connection"
    case futurePrivateUserData = "future private user data connection"
    case futureBrokerSession = "future broker session"
}

/// LiveConnectionStatusReadModel 是 MTP-69 的最小 connection status 只读证据。
///
/// 它只保存状态标签、source anchor 和禁区 flag；不会打开网络连接、创建 WebSocket / listenKey、
/// 调用 signed / account endpoint、实例化 broker adapter、暴露 Runtime object 或 schema，也不提供
/// reconnect / start / stop live command。
public struct LiveConnectionStatusReadModel: Codable, Equatable, Sendable {
    public let connectionID: Identifier
    public let issueID: Identifier
    public let connectionKind: LiveConnectionKind
    public let status: LiveMonitoringStatus
    public let sourceAnchors: [String]
    public let lastObservedAt: Date
    public let isReadModelOnly: Bool
    public let isFutureEvidence: Bool
    public let hasActiveNetworkConnection: Bool
    public let opensWebSocket: Bool
    public let usesPrivateWebSocket: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let readsAPIKey: Bool
    public let readsSecret: Bool
    public let readsAccountPayload: Bool
    public let instantiatesBrokerAdapter: Bool
    public let exposesAdapterSurface: Bool
    public let exposesRuntimeObject: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let providesReconnectCommand: Bool
    public let providesStartStopCommand: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool

    public var connectionBoundaryHeld: Bool {
        sourceAnchors == Self.requiredSourceAnchors(for: connectionKind)
            && LiveMonitoringStatus.allCases.contains(status)
            && isReadModelOnly
            && isFutureEvidence
            && hasActiveNetworkConnection == false
            && opensWebSocket == false
            && usesPrivateWebSocket == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && readsAPIKey == false
            && readsSecret == false
            && readsAccountPayload == false
            && instantiatesBrokerAdapter == false
            && exposesAdapterSurface == false
            && exposesRuntimeObject == false
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && providesReconnectCommand == false
            && providesStartStopCommand == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
    }

    public init(
        connectionID: Identifier,
        issueID: Identifier = try! Identifier("MTP-69"),
        connectionKind: LiveConnectionKind,
        status: LiveMonitoringStatus,
        sourceAnchors: [String]? = nil,
        lastObservedAt: Date = Date(timeIntervalSince1970: 6_900),
        isReadModelOnly: Bool = true,
        isFutureEvidence: Bool = true,
        hasActiveNetworkConnection: Bool = false,
        opensWebSocket: Bool = false,
        usesPrivateWebSocket: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        readsAPIKey: Bool = false,
        readsSecret: Bool = false,
        readsAccountPayload: Bool = false,
        instantiatesBrokerAdapter: Bool = false,
        exposesAdapterSurface: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesSQLiteSchema: Bool = false,
        exposesDuckDBSchema: Bool = false,
        providesReconnectCommand: Bool = false,
        providesStartStopCommand: Bool = false,
        authorizesLiveTrading: Bool = false,
        authorizesTradingExecution: Bool = false
    ) throws {
        let anchors = sourceAnchors ?? Self.requiredSourceAnchors(for: connectionKind)
        guard anchors == Self.requiredSourceAnchors(for: connectionKind) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceAnchors",
                expected: Self.requiredSourceAnchors(for: connectionKind).joined(separator: ","),
                actual: anchors.joined(separator: ",")
            )
        }
        guard LiveMonitoringStatus.allCases.contains(status) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "status",
                expected: LiveMonitoringStatus.allCases.map(\.rawValue).joined(separator: ","),
                actual: status.rawValue
            )
        }
        try Self.validateForbiddenFlags(
            isReadModelOnly: isReadModelOnly,
            isFutureEvidence: isFutureEvidence,
            hasActiveNetworkConnection: hasActiveNetworkConnection,
            opensWebSocket: opensWebSocket,
            usesPrivateWebSocket: usesPrivateWebSocket,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            readsAPIKey: readsAPIKey,
            readsSecret: readsSecret,
            readsAccountPayload: readsAccountPayload,
            instantiatesBrokerAdapter: instantiatesBrokerAdapter,
            exposesAdapterSurface: exposesAdapterSurface,
            exposesRuntimeObject: exposesRuntimeObject,
            exposesSQLiteSchema: exposesSQLiteSchema,
            exposesDuckDBSchema: exposesDuckDBSchema,
            providesReconnectCommand: providesReconnectCommand,
            providesStartStopCommand: providesStartStopCommand,
            authorizesLiveTrading: authorizesLiveTrading,
            authorizesTradingExecution: authorizesTradingExecution
        )

        self.connectionID = connectionID
        self.issueID = issueID
        self.connectionKind = connectionKind
        self.status = status
        self.sourceAnchors = anchors
        self.lastObservedAt = lastObservedAt
        self.isReadModelOnly = isReadModelOnly
        self.isFutureEvidence = isFutureEvidence
        self.hasActiveNetworkConnection = hasActiveNetworkConnection
        self.opensWebSocket = opensWebSocket
        self.usesPrivateWebSocket = usesPrivateWebSocket
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.readsAPIKey = readsAPIKey
        self.readsSecret = readsSecret
        self.readsAccountPayload = readsAccountPayload
        self.instantiatesBrokerAdapter = instantiatesBrokerAdapter
        self.exposesAdapterSurface = exposesAdapterSurface
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesSQLiteSchema = exposesSQLiteSchema
        self.exposesDuckDBSchema = exposesDuckDBSchema
        self.providesReconnectCommand = providesReconnectCommand
        self.providesStartStopCommand = providesStartStopCommand
        self.authorizesLiveTrading = authorizesLiveTrading
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            connectionID: try container.decode(Identifier.self, forKey: .connectionID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            connectionKind: try container.decode(LiveConnectionKind.self, forKey: .connectionKind),
            status: try container.decode(LiveMonitoringStatus.self, forKey: .status),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            lastObservedAt: try container.decode(Date.self, forKey: .lastObservedAt),
            isReadModelOnly: try container.decode(Bool.self, forKey: .isReadModelOnly),
            isFutureEvidence: try container.decode(Bool.self, forKey: .isFutureEvidence),
            hasActiveNetworkConnection: try container.decode(Bool.self, forKey: .hasActiveNetworkConnection),
            opensWebSocket: try container.decode(Bool.self, forKey: .opensWebSocket),
            usesPrivateWebSocket: try container.decode(Bool.self, forKey: .usesPrivateWebSocket),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            readsAccountPayload: try container.decode(Bool.self, forKey: .readsAccountPayload),
            instantiatesBrokerAdapter: try container.decode(Bool.self, forKey: .instantiatesBrokerAdapter),
            exposesAdapterSurface: try container.decode(Bool.self, forKey: .exposesAdapterSurface),
            exposesRuntimeObject: try container.decode(Bool.self, forKey: .exposesRuntimeObject),
            exposesSQLiteSchema: try container.decode(Bool.self, forKey: .exposesSQLiteSchema),
            exposesDuckDBSchema: try container.decode(Bool.self, forKey: .exposesDuckDBSchema),
            providesReconnectCommand: try container.decode(Bool.self, forKey: .providesReconnectCommand),
            providesStartStopCommand: try container.decode(Bool.self, forKey: .providesStartStopCommand),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            authorizesTradingExecution: try container.decode(Bool.self, forKey: .authorizesTradingExecution)
        )
    }

    public static func requiredSourceAnchors(for connectionKind: LiveConnectionKind) -> [String] {
        switch connectionKind {
        case .publicMarketData:
            [
                "MTP-68-LIVE-MONITORING-READ-MODEL-ONLY",
                "MTP-69-CONNECTION-STATUS-READ-MODEL",
                "BinanceReadOnlyAdapterBoundary"
            ]
        case .futurePrivateUserData:
            [
                "MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY",
                "MTP-68-LIVE-MONITORING-READ-MODEL-ONLY",
                "MTP-69-CONNECTION-STATUS-READ-MODEL"
            ]
        case .futureBrokerSession:
            [
                "MTP-63-ADAPTER-CAPABILITY-ISOLATION",
                "MTP-68-LIVE-MONITORING-READ-MODEL-ONLY",
                "MTP-69-CONNECTION-STATUS-READ-MODEL"
            ]
        }
    }

    private static func validateForbiddenFlags(
        isReadModelOnly: Bool,
        isFutureEvidence: Bool,
        hasActiveNetworkConnection: Bool,
        opensWebSocket: Bool,
        usesPrivateWebSocket: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        readsAPIKey: Bool,
        readsSecret: Bool,
        readsAccountPayload: Bool,
        instantiatesBrokerAdapter: Bool,
        exposesAdapterSurface: Bool,
        exposesRuntimeObject: Bool,
        exposesSQLiteSchema: Bool,
        exposesDuckDBSchema: Bool,
        providesReconnectCommand: Bool,
        providesStartStopCommand: Bool,
        authorizesLiveTrading: Bool,
        authorizesTradingExecution: Bool
    ) throws {
        guard isReadModelOnly else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("isReadModelOnly")
        }
        guard isFutureEvidence else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("isFutureEvidence")
        }

        let forbiddenFlags = [
            ("hasActiveNetworkConnection", hasActiveNetworkConnection),
            ("opensWebSocket", opensWebSocket),
            ("usesPrivateWebSocket", usesPrivateWebSocket),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("readsAPIKey", readsAPIKey),
            ("readsSecret", readsSecret),
            ("readsAccountPayload", readsAccountPayload),
            ("instantiatesBrokerAdapter", instantiatesBrokerAdapter),
            ("exposesAdapterSurface", exposesAdapterSurface),
            ("exposesRuntimeObject", exposesRuntimeObject),
            ("exposesSQLiteSchema", exposesSQLiteSchema),
            ("exposesDuckDBSchema", exposesDuckDBSchema),
            ("providesReconnectCommand", providesReconnectCommand),
            ("providesStartStopCommand", providesStartStopCommand),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("authorizesTradingExecution", authorizesTradingExecution)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveMonitoringConsoleForbiddenCapability(capability.0)
        }
    }
}

/// LiveRuntimeHealthReadModel 是 MTP-69 的最小 future live runtime health 只读快照。
///
/// 该模型聚合 health status 和 connection status evidence，服务后续 Dashboard / Report /
/// Event Timeline 的只读输入。它不启动 runtime，不轮询生产 health，不建立网络连接，不读取 secret /
/// account payload，不暴露 Runtime object 或 persistence schema，也不提供 reconnect / start / stop
/// live command。
public struct LiveRuntimeHealthReadModel: Codable, Equatable, Sendable {
    public let healthID: Identifier
    public let issueID: Identifier
    public let status: LiveMonitoringStatus
    public let sourceAnchors: [String]
    public let allowedStatuses: [LiveMonitoringStatus]
    public let connections: [LiveConnectionStatusReadModel]
    public let updatedAt: Date
    public let isReadModelOnly: Bool
    public let providesCommandSurface: Bool
    public let startsLiveRuntime: Bool
    public let stopsLiveRuntime: Bool
    public let pollsRuntimeHealth: Bool
    public let opensNetworkConnection: Bool
    public let readsAPIKey: Bool
    public let readsSecret: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let readsAccountPayload: Bool
    public let instantiatesBrokerAdapter: Bool
    public let exposesAdapterSurface: Bool
    public let exposesRuntimeObject: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var runtimeHealthBoundaryHeld: Bool {
        sourceAnchors == Self.requiredSourceAnchors
            && allowedStatuses == LiveMonitoringStatus.allCases
            && allowedStatuses.contains(status)
            && connections == Self.requiredConnectionStatuses
            && connectionStatusBoundaryHeld
            && isReadModelOnly
            && providesCommandSurface == false
            && startsLiveRuntime == false
            && stopsLiveRuntime == false
            && pollsRuntimeHealth == false
            && opensNetworkConnection == false
            && readsAPIKey == false
            && readsSecret == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && readsAccountPayload == false
            && instantiatesBrokerAdapter == false
            && exposesAdapterSurface == false
            && exposesRuntimeObject == false
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
    }

    public var connectionStatusBoundaryHeld: Bool {
        connections.allSatisfy(\.connectionBoundaryHeld)
    }

    public init(
        healthID: Identifier = try! Identifier("mtp-69-live-runtime-health"),
        issueID: Identifier = try! Identifier("MTP-69"),
        status: LiveMonitoringStatus = .blocked,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        allowedStatuses: [LiveMonitoringStatus] = LiveMonitoringStatus.allCases,
        connections: [LiveConnectionStatusReadModel] = Self.requiredConnectionStatuses,
        updatedAt: Date = Date(timeIntervalSince1970: 6_901),
        isReadModelOnly: Bool = true,
        providesCommandSurface: Bool = false,
        startsLiveRuntime: Bool = false,
        stopsLiveRuntime: Bool = false,
        pollsRuntimeHealth: Bool = false,
        opensNetworkConnection: Bool = false,
        readsAPIKey: Bool = false,
        readsSecret: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        readsAccountPayload: Bool = false,
        instantiatesBrokerAdapter: Bool = false,
        exposesAdapterSurface: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesSQLiteSchema: Bool = false,
        exposesDuckDBSchema: Bool = false,
        authorizesLiveTrading: Bool = false,
        authorizesTradingExecution: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        guard sourceAnchors == Self.requiredSourceAnchors else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceAnchors",
                expected: Self.requiredSourceAnchors.joined(separator: ","),
                actual: sourceAnchors.joined(separator: ",")
            )
        }
        guard allowedStatuses == LiveMonitoringStatus.allCases else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "allowedStatuses",
                expected: LiveMonitoringStatus.allCases.map(\.rawValue).joined(separator: ","),
                actual: allowedStatuses.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedStatuses.contains(status) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "status",
                expected: allowedStatuses.map(\.rawValue).joined(separator: ","),
                actual: status.rawValue
            )
        }
        try Self.validate(connections: connections)
        try Self.validateForbiddenFlags(
            isReadModelOnly: isReadModelOnly,
            providesCommandSurface: providesCommandSurface,
            startsLiveRuntime: startsLiveRuntime,
            stopsLiveRuntime: stopsLiveRuntime,
            pollsRuntimeHealth: pollsRuntimeHealth,
            opensNetworkConnection: opensNetworkConnection,
            readsAPIKey: readsAPIKey,
            readsSecret: readsSecret,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            readsAccountPayload: readsAccountPayload,
            instantiatesBrokerAdapter: instantiatesBrokerAdapter,
            exposesAdapterSurface: exposesAdapterSurface,
            exposesRuntimeObject: exposesRuntimeObject,
            exposesSQLiteSchema: exposesSQLiteSchema,
            exposesDuckDBSchema: exposesDuckDBSchema,
            authorizesLiveTrading: authorizesLiveTrading,
            authorizesTradingExecution: authorizesTradingExecution,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.healthID = healthID
        self.issueID = issueID
        self.status = status
        self.sourceAnchors = sourceAnchors
        self.allowedStatuses = allowedStatuses
        self.connections = connections
        self.updatedAt = updatedAt
        self.isReadModelOnly = isReadModelOnly
        self.providesCommandSurface = providesCommandSurface
        self.startsLiveRuntime = startsLiveRuntime
        self.stopsLiveRuntime = stopsLiveRuntime
        self.pollsRuntimeHealth = pollsRuntimeHealth
        self.opensNetworkConnection = opensNetworkConnection
        self.readsAPIKey = readsAPIKey
        self.readsSecret = readsSecret
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.readsAccountPayload = readsAccountPayload
        self.instantiatesBrokerAdapter = instantiatesBrokerAdapter
        self.exposesAdapterSurface = exposesAdapterSurface
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesSQLiteSchema = exposesSQLiteSchema
        self.exposesDuckDBSchema = exposesDuckDBSchema
        self.authorizesLiveTrading = authorizesLiveTrading
        self.authorizesTradingExecution = authorizesTradingExecution
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            healthID: try container.decode(Identifier.self, forKey: .healthID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            status: try container.decode(LiveMonitoringStatus.self, forKey: .status),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            allowedStatuses: try container.decode([LiveMonitoringStatus].self, forKey: .allowedStatuses),
            connections: try container.decode([LiveConnectionStatusReadModel].self, forKey: .connections),
            updatedAt: try container.decode(Date.self, forKey: .updatedAt),
            isReadModelOnly: try container.decode(Bool.self, forKey: .isReadModelOnly),
            providesCommandSurface: try container.decode(Bool.self, forKey: .providesCommandSurface),
            startsLiveRuntime: try container.decode(Bool.self, forKey: .startsLiveRuntime),
            stopsLiveRuntime: try container.decode(Bool.self, forKey: .stopsLiveRuntime),
            pollsRuntimeHealth: try container.decode(Bool.self, forKey: .pollsRuntimeHealth),
            opensNetworkConnection: try container.decode(Bool.self, forKey: .opensNetworkConnection),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            readsAccountPayload: try container.decode(Bool.self, forKey: .readsAccountPayload),
            instantiatesBrokerAdapter: try container.decode(Bool.self, forKey: .instantiatesBrokerAdapter),
            exposesAdapterSurface: try container.decode(Bool.self, forKey: .exposesAdapterSurface),
            exposesRuntimeObject: try container.decode(Bool.self, forKey: .exposesRuntimeObject),
            exposesSQLiteSchema: try container.decode(Bool.self, forKey: .exposesSQLiteSchema),
            exposesDuckDBSchema: try container.decode(Bool.self, forKey: .exposesDuckDBSchema),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            authorizesTradingExecution: try container.decode(Bool.self, forKey: .authorizesTradingExecution),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredSourceAnchors: [String] = [
        "MTP-68-LIVE-MONITORING-CONSOLE-IA",
        "MTP-68-LIVE-MONITORING-STATUS-TAXONOMY",
        "MTP-69-LIVE-RUNTIME-HEALTH-READ-MODEL",
        "MTP-69-CONNECTION-STATUS-READ-MODEL"
    ]

    public static let requiredConnectionStatuses: [LiveConnectionStatusReadModel] = [
        Self.makeConnection(
            "mtp-69-public-market-disconnected",
            kind: .publicMarketData,
            status: .disconnected
        ),
        Self.makeConnection(
            "mtp-69-private-user-data-blocked",
            kind: .futurePrivateUserData,
            status: .blocked
        ),
        Self.makeConnection(
            "mtp-69-broker-session-unavailable",
            kind: .futureBrokerSession,
            status: .unavailable
        )
    ]

    public static let deterministicFixture: LiveRuntimeHealthReadModel = {
        do {
            return try LiveRuntimeHealthReadModel()
        } catch {
            preconditionFailure("MTP-69 live runtime health fixture must be valid: \(error)")
        }
    }()

    private static func makeConnection(
        _ connectionID: String,
        kind: LiveConnectionKind,
        status: LiveMonitoringStatus
    ) -> LiveConnectionStatusReadModel {
        do {
            return try LiveConnectionStatusReadModel(
                connectionID: try Identifier(connectionID),
                connectionKind: kind,
                status: status
            )
        } catch {
            preconditionFailure("MTP-69 connection status fixture must be valid: \(error)")
        }
    }

    private static func validate(connections: [LiveConnectionStatusReadModel]) throws {
        guard connections == Self.requiredConnectionStatuses else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "connections",
                expected: Self.requiredConnectionStatuses
                    .map(\.connectionKind.rawValue)
                    .joined(separator: ","),
                actual: connections
                    .map(\.connectionKind.rawValue)
                    .joined(separator: ",")
            )
        }
        guard connections.allSatisfy(\.connectionBoundaryHeld) else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("connections")
        }
    }

    private static func validateForbiddenFlags(
        isReadModelOnly: Bool,
        providesCommandSurface: Bool,
        startsLiveRuntime: Bool,
        stopsLiveRuntime: Bool,
        pollsRuntimeHealth: Bool,
        opensNetworkConnection: Bool,
        readsAPIKey: Bool,
        readsSecret: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        readsAccountPayload: Bool,
        instantiatesBrokerAdapter: Bool,
        exposesAdapterSurface: Bool,
        exposesRuntimeObject: Bool,
        exposesSQLiteSchema: Bool,
        exposesDuckDBSchema: Bool,
        authorizesLiveTrading: Bool,
        authorizesTradingExecution: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isReadModelOnly else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("isReadModelOnly")
        }

        let forbiddenFlags = [
            ("providesCommandSurface", providesCommandSurface),
            ("startsLiveRuntime", startsLiveRuntime),
            ("stopsLiveRuntime", stopsLiveRuntime),
            ("pollsRuntimeHealth", pollsRuntimeHealth),
            ("opensNetworkConnection", opensNetworkConnection),
            ("readsAPIKey", readsAPIKey),
            ("readsSecret", readsSecret),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("readsAccountPayload", readsAccountPayload),
            ("instantiatesBrokerAdapter", instantiatesBrokerAdapter),
            ("exposesAdapterSurface", exposesAdapterSurface),
            ("exposesRuntimeObject", exposesRuntimeObject),
            ("exposesSQLiteSchema", exposesSQLiteSchema),
            ("exposesDuckDBSchema", exposesDuckDBSchema),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("authorizesTradingExecution", authorizesTradingExecution),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveMonitoringConsoleForbiddenCapability(capability.0)
        }
    }
}
