import DomainModel
import Foundation

/// L4PrivateStreamReadOnlyRuntimeMode 定义 GH-456 private stream / account snapshot gate 的触发模式。
///
/// 默认 `disabled` 不产出任何 private stream evidence；`localFixture` 和 `sandboxConfigured`
/// 只允许使用 deterministic fixture 生成 read-model-only evidence，不创建 listenKey、不打开 WebSocket、
/// 不消费真实 broker payload，也不形成 command surface。
public enum L4PrivateStreamReadOnlyRuntimeMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case disabled = "disabled"
    case localFixture = "local fixture"
    case sandboxConfigured = "sandbox configured"
    case production = "production"
}

/// L4PrivateStreamSourceIdentity 固定 GH-456 可以描述的 private stream / account snapshot 来源身份。
///
/// Source identity 是只读 evidence 的来源标签，不是 listenKey value、WebSocket session、
/// broker payload、execution report payload 或真实账户端点响应。
public enum L4PrivateStreamSourceIdentity: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signedAccountSnapshot = "signed account snapshot source"
    case privateBalanceUpdate = "private balance update source"
    case privatePositionUpdate = "private position update source"
    case privateMarginUpdate = "private margin update source"
    case listenKeySession = "listenKey session source identity"
}

/// L4PrivateStreamFreshnessStatus 表达 GH-456 stale / blocked / missing / disconnect evidence。
///
/// 这些状态只进入 read model，不驱动 reconnect、listenKey keep-alive、command retry 或订单操作。
public enum L4PrivateStreamFreshnessStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case fresh = "fresh"
    case stale = "stale"
    case blocked = "blocked"
    case missing = "missing"
    case disconnected = "disconnected"
}

/// L4PrivateStreamReadOnlyEventKind 固定 GH-456 可以映射到 read model 的事件类别。
///
/// 每个类别都必须保持 canonical / fixture-only，不得保存 raw private stream payload。
public enum L4PrivateStreamReadOnlyEventKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case accountSnapshot = "account snapshot"
    case balanceUpdate = "balance update"
    case positionUpdate = "position update"
    case marginUpdate = "margin update"
    case staleEvidence = "stale evidence"
    case blockedEvidence = "blocked evidence"
    case missingEvidence = "missing evidence"
    case disconnectEvidence = "disconnect evidence"
}

/// L4PrivateStreamReadOnlyForbiddenCapability 枚举 GH-456 必须继续关闭的 private / command 能力。
///
/// Runtime 可以产生 deterministic source / freshness evidence，但不能读取 secret、创建 listenKey、
/// 打开 private WebSocket、暴露 raw broker payload、实现 ExecutionClient adapter、OMS 或交易命令。
public enum L4PrivateStreamReadOnlyForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case unconfiguredPrivateStreamRead = "unconfigured private stream read"
    case productionGateEnabled = "production gate enabled"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case credentialValueRead = "credential value read"
    case secretMaterialAvailable = "secret material available"
    case signedEndpointCall = "signed endpoint call"
    case accountEndpointCall = "account endpoint call"
    case listenKeyValueRead = "listenKey value read"
    case listenKeyCreation = "listenKey creation"
    case listenKeyKeepAlive = "listenKey keep-alive"
    case listenKeyClose = "listenKey close"
    case privateWebSocketOpen = "private WebSocket open"
    case privateWebSocketReconnect = "private WebSocket reconnect"
    case realPrivateEventConsumption = "real private event consumption"
    case rawPrivatePayloadExposure = "raw private payload exposure"
    case rawBrokerPayloadExposure = "raw broker payload exposure"
    case accountEndpointPayloadExposure = "account endpoint payload exposure"
    case dashboardRawPayloadExposure = "Dashboard raw payload exposure"
    case networkConnection = "network connection"
    case commandRuntime = "command runtime"
    case executionClientAdapterImplementation = "ExecutionClient adapter implementation"
    case omsImplementation = "OMS implementation"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case liveProConsoleCommandSurface = "Live PRO Console command surface"
    case orderForm = "order form"
}

/// L4PrivateStreamReadOnlyRuntimeConfiguration 是 GH-456 runtime 的输入合同。
///
/// 配置只携带 credential reference identity、sandbox gate、fixture stream gate 和 mapping gate。
/// 它不携带 secret value，不创建 listenKey，不打开 WebSocket，也不授权 production endpoint。
public struct L4PrivateStreamReadOnlyRuntimeConfiguration: Codable, Equatable, Sendable {
    public let mode: L4PrivateStreamReadOnlyRuntimeMode
    public let credentialReference: String?
    public let sourceIdentity: String
    public let sandboxGateEnabled: Bool
    public let fixtureStreamEnabled: Bool
    public let accountSnapshotMappingEnabled: Bool
    public let productionGateEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let secretMaterialAvailable: Bool
    public let listenKeyLifecycleAllowed: Bool
    public let privateWebSocketAllowed: Bool
    public let networkConnectionAllowed: Bool
    public let rawPayloadExposureAllowed: Bool
    public let commandRuntimeAllowed: Bool

    public init(
        mode: L4PrivateStreamReadOnlyRuntimeMode = .disabled,
        credentialReference: String? = nil,
        sourceIdentity: String = "gh-456-disabled-private-stream-account-snapshot-runtime",
        sandboxGateEnabled: Bool = false,
        fixtureStreamEnabled: Bool = false,
        accountSnapshotMappingEnabled: Bool = false,
        productionGateEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        secretMaterialAvailable: Bool = false,
        listenKeyLifecycleAllowed: Bool = false,
        privateWebSocketAllowed: Bool = false,
        networkConnectionAllowed: Bool = false,
        rawPayloadExposureAllowed: Bool = false,
        commandRuntimeAllowed: Bool = false
    ) throws {
        guard mode != .production else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("mode.production")
        }
        for forbiddenFlag in [
            ("productionGateEnabled", productionGateEnabled),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("secretMaterialAvailable", secretMaterialAvailable),
            ("listenKeyLifecycleAllowed", listenKeyLifecycleAllowed),
            ("privateWebSocketAllowed", privateWebSocketAllowed),
            ("networkConnectionAllowed", networkConnectionAllowed),
            ("rawPayloadExposureAllowed", rawPayloadExposureAllowed),
            ("commandRuntimeAllowed", commandRuntimeAllowed)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }
        if mode != .disabled {
            guard let credentialReference, credentialReference.isEmpty == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "credentialReference",
                    expected: "non-empty external credential reference identity",
                    actual: "missing"
                )
            }
            guard sandboxGateEnabled else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "sandboxGateEnabled",
                    expected: "true",
                    actual: "false"
                )
            }
            guard fixtureStreamEnabled else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "fixtureStreamEnabled",
                    expected: "true",
                    actual: "false"
                )
            }
            guard accountSnapshotMappingEnabled else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "accountSnapshotMappingEnabled",
                    expected: "true",
                    actual: "false"
                )
            }
        }

        self.mode = mode
        self.credentialReference = credentialReference
        self.sourceIdentity = sourceIdentity
        self.sandboxGateEnabled = sandboxGateEnabled
        self.fixtureStreamEnabled = fixtureStreamEnabled
        self.accountSnapshotMappingEnabled = accountSnapshotMappingEnabled
        self.productionGateEnabled = productionGateEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.secretMaterialAvailable = secretMaterialAvailable
        self.listenKeyLifecycleAllowed = listenKeyLifecycleAllowed
        self.privateWebSocketAllowed = privateWebSocketAllowed
        self.networkConnectionAllowed = networkConnectionAllowed
        self.rawPayloadExposureAllowed = rawPayloadExposureAllowed
        self.commandRuntimeAllowed = commandRuntimeAllowed
    }

    public static func disabled() throws -> L4PrivateStreamReadOnlyRuntimeConfiguration {
        try L4PrivateStreamReadOnlyRuntimeConfiguration()
    }

    public static func sandboxFixture(
        credentialReference: String = "credential-reference:gh-453-external"
    ) throws -> L4PrivateStreamReadOnlyRuntimeConfiguration {
        try L4PrivateStreamReadOnlyRuntimeConfiguration(
            mode: .sandboxConfigured,
            credentialReference: credentialReference,
            sourceIdentity: "gh-456-sandbox-private-stream-account-snapshot-fixture",
            sandboxGateEnabled: true,
            fixtureStreamEnabled: true,
            accountSnapshotMappingEnabled: true
        )
    }
}

/// L4PrivateStreamAccountSnapshotReadModelRecord 是 GH-456 输出的 read-model-only 事件行。
///
/// `canonicalReadModelValue` 是经过归一化的 evidence，不是 raw private stream payload、account
/// endpoint JSON、broker state、execution report 或 command payload。
public struct L4PrivateStreamAccountSnapshotReadModelRecord: Codable, Equatable, Sendable {
    public let eventKind: L4PrivateStreamReadOnlyEventKind
    public let sourceKind: L4PrivateStreamSourceIdentity
    public let freshnessStatus: L4PrivateStreamFreshnessStatus
    public let canonicalReadModelValue: String
    public let sourceIdentity: String
    public let rawPrivatePayloadExposed: Bool
    public let commandSurfaceEnabled: Bool

    public init(
        eventKind: L4PrivateStreamReadOnlyEventKind,
        sourceKind: L4PrivateStreamSourceIdentity,
        freshnessStatus: L4PrivateStreamFreshnessStatus,
        canonicalReadModelValue: String,
        sourceIdentity: String,
        rawPrivatePayloadExposed: Bool = false,
        commandSurfaceEnabled: Bool = false
    ) throws {
        guard canonicalReadModelValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "canonicalReadModelValue",
                expected: "non-empty private stream read-model evidence",
                actual: "empty"
            )
        }
        guard sourceIdentity.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIdentity",
                expected: "non-empty source identity",
                actual: "empty"
            )
        }
        guard rawPrivatePayloadExposed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("rawPrivatePayloadExposed")
        }
        guard commandSurfaceEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("commandSurfaceEnabled")
        }

        self.eventKind = eventKind
        self.sourceKind = sourceKind
        self.freshnessStatus = freshnessStatus
        self.canonicalReadModelValue = canonicalReadModelValue
        self.sourceIdentity = sourceIdentity
        self.rawPrivatePayloadExposed = rawPrivatePayloadExposed
        self.commandSurfaceEnabled = commandSurfaceEnabled
    }
}

/// L4PrivateStreamAccountSnapshotReadOnlyEvidence 是 GH-456 runtime 的唯一输出。
///
/// Evidence 只暴露 private stream source identity、account snapshot read-model update 和 freshness
/// 状态；它不包含 listenKey value、raw broker payload、private WebSocket session 或命令状态。
public struct L4PrivateStreamAccountSnapshotReadOnlyEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let signedAccountEvidenceID: Identifier
    public let sourceIdentity: String
    public let records: [L4PrivateStreamAccountSnapshotReadModelRecord]
    public let validationAnchors: [String]
    public let readModelOnly: Bool
    public let dashboardReadModelOnly: Bool
    public let listenKeyValueExposed: Bool
    public let privateWebSocketOpened: Bool
    public let rawBrokerPayloadExposed: Bool
    public let rawPrivatePayloadExposed: Bool
    public let commandSurfaceEnabled: Bool
    public let productionGateEnabled: Bool

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-456"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-454", "GH-455"]
            && signedAccountEvidenceID.rawValue == "gh-455-signed-account-read-only-evidence"
            && Set(records.map(\.freshnessStatus)) == Set(L4PrivateStreamFreshnessStatus.allCases)
            && Set(records.map(\.sourceKind)) == Set(L4PrivateStreamSourceIdentity.allCases)
            && records.allSatisfy { $0.rawPrivatePayloadExposed == false && $0.commandSurfaceEnabled == false }
            && validationAnchors == L4PrivateStreamAccountSnapshotReadOnlyRuntime.requiredValidationAnchors
            && readModelOnly
            && dashboardReadModelOnly
            && listenKeyValueExposed == false
            && privateWebSocketOpened == false
            && rawBrokerPayloadExposed == false
            && rawPrivatePayloadExposed == false
            && commandSurfaceEnabled == false
            && productionGateEnabled == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-456-private-stream-account-snapshot-read-only-evidence"),
        issueID: Identifier = Identifier.constant("GH-456"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-454"),
            Identifier.constant("GH-455")
        ],
        signedAccountEvidenceID: Identifier,
        sourceIdentity: String,
        records: [L4PrivateStreamAccountSnapshotReadModelRecord],
        validationAnchors: [String] = L4PrivateStreamAccountSnapshotReadOnlyRuntime.requiredValidationAnchors,
        readModelOnly: Bool = true,
        dashboardReadModelOnly: Bool = true,
        listenKeyValueExposed: Bool = false,
        privateWebSocketOpened: Bool = false,
        rawBrokerPayloadExposed: Bool = false,
        rawPrivatePayloadExposed: Bool = false,
        commandSurfaceEnabled: Bool = false,
        productionGateEnabled: Bool = false
    ) throws {
        guard records.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "records",
                expected: "non-empty private stream read-model evidence records",
                actual: "empty"
            )
        }
        guard validationAnchors == L4PrivateStreamAccountSnapshotReadOnlyRuntime.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: L4PrivateStreamAccountSnapshotReadOnlyRuntime.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard readModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readModelOnly")
        }
        guard dashboardReadModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("dashboardReadModelOnly")
        }
        for forbiddenFlag in [
            ("listenKeyValueExposed", listenKeyValueExposed),
            ("privateWebSocketOpened", privateWebSocketOpened),
            ("rawBrokerPayloadExposed", rawBrokerPayloadExposed),
            ("rawPrivatePayloadExposed", rawPrivatePayloadExposed),
            ("commandSurfaceEnabled", commandSurfaceEnabled),
            ("productionGateEnabled", productionGateEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.signedAccountEvidenceID = signedAccountEvidenceID
        self.sourceIdentity = sourceIdentity
        self.records = records
        self.validationAnchors = validationAnchors
        self.readModelOnly = readModelOnly
        self.dashboardReadModelOnly = dashboardReadModelOnly
        self.listenKeyValueExposed = listenKeyValueExposed
        self.privateWebSocketOpened = privateWebSocketOpened
        self.rawBrokerPayloadExposed = rawBrokerPayloadExposed
        self.rawPrivatePayloadExposed = rawPrivatePayloadExposed
        self.commandSurfaceEnabled = commandSurfaceEnabled
        self.productionGateEnabled = productionGateEnabled
    }
}

/// L4PrivateStreamAccountSnapshotReadOnlyRuntime 是 GH-456 的 private stream / account snapshot gate。
///
/// Runtime 依赖 GH-455 signed account read-only evidence，只在 sandbox / fixture gate 满足时生成
/// deterministic source / freshness / snapshot read-model evidence。它不创建 listenKey、不打开 WebSocket、
/// 不暴露 raw payload、不接 Dashboard command，也不实现 ExecutionClient adapter 或 OMS。
public struct L4PrivateStreamAccountSnapshotReadOnlyRuntime: Codable, Equatable, Sendable {
    public let runtimeID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let forbiddenCapabilities: [L4PrivateStreamReadOnlyForbiddenCapability]
    public let validationAnchors: [String]
    public let productionDisabledByDefault: Bool
    public let fixtureStreamOnly: Bool
    public let dashboardReadModelOnlyBoundaryHeld: Bool

    public init(
        runtimeID: Identifier = Identifier.constant("gh-456-private-stream-account-snapshot-read-only-runtime"),
        issueID: Identifier = Identifier.constant("GH-456"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-454"),
            Identifier.constant("GH-455")
        ],
        forbiddenCapabilities: [L4PrivateStreamReadOnlyForbiddenCapability] =
            L4PrivateStreamReadOnlyForbiddenCapability.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionDisabledByDefault: Bool = true,
        fixtureStreamOnly: Bool = true,
        dashboardReadModelOnlyBoundaryHeld: Bool = true
    ) throws {
        guard forbiddenCapabilities == L4PrivateStreamReadOnlyForbiddenCapability.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: L4PrivateStreamReadOnlyForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard productionDisabledByDefault else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionDisabledByDefault")
        }
        guard fixtureStreamOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("fixtureStreamOnly")
        }
        guard dashboardReadModelOnlyBoundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("dashboardReadModelOnlyBoundaryHeld")
        }

        self.runtimeID = runtimeID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.productionDisabledByDefault = productionDisabledByDefault
        self.fixtureStreamOnly = fixtureStreamOnly
        self.dashboardReadModelOnlyBoundaryHeld = dashboardReadModelOnlyBoundaryHeld
    }

    public var runtimeBoundaryHeld: Bool {
        issueID.rawValue == "GH-456"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-454", "GH-455"]
            && forbiddenCapabilities == L4PrivateStreamReadOnlyForbiddenCapability.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && productionDisabledByDefault
            && fixtureStreamOnly
            && dashboardReadModelOnlyBoundaryHeld
    }

    public func readPrivateStreamAccountSnapshotEvidence(
        configuration: L4PrivateStreamReadOnlyRuntimeConfiguration,
        signedAccountEvidence: L4SignedAccountReadOnlyEvidence
    ) throws -> L4PrivateStreamAccountSnapshotReadOnlyEvidence {
        guard configuration.mode != .disabled else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mode",
                expected: "local fixture or sandbox configured",
                actual: "disabled"
            )
        }
        guard signedAccountEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "signedAccountEvidence",
                expected: "GH-455 canonical signed account read-only evidence",
                actual: "boundary drift"
            )
        }
        guard configuration.sandboxGateEnabled else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxGateEnabled",
                expected: "true",
                actual: "false"
            )
        }
        guard configuration.fixtureStreamEnabled else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "fixtureStreamEnabled",
                expected: "true",
                actual: "false"
            )
        }
        guard configuration.accountSnapshotMappingEnabled else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "accountSnapshotMappingEnabled",
                expected: "true",
                actual: "false"
            )
        }
        guard configuration.listenKeyLifecycleAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("listenKeyLifecycleAllowed")
        }
        guard configuration.privateWebSocketAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("privateWebSocketAllowed")
        }
        guard configuration.commandRuntimeAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("commandRuntimeAllowed")
        }

        return try Self.deterministicEvidence(
            sourceIdentity: configuration.sourceIdentity,
            signedAccountEvidence: signedAccountEvidence
        )
    }

    public static func deterministicFixture() throws -> L4PrivateStreamAccountSnapshotReadOnlyRuntime {
        try L4PrivateStreamAccountSnapshotReadOnlyRuntime()
    }

    public static let requiredValidationAnchors: [String] = [
        "GH-456-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME",
        "GH-456-PRIVATE-STREAM-SOURCE-IDENTITY",
        "GH-456-ACCOUNT-SNAPSHOT-READ-MODEL-UPDATE",
        "GH-456-FRESHNESS-STALE-BLOCKED-MISSING-DISCONNECT-EVIDENCE",
        "GH-456-LISTENKEY-LIFECYCLE-NO-COMMAND-SURFACE",
        "GH-456-NON-AUTHORIZATION",
        "TVM-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME"
    ]

    private static func deterministicEvidence(
        sourceIdentity: String,
        signedAccountEvidence: L4SignedAccountReadOnlyEvidence
    ) throws -> L4PrivateStreamAccountSnapshotReadOnlyEvidence {
        try L4PrivateStreamAccountSnapshotReadOnlyEvidence(
            signedAccountEvidenceID: signedAccountEvidence.evidenceID,
            sourceIdentity: sourceIdentity,
            records: [
                L4PrivateStreamAccountSnapshotReadModelRecord(
                    eventKind: .accountSnapshot,
                    sourceKind: .signedAccountSnapshot,
                    freshnessStatus: .fresh,
                    canonicalReadModelValue: "snapshot mapped from GH-455 canonical account evidence",
                    sourceIdentity: sourceIdentity
                ),
                L4PrivateStreamAccountSnapshotReadModelRecord(
                    eventKind: .balanceUpdate,
                    sourceKind: .privateBalanceUpdate,
                    freshnessStatus: .fresh,
                    canonicalReadModelValue: "balance update mapped to read model only",
                    sourceIdentity: sourceIdentity
                ),
                L4PrivateStreamAccountSnapshotReadModelRecord(
                    eventKind: .positionUpdate,
                    sourceKind: .privatePositionUpdate,
                    freshnessStatus: .fresh,
                    canonicalReadModelValue: "position update mapped to read model only",
                    sourceIdentity: sourceIdentity
                ),
                L4PrivateStreamAccountSnapshotReadModelRecord(
                    eventKind: .marginUpdate,
                    sourceKind: .privateMarginUpdate,
                    freshnessStatus: .fresh,
                    canonicalReadModelValue: "margin update mapped to read model only",
                    sourceIdentity: sourceIdentity
                ),
                L4PrivateStreamAccountSnapshotReadModelRecord(
                    eventKind: .staleEvidence,
                    sourceKind: .listenKeySession,
                    freshnessStatus: .stale,
                    canonicalReadModelValue: "stale private stream evidence blocks command inference",
                    sourceIdentity: sourceIdentity
                ),
                L4PrivateStreamAccountSnapshotReadModelRecord(
                    eventKind: .blockedEvidence,
                    sourceKind: .listenKeySession,
                    freshnessStatus: .blocked,
                    canonicalReadModelValue: "blocked private stream evidence keeps Dashboard read-only",
                    sourceIdentity: sourceIdentity
                ),
                L4PrivateStreamAccountSnapshotReadModelRecord(
                    eventKind: .missingEvidence,
                    sourceKind: .listenKeySession,
                    freshnessStatus: .missing,
                    canonicalReadModelValue: "missing private stream evidence has no broker fallback",
                    sourceIdentity: sourceIdentity
                ),
                L4PrivateStreamAccountSnapshotReadModelRecord(
                    eventKind: .disconnectEvidence,
                    sourceKind: .listenKeySession,
                    freshnessStatus: .disconnected,
                    canonicalReadModelValue: "disconnect evidence records no reconnect or command retry",
                    sourceIdentity: sourceIdentity
                )
            ]
        )
    }
}
