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

/// LiveStreamMonitoringEvidenceKind 定义 MTP-70 stream evidence 的允许类型。
///
/// 这些类型只服务 market stream / order stream 的只读 evidence；它们不创建真实 stream
/// runtime，不订阅 public / private WebSocket，不消费 execution report，也不表示 broker fill。
public enum LiveStreamMonitoringEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case publicReadOnlyMarketEvidence = "public read-only market stream evidence"
    case blockedOrderStreamEvidence = "blocked order stream evidence"
    case simulatedPaperOrderEvidence = "simulated paper order evidence"
    case futureOrderStreamGate = "future order stream gate evidence"
}

/// LiveStreamMonitoringKind 固定 MTP-70 read model 覆盖的 stream 分区。
///
/// `publicMarketStream` 只能对应 public read-only / fixture evidence；三个 order stream 分区只
/// 表达 blocked、simulated 和 future-only evidence，不得被解释为 real order state machine、
/// execution report、broker fill、OMS 或真实账户状态。
public enum LiveStreamMonitoringKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case publicMarketStream = "public market stream"
    case blockedOrderStream = "blocked order stream"
    case simulatedOrderStream = "simulated order stream"
    case futureOrderStream = "future order stream"
}

/// LiveStreamMonitoringEvidenceItem 是 MTP-70 的单项 stream evidence read model。
///
/// 该类型只保存 stream 分区、状态标签、source anchors 和禁区 flag。market stream 不能打开
/// public WebSocket 或生产订阅控制；order stream 只能展示 blocked / simulated / future evidence，
/// 不能创建 listenKey、account endpoint、execution report、broker fill 或真实订单状态机。
public struct LiveStreamMonitoringEvidenceItem: Codable, Equatable, Sendable {
    public let streamID: Identifier
    public let issueID: Identifier
    public let streamKind: LiveStreamMonitoringKind
    public let status: LiveMonitoringStatus
    public let evidenceKind: LiveStreamMonitoringEvidenceKind
    public let sourceAnchors: [String]
    public let paperEvidenceIDs: [Identifier]
    public let observedAt: Date
    public let isReadModelOnly: Bool
    public let isPublicReadOnlyMarketEvidence: Bool
    public let isBlockedEvidence: Bool
    public let isSimulatedEvidence: Bool
    public let isFutureEvidence: Bool
    public let hasActiveMarketStream: Bool
    public let hasActiveOrderStream: Bool
    public let opensMarketWebSocket: Bool
    public let opensPrivateUserDataStream: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let readsAPIKey: Bool
    public let readsSecret: Bool
    public let readsAccountPayload: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let implementsRealOrderStateMachine: Bool
    public let providesOrderCommand: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let instantiatesBrokerAdapter: Bool
    public let exposesAdapterSurface: Bool
    public let exposesRuntimeObject: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var isOrderStreamEvidence: Bool {
        switch streamKind {
        case .publicMarketStream:
            false
        case .blockedOrderStream, .simulatedOrderStream, .futureOrderStream:
            true
        }
    }

    public var streamBoundaryHeld: Bool {
        sourceAnchors == Self.requiredSourceAnchors(for: streamKind)
            && evidenceKind == Self.requiredEvidenceKind(for: streamKind)
            && status == Self.requiredStatus(for: streamKind)
            && paperEvidenceIDs == Self.requiredPaperEvidenceIDs(for: streamKind)
            && Self.modeFlags(
                isPublicReadOnlyMarketEvidence,
                isBlockedEvidence,
                isSimulatedEvidence,
                isFutureEvidence
            ) == Self.requiredModeFlags(for: streamKind)
            && isReadModelOnly
            && hasActiveMarketStream == false
            && hasActiveOrderStream == false
            && opensMarketWebSocket == false
            && opensPrivateUserDataStream == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && readsAPIKey == false
            && readsSecret == false
            && readsAccountPayload == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && implementsRealOrderStateMachine == false
            && providesOrderCommand == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && instantiatesBrokerAdapter == false
            && exposesAdapterSurface == false
            && exposesRuntimeObject == false
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        streamID: Identifier,
        issueID: Identifier = try! Identifier("MTP-70"),
        streamKind: LiveStreamMonitoringKind,
        status: LiveMonitoringStatus? = nil,
        evidenceKind: LiveStreamMonitoringEvidenceKind? = nil,
        sourceAnchors: [String]? = nil,
        paperEvidenceIDs: [Identifier]? = nil,
        observedAt: Date = Date(timeIntervalSince1970: 7_000),
        isReadModelOnly: Bool = true,
        isPublicReadOnlyMarketEvidence: Bool? = nil,
        isBlockedEvidence: Bool? = nil,
        isSimulatedEvidence: Bool? = nil,
        isFutureEvidence: Bool? = nil,
        hasActiveMarketStream: Bool = false,
        hasActiveOrderStream: Bool = false,
        opensMarketWebSocket: Bool = false,
        opensPrivateUserDataStream: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        readsAPIKey: Bool = false,
        readsSecret: Bool = false,
        readsAccountPayload: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        implementsRealOrderStateMachine: Bool = false,
        providesOrderCommand: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        instantiatesBrokerAdapter: Bool = false,
        exposesAdapterSurface: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesSQLiteSchema: Bool = false,
        exposesDuckDBSchema: Bool = false,
        authorizesLiveTrading: Bool = false,
        authorizesTradingExecution: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        let requiredStatus = Self.requiredStatus(for: streamKind)
        let requiredEvidenceKind = Self.requiredEvidenceKind(for: streamKind)
        let anchors = sourceAnchors ?? Self.requiredSourceAnchors(for: streamKind)
        let paperEvidenceIDs = paperEvidenceIDs ?? Self.requiredPaperEvidenceIDs(for: streamKind)
        let requiredModeFlags = Self.requiredModeFlags(for: streamKind)
        let actualModeFlags = Self.modeFlags(
            isPublicReadOnlyMarketEvidence ?? requiredModeFlags[0],
            isBlockedEvidence ?? requiredModeFlags[1],
            isSimulatedEvidence ?? requiredModeFlags[2],
            isFutureEvidence ?? requiredModeFlags[3]
        )

        guard status ?? requiredStatus == requiredStatus else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "status",
                expected: requiredStatus.rawValue,
                actual: (status ?? requiredStatus).rawValue
            )
        }
        guard evidenceKind ?? requiredEvidenceKind == requiredEvidenceKind else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "evidenceKind",
                expected: requiredEvidenceKind.rawValue,
                actual: (evidenceKind ?? requiredEvidenceKind).rawValue
            )
        }
        guard anchors == Self.requiredSourceAnchors(for: streamKind) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceAnchors",
                expected: Self.requiredSourceAnchors(for: streamKind).joined(separator: ","),
                actual: anchors.joined(separator: ",")
            )
        }
        guard paperEvidenceIDs == Self.requiredPaperEvidenceIDs(for: streamKind) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "paperEvidenceIDs",
                expected: Self.requiredPaperEvidenceIDs(for: streamKind)
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: paperEvidenceIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard actualModeFlags == requiredModeFlags else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "evidenceMode",
                expected: Self.describeModeFlags(requiredModeFlags),
                actual: Self.describeModeFlags(actualModeFlags)
            )
        }
        try Self.validateForbiddenFlags(
            isReadModelOnly: isReadModelOnly,
            hasActiveMarketStream: hasActiveMarketStream,
            hasActiveOrderStream: hasActiveOrderStream,
            opensMarketWebSocket: opensMarketWebSocket,
            opensPrivateUserDataStream: opensPrivateUserDataStream,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            readsAPIKey: readsAPIKey,
            readsSecret: readsSecret,
            readsAccountPayload: readsAccountPayload,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            providesOrderCommand: providesOrderCommand,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            instantiatesBrokerAdapter: instantiatesBrokerAdapter,
            exposesAdapterSurface: exposesAdapterSurface,
            exposesRuntimeObject: exposesRuntimeObject,
            exposesSQLiteSchema: exposesSQLiteSchema,
            exposesDuckDBSchema: exposesDuckDBSchema,
            authorizesLiveTrading: authorizesLiveTrading,
            authorizesTradingExecution: authorizesTradingExecution,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.streamID = streamID
        self.issueID = issueID
        self.streamKind = streamKind
        self.status = requiredStatus
        self.evidenceKind = requiredEvidenceKind
        self.sourceAnchors = anchors
        self.paperEvidenceIDs = paperEvidenceIDs
        self.observedAt = observedAt
        self.isReadModelOnly = isReadModelOnly
        self.isPublicReadOnlyMarketEvidence = actualModeFlags[0]
        self.isBlockedEvidence = actualModeFlags[1]
        self.isSimulatedEvidence = actualModeFlags[2]
        self.isFutureEvidence = actualModeFlags[3]
        self.hasActiveMarketStream = hasActiveMarketStream
        self.hasActiveOrderStream = hasActiveOrderStream
        self.opensMarketWebSocket = opensMarketWebSocket
        self.opensPrivateUserDataStream = opensPrivateUserDataStream
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.readsAPIKey = readsAPIKey
        self.readsSecret = readsSecret
        self.readsAccountPayload = readsAccountPayload
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.providesOrderCommand = providesOrderCommand
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
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
            streamID: try container.decode(Identifier.self, forKey: .streamID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            streamKind: try container.decode(LiveStreamMonitoringKind.self, forKey: .streamKind),
            status: try container.decode(LiveMonitoringStatus.self, forKey: .status),
            evidenceKind: try container.decode(LiveStreamMonitoringEvidenceKind.self, forKey: .evidenceKind),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            paperEvidenceIDs: try container.decode([Identifier].self, forKey: .paperEvidenceIDs),
            observedAt: try container.decode(Date.self, forKey: .observedAt),
            isReadModelOnly: try container.decode(Bool.self, forKey: .isReadModelOnly),
            isPublicReadOnlyMarketEvidence: try container.decode(
                Bool.self,
                forKey: .isPublicReadOnlyMarketEvidence
            ),
            isBlockedEvidence: try container.decode(Bool.self, forKey: .isBlockedEvidence),
            isSimulatedEvidence: try container.decode(Bool.self, forKey: .isSimulatedEvidence),
            isFutureEvidence: try container.decode(Bool.self, forKey: .isFutureEvidence),
            hasActiveMarketStream: try container.decode(Bool.self, forKey: .hasActiveMarketStream),
            hasActiveOrderStream: try container.decode(Bool.self, forKey: .hasActiveOrderStream),
            opensMarketWebSocket: try container.decode(Bool.self, forKey: .opensMarketWebSocket),
            opensPrivateUserDataStream: try container.decode(Bool.self, forKey: .opensPrivateUserDataStream),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            readsAccountPayload: try container.decode(Bool.self, forKey: .readsAccountPayload),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            implementsRealOrderStateMachine: try container.decode(
                Bool.self,
                forKey: .implementsRealOrderStateMachine
            ),
            providesOrderCommand: try container.decode(Bool.self, forKey: .providesOrderCommand),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
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

    public static func requiredStatus(for streamKind: LiveStreamMonitoringKind) -> LiveMonitoringStatus {
        switch streamKind {
        case .publicMarketStream:
            .disconnected
        case .blockedOrderStream, .simulatedOrderStream:
            .blocked
        case .futureOrderStream:
            .unavailable
        }
    }

    public static func requiredEvidenceKind(
        for streamKind: LiveStreamMonitoringKind
    ) -> LiveStreamMonitoringEvidenceKind {
        switch streamKind {
        case .publicMarketStream:
            .publicReadOnlyMarketEvidence
        case .blockedOrderStream:
            .blockedOrderStreamEvidence
        case .simulatedOrderStream:
            .simulatedPaperOrderEvidence
        case .futureOrderStream:
            .futureOrderStreamGate
        }
    }

    public static func requiredSourceAnchors(for streamKind: LiveStreamMonitoringKind) -> [String] {
        switch streamKind {
        case .publicMarketStream:
            [
                "MTP-68-LIVE-MONITORING-READ-MODEL-ONLY",
                "MTP-70-MARKET-STREAM-PUBLIC-READ-ONLY-EVIDENCE",
                "BinanceReadOnlyAdapterBoundary"
            ]
        case .blockedOrderStream:
            [
                "MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY",
                "MTP-63-ADAPTER-CAPABILITY-ISOLATION",
                "MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY",
                "MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE",
                "MTP-70-ORDER-STREAM-BLOCKED-SIMULATED-FUTURE-EVIDENCE"
            ]
        case .simulatedOrderStream:
            [
                "TVM-PAPER-EXECUTION-WORKFLOW",
                "MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE",
                "MTP-70-ORDER-STREAM-BLOCKED-SIMULATED-FUTURE-EVIDENCE"
            ]
        case .futureOrderStream:
            [
                "MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY",
                "MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE",
                "MTP-70-ORDER-STREAM-BLOCKED-SIMULATED-FUTURE-EVIDENCE"
            ]
        }
    }

    public static func requiredPaperEvidenceIDs(for streamKind: LiveStreamMonitoringKind) -> [Identifier] {
        switch streamKind {
        case .publicMarketStream, .blockedOrderStream, .futureOrderStream:
            []
        case .simulatedOrderStream:
            [
                try! Identifier("paper-replay-order-allowed"),
                try! Identifier("paper-replay-fill-allowed")
            ]
        }
    }

    private static func requiredModeFlags(for streamKind: LiveStreamMonitoringKind) -> [Bool] {
        switch streamKind {
        case .publicMarketStream:
            modeFlags(true, false, false, false)
        case .blockedOrderStream:
            modeFlags(false, true, false, false)
        case .simulatedOrderStream:
            modeFlags(false, false, true, false)
        case .futureOrderStream:
            modeFlags(false, false, false, true)
        }
    }

    private static func modeFlags(
        _ isPublicReadOnlyMarketEvidence: Bool,
        _ isBlockedEvidence: Bool,
        _ isSimulatedEvidence: Bool,
        _ isFutureEvidence: Bool
    ) -> [Bool] {
        [
            isPublicReadOnlyMarketEvidence,
            isBlockedEvidence,
            isSimulatedEvidence,
            isFutureEvidence
        ]
    }

    private static func describeModeFlags(_ values: [Bool]) -> String {
        [
            "publicMarket=\(values[0])",
            "blocked=\(values[1])",
            "simulated=\(values[2])",
            "future=\(values[3])"
        ].joined(separator: ",")
    }

    private static func validateForbiddenFlags(
        isReadModelOnly: Bool,
        hasActiveMarketStream: Bool,
        hasActiveOrderStream: Bool,
        opensMarketWebSocket: Bool,
        opensPrivateUserDataStream: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        readsAPIKey: Bool,
        readsSecret: Bool,
        readsAccountPayload: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        implementsRealOrderStateMachine: Bool,
        providesOrderCommand: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
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
            ("hasActiveMarketStream", hasActiveMarketStream),
            ("hasActiveOrderStream", hasActiveOrderStream),
            ("opensMarketWebSocket", opensMarketWebSocket),
            ("opensPrivateUserDataStream", opensPrivateUserDataStream),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("readsAPIKey", readsAPIKey),
            ("readsSecret", readsSecret),
            ("readsAccountPayload", readsAccountPayload),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("providesOrderCommand", providesOrderCommand),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
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

/// LiveStreamMonitoringEvidenceReadModel 汇总 MTP-70 的 market stream / order stream evidence。
///
/// 该 read model 以 MTP-69 runtime health 为上游，只额外表达四类 stream evidence。它不接入
/// 真实 market streaming runtime 或 account/order streaming runtime；订单流只保持 blocked、
/// simulated、future-only 三种证据，不能形成 real order state machine 或 order command。
public struct LiveStreamMonitoringEvidenceReadModel: Codable, Equatable, Sendable {
    public let readModelID: Identifier
    public let issueID: Identifier
    public let runtimeHealth: LiveRuntimeHealthReadModel
    public let sourceAnchors: [String]
    public let streamEvidence: [LiveStreamMonitoringEvidenceItem]
    public let updatedAt: Date
    public let isReadModelOnly: Bool
    public let providesCommandSurface: Bool
    public let opensMarketWebSocket: Bool
    public let opensPrivateUserDataStream: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let readsAPIKey: Bool
    public let readsSecret: Bool
    public let readsAccountPayload: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let implementsRealOrderStateMachine: Bool
    public let providesOrderCommand: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let instantiatesBrokerAdapter: Bool
    public let exposesAdapterSurface: Bool
    public let exposesRuntimeObject: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let authorizesLiveTrading: Bool
    public let authorizesTradingExecution: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var marketStreamEvidenceCount: Int {
        streamEvidence.filter { $0.streamKind == .publicMarketStream }.count
    }

    public var orderStreamEvidenceCount: Int {
        streamEvidence.filter(\.isOrderStreamEvidence).count
    }

    public var orderStreamEvidenceKinds: [LiveStreamMonitoringEvidenceKind] {
        streamEvidence
            .filter(\.isOrderStreamEvidence)
            .map(\.evidenceKind)
    }

    public var streamEvidenceBoundaryHeld: Bool {
        sourceAnchors == Self.requiredSourceAnchors
            && runtimeHealth == .deterministicFixture
            && runtimeHealth.runtimeHealthBoundaryHeld
            && streamEvidence == Self.requiredStreamEvidence
            && streamEvidence.allSatisfy(\.streamBoundaryHeld)
    }

    public var orderStreamEvidenceBoundaryHeld: Bool {
        let orderEvidence = streamEvidence.filter(\.isOrderStreamEvidence)
        return orderEvidence.map(\.streamKind) == [
            .blockedOrderStream,
            .simulatedOrderStream,
            .futureOrderStream
        ]
            && orderEvidence.map(\.evidenceKind) == [
                .blockedOrderStreamEvidence,
                .simulatedPaperOrderEvidence,
                .futureOrderStreamGate
            ]
            && orderEvidence.allSatisfy(\.streamBoundaryHeld)
            && orderEvidence.allSatisfy { $0.hasActiveOrderStream == false }
            && orderEvidence.allSatisfy { $0.opensPrivateUserDataStream == false }
            && orderEvidence.allSatisfy { $0.createsListenKey == false }
            && orderEvidence.allSatisfy { $0.consumesExecutionReport == false }
            && orderEvidence.allSatisfy { $0.recordsBrokerFill == false }
            && orderEvidence.allSatisfy { $0.implementsRealOrderStateMachine == false }
            && orderEvidence.allSatisfy { $0.providesOrderCommand == false }
    }

    public var readModelOnlyBoundaryHeld: Bool {
        streamEvidenceBoundaryHeld
            && orderStreamEvidenceBoundaryHeld
            && isReadModelOnly
            && providesCommandSurface == false
            && opensMarketWebSocket == false
            && opensPrivateUserDataStream == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && readsAPIKey == false
            && readsSecret == false
            && readsAccountPayload == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && implementsRealOrderStateMachine == false
            && providesOrderCommand == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && instantiatesBrokerAdapter == false
            && exposesAdapterSurface == false
            && exposesRuntimeObject == false
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && authorizesLiveTrading == false
            && authorizesTradingExecution == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        readModelID: Identifier = try! Identifier("mtp-70-live-stream-monitoring-evidence"),
        issueID: Identifier = try! Identifier("MTP-70"),
        runtimeHealth: LiveRuntimeHealthReadModel = .deterministicFixture,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        streamEvidence: [LiveStreamMonitoringEvidenceItem] = Self.requiredStreamEvidence,
        updatedAt: Date = Date(timeIntervalSince1970: 7_001),
        isReadModelOnly: Bool = true,
        providesCommandSurface: Bool = false,
        opensMarketWebSocket: Bool = false,
        opensPrivateUserDataStream: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        readsAPIKey: Bool = false,
        readsSecret: Bool = false,
        readsAccountPayload: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        implementsRealOrderStateMachine: Bool = false,
        providesOrderCommand: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        instantiatesBrokerAdapter: Bool = false,
        exposesAdapterSurface: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesSQLiteSchema: Bool = false,
        exposesDuckDBSchema: Bool = false,
        authorizesLiveTrading: Bool = false,
        authorizesTradingExecution: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        guard runtimeHealth == .deterministicFixture else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "runtimeHealth",
                expected: LiveRuntimeHealthReadModel.deterministicFixture.healthID.rawValue,
                actual: runtimeHealth.healthID.rawValue
            )
        }
        guard sourceAnchors == Self.requiredSourceAnchors else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceAnchors",
                expected: Self.requiredSourceAnchors.joined(separator: ","),
                actual: sourceAnchors.joined(separator: ",")
            )
        }
        try Self.validate(streamEvidence: streamEvidence)
        try Self.validateForbiddenFlags(
            isReadModelOnly: isReadModelOnly,
            providesCommandSurface: providesCommandSurface,
            opensMarketWebSocket: opensMarketWebSocket,
            opensPrivateUserDataStream: opensPrivateUserDataStream,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            readsAPIKey: readsAPIKey,
            readsSecret: readsSecret,
            readsAccountPayload: readsAccountPayload,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            providesOrderCommand: providesOrderCommand,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            instantiatesBrokerAdapter: instantiatesBrokerAdapter,
            exposesAdapterSurface: exposesAdapterSurface,
            exposesRuntimeObject: exposesRuntimeObject,
            exposesSQLiteSchema: exposesSQLiteSchema,
            exposesDuckDBSchema: exposesDuckDBSchema,
            authorizesLiveTrading: authorizesLiveTrading,
            authorizesTradingExecution: authorizesTradingExecution,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.readModelID = readModelID
        self.issueID = issueID
        self.runtimeHealth = runtimeHealth
        self.sourceAnchors = sourceAnchors
        self.streamEvidence = streamEvidence
        self.updatedAt = updatedAt
        self.isReadModelOnly = isReadModelOnly
        self.providesCommandSurface = providesCommandSurface
        self.opensMarketWebSocket = opensMarketWebSocket
        self.opensPrivateUserDataStream = opensPrivateUserDataStream
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.readsAPIKey = readsAPIKey
        self.readsSecret = readsSecret
        self.readsAccountPayload = readsAccountPayload
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.providesOrderCommand = providesOrderCommand
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
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
            readModelID: try container.decode(Identifier.self, forKey: .readModelID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            runtimeHealth: try container.decode(LiveRuntimeHealthReadModel.self, forKey: .runtimeHealth),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            streamEvidence: try container.decode(
                [LiveStreamMonitoringEvidenceItem].self,
                forKey: .streamEvidence
            ),
            updatedAt: try container.decode(Date.self, forKey: .updatedAt),
            isReadModelOnly: try container.decode(Bool.self, forKey: .isReadModelOnly),
            providesCommandSurface: try container.decode(Bool.self, forKey: .providesCommandSurface),
            opensMarketWebSocket: try container.decode(Bool.self, forKey: .opensMarketWebSocket),
            opensPrivateUserDataStream: try container.decode(Bool.self, forKey: .opensPrivateUserDataStream),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            readsAccountPayload: try container.decode(Bool.self, forKey: .readsAccountPayload),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            implementsRealOrderStateMachine: try container.decode(
                Bool.self,
                forKey: .implementsRealOrderStateMachine
            ),
            providesOrderCommand: try container.decode(Bool.self, forKey: .providesOrderCommand),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
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
        "MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE",
        "MTP-69-LIVE-RUNTIME-HEALTH-READ-MODEL",
        "MTP-70-MARKET-STREAM-ORDER-STREAM-READ-MODEL"
    ]

    public static let requiredStreamEvidence: [LiveStreamMonitoringEvidenceItem] = [
        Self.makeStreamEvidence(
            "mtp-70-public-market-stream-disconnected",
            kind: .publicMarketStream
        ),
        Self.makeStreamEvidence(
            "mtp-70-order-stream-blocked",
            kind: .blockedOrderStream
        ),
        Self.makeStreamEvidence(
            "mtp-70-order-stream-simulated-paper-evidence",
            kind: .simulatedOrderStream
        ),
        Self.makeStreamEvidence(
            "mtp-70-order-stream-future-gate",
            kind: .futureOrderStream
        )
    ]

    public static let deterministicFixture: LiveStreamMonitoringEvidenceReadModel = {
        do {
            return try LiveStreamMonitoringEvidenceReadModel()
        } catch {
            preconditionFailure("MTP-70 stream monitoring evidence fixture must be valid: \(error)")
        }
    }()

    private static func makeStreamEvidence(
        _ streamID: String,
        kind: LiveStreamMonitoringKind
    ) -> LiveStreamMonitoringEvidenceItem {
        do {
            return try LiveStreamMonitoringEvidenceItem(
                streamID: try Identifier(streamID),
                streamKind: kind
            )
        } catch {
            preconditionFailure("MTP-70 stream evidence item fixture must be valid: \(error)")
        }
    }

    private static func validate(streamEvidence: [LiveStreamMonitoringEvidenceItem]) throws {
        guard streamEvidence == Self.requiredStreamEvidence else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "streamEvidence",
                expected: Self.requiredStreamEvidence.map(\.streamKind.rawValue).joined(separator: ","),
                actual: streamEvidence.map(\.streamKind.rawValue).joined(separator: ",")
            )
        }
        guard streamEvidence.allSatisfy(\.streamBoundaryHeld) else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("streamEvidence")
        }
    }

    private static func validateForbiddenFlags(
        isReadModelOnly: Bool,
        providesCommandSurface: Bool,
        opensMarketWebSocket: Bool,
        opensPrivateUserDataStream: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        readsAPIKey: Bool,
        readsSecret: Bool,
        readsAccountPayload: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        implementsRealOrderStateMachine: Bool,
        providesOrderCommand: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
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
            ("opensMarketWebSocket", opensMarketWebSocket),
            ("opensPrivateUserDataStream", opensPrivateUserDataStream),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("readsAPIKey", readsAPIKey),
            ("readsSecret", readsSecret),
            ("readsAccountPayload", readsAccountPayload),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("providesOrderCommand", providesOrderCommand),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
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
