import Foundation

/// LiveAuditIncidentStopTerm 定义 MTP-89 允许命名的 Live audit / incident / stop 术语。
///
/// 这些术语只服务 Future / gated 合同、blocked evidence 和后续验证锚点；它们不构成当前
/// incident replay runtime、emergency stop、shutdown、restore、production operations、
/// Live PRO Console、live command、交易按钮、broker action 或真实交易授权。
public enum LiveAuditIncidentStopTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case liveAudit = "live audit"
    case auditTrail = "audit trail"
    case incident = "incident"
    case incidentReplay = "incident replay"
    case stopControl = "stop control"
    case emergencyStop = "emergency stop"
    case shutdown = "shutdown"
    case restore = "restore"
}

/// FutureAuditIncidentStopTaxonomyTerm 固定 MTP-89 的 future audit / incident / stop 分类。
///
/// 这些值只是 taxonomy label，不能被解释成当前 Swift command、production operation、
/// live console action、runtime workflow、broker action、incident replay executor 或停机 / 恢复命令。
public enum FutureAuditIncidentStopTaxonomyTerm: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signalAuditTrail = "signal audit trail"
    case orderAuditTrail = "order audit trail"
    case riskDecisionAuditTrail = "risk decision audit trail"
    case fillAuditTrail = "fill audit trail"
    case incidentReplay = "incident replay"
    case stopControl = "stop control"
    case emergencyStop = "emergency stop"
    case shutdown = "shutdown"
    case restore = "restore"
    case productionOperations = "production operations"
}

/// LiveAuditIncidentStopFutureGate 描述 Future audit / incident / stop 进入实现前必须补齐的 gate。
///
/// Gate 只表达后续 Project Definition 前的必要条件；当前 MTP-89 不实现审计存储、事故回放、
/// 停机 / 恢复控制、生产运维、Live PRO Console、signed/account/listenKey、broker action 或命令 UI。
public enum LiveAuditIncidentStopFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case humanLiveAuditIncidentStopDecision = "Human independent Live audit / incident / stop decision"
    case liveTradingFoundationBoundarySatisfied = "Live trading foundation boundary satisfied"
    case liveExecutionControlBoundarySatisfied = "Live execution control boundary satisfied"
    case liveRiskGateBoundarySatisfied = "Live risk gate boundary satisfied"
    case auditTrailContractDefined = "audit trail contract defined"
    case incidentReplayContractDefined = "incident replay contract defined"
    case stopControlContractDefined = "stop control contract defined"
    case emergencyStopShutdownRestoreContractDefined = "emergency stop / shutdown / restore contract defined"
    case productionOperationsContractDefined = "production operations contract defined"
    case readModelOnlyBlockedEvidenceDefined = "read-model-only incident / stop blocked evidence defined"
    case dashboardReportTimelineEvidenceBoundaryDefined = "Dashboard / Report / Event Timeline evidence boundary defined"
    case liveProConsoleIndependentProjectDefinition = "Live PRO Console independent Project Definition required"
}

/// LiveAuditIncidentStopForbiddenCapability 枚举 MTP-89 必须保持禁止的能力面。
///
/// 这些值可以进入 deterministic forbidden tests 和 PR evidence，但不能出现在当前可执行 API、
/// adapter、runtime、operation、UI command、Live PRO Console、paper evidence 升级路径或网络请求中。
public enum LiveAuditIncidentStopForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case apiKey = "API key"
    case secretStorage = "secret storage"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case brokerAction = "broker action"
    case brokerExecutionAdapter = "broker execution adapter"
    case exchangeExecutionAdapter = "exchange execution adapter"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case oms = "OMS"
    case realOrderStateMachine = "real order state machine"
    case realOrderSubmit = "real order submit"
    case realOrderCancel = "real order cancel"
    case realOrderReplace = "real order replace"
    case executionReportRuntime = "execution report runtime"
    case brokerFillRuntime = "broker fill runtime"
    case reconciliationRuntime = "reconciliation runtime"
    case auditTrailRuntime = "audit trail runtime"
    case incidentReplayRuntime = "incident replay runtime"
    case stopControlRuntime = "stop control runtime"
    case emergencyStopCommand = "emergency stop command"
    case shutdownCommand = "shutdown command"
    case restoreCommand = "restore command"
    case productionOperationsRuntime = "production operations runtime"
    case liveProConsole = "Live PRO Console"
    case liveCommandSurface = "live command surface"
    case orderLevelCommandUI = "order-level command UI"
    case tradingButton = "trading button"
    case workbenchLiveProConsoleUpgrade = "Workbench to Live PRO Console upgrade"
    case dashboardLiveProConsoleUpgrade = "Dashboard to Live PRO Console upgrade"
}

/// LiveAuditIncidentStopEvidenceKind 限定 MTP-89 当前可以输出的非执行证据。
///
/// Evidence 只用于合同、validation anchor、deterministic tests、blocked evidence 边界和 PR 审计；
/// Dashboard / Report / Event Timeline 展示面、read model 和 automation readiness 收口保留给后续 issue。
public enum LiveAuditIncidentStopEvidenceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case contractDocumentation = "contract documentation"
    case validationMatrixCandidate = "validation matrix candidate"
    case validationPlanAnchor = "validation plan anchor"
    case deterministicForbiddenTest = "deterministic forbidden capability test"
    case futureGateTaxonomy = "future gate taxonomy"
    case blockedEvidenceBoundary = "blocked evidence boundary"
    case prBoundaryEvidence = "PR boundary evidence"
}

/// LiveAuditTrailSubject 固定 MTP-90 允许讨论的 Future audit trail 对象。
///
/// 这些对象只用于后续 Project Definition 前的审计链 gate 命名；当前代码不得把 signal、
/// paper order、risk blocker 或 simulated fill 升级为真实 audit fact、broker ledger、OMS log
/// 或 production audit runtime。
public enum LiveAuditTrailSubject: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signal = "signal"
    case order = "order"
    case riskDecision = "risk decision"
    case fill = "fill"
}

/// LiveAuditTrailFutureGate 定义 MTP-90 的 signal / order / risk decision / fill future gates。
///
/// Gate 只描述 Future Live audit trail 进入实现前必须具备的合同和证据来源；它们不创建
/// execution report ingestion、broker fill fact、real order state machine、OMS、broker action、
/// reconciliation runtime 或任何 live command。
public enum LiveAuditTrailFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signalSourceContractDefined = "signal source contract defined"
    case signalDecisionPathContractDefined = "signal decision path contract defined"
    case signalReplayCorrelationContractDefined = "signal replay correlation contract defined"
    case orderIntentSourceContractDefined = "order intent source contract defined"
    case orderStateTransitionContractDefined = "order state transition contract defined"
    case orderCommandAuthorizationGateDefined = "order command authorization gate defined"
    case riskDecisionSourceContractDefined = "risk decision source contract defined"
    case riskGateOutcomeContractDefined = "risk gate outcome contract defined"
    case riskBlockedReasonContractDefined = "risk blocked reason contract defined"
    case fillSourceContractDefined = "fill source contract defined"
    case executionReportSourceGateDefined = "execution report source gate defined"
    case brokerFillSourceGateDefined = "broker fill source gate defined"
    case auditTrailReplayCorrelationGateDefined = "audit trail replay correlation gate defined"
    case readModelOnlyAuditEvidenceGateDefined = "read-model-only audit evidence gate defined"
}

/// LiveAuditTrailForbiddenCapability 枚举 MTP-90 必须保持禁止的 audit trail 能力面。
///
/// 这些 capability 可以作为 deterministic forbidden tests 和 PR evidence 出现，但不能被实现为
/// 当前 adapter、runtime、parser、broker recorder、OMS、real order state machine、UI command
/// 或真实交易行为。
public enum LiveAuditTrailForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case brokerAction = "broker action"
    case executionReportIngestion = "execution report ingestion"
    case brokerFillFact = "broker fill fact"
    case brokerFillRecorder = "broker fill recorder"
    case realOrderStateMachine = "real order state machine"
    case oms = "OMS"
    case brokerReconciliation = "broker reconciliation"
    case auditTrailRuntime = "audit trail runtime"
    case realOrderSubmitCancelReplace = "real order submit / cancel / replace"
    case liveCommandSurface = "live command surface"
    case orderLevelCommandUI = "order-level command UI"
    case tradingButton = "trading button"
    case paperOrderAuditFactUpgrade = "paper order to real audit fact upgrade"
    case simulatedFillBrokerFillUpgrade = "simulated fill to broker fill upgrade"
    case riskBlockerLiveRiskDecisionUpgrade = "risk blocker to live risk decision upgrade"
}

/// LiveAuditTrailFutureGateBoundary 是 MTP-90 的 Future audit trail gate fixture。
///
/// 该 fixture 只固定 signal、order、risk decision 和 fill 的 Future gate、source anchor、
/// forbidden capability 和 validation anchor。它明确阻断 execution report ingestion、broker fill
/// fact、real order state machine、OMS、broker action，以及 paper evidence 到真实 audit fact 的升级。
public struct LiveAuditTrailFutureGateBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let subjects: [LiveAuditTrailSubject]
    public let futureGates: [LiveAuditTrailFutureGate]
    public let forbiddenCapabilities: [LiveAuditTrailForbiddenCapability]
    public let allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind]
    public let auditTrailSourceAnchors: [String]
    public let validationAnchors: [String]
    public let isFutureOnlyAuditTrailContract: Bool
    public let representsBlockedEvidenceOnly: Bool
    public let upgradesSignalEvidenceToLiveAuditFact: Bool
    public let upgradesPaperOrderToRealOrderAuditFact: Bool
    public let upgradesPaperRiskToLiveRiskDecisionAuditFact: Bool
    public let upgradesSimulatedFillToBrokerFillAuditFact: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let executesBrokerAction: Bool
    public let ingestsExecutionReport: Bool
    public let recordsBrokerFillFact: Bool
    public let recordsBrokerFillRuntime: Bool
    public let implementsRealOrderStateMachine: Bool
    public let implementsOMS: Bool
    public let performsBrokerReconciliation: Bool
    public let recordsAuditTrailRuntime: Bool
    public let submitsCancelsOrReplacesRealOrder: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var auditTrailFutureGateBoundaryHeld: Bool {
        subjects == Self.requiredSubjects
            && futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && auditTrailSourceAnchors == Self.requiredAuditTrailSourceAnchors
            && validationAnchors == Self.requiredValidationAnchors
            && forbiddenCapabilityBoundaryHeld
            && paperEvidenceIsolationBoundaryHeld
    }

    public var paperEvidenceIsolationBoundaryHeld: Bool {
        isFutureOnlyAuditTrailContract
            && representsBlockedEvidenceOnly
            && upgradesSignalEvidenceToLiveAuditFact == false
            && upgradesPaperOrderToRealOrderAuditFact == false
            && upgradesPaperRiskToLiveRiskDecisionAuditFact == false
            && upgradesSimulatedFillToBrokerFillAuditFact == false
            && ingestsExecutionReport == false
            && recordsBrokerFillFact == false
            && implementsRealOrderStateMachine == false
            && implementsOMS == false
            && executesBrokerAction == false
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        isFutureOnlyAuditTrailContract
            && representsBlockedEvidenceOnly
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && implementsLiveExecutionAdapter == false
            && executesBrokerAction == false
            && ingestsExecutionReport == false
            && recordsBrokerFillFact == false
            && recordsBrokerFillRuntime == false
            && implementsRealOrderStateMachine == false
            && implementsOMS == false
            && performsBrokerReconciliation == false
            && recordsAuditTrailRuntime == false
            && submitsCancelsOrReplacesRealOrder == false
            && providesLiveCommand == false
            && exposesOrderLevelCommandUI == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-90-live-audit-trail-future-gates"),
        issueID: Identifier = try! Identifier("MTP-90"),
        subjects: [LiveAuditTrailSubject] = Self.requiredSubjects,
        futureGates: [LiveAuditTrailFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveAuditTrailForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind] = Self.allowedEvidenceKinds,
        auditTrailSourceAnchors: [String] = Self.requiredAuditTrailSourceAnchors,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        isFutureOnlyAuditTrailContract: Bool = true,
        representsBlockedEvidenceOnly: Bool = true,
        upgradesSignalEvidenceToLiveAuditFact: Bool = false,
        upgradesPaperOrderToRealOrderAuditFact: Bool = false,
        upgradesPaperRiskToLiveRiskDecisionAuditFact: Bool = false,
        upgradesSimulatedFillToBrokerFillAuditFact: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        executesBrokerAction: Bool = false,
        ingestsExecutionReport: Bool = false,
        recordsBrokerFillFact: Bool = false,
        recordsBrokerFillRuntime: Bool = false,
        implementsRealOrderStateMachine: Bool = false,
        implementsOMS: Bool = false,
        performsBrokerReconciliation: Bool = false,
        recordsAuditTrailRuntime: Bool = false,
        submitsCancelsOrReplacesRealOrder: Bool = false,
        providesLiveCommand: Bool = false,
        exposesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            subjects: subjects,
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            auditTrailSourceAnchors: auditTrailSourceAnchors,
            validationAnchors: validationAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureOnlyAuditTrailContract: isFutureOnlyAuditTrailContract,
            representsBlockedEvidenceOnly: representsBlockedEvidenceOnly,
            upgradesSignalEvidenceToLiveAuditFact: upgradesSignalEvidenceToLiveAuditFact,
            upgradesPaperOrderToRealOrderAuditFact: upgradesPaperOrderToRealOrderAuditFact,
            upgradesPaperRiskToLiveRiskDecisionAuditFact: upgradesPaperRiskToLiveRiskDecisionAuditFact,
            upgradesSimulatedFillToBrokerFillAuditFact: upgradesSimulatedFillToBrokerFillAuditFact,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            executesBrokerAction: executesBrokerAction,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFillFact: recordsBrokerFillFact,
            recordsBrokerFillRuntime: recordsBrokerFillRuntime,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            implementsOMS: implementsOMS,
            performsBrokerReconciliation: performsBrokerReconciliation,
            recordsAuditTrailRuntime: recordsAuditTrailRuntime,
            submitsCancelsOrReplacesRealOrder: submitsCancelsOrReplacesRealOrder,
            providesLiveCommand: providesLiveCommand,
            exposesOrderLevelCommandUI: exposesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.subjects = subjects
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.auditTrailSourceAnchors = auditTrailSourceAnchors
        self.validationAnchors = validationAnchors
        self.isFutureOnlyAuditTrailContract = isFutureOnlyAuditTrailContract
        self.representsBlockedEvidenceOnly = representsBlockedEvidenceOnly
        self.upgradesSignalEvidenceToLiveAuditFact = upgradesSignalEvidenceToLiveAuditFact
        self.upgradesPaperOrderToRealOrderAuditFact = upgradesPaperOrderToRealOrderAuditFact
        self.upgradesPaperRiskToLiveRiskDecisionAuditFact = upgradesPaperRiskToLiveRiskDecisionAuditFact
        self.upgradesSimulatedFillToBrokerFillAuditFact = upgradesSimulatedFillToBrokerFillAuditFact
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.executesBrokerAction = executesBrokerAction
        self.ingestsExecutionReport = ingestsExecutionReport
        self.recordsBrokerFillFact = recordsBrokerFillFact
        self.recordsBrokerFillRuntime = recordsBrokerFillRuntime
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.implementsOMS = implementsOMS
        self.performsBrokerReconciliation = performsBrokerReconciliation
        self.recordsAuditTrailRuntime = recordsAuditTrailRuntime
        self.submitsCancelsOrReplacesRealOrder = submitsCancelsOrReplacesRealOrder
        self.providesLiveCommand = providesLiveCommand
        self.exposesOrderLevelCommandUI = exposesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            subjects: try container.decode([LiveAuditTrailSubject].self, forKey: .subjects),
            futureGates: try container.decode([LiveAuditTrailFutureGate].self, forKey: .futureGates),
            forbiddenCapabilities: try container.decode(
                [LiveAuditTrailForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveAuditIncidentStopEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            auditTrailSourceAnchors: try container.decode([String].self, forKey: .auditTrailSourceAnchors),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            isFutureOnlyAuditTrailContract: try container.decode(
                Bool.self,
                forKey: .isFutureOnlyAuditTrailContract
            ),
            representsBlockedEvidenceOnly: try container.decode(Bool.self, forKey: .representsBlockedEvidenceOnly),
            upgradesSignalEvidenceToLiveAuditFact: try container.decode(
                Bool.self,
                forKey: .upgradesSignalEvidenceToLiveAuditFact
            ),
            upgradesPaperOrderToRealOrderAuditFact: try container.decode(
                Bool.self,
                forKey: .upgradesPaperOrderToRealOrderAuditFact
            ),
            upgradesPaperRiskToLiveRiskDecisionAuditFact: try container.decode(
                Bool.self,
                forKey: .upgradesPaperRiskToLiveRiskDecisionAuditFact
            ),
            upgradesSimulatedFillToBrokerFillAuditFact: try container.decode(
                Bool.self,
                forKey: .upgradesSimulatedFillToBrokerFillAuditFact
            ),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            executesBrokerAction: try container.decode(Bool.self, forKey: .executesBrokerAction),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            recordsBrokerFillFact: try container.decode(Bool.self, forKey: .recordsBrokerFillFact),
            recordsBrokerFillRuntime: try container.decode(Bool.self, forKey: .recordsBrokerFillRuntime),
            implementsRealOrderStateMachine: try container.decode(Bool.self, forKey: .implementsRealOrderStateMachine),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            performsBrokerReconciliation: try container.decode(Bool.self, forKey: .performsBrokerReconciliation),
            recordsAuditTrailRuntime: try container.decode(Bool.self, forKey: .recordsAuditTrailRuntime),
            submitsCancelsOrReplacesRealOrder: try container.decode(
                Bool.self,
                forKey: .submitsCancelsOrReplacesRealOrder
            ),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            exposesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .exposesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func gates(for subject: LiveAuditTrailSubject) -> [LiveAuditTrailFutureGate] {
        Self.requiredFutureGatesBySubject[subject] ?? []
    }

    public func forbidsCapability(_ capability: LiveAuditTrailForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static let requiredSubjects: [LiveAuditTrailSubject] = LiveAuditTrailSubject.allCases

    public static let requiredFutureGatesBySubject: [LiveAuditTrailSubject: [LiveAuditTrailFutureGate]] = [
        .signal: [
            .signalSourceContractDefined,
            .signalDecisionPathContractDefined,
            .signalReplayCorrelationContractDefined
        ],
        .order: [
            .orderIntentSourceContractDefined,
            .orderStateTransitionContractDefined,
            .orderCommandAuthorizationGateDefined
        ],
        .riskDecision: [
            .riskDecisionSourceContractDefined,
            .riskGateOutcomeContractDefined,
            .riskBlockedReasonContractDefined
        ],
        .fill: [
            .fillSourceContractDefined,
            .executionReportSourceGateDefined,
            .brokerFillSourceGateDefined
        ]
    ]

    public static let requiredFutureGates: [LiveAuditTrailFutureGate] = [
        .signalSourceContractDefined,
        .signalDecisionPathContractDefined,
        .signalReplayCorrelationContractDefined,
        .orderIntentSourceContractDefined,
        .orderStateTransitionContractDefined,
        .orderCommandAuthorizationGateDefined,
        .riskDecisionSourceContractDefined,
        .riskGateOutcomeContractDefined,
        .riskBlockedReasonContractDefined,
        .fillSourceContractDefined,
        .executionReportSourceGateDefined,
        .brokerFillSourceGateDefined,
        .auditTrailReplayCorrelationGateDefined,
        .readModelOnlyAuditEvidenceGateDefined
    ]

    public static let requiredForbiddenCapabilities: [LiveAuditTrailForbiddenCapability] =
        LiveAuditTrailForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .futureGateTaxonomy,
        .blockedEvidenceBoundary,
        .prBoundaryEvidence
    ]

    public static let requiredAuditTrailSourceAnchors: [String] = [
        "MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY",
        "MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY",
        "MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE",
        "MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE",
        "PaperOrderIntent",
        "PaperExecutionDecision",
        "RiskBlockerEvidence",
        "PaperSimulatedFillEvidence"
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES",
        "MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS",
        "MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION",
        "MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE",
        "MTP-90-LIVE-AUDIT-TRAIL-VALIDATION",
        "TVM-LIVE-AUDIT-INCIDENT-STOP"
    ]

    public static let deterministicFixture: LiveAuditTrailFutureGateBoundary = {
        do {
            return try LiveAuditTrailFutureGateBoundary()
        } catch {
            preconditionFailure("MTP-90 Live audit trail future gate fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        subjects: [LiveAuditTrailSubject],
        futureGates: [LiveAuditTrailFutureGate],
        forbiddenCapabilities: [LiveAuditTrailForbiddenCapability],
        allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind],
        auditTrailSourceAnchors: [String],
        validationAnchors: [String]
    ) throws {
        guard subjects == Self.requiredSubjects else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "subjects",
                expected: Self.requiredSubjects.map(\.rawValue).joined(separator: ","),
                actual: subjects.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
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
        guard auditTrailSourceAnchors == Self.requiredAuditTrailSourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "auditTrailSourceAnchors",
                expected: Self.requiredAuditTrailSourceAnchors.joined(separator: ","),
                actual: auditTrailSourceAnchors.joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isFutureOnlyAuditTrailContract: Bool,
        representsBlockedEvidenceOnly: Bool,
        upgradesSignalEvidenceToLiveAuditFact: Bool,
        upgradesPaperOrderToRealOrderAuditFact: Bool,
        upgradesPaperRiskToLiveRiskDecisionAuditFact: Bool,
        upgradesSimulatedFillToBrokerFillAuditFact: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        implementsLiveExecutionAdapter: Bool,
        executesBrokerAction: Bool,
        ingestsExecutionReport: Bool,
        recordsBrokerFillFact: Bool,
        recordsBrokerFillRuntime: Bool,
        implementsRealOrderStateMachine: Bool,
        implementsOMS: Bool,
        performsBrokerReconciliation: Bool,
        recordsAuditTrailRuntime: Bool,
        submitsCancelsOrReplacesRealOrder: Bool,
        providesLiveCommand: Bool,
        exposesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureOnlyAuditTrailContract else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureOnlyAuditTrailContract")
        }
        guard representsBlockedEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("representsBlockedEvidenceOnly")
        }

        let forbiddenFlags = [
            ("upgradesSignalEvidenceToLiveAuditFact", upgradesSignalEvidenceToLiveAuditFact),
            ("upgradesPaperOrderToRealOrderAuditFact", upgradesPaperOrderToRealOrderAuditFact),
            ("upgradesPaperRiskToLiveRiskDecisionAuditFact", upgradesPaperRiskToLiveRiskDecisionAuditFact),
            ("upgradesSimulatedFillToBrokerFillAuditFact", upgradesSimulatedFillToBrokerFillAuditFact),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("executesBrokerAction", executesBrokerAction),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("recordsBrokerFillFact", recordsBrokerFillFact),
            ("recordsBrokerFillRuntime", recordsBrokerFillRuntime),
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("implementsOMS", implementsOMS),
            ("performsBrokerReconciliation", performsBrokerReconciliation),
            ("recordsAuditTrailRuntime", recordsAuditTrailRuntime),
            ("submitsCancelsOrReplacesRealOrder", submitsCancelsOrReplacesRealOrder),
            ("providesLiveCommand", providesLiveCommand),
            ("exposesOrderLevelCommandUI", exposesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveIncidentReplayFutureGate 定义 MTP-91 的 incident replay future gates。
///
/// 这些 gate 只描述后续 Project Definition 前必须补齐的输入来源、回放范围、证据和输出合同。
/// 当前实现不得把 Event Log / Replay 升级为生产事故回放、生产恢复、broker replay、account replay
/// 或任何自动恢复系统。
public enum LiveIncidentReplayFutureGate: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case incidentInputSourceContractDefined = "incident input source contract defined"
    case auditTrailInputSourceGateDefined = "audit trail input source gate defined"
    case eventLogEvidenceInputBoundaryDefined = "Event Log evidence input boundary defined"
    case brokerStateInputForbidden = "broker state input forbidden"
    case accountStateInputForbidden = "account state input forbidden"
    case replayScopeContractDefined = "replay scope contract defined"
    case replayTimeWindowScopeDefined = "replay time window scope defined"
    case replayEvidenceSourceContractDefined = "replay evidence source contract defined"
    case deterministicReplayEvidencePathDefined = "deterministic replay evidence path defined"
    case replayOutputContractDefined = "replay output contract defined"
    case readModelOnlyReplayOutputGateDefined = "read-model-only replay output gate defined"
    case productionRecoveryOutputForbidden = "production recovery output forbidden"
}

/// LiveIncidentReplayForbiddenCapability 枚举 MTP-91 必须保持禁止的事故回放能力面。
///
/// 这些 capability 只能作为 forbidden tests 和 PR evidence 的字符串证据出现；不能被实现为
/// runtime、adapter、broker/account state reader、production recovery、auto restore、Live PRO Console
/// 或交易 UI。
public enum LiveIncidentReplayForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case incidentReplayRuntime = "incident replay runtime"
    case productionRecoveryRuntime = "production recovery runtime"
    case autoRestoreRuntime = "auto restore runtime"
    case autoRollbackRuntime = "auto rollback runtime"
    case brokerReplayRuntime = "broker replay runtime"
    case accountReplayRuntime = "account replay runtime"
    case brokerStateReader = "broker state reader"
    case realAccountStateReader = "real account state reader"
    case signedEndpoint = "signed endpoint"
    case accountEndpoint = "account endpoint"
    case listenKeyUserDataStream = "listenKey user data stream"
    case brokerAction = "broker action"
    case liveExecutionAdapter = "LiveExecutionAdapter"
    case oms = "OMS"
    case realOrderStateMachine = "real order state machine"
    case executionReportIngestion = "execution report ingestion"
    case brokerFillFact = "broker fill fact"
    case auditTrailRuntime = "audit trail runtime"
    case productionOperationsRuntime = "production operations runtime"
    case liveCommandSurface = "live command surface"
    case liveProConsole = "Live PRO Console"
    case tradingButton = "trading button"
    case currentReplayProductionRecoveryUpgrade = "current replay to production recovery upgrade"
    case eventLogBrokerReplayUpgrade = "Event Log to broker replay upgrade"
}

/// LiveIncidentReplayFutureGateBoundary 是 MTP-91 的 incident replay future gate fixture。
///
/// 该 fixture 固定 incident replay 只能是 Future / gated contract。当前 Event Log / Replay 仍是
/// deterministic evidence path；它不能读取真实 account / broker state，不能调用 signed/account/listenKey，
/// 不能执行 broker action，不能成为 production recovery、auto restore、broker replay 或 account replay。
public struct LiveIncidentReplayFutureGateBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let futureGates: [LiveIncidentReplayFutureGate]
    public let forbiddenCapabilities: [LiveIncidentReplayForbiddenCapability]
    public let allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind]
    public let incidentReplaySourceAnchors: [String]
    public let validationAnchors: [String]
    public let isFutureOnlyIncidentReplayContract: Bool
    public let representsDeterministicEvidencePathOnly: Bool
    public let treatsCurrentReplayAsProductionIncidentReplay: Bool
    public let implementsIncidentReplayRuntime: Bool
    public let readsRealAccountState: Bool
    public let readsBrokerState: Bool
    public let replaysBrokerEvents: Bool
    public let replaysAccountEvents: Bool
    public let runsProductionRecovery: Bool
    public let runsAutoRestore: Bool
    public let performsAutoRollback: Bool
    public let mutatesProductionRuntime: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let executesBrokerAction: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderStateMachine: Bool
    public let ingestsExecutionReport: Bool
    public let recordsBrokerFillFact: Bool
    public let recordsAuditTrailRuntime: Bool
    public let runsProductionOperations: Bool
    public let providesLiveCommand: Bool
    public let exposesLiveProConsole: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var incidentReplayFutureGateBoundaryHeld: Bool {
        futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && incidentReplaySourceAnchors == Self.requiredIncidentReplaySourceAnchors
            && validationAnchors == Self.requiredValidationAnchors
            && deterministicReplayEvidenceBoundaryHeld
            && forbiddenCapabilityBoundaryHeld
    }

    public var deterministicReplayEvidenceBoundaryHeld: Bool {
        isFutureOnlyIncidentReplayContract
            && representsDeterministicEvidencePathOnly
            && treatsCurrentReplayAsProductionIncidentReplay == false
            && implementsIncidentReplayRuntime == false
            && runsProductionRecovery == false
            && runsAutoRestore == false
            && performsAutoRollback == false
            && mutatesProductionRuntime == false
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        isFutureOnlyIncidentReplayContract
            && representsDeterministicEvidencePathOnly
            && readsRealAccountState == false
            && readsBrokerState == false
            && replaysBrokerEvents == false
            && replaysAccountEvents == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && executesBrokerAction == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderStateMachine == false
            && ingestsExecutionReport == false
            && recordsBrokerFillFact == false
            && recordsAuditTrailRuntime == false
            && runsProductionOperations == false
            && providesLiveCommand == false
            && exposesLiveProConsole == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-91-incident-replay-future-gates"),
        issueID: Identifier = try! Identifier("MTP-91"),
        futureGates: [LiveIncidentReplayFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveIncidentReplayForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind] = Self.allowedEvidenceKinds,
        incidentReplaySourceAnchors: [String] = Self.requiredIncidentReplaySourceAnchors,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        isFutureOnlyIncidentReplayContract: Bool = true,
        representsDeterministicEvidencePathOnly: Bool = true,
        treatsCurrentReplayAsProductionIncidentReplay: Bool = false,
        implementsIncidentReplayRuntime: Bool = false,
        readsRealAccountState: Bool = false,
        readsBrokerState: Bool = false,
        replaysBrokerEvents: Bool = false,
        replaysAccountEvents: Bool = false,
        runsProductionRecovery: Bool = false,
        runsAutoRestore: Bool = false,
        performsAutoRollback: Bool = false,
        mutatesProductionRuntime: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        executesBrokerAction: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderStateMachine: Bool = false,
        ingestsExecutionReport: Bool = false,
        recordsBrokerFillFact: Bool = false,
        recordsAuditTrailRuntime: Bool = false,
        runsProductionOperations: Bool = false,
        providesLiveCommand: Bool = false,
        exposesLiveProConsole: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            incidentReplaySourceAnchors: incidentReplaySourceAnchors,
            validationAnchors: validationAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureOnlyIncidentReplayContract: isFutureOnlyIncidentReplayContract,
            representsDeterministicEvidencePathOnly: representsDeterministicEvidencePathOnly,
            treatsCurrentReplayAsProductionIncidentReplay: treatsCurrentReplayAsProductionIncidentReplay,
            implementsIncidentReplayRuntime: implementsIncidentReplayRuntime,
            readsRealAccountState: readsRealAccountState,
            readsBrokerState: readsBrokerState,
            replaysBrokerEvents: replaysBrokerEvents,
            replaysAccountEvents: replaysAccountEvents,
            runsProductionRecovery: runsProductionRecovery,
            runsAutoRestore: runsAutoRestore,
            performsAutoRollback: performsAutoRollback,
            mutatesProductionRuntime: mutatesProductionRuntime,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            executesBrokerAction: executesBrokerAction,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            ingestsExecutionReport: ingestsExecutionReport,
            recordsBrokerFillFact: recordsBrokerFillFact,
            recordsAuditTrailRuntime: recordsAuditTrailRuntime,
            runsProductionOperations: runsProductionOperations,
            providesLiveCommand: providesLiveCommand,
            exposesLiveProConsole: exposesLiveProConsole,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.incidentReplaySourceAnchors = incidentReplaySourceAnchors
        self.validationAnchors = validationAnchors
        self.isFutureOnlyIncidentReplayContract = isFutureOnlyIncidentReplayContract
        self.representsDeterministicEvidencePathOnly = representsDeterministicEvidencePathOnly
        self.treatsCurrentReplayAsProductionIncidentReplay = treatsCurrentReplayAsProductionIncidentReplay
        self.implementsIncidentReplayRuntime = implementsIncidentReplayRuntime
        self.readsRealAccountState = readsRealAccountState
        self.readsBrokerState = readsBrokerState
        self.replaysBrokerEvents = replaysBrokerEvents
        self.replaysAccountEvents = replaysAccountEvents
        self.runsProductionRecovery = runsProductionRecovery
        self.runsAutoRestore = runsAutoRestore
        self.performsAutoRollback = performsAutoRollback
        self.mutatesProductionRuntime = mutatesProductionRuntime
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.executesBrokerAction = executesBrokerAction
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.ingestsExecutionReport = ingestsExecutionReport
        self.recordsBrokerFillFact = recordsBrokerFillFact
        self.recordsAuditTrailRuntime = recordsAuditTrailRuntime
        self.runsProductionOperations = runsProductionOperations
        self.providesLiveCommand = providesLiveCommand
        self.exposesLiveProConsole = exposesLiveProConsole
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            futureGates: try container.decode([LiveIncidentReplayFutureGate].self, forKey: .futureGates),
            forbiddenCapabilities: try container.decode(
                [LiveIncidentReplayForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveAuditIncidentStopEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            incidentReplaySourceAnchors: try container.decode([String].self, forKey: .incidentReplaySourceAnchors),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            isFutureOnlyIncidentReplayContract: try container.decode(
                Bool.self,
                forKey: .isFutureOnlyIncidentReplayContract
            ),
            representsDeterministicEvidencePathOnly: try container.decode(
                Bool.self,
                forKey: .representsDeterministicEvidencePathOnly
            ),
            treatsCurrentReplayAsProductionIncidentReplay: try container.decode(
                Bool.self,
                forKey: .treatsCurrentReplayAsProductionIncidentReplay
            ),
            implementsIncidentReplayRuntime: try container.decode(
                Bool.self,
                forKey: .implementsIncidentReplayRuntime
            ),
            readsRealAccountState: try container.decode(Bool.self, forKey: .readsRealAccountState),
            readsBrokerState: try container.decode(Bool.self, forKey: .readsBrokerState),
            replaysBrokerEvents: try container.decode(Bool.self, forKey: .replaysBrokerEvents),
            replaysAccountEvents: try container.decode(Bool.self, forKey: .replaysAccountEvents),
            runsProductionRecovery: try container.decode(Bool.self, forKey: .runsProductionRecovery),
            runsAutoRestore: try container.decode(Bool.self, forKey: .runsAutoRestore),
            performsAutoRollback: try container.decode(Bool.self, forKey: .performsAutoRollback),
            mutatesProductionRuntime: try container.decode(Bool.self, forKey: .mutatesProductionRuntime),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            executesBrokerAction: try container.decode(Bool.self, forKey: .executesBrokerAction),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderStateMachine: try container.decode(Bool.self, forKey: .implementsRealOrderStateMachine),
            ingestsExecutionReport: try container.decode(Bool.self, forKey: .ingestsExecutionReport),
            recordsBrokerFillFact: try container.decode(Bool.self, forKey: .recordsBrokerFillFact),
            recordsAuditTrailRuntime: try container.decode(Bool.self, forKey: .recordsAuditTrailRuntime),
            runsProductionOperations: try container.decode(Bool.self, forKey: .runsProductionOperations),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            exposesLiveProConsole: try container.decode(Bool.self, forKey: .exposesLiveProConsole),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func forbidsCapability(_ capability: LiveIncidentReplayForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static let requiredFutureGates: [LiveIncidentReplayFutureGate] =
        LiveIncidentReplayFutureGate.allCases

    public static let requiredForbiddenCapabilities: [LiveIncidentReplayForbiddenCapability] =
        LiveIncidentReplayForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .futureGateTaxonomy,
        .blockedEvidenceBoundary,
        .prBoundaryEvidence
    ]

    public static let requiredIncidentReplaySourceAnchors: [String] = [
        "MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY",
        "MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES",
        "MTP-90-LIVE-AUDIT-TRAIL-VALIDATION",
        "Event Log",
        "Replay",
        "TVM-LIVE-AUDIT-INCIDENT-STOP"
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-91-INCIDENT-REPLAY-FUTURE-GATES",
        "MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES",
        "MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES",
        "MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS",
        "MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY",
        "MTP-91-INCIDENT-REPLAY-VALIDATION",
        "TVM-LIVE-AUDIT-INCIDENT-STOP"
    ]

    public static let deterministicFixture: LiveIncidentReplayFutureGateBoundary = {
        do {
            return try LiveIncidentReplayFutureGateBoundary()
        } catch {
            preconditionFailure("MTP-91 incident replay future gate fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        futureGates: [LiveIncidentReplayFutureGate],
        forbiddenCapabilities: [LiveIncidentReplayForbiddenCapability],
        allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind],
        incidentReplaySourceAnchors: [String],
        validationAnchors: [String]
    ) throws {
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
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
        guard incidentReplaySourceAnchors == Self.requiredIncidentReplaySourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "incidentReplaySourceAnchors",
                expected: Self.requiredIncidentReplaySourceAnchors.joined(separator: ","),
                actual: incidentReplaySourceAnchors.joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isFutureOnlyIncidentReplayContract: Bool,
        representsDeterministicEvidencePathOnly: Bool,
        treatsCurrentReplayAsProductionIncidentReplay: Bool,
        implementsIncidentReplayRuntime: Bool,
        readsRealAccountState: Bool,
        readsBrokerState: Bool,
        replaysBrokerEvents: Bool,
        replaysAccountEvents: Bool,
        runsProductionRecovery: Bool,
        runsAutoRestore: Bool,
        performsAutoRollback: Bool,
        mutatesProductionRuntime: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        executesBrokerAction: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderStateMachine: Bool,
        ingestsExecutionReport: Bool,
        recordsBrokerFillFact: Bool,
        recordsAuditTrailRuntime: Bool,
        runsProductionOperations: Bool,
        providesLiveCommand: Bool,
        exposesLiveProConsole: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureOnlyIncidentReplayContract else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureOnlyIncidentReplayContract")
        }
        guard representsDeterministicEvidencePathOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("representsDeterministicEvidencePathOnly")
        }

        let forbiddenFlags = [
            ("treatsCurrentReplayAsProductionIncidentReplay", treatsCurrentReplayAsProductionIncidentReplay),
            ("implementsIncidentReplayRuntime", implementsIncidentReplayRuntime),
            ("readsRealAccountState", readsRealAccountState),
            ("readsBrokerState", readsBrokerState),
            ("replaysBrokerEvents", replaysBrokerEvents),
            ("replaysAccountEvents", replaysAccountEvents),
            ("runsProductionRecovery", runsProductionRecovery),
            ("runsAutoRestore", runsAutoRestore),
            ("performsAutoRollback", performsAutoRollback),
            ("mutatesProductionRuntime", mutatesProductionRuntime),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("executesBrokerAction", executesBrokerAction),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("ingestsExecutionReport", ingestsExecutionReport),
            ("recordsBrokerFillFact", recordsBrokerFillFact),
            ("recordsAuditTrailRuntime", recordsAuditTrailRuntime),
            ("runsProductionOperations", runsProductionOperations),
            ("providesLiveCommand", providesLiveCommand),
            ("exposesLiveProConsole", exposesLiveProConsole),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}

/// LiveAuditIncidentStopTerminologyBoundary 是 MTP-89 的 Future-only terminology / taxonomy fixture。
///
/// 该 fixture 只把 live audit、audit trail、incident、incident replay、stop control、
/// emergency stop、shutdown、restore、future gates 和 forbidden capability baseline 固定为可测试合同。
/// 所有 secret、signed/account/listenKey、broker action、LiveExecutionAdapter、OMS、真实订单、
/// incident replay runtime、stop / shutdown / restore command、production operations、Live PRO Console、
/// live command 和交易按钮旗标必须保持关闭。
public struct LiveAuditIncidentStopTerminologyBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let terms: [LiveAuditIncidentStopTerm]
    public let taxonomy: [FutureAuditIncidentStopTaxonomyTerm]
    public let futureGates: [LiveAuditIncidentStopFutureGate]
    public let forbiddenCapabilities: [LiveAuditIncidentStopForbiddenCapability]
    public let allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind]
    public let validationAnchors: [String]
    public let blockedEvidenceSourceAnchors: [String]
    public let isFutureOnlyTerminology: Bool
    public let representsBlockedEvidenceOnly: Bool
    public let readsAPIKey: Bool
    public let storesSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let executesBrokerAction: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderStateMachine: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let consumesExecutionReport: Bool
    public let recordsBrokerFill: Bool
    public let performsReconciliation: Bool
    public let recordsAuditTrailRuntime: Bool
    public let providesIncidentReplayRuntime: Bool
    public let runsStopControlRuntime: Bool
    public let runsEmergencyStopCommand: Bool
    public let runsShutdownCommand: Bool
    public let runsRestoreCommand: Bool
    public let runsProductionOperations: Bool
    public let exposesLiveProConsole: Bool
    public let treatsWorkbenchAsLiveProConsole: Bool
    public let treatsDashboardAsLiveProConsole: Bool
    public let providesLiveCommand: Bool
    public let exposesOrderLevelCommandUI: Bool
    public let providesTradingButton: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var terminologyBoundaryHeld: Bool {
        terms == Self.requiredTerms
            && taxonomy == Self.requiredTaxonomy
            && futureGates == Self.requiredFutureGates
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && validationAnchors == Self.requiredValidationAnchors
            && blockedEvidenceSourceAnchors == Self.requiredBlockedEvidenceSourceAnchors
            && forbiddenCapabilityBoundaryHeld
            && productSurfaceBoundaryHeld
    }

    public var taxonomyBoundaryHeld: Bool {
        taxonomy == Self.requiredTaxonomy
            && isFutureOnlyTerminology
            && representsBlockedEvidenceOnly
            && providesIncidentReplayRuntime == false
            && runsStopControlRuntime == false
            && runsEmergencyStopCommand == false
            && runsShutdownCommand == false
            && runsRestoreCommand == false
            && runsProductionOperations == false
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        isFutureOnlyTerminology
            && representsBlockedEvidenceOnly
            && readsAPIKey == false
            && storesSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && executesBrokerAction == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderStateMachine == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && consumesExecutionReport == false
            && recordsBrokerFill == false
            && performsReconciliation == false
            && recordsAuditTrailRuntime == false
            && providesIncidentReplayRuntime == false
            && runsStopControlRuntime == false
            && runsEmergencyStopCommand == false
            && runsShutdownCommand == false
            && runsRestoreCommand == false
            && runsProductionOperations == false
            && providesLiveCommand == false
            && exposesOrderLevelCommandUI == false
            && providesTradingButton == false
            && requiredValidationDependsOnNetwork == false
    }

    public var productSurfaceBoundaryHeld: Bool {
        exposesLiveProConsole == false
            && treatsWorkbenchAsLiveProConsole == false
            && treatsDashboardAsLiveProConsole == false
            && providesLiveCommand == false
            && exposesOrderLevelCommandUI == false
            && providesTradingButton == false
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-89-live-audit-incident-stop-terminology"),
        issueID: Identifier = try! Identifier("MTP-89"),
        terms: [LiveAuditIncidentStopTerm] = Self.requiredTerms,
        taxonomy: [FutureAuditIncidentStopTaxonomyTerm] = Self.requiredTaxonomy,
        futureGates: [LiveAuditIncidentStopFutureGate] = Self.requiredFutureGates,
        forbiddenCapabilities: [LiveAuditIncidentStopForbiddenCapability] = Self.requiredForbiddenCapabilities,
        allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind] = Self.allowedEvidenceKinds,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        blockedEvidenceSourceAnchors: [String] = Self.requiredBlockedEvidenceSourceAnchors,
        isFutureOnlyTerminology: Bool = true,
        representsBlockedEvidenceOnly: Bool = true,
        readsAPIKey: Bool = false,
        storesSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        executesBrokerAction: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderStateMachine: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        consumesExecutionReport: Bool = false,
        recordsBrokerFill: Bool = false,
        performsReconciliation: Bool = false,
        recordsAuditTrailRuntime: Bool = false,
        providesIncidentReplayRuntime: Bool = false,
        runsStopControlRuntime: Bool = false,
        runsEmergencyStopCommand: Bool = false,
        runsShutdownCommand: Bool = false,
        runsRestoreCommand: Bool = false,
        runsProductionOperations: Bool = false,
        exposesLiveProConsole: Bool = false,
        treatsWorkbenchAsLiveProConsole: Bool = false,
        treatsDashboardAsLiveProConsole: Bool = false,
        providesLiveCommand: Bool = false,
        exposesOrderLevelCommandUI: Bool = false,
        providesTradingButton: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        try Self.validate(
            terms: terms,
            taxonomy: taxonomy,
            futureGates: futureGates,
            forbiddenCapabilities: forbiddenCapabilities,
            allowedEvidenceKinds: allowedEvidenceKinds,
            validationAnchors: validationAnchors,
            blockedEvidenceSourceAnchors: blockedEvidenceSourceAnchors
        )
        try Self.validateForbiddenFlags(
            isFutureOnlyTerminology: isFutureOnlyTerminology,
            representsBlockedEvidenceOnly: representsBlockedEvidenceOnly,
            readsAPIKey: readsAPIKey,
            storesSecret: storesSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            executesBrokerAction: executesBrokerAction,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderStateMachine: implementsRealOrderStateMachine,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            consumesExecutionReport: consumesExecutionReport,
            recordsBrokerFill: recordsBrokerFill,
            performsReconciliation: performsReconciliation,
            recordsAuditTrailRuntime: recordsAuditTrailRuntime,
            providesIncidentReplayRuntime: providesIncidentReplayRuntime,
            runsStopControlRuntime: runsStopControlRuntime,
            runsEmergencyStopCommand: runsEmergencyStopCommand,
            runsShutdownCommand: runsShutdownCommand,
            runsRestoreCommand: runsRestoreCommand,
            runsProductionOperations: runsProductionOperations,
            exposesLiveProConsole: exposesLiveProConsole,
            treatsWorkbenchAsLiveProConsole: treatsWorkbenchAsLiveProConsole,
            treatsDashboardAsLiveProConsole: treatsDashboardAsLiveProConsole,
            providesLiveCommand: providesLiveCommand,
            exposesOrderLevelCommandUI: exposesOrderLevelCommandUI,
            providesTradingButton: providesTradingButton,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.terms = terms
        self.taxonomy = taxonomy
        self.futureGates = futureGates
        self.forbiddenCapabilities = forbiddenCapabilities
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.validationAnchors = validationAnchors
        self.blockedEvidenceSourceAnchors = blockedEvidenceSourceAnchors
        self.isFutureOnlyTerminology = isFutureOnlyTerminology
        self.representsBlockedEvidenceOnly = representsBlockedEvidenceOnly
        self.readsAPIKey = readsAPIKey
        self.storesSecret = storesSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.executesBrokerAction = executesBrokerAction
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderStateMachine = implementsRealOrderStateMachine
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.consumesExecutionReport = consumesExecutionReport
        self.recordsBrokerFill = recordsBrokerFill
        self.performsReconciliation = performsReconciliation
        self.recordsAuditTrailRuntime = recordsAuditTrailRuntime
        self.providesIncidentReplayRuntime = providesIncidentReplayRuntime
        self.runsStopControlRuntime = runsStopControlRuntime
        self.runsEmergencyStopCommand = runsEmergencyStopCommand
        self.runsShutdownCommand = runsShutdownCommand
        self.runsRestoreCommand = runsRestoreCommand
        self.runsProductionOperations = runsProductionOperations
        self.exposesLiveProConsole = exposesLiveProConsole
        self.treatsWorkbenchAsLiveProConsole = treatsWorkbenchAsLiveProConsole
        self.treatsDashboardAsLiveProConsole = treatsDashboardAsLiveProConsole
        self.providesLiveCommand = providesLiveCommand
        self.exposesOrderLevelCommandUI = exposesOrderLevelCommandUI
        self.providesTradingButton = providesTradingButton
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            terms: try container.decode([LiveAuditIncidentStopTerm].self, forKey: .terms),
            taxonomy: try container.decode([FutureAuditIncidentStopTaxonomyTerm].self, forKey: .taxonomy),
            futureGates: try container.decode([LiveAuditIncidentStopFutureGate].self, forKey: .futureGates),
            forbiddenCapabilities: try container.decode(
                [LiveAuditIncidentStopForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            allowedEvidenceKinds: try container.decode(
                [LiveAuditIncidentStopEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            blockedEvidenceSourceAnchors: try container.decode(
                [String].self,
                forKey: .blockedEvidenceSourceAnchors
            ),
            isFutureOnlyTerminology: try container.decode(Bool.self, forKey: .isFutureOnlyTerminology),
            representsBlockedEvidenceOnly: try container.decode(Bool.self, forKey: .representsBlockedEvidenceOnly),
            readsAPIKey: try container.decode(Bool.self, forKey: .readsAPIKey),
            storesSecret: try container.decode(Bool.self, forKey: .storesSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            executesBrokerAction: try container.decode(Bool.self, forKey: .executesBrokerAction),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderStateMachine: try container.decode(Bool.self, forKey: .implementsRealOrderStateMachine),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            consumesExecutionReport: try container.decode(Bool.self, forKey: .consumesExecutionReport),
            recordsBrokerFill: try container.decode(Bool.self, forKey: .recordsBrokerFill),
            performsReconciliation: try container.decode(Bool.self, forKey: .performsReconciliation),
            recordsAuditTrailRuntime: try container.decode(Bool.self, forKey: .recordsAuditTrailRuntime),
            providesIncidentReplayRuntime: try container.decode(Bool.self, forKey: .providesIncidentReplayRuntime),
            runsStopControlRuntime: try container.decode(Bool.self, forKey: .runsStopControlRuntime),
            runsEmergencyStopCommand: try container.decode(Bool.self, forKey: .runsEmergencyStopCommand),
            runsShutdownCommand: try container.decode(Bool.self, forKey: .runsShutdownCommand),
            runsRestoreCommand: try container.decode(Bool.self, forKey: .runsRestoreCommand),
            runsProductionOperations: try container.decode(Bool.self, forKey: .runsProductionOperations),
            exposesLiveProConsole: try container.decode(Bool.self, forKey: .exposesLiveProConsole),
            treatsWorkbenchAsLiveProConsole: try container.decode(
                Bool.self,
                forKey: .treatsWorkbenchAsLiveProConsole
            ),
            treatsDashboardAsLiveProConsole: try container.decode(
                Bool.self,
                forKey: .treatsDashboardAsLiveProConsole
            ),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            exposesOrderLevelCommandUI: try container.decode(Bool.self, forKey: .exposesOrderLevelCommandUI),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public func forbidsCapability(_ capability: LiveAuditIncidentStopForbiddenCapability) -> Bool {
        forbiddenCapabilities.contains(capability)
    }

    public static let requiredTerms: [LiveAuditIncidentStopTerm] = LiveAuditIncidentStopTerm.allCases

    public static let requiredTaxonomy: [FutureAuditIncidentStopTaxonomyTerm] =
        FutureAuditIncidentStopTaxonomyTerm.allCases

    public static let requiredFutureGates: [LiveAuditIncidentStopFutureGate] = [
        .humanLiveAuditIncidentStopDecision,
        .liveTradingFoundationBoundarySatisfied,
        .liveExecutionControlBoundarySatisfied,
        .liveRiskGateBoundarySatisfied,
        .auditTrailContractDefined,
        .incidentReplayContractDefined,
        .stopControlContractDefined,
        .emergencyStopShutdownRestoreContractDefined,
        .productionOperationsContractDefined,
        .readModelOnlyBlockedEvidenceDefined,
        .dashboardReportTimelineEvidenceBoundaryDefined,
        .liveProConsoleIndependentProjectDefinition
    ]

    public static let requiredForbiddenCapabilities: [LiveAuditIncidentStopForbiddenCapability] =
        LiveAuditIncidentStopForbiddenCapability.allCases

    public static let allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixCandidate,
        .validationPlanAnchor,
        .deterministicForbiddenTest,
        .futureGateTaxonomy,
        .blockedEvidenceBoundary,
        .prBoundaryEvidence
    ]

    public static let requiredValidationAnchors: [String] = [
        "MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY",
        "MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY",
        "MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES",
        "MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND",
        "MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE",
        "MTP-89-LIVE-AUDIT-INCIDENT-STOP-VALIDATION",
        "TVM-LIVE-AUDIT-INCIDENT-STOP"
    ]

    public static let requiredBlockedEvidenceSourceAnchors: [String] = [
        "TVM-LIVE-TRADING-FOUNDATION",
        "TVM-LIVE-EXECUTION-CONTROL",
        "TVM-LIVE-RISK-GATE",
        "MTP-65-LIVE-BLOCKED-EVIDENCE",
        "MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE",
        "MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE",
        "MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY"
    ]

    public static let deterministicFixture: LiveAuditIncidentStopTerminologyBoundary = {
        do {
            return try LiveAuditIncidentStopTerminologyBoundary()
        } catch {
            preconditionFailure("MTP-89 Live audit / incident / stop terminology fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        terms: [LiveAuditIncidentStopTerm],
        taxonomy: [FutureAuditIncidentStopTaxonomyTerm],
        futureGates: [LiveAuditIncidentStopFutureGate],
        forbiddenCapabilities: [LiveAuditIncidentStopForbiddenCapability],
        allowedEvidenceKinds: [LiveAuditIncidentStopEvidenceKind],
        validationAnchors: [String],
        blockedEvidenceSourceAnchors: [String]
    ) throws {
        guard terms == Self.requiredTerms else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "terms",
                expected: Self.requiredTerms.map(\.rawValue).joined(separator: ","),
                actual: terms.map(\.rawValue).joined(separator: ",")
            )
        }
        guard taxonomy == Self.requiredTaxonomy else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "taxonomy",
                expected: Self.requiredTaxonomy.map(\.rawValue).joined(separator: ","),
                actual: taxonomy.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
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
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard blockedEvidenceSourceAnchors == Self.requiredBlockedEvidenceSourceAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "blockedEvidenceSourceAnchors",
                expected: Self.requiredBlockedEvidenceSourceAnchors.joined(separator: ","),
                actual: blockedEvidenceSourceAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        isFutureOnlyTerminology: Bool,
        representsBlockedEvidenceOnly: Bool,
        readsAPIKey: Bool,
        storesSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        executesBrokerAction: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderStateMachine: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        consumesExecutionReport: Bool,
        recordsBrokerFill: Bool,
        performsReconciliation: Bool,
        recordsAuditTrailRuntime: Bool,
        providesIncidentReplayRuntime: Bool,
        runsStopControlRuntime: Bool,
        runsEmergencyStopCommand: Bool,
        runsShutdownCommand: Bool,
        runsRestoreCommand: Bool,
        runsProductionOperations: Bool,
        exposesLiveProConsole: Bool,
        treatsWorkbenchAsLiveProConsole: Bool,
        treatsDashboardAsLiveProConsole: Bool,
        providesLiveCommand: Bool,
        exposesOrderLevelCommandUI: Bool,
        providesTradingButton: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard isFutureOnlyTerminology else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureOnlyTerminology")
        }
        guard representsBlockedEvidenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("representsBlockedEvidenceOnly")
        }

        let forbiddenFlags = [
            ("readsAPIKey", readsAPIKey),
            ("storesSecret", storesSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("executesBrokerAction", executesBrokerAction),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderStateMachine", implementsRealOrderStateMachine),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("consumesExecutionReport", consumesExecutionReport),
            ("recordsBrokerFill", recordsBrokerFill),
            ("performsReconciliation", performsReconciliation),
            ("recordsAuditTrailRuntime", recordsAuditTrailRuntime),
            ("providesIncidentReplayRuntime", providesIncidentReplayRuntime),
            ("runsStopControlRuntime", runsStopControlRuntime),
            ("runsEmergencyStopCommand", runsEmergencyStopCommand),
            ("runsShutdownCommand", runsShutdownCommand),
            ("runsRestoreCommand", runsRestoreCommand),
            ("runsProductionOperations", runsProductionOperations),
            ("exposesLiveProConsole", exposesLiveProConsole),
            ("treatsWorkbenchAsLiveProConsole", treatsWorkbenchAsLiveProConsole),
            ("treatsDashboardAsLiveProConsole", treatsDashboardAsLiveProConsole),
            ("providesLiveCommand", providesLiveCommand),
            ("exposesOrderLevelCommandUI", exposesOrderLevelCommandUI),
            ("providesTradingButton", providesTradingButton),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}
