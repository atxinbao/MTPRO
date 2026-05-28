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

/// LiveReadOnlyAdapterCapabilityMatrixEntry 固定 MTP-128 的 adapter capability matrix 行。
///
/// `publicMarketDataAllowed` 是当前唯一可表达的 adapter capability；future private account
/// read-only 只能作为 gated 输入，其余 signed、account/listenKey、order write、broker /
/// exchange execution adapter、`LiveExecutionAdapter`、execution report、broker fill、
/// reconciliation 和真实账户能力都只能作为 forbidden evidence。
public enum LiveReadOnlyAdapterCapabilityMatrixEntry: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case publicMarketDataAllowed = "public market data allowed"
    case futurePrivateAccountReadOnlyGated = "future private account read-only gated"
    case signedEndpointForbidden = "signed endpoint forbidden"
    case orderWriteForbidden = "order write forbidden"
    case brokerActionForbidden = "broker action forbidden"
    case brokerExecutionAdapterForbidden = "broker execution adapter forbidden"
    case exchangeExecutionAdapterForbidden = "exchange execution adapter forbidden"
    case liveExecutionAdapterForbidden = "LiveExecutionAdapter forbidden"
    case accountEndpointListenKeyForbidden = "account endpoint / listenKey forbidden"
    case executionReportBrokerFillReconciliationForbidden =
        "execution report / broker fill / reconciliation forbidden"
    case realAccountPositionMarginLeverageForbidden =
        "real account / broker position / margin / leverage forbidden"
}

/// LiveReadOnlyAdapterCapabilityFutureGate 定义 MTP-128 后续 adapter 工作进入实现前的 gate。
///
/// 这些 gate 只描述 contract / validation 前置条件；当前类型不创建 broker adapter、
/// exchange execution adapter 或 private account runtime。
public enum LiveReadOnlyAdapterCapabilityFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case credentialEndpointTaxonomySatisfied = "credential / endpoint taxonomy satisfied"
    case publicReadOnlyAdapterStaysReadOnly = "public read-only adapter stays read-only"
    case futurePrivateReadOnlyContract = "future private read-only contract"
    case adapterImplementationIndependentProject = "adapter implementation independent Project"
    case orderWriteForbiddenValidation = "order write forbidden validation"
    case brokerExecutionAdapterFutureGate = "broker / exchange execution adapter future gate"
}

/// LiveReadOnlyAdapterCapabilityEvidenceKind 限定 MTP-128 可以产生的非执行证据。
///
/// Evidence 只用于合同、shared language、validation matrix、automation readiness、
/// deterministic tests 和 PR boundary evidence；它不实例化 adapter 或连接外部系统。
public enum LiveReadOnlyAdapterCapabilityEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case domainContextTerms = "domain context terms"
    case validationMatrixAnchor = "validation matrix anchor"
    case automationReadinessAnchor = "automation readiness anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveReadOnlyAccountPositionBalanceFutureGate 固定 MTP-129 的 L3.1 输入门槛。
///
/// 这些 gate 只描述未来 account / position / balance read-model-only 工作进入规划前必须补齐的
/// source identity、snapshot freshness、evidence identity 和 ViewModel boundary；当前 Core 不实现
/// 真实账户读取、broker position 同步、margin / leverage / real PnL runtime 或任何 private endpoint。
public enum LiveReadOnlyAccountPositionBalanceFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case accountReadModelOnlyContract = "account read-model-only contract"
    case positionReadModelOnlyContract = "position read-model-only contract"
    case balanceReadModelOnlyContract = "balance read-model-only contract"
    case sourceIdentityRequired = "source identity required"
    case snapshotFreshnessRequired = "snapshot freshness required"
    case evidenceIdentityRequired = "evidence identity required"
    case workbenchDashboardViewModelBoundary = "Workbench / Dashboard ViewModel boundary"
    case paperSimulatedFixtureIsolation = "paper / simulated / fixture evidence isolation"
}

/// LiveReadOnlyAccountPositionBalanceSourceIdentity 定义 MTP-129 未来只读 evidence 的来源身份。
///
/// 当前值只作为合同和测试证据出现；`fixtureSourceIdentityIsolation` 明确 paper / simulated / fixture
/// 证据不能伪装成真实 account、broker position、balance、margin、leverage 或 PnL payload。
public enum LiveReadOnlyAccountPositionBalanceSourceIdentity: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case futureAccountSourceIdentity = "future account source identity"
    case futurePositionSourceIdentity = "future position source identity"
    case futureBalanceSourceIdentity = "future balance source identity"
    case fixtureSourceIdentityIsolation = "fixture source identity isolation"
}

/// LiveReadOnlyAccountPositionBalanceFreshnessBoundary 固定 MTP-129 的 freshness 语义。
///
/// 这些值只要求后续 L3.1 规划必须声明 snapshot 时间、水位线和 stale 状态；当前不创建
/// account snapshot runtime，不连接 private stream，也不从 broker 或 exchange 同步任何账户状态。
public enum LiveReadOnlyAccountPositionBalanceFreshnessBoundary: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case snapshotObservedAtRequired = "snapshot observedAt required"
    case sourceWatermarkRequired = "source watermark required"
    case staleBoundaryRequired = "stale boundary required"
}

/// LiveReadOnlyAccountPositionBalanceEvidenceKind 限定 MTP-129 可以产生的非执行证据。
///
/// Evidence 只用于合同、shared language、validation matrix、automation readiness、focused tests
/// 和 PR boundary evidence；它不创建 read model runtime、ViewModel runtime 或真实账户数据流。
public enum LiveReadOnlyAccountPositionBalanceEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case domainContextTerms = "domain context terms"
    case validationMatrixAnchor = "validation matrix anchor"
    case automationReadinessAnchor = "automation readiness anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case l31HandoffMaterial = "L3.1 handoff material"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveReadOnlyAccountPositionBalanceForbiddenInterpretation 列出 MTP-129 必须拒绝的证据误读。
///
/// 这些值防止 paper portfolio、simulated fill、fixture snapshot 或 report evidence 被解释为真实
/// account / position / balance data；它们只能作为 forbidden tests 和 future-gated handoff 证据。
public enum LiveReadOnlyAccountPositionBalanceForbiddenInterpretation: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case paperPortfolioAsRealAccount = "paper portfolio as real account"
    case simulatedFillAsBrokerPosition = "simulated fill as broker position"
    case fixtureEvidenceAsRealBalance = "fixture evidence as real balance"
    case reportReadModelAsBrokerAccount = "report read model as broker account"
    case dashboardViewModelAsLiveAccountRuntime = "Dashboard ViewModel as live account runtime"
}

/// LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial 固定 MTP-130 的 L3.2 输入材料。
///
/// 这些材料只描述后续 private stream / account snapshot simulation gate 需要的字段、身份、
/// freshness 和 event shape；当前 Core 不创建 listenKey、不打开 private WebSocket、不运行
/// account snapshot runtime，也不把 fixture 或 simulation evidence 解释为真实账户数据流。
public enum LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case privateStreamSourceIdentity = "private stream source identity"
    case accountSnapshotFixtureIdentity = "account snapshot fixture identity"
    case snapshotObservedAt = "snapshot observedAt"
    case sourceWatermark = "source watermark"
    case freshnessBoundary = "freshness boundary"
    case accountEventShape = "account event shape"
    case positionEventShape = "position event shape"
    case balanceEventShape = "balance event shape"
    case fixtureReplayCursor = "fixture replay cursor"
    case simulationGateBoundary = "simulation gate boundary"
}

/// LiveReadOnlyPrivateStreamAccountSnapshotFutureFixtureRequirement 定义 MTP-130 的 future fixture 门槛。
///
/// Requirement 只为后续 L3.2 独立 Project 提供测试输入说明；它不实现 private stream runtime、
/// 不连接账户 endpoint / listenKey，也不要求本地验证依赖外部网络或真实 Binance 账户。
public enum LiveReadOnlyPrivateStreamAccountSnapshotFutureFixtureRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case deterministicAccountSnapshotFixture = "deterministic account snapshot fixture"
    case privateStreamEventFixture = "private stream event fixture"
    case fixtureSourceIdentityDeclared = "fixture source identity declared"
    case fixtureFreshnessDeclared = "fixture freshness declared"
    case replayCursorDeclared = "replay cursor declared"
    case liveStreamImplementationSeparated = "live stream implementation separated"
    case listenKeyForbiddenValidation = "listenKey forbidden validation"
    case networkIndependentValidation = "network independent validation"
}

/// LiveReadOnlyPrivateStreamAccountSnapshotForbiddenCapability 列出 MTP-130 必须拒绝的能力。
///
/// 这些能力只能作为 forbidden capability tests 和 L3.2 handoff evidence 出现；任何 init 或
/// Codable 解码都不能把它们恢复成 listenKey、private WebSocket、account snapshot runtime、
/// signed/account endpoint、broker adapter、真实订单或 UI command surface。
public enum LiveReadOnlyPrivateStreamAccountSnapshotForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case listenKeyCreation = "listenKey creation"
    case listenKeyKeepalive = "listenKey keepalive"
    case privateWebSocketRuntime = "private WebSocket runtime"
    case accountSnapshotRuntime = "account snapshot runtime"
    case signedEndpointCall = "signed endpoint call"
    case accountEndpointCall = "account endpoint call"
    case realAccountRead = "real account read"
    case realAccountPayloadConsumption = "real account payload consumption"
    case brokerPositionSync = "broker position sync"
    case marginLeverageRead = "margin / leverage read"
    case brokerAdapterConnection = "broker adapter connection"
    case liveExecutionAdapterImplementation = "LiveExecutionAdapter implementation"
    case omsImplementation = "OMS implementation"
    case realOrderWrite = "real order write"
    case simulationGateAsLiveStreamImplementation = "simulation gate as live stream implementation"
    case fixtureSnapshotAsRealAccountSnapshot = "fixture snapshot as real account snapshot"
    case tradingButton = "trading button"
    case liveCommand = "live command"
}

/// LiveReadOnlyPrivateStreamAccountSnapshotEvidenceKind 限定 MTP-130 可以产生的非执行证据。
///
/// Evidence 只用于合同、shared language、validation matrix、automation readiness、focused tests
/// 和 PR boundary evidence；它不创建 endpoint、adapter、runtime、ViewModel 或 Dashboard 行为。
public enum LiveReadOnlyPrivateStreamAccountSnapshotEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case domainContextTerms = "domain context terms"
    case validationMatrixAnchor = "validation matrix anchor"
    case automationReadinessAnchor = "automation readiness anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case l32HandoffMaterial = "L3.2 handoff material"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveReadOnlyWorkbenchBoundarySurface 固定 MTP-131 允许 Workbench 展示的只读 surface。
///
/// 这些 surface 只能表达 Live readiness boundary evidence、detail / audit route 和后续 L3.x handoff。
/// 它们不等于 API key 表单、broker/account connect、Live PRO Console、order form 或 live command。
public enum LiveReadOnlyWorkbenchBoundarySurface: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case workbenchLiveReadinessEvidence = "Workbench Live readiness evidence"
    case dashboardLiveReadinessSummary = "Dashboard Live readiness summary"
    case reportLiveReadinessBoundaryEvidence = "Report Live readiness boundary evidence"
    case eventTimelineAuditRoute = "Event Timeline audit route"
    case detailInspectorBoundaryEvidence = "detail inspector boundary evidence"
}

/// LiveReadOnlyWorkbenchInputBoundary 固定 MTP-131 UI 可以消费的输入来源。
///
/// 输入必须是 Core deterministic fixture 或 App ReadModel / ViewModel。Workbench / Dashboard 不允许
/// 直接读取 Persistence schema、Runtime object、adapter request、secret、account payload 或 broker state。
public enum LiveReadOnlyWorkbenchInputBoundary: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case liveReadinessReadModel = "Live readiness read model"
    case credentialEndpointTaxonomyFixture = "credential / endpoint taxonomy fixture"
    case adapterCapabilityMatrixFixture = "adapter capability matrix fixture"
    case accountPositionBalanceFutureGateFixture = "account / position / balance future gate fixture"
    case privateStreamAccountSnapshotSimulationGateFixture =
        "private stream / account snapshot simulation gate fixture"
    case appReadModelProjection = "App read model projection"
    case appViewModelSnapshot = "App ViewModel snapshot"
    case dashboardShellSnapshot = "Dashboard shell snapshot"
    case evidenceExplorerTimelineRoute = "Evidence Explorer timeline route"
}

/// LiveReadOnlyWorkbenchForbiddenUISurface 列出 MTP-131 必须拒绝的 UI surface。
///
/// 这些值只能进入 forbidden tests、contract docs、validation matrix 和 PR boundary evidence，不能作为
/// Dashboard / Workbench 的可见交互能力、连接向导、命令入口或真实账户展示。
public enum LiveReadOnlyWorkbenchForbiddenUISurface: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKeyInput = "API key input"
    case secretStorage = "secret storage"
    case brokerConnect = "broker connect"
    case accountConnect = "account connect"
    case livePROConsole = "Live PRO Console"
    case tradingButton = "trading button"
    case liveCommand = "live command"
    case orderForm = "order form"
    case realAccountBalance = "real account balance"
    case brokerPosition = "broker position"
    case runtimeObject = "Runtime object"
    case databaseSchema = "database schema"
    case signedEndpoint = "signed endpoint"
    case accountEndpointListenKey = "account endpoint / listenKey"
    case brokerAdapter = "broker adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case oms = "OMS"
    case realOrderLifecycle = "real order lifecycle"
    case realSubmitCancelReplace = "real submit / cancel / replace"
}

/// LiveReadOnlyWorkbenchDetailAuditRoute 固定 MTP-131 的 detail / audit routing。
///
/// route 只用于解释证据来源和后续 handoff，不能下推为查询语言、Runtime replay command、
/// incident replay、stop control、broker operation 或 live audit runtime。
public enum LiveReadOnlyWorkbenchDetailAuditRoute: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dashboardSummaryToReportEvidence = "Dashboard summary -> Report evidence"
    case reportEvidenceToEventTimeline = "Report evidence -> Event Timeline"
    case eventTimelineToContractAnchor = "Event Timeline -> contract anchor"
    case detailInspectorToValidationAnchor = "detail inspector -> validation anchor"
}

/// LiveReadOnlyWorkbenchHandoffTarget 固定 MTP-131 对后续 L3.x 的非执行交接。
///
/// 这些 target 只说明 UI boundary 已为后续 planning 保留只读输入位置；它们不授权 L3.1、L3.2、
/// L3.3 或 L4 自动进入实现。
public enum LiveReadOnlyWorkbenchHandoffTarget: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case l31AccountPositionBalanceReadModelOnly = "L3.1 account / position / balance read-model-only"
    case l32PrivateStreamAccountSnapshotSimulationGate =
        "L3.2 private stream / account snapshot simulation gate"
    case l33LiveMonitoringReadOnlyConsoleV2 = "L3.3 Live Monitoring read-only console v2"
}

/// LiveReadOnlyWorkbenchEvidenceKind 限定 MTP-131 可以产生的 evidence。
///
/// Evidence 只用于合同、Core fixture、App ReadModel / ViewModel、Dashboard shell snapshot、Event Timeline
/// audit route、validation anchors 和 PR boundary evidence；它不创建任何 live UI command 或 broker surface。
public enum LiveReadOnlyWorkbenchEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case coreDeterministicFixture = "Core deterministic fixture"
    case appReadModel = "App ReadModel"
    case appViewModel = "App ViewModel"
    case dashboardShellSnapshot = "Dashboard shell snapshot"
    case eventTimelineAuditRoute = "Event Timeline audit route"
    case validationMatrixAnchor = "validation matrix anchor"
    case automationReadinessAnchor = "automation readiness anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case l31l32l33HandoffMaterial = "L3.1 / L3.2 / L3.3 handoff material"
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

/// LiveReadOnlyAdapterCapabilityMatrixBoundary 是 MTP-128 的 L3.0 adapter capability matrix fixture。
///
/// 该合同只把 public market data allowed、future private account read-only gated 和
/// forbidden write / broker / execution capability 固定为 deterministic evidence。当前 public
/// adapter 不能升级为 broker / exchange execution adapter，Codable 解码同样会拒绝任何
/// signed endpoint、account endpoint、listenKey、order write、execution report、broker fill、
/// reconciliation 或真实账户能力。
public struct LiveReadOnlyAdapterCapabilityMatrixBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let matrixID: String
    public let capabilityMatrix: [LiveReadOnlyAdapterCapabilityMatrixEntry]
    public let currentAllowedCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry]
    public let futureGatedCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry]
    public let forbiddenCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry]
    public let futureGates: [LiveReadOnlyAdapterCapabilityFutureGate]
    public let allowedEvidenceKinds: [LiveReadOnlyAdapterCapabilityEvidenceKind]
    public let createsBrokerAdapter: Bool
    public let createsExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let upgradesPublicReadOnlyAdapterToExecutionAdapter: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let exposesOrderWriteCapability: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let readsExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let runsReconciliation: Bool
    public let readsRealAccountPositionMarginLeverage: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var adapterCapabilityMatrixBoundaryHeld: Bool {
        matrixID == Self.requiredMatrixID
            && capabilityMatrix == Self.requiredCapabilityMatrix
            && currentAllowedCapabilities == Self.requiredCurrentAllowedCapabilities
            && futureGatedCapabilities == Self.requiredFutureGatedCapabilities
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && futureGates == Self.requiredFutureGates
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && createsBrokerAdapter == false
            && createsExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && upgradesPublicReadOnlyAdapterToExecutionAdapter == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && exposesOrderWriteCapability == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && readsExecutionReport == false
            && recordsBrokerFill == false
            && runsReconciliation == false
            && readsRealAccountPositionMarginLeverage == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-128-live-read-only-adapter-capability-matrix"),
        issueID: Identifier = try! Identifier("MTP-128"),
        matrixID: String = Self.requiredMatrixID,
        capabilityMatrix: [LiveReadOnlyAdapterCapabilityMatrixEntry] = Self.requiredCapabilityMatrix,
        currentAllowedCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry] =
            Self.requiredCurrentAllowedCapabilities,
        futureGatedCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry] =
            Self.requiredFutureGatedCapabilities,
        forbiddenCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry] = Self.requiredForbiddenCapabilities,
        futureGates: [LiveReadOnlyAdapterCapabilityFutureGate] = Self.requiredFutureGates,
        allowedEvidenceKinds: [LiveReadOnlyAdapterCapabilityEvidenceKind] = Self.allowedEvidenceKinds,
        createsBrokerAdapter: Bool = false,
        createsExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        upgradesPublicReadOnlyAdapterToExecutionAdapter: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        exposesOrderWriteCapability: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        readsExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        runsReconciliation: Bool = false,
        readsRealAccountPositionMarginLeverage: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            matrixID: matrixID,
            capabilityMatrix: capabilityMatrix,
            currentAllowedCapabilities: currentAllowedCapabilities,
            futureGatedCapabilities: futureGatedCapabilities,
            forbiddenCapabilities: forbiddenCapabilities,
            futureGates: futureGates,
            allowedEvidenceKinds: allowedEvidenceKinds
        )
        try Self.validateForbiddenFlags(
            createsBrokerAdapter: createsBrokerAdapter,
            createsExchangeExecutionAdapter: createsExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            upgradesPublicReadOnlyAdapterToExecutionAdapter: upgradesPublicReadOnlyAdapterToExecutionAdapter,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            exposesOrderWriteCapability: exposesOrderWriteCapability,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            readsExecutionReport: readsExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            runsReconciliation: runsReconciliation,
            readsRealAccountPositionMarginLeverage: readsRealAccountPositionMarginLeverage,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.matrixID = matrixID
        self.capabilityMatrix = capabilityMatrix
        self.currentAllowedCapabilities = currentAllowedCapabilities
        self.futureGatedCapabilities = futureGatedCapabilities
        self.forbiddenCapabilities = forbiddenCapabilities
        self.futureGates = futureGates
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.createsBrokerAdapter = createsBrokerAdapter
        self.createsExchangeExecutionAdapter = createsExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.upgradesPublicReadOnlyAdapterToExecutionAdapter = upgradesPublicReadOnlyAdapterToExecutionAdapter
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.exposesOrderWriteCapability = exposesOrderWriteCapability
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.readsExecutionReport = readsExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.runsReconciliation = runsReconciliation
        self.readsRealAccountPositionMarginLeverage = readsRealAccountPositionMarginLeverage
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            matrixID: try container.decode(String.self, forKey: .matrixID),
            capabilityMatrix: try container.decode(
                [LiveReadOnlyAdapterCapabilityMatrixEntry].self,
                forKey: .capabilityMatrix
            ),
            currentAllowedCapabilities: try container.decode(
                [LiveReadOnlyAdapterCapabilityMatrixEntry].self,
                forKey: .currentAllowedCapabilities
            ),
            futureGatedCapabilities: try container.decode(
                [LiveReadOnlyAdapterCapabilityMatrixEntry].self,
                forKey: .futureGatedCapabilities
            ),
            forbiddenCapabilities: try container.decode(
                [LiveReadOnlyAdapterCapabilityMatrixEntry].self,
                forKey: .forbiddenCapabilities
            ),
            futureGates: try container.decode([LiveReadOnlyAdapterCapabilityFutureGate].self, forKey: .futureGates),
            allowedEvidenceKinds: try container.decode(
                [LiveReadOnlyAdapterCapabilityEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            createsBrokerAdapter: try container.decode(Bool.self, forKey: .createsBrokerAdapter),
            createsExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .createsExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            upgradesPublicReadOnlyAdapterToExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .upgradesPublicReadOnlyAdapterToExecutionAdapter
            ),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            exposesOrderWriteCapability: try container.decode(Bool.self, forKey: .exposesOrderWriteCapability),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            readsExecutionReport: try container.decode(Bool.self, forKey: .readsExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            runsReconciliation: try container.decode(Bool.self, forKey: .runsReconciliation),
            readsRealAccountPositionMarginLeverage: try container.decode(
                Bool.self,
                forKey: .readsRealAccountPositionMarginLeverage
            ),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredMatrixID = "TVM-LIVE-READ-ONLY-READINESS"
    public static let requiredCapabilityMatrix = LiveReadOnlyAdapterCapabilityMatrixEntry.allCases

    public static let requiredCurrentAllowedCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry] = [
        .publicMarketDataAllowed
    ]

    public static let requiredFutureGatedCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry] = [
        .futurePrivateAccountReadOnlyGated
    ]

    public static let requiredForbiddenCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry] = [
        .signedEndpointForbidden,
        .orderWriteForbidden,
        .brokerActionForbidden,
        .brokerExecutionAdapterForbidden,
        .exchangeExecutionAdapterForbidden,
        .liveExecutionAdapterForbidden,
        .accountEndpointListenKeyForbidden,
        .executionReportBrokerFillReconciliationForbidden,
        .realAccountPositionMarginLeverageForbidden
    ]

    public static let requiredFutureGates: [LiveReadOnlyAdapterCapabilityFutureGate] = [
        .credentialEndpointTaxonomySatisfied,
        .publicReadOnlyAdapterStaysReadOnly,
        .futurePrivateReadOnlyContract,
        .adapterImplementationIndependentProject,
        .orderWriteForbiddenValidation,
        .brokerExecutionAdapterFutureGate
    ]

    public static let allowedEvidenceKinds: [LiveReadOnlyAdapterCapabilityEvidenceKind] = [
        .contractDocumentation,
        .domainContextTerms,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicForbiddenTest,
        .prBoundaryEvidence
    ]

    public static let deterministicFixture: LiveReadOnlyAdapterCapabilityMatrixBoundary = {
        do {
            return try LiveReadOnlyAdapterCapabilityMatrixBoundary()
        } catch {
            preconditionFailure("MTP-128 Live read-only adapter capability matrix fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        matrixID: String,
        capabilityMatrix: [LiveReadOnlyAdapterCapabilityMatrixEntry],
        currentAllowedCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry],
        futureGatedCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry],
        forbiddenCapabilities: [LiveReadOnlyAdapterCapabilityMatrixEntry],
        futureGates: [LiveReadOnlyAdapterCapabilityFutureGate],
        allowedEvidenceKinds: [LiveReadOnlyAdapterCapabilityEvidenceKind]
    ) throws {
        guard matrixID == Self.requiredMatrixID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "matrixID",
                expected: Self.requiredMatrixID,
                actual: matrixID
            )
        }
        guard capabilityMatrix == Self.requiredCapabilityMatrix else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "capabilityMatrix",
                expected: Self.requiredCapabilityMatrix.map(\.rawValue).joined(separator: ","),
                actual: capabilityMatrix.map(\.rawValue).joined(separator: ",")
            )
        }
        guard currentAllowedCapabilities == Self.requiredCurrentAllowedCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "currentAllowedCapabilities",
                expected: Self.requiredCurrentAllowedCapabilities.map(\.rawValue).joined(separator: ","),
                actual: currentAllowedCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGatedCapabilities == Self.requiredFutureGatedCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGatedCapabilities",
                expected: Self.requiredFutureGatedCapabilities.map(\.rawValue).joined(separator: ","),
                actual: futureGatedCapabilities.map(\.rawValue).joined(separator: ",")
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
        createsBrokerAdapter: Bool,
        createsExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        upgradesPublicReadOnlyAdapterToExecutionAdapter: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        exposesOrderWriteCapability: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        readsExecutionReport: Bool,
        recordsBrokerFill: Bool,
        runsReconciliation: Bool,
        readsRealAccountPositionMarginLeverage: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        let forbiddenFlags = [
            ("createsBrokerAdapter", createsBrokerAdapter),
            ("createsExchangeExecutionAdapter", createsExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            (
                "upgradesPublicReadOnlyAdapterToExecutionAdapter",
                upgradesPublicReadOnlyAdapterToExecutionAdapter
            ),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("exposesOrderWriteCapability", exposesOrderWriteCapability),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("readsExecutionReport", readsExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("runsReconciliation", runsReconciliation),
            ("readsRealAccountPositionMarginLeverage", readsRealAccountPositionMarginLeverage),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveReadOnlyAccountPositionBalanceFutureGateBoundary 是 MTP-129 的 L3.1 read-model-only future gate fixture。
///
/// 该合同只定义 account / position / balance 未来只读模型进入后续 Project 前需要的 source
/// identity、snapshot freshness、evidence identity 和 Workbench / Dashboard ViewModel 边界。
/// 它不实现 account read model runtime，不读取真实账户，不同步 broker position，不读取 margin /
/// leverage / real PnL，不调用 signed 或 account endpoint，也不允许 paper / simulated / fixture
/// evidence 被反序列化成真实账户数据。
public struct LiveReadOnlyAccountPositionBalanceFutureGateBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let matrixID: String
    public let futureGates: [LiveReadOnlyAccountPositionBalanceFutureGate]
    public let sourceIdentityBoundaries: [LiveReadOnlyAccountPositionBalanceSourceIdentity]
    public let freshnessBoundaries: [LiveReadOnlyAccountPositionBalanceFreshnessBoundary]
    public let forbiddenInterpretations: [LiveReadOnlyAccountPositionBalanceForbiddenInterpretation]
    public let allowedEvidenceKinds: [LiveReadOnlyAccountPositionBalanceEvidenceKind]
    public let implementsAccountReadModelRuntime: Bool
    public let implementsPositionReadModelRuntime: Bool
    public let implementsBalanceReadModelRuntime: Bool
    public let readsRealAccount: Bool
    public let syncsBrokerPosition: Bool
    public let readsRealAccountBalance: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let readsRealPnL: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBrokerAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let representsPaperEvidenceAsRealAccountData: Bool
    public let representsSimulatedFillAsBrokerPosition: Bool
    public let representsFixtureEvidenceAsRealAccountSnapshot: Bool
    public let exposesTradingButton: Bool
    public let exposesLiveCommand: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var accountPositionBalanceFutureGateBoundaryHeld: Bool {
        matrixID == Self.requiredMatrixID
            && futureGates == Self.requiredFutureGates
            && sourceIdentityBoundaries == Self.requiredSourceIdentityBoundaries
            && freshnessBoundaries == Self.requiredFreshnessBoundaries
            && forbiddenInterpretations == Self.requiredForbiddenInterpretations
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && implementsAccountReadModelRuntime == false
            && implementsPositionReadModelRuntime == false
            && implementsBalanceReadModelRuntime == false
            && readsRealAccount == false
            && syncsBrokerPosition == false
            && readsRealAccountBalance == false
            && readsMargin == false
            && readsLeverage == false
            && readsRealPnL == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBrokerAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && representsPaperEvidenceAsRealAccountData == false
            && representsSimulatedFillAsBrokerPosition == false
            && representsFixtureEvidenceAsRealAccountSnapshot == false
            && exposesTradingButton == false
            && exposesLiveCommand == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-129-live-read-only-account-position-balance-future-gates"),
        issueID: Identifier = try! Identifier("MTP-129"),
        matrixID: String = Self.requiredMatrixID,
        futureGates: [LiveReadOnlyAccountPositionBalanceFutureGate] = Self.requiredFutureGates,
        sourceIdentityBoundaries: [LiveReadOnlyAccountPositionBalanceSourceIdentity] =
            Self.requiredSourceIdentityBoundaries,
        freshnessBoundaries: [LiveReadOnlyAccountPositionBalanceFreshnessBoundary] =
            Self.requiredFreshnessBoundaries,
        forbiddenInterpretations: [LiveReadOnlyAccountPositionBalanceForbiddenInterpretation] =
            Self.requiredForbiddenInterpretations,
        allowedEvidenceKinds: [LiveReadOnlyAccountPositionBalanceEvidenceKind] = Self.allowedEvidenceKinds,
        implementsAccountReadModelRuntime: Bool = false,
        implementsPositionReadModelRuntime: Bool = false,
        implementsBalanceReadModelRuntime: Bool = false,
        readsRealAccount: Bool = false,
        syncsBrokerPosition: Bool = false,
        readsRealAccountBalance: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        readsRealPnL: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBrokerAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        representsPaperEvidenceAsRealAccountData: Bool = false,
        representsSimulatedFillAsBrokerPosition: Bool = false,
        representsFixtureEvidenceAsRealAccountSnapshot: Bool = false,
        exposesTradingButton: Bool = false,
        exposesLiveCommand: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            matrixID: matrixID,
            futureGates: futureGates,
            sourceIdentityBoundaries: sourceIdentityBoundaries,
            freshnessBoundaries: freshnessBoundaries,
            forbiddenInterpretations: forbiddenInterpretations,
            allowedEvidenceKinds: allowedEvidenceKinds
        )
        try Self.validateForbiddenFlags(
            implementsAccountReadModelRuntime: implementsAccountReadModelRuntime,
            implementsPositionReadModelRuntime: implementsPositionReadModelRuntime,
            implementsBalanceReadModelRuntime: implementsBalanceReadModelRuntime,
            readsRealAccount: readsRealAccount,
            syncsBrokerPosition: syncsBrokerPosition,
            readsRealAccountBalance: readsRealAccountBalance,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            readsRealPnL: readsRealPnL,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBrokerAdapter: connectsBrokerAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            representsPaperEvidenceAsRealAccountData: representsPaperEvidenceAsRealAccountData,
            representsSimulatedFillAsBrokerPosition: representsSimulatedFillAsBrokerPosition,
            representsFixtureEvidenceAsRealAccountSnapshot: representsFixtureEvidenceAsRealAccountSnapshot,
            exposesTradingButton: exposesTradingButton,
            exposesLiveCommand: exposesLiveCommand,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.matrixID = matrixID
        self.futureGates = futureGates
        self.sourceIdentityBoundaries = sourceIdentityBoundaries
        self.freshnessBoundaries = freshnessBoundaries
        self.forbiddenInterpretations = forbiddenInterpretations
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.implementsAccountReadModelRuntime = implementsAccountReadModelRuntime
        self.implementsPositionReadModelRuntime = implementsPositionReadModelRuntime
        self.implementsBalanceReadModelRuntime = implementsBalanceReadModelRuntime
        self.readsRealAccount = readsRealAccount
        self.syncsBrokerPosition = syncsBrokerPosition
        self.readsRealAccountBalance = readsRealAccountBalance
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.readsRealPnL = readsRealPnL
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBrokerAdapter = connectsBrokerAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.representsPaperEvidenceAsRealAccountData = representsPaperEvidenceAsRealAccountData
        self.representsSimulatedFillAsBrokerPosition = representsSimulatedFillAsBrokerPosition
        self.representsFixtureEvidenceAsRealAccountSnapshot = representsFixtureEvidenceAsRealAccountSnapshot
        self.exposesTradingButton = exposesTradingButton
        self.exposesLiveCommand = exposesLiveCommand
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            matrixID: try container.decode(String.self, forKey: .matrixID),
            futureGates: try container.decode(
                [LiveReadOnlyAccountPositionBalanceFutureGate].self,
                forKey: .futureGates
            ),
            sourceIdentityBoundaries: try container.decode(
                [LiveReadOnlyAccountPositionBalanceSourceIdentity].self,
                forKey: .sourceIdentityBoundaries
            ),
            freshnessBoundaries: try container.decode(
                [LiveReadOnlyAccountPositionBalanceFreshnessBoundary].self,
                forKey: .freshnessBoundaries
            ),
            forbiddenInterpretations: try container.decode(
                [LiveReadOnlyAccountPositionBalanceForbiddenInterpretation].self,
                forKey: .forbiddenInterpretations
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveReadOnlyAccountPositionBalanceEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            implementsAccountReadModelRuntime: try container.decode(
                Bool.self,
                forKey: .implementsAccountReadModelRuntime
            ),
            implementsPositionReadModelRuntime: try container.decode(
                Bool.self,
                forKey: .implementsPositionReadModelRuntime
            ),
            implementsBalanceReadModelRuntime: try container.decode(
                Bool.self,
                forKey: .implementsBalanceReadModelRuntime
            ),
            readsRealAccount: try container.decode(Bool.self, forKey: .readsRealAccount),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            readsRealPnL: try container.decode(Bool.self, forKey: .readsRealPnL),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBrokerAdapter: try container.decode(Bool.self, forKey: .connectsBrokerAdapter),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            representsPaperEvidenceAsRealAccountData: try container.decode(
                Bool.self,
                forKey: .representsPaperEvidenceAsRealAccountData
            ),
            representsSimulatedFillAsBrokerPosition: try container.decode(
                Bool.self,
                forKey: .representsSimulatedFillAsBrokerPosition
            ),
            representsFixtureEvidenceAsRealAccountSnapshot: try container.decode(
                Bool.self,
                forKey: .representsFixtureEvidenceAsRealAccountSnapshot
            ),
            exposesTradingButton: try container.decode(Bool.self, forKey: .exposesTradingButton),
            exposesLiveCommand: try container.decode(Bool.self, forKey: .exposesLiveCommand),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredMatrixID = "TVM-LIVE-READ-ONLY-READINESS"
    public static let requiredFutureGates = LiveReadOnlyAccountPositionBalanceFutureGate.allCases
    public static let requiredSourceIdentityBoundaries =
        LiveReadOnlyAccountPositionBalanceSourceIdentity.allCases
    public static let requiredFreshnessBoundaries =
        LiveReadOnlyAccountPositionBalanceFreshnessBoundary.allCases
    public static let requiredForbiddenInterpretations =
        LiveReadOnlyAccountPositionBalanceForbiddenInterpretation.allCases

    public static let allowedEvidenceKinds: [LiveReadOnlyAccountPositionBalanceEvidenceKind] = [
        .contractDocumentation,
        .domainContextTerms,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicForbiddenTest,
        .l31HandoffMaterial,
        .prBoundaryEvidence
    ]

    public static let deterministicFixture: LiveReadOnlyAccountPositionBalanceFutureGateBoundary = {
        do {
            return try LiveReadOnlyAccountPositionBalanceFutureGateBoundary()
        } catch {
            preconditionFailure(
                "MTP-129 Live read-only account / position / balance future gate fixture must be valid: \(error)"
            )
        }
    }()

    private static func validate(
        matrixID: String,
        futureGates: [LiveReadOnlyAccountPositionBalanceFutureGate],
        sourceIdentityBoundaries: [LiveReadOnlyAccountPositionBalanceSourceIdentity],
        freshnessBoundaries: [LiveReadOnlyAccountPositionBalanceFreshnessBoundary],
        forbiddenInterpretations: [LiveReadOnlyAccountPositionBalanceForbiddenInterpretation],
        allowedEvidenceKinds: [LiveReadOnlyAccountPositionBalanceEvidenceKind]
    ) throws {
        guard matrixID == Self.requiredMatrixID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "matrixID",
                expected: Self.requiredMatrixID,
                actual: matrixID
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard sourceIdentityBoundaries == Self.requiredSourceIdentityBoundaries else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIdentityBoundaries",
                expected: Self.requiredSourceIdentityBoundaries.map(\.rawValue).joined(separator: ","),
                actual: sourceIdentityBoundaries.map(\.rawValue).joined(separator: ",")
            )
        }
        guard freshnessBoundaries == Self.requiredFreshnessBoundaries else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "freshnessBoundaries",
                expected: Self.requiredFreshnessBoundaries.map(\.rawValue).joined(separator: ","),
                actual: freshnessBoundaries.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenInterpretations == Self.requiredForbiddenInterpretations else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenInterpretations",
                expected: Self.requiredForbiddenInterpretations.map(\.rawValue).joined(separator: ","),
                actual: forbiddenInterpretations.map(\.rawValue).joined(separator: ",")
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
        implementsAccountReadModelRuntime: Bool,
        implementsPositionReadModelRuntime: Bool,
        implementsBalanceReadModelRuntime: Bool,
        readsRealAccount: Bool,
        syncsBrokerPosition: Bool,
        readsRealAccountBalance: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        readsRealPnL: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBrokerAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        representsPaperEvidenceAsRealAccountData: Bool,
        representsSimulatedFillAsBrokerPosition: Bool,
        representsFixtureEvidenceAsRealAccountSnapshot: Bool,
        exposesTradingButton: Bool,
        exposesLiveCommand: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        let forbiddenFlags = [
            ("implementsAccountReadModelRuntime", implementsAccountReadModelRuntime),
            ("implementsPositionReadModelRuntime", implementsPositionReadModelRuntime),
            ("implementsBalanceReadModelRuntime", implementsBalanceReadModelRuntime),
            ("readsRealAccount", readsRealAccount),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("readsRealAccountBalance", readsRealAccountBalance),
            ("readsMargin", readsMargin),
            ("readsLeverage", readsLeverage),
            ("readsRealPnL", readsRealPnL),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBrokerAdapter", connectsBrokerAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("representsPaperEvidenceAsRealAccountData", representsPaperEvidenceAsRealAccountData),
            ("representsSimulatedFillAsBrokerPosition", representsSimulatedFillAsBrokerPosition),
            ("representsFixtureEvidenceAsRealAccountSnapshot", representsFixtureEvidenceAsRealAccountSnapshot),
            ("exposesTradingButton", exposesTradingButton),
            ("exposesLiveCommand", exposesLiveCommand),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// AccountPositionBalanceReadModelOnlyFixtureComponent 固定 MTP-137 fixture 的三类记录。
///
/// 每个 component 都只能表示本地 deterministic read-model-only evidence，不映射到真实
/// account payload、broker position、margin balance、runtime object 或 adapter response。
public enum AccountPositionBalanceReadModelOnlyFixtureComponent: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case accountSnapshot = "account snapshot"
    case positionSnapshot = "position snapshot"
    case balanceSnapshot = "balance snapshot"
}

/// AccountPositionBalanceReadModelOnlyForbiddenCapability 列出 MTP-137 fixture tests 必须拒绝的能力。
///
/// 这些值只作为 deterministic forbidden test evidence 出现。它们不能被解释为 signed endpoint、
/// account endpoint、listenKey、broker adapter、真实账户读取或真实 PnL / margin / leverage 支持。
public enum AccountPositionBalanceReadModelOnlyForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKey = "listenKey"
    case privateWebSocket = "private WebSocket"
    case secretRead = "secret read"
    case brokerAdapter = "broker adapter"
    case realAccountRead = "real account read"
    case realAccountPayload = "real account payload"
    case brokerPayloadImport = "broker payload import"
    case brokerPositionSync = "broker position sync"
    case realPnLRuntime = "real PnL runtime"
    case marginRead = "margin read"
    case leverageRead = "leverage read"
    case accountSnapshotRuntime = "account snapshot runtime"
    case payloadSchemaRuntimeObjectExposure = "payload / schema / runtime object exposure"
}

/// AccountPositionBalanceReadModelOnlyFixtureRecord 是 MTP-137 的单条 fixture shape。
///
/// Record 只保存 snapshot identity、evidence identity、source / freshness identity 和允许映射到
/// Read Model 的字段名。它故意不保存真实 payload、schema、runtime object、broker state 或 endpoint
/// descriptor，避免 fixture 被误用为真实账户导入器。
public struct AccountPositionBalanceReadModelOnlyFixtureRecord: Codable, Equatable, Sendable {
    public let component: AccountPositionBalanceReadModelOnlyFixtureComponent
    public let snapshotID: String
    public let evidenceID: String
    public let sourceIdentity: String
    public let observedAt: Int
    public let sourceWatermark: String
    public let freshnessStatus: ScenarioReplayFreshnessStatus
    public let readModelFields: [String]

    public var canonicalLine: String {
        [
            component.rawValue,
            snapshotID,
            evidenceID,
            sourceIdentity,
            String(observedAt),
            sourceWatermark,
            freshnessStatus.rawValue,
            readModelFields.joined(separator: "+")
        ].joined(separator: "|")
    }

    public var readModelMappingIsolated: Bool {
        sourceIdentity == Self.requiredSourceIdentity
            && freshnessStatus == .fresh
            && containsForbiddenPayloadText(Self.forbiddenReadModelFieldTokens) == false
    }

    public init(
        component: AccountPositionBalanceReadModelOnlyFixtureComponent,
        snapshotID: String,
        evidenceID: String,
        sourceIdentity: String = Self.requiredSourceIdentity,
        observedAt: Int = Self.requiredObservedAt,
        sourceWatermark: String = Self.requiredSourceWatermark,
        freshnessStatus: ScenarioReplayFreshnessStatus = .fresh,
        readModelFields: [String]
    ) throws {
        try Self.validate(
            component: component,
            snapshotID: snapshotID,
            evidenceID: evidenceID,
            sourceIdentity: sourceIdentity,
            observedAt: observedAt,
            sourceWatermark: sourceWatermark,
            freshnessStatus: freshnessStatus,
            readModelFields: readModelFields
        )

        self.component = component
        self.snapshotID = snapshotID
        self.evidenceID = evidenceID
        self.sourceIdentity = sourceIdentity
        self.observedAt = observedAt
        self.sourceWatermark = sourceWatermark
        self.freshnessStatus = freshnessStatus
        self.readModelFields = readModelFields
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            component: try container.decode(
                AccountPositionBalanceReadModelOnlyFixtureComponent.self,
                forKey: .component
            ),
            snapshotID: try container.decode(String.self, forKey: .snapshotID),
            evidenceID: try container.decode(String.self, forKey: .evidenceID),
            sourceIdentity: try container.decode(String.self, forKey: .sourceIdentity),
            observedAt: try container.decode(Int.self, forKey: .observedAt),
            sourceWatermark: try container.decode(String.self, forKey: .sourceWatermark),
            freshnessStatus: try container.decode(ScenarioReplayFreshnessStatus.self, forKey: .freshnessStatus),
            readModelFields: try container.decode([String].self, forKey: .readModelFields)
        )
    }

    public func containsForbiddenPayloadText(_ forbiddenTokens: [String]) -> Bool {
        let searchable = [
            snapshotID,
            evidenceID,
            sourceIdentity,
            sourceWatermark,
            readModelFields.joined(separator: "|")
        ]
            .joined(separator: "|")
            .lowercased()

        return forbiddenTokens.contains { token in
            searchable.contains(token.lowercased())
        }
    }

    public static let requiredSourceIdentity = "fixture:mtp-137-account-position-balance-read-model-only"
    public static let requiredObservedAt = 1_704_067_500
    public static let requiredSourceWatermark = "fixture-watermark:mtp-137:2024-01-01T00:05:00Z"
    public static let forbiddenReadModelFieldTokens = [
        "payload",
        "schema",
        "runtime",
        "endpoint",
        "listenkey",
        "secret",
        "broker",
        "margin",
        "leverage",
        "realpnl",
        "real-pnl",
        "real_pnl"
    ]

    private static func validate(
        component: AccountPositionBalanceReadModelOnlyFixtureComponent,
        snapshotID: String,
        evidenceID: String,
        sourceIdentity: String,
        observedAt: Int,
        sourceWatermark: String,
        freshnessStatus: ScenarioReplayFreshnessStatus,
        readModelFields: [String]
    ) throws {
        guard snapshotID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "\(component.rawValue).snapshotID",
                expected: "non-empty snapshot identity",
                actual: "empty"
            )
        }
        guard evidenceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "\(component.rawValue).evidenceID",
                expected: "non-empty evidence identity",
                actual: "empty"
            )
        }
        guard sourceIdentity == Self.requiredSourceIdentity else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "\(component.rawValue).sourceIdentity",
                expected: Self.requiredSourceIdentity,
                actual: sourceIdentity
            )
        }
        guard observedAt == Self.requiredObservedAt else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "\(component.rawValue).observedAt",
                expected: String(Self.requiredObservedAt),
                actual: String(observedAt)
            )
        }
        guard sourceWatermark == Self.requiredSourceWatermark else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "\(component.rawValue).sourceWatermark",
                expected: Self.requiredSourceWatermark,
                actual: sourceWatermark
            )
        }
        guard freshnessStatus == .fresh else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "\(component.rawValue).freshnessStatus",
                expected: ScenarioReplayFreshnessStatus.fresh.rawValue,
                actual: freshnessStatus.rawValue
            )
        }
        guard readModelFields.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "\(component.rawValue).readModelFields",
                expected: "non-empty read model field list",
                actual: "empty"
            )
        }
        if let forbiddenField = readModelFields.first(where: { field in
            Self.forbiddenReadModelFieldTokens.contains { token in
                field.lowercased().contains(token.lowercased())
            }
        }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readModelFields.\(forbiddenField)")
        }
    }
}

/// AccountPositionBalanceReadModelOnlyFixtureContract 是 MTP-137 的 deterministic fixture 合同。
///
/// 该合同把 account / position / balance 的 fixture shape、fixture version、checksum、freshness
/// 和 source identity 固定为本地证据，并用 init / Codable validation 拒绝真实 endpoint、
/// secret、listenKey、broker adapter、real account payload、real PnL、margin、leverage 以及
/// payload / schema / runtime object 暴露。它不是 account snapshot runtime，也不是 broker payload importer。
public struct AccountPositionBalanceReadModelOnlyFixtureContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let fixtureVersion: FixtureVersion
    public let records: [AccountPositionBalanceReadModelOnlyFixtureRecord]
    public let checksum: String
    public let checksumMatchedCanonicalPreimage: Bool
    public let freshnessStatus: ScenarioReplayFreshnessStatus
    public let forbiddenCapabilities: [AccountPositionBalanceReadModelOnlyForbiddenCapability]
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let opensPrivateWebSocket: Bool
    public let readsSecret: Bool
    public let importsBrokerPayload: Bool
    public let readsRealAccount: Bool
    public let consumesRealAccountPayload: Bool
    public let syncsBrokerPosition: Bool
    public let readsRealPnL: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let runsAccountSnapshotRuntime: Bool
    public let exposesPayloadSchemaRuntimeObject: Bool

    public var fixtureContractBoundaryHeld: Bool {
        fixtureVersion == Self.requiredFixtureVersion
            && records == Self.requiredRecords
            && checksum == Self.requiredChecksum
            && checksumMatchedCanonicalPreimage
            && freshnessStatus == .fresh
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && records.allSatisfy(\.readModelMappingIsolated)
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && opensPrivateWebSocket == false
            && readsSecret == false
            && importsBrokerPayload == false
            && readsRealAccount == false
            && consumesRealAccountPayload == false
            && syncsBrokerPosition == false
            && readsRealPnL == false
            && readsMargin == false
            && readsLeverage == false
            && runsAccountSnapshotRuntime == false
            && exposesPayloadSchemaRuntimeObject == false
    }

    public var canonicalPreimage: String {
        Self.canonicalPreimage(for: records)
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-137-account-position-balance-read-model-only-fixture"),
        issueID: Identifier = try! Identifier("MTP-137"),
        fixtureVersion: FixtureVersion = Self.requiredFixtureVersion,
        records: [AccountPositionBalanceReadModelOnlyFixtureRecord] = Self.requiredRecords,
        checksum: String? = nil,
        checksumMatchedCanonicalPreimage: Bool = true,
        freshnessStatus: ScenarioReplayFreshnessStatus = .fresh,
        forbiddenCapabilities: [AccountPositionBalanceReadModelOnlyForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        opensPrivateWebSocket: Bool = false,
        readsSecret: Bool = false,
        importsBrokerPayload: Bool = false,
        readsRealAccount: Bool = false,
        consumesRealAccountPayload: Bool = false,
        syncsBrokerPosition: Bool = false,
        readsRealPnL: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        runsAccountSnapshotRuntime: Bool = false,
        exposesPayloadSchemaRuntimeObject: Bool = false
    ) throws {
        let expectedChecksum = Self.checksum(for: records)
        let providedChecksum = checksum ?? expectedChecksum
        try Self.validate(
            fixtureVersion: fixtureVersion,
            records: records,
            checksum: providedChecksum,
            checksumMatchedCanonicalPreimage: checksumMatchedCanonicalPreimage,
            freshnessStatus: freshnessStatus,
            forbiddenCapabilities: forbiddenCapabilities
        )
        try Self.validateForbiddenFlags(
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            opensPrivateWebSocket: opensPrivateWebSocket,
            readsSecret: readsSecret,
            importsBrokerPayload: importsBrokerPayload,
            readsRealAccount: readsRealAccount,
            consumesRealAccountPayload: consumesRealAccountPayload,
            syncsBrokerPosition: syncsBrokerPosition,
            readsRealPnL: readsRealPnL,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            runsAccountSnapshotRuntime: runsAccountSnapshotRuntime,
            exposesPayloadSchemaRuntimeObject: exposesPayloadSchemaRuntimeObject
        )

        self.contractID = contractID
        self.issueID = issueID
        self.fixtureVersion = fixtureVersion
        self.records = records
        self.checksum = providedChecksum
        self.checksumMatchedCanonicalPreimage = checksumMatchedCanonicalPreimage
        self.freshnessStatus = freshnessStatus
        self.forbiddenCapabilities = forbiddenCapabilities
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.readsSecret = readsSecret
        self.importsBrokerPayload = importsBrokerPayload
        self.readsRealAccount = readsRealAccount
        self.consumesRealAccountPayload = consumesRealAccountPayload
        self.syncsBrokerPosition = syncsBrokerPosition
        self.readsRealPnL = readsRealPnL
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.runsAccountSnapshotRuntime = runsAccountSnapshotRuntime
        self.exposesPayloadSchemaRuntimeObject = exposesPayloadSchemaRuntimeObject
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            fixtureVersion: try container.decode(FixtureVersion.self, forKey: .fixtureVersion),
            records: try container.decode(
                [AccountPositionBalanceReadModelOnlyFixtureRecord].self,
                forKey: .records
            ),
            checksum: try container.decode(String.self, forKey: .checksum),
            checksumMatchedCanonicalPreimage: try container.decode(
                Bool.self,
                forKey: .checksumMatchedCanonicalPreimage
            ),
            freshnessStatus: try container.decode(ScenarioReplayFreshnessStatus.self, forKey: .freshnessStatus),
            forbiddenCapabilities: try container.decode(
                [AccountPositionBalanceReadModelOnlyForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            opensPrivateWebSocket: try container.decode(Bool.self, forKey: .opensPrivateWebSocket),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            importsBrokerPayload: try container.decode(Bool.self, forKey: .importsBrokerPayload),
            readsRealAccount: try container.decode(Bool.self, forKey: .readsRealAccount),
            consumesRealAccountPayload: try container.decode(Bool.self, forKey: .consumesRealAccountPayload),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            readsRealPnL: try container.decode(Bool.self, forKey: .readsRealPnL),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            runsAccountSnapshotRuntime: try container.decode(Bool.self, forKey: .runsAccountSnapshotRuntime),
            exposesPayloadSchemaRuntimeObject: try container.decode(
                Bool.self,
                forKey: .exposesPayloadSchemaRuntimeObject
            )
        )
    }

    public func containsForbiddenPayloadText(_ forbiddenTokens: [String]) -> Bool {
        let searchable = [
            fixtureVersion.rawValue,
            checksum,
            freshnessStatus.rawValue,
            records.map(\.canonicalLine).joined(separator: "|")
        ]
            .joined(separator: "|")
            .lowercased()

        return forbiddenTokens.contains { token in
            searchable.contains(token.lowercased())
        }
    }

    public static let requiredFixtureVersion = try! FixtureVersion("fixture-v1")
    public static let requiredForbiddenCapabilities =
        AccountPositionBalanceReadModelOnlyForbiddenCapability.allCases

    public static let requiredRecords: [AccountPositionBalanceReadModelOnlyFixtureRecord] = {
        do {
            return [
                try AccountPositionBalanceReadModelOnlyFixtureRecord(
                    component: .accountSnapshot,
                    snapshotID: "account-snapshot|fixture|mtp-137-local-account-evidence|1704067500|fresh",
                    evidenceID: "account-evidence|fixture|mtp-137|1704067500|fresh",
                    readModelFields: [
                        "accountSnapshotId",
                        "accountEvidenceId",
                        "sourceIdentity",
                        "observedAt",
                        "sourceWatermark",
                        "freshnessStatus"
                    ]
                ),
                try AccountPositionBalanceReadModelOnlyFixtureRecord(
                    component: .positionSnapshot,
                    snapshotID: "position-snapshot|fixture|mtp-137-local-position-evidence|BTCUSDT|1704067500|fresh",
                    evidenceID: "position-evidence|fixture|mtp-137|BTCUSDT|long|1704067500|fresh",
                    readModelFields: [
                        "positionSnapshotId",
                        "positionEvidenceId",
                        "symbol",
                        "side",
                        "quantity",
                        "exposureNotional",
                        "sourceIdentity",
                        "freshnessStatus"
                    ]
                ),
                try AccountPositionBalanceReadModelOnlyFixtureRecord(
                    component: .balanceSnapshot,
                    snapshotID: "balance-snapshot|fixture|mtp-137-local-balance-evidence|USD|1704067500|fresh",
                    evidenceID: "balance-evidence|fixture|mtp-137|paper-simulated|1704067500|fresh",
                    readModelFields: [
                        "balanceSnapshotId",
                        "balanceEvidenceId",
                        "currency",
                        "paperCash",
                        "paperEquity",
                        "simulatedBalance",
                        "sourceIdentity",
                        "freshnessStatus"
                    ]
                )
            ]
        } catch {
            preconditionFailure("MTP-137 account / position / balance fixture records must be valid: \(error)")
        }
    }()

    public static let requiredChecksum = checksum(for: requiredRecords)

    public static let deterministicFixture: AccountPositionBalanceReadModelOnlyFixtureContract = {
        do {
            return try AccountPositionBalanceReadModelOnlyFixtureContract()
        } catch {
            preconditionFailure(
                "MTP-137 account / position / balance read-model-only fixture contract must be valid: \(error)"
            )
        }
    }()

    public static func canonicalPreimage(
        for records: [AccountPositionBalanceReadModelOnlyFixtureRecord]
    ) -> String {
        records.map(\.canonicalLine).joined(separator: "\n")
    }

    public static func checksum(
        for records: [AccountPositionBalanceReadModelOnlyFixtureRecord]
    ) -> String {
        ScenarioReplayChecksumEvidence.checksum(forCanonicalPreimage: canonicalPreimage(for: records))
    }

    private static func validate(
        fixtureVersion: FixtureVersion,
        records: [AccountPositionBalanceReadModelOnlyFixtureRecord],
        checksum: String,
        checksumMatchedCanonicalPreimage: Bool,
        freshnessStatus: ScenarioReplayFreshnessStatus,
        forbiddenCapabilities: [AccountPositionBalanceReadModelOnlyForbiddenCapability]
    ) throws {
        guard fixtureVersion == Self.requiredFixtureVersion else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "fixtureVersion",
                expected: Self.requiredFixtureVersion.rawValue,
                actual: fixtureVersion.rawValue
            )
        }
        guard records == Self.requiredRecords else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "records",
                expected: Self.requiredRecords.map(\.component.rawValue).joined(separator: ","),
                actual: records.map(\.component.rawValue).joined(separator: ",")
            )
        }
        guard records.allSatisfy(\.readModelMappingIsolated) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readModelMappingIsolated")
        }
        guard checksum == Self.requiredChecksum else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "checksum",
                expected: Self.requiredChecksum,
                actual: checksum
            )
        }
        guard checksumMatchedCanonicalPreimage else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "checksumMatchedCanonicalPreimage",
                expected: "true",
                actual: "false"
            )
        }
        guard freshnessStatus == .fresh else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "freshnessStatus",
                expected: ScenarioReplayFreshnessStatus.fresh.rawValue,
                actual: freshnessStatus.rawValue
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
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
        readsSecret: Bool,
        importsBrokerPayload: Bool,
        readsRealAccount: Bool,
        consumesRealAccountPayload: Bool,
        syncsBrokerPosition: Bool,
        readsRealPnL: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        runsAccountSnapshotRuntime: Bool,
        exposesPayloadSchemaRuntimeObject: Bool
    ) throws {
        let forbiddenFlags = [
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("opensPrivateWebSocket", opensPrivateWebSocket),
            ("readsSecret", readsSecret),
            ("importsBrokerPayload", importsBrokerPayload),
            ("readsRealAccount", readsRealAccount),
            ("consumesRealAccountPayload", consumesRealAccountPayload),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("readsRealPnL", readsRealPnL),
            ("readsMargin", readsMargin),
            ("readsLeverage", readsLeverage),
            ("runsAccountSnapshotRuntime", runsAccountSnapshotRuntime),
            ("exposesPayloadSchemaRuntimeObject", exposesPayloadSchemaRuntimeObject)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary 是 MTP-130 的 L3.2 simulation gate input fixture。
///
/// 该合同只定义 private stream / account snapshot simulation gate 的输入材料、future fixture
/// requirements、listenKey forbidden tests 和 simulation gate 与 live private stream implementation
/// 的隔离。它不创建 listenKey，不连接 private WebSocket，不运行 account snapshot runtime，
/// 不读取真实账户或 broker position，也不暴露 trading button / live command。
public struct LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let matrixID: String
    public let simulationInputMaterial: [LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial]
    public let futureFixtureRequirements: [LiveReadOnlyPrivateStreamAccountSnapshotFutureFixtureRequirement]
    public let forbiddenCapabilities: [LiveReadOnlyPrivateStreamAccountSnapshotForbiddenCapability]
    public let allowedEvidenceKinds: [LiveReadOnlyPrivateStreamAccountSnapshotEvidenceKind]
    public let createsListenKey: Bool
    public let keepsListenKeyAlive: Bool
    public let opensPrivateWebSocket: Bool
    public let runsPrivateStreamRuntime: Bool
    public let runsAccountSnapshotRuntime: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let readsRealAccount: Bool
    public let consumesRealAccountPayload: Bool
    public let syncsBrokerPosition: Bool
    public let readsMargin: Bool
    public let readsLeverage: Bool
    public let connectsBrokerAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let writesRealOrder: Bool
    public let representsSimulationGateAsLiveStreamImplementation: Bool
    public let representsFixtureSnapshotAsRealAccountSnapshot: Bool
    public let exposesTradingButton: Bool
    public let exposesLiveCommand: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var privateStreamAccountSnapshotSimulationGateBoundaryHeld: Bool {
        matrixID == Self.requiredMatrixID
            && simulationInputMaterial == Self.requiredSimulationInputMaterial
            && futureFixtureRequirements == Self.requiredFutureFixtureRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && createsListenKey == false
            && keepsListenKeyAlive == false
            && opensPrivateWebSocket == false
            && runsPrivateStreamRuntime == false
            && runsAccountSnapshotRuntime == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && readsRealAccount == false
            && consumesRealAccountPayload == false
            && syncsBrokerPosition == false
            && readsMargin == false
            && readsLeverage == false
            && connectsBrokerAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && writesRealOrder == false
            && representsSimulationGateAsLiveStreamImplementation == false
            && representsFixtureSnapshotAsRealAccountSnapshot == false
            && exposesTradingButton == false
            && exposesLiveCommand == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier(
            "mtp-130-live-read-only-private-stream-account-snapshot-simulation-gate"
        ),
        issueID: Identifier = try! Identifier("MTP-130"),
        matrixID: String = Self.requiredMatrixID,
        simulationInputMaterial: [LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial] =
            Self.requiredSimulationInputMaterial,
        futureFixtureRequirements: [LiveReadOnlyPrivateStreamAccountSnapshotFutureFixtureRequirement] =
            Self.requiredFutureFixtureRequirements,
        forbiddenCapabilities: [LiveReadOnlyPrivateStreamAccountSnapshotForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveReadOnlyPrivateStreamAccountSnapshotEvidenceKind] = Self.allowedEvidenceKinds,
        createsListenKey: Bool = false,
        keepsListenKeyAlive: Bool = false,
        opensPrivateWebSocket: Bool = false,
        runsPrivateStreamRuntime: Bool = false,
        runsAccountSnapshotRuntime: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        readsRealAccount: Bool = false,
        consumesRealAccountPayload: Bool = false,
        syncsBrokerPosition: Bool = false,
        readsMargin: Bool = false,
        readsLeverage: Bool = false,
        connectsBrokerAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        writesRealOrder: Bool = false,
        representsSimulationGateAsLiveStreamImplementation: Bool = false,
        representsFixtureSnapshotAsRealAccountSnapshot: Bool = false,
        exposesTradingButton: Bool = false,
        exposesLiveCommand: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            matrixID: matrixID,
            simulationInputMaterial: simulationInputMaterial,
            futureFixtureRequirements: futureFixtureRequirements,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds
        )
        try Self.validateForbiddenFlags(
            createsListenKey: createsListenKey,
            keepsListenKeyAlive: keepsListenKeyAlive,
            opensPrivateWebSocket: opensPrivateWebSocket,
            runsPrivateStreamRuntime: runsPrivateStreamRuntime,
            runsAccountSnapshotRuntime: runsAccountSnapshotRuntime,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            readsRealAccount: readsRealAccount,
            consumesRealAccountPayload: consumesRealAccountPayload,
            syncsBrokerPosition: syncsBrokerPosition,
            readsMargin: readsMargin,
            readsLeverage: readsLeverage,
            connectsBrokerAdapter: connectsBrokerAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            writesRealOrder: writesRealOrder,
            representsSimulationGateAsLiveStreamImplementation:
                representsSimulationGateAsLiveStreamImplementation,
            representsFixtureSnapshotAsRealAccountSnapshot: representsFixtureSnapshotAsRealAccountSnapshot,
            exposesTradingButton: exposesTradingButton,
            exposesLiveCommand: exposesLiveCommand,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.matrixID = matrixID
        self.simulationInputMaterial = simulationInputMaterial
        self.futureFixtureRequirements = futureFixtureRequirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.createsListenKey = createsListenKey
        self.keepsListenKeyAlive = keepsListenKeyAlive
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.runsPrivateStreamRuntime = runsPrivateStreamRuntime
        self.runsAccountSnapshotRuntime = runsAccountSnapshotRuntime
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.readsRealAccount = readsRealAccount
        self.consumesRealAccountPayload = consumesRealAccountPayload
        self.syncsBrokerPosition = syncsBrokerPosition
        self.readsMargin = readsMargin
        self.readsLeverage = readsLeverage
        self.connectsBrokerAdapter = connectsBrokerAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.writesRealOrder = writesRealOrder
        self.representsSimulationGateAsLiveStreamImplementation =
            representsSimulationGateAsLiveStreamImplementation
        self.representsFixtureSnapshotAsRealAccountSnapshot = representsFixtureSnapshotAsRealAccountSnapshot
        self.exposesTradingButton = exposesTradingButton
        self.exposesLiveCommand = exposesLiveCommand
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            matrixID: try container.decode(String.self, forKey: .matrixID),
            simulationInputMaterial: try container.decode(
                [LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial].self,
                forKey: .simulationInputMaterial
            ),
            futureFixtureRequirements: try container.decode(
                [LiveReadOnlyPrivateStreamAccountSnapshotFutureFixtureRequirement].self,
                forKey: .futureFixtureRequirements
            ),
            forbiddenCapabilities: try container.decode(
                [LiveReadOnlyPrivateStreamAccountSnapshotForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveReadOnlyPrivateStreamAccountSnapshotEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            keepsListenKeyAlive: try container.decode(Bool.self, forKey: .keepsListenKeyAlive),
            opensPrivateWebSocket: try container.decode(Bool.self, forKey: .opensPrivateWebSocket),
            runsPrivateStreamRuntime: try container.decode(Bool.self, forKey: .runsPrivateStreamRuntime),
            runsAccountSnapshotRuntime: try container.decode(
                Bool.self,
                forKey: .runsAccountSnapshotRuntime
            ),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            readsRealAccount: try container.decode(Bool.self, forKey: .readsRealAccount),
            consumesRealAccountPayload: try container.decode(Bool.self, forKey: .consumesRealAccountPayload),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition),
            readsMargin: try container.decode(Bool.self, forKey: .readsMargin),
            readsLeverage: try container.decode(Bool.self, forKey: .readsLeverage),
            connectsBrokerAdapter: try container.decode(Bool.self, forKey: .connectsBrokerAdapter),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            writesRealOrder: try container.decode(Bool.self, forKey: .writesRealOrder),
            representsSimulationGateAsLiveStreamImplementation: try container.decode(
                Bool.self,
                forKey: .representsSimulationGateAsLiveStreamImplementation
            ),
            representsFixtureSnapshotAsRealAccountSnapshot: try container.decode(
                Bool.self,
                forKey: .representsFixtureSnapshotAsRealAccountSnapshot
            ),
            exposesTradingButton: try container.decode(Bool.self, forKey: .exposesTradingButton),
            exposesLiveCommand: try container.decode(Bool.self, forKey: .exposesLiveCommand),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredMatrixID = "TVM-LIVE-READ-ONLY-READINESS"
    public static let requiredSimulationInputMaterial =
        LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial.allCases
    public static let requiredFutureFixtureRequirements =
        LiveReadOnlyPrivateStreamAccountSnapshotFutureFixtureRequirement.allCases
    public static let requiredForbiddenCapabilities =
        LiveReadOnlyPrivateStreamAccountSnapshotForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveReadOnlyPrivateStreamAccountSnapshotEvidenceKind] = [
        .contractDocumentation,
        .domainContextTerms,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicForbiddenTest,
        .l32HandoffMaterial,
        .prBoundaryEvidence
    ]

    public static let deterministicFixture: LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary = {
        do {
            return try LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary()
        } catch {
            preconditionFailure(
                "MTP-130 Live read-only private stream / account snapshot simulation gate fixture "
                    + "must be valid: \(error)"
            )
        }
    }()

    private static func validate(
        matrixID: String,
        simulationInputMaterial: [LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial],
        futureFixtureRequirements: [LiveReadOnlyPrivateStreamAccountSnapshotFutureFixtureRequirement],
        forbiddenCapabilities: [LiveReadOnlyPrivateStreamAccountSnapshotForbiddenCapability],
        allowedEvidenceKinds: [LiveReadOnlyPrivateStreamAccountSnapshotEvidenceKind]
    ) throws {
        guard matrixID == Self.requiredMatrixID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "matrixID",
                expected: Self.requiredMatrixID,
                actual: matrixID
            )
        }
        guard simulationInputMaterial == Self.requiredSimulationInputMaterial else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "simulationInputMaterial",
                expected: Self.requiredSimulationInputMaterial.map(\.rawValue).joined(separator: ","),
                actual: simulationInputMaterial.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureFixtureRequirements == Self.requiredFutureFixtureRequirements else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureFixtureRequirements",
                expected: Self.requiredFutureFixtureRequirements.map(\.rawValue).joined(separator: ","),
                actual: futureFixtureRequirements.map(\.rawValue).joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
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
        createsListenKey: Bool,
        keepsListenKeyAlive: Bool,
        opensPrivateWebSocket: Bool,
        runsPrivateStreamRuntime: Bool,
        runsAccountSnapshotRuntime: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        readsRealAccount: Bool,
        consumesRealAccountPayload: Bool,
        syncsBrokerPosition: Bool,
        readsMargin: Bool,
        readsLeverage: Bool,
        connectsBrokerAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        writesRealOrder: Bool,
        representsSimulationGateAsLiveStreamImplementation: Bool,
        representsFixtureSnapshotAsRealAccountSnapshot: Bool,
        exposesTradingButton: Bool,
        exposesLiveCommand: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        let forbiddenFlags = [
            ("createsListenKey", createsListenKey),
            ("keepsListenKeyAlive", keepsListenKeyAlive),
            ("opensPrivateWebSocket", opensPrivateWebSocket),
            ("runsPrivateStreamRuntime", runsPrivateStreamRuntime),
            ("runsAccountSnapshotRuntime", runsAccountSnapshotRuntime),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("readsRealAccount", readsRealAccount),
            ("consumesRealAccountPayload", consumesRealAccountPayload),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("readsMargin", readsMargin),
            ("readsLeverage", readsLeverage),
            ("connectsBrokerAdapter", connectsBrokerAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("writesRealOrder", writesRealOrder),
            (
                "representsSimulationGateAsLiveStreamImplementation",
                representsSimulationGateAsLiveStreamImplementation
            ),
            (
                "representsFixtureSnapshotAsRealAccountSnapshot",
                representsFixtureSnapshotAsRealAccountSnapshot
            ),
            ("exposesTradingButton", exposesTradingButton),
            ("exposesLiveCommand", exposesLiveCommand),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveReadOnlyWorkbenchReadModelBoundary 是 MTP-131 的 Workbench / Dashboard 只读边界 fixture。
///
/// 该合同固定 UI 只能消费 ReadModel / ViewModel，并且只能展示 Live readiness boundary evidence。
/// 所有 API key 输入、secret storage、broker/account connect、Live PRO Console、交易按钮、live command、
/// order form、signed/account endpoint、listenKey、adapter、Runtime、schema、OMS 和真实订单能力都必须保持
/// `false`；Codable 解码也会重复校验，避免后续 UI payload 被反序列化成可执行 surface。
public struct LiveReadOnlyWorkbenchReadModelBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let matrixID: String
    public let boundarySurfaces: [LiveReadOnlyWorkbenchBoundarySurface]
    public let inputBoundaries: [LiveReadOnlyWorkbenchInputBoundary]
    public let forbiddenUISurfaces: [LiveReadOnlyWorkbenchForbiddenUISurface]
    public let detailAuditRoutes: [LiveReadOnlyWorkbenchDetailAuditRoute]
    public let handoffTargets: [LiveReadOnlyWorkbenchHandoffTarget]
    public let allowedEvidenceKinds: [LiveReadOnlyWorkbenchEvidenceKind]
    public let sourceAnchors: [String]
    public let validationAnchors: [String]
    public let consumesOnlyReadModelViewModel: Bool
    public let exposesAPIKeyInput: Bool
    public let storesSecret: Bool
    public let providesBrokerConnect: Bool
    public let providesAccountConnect: Bool
    public let exposesLivePROConsole: Bool
    public let providesTradingButton: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesRealAccountBalance: Bool
    public let exposesBrokerPosition: Bool
    public let exposesRuntimeObject: Bool
    public let exposesDatabaseSchema: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let instantiatesBrokerAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var workbenchReadModelOnlyBoundaryHeld: Bool {
        matrixID == Self.requiredMatrixID
            && boundarySurfaces == Self.requiredBoundarySurfaces
            && inputBoundaries == Self.requiredInputBoundaries
            && forbiddenUISurfaces == Self.requiredForbiddenUISurfaces
            && detailAuditRoutes == Self.requiredDetailAuditRoutes
            && handoffTargets == Self.requiredHandoffTargets
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && sourceAnchors == Self.requiredSourceAnchors
            && validationAnchors == Self.requiredValidationAnchors
            && consumesOnlyReadModelViewModel
            && exposesAPIKeyInput == false
            && storesSecret == false
            && providesBrokerConnect == false
            && providesAccountConnect == false
            && exposesLivePROConsole == false
            && providesTradingButton == false
            && providesLiveCommand == false
            && exposesOrderForm == false
            && exposesRealAccountBalance == false
            && exposesBrokerPosition == false
            && exposesRuntimeObject == false
            && exposesDatabaseSchema == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && instantiatesBrokerAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-131-live-read-only-workbench-read-model-boundary"),
        issueID: Identifier = try! Identifier("MTP-131"),
        matrixID: String = Self.requiredMatrixID,
        boundarySurfaces: [LiveReadOnlyWorkbenchBoundarySurface] = Self.requiredBoundarySurfaces,
        inputBoundaries: [LiveReadOnlyWorkbenchInputBoundary] = Self.requiredInputBoundaries,
        forbiddenUISurfaces: [LiveReadOnlyWorkbenchForbiddenUISurface] = Self.requiredForbiddenUISurfaces,
        detailAuditRoutes: [LiveReadOnlyWorkbenchDetailAuditRoute] = Self.requiredDetailAuditRoutes,
        handoffTargets: [LiveReadOnlyWorkbenchHandoffTarget] = Self.requiredHandoffTargets,
        allowedEvidenceKinds: [LiveReadOnlyWorkbenchEvidenceKind] = Self.allowedEvidenceKinds,
        sourceAnchors: [String] = Self.requiredSourceAnchors,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        consumesOnlyReadModelViewModel: Bool = true,
        exposesAPIKeyInput: Bool = false,
        storesSecret: Bool = false,
        providesBrokerConnect: Bool = false,
        providesAccountConnect: Bool = false,
        exposesLivePROConsole: Bool = false,
        providesTradingButton: Bool = false,
        providesLiveCommand: Bool = false,
        exposesOrderForm: Bool = false,
        exposesRealAccountBalance: Bool = false,
        exposesBrokerPosition: Bool = false,
        exposesRuntimeObject: Bool = false,
        exposesDatabaseSchema: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        instantiatesBrokerAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            matrixID: matrixID,
            boundarySurfaces: boundarySurfaces,
            inputBoundaries: inputBoundaries,
            forbiddenUISurfaces: forbiddenUISurfaces,
            detailAuditRoutes: detailAuditRoutes,
            handoffTargets: handoffTargets,
            allowedEvidenceKinds: allowedEvidenceKinds,
            sourceAnchors: sourceAnchors,
            validationAnchors: validationAnchors
        )
        try Self.validateForbiddenFlags(
            consumesOnlyReadModelViewModel: consumesOnlyReadModelViewModel,
            exposesAPIKeyInput: exposesAPIKeyInput,
            storesSecret: storesSecret,
            providesBrokerConnect: providesBrokerConnect,
            providesAccountConnect: providesAccountConnect,
            exposesLivePROConsole: exposesLivePROConsole,
            providesTradingButton: providesTradingButton,
            providesLiveCommand: providesLiveCommand,
            exposesOrderForm: exposesOrderForm,
            exposesRealAccountBalance: exposesRealAccountBalance,
            exposesBrokerPosition: exposesBrokerPosition,
            exposesRuntimeObject: exposesRuntimeObject,
            exposesDatabaseSchema: exposesDatabaseSchema,
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            instantiatesBrokerAdapter: instantiatesBrokerAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.matrixID = matrixID
        self.boundarySurfaces = boundarySurfaces
        self.inputBoundaries = inputBoundaries
        self.forbiddenUISurfaces = forbiddenUISurfaces
        self.detailAuditRoutes = detailAuditRoutes
        self.handoffTargets = handoffTargets
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.sourceAnchors = sourceAnchors
        self.validationAnchors = validationAnchors
        self.consumesOnlyReadModelViewModel = consumesOnlyReadModelViewModel
        self.exposesAPIKeyInput = exposesAPIKeyInput
        self.storesSecret = storesSecret
        self.providesBrokerConnect = providesBrokerConnect
        self.providesAccountConnect = providesAccountConnect
        self.exposesLivePROConsole = exposesLivePROConsole
        self.providesTradingButton = providesTradingButton
        self.providesLiveCommand = providesLiveCommand
        self.exposesOrderForm = exposesOrderForm
        self.exposesRealAccountBalance = exposesRealAccountBalance
        self.exposesBrokerPosition = exposesBrokerPosition
        self.exposesRuntimeObject = exposesRuntimeObject
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.instantiatesBrokerAdapter = instantiatesBrokerAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
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
            matrixID: try container.decode(String.self, forKey: .matrixID),
            boundarySurfaces: try container.decode(
                [LiveReadOnlyWorkbenchBoundarySurface].self,
                forKey: .boundarySurfaces
            ),
            inputBoundaries: try container.decode(
                [LiveReadOnlyWorkbenchInputBoundary].self,
                forKey: .inputBoundaries
            ),
            forbiddenUISurfaces: try container.decode(
                [LiveReadOnlyWorkbenchForbiddenUISurface].self,
                forKey: .forbiddenUISurfaces
            ),
            detailAuditRoutes: try container.decode(
                [LiveReadOnlyWorkbenchDetailAuditRoute].self,
                forKey: .detailAuditRoutes
            ),
            handoffTargets: try container.decode(
                [LiveReadOnlyWorkbenchHandoffTarget].self,
                forKey: .handoffTargets
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveReadOnlyWorkbenchEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            sourceAnchors: try container.decode([String].self, forKey: .sourceAnchors),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            consumesOnlyReadModelViewModel: try container.decode(
                Bool.self,
                forKey: .consumesOnlyReadModelViewModel
            ),
            exposesAPIKeyInput: try container.decode(Bool.self, forKey: .exposesAPIKeyInput),
            storesSecret: try container.decode(Bool.self, forKey: .storesSecret),
            providesBrokerConnect: try container.decode(Bool.self, forKey: .providesBrokerConnect),
            providesAccountConnect: try container.decode(Bool.self, forKey: .providesAccountConnect),
            exposesLivePROConsole: try container.decode(Bool.self, forKey: .exposesLivePROConsole),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm),
            exposesRealAccountBalance: try container.decode(Bool.self, forKey: .exposesRealAccountBalance),
            exposesBrokerPosition: try container.decode(Bool.self, forKey: .exposesBrokerPosition),
            exposesRuntimeObject: try container.decode(Bool.self, forKey: .exposesRuntimeObject),
            exposesDatabaseSchema: try container.decode(Bool.self, forKey: .exposesDatabaseSchema),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            instantiatesBrokerAdapter: try container.decode(Bool.self, forKey: .instantiatesBrokerAdapter),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let requiredMatrixID = "TVM-LIVE-READ-ONLY-READINESS"
    public static let requiredBoundarySurfaces = LiveReadOnlyWorkbenchBoundarySurface.allCases
    public static let requiredInputBoundaries = LiveReadOnlyWorkbenchInputBoundary.allCases
    public static let requiredForbiddenUISurfaces = LiveReadOnlyWorkbenchForbiddenUISurface.allCases
    public static let requiredDetailAuditRoutes = LiveReadOnlyWorkbenchDetailAuditRoute.allCases
    public static let requiredHandoffTargets = LiveReadOnlyWorkbenchHandoffTarget.allCases

    public static let allowedEvidenceKinds: [LiveReadOnlyWorkbenchEvidenceKind] = [
        .contractDocumentation,
        .coreDeterministicFixture,
        .appReadModel,
        .appViewModel,
        .dashboardShellSnapshot,
        .eventTimelineAuditRoute,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicForbiddenTest,
        .l31l32l33HandoffMaterial,
        .prBoundaryEvidence
    ]

    public static let requiredSourceAnchors: [String] = [
        "MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY",
        "MTP-127-ENDPOINT-CAPABILITY-TAXONOMY",
        "MTP-128-ADAPTER-CAPABILITY-MATRIX",
        "MTP-129-ACCOUNT-POSITION-BALANCE-FUTURE-GATES",
        "MTP-130-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE",
        "MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY"
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY",
        "MTP-131-READ-MODEL-VIEWMODEL-INPUT-BOUNDARY",
        "MTP-131-FORBIDDEN-UI-SURFACE",
        "MTP-131-DETAIL-AUDIT-ROUTING",
        "MTP-131-L31-L32-L33-HANDOFF",
        "MTP-131-LIVE-READ-ONLY-WORKBENCH-VALIDATION"
    ]

    public static let deterministicFixture: LiveReadOnlyWorkbenchReadModelBoundary = {
        do {
            return try LiveReadOnlyWorkbenchReadModelBoundary()
        } catch {
            preconditionFailure(
                "MTP-131 Live read-only Workbench read-model boundary fixture must be valid: \(error)"
            )
        }
    }()

    private static func validate(
        matrixID: String,
        boundarySurfaces: [LiveReadOnlyWorkbenchBoundarySurface],
        inputBoundaries: [LiveReadOnlyWorkbenchInputBoundary],
        forbiddenUISurfaces: [LiveReadOnlyWorkbenchForbiddenUISurface],
        detailAuditRoutes: [LiveReadOnlyWorkbenchDetailAuditRoute],
        handoffTargets: [LiveReadOnlyWorkbenchHandoffTarget],
        allowedEvidenceKinds: [LiveReadOnlyWorkbenchEvidenceKind],
        sourceAnchors: [String],
        validationAnchors: [String]
    ) throws {
        let checks: [(field: String, expected: [String], actual: [String])] = [
            ("boundarySurfaces", Self.requiredBoundarySurfaces.map(\.rawValue), boundarySurfaces.map(\.rawValue)),
            ("inputBoundaries", Self.requiredInputBoundaries.map(\.rawValue), inputBoundaries.map(\.rawValue)),
            ("forbiddenUISurfaces", Self.requiredForbiddenUISurfaces.map(\.rawValue), forbiddenUISurfaces.map(\.rawValue)),
            ("detailAuditRoutes", Self.requiredDetailAuditRoutes.map(\.rawValue), detailAuditRoutes.map(\.rawValue)),
            ("handoffTargets", Self.requiredHandoffTargets.map(\.rawValue), handoffTargets.map(\.rawValue)),
            ("allowedEvidenceKinds", Self.allowedEvidenceKinds.map(\.rawValue), allowedEvidenceKinds.map(\.rawValue)),
            ("sourceAnchors", Self.requiredSourceAnchors, sourceAnchors),
            ("validationAnchors", Self.requiredValidationAnchors, validationAnchors)
        ]
        guard matrixID == Self.requiredMatrixID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "matrixID",
                expected: Self.requiredMatrixID,
                actual: matrixID
            )
        }
        for check in checks where check.expected != check.actual {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: check.field,
                expected: check.expected.joined(separator: ","),
                actual: check.actual.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        consumesOnlyReadModelViewModel: Bool,
        exposesAPIKeyInput: Bool,
        storesSecret: Bool,
        providesBrokerConnect: Bool,
        providesAccountConnect: Bool,
        exposesLivePROConsole: Bool,
        providesTradingButton: Bool,
        providesLiveCommand: Bool,
        exposesOrderForm: Bool,
        exposesRealAccountBalance: Bool,
        exposesBrokerPosition: Bool,
        exposesRuntimeObject: Bool,
        exposesDatabaseSchema: Bool,
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        instantiatesBrokerAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderLifecycle: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard consumesOnlyReadModelViewModel else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "consumesOnlyReadModelViewModel",
                expected: "true",
                actual: "false"
            )
        }
        let forbiddenFlags = [
            ("exposesAPIKeyInput", exposesAPIKeyInput),
            ("storesSecret", storesSecret),
            ("providesBrokerConnect", providesBrokerConnect),
            ("providesAccountConnect", providesAccountConnect),
            ("exposesLivePROConsole", exposesLivePROConsole),
            ("providesTradingButton", providesTradingButton),
            ("providesLiveCommand", providesLiveCommand),
            ("exposesOrderForm", exposesOrderForm),
            ("exposesRealAccountBalance", exposesRealAccountBalance),
            ("exposesBrokerPosition", exposesBrokerPosition),
            ("exposesRuntimeObject", exposesRuntimeObject),
            ("exposesDatabaseSchema", exposesDatabaseSchema),
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("instantiatesBrokerAdapter", instantiatesBrokerAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
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
