import Foundation

/// LiveTradingFoundationGate 固定 Live trading foundation Project 内的 gate 顺序。
///
/// 当前 Core 只把这些 gate 作为合同和验证锚点表达；它不创建 API key 读取、secret 存储、
/// signed request、account endpoint、listenKey、broker adapter 或真实订单执行入口。
public enum LiveTradingFoundationGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case taxonomyBlockedBoundary = "Gate 0 taxonomy / blocked boundary"
    case credentialEndpointBoundary = "Gate 1 API key / signed / account / listenKey boundary"
    case adapterCapabilityIsolation = "Gate 2 adapter capability isolation"
    case realOrderLifecycleTerms = "Gate 3 real order lifecycle terms"
    case liveReadinessBlockedReadModel = "Gate 4 Live readiness blocked read model"
    case workbenchBlockedEvidenceSurface = "Gate 5 Workbench blocked evidence surface"
    case stageValidationCloseout = "Gate 6 stage validation closeout"
}

/// LiveTradingCredentialEndpointCapability 枚举 MTP-62 必须保持禁止的凭证、签名和账户能力。
///
/// 枚举值可以进入 docs、validation matrix、deterministic tests 和后续 read-model-only
/// blocked evidence；它们不能作为当前可调用 adapter、配置项、secret provider 或网络请求能力。
public enum LiveTradingCredentialEndpointCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case secretStorage = "secret storage"
    case requestSignature = "request signature"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case realAccountPayload = "real account payload"
}

/// LiveTradingCredentialEndpointFutureGate 定义 MTP-62 以后才能独立规划的 gate 条件。
///
/// 每个 gate 只描述进入 future Project 前必须补齐的政策、合同和审计证据；当前类型不实现
/// 对应能力，也不从本地环境、Keychain、配置文件或外部系统读取任何 credential。
public enum LiveTradingCredentialEndpointFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveDecision = "Human independent Live decision"
    case apiKeySecretPolicy = "API key / secret policy"
    case signedEndpointCapabilityContract = "signed endpoint capability contract"
    case accountEndpointCapabilityContract = "account endpoint capability contract"
    case listenKeyUserDataStreamContract = "listenKey user data stream contract"
    case publicReadOnlyAdapterSeparation = "public read-only adapter separation"
    case auditAndOperationsEvidence = "audit and operations evidence"
}

/// LiveTradingCredentialEndpointEvidenceKind 限定 MTP-62 当前可以产生的非执行证据。
///
/// 这些 evidence 只服务合同、测试和 PR 审计，不代表实盘 readiness，也不授权后续 issue
/// 自动进入 Todo 或把 public market data adapter 升级为 signed/account 能力。
public enum LiveTradingCredentialEndpointEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case validationMatrixAnchor = "validation matrix anchor"
    case automationReadinessAnchor = "automation readiness anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveReadOnlyCredentialPolicyTerm 固定 MTP-127 的 credential / secret policy 边界词汇。
///
/// 这些术语只描述后续 L3.x 进入真实只读账户能力前必须补齐的 policy gate；当前 Core
/// 不读取本地 secret，不新增 env / Keychain / config secret path，也不实现 credential provider。
public enum LiveReadOnlyCredentialPolicyTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case credentialSecretPolicyFutureGate = "credential / secret policy future gate"
    case noLocalSecretRead = "no local secret read"
    case noAPIKeySecretStorageImplementation = "no API key / secret storage implementation"
    case noSecretConfigurationPath = "no env / keychain / config secret path"
    case noCredentialProviderRuntime = "no credential provider runtime"
}

/// LiveReadOnlyEndpointCapabilityTaxonomy 固定 MTP-127 的 endpoint capability taxonomy。
///
/// `publicReadOnlyMarketData` 是当前唯一允许的 endpoint capability；其余值只能作为
/// forbidden / future gate evidence 出现，不能被解释为当前 signed、account、listenKey、
/// private stream、broker action 或 execution runtime。
public enum LiveReadOnlyEndpointCapabilityTaxonomy: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case publicReadOnlyMarketData = "public read-only market data"
    case signedEndpointForbidden = "signed endpoint forbidden"
    case accountEndpointForbidden = "account endpoint forbidden"
    case listenKeyForbidden = "listenKey forbidden"
    case privateWebSocketForbidden = "private WebSocket forbidden"
    case brokerActionForbidden = "broker action forbidden"
}

/// LiveReadOnlyCredentialEndpointFutureGate 定义 MTP-127 后续才能进入规划的 gate。
///
/// Gate 只描述 policy、contract、simulation input、adapter matrix 和 audit prerequisites；
/// 当前类型不实现 endpoint runtime，也不授权 L3.1、L3.2、L3.3 或 L4 自动施工。
public enum LiveReadOnlyCredentialEndpointFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanIndependentLiveDecision = "Human independent Live decision"
    case credentialSecretPolicy = "credential / secret policy"
    case signedEndpointCapabilityContract = "signed endpoint capability contract"
    case accountEndpointCapabilityContract = "account endpoint capability contract"
    case listenKeyPrivateStreamSimulationGate = "listenKey / private stream simulation gate"
    case adapterCapabilityMatrix = "adapter capability matrix"
    case brokerActionNonExecutionAudit = "broker action non-execution audit"
}

/// LiveReadOnlyCredentialEndpointEvidenceKind 限定 MTP-127 可以产生的非执行证据。
///
/// Evidence 只用于合同、shared language、validation matrix、automation readiness、focused tests
/// 和 PR boundary evidence；它不创建 secret、endpoint、adapter、runtime 或 UI surface。
public enum LiveReadOnlyCredentialEndpointEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case domainContextTerms = "domain context terms"
    case validationMatrixAnchor = "validation matrix anchor"
    case automationReadinessAnchor = "automation readiness anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveAdapterIsolationForbiddenCapability 枚举 MTP-63 Gate 2 必须阻断的 adapter 能力。
///
/// 这些值只描述 future / gated adapter capability，不能被解释为当前 `Adapters` target
/// 已有的类型、协议或运行时连接；当前 Binance adapter 只能保持 public market data read-only。
public enum LiveAdapterIsolationForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case executionVenueConnection = "execution venue connection"
    case orderSubmit = "order submit"
    case orderCancel = "order cancel"
    case orderReplace = "order replace"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case realOrderLifecycle = "real order lifecycle"
    case oms = "OMS"
}

/// LiveAdapterIsolationFutureGate 定义 future live adapter 进入后续 Project 前必须满足的条件。
///
/// Gate 2 只固定隔离合同：future live adapter 仍是未来能力，必须等 credential、broker、
/// real order lifecycle、risk / operations 和 audit gate 独立完成后才能被规划成实现。
public enum LiveAdapterIsolationFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveDecision = "Human independent Live decision"
    case credentialEndpointBoundarySatisfied = "credential endpoint boundary satisfied"
    case adapterCapabilityContract = "adapter capability contract"
    case brokerExchangeAdapterContract = "broker / exchange adapter contract"
    case realOrderLifecycleContract = "real order lifecycle contract"
    case riskAndOperationsReadiness = "risk and operations readiness"
    case auditEvidence = "audit evidence"
}

/// LiveAdapterIsolationEvidenceKind 限定 MTP-63 当前允许产生的非执行证据。
///
/// 这些 evidence 只用于合同、矩阵、automation readiness、deterministic forbidden tests
/// 和 PR 审计；它们不创建任何可实例化的实盘 adapter，也不解锁真实交易执行。
public enum LiveAdapterIsolationEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case validationMatrixAnchor = "validation matrix anchor"
    case automationReadinessAnchor = "automation readiness anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// RealOrderLifecycleTerm 枚举 MTP-64 只能命名、不能实现的真实订单生命周期术语。
///
/// 这些术语服务 Gate 3 合同、validation matrix 和 forbidden tests；它们不代表当前 Core
/// 拥有真实订单状态机、OMS、broker fill 或 reconciliation 能力，也不能从 paper-only
/// lifecycle、simulated fill 或 portfolio projection 偷渡。
public enum RealOrderLifecycleTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case realOrderIntent = "real order intent"
    case realOrderStateMachine = "real order state machine"
    case realOrderSubmit = "real order submit"
    case realOrderCancel = "real order cancel"
    case realOrderReplace = "real order replace"
    case executionReport = "execution report"
    case brokerFill = "broker fill"
    case orderReconciliation = "order reconciliation"
    case oms = "OMS"
    case realAccountState = "real account state"
}

/// RealOrderLifecycleFutureGate 定义真实订单生命周期进入 future Project 前必须补齐的 gate。
///
/// Gate 3 只把 submit / cancel / replace、execution report、broker fill 和 reconciliation
/// 列为后续合同条件；当前类型不执行订单、不读取成交回报、不同步账户或仓位。
public enum RealOrderLifecycleFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveDecision = "Human independent Live decision"
    case credentialEndpointBoundarySatisfied = "credential endpoint boundary satisfied"
    case adapterCapabilityIsolationSatisfied = "adapter capability isolation satisfied"
    case realOrderStateMachineContract = "real order state machine contract"
    case submitContract = "submit contract"
    case cancelContract = "cancel contract"
    case replaceContract = "replace contract"
    case executionReportContract = "execution report contract"
    case brokerFillContract = "broker fill contract"
    case reconciliationContract = "reconciliation contract"
    case omsBlueprint = "OMS blueprint"
    case liveRiskOperationsAuditEvidence = "live risk / operations / audit evidence"
}

/// RealOrderLifecycleForbiddenCapability 枚举 MTP-64 必须保持禁止的真实订单能力。
///
/// 这些能力可以被 deterministic tests 断言为 false，但不能出现在当前可调用 API、adapter、
/// command model、paper evidence 升级路径或 read model 授权语义中。
public enum RealOrderLifecycleForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case realOrderStateMachine = "real order state machine"
    case orderSubmit = "order submit"
    case orderCancel = "order cancel"
    case orderReplace = "order replace"
    case executionReport = "execution report"
    case brokerFill = "broker fill"
    case orderReconciliation = "order reconciliation"
    case oms = "OMS"
    case realAccountState = "real account state"
    case brokerPositionSync = "broker position sync"
    case paperOrderLifecycleUpgrade = "paper order lifecycle upgrade"
    case paperOrderIntentUpgrade = "paper order intent upgrade"
    case simulatedFillUpgrade = "simulated fill upgrade"
    case paperPortfolioProjectionUpgrade = "paper portfolio projection upgrade"
    case readModelRealOrderState = "read model real order state"
}

/// RealOrderLifecycleEvidenceKind 限定 MTP-64 当前允许输出的非执行证据。
///
/// Evidence 只用于合同、矩阵、automation readiness、deterministic forbidden tests 和 PR
/// 审计；它不代表 Live readiness，也不授权 MTP-65+ 或后续 Live execution scope。
public enum RealOrderLifecycleEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case terminologyDocumentation = "terminology documentation"
    case futureGateDocumentation = "future gate documentation"
    case validationMatrixAnchor = "validation matrix anchor"
    case automationReadinessAnchor = "automation readiness anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case paperLiveIsolationEvidence = "paper / live isolation evidence"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveReadinessStatus 表达 MTP-65 read model 当前唯一允许的 readiness 状态。
///
/// 当前 Project 只允许输出 blocked readiness，不能出现 ready、partial、enabled 或 degraded
/// 这类会被误读为实盘可用的状态。
public enum LiveReadinessStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case blocked = "blocked"
}

/// LiveBlockedCapability 枚举 Gate 4 read model 必须展示为 blocked 的最小实盘能力。
///
/// 这些值只用于 read-model-only evidence，不能被解释成 command、adapter capability、secret
/// provider、account endpoint、broker adapter 或真实订单生命周期实现。
public enum LiveBlockedCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case brokerAdapter = "broker adapter"
    case realOrderLifecycle = "real order lifecycle"
}

/// LiveBlockedEvidenceKind 限定 MTP-65 当前允许输出的 read-model-only evidence 类型。
///
/// Evidence 只用于 deterministic snapshot、contract、validation matrix、automation readiness 和
/// PR 审计；它不提供 UI command surface，也不授权真实 Live trading。
public enum LiveBlockedEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case readModelSnapshot = "read model snapshot"
    case contractDocumentation = "contract documentation"
    case validationMatrixAnchor = "validation matrix anchor"
    case automationReadinessAnchor = "automation readiness anchor"
    case deterministicCodableTest = "deterministic Codable test"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveBlockedEvidence 是 MTP-65 的单项 blocked evidence read model。
///
/// 每条 evidence 只把某个 Live gate 显示为 blocked，并记录它来自哪一层已完成合同锚点。
/// 所有 command、adapter、runtime、SQLite / DuckDB schema、API key、signed endpoint、account
/// endpoint、listenKey、broker adapter 和真实订单生命周期 flag 都必须保持 false；Codable 解码
/// 会重复校验，防止 fixture 或后续 App read model 反序列化成可执行 Live 能力。
public struct LiveBlockedEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let gate: LiveTradingFoundationGate
    public let capability: LiveBlockedCapability
    public let evidenceKind: LiveBlockedEvidenceKind
    public let sourceAnchors: [String]
    public let isBlocked: Bool
    public let isReadModelOnly: Bool
    public let providesCommandSurface: Bool
    public let authorizesLiveTrading: Bool
    public let exposesAdapterSurface: Bool
    public let exposesRuntimeObject: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let requiresAPIKey: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerAdapter: Bool
    public let representsRealOrderLifecycle: Bool

    public var blockedReadModelBoundaryHeld: Bool {
        gate == Self.requiredGate(for: capability)
            && sourceAnchors == Self.requiredSourceAnchors(for: capability)
            && isBlocked
            && isReadModelOnly
            && providesCommandSurface == false
            && authorizesLiveTrading == false
            && exposesAdapterSurface == false
            && exposesRuntimeObject == false
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && requiresAPIKey == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerAdapter == false
            && representsRealOrderLifecycle == false
    }

    public init(
        evidenceID: Identifier,
        gate: LiveTradingFoundationGate,
        capability: LiveBlockedCapability,
        evidenceKind: LiveBlockedEvidenceKind = .readModelSnapshot,
        sourceAnchors: [String]? = nil,
        isBlocked: Bool = true,
        isReadModelOnly: Bool = true,
        providesCommandSurface: Bool = false,
        authorizesLiveTrading: Bool = false,
        exposesAdapterSurface: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesSQLiteSchema: Bool = false,
        exposesDuckDBSchema: Bool = false,
        requiresAPIKey: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        instantiatesBrokerAdapter: Bool = false,
        representsRealOrderLifecycle: Bool = false
    ) throws {
        let requiredGate = Self.requiredGate(for: capability)
        let requiredSourceAnchors = Self.requiredSourceAnchors(for: capability)
        guard gate == requiredGate else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "gate",
                expected: requiredGate.rawValue,
                actual: gate.rawValue
            )
        }
        let anchors = sourceAnchors ?? requiredSourceAnchors
        guard anchors == requiredSourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceAnchors",
                expected: requiredSourceAnchors.joined(separator: ","),
                actual: anchors.joined(separator: ",")
            )
        }
        try Self.validateForbiddenFlags(
            isBlocked: isBlocked,
            isReadModelOnly: isReadModelOnly,
            providesCommandSurface: providesCommandSurface,
            authorizesLiveTrading: authorizesLiveTrading,
            exposesAdapterSurface: exposesAdapterSurface,
            exposesRuntimeObject: exposesRuntimeObject,
            exposesSQLiteSchema: exposesSQLiteSchema,
            exposesDuckDBSchema: exposesDuckDBSchema,
            requiresAPIKey: requiresAPIKey,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            instantiatesBrokerAdapter: instantiatesBrokerAdapter,
            representsRealOrderLifecycle: representsRealOrderLifecycle
        )

        self.evidenceID = evidenceID
        self.gate = gate
        self.capability = capability
        self.evidenceKind = evidenceKind
        self.sourceAnchors = anchors
        self.isBlocked = isBlocked
        self.isReadModelOnly = isReadModelOnly
        self.providesCommandSurface = providesCommandSurface
        self.authorizesLiveTrading = authorizesLiveTrading
        self.exposesAdapterSurface = exposesAdapterSurface
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesSQLiteSchema = exposesSQLiteSchema
        self.exposesDuckDBSchema = exposesDuckDBSchema
        self.requiresAPIKey = requiresAPIKey
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.instantiatesBrokerAdapter = instantiatesBrokerAdapter
        self.representsRealOrderLifecycle = representsRealOrderLifecycle
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            evidenceID: try container.decode(Identifier.self, forKey: .evidenceID),
            gate: try container.decode(LiveTradingFoundationGate.self, forKey: .gate),
            capability: try container.decode(LiveBlockedCapability.self, forKey: .capability),
            evidenceKind: try container.decode(LiveBlockedEvidenceKind.self, forKey: .evidenceKind),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            isBlocked: try container.decode(Bool.self, forKey: .isBlocked),
            isReadModelOnly: try container.decode(Bool.self, forKey: .isReadModelOnly),
            providesCommandSurface: try container.decode(Bool.self, forKey: .providesCommandSurface),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            exposesAdapterSurface: try container.decode(Bool.self, forKey: .exposesAdapterSurface),
            exposesRuntimeObject: try container.decode(Bool.self, forKey: .exposesRuntimeObject),
            exposesSQLiteSchema: try container.decode(Bool.self, forKey: .exposesSQLiteSchema),
            exposesDuckDBSchema: try container.decode(Bool.self, forKey: .exposesDuckDBSchema),
            requiresAPIKey: try container.decode(Bool.self, forKey: .requiresAPIKey),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            instantiatesBrokerAdapter: try container.decode(Bool.self, forKey: .instantiatesBrokerAdapter),
            representsRealOrderLifecycle: try container.decode(Bool.self, forKey: .representsRealOrderLifecycle)
        )
    }

    public static func requiredGate(for capability: LiveBlockedCapability) -> LiveTradingFoundationGate {
        switch capability {
        case .apiKey, .signedEndpoint, .accountEndpoint, .listenKeyUserDataStream:
            .credentialEndpointBoundary
        case .brokerAdapter:
            .adapterCapabilityIsolation
        case .realOrderLifecycle:
            .realOrderLifecycleTerms
        }
    }

    public static func requiredSourceAnchors(for capability: LiveBlockedCapability) -> [String] {
        switch capability {
        case .apiKey:
            [
                "MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY",
                "LiveTradingCredentialEndpointBoundary"
            ]
        case .signedEndpoint:
            [
                "MTP-62-LIVE-CREDENTIAL-FUTURE-GATES",
                "LiveTradingCredentialEndpointBoundary"
            ]
        case .accountEndpoint:
            [
                "MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY",
                "LiveTradingCredentialEndpointBoundary"
            ]
        case .listenKeyUserDataStream:
            [
                "MTP-62-LIVE-CREDENTIAL-FUTURE-GATES",
                "LiveTradingCredentialEndpointBoundary"
            ]
        case .brokerAdapter:
            [
                "MTP-63-ADAPTER-CAPABILITY-ISOLATION",
                "LiveAdapterCapabilityIsolationBoundary"
            ]
        case .realOrderLifecycle:
            [
                "MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY",
                "RealOrderLifecycleBoundary"
            ]
        }
    }

    private static func validateForbiddenFlags(
        isBlocked: Bool,
        isReadModelOnly: Bool,
        providesCommandSurface: Bool,
        authorizesLiveTrading: Bool,
        exposesAdapterSurface: Bool,
        exposesRuntimeObject: Bool,
        exposesSQLiteSchema: Bool,
        exposesDuckDBSchema: Bool,
        requiresAPIKey: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        instantiatesBrokerAdapter: Bool,
        representsRealOrderLifecycle: Bool
    ) throws {
        guard isBlocked else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isBlocked")
        }
        guard isReadModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isReadModelOnly")
        }

        let forbiddenFlags = [
            ("providesCommandSurface", providesCommandSurface),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("exposesAdapterSurface", exposesAdapterSurface),
            ("exposesRuntimeObject", exposesRuntimeObject),
            ("exposesSQLiteSchema", exposesSQLiteSchema),
            ("exposesDuckDBSchema", exposesDuckDBSchema),
            ("requiresAPIKey", requiresAPIKey),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("instantiatesBrokerAdapter", instantiatesBrokerAdapter),
            ("representsRealOrderLifecycle", representsRealOrderLifecycle)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveReadiness 是 MTP-65 的最小 Live readiness read model。
///
/// 该 read model 聚合 Gate 1、Gate 2 和 Gate 3 已固定的 blocked evidence，向 App / 后续
/// Dashboard 接入提供稳定只读输入。它不暴露 adapter surface、Runtime object、SQLite / DuckDB
/// schema，不提供 command surface，不读取 API key，不调用 signed / account endpoint，不创建
/// listenKey，不实例化 broker adapter，也不表达真实订单生命周期 readiness。
public struct LiveReadiness: Codable, Equatable, Sendable {
    public let readinessID: Identifier
    public let issueID: Identifier
    public let gate: LiveTradingFoundationGate
    public let status: LiveReadinessStatus
    public let blockedEvidence: [LiveBlockedEvidence]
    public let allowedEvidenceKinds: [LiveBlockedEvidenceKind]
    public let isReadModelOnly: Bool
    public let providesCommandSurface: Bool
    public let authorizesLiveTrading: Bool
    public let exposesAdapterSurface: Bool
    public let exposesRuntimeObject: Bool
    public let exposesSQLiteSchema: Bool
    public let exposesDuckDBSchema: Bool
    public let readsAPIKey: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerAdapter: Bool
    public let representsRealOrderLifecycle: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var liveReadinessBoundaryHeld: Bool {
        gate == .liveReadinessBlockedReadModel
            && status == .blocked
            && blockedEvidence == Self.requiredBlockedEvidence
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && blockedEvidence.allSatisfy(\.blockedReadModelBoundaryHeld)
            && isReadModelOnly
            && providesCommandSurface == false
            && authorizesLiveTrading == false
            && exposesAdapterSurface == false
            && exposesRuntimeObject == false
            && exposesSQLiteSchema == false
            && exposesDuckDBSchema == false
            && readsAPIKey == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerAdapter == false
            && representsRealOrderLifecycle == false
            && requiredValidationDependsOnNetwork == false
    }

    public var allLiveGatesBlocked: Bool {
        status == .blocked
            && blockedEvidence.map(\.capability) == LiveBlockedCapability.allCases
            && blockedEvidence.allSatisfy(\.isBlocked)
    }

    public init(
        readinessID: Identifier = try! Identifier("mtp-65-live-readiness"),
        issueID: Identifier = try! Identifier("MTP-65"),
        gate: LiveTradingFoundationGate = .liveReadinessBlockedReadModel,
        status: LiveReadinessStatus = .blocked,
        blockedEvidence: [LiveBlockedEvidence] = Self.requiredBlockedEvidence,
        allowedEvidenceKinds: [LiveBlockedEvidenceKind] = Self.allowedEvidenceKinds,
        isReadModelOnly: Bool = true,
        providesCommandSurface: Bool = false,
        authorizesLiveTrading: Bool = false,
        exposesAdapterSurface: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesSQLiteSchema: Bool = false,
        exposesDuckDBSchema: Bool = false,
        readsAPIKey: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        instantiatesBrokerAdapter: Bool = false,
        representsRealOrderLifecycle: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        guard gate == .liveReadinessBlockedReadModel else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "gate",
                expected: LiveTradingFoundationGate.liveReadinessBlockedReadModel.rawValue,
                actual: gate.rawValue
            )
        }
        try Self.validate(
            blockedEvidence: blockedEvidence,
            allowedEvidenceKinds: allowedEvidenceKinds
        )
        try Self.validateForbiddenFlags(
            isReadModelOnly: isReadModelOnly,
            providesCommandSurface: providesCommandSurface,
            authorizesLiveTrading: authorizesLiveTrading,
            exposesAdapterSurface: exposesAdapterSurface,
            exposesRuntimeObject: exposesRuntimeObject,
            exposesSQLiteSchema: exposesSQLiteSchema,
            exposesDuckDBSchema: exposesDuckDBSchema,
            readsAPIKey: readsAPIKey,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            instantiatesBrokerAdapter: instantiatesBrokerAdapter,
            representsRealOrderLifecycle: representsRealOrderLifecycle,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.readinessID = readinessID
        self.issueID = issueID
        self.gate = gate
        self.status = status
        self.blockedEvidence = blockedEvidence
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.isReadModelOnly = isReadModelOnly
        self.providesCommandSurface = providesCommandSurface
        self.authorizesLiveTrading = authorizesLiveTrading
        self.exposesAdapterSurface = exposesAdapterSurface
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesSQLiteSchema = exposesSQLiteSchema
        self.exposesDuckDBSchema = exposesDuckDBSchema
        self.readsAPIKey = readsAPIKey
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.instantiatesBrokerAdapter = instantiatesBrokerAdapter
        self.representsRealOrderLifecycle = representsRealOrderLifecycle
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            readinessID: try container.decode(Identifier.self, forKey: .readinessID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            gate: try container.decode(LiveTradingFoundationGate.self, forKey: .gate),
            status: try container.decode(LiveReadinessStatus.self, forKey: .status),
            blockedEvidence: try container.decode([LiveBlockedEvidence].self, forKey: .blockedEvidence),
            allowedEvidenceKinds: try container.decode(
                [LiveBlockedEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            isReadModelOnly: try container.decode(Bool.self, forKey: .isReadModelOnly),
            providesCommandSurface: try container.decode(Bool.self, forKey: .providesCommandSurface),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            exposesAdapterSurface: try container.decode(Bool.self, forKey: .exposesAdapterSurface),
            exposesRuntimeObject: try container.decode(Bool.self, forKey: .exposesRuntimeObject),
            exposesSQLiteSchema: try container.decode(Bool.self, forKey: .exposesSQLiteSchema),
            exposesDuckDBSchema: try container.decode(Bool.self, forKey: .exposesDuckDBSchema),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            instantiatesBrokerAdapter: try container.decode(Bool.self, forKey: .instantiatesBrokerAdapter),
            representsRealOrderLifecycle: try container.decode(Bool.self, forKey: .representsRealOrderLifecycle),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let allowedEvidenceKinds: [LiveBlockedEvidenceKind] = [
        .readModelSnapshot,
        .contractDocumentation,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicCodableTest,
        .prBoundaryEvidence
    ]

    public static let requiredBlockedEvidence: [LiveBlockedEvidence] = [
        Self.makeEvidence(
            "mtp-65-api-key-blocked",
            gate: .credentialEndpointBoundary,
            capability: .apiKey
        ),
        Self.makeEvidence(
            "mtp-65-signed-endpoint-blocked",
            gate: .credentialEndpointBoundary,
            capability: .signedEndpoint
        ),
        Self.makeEvidence(
            "mtp-65-account-endpoint-blocked",
            gate: .credentialEndpointBoundary,
            capability: .accountEndpoint
        ),
        Self.makeEvidence(
            "mtp-65-listen-key-blocked",
            gate: .credentialEndpointBoundary,
            capability: .listenKeyUserDataStream
        ),
        Self.makeEvidence(
            "mtp-65-broker-adapter-blocked",
            gate: .adapterCapabilityIsolation,
            capability: .brokerAdapter
        ),
        Self.makeEvidence(
            "mtp-65-real-order-lifecycle-blocked",
            gate: .realOrderLifecycleTerms,
            capability: .realOrderLifecycle
        )
    ]

    public static let deterministicFixture: LiveReadiness = {
        do {
            return try LiveReadiness()
        } catch {
            preconditionFailure("MTP-65 Live readiness read model fixture must be valid: \(error)")
        }
    }()

    private static func makeEvidence(
        _ evidenceID: String,
        gate: LiveTradingFoundationGate,
        capability: LiveBlockedCapability
    ) -> LiveBlockedEvidence {
        do {
            return try LiveBlockedEvidence(
                evidenceID: try Identifier(evidenceID),
                gate: gate,
                capability: capability
            )
        } catch {
            preconditionFailure("MTP-65 Live blocked evidence fixture must be valid: \(error)")
        }
    }

    private static func validate(
        blockedEvidence: [LiveBlockedEvidence],
        allowedEvidenceKinds: [LiveBlockedEvidenceKind]
    ) throws {
        guard blockedEvidence == Self.requiredBlockedEvidence else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "blockedEvidence",
                expected: Self.requiredBlockedEvidence.map(\.capability.rawValue).joined(separator: ","),
                actual: blockedEvidence.map(\.capability.rawValue).joined(separator: ",")
            )
        }
        guard blockedEvidence.allSatisfy(\.blockedReadModelBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("blockedEvidence")
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isReadModelOnly: Bool,
        providesCommandSurface: Bool,
        authorizesLiveTrading: Bool,
        exposesAdapterSurface: Bool,
        exposesRuntimeObject: Bool,
        exposesSQLiteSchema: Bool,
        exposesDuckDBSchema: Bool,
        readsAPIKey: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        instantiatesBrokerAdapter: Bool,
        representsRealOrderLifecycle: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isReadModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isReadModelOnly")
        }

        let forbiddenFlags = [
            ("providesCommandSurface", providesCommandSurface),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("exposesAdapterSurface", exposesAdapterSurface),
            ("exposesRuntimeObject", exposesRuntimeObject),
            ("exposesSQLiteSchema", exposesSQLiteSchema),
            ("exposesDuckDBSchema", exposesDuckDBSchema),
            ("readsAPIKey", readsAPIKey),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("instantiatesBrokerAdapter", instantiatesBrokerAdapter),
            ("representsRealOrderLifecycle", representsRealOrderLifecycle),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveTradingCredentialEndpointBoundary 是 MTP-62 的 Gate 1 合同 fixture。
///
/// 该合同只表达 API key、secret storage、signed endpoint、account endpoint 和 listenKey
/// 仍被阻断，并把它们挂到 future gate。所有 capability flag 必须为 false；Codable 解码也会
/// 重新执行同一校验，防止测试 fixture 或后续 read model 反序列化时恢复真实 credential、
/// account payload、签名请求或 listenKey user data stream。
public struct LiveTradingCredentialEndpointBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let gate: LiveTradingFoundationGate
    public let forbiddenCapabilities: [LiveTradingCredentialEndpointCapability]
    public let futureGates: [LiveTradingCredentialEndpointFutureGate]
    public let allowedEvidenceKinds: [LiveTradingCredentialEndpointEvidenceKind]
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let signsRequests: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let consumesRealAccountPayload: Bool
    public let upgradesPublicReadOnlyAdapter: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var gateOneBoundaryHeld: Bool {
        gate == .credentialEndpointBoundary
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && futureGates == Self.requiredFutureGates
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && readsAPIKey == false
            && storesSecret == false
            && signsRequests == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && consumesRealAccountPayload == false
            && upgradesPublicReadOnlyAdapter == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-62-live-credential-endpoint-boundary"),
        issueID: Identifier = try! Identifier("MTP-62"),
        gate: LiveTradingFoundationGate = .credentialEndpointBoundary,
        forbiddenCapabilities: [LiveTradingCredentialEndpointCapability] = Self.requiredForbiddenCapabilities,
        futureGates: [LiveTradingCredentialEndpointFutureGate] = Self.requiredFutureGates,
        allowedEvidenceKinds: [LiveTradingCredentialEndpointEvidenceKind] = Self.allowedEvidenceKinds,
        readsAPIKey: Bool = false,
        storesSecret: Bool = false,
        signsRequests: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        consumesRealAccountPayload: Bool = false,
        upgradesPublicReadOnlyAdapter: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        guard gate == .credentialEndpointBoundary else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "gate",
                expected: LiveTradingFoundationGate.credentialEndpointBoundary.rawValue,
                actual: gate.rawValue
            )
        }
        try Self.validate(
            forbiddenCapabilities: forbiddenCapabilities,
            futureGates: futureGates,
            allowedEvidenceKinds: allowedEvidenceKinds
        )
        try Self.validateForbiddenFlags(
            readsAPIKey: readsAPIKey,
            storesSecret: storesSecret,
            signsRequests: signsRequests,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            consumesRealAccountPayload: consumesRealAccountPayload,
            upgradesPublicReadOnlyAdapter: upgradesPublicReadOnlyAdapter,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.gate = gate
        self.forbiddenCapabilities = forbiddenCapabilities
        self.futureGates = futureGates
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.readsAPIKey = readsAPIKey
        self.storesSecret = storesSecret
        self.signsRequests = signsRequests
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.consumesRealAccountPayload = consumesRealAccountPayload
        self.upgradesPublicReadOnlyAdapter = upgradesPublicReadOnlyAdapter
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            gate: try container.decode(LiveTradingFoundationGate.self, forKey: .gate),
            forbiddenCapabilities: try container.decode(
                [LiveTradingCredentialEndpointCapability].self,
                forKey: .forbiddenCapabilities
            ),
            futureGates: try container.decode(
                [LiveTradingCredentialEndpointFutureGate].self,
                forKey: .futureGates
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveTradingCredentialEndpointEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            storesSecret: try container.decode(Bool.self, forKey: .storesSecret),
            signsRequests: try container.decode(Bool.self, forKey: .signsRequests),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            consumesRealAccountPayload: try container.decode(
                Bool.self,
                forKey: .consumesRealAccountPayload
            ),
            upgradesPublicReadOnlyAdapter: try container.decode(
                Bool.self,
                forKey: .upgradesPublicReadOnlyAdapter
            ),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredForbiddenCapabilities: [LiveTradingCredentialEndpointCapability] = [
        .apiKey,
        .secretStorage,
        .requestSignature,
        .signedEndpoint,
        .accountEndpoint,
        .listenKeyUserDataStream,
        .realAccountPayload
    ]

    public static let requiredFutureGates: [LiveTradingCredentialEndpointFutureGate] = [
        .humanLiveDecision,
        .apiKeySecretPolicy,
        .signedEndpointCapabilityContract,
        .accountEndpointCapabilityContract,
        .listenKeyUserDataStreamContract,
        .publicReadOnlyAdapterSeparation,
        .auditAndOperationsEvidence
    ]

    public static let allowedEvidenceKinds: [LiveTradingCredentialEndpointEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicForbiddenTest,
        .prBoundaryEvidence
    ]

    public static let deterministicFixture: LiveTradingCredentialEndpointBoundary = {
        do {
            return try LiveTradingCredentialEndpointBoundary()
        } catch {
            preconditionFailure("MTP-62 Live credential endpoint boundary fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        forbiddenCapabilities: [LiveTradingCredentialEndpointCapability],
        futureGates: [LiveTradingCredentialEndpointFutureGate],
        allowedEvidenceKinds: [LiveTradingCredentialEndpointEvidenceKind]
    ) throws {
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        readsAPIKey: Bool,
        storesSecret: Bool,
        signsRequests: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        consumesRealAccountPayload: Bool,
        upgradesPublicReadOnlyAdapter: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        let forbiddenFlags = [
            ("readsAPIKey", readsAPIKey),
            ("storesSecret", storesSecret),
            ("signsRequests", signsRequests),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("consumesRealAccountPayload", consumesRealAccountPayload),
            ("upgradesPublicReadOnlyAdapter", upgradesPublicReadOnlyAdapter),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveReadOnlyCredentialEndpointTaxonomyBoundary 是 MTP-127 的 L3.0 credential / endpoint taxonomy fixture。
///
/// 该合同只把 credential / secret policy、endpoint capability taxonomy 和 public read-only
/// 隔离关系固定为 deterministic evidence。当前唯一允许能力是 public read-only market data；
/// API key / secret storage、本地 secret read、signed endpoint、account endpoint、listenKey、
/// private WebSocket、broker action、`LiveExecutionAdapter` 和 private read runtime flag 必须
/// 全部保持 false。Codable 解码会重复执行同一校验，防止测试 payload 或后续 read model
/// 把 L3.0 readiness taxonomy 反序列化成真实 endpoint runtime。
public struct LiveReadOnlyCredentialEndpointTaxonomyBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let matrixID: String
    public let credentialPolicyTerms: [LiveReadOnlyCredentialPolicyTerm]
    public let endpointTaxonomy: [LiveReadOnlyEndpointCapabilityTaxonomy]
    public let allowedCurrentEndpointCapabilities: [LiveReadOnlyEndpointCapabilityTaxonomy]
    public let forbiddenEndpointCapabilities: [LiveReadOnlyEndpointCapabilityTaxonomy]
    public let futureGates: [LiveReadOnlyCredentialEndpointFutureGate]
    public let allowedEvidenceKinds: [LiveReadOnlyCredentialEndpointEvidenceKind]
    public let readsLocalSecret: Bool
    public let implementsAPIKeyStorage: Bool
    public let createsSecretConfigurationPath: Bool
    public let signsRequest: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let opensPrivateWebSocket: Bool
    public let connectsBrokerAdapter: Bool
    public let performsBrokerAction: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let exposesPrivateReadRuntime: Bool
    public let upgradesPublicReadOnlyAdapter: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var credentialEndpointTaxonomyBoundaryHeld: Bool {
        matrixID == Self.requiredMatrixID
            && credentialPolicyTerms == Self.requiredCredentialPolicyTerms
            && endpointTaxonomy == Self.requiredEndpointTaxonomy
            && allowedCurrentEndpointCapabilities == Self.requiredAllowedCurrentEndpointCapabilities
            && forbiddenEndpointCapabilities == Self.requiredForbiddenEndpointCapabilities
            && futureGates == Self.requiredFutureGates
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && readsLocalSecret == false
            && implementsAPIKeyStorage == false
            && createsSecretConfigurationPath == false
            && signsRequest == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && opensPrivateWebSocket == false
            && connectsBrokerAdapter == false
            && performsBrokerAction == false
            && implementsLiveExecutionAdapter == false
            && exposesPrivateReadRuntime == false
            && upgradesPublicReadOnlyAdapter == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-127-live-read-only-credential-endpoint-taxonomy"),
        issueID: Identifier = try! Identifier("MTP-127"),
        matrixID: String = Self.requiredMatrixID,
        credentialPolicyTerms: [LiveReadOnlyCredentialPolicyTerm] = Self.requiredCredentialPolicyTerms,
        endpointTaxonomy: [LiveReadOnlyEndpointCapabilityTaxonomy] = Self.requiredEndpointTaxonomy,
        allowedCurrentEndpointCapabilities: [LiveReadOnlyEndpointCapabilityTaxonomy] =
            Self.requiredAllowedCurrentEndpointCapabilities,
        forbiddenEndpointCapabilities: [LiveReadOnlyEndpointCapabilityTaxonomy] =
            Self.requiredForbiddenEndpointCapabilities,
        futureGates: [LiveReadOnlyCredentialEndpointFutureGate] = Self.requiredFutureGates,
        allowedEvidenceKinds: [LiveReadOnlyCredentialEndpointEvidenceKind] = Self.allowedEvidenceKinds,
        readsLocalSecret: Bool = false,
        implementsAPIKeyStorage: Bool = false,
        createsSecretConfigurationPath: Bool = false,
        signsRequest: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        opensPrivateWebSocket: Bool = false,
        connectsBrokerAdapter: Bool = false,
        performsBrokerAction: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        exposesPrivateReadRuntime: Bool = false,
        upgradesPublicReadOnlyAdapter: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            matrixID: matrixID,
            credentialPolicyTerms: credentialPolicyTerms,
            endpointTaxonomy: endpointTaxonomy,
            allowedCurrentEndpointCapabilities: allowedCurrentEndpointCapabilities,
            forbiddenEndpointCapabilities: forbiddenEndpointCapabilities,
            futureGates: futureGates,
            allowedEvidenceKinds: allowedEvidenceKinds
        )
        try Self.validateForbiddenFlags(
            readsLocalSecret: readsLocalSecret,
            implementsAPIKeyStorage: implementsAPIKeyStorage,
            createsSecretConfigurationPath: createsSecretConfigurationPath,
            signsRequest: signsRequest,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            opensPrivateWebSocket: opensPrivateWebSocket,
            connectsBrokerAdapter: connectsBrokerAdapter,
            performsBrokerAction: performsBrokerAction,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            exposesPrivateReadRuntime: exposesPrivateReadRuntime,
            upgradesPublicReadOnlyAdapter: upgradesPublicReadOnlyAdapter,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.matrixID = matrixID
        self.credentialPolicyTerms = credentialPolicyTerms
        self.endpointTaxonomy = endpointTaxonomy
        self.allowedCurrentEndpointCapabilities = allowedCurrentEndpointCapabilities
        self.forbiddenEndpointCapabilities = forbiddenEndpointCapabilities
        self.futureGates = futureGates
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.readsLocalSecret = readsLocalSecret
        self.implementsAPIKeyStorage = implementsAPIKeyStorage
        self.createsSecretConfigurationPath = createsSecretConfigurationPath
        self.signsRequest = signsRequest
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.connectsBrokerAdapter = connectsBrokerAdapter
        self.performsBrokerAction = performsBrokerAction
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.exposesPrivateReadRuntime = exposesPrivateReadRuntime
        self.upgradesPublicReadOnlyAdapter = upgradesPublicReadOnlyAdapter
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            matrixID: try container.decode(String.self, forKey: .matrixID),
            credentialPolicyTerms: try container.decode(
                [LiveReadOnlyCredentialPolicyTerm].self,
                forKey: .credentialPolicyTerms
            ),
            endpointTaxonomy: try container.decode(
                [LiveReadOnlyEndpointCapabilityTaxonomy].self,
                forKey: .endpointTaxonomy
            ),
            allowedCurrentEndpointCapabilities: try container.decode(
                [LiveReadOnlyEndpointCapabilityTaxonomy].self,
                forKey: .allowedCurrentEndpointCapabilities
            ),
            forbiddenEndpointCapabilities: try container.decode(
                [LiveReadOnlyEndpointCapabilityTaxonomy].self,
                forKey: .forbiddenEndpointCapabilities
            ),
            futureGates: try container.decode(
                [LiveReadOnlyCredentialEndpointFutureGate].self,
                forKey: .futureGates
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveReadOnlyCredentialEndpointEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            readsLocalSecret: try container.decode(Bool.self, forKey: .readsLocalSecret),
            implementsAPIKeyStorage: try container.decode(Bool.self, forKey: .implementsAPIKeyStorage),
            createsSecretConfigurationPath: try container.decode(
                Bool.self,
                forKey: .createsSecretConfigurationPath
            ),
            signsRequest: try container.decode(Bool.self, forKey: .signsRequest),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            opensPrivateWebSocket: try container.decode(Bool.self, forKey: .opensPrivateWebSocket),
            connectsBrokerAdapter: try container.decode(Bool.self, forKey: .connectsBrokerAdapter),
            performsBrokerAction: try container.decode(Bool.self, forKey: .performsBrokerAction),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            exposesPrivateReadRuntime: try container.decode(Bool.self, forKey: .exposesPrivateReadRuntime),
            upgradesPublicReadOnlyAdapter: try container.decode(Bool.self, forKey: .upgradesPublicReadOnlyAdapter),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredMatrixID = "TVM-LIVE-READ-ONLY-READINESS"
    public static let requiredCredentialPolicyTerms = LiveReadOnlyCredentialPolicyTerm.allCases
    public static let requiredEndpointTaxonomy = LiveReadOnlyEndpointCapabilityTaxonomy.allCases

    public static let requiredAllowedCurrentEndpointCapabilities: [LiveReadOnlyEndpointCapabilityTaxonomy] = [
        .publicReadOnlyMarketData
    ]

    public static let requiredForbiddenEndpointCapabilities: [LiveReadOnlyEndpointCapabilityTaxonomy] = [
        .signedEndpointForbidden,
        .accountEndpointForbidden,
        .listenKeyForbidden,
        .privateWebSocketForbidden,
        .brokerActionForbidden
    ]

    public static let requiredFutureGates: [LiveReadOnlyCredentialEndpointFutureGate] = [
        .humanIndependentLiveDecision,
        .credentialSecretPolicy,
        .signedEndpointCapabilityContract,
        .accountEndpointCapabilityContract,
        .listenKeyPrivateStreamSimulationGate,
        .adapterCapabilityMatrix,
        .brokerActionNonExecutionAudit
    ]

    public static let allowedEvidenceKinds: [LiveReadOnlyCredentialEndpointEvidenceKind] = [
        .contractDocumentation,
        .domainContextTerms,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicForbiddenTest,
        .prBoundaryEvidence
    ]

    public static let deterministicFixture: LiveReadOnlyCredentialEndpointTaxonomyBoundary = {
        do {
            return try LiveReadOnlyCredentialEndpointTaxonomyBoundary()
        } catch {
            preconditionFailure("MTP-127 Live read-only credential endpoint taxonomy fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        matrixID: String,
        credentialPolicyTerms: [LiveReadOnlyCredentialPolicyTerm],
        endpointTaxonomy: [LiveReadOnlyEndpointCapabilityTaxonomy],
        allowedCurrentEndpointCapabilities: [LiveReadOnlyEndpointCapabilityTaxonomy],
        forbiddenEndpointCapabilities: [LiveReadOnlyEndpointCapabilityTaxonomy],
        futureGates: [LiveReadOnlyCredentialEndpointFutureGate],
        allowedEvidenceKinds: [LiveReadOnlyCredentialEndpointEvidenceKind]
    ) throws {
        guard matrixID == Self.requiredMatrixID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "matrixID",
                expected: Self.requiredMatrixID,
                actual: matrixID
            )
        }
        guard credentialPolicyTerms == Self.requiredCredentialPolicyTerms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "credentialPolicyTerms",
                expected: Self.requiredCredentialPolicyTerms.map(\.rawValue).joined(separator: ","),
                actual: credentialPolicyTerms.map(\.rawValue).joined(separator: ",")
            )
        }
        guard endpointTaxonomy == Self.requiredEndpointTaxonomy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointTaxonomy",
                expected: Self.requiredEndpointTaxonomy.map(\.rawValue).joined(separator: ","),
                actual: endpointTaxonomy.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedCurrentEndpointCapabilities == Self.requiredAllowedCurrentEndpointCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedCurrentEndpointCapabilities",
                expected: Self.requiredAllowedCurrentEndpointCapabilities.map(\.rawValue).joined(separator: ","),
                actual: allowedCurrentEndpointCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenEndpointCapabilities == Self.requiredForbiddenEndpointCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenEndpointCapabilities",
                expected: Self.requiredForbiddenEndpointCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenEndpointCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        readsLocalSecret: Bool,
        implementsAPIKeyStorage: Bool,
        createsSecretConfigurationPath: Bool,
        signsRequest: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        opensPrivateWebSocket: Bool,
        connectsBrokerAdapter: Bool,
        performsBrokerAction: Bool,
        implementsLiveExecutionAdapter: Bool,
        exposesPrivateReadRuntime: Bool,
        upgradesPublicReadOnlyAdapter: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        let forbiddenFlags = [
            ("readsLocalSecret", readsLocalSecret),
            ("implementsAPIKeyStorage", implementsAPIKeyStorage),
            ("createsSecretConfigurationPath", createsSecretConfigurationPath),
            ("signsRequest", signsRequest),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("opensPrivateWebSocket", opensPrivateWebSocket),
            ("connectsBrokerAdapter", connectsBrokerAdapter),
            ("performsBrokerAction", performsBrokerAction),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("exposesPrivateReadRuntime", exposesPrivateReadRuntime),
            ("upgradesPublicReadOnlyAdapter", upgradesPublicReadOnlyAdapter),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// RealOrderLifecycleBoundary 是 MTP-64 的 Gate 3 合同 fixture。
///
/// 该合同只定义真实订单生命周期术语、future gates 和 forbidden capability tests。所有
/// submit / cancel / replace、execution report、broker fill、reconciliation、OMS、真实账户
/// 和 paper evidence 升级 flag 都必须保持 false；Codable 解码会重复校验，防止后续
/// read model 或测试 payload 把 blocked evidence 反序列化成真实订单状态机。
public struct RealOrderLifecycleBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let gate: LiveTradingFoundationGate
    public let terminology: [RealOrderLifecycleTerm]
    public let forbiddenCapabilities: [RealOrderLifecycleForbiddenCapability]
    public let futureGates: [RealOrderLifecycleFutureGate]
    public let allowedEvidenceKinds: [RealOrderLifecycleEvidenceKind]
    public let implementsRealOrderStateMachine: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool
    public let implementsOMS: Bool
    public let readsRealAccountState: Bool
    public let syncsBrokerPosition: Bool
    public let upgradesPaperOrderLifecycle: Bool
    public let upgradesPaperOrderIntent: Bool
    public let upgradesSimulatedFillToBrokerFill: Bool
    public let upgradesPaperPortfolioToAccountState: Bool
    public let readModelRepresentsRealOrderLifecycle: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var gateThreeBoundaryHeld: Bool {
        gate == .realOrderLifecycleTerms
            && terminology == Self.requiredTerminology
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && futureGates == Self.requiredFutureGates
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && implementsRealOrderStateMachine == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
            && implementsOMS == false
            && readsRealAccountState == false
            && syncsBrokerPosition == false
            && upgradesPaperOrderLifecycle == false
            && upgradesPaperOrderIntent == false
            && upgradesSimulatedFillToBrokerFill == false
            && upgradesPaperPortfolioToAccountState == false
            && readModelRepresentsRealOrderLifecycle == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-64-real-order-lifecycle-boundary"),
        issueID: Identifier = try! Identifier("MTP-64"),
        gate: LiveTradingFoundationGate = .realOrderLifecycleTerms,
        terminology: [RealOrderLifecycleTerm] = Self.requiredTerminology,
        forbiddenCapabilities: [RealOrderLifecycleForbiddenCapability] = Self.requiredForbiddenCapabilities,
        futureGates: [RealOrderLifecycleFutureGate] = Self.requiredFutureGates,
        allowedEvidenceKinds: [RealOrderLifecycleEvidenceKind] = Self.allowedEvidenceKinds,
        implementsRealOrderStateMachine: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        performsReconciliation: Bool = false,
        implementsOMS: Bool = false,
        readsRealAccountState: Bool = false,
        syncsBrokerPosition: Bool = false,
        upgradesPaperOrderLifecycle: Bool = false,
        upgradesPaperOrderIntent: Bool = false,
        upgradesSimulatedFillToBrokerFill: Bool = false,
        upgradesPaperPortfolioToAccountState: Bool = false,
        readModelRepresentsRealOrderLifecycle: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        guard gate == .realOrderLifecycleTerms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "gate",
                expected: LiveTradingFoundationGate.realOrderLifecycleTerms.rawValue,
                actual: gate.rawValue
            )
        }
        try Self.validate(
            terminology: terminology,
            forbiddenCapabilities: forbiddenCapabilities,
            futureGates: futureGates,
            allowedEvidenceKinds: allowedEvidenceKinds
        )
        try Self.validateForbiddenFlags(
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            performsReconciliation: performsReconciliation,
            implementsOMS: implementsOMS,
            readsRealAccountState: readsRealAccountState,
            syncsBrokerPosition: syncsBrokerPosition,
            upgradesPaperOrderLifecycle: upgradesPaperOrderLifecycle,
            upgradesPaperOrderIntent: upgradesPaperOrderIntent,
            upgradesSimulatedFillToBrokerFill: upgradesSimulatedFillToBrokerFill,
            upgradesPaperPortfolioToAccountState: upgradesPaperPortfolioToAccountState,
            readModelRepresentsRealOrderLifecycle: readModelRepresentsRealOrderLifecycle,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.gate = gate
        self.terminology = terminology
        self.forbiddenCapabilities = forbiddenCapabilities
        self.futureGates = futureGates
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.performsReconciliation = performsReconciliation
        self.implementsOMS = implementsOMS
        self.readsRealAccountState = readsRealAccountState
        self.syncsBrokerPosition = syncsBrokerPosition
        self.upgradesPaperOrderLifecycle = upgradesPaperOrderLifecycle
        self.upgradesPaperOrderIntent = upgradesPaperOrderIntent
        self.upgradesSimulatedFillToBrokerFill = upgradesSimulatedFillToBrokerFill
        self.upgradesPaperPortfolioToAccountState = upgradesPaperPortfolioToAccountState
        self.readModelRepresentsRealOrderLifecycle = readModelRepresentsRealOrderLifecycle
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            gate: try container.decode(LiveTradingFoundationGate.self, forKey: .gate),
            terminology: try container.decode([RealOrderLifecycleTerm].self, forKey: .terminology),
            forbiddenCapabilities: try container.decode(
                [RealOrderLifecycleForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            futureGates: try container.decode([RealOrderLifecycleFutureGate].self, forKey: .futureGates),
            allowedEvidenceKinds: try container.decode(
                [RealOrderLifecycleEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            implementsRealOrderStateMachine: try container.decode(
                Bool.self,
                forKey: .implementsRealOrderStateMachine
            ),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            performsReconciliation: try container.decode(Bool.self, forKey: .performsReconciliation),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            readsRealAccountState: try container.decode(Bool.self, forKey: .readsRealAccountState),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            upgradesPaperOrderLifecycle: try container.decode(Bool.self, forKey: .upgradesPaperOrderLifecycle),
            upgradesPaperOrderIntent: try container.decode(Bool.self, forKey: .upgradesPaperOrderIntent),
            upgradesSimulatedFillToBrokerFill: try container.decode(
                Bool.self,
                forKey: .upgradesSimulatedFillToBrokerFill
            ),
            upgradesPaperPortfolioToAccountState: try container.decode(
                Bool.self,
                forKey: .upgradesPaperPortfolioToAccountState
            ),
            readModelRepresentsRealOrderLifecycle: try container.decode(
                Bool.self,
                forKey: .readModelRepresentsRealOrderLifecycle
            ),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredTerminology = RealOrderLifecycleTerm.allCases
    public static let requiredForbiddenCapabilities = RealOrderLifecycleForbiddenCapability.allCases

    public static let requiredFutureGates: [RealOrderLifecycleFutureGate] = [
        .humanLiveDecision,
        .credentialEndpointBoundarySatisfied,
        .adapterCapabilityIsolationSatisfied,
        .realOrderStateMachineContract,
        .submitContract,
        .cancelContract,
        .replaceContract,
        .executionReportContract,
        .brokerFillContract,
        .reconciliationContract,
        .omsBlueprint,
        .liveRiskOperationsAuditEvidence
    ]

    public static let allowedEvidenceKinds: [RealOrderLifecycleEvidenceKind] = [
        .terminologyDocumentation,
        .futureGateDocumentation,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicForbiddenTest,
        .paperLiveIsolationEvidence,
        .prBoundaryEvidence
    ]

    public static let deterministicFixture: RealOrderLifecycleBoundary = {
        do {
            return try RealOrderLifecycleBoundary()
        } catch {
            preconditionFailure("MTP-64 real order lifecycle boundary fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terminology: [RealOrderLifecycleTerm],
        forbiddenCapabilities: [RealOrderLifecycleForbiddenCapability],
        futureGates: [RealOrderLifecycleFutureGate],
        allowedEvidenceKinds: [RealOrderLifecycleEvidenceKind]
    ) throws {
        guard terminology == Self.requiredTerminology else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "terminology",
                expected: Self.requiredTerminology.map(\.rawValue).joined(separator: ","),
                actual: terminology.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        implementsRealOrderStateMachine: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        performsReconciliation: Bool,
        implementsOMS: Bool,
        readsRealAccountState: Bool,
        syncsBrokerPosition: Bool,
        upgradesPaperOrderLifecycle: Bool,
        upgradesPaperOrderIntent: Bool,
        upgradesSimulatedFillToBrokerFill: Bool,
        upgradesPaperPortfolioToAccountState: Bool,
        readModelRepresentsRealOrderLifecycle: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        let forbiddenFlags = [
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("performsReconciliation", performsReconciliation),
            ("implementsOMS", implementsOMS),
            ("readsRealAccountState", readsRealAccountState),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("upgradesPaperOrderLifecycle", upgradesPaperOrderLifecycle),
            ("upgradesPaperOrderIntent", upgradesPaperOrderIntent),
            ("upgradesSimulatedFillToBrokerFill", upgradesSimulatedFillToBrokerFill),
            ("upgradesPaperPortfolioToAccountState", upgradesPaperPortfolioToAccountState),
            ("readModelRepresentsRealOrderLifecycle", readModelRepresentsRealOrderLifecycle),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveAdapterCapabilityIsolationBoundary 是 MTP-63 的 Gate 2 合同 fixture。
///
/// 该合同把当前 Binance public read-only adapter 与 future live adapter capability 明确隔离：
/// 当前 adapter 只能提供公开行情读取，future live adapter / broker / exchange execution adapter
/// 只能作为 future gate 和 forbidden test 出现。所有执行、venue、真实订单和网络依赖 flag 必须
/// 为 false；Codable 解码也会重新校验，防止 fixture 被篡改成实盘执行入口。
public struct LiveAdapterCapabilityIsolationBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let gate: LiveTradingFoundationGate
    public let currentAdapterName: String
    public let readOnlyAllowedCapabilities: [String]
    public let forbiddenCapabilities: [LiveAdapterIsolationForbiddenCapability]
    public let futureGates: [LiveAdapterIsolationFutureGate]
    public let allowedEvidenceKinds: [LiveAdapterIsolationEvidenceKind]
    public let currentAdapterIsReadOnly: Bool
    public let currentAdapterRequiresAPIKey: Bool
    public let currentAdapterUsesSignedEndpoint: Bool
    public let currentAdapterCallsAccountEndpoint: Bool
    public let currentAdapterCreatesListenKey: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let exposesExecutionVenueConnection: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var gateTwoBoundaryHeld: Bool {
        gate == .adapterCapabilityIsolation
            && currentAdapterName == Self.currentAdapterName
            && readOnlyAllowedCapabilities == Self.requiredReadOnlyAllowedCapabilities
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && futureGates == Self.requiredFutureGates
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && currentAdapterIsReadOnly
            && currentAdapterRequiresAPIKey == false
            && currentAdapterUsesSignedEndpoint == false
            && currentAdapterCallsAccountEndpoint == false
            && currentAdapterCreatesListenKey == false
            && implementsLiveExecutionAdapter == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && exposesExecutionVenueConnection == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-63-live-adapter-capability-isolation"),
        issueID: Identifier = try! Identifier("MTP-63"),
        gate: LiveTradingFoundationGate = .adapterCapabilityIsolation,
        currentAdapterName: String = Self.currentAdapterName,
        readOnlyAllowedCapabilities: [String] = Self.requiredReadOnlyAllowedCapabilities,
        forbiddenCapabilities: [LiveAdapterIsolationForbiddenCapability] = Self.requiredForbiddenCapabilities,
        futureGates: [LiveAdapterIsolationFutureGate] = Self.requiredFutureGates,
        allowedEvidenceKinds: [LiveAdapterIsolationEvidenceKind] = Self.allowedEvidenceKinds,
        currentAdapterIsReadOnly: Bool = true,
        currentAdapterRequiresAPIKey: Bool = false,
        currentAdapterUsesSignedEndpoint: Bool = false,
        currentAdapterCallsAccountEndpoint: Bool = false,
        currentAdapterCreatesListenKey: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        exposesExecutionVenueConnection: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        guard gate == .adapterCapabilityIsolation else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "gate",
                expected: LiveTradingFoundationGate.adapterCapabilityIsolation.rawValue,
                actual: gate.rawValue
            )
        }
        try Self.validate(
            currentAdapterName: currentAdapterName,
            readOnlyAllowedCapabilities: readOnlyAllowedCapabilities,
            forbiddenCapabilities: forbiddenCapabilities,
            futureGates: futureGates,
            allowedEvidenceKinds: allowedEvidenceKinds
        )
        try Self.validateForbiddenFlags(
            currentAdapterIsReadOnly: currentAdapterIsReadOnly,
            currentAdapterRequiresAPIKey: currentAdapterRequiresAPIKey,
            currentAdapterUsesSignedEndpoint: currentAdapterUsesSignedEndpoint,
            currentAdapterCallsAccountEndpoint: currentAdapterCallsAccountEndpoint,
            currentAdapterCreatesListenKey: currentAdapterCreatesListenKey,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            exposesExecutionVenueConnection: exposesExecutionVenueConnection,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.gate = gate
        self.currentAdapterName = currentAdapterName
        self.readOnlyAllowedCapabilities = readOnlyAllowedCapabilities
        self.forbiddenCapabilities = forbiddenCapabilities
        self.futureGates = futureGates
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.currentAdapterIsReadOnly = currentAdapterIsReadOnly
        self.currentAdapterRequiresAPIKey = currentAdapterRequiresAPIKey
        self.currentAdapterUsesSignedEndpoint = currentAdapterUsesSignedEndpoint
        self.currentAdapterCallsAccountEndpoint = currentAdapterCallsAccountEndpoint
        self.currentAdapterCreatesListenKey = currentAdapterCreatesListenKey
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.exposesExecutionVenueConnection = exposesExecutionVenueConnection
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            gate: try container.decode(LiveTradingFoundationGate.self, forKey: .gate),
            currentAdapterName: try container.decode(String.self, forKey: .currentAdapterName),
            readOnlyAllowedCapabilities: try container.decode([String].self, forKey: .readOnlyAllowedCapabilities),
            forbiddenCapabilities: try container.decode(
                [LiveAdapterIsolationForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            futureGates: try container.decode([LiveAdapterIsolationFutureGate].self, forKey: .futureGates),
            allowedEvidenceKinds: try container.decode(
                [LiveAdapterIsolationEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            currentAdapterIsReadOnly: try container.decode(Bool.self, forKey: .currentAdapterIsReadOnly),
            currentAdapterRequiresAPIKey: try container.decode(Bool.self, forKey: .currentAdapterRequiresAPIKey),
            currentAdapterUsesSignedEndpoint: try container.decode(
                Bool.self,
                forKey: .currentAdapterUsesSignedEndpoint
            ),
            currentAdapterCallsAccountEndpoint: try container.decode(
                Bool.self,
                forKey: .currentAdapterCallsAccountEndpoint
            ),
            currentAdapterCreatesListenKey: try container.decode(Bool.self, forKey: .currentAdapterCreatesListenKey),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            exposesExecutionVenueConnection: try container.decode(
                Bool.self,
                forKey: .exposesExecutionVenueConnection
            ),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let currentAdapterName = "Binance public market data"

    public static let requiredReadOnlyAllowedCapabilities = [
        "exchangeInfo",
        "klines",
        "recent trades",
        "best bid / ask",
        "depth snapshot",
        "depth delta"
    ]

    public static let requiredForbiddenCapabilities = LiveAdapterIsolationForbiddenCapability.allCases

    public static let requiredFutureGates: [LiveAdapterIsolationFutureGate] = [
        .humanLiveDecision,
        .credentialEndpointBoundarySatisfied,
        .adapterCapabilityContract,
        .brokerExchangeAdapterContract,
        .realOrderLifecycleContract,
        .riskAndOperationsReadiness,
        .auditEvidence
    ]

    public static let allowedEvidenceKinds: [LiveAdapterIsolationEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicForbiddenTest,
        .prBoundaryEvidence
    ]

    public static let deterministicFixture: LiveAdapterCapabilityIsolationBoundary = {
        do {
            return try LiveAdapterCapabilityIsolationBoundary()
        } catch {
            preconditionFailure("MTP-63 Live adapter capability isolation fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        currentAdapterName: String,
        readOnlyAllowedCapabilities: [String],
        forbiddenCapabilities: [LiveAdapterIsolationForbiddenCapability],
        futureGates: [LiveAdapterIsolationFutureGate],
        allowedEvidenceKinds: [LiveAdapterIsolationEvidenceKind]
    ) throws {
        guard currentAdapterName == Self.currentAdapterName else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "currentAdapterName",
                expected: Self.currentAdapterName,
                actual: currentAdapterName
            )
        }
        guard readOnlyAllowedCapabilities == Self.requiredReadOnlyAllowedCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "readOnlyAllowedCapabilities",
                expected: Self.requiredReadOnlyAllowedCapabilities.joined(separator: ","),
                actual: readOnlyAllowedCapabilities.joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        currentAdapterIsReadOnly: Bool,
        currentAdapterRequiresAPIKey: Bool,
        currentAdapterUsesSignedEndpoint: Bool,
        currentAdapterCallsAccountEndpoint: Bool,
        currentAdapterCreatesListenKey: Bool,
        implementsLiveExecutionAdapter: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        exposesExecutionVenueConnection: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard currentAdapterIsReadOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("currentAdapterIsReadOnly")
        }

        let forbiddenFlags = [
            ("currentAdapterRequiresAPIKey", currentAdapterRequiresAPIKey),
            ("currentAdapterUsesSignedEndpoint", currentAdapterUsesSignedEndpoint),
            ("currentAdapterCallsAccountEndpoint", currentAdapterCallsAccountEndpoint),
            ("currentAdapterCreatesListenKey", currentAdapterCreatesListenKey),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("exposesExecutionVenueConnection", exposesExecutionVenueConnection),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}
