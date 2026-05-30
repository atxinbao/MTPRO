import Foundation

/// LiveMonitoringSourceEvidenceOrigin 固定 MTP-148 可解释的 monitoring evidence 来源类别。
///
/// 这些类别只描述 L3.0 / L3.1 / L3.2 已完成 evidence 的来源，不是 source adapter、
/// connection manager、private stream runtime、account endpoint payload 或 broker state。
public enum LiveMonitoringSourceEvidenceOrigin: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case boundary = "boundary evidence"
    case fixture = "fixture evidence"
    case simulated = "simulated evidence"
    case readModelOnly = "read-model-only evidence"
}

/// LiveMonitoringSourceEvidenceLayer 表示 MTP-148 可以引用的上游 evidence layer。
///
/// L3.0 / L3.1 / L3.2 都只能作为 read-model-only monitoring source identity 的输入；
/// `futureRealAccountUnavailable` 只是 unavailable 语义锚点，不代表当前存在真实账户连接。
public enum LiveMonitoringSourceEvidenceLayer: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case l30ReadinessBoundary = "L3.0 live read-only readiness boundary"
    case l31AccountPositionBalanceReadModelOnly = "L3.1 account position balance read-model-only"
    case l32PrivateStreamAccountSnapshotSimulationGate = "L3.2 private stream account snapshot simulation gate"
    case futureRealAccountUnavailable = "future real account unavailable label"
}

/// LiveMonitoringSourceStatus 定义 MTP-148 最小 source status 语义。
///
/// status 只解释本地 evidence 是否可用于 monitoring 展示，不触发 refresh、reconnect、
/// account sync、private stream start、broker connect 或任何 live command。
public enum LiveMonitoringSourceStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case available = "available read-model-only source"
    case stale = "stale read-model-only source"
    case blocked = "blocked by boundary"
    case unavailable = "unavailable source"
}

/// LiveMonitoringSourceFreshnessSemantics 定义 MTP-148 最小 freshness / unavailable 语义。
///
/// freshness 只来自 deterministic boundary、fixture、simulated 或 read-model-only evidence；
/// `unavailable` 不会升级为真实 account endpoint、listenKey 或 private WebSocket fallback。
public enum LiveMonitoringSourceFreshnessSemantics: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case fresh = "fresh evidence"
    case stale = "stale evidence"
    case blocked = "blocked evidence"
    case missing = "missing evidence"
    case unavailable = "unavailable evidence"
}

/// LiveMonitoringSourceIdentityForbiddenCapability 列出 MTP-148 source identity 必须拒绝的能力。
///
/// 这些值只作为 deterministic forbidden tests 与 PR boundary evidence。它们不能被实现为
/// 当前 endpoint、adapter、Runtime、Dashboard command、broker connector 或真实账户资料通道。
public enum LiveMonitoringSourceIdentityForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case apiKey = "API key"
    case secret = "secret"
    case listenKey = "listenKey"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case privateWebSocketRuntime = "private WebSocket runtime"
    case privateStreamRuntime = "private stream runtime"
    case accountSnapshotRuntime = "account snapshot runtime"
    case accountPayload = "account payload"
    case brokerPayload = "broker payload"
    case brokerState = "broker state"
    case adapterRequest = "adapter request"
    case runtimeObject = "Runtime object"
    case brokerAdapter = "broker adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case oms = "OMS"
    case realAccountRead = "real account read"
    case liveCommand = "live command"
    case tradingButton = "trading button"
    case orderForm = "order form"
}

/// LiveMonitoringSourceIdentityRecord 是 MTP-148 的单条 monitoring source identity。
///
/// Record 只保存上游 evidence layer、source identity、origin、freshness/status 和 validation anchor。
/// 它故意不保存 endpoint URL、API key、secret、listenKey、account payload、broker state、
/// adapter request 或 Runtime object，避免 fixture / simulated evidence 被误读为真实账户连接。
public struct LiveMonitoringSourceIdentityRecord: Codable, Equatable, Sendable {
    public let layer: LiveMonitoringSourceEvidenceLayer
    public let sourceIdentity: String
    public let evidenceOrigins: [LiveMonitoringSourceEvidenceOrigin]
    public let sourceStatus: LiveMonitoringSourceStatus
    public let freshnessSemantics: LiveMonitoringSourceFreshnessSemantics
    public let sourceUnavailableReason: String?
    public let validationAnchor: String
    public let boundaryNote: String

    public var canonicalLine: String {
        [
            layer.rawValue,
            sourceIdentity,
            evidenceOrigins.map(\.rawValue).joined(separator: "+"),
            sourceStatus.rawValue,
            freshnessSemantics.rawValue,
            sourceUnavailableReason ?? "none",
            validationAnchor,
            boundaryNote
        ].joined(separator: "|")
    }

    public var sourceIdentityBoundaryHeld: Bool {
        self == Self.requiredRecord(for: layer)
            && containsForbiddenSourceText(Self.forbiddenSourceIdentityTokens) == false
    }

    public init(
        layer: LiveMonitoringSourceEvidenceLayer,
        sourceIdentity: String? = nil,
        evidenceOrigins: [LiveMonitoringSourceEvidenceOrigin]? = nil,
        sourceStatus: LiveMonitoringSourceStatus? = nil,
        freshnessSemantics: LiveMonitoringSourceFreshnessSemantics? = nil,
        sourceUnavailableReason: String? = nil,
        validationAnchor: String? = nil,
        boundaryNote: String? = nil
    ) throws {
        let required = Self.requiredRecord(for: layer)
        let resolvedSourceIdentity = sourceIdentity ?? required.sourceIdentity
        let resolvedOrigins = evidenceOrigins ?? required.evidenceOrigins
        let resolvedStatus = sourceStatus ?? required.sourceStatus
        let resolvedFreshness = freshnessSemantics ?? required.freshnessSemantics
        let resolvedUnavailableReason = sourceUnavailableReason ?? required.sourceUnavailableReason
        let resolvedValidationAnchor = validationAnchor ?? required.validationAnchor
        let resolvedBoundaryNote = boundaryNote ?? required.boundaryNote

        try Self.validate(
            layer: layer,
            sourceIdentity: resolvedSourceIdentity,
            evidenceOrigins: resolvedOrigins,
            sourceStatus: resolvedStatus,
            freshnessSemantics: resolvedFreshness,
            sourceUnavailableReason: resolvedUnavailableReason,
            validationAnchor: resolvedValidationAnchor,
            boundaryNote: resolvedBoundaryNote
        )

        self.layer = layer
        self.sourceIdentity = resolvedSourceIdentity
        self.evidenceOrigins = resolvedOrigins
        self.sourceStatus = resolvedStatus
        self.freshnessSemantics = resolvedFreshness
        self.sourceUnavailableReason = resolvedUnavailableReason
        self.validationAnchor = resolvedValidationAnchor
        self.boundaryNote = resolvedBoundaryNote
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            layer: try container.decode(LiveMonitoringSourceEvidenceLayer.self, forKey: .layer),
            sourceIdentity: try container.decode(String.self, forKey: .sourceIdentity),
            evidenceOrigins: try container.decode([LiveMonitoringSourceEvidenceOrigin].self, forKey: .evidenceOrigins),
            sourceStatus: try container.decode(LiveMonitoringSourceStatus.self, forKey: .sourceStatus),
            freshnessSemantics: try container.decode(
                LiveMonitoringSourceFreshnessSemantics.self,
                forKey: .freshnessSemantics
            ),
            sourceUnavailableReason: try container.decodeIfPresent(String.self, forKey: .sourceUnavailableReason),
            validationAnchor: try container.decode(String.self, forKey: .validationAnchor),
            boundaryNote: try container.decode(String.self, forKey: .boundaryNote)
        )
    }

    public func containsForbiddenSourceText(_ forbiddenTokens: [String]) -> Bool {
        let searchable = [
            sourceIdentity,
            evidenceOrigins.map(\.rawValue).joined(separator: "|"),
            sourceStatus.rawValue,
            freshnessSemantics.rawValue,
            sourceUnavailableReason ?? "",
            validationAnchor,
            boundaryNote
        ]
            .joined(separator: "|")
            .lowercased()

        return forbiddenTokens.contains { token in
            searchable.contains(token.lowercased())
        }
    }

    public static let forbiddenSourceIdentityTokens = [
        "apikey",
        "api-key",
        "secret",
        "listenkey",
        "signedendpoint",
        "signed-endpoint",
        "accountendpoint",
        "account-endpoint",
        "privatewebsocket",
        "private-websocket",
        "accountpayload",
        "account-payload",
        "brokerpayload",
        "broker-payload",
        "brokerstate",
        "broker-state",
        "adapterrequest",
        "adapter-request",
        "runtimeobject",
        "runtime-object",
        "liveexecutionadapter",
        "live-execution-adapter",
        "tradingbutton",
        "trading-button",
        "livecommand",
        "live-command",
        "orderform",
        "order-form"
    ]

    public static func requiredRecord(
        for layer: LiveMonitoringSourceEvidenceLayer
    ) -> LiveMonitoringSourceIdentityRecord {
        switch layer {
        case .l30ReadinessBoundary:
            Self.unchecked(
                layer: layer,
                sourceIdentity: "boundary:l3.0:live-read-only-readiness",
                evidenceOrigins: [.boundary],
                sourceStatus: .blocked,
                freshnessSemantics: .blocked,
                sourceUnavailableReason: nil,
                validationAnchor: "MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION",
                boundaryNote: "L3.0 only provides readiness and forbidden capability boundary evidence"
            )
        case .l31AccountPositionBalanceReadModelOnly:
            Self.unchecked(
                layer: layer,
                sourceIdentity: AccountPositionBalanceReadModelOnlyFixtureRecord.requiredSourceIdentity,
                evidenceOrigins: [.fixture, .readModelOnly],
                sourceStatus: .available,
                freshnessSemantics: .fresh,
                sourceUnavailableReason: nil,
                validationAnchor: "MTP-137-FIXTURE-FORBIDDEN-REAL-ACCOUNT-VALIDATION",
                boundaryNote: "L3.1 fixture evidence is read-model-only and not a real account source"
            )
        case .l32PrivateStreamAccountSnapshotSimulationGate:
            Self.unchecked(
                layer: layer,
                sourceIdentity: SimulatedPrivateAccountEventSourceIdentityRecord.requiredSourceIdentity(
                    for: .simulatedPrivateStreamSource
                ),
                evidenceOrigins: [.fixture, .simulated, .readModelOnly],
                sourceStatus: .available,
                freshnessSemantics: .fresh,
                sourceUnavailableReason: nil,
                validationAnchor: "MTP-144-SIMULATED-ACCOUNT-SNAPSHOT-FRESHNESS-EVIDENCE-VALIDATION",
                boundaryNote: "L3.2 simulation gate source identity is simulated evidence, not a private stream runtime"
            )
        case .futureRealAccountUnavailable:
            Self.unchecked(
                layer: layer,
                sourceIdentity: "unavailable:future-real-account-source-label-only",
                evidenceOrigins: [.boundary],
                sourceStatus: .unavailable,
                freshnessSemantics: .unavailable,
                sourceUnavailableReason: "future real account source is gated and unavailable in MTP-148",
                validationAnchor: "MTP-147-FORBIDDEN-CAPABILITY-BASELINE",
                boundaryNote: "future real account source label cannot be interpreted as broker state"
            )
        }
    }

    private static func validate(
        layer: LiveMonitoringSourceEvidenceLayer,
        sourceIdentity: String,
        evidenceOrigins: [LiveMonitoringSourceEvidenceOrigin],
        sourceStatus: LiveMonitoringSourceStatus,
        freshnessSemantics: LiveMonitoringSourceFreshnessSemantics,
        sourceUnavailableReason: String?,
        validationAnchor: String,
        boundaryNote: String
    ) throws {
        let expected = Self.requiredRecord(for: layer)
        let actual = Self.unchecked(
            layer: layer,
            sourceIdentity: sourceIdentity,
            evidenceOrigins: evidenceOrigins,
            sourceStatus: sourceStatus,
            freshnessSemantics: freshnessSemantics,
            sourceUnavailableReason: sourceUnavailableReason,
            validationAnchor: validationAnchor,
            boundaryNote: boundaryNote
        )

        guard actual == expected else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(layer.rawValue).sourceIdentity",
                expected: expected.canonicalLine,
                actual: actual.canonicalLine
            )
        }
        if let forbiddenToken = Self.forbiddenSourceIdentityTokens.first(where: { token in
            actual.containsForbiddenSourceText([token])
        }) {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("sourceIdentity.\(forbiddenToken)")
        }
    }

    private static func unchecked(
        layer: LiveMonitoringSourceEvidenceLayer,
        sourceIdentity: String,
        evidenceOrigins: [LiveMonitoringSourceEvidenceOrigin],
        sourceStatus: LiveMonitoringSourceStatus,
        freshnessSemantics: LiveMonitoringSourceFreshnessSemantics,
        sourceUnavailableReason: String?,
        validationAnchor: String,
        boundaryNote: String
    ) -> LiveMonitoringSourceIdentityRecord {
        LiveMonitoringSourceIdentityRecord(
            uncheckedLayer: layer,
            uncheckedSourceIdentity: sourceIdentity,
            uncheckedEvidenceOrigins: evidenceOrigins,
            uncheckedSourceStatus: sourceStatus,
            uncheckedFreshnessSemantics: freshnessSemantics,
            uncheckedSourceUnavailableReason: sourceUnavailableReason,
            uncheckedValidationAnchor: validationAnchor,
            uncheckedBoundaryNote: boundaryNote
        )
    }

    private init(
        uncheckedLayer: LiveMonitoringSourceEvidenceLayer,
        uncheckedSourceIdentity: String,
        uncheckedEvidenceOrigins: [LiveMonitoringSourceEvidenceOrigin],
        uncheckedSourceStatus: LiveMonitoringSourceStatus,
        uncheckedFreshnessSemantics: LiveMonitoringSourceFreshnessSemantics,
        uncheckedSourceUnavailableReason: String?,
        uncheckedValidationAnchor: String,
        uncheckedBoundaryNote: String
    ) {
        layer = uncheckedLayer
        sourceIdentity = uncheckedSourceIdentity
        evidenceOrigins = uncheckedEvidenceOrigins
        sourceStatus = uncheckedSourceStatus
        freshnessSemantics = uncheckedFreshnessSemantics
        sourceUnavailableReason = uncheckedSourceUnavailableReason
        validationAnchor = uncheckedValidationAnchor
        boundaryNote = uncheckedBoundaryNote
    }
}

/// LiveMonitoringSourceIdentityContract 是 MTP-148 的 deterministic source identity 合同。
///
/// 合同把 L3.0 readiness boundary、L3.1 APB read-model-only fixture、L3.2 private stream
/// simulation gate 和 future real account unavailable label 固定为只读 monitoring source identity。
/// 它不创建真实 source adapter，不读取真实 account / position / balance，不接 listenKey 或
/// account endpoint，不暴露 Runtime object、Adapter request、数据库 schema、broker payload 或 broker state。
public struct LiveMonitoringSourceIdentityContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let matrixID: String
    public let sourceRecords: [LiveMonitoringSourceIdentityRecord]
    public let checksum: String
    public let checksumMatchedCanonicalPreimage: Bool
    public let forbiddenCapabilities: [LiveMonitoringSourceIdentityForbiddenCapability]
    public let createsRealSourceAdapter: Bool
    public let readsRealAccount: Bool
    public let readsRealPosition: Bool
    public let readsRealBalance: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let opensPrivateWebSocket: Bool
    public let runsPrivateStreamRuntime: Bool
    public let runsAccountSnapshotRuntime: Bool
    public let readsAPIKey: Bool
    public let readsSecret: Bool
    public let exposesAccountPayload: Bool
    public let exposesBrokerPayload: Bool
    public let exposesBrokerState: Bool
    public let exposesAdapterRequest: Bool
    public let exposesRuntimeObject: Bool
    public let exposesDatabaseSchema: Bool
    public let connectsBrokerAdapter: Bool
    public let connectsExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let exposesLiveCommand: Bool
    public let exposesTradingButton: Bool
    public let exposesOrderForm: Bool

    public var sourceIdentityBoundaryHeld: Bool {
        matrixID == Self.requiredMatrixID
            && sourceRecords == Self.requiredSourceRecords
            && sourceRecords.allSatisfy(\.sourceIdentityBoundaryHeld)
            && checksum == Self.requiredChecksum
            && checksumMatchedCanonicalPreimage
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && forbiddenFlagsAreFalse
    }

    public var canonicalPreimage: String {
        Self.canonicalPreimage(for: sourceRecords)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-148-live-monitoring-source-identity"),
        issueID: Identifier = try! Identifier("MTP-148"),
        matrixID: String = Self.requiredMatrixID,
        sourceRecords: [LiveMonitoringSourceIdentityRecord] = Self.requiredSourceRecords,
        checksum: String? = nil,
        checksumMatchedCanonicalPreimage: Bool = true,
        forbiddenCapabilities: [LiveMonitoringSourceIdentityForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        createsRealSourceAdapter: Bool = false,
        readsRealAccount: Bool = false,
        readsRealPosition: Bool = false,
        readsRealBalance: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        opensPrivateWebSocket: Bool = false,
        runsPrivateStreamRuntime: Bool = false,
        runsAccountSnapshotRuntime: Bool = false,
        readsAPIKey: Bool = false,
        readsSecret: Bool = false,
        exposesAccountPayload: Bool = false,
        exposesBrokerPayload: Bool = false,
        exposesBrokerState: Bool = false,
        exposesAdapterRequest: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesDatabaseSchema: Bool = false,
        connectsBrokerAdapter: Bool = false,
        connectsExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        exposesLiveCommand: Bool = false,
        exposesTradingButton: Bool = false,
        exposesOrderForm: Bool = false
    ) throws {
        let providedChecksum = checksum ?? Self.checksum(for: sourceRecords)
        try Self.validate(
            matrixID: matrixID,
            sourceRecords: sourceRecords,
            checksum: providedChecksum,
            checksumMatchedCanonicalPreimage: checksumMatchedCanonicalPreimage,
            forbiddenCapabilities: forbiddenCapabilities
        )
        try Self.validateForbiddenFlags(
            createsRealSourceAdapter: createsRealSourceAdapter,
            readsRealAccount: readsRealAccount,
            readsRealPosition: readsRealPosition,
            readsRealBalance: readsRealBalance,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            opensPrivateWebSocket: opensPrivateWebSocket,
            runsPrivateStreamRuntime: runsPrivateStreamRuntime,
            runsAccountSnapshotRuntime: runsAccountSnapshotRuntime,
            readsAPIKey: readsAPIKey,
            readsSecret: readsSecret,
            exposesAccountPayload: exposesAccountPayload,
            exposesBrokerPayload: exposesBrokerPayload,
            exposesBrokerState: exposesBrokerState,
            exposesAdapterRequest: exposesAdapterRequest,
            exposesRuntimeObject: exposesRuntimeObject,
            exposesDatabaseSchema: exposesDatabaseSchema,
            connectsBrokerAdapter: connectsBrokerAdapter,
            connectsExchangeExecutionAdapter: connectsExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            exposesLiveCommand: exposesLiveCommand,
            exposesTradingButton: exposesTradingButton,
            exposesOrderForm: exposesOrderForm
        )

        self.contractID = contractID
        self.issueID = issueID
        self.matrixID = matrixID
        self.sourceRecords = sourceRecords
        self.checksum = providedChecksum
        self.checksumMatchedCanonicalPreimage = checksumMatchedCanonicalPreimage
        self.forbiddenCapabilities = forbiddenCapabilities
        self.createsRealSourceAdapter = createsRealSourceAdapter
        self.readsRealAccount = readsRealAccount
        self.readsRealPosition = readsRealPosition
        self.readsRealBalance = readsRealBalance
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.runsPrivateStreamRuntime = runsPrivateStreamRuntime
        self.runsAccountSnapshotRuntime = runsAccountSnapshotRuntime
        self.readsAPIKey = readsAPIKey
        self.readsSecret = readsSecret
        self.exposesAccountPayload = exposesAccountPayload
        self.exposesBrokerPayload = exposesBrokerPayload
        self.exposesBrokerState = exposesBrokerState
        self.exposesAdapterRequest = exposesAdapterRequest
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.connectsBrokerAdapter = connectsBrokerAdapter
        self.connectsExchangeExecutionAdapter = connectsExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.exposesLiveCommand = exposesLiveCommand
        self.exposesTradingButton = exposesTradingButton
        self.exposesOrderForm = exposesOrderForm
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            matrixID: try container.decode(String.self, forKey: .matrixID),
            sourceRecords: try container.decode([LiveMonitoringSourceIdentityRecord].self, forKey: .sourceRecords),
            checksum: try container.decode(String.self, forKey: .checksum),
            checksumMatchedCanonicalPreimage: try container.decode(
                Bool.self,
                forKey: .checksumMatchedCanonicalPreimage
            ),
            forbiddenCapabilities: try container.decode(
                [LiveMonitoringSourceIdentityForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            createsRealSourceAdapter: try container.decode(Bool.self, forKey: .createsRealSourceAdapter),
            readsRealAccount: try container.decode(Bool.self, forKey: .readsRealAccount),
            readsRealPosition: try container.decode(Bool.self, forKey: .readsRealPosition),
            readsRealBalance: try container.decode(Bool.self, forKey: .readsRealBalance),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            opensPrivateWebSocket: try container.decode(Bool.self, forKey: .opensPrivateWebSocket),
            runsPrivateStreamRuntime: try container.decode(Bool.self, forKey: .runsPrivateStreamRuntime),
            runsAccountSnapshotRuntime: try container.decode(Bool.self, forKey: .runsAccountSnapshotRuntime),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            exposesAccountPayload: try container.decode(Bool.self, forKey: .exposesAccountPayload),
            exposesBrokerPayload: try container.decode(Bool.self, forKey: .exposesBrokerPayload),
            exposesBrokerState: try container.decode(Bool.self, forKey: .exposesBrokerState),
            exposesAdapterRequest: try container.decode(Bool.self, forKey: .exposesAdapterRequest),
            exposesRuntimeObject: try container.decode(Bool.self, forKey: .exposesRuntimeObject),
            exposesDatabaseSchema: try container.decode(Bool.self, forKey: .exposesDatabaseSchema),
            connectsBrokerAdapter: try container.decode(Bool.self, forKey: .connectsBrokerAdapter),
            connectsExchangeExecutionAdapter: try container.decode(Bool.self, forKey: .connectsExchangeExecutionAdapter),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            exposesLiveCommand: try container.decode(Bool.self, forKey: .exposesLiveCommand),
            exposesTradingButton: try container.decode(Bool.self, forKey: .exposesTradingButton),
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm)
        )
    }

    public func containsForbiddenPayloadText(_ forbiddenTokens: [String]) -> Bool {
        let searchable = [
            matrixID,
            checksum,
            sourceRecords.map(\.canonicalLine).joined(separator: "|")
        ]
            .joined(separator: "|")
            .lowercased()

        return forbiddenTokens.contains { token in
            searchable.contains(token.lowercased())
        }
    }

    public static let requiredMatrixID = "TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2"
    public static let requiredForbiddenCapabilities =
        LiveMonitoringSourceIdentityForbiddenCapability.allCases

    public static let requiredSourceRecords: [LiveMonitoringSourceIdentityRecord] =
        LiveMonitoringSourceEvidenceLayer.allCases.map {
            LiveMonitoringSourceIdentityRecord.requiredRecord(for: $0)
        }

    public static let requiredChecksum = checksum(for: requiredSourceRecords)

    public static let deterministicFixture: LiveMonitoringSourceIdentityContract = {
        do {
            return try LiveMonitoringSourceIdentityContract()
        } catch {
            preconditionFailure("MTP-148 live monitoring source identity contract must be valid: \(error)")
        }
    }()

    public static func canonicalPreimage(
        for sourceRecords: [LiveMonitoringSourceIdentityRecord]
    ) -> String {
        sourceRecords.map(\.canonicalLine).joined(separator: "\n")
    }

    public static func checksum(
        for sourceRecords: [LiveMonitoringSourceIdentityRecord]
    ) -> String {
        ScenarioReplayChecksumEvidence.checksum(forCanonicalPreimage: canonicalPreimage(for: sourceRecords))
    }

    private var forbiddenFlagsAreFalse: Bool {
        createsRealSourceAdapter == false
            && readsRealAccount == false
            && readsRealPosition == false
            && readsRealBalance == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && opensPrivateWebSocket == false
            && runsPrivateStreamRuntime == false
            && runsAccountSnapshotRuntime == false
            && readsAPIKey == false
            && readsSecret == false
            && exposesAccountPayload == false
            && exposesBrokerPayload == false
            && exposesBrokerState == false
            && exposesAdapterRequest == false
            && exposesRuntimeObject == false
            && exposesDatabaseSchema == false
            && connectsBrokerAdapter == false
            && connectsExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && exposesLiveCommand == false
            && exposesTradingButton == false
            && exposesOrderForm == false
    }

    private static func validate(
        matrixID: String,
        sourceRecords: [LiveMonitoringSourceIdentityRecord],
        checksum: String,
        checksumMatchedCanonicalPreimage: Bool,
        forbiddenCapabilities: [LiveMonitoringSourceIdentityForbiddenCapability]
    ) throws {
        guard matrixID == Self.requiredMatrixID else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "matrixID",
                expected: Self.requiredMatrixID,
                actual: matrixID
            )
        }
        guard sourceRecords == Self.requiredSourceRecords else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceRecords",
                expected: Self.requiredSourceRecords.map(\.layer.rawValue).joined(separator: ","),
                actual: sourceRecords.map(\.layer.rawValue).joined(separator: ",")
            )
        }
        guard sourceRecords.allSatisfy(\.sourceIdentityBoundaryHeld) else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("sourceIdentityBoundaryHeld")
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
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        createsRealSourceAdapter: Bool,
        readsRealAccount: Bool,
        readsRealPosition: Bool,
        readsRealBalance: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        opensPrivateWebSocket: Bool,
        runsPrivateStreamRuntime: Bool,
        runsAccountSnapshotRuntime: Bool,
        readsAPIKey: Bool,
        readsSecret: Bool,
        exposesAccountPayload: Bool,
        exposesBrokerPayload: Bool,
        exposesBrokerState: Bool,
        exposesAdapterRequest: Bool,
        exposesRuntimeObject: Bool,
        exposesDatabaseSchema: Bool,
        connectsBrokerAdapter: Bool,
        connectsExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        exposesLiveCommand: Bool,
        exposesTradingButton: Bool,
        exposesOrderForm: Bool
    ) throws {
        let forbiddenFlags = [
            ("createsRealSourceAdapter", createsRealSourceAdapter),
            ("readsRealAccount", readsRealAccount),
            ("readsRealPosition", readsRealPosition),
            ("readsRealBalance", readsRealBalance),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("opensPrivateWebSocket", opensPrivateWebSocket),
            ("runsPrivateStreamRuntime", runsPrivateStreamRuntime),
            ("runsAccountSnapshotRuntime", runsAccountSnapshotRuntime),
            ("readsAPIKey", readsAPIKey),
            ("readsSecret", readsSecret),
            ("exposesAccountPayload", exposesAccountPayload),
            ("exposesBrokerPayload", exposesBrokerPayload),
            ("exposesBrokerState", exposesBrokerState),
            ("exposesAdapterRequest", exposesAdapterRequest),
            ("exposesRuntimeObject", exposesRuntimeObject),
            ("exposesDatabaseSchema", exposesDatabaseSchema),
            ("connectsBrokerAdapter", connectsBrokerAdapter),
            ("connectsExchangeExecutionAdapter", connectsExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("exposesLiveCommand", exposesLiveCommand),
            ("exposesTradingButton", exposesTradingButton),
            ("exposesOrderForm", exposesOrderForm)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveMonitoringConsoleForbiddenCapability(capability.0)
        }
    }
}
