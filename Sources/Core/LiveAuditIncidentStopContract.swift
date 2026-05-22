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
