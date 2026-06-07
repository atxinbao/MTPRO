import DomainModel
import Foundation

/// ProductionCutoverIncidentReadinessState 固定 GH-507 incident / rollback / no-trade gate 的状态。
///
/// 这些 state 只用于 production cutover 前的 readiness evidence；它们不实现 emergency stop runtime、
/// shutdown / restore runtime、production operations 或任何真实订单命令。
public enum ProductionCutoverIncidentReadinessState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case incidentStop = "incident stop"
    case rollbackReady = "rollback ready"
    case noTrade = "no-trade"
    case productionBlocked = "production blocked"
    case dryRunOnly = "dry-run-only"
    case futureRecoveryGate = "future recovery gate"
}

/// ProductionCutoverIncidentForbiddenCapability 枚举 GH-507 必须继续关闭的运行时能力。
public enum ProductionCutoverIncidentForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case emergencyStopRuntime = "emergency stop runtime"
    case shutdownRuntime = "shutdown runtime"
    case restoreRuntime = "restore runtime"
    case productionOperationsRuntime = "production operations runtime"
    case liveCommandSurface = "live command surface"
    case tradingButton = "trading button"
    case orderForm = "order form"
    case brokerConnection = "broker connection"
    case brokerFillParser = "broker fill parser"
    case reconciliationRuntime = "reconciliation runtime"
    case noTradeBypass = "no-trade bypass"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case realSubmitCancelReplace = "real submit / cancel / replace"
}

/// ProductionCutoverIncidentRollbackEvidence 是 GH-507 rollback readiness checklist row。
///
/// Row 只能描述 incident stop、rollback 和 no-trade 的 evidence。任何 runtime command、broker
/// connection、real order action 或 no-trade bypass 都会被拒绝。
public struct ProductionCutoverIncidentRollbackEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let state: ProductionCutoverIncidentReadinessState
    public let expectedEvidence: String
    public let blockedReason: String
    public let noTradeStateHasPriority: Bool
    public let runtimeCommandImplemented: Bool
    public let connectsBroker: Bool
    public let submitsRealOrder: Bool
    public let bypassesNoTradeState: Bool

    public init(
        evidenceID: Identifier,
        state: ProductionCutoverIncidentReadinessState,
        expectedEvidence: String,
        blockedReason: String,
        noTradeStateHasPriority: Bool = true,
        runtimeCommandImplemented: Bool = false,
        connectsBroker: Bool = false,
        submitsRealOrder: Bool = false,
        bypassesNoTradeState: Bool = false
    ) throws {
        guard expectedEvidence.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "expectedEvidence",
                expected: "non-empty incident rollback evidence",
                actual: "empty"
            )
        }
        guard blockedReason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "blockedReason",
                expected: "non-empty incident rollback blocked reason",
                actual: "empty"
            )
        }
        guard noTradeStateHasPriority else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "noTradeStateHasPriority",
                expected: "true",
                actual: "false"
            )
        }
        for (field, value) in [
            ("runtimeCommandImplemented", runtimeCommandImplemented),
            ("connectsBroker", connectsBroker),
            ("submitsRealOrder", submitsRealOrder),
            ("bypassesNoTradeState", bypassesNoTradeState)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }

        self.evidenceID = evidenceID
        self.state = state
        self.expectedEvidence = expectedEvidence
        self.blockedReason = blockedReason
        self.noTradeStateHasPriority = noTradeStateHasPriority
        self.runtimeCommandImplemented = runtimeCommandImplemented
        self.connectsBroker = connectsBroker
        self.submitsRealOrder = submitsRealOrder
        self.bypassesNoTradeState = bypassesNoTradeState
    }
}

/// ProductionCutoverIncidentRollbackNoTradeGate 是 GH-507 的 incident / rollback / no-trade readiness gate。
///
/// Gate 固定 production cutover 前的事故阻断、回滚准备和 no-trade 优先级。它不是 emergency stop
/// runtime，不实现 shutdown / restore、不连接 broker、不解析 fill / reconciliation，也不提交真实订单。
public struct ProductionCutoverIncidentRollbackNoTradeGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let projectName: String
    public let canonicalQueueRange: String
    public let states: [ProductionCutoverIncidentReadinessState]
    public let forbiddenCapabilities: [ProductionCutoverIncidentForbiddenCapability]
    public let rollbackChecklist: [ProductionCutoverIncidentRollbackEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let manualApprovalGateRequired: Bool
    public let productionNoDefaultTradingRequired: Bool
    public let rollbackChecklistRequired: Bool
    public let noTradeStatePriorityRequired: Bool
    public let productionBlockedDryRunDefault: Bool
    public let implementsEmergencyStopRuntime: Bool
    public let implementsShutdownRuntime: Bool
    public let implementsRestoreRuntime: Bool
    public let implementsProductionOperationsRuntime: Bool
    public let exposesLiveCommandSurface: Bool
    public let exposesTradingButton: Bool
    public let exposesOrderForm: Bool
    public let connectsBroker: Bool
    public let parsesBrokerFill: Bool
    public let performsReconciliation: Bool
    public let bypassesNoTradeState: Bool
    public let productionTradingEnabledByDefault: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var gateHeld: Bool {
        issueID.rawValue == "GH-507"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-506"]
            && projectName == ProductionCutoverCredentialSecretPolicyGate.requiredProjectName
            && canonicalQueueRange == "GH-503..GH-510"
            && states == ProductionCutoverIncidentReadinessState.allCases
            && forbiddenCapabilities == ProductionCutoverIncidentForbiddenCapability.allCases
            && rollbackChecklist == Self.requiredRollbackChecklist
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands
            && manualApprovalGateRequired
            && productionNoDefaultTradingRequired
            && rollbackChecklistRequired
            && noTradeStatePriorityRequired
            && productionBlockedDryRunDefault
            && allForbiddenFlagsRemainClosed
    }

    public var rollbackChecklistCoverageHeld: Bool {
        Set(rollbackChecklist.map(\.state)) == Set(ProductionCutoverIncidentReadinessState.allCases)
            && rollbackChecklist.allSatisfy(\.noTradeStateHasPriority)
            && rollbackChecklist.allSatisfy { $0.runtimeCommandImplemented == false }
            && rollbackChecklist.allSatisfy { $0.bypassesNoTradeState == false }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            implementsEmergencyStopRuntime,
            implementsShutdownRuntime,
            implementsRestoreRuntime,
            implementsProductionOperationsRuntime,
            exposesLiveCommandSurface,
            exposesTradingButton,
            exposesOrderForm,
            connectsBroker,
            parsesBrokerFill,
            performsReconciliation,
            bypassesNoTradeState,
            productionTradingEnabledByDefault,
            submitsRealOrder,
            cancelsRealOrder,
            replacesRealOrder
        ].allSatisfy { $0 == false }
    }

    public init(
        gateID: Identifier = Identifier.constant("gh-507-production-cutover-incident-rollback-no-trade-gate"),
        issueID: Identifier = Identifier.constant("GH-507"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-506")],
        projectName: String = ProductionCutoverCredentialSecretPolicyGate.requiredProjectName,
        canonicalQueueRange: String = "GH-503..GH-510",
        states: [ProductionCutoverIncidentReadinessState] = ProductionCutoverIncidentReadinessState.allCases,
        forbiddenCapabilities: [ProductionCutoverIncidentForbiddenCapability] =
            ProductionCutoverIncidentForbiddenCapability.allCases,
        rollbackChecklist: [ProductionCutoverIncidentRollbackEvidence] = Self.requiredRollbackChecklist,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands,
        manualApprovalGateRequired: Bool = true,
        productionNoDefaultTradingRequired: Bool = true,
        rollbackChecklistRequired: Bool = true,
        noTradeStatePriorityRequired: Bool = true,
        productionBlockedDryRunDefault: Bool = true,
        implementsEmergencyStopRuntime: Bool = false,
        implementsShutdownRuntime: Bool = false,
        implementsRestoreRuntime: Bool = false,
        implementsProductionOperationsRuntime: Bool = false,
        exposesLiveCommandSurface: Bool = false,
        exposesTradingButton: Bool = false,
        exposesOrderForm: Bool = false,
        connectsBroker: Bool = false,
        parsesBrokerFill: Bool = false,
        performsReconciliation: Bool = false,
        bypassesNoTradeState: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false
    ) throws {
        try Self.validateRequired(
            upstreamIssueIDs: upstreamIssueIDs,
            states: states,
            forbiddenCapabilities: forbiddenCapabilities,
            rollbackChecklist: rollbackChecklist,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredFlags(
            manualApprovalGateRequired: manualApprovalGateRequired,
            productionNoDefaultTradingRequired: productionNoDefaultTradingRequired,
            rollbackChecklistRequired: rollbackChecklistRequired,
            noTradeStatePriorityRequired: noTradeStatePriorityRequired,
            productionBlockedDryRunDefault: productionBlockedDryRunDefault
        )
        try Self.validateForbiddenFlags(
            implementsEmergencyStopRuntime: implementsEmergencyStopRuntime,
            implementsShutdownRuntime: implementsShutdownRuntime,
            implementsRestoreRuntime: implementsRestoreRuntime,
            implementsProductionOperationsRuntime: implementsProductionOperationsRuntime,
            exposesLiveCommandSurface: exposesLiveCommandSurface,
            exposesTradingButton: exposesTradingButton,
            exposesOrderForm: exposesOrderForm,
            connectsBroker: connectsBroker,
            parsesBrokerFill: parsesBrokerFill,
            performsReconciliation: performsReconciliation,
            bypassesNoTradeState: bypassesNoTradeState,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder
        )

        self.gateID = gateID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.projectName = projectName
        self.canonicalQueueRange = canonicalQueueRange
        self.states = states
        self.forbiddenCapabilities = forbiddenCapabilities
        self.rollbackChecklist = rollbackChecklist
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.manualApprovalGateRequired = manualApprovalGateRequired
        self.productionNoDefaultTradingRequired = productionNoDefaultTradingRequired
        self.rollbackChecklistRequired = rollbackChecklistRequired
        self.noTradeStatePriorityRequired = noTradeStatePriorityRequired
        self.productionBlockedDryRunDefault = productionBlockedDryRunDefault
        self.implementsEmergencyStopRuntime = implementsEmergencyStopRuntime
        self.implementsShutdownRuntime = implementsShutdownRuntime
        self.implementsRestoreRuntime = implementsRestoreRuntime
        self.implementsProductionOperationsRuntime = implementsProductionOperationsRuntime
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
        self.exposesTradingButton = exposesTradingButton
        self.exposesOrderForm = exposesOrderForm
        self.connectsBroker = connectsBroker
        self.parsesBrokerFill = parsesBrokerFill
        self.performsReconciliation = performsReconciliation
        self.bypassesNoTradeState = bypassesNoTradeState
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
    }

    public static func deterministicFixture() throws -> ProductionCutoverIncidentRollbackNoTradeGate {
        try ProductionCutoverIncidentRollbackNoTradeGate()
    }

    public static let requiredValidationAnchors = [
        "GH-507-INCIDENT-STOP-ROLLBACK-NO-TRADE-GATE",
        "GH-507-ROLLBACK-READINESS-CHECKLIST",
        "GH-507-NO-TRADE-STATE-PRIORITY",
        "GH-507-PRODUCTION-NO-DEFAULT-TRADING-EVIDENCE",
        "GH-507-NO-PRODUCTION-RUNTIME-COMMAND"
    ]

    public static let requiredRollbackChecklist: [ProductionCutoverIncidentRollbackEvidence] = {
        do {
            return [
                try ProductionCutoverIncidentRollbackEvidence(
                    evidenceID: Identifier.constant("gh-507-incident-stop-evidence"),
                    state: .incidentStop,
                    expectedEvidence: "incident stop remains readiness evidence",
                    blockedReason: "incident stop does not implement emergency stop runtime"
                ),
                try ProductionCutoverIncidentRollbackEvidence(
                    evidenceID: Identifier.constant("gh-507-rollback-ready-evidence"),
                    state: .rollbackReady,
                    expectedEvidence: "rollback checklist remains explicit and auditable",
                    blockedReason: "rollback readiness does not implement shutdown or restore runtime"
                ),
                try ProductionCutoverIncidentRollbackEvidence(
                    evidenceID: Identifier.constant("gh-507-no-trade-priority-evidence"),
                    state: .noTrade,
                    expectedEvidence: "no-trade state has priority over future production command",
                    blockedReason: "production command remains blocked while no-trade is active"
                ),
                try ProductionCutoverIncidentRollbackEvidence(
                    evidenceID: Identifier.constant("gh-507-production-blocked-evidence"),
                    state: .productionBlocked,
                    expectedEvidence: "production default remains no-trading and blocked",
                    blockedReason: "production trading remains disabled before cutover"
                ),
                try ProductionCutoverIncidentRollbackEvidence(
                    evidenceID: Identifier.constant("gh-507-dry-run-only-evidence"),
                    state: .dryRunOnly,
                    expectedEvidence: "dry-run evidence cannot become production operations",
                    blockedReason: "dry-run cannot bypass no-trade state"
                ),
                try ProductionCutoverIncidentRollbackEvidence(
                    evidenceID: Identifier.constant("gh-507-future-recovery-gate-evidence"),
                    state: .futureRecoveryGate,
                    expectedEvidence: "future recovery requires a dedicated authorization gate",
                    blockedReason: "GH-507 cannot authorize recovery runtime"
                )
            ]
        } catch {
            preconditionFailure("GH-507 deterministic incident rollback evidence must be valid: \(error)")
        }
    }()
}

private extension ProductionCutoverIncidentRollbackNoTradeGate {
    static func validateRequired(
        upstreamIssueIDs: [Identifier],
        states: [ProductionCutoverIncidentReadinessState],
        forbiddenCapabilities: [ProductionCutoverIncidentForbiddenCapability],
        rollbackChecklist: [ProductionCutoverIncidentRollbackEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "upstreamIssueIDs",
                upstreamIssueIDs.map(\.rawValue) == ["GH-506"],
                "GH-506",
                upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            (
                "states",
                states == ProductionCutoverIncidentReadinessState.allCases,
                ProductionCutoverIncidentReadinessState.allCases.map(\.rawValue).joined(separator: ","),
                states.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == ProductionCutoverIncidentForbiddenCapability.allCases,
                ProductionCutoverIncidentForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "rollbackChecklist",
                rollbackChecklist == requiredRollbackChecklist,
                "GH-507 required incident rollback checklist",
                rollbackChecklist.map(\.state.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands,
                ProductionCutoverCredentialSecretPolicyGate.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredFlags(
        manualApprovalGateRequired: Bool,
        productionNoDefaultTradingRequired: Bool,
        rollbackChecklistRequired: Bool,
        noTradeStatePriorityRequired: Bool,
        productionBlockedDryRunDefault: Bool
    ) throws {
        for (field, value) in [
            ("manualApprovalGateRequired", manualApprovalGateRequired),
            ("productionNoDefaultTradingRequired", productionNoDefaultTradingRequired),
            ("rollbackChecklistRequired", rollbackChecklistRequired),
            ("noTradeStatePriorityRequired", noTradeStatePriorityRequired),
            ("productionBlockedDryRunDefault", productionBlockedDryRunDefault)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        implementsEmergencyStopRuntime: Bool,
        implementsShutdownRuntime: Bool,
        implementsRestoreRuntime: Bool,
        implementsProductionOperationsRuntime: Bool,
        exposesLiveCommandSurface: Bool,
        exposesTradingButton: Bool,
        exposesOrderForm: Bool,
        connectsBroker: Bool,
        parsesBrokerFill: Bool,
        performsReconciliation: Bool,
        bypassesNoTradeState: Bool,
        productionTradingEnabledByDefault: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool
    ) throws {
        let forbiddenFlags = [
            ("implementsEmergencyStopRuntime", implementsEmergencyStopRuntime),
            ("implementsShutdownRuntime", implementsShutdownRuntime),
            ("implementsRestoreRuntime", implementsRestoreRuntime),
            ("implementsProductionOperationsRuntime", implementsProductionOperationsRuntime),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface),
            ("exposesTradingButton", exposesTradingButton),
            ("exposesOrderForm", exposesOrderForm),
            ("connectsBroker", connectsBroker),
            ("parsesBrokerFill", parsesBrokerFill),
            ("performsReconciliation", performsReconciliation),
            ("bypassesNoTradeState", bypassesNoTradeState),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
