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
