import Foundation

public enum ReleaseV0280ReadinessGateKind: String, Codable, Equatable, Sendable, CaseIterable {
    case contract = "contract"
    case credentialSecretAccessPolicy = "credential-secret-access-policy"
    case endpointAllowlist = "endpoint-allowlist"
    case manualApproval = "manual-approval"
    case capitalRisk = "capital-risk"
    case incidentRollback = "incident-rollback"
    case dashboardCLI = "dashboard-cli"
    case aggregateValidation = "aggregate-validation"
}

public enum ReleaseV0280ReadinessEvaluationMode: String, Codable, Equatable, Sendable {
    case contractOnly = "contract-only"
}

public enum ReleaseV0280ReadinessStatus: String, Codable, Equatable, Sendable {
    case notEvaluated = "not-evaluated"
}

public enum ReleaseV0280CutoverDecision: String, Codable, Equatable, Sendable {
    case blocked
}

public enum ReleaseV0280ReadinessGateState: String, Codable, Equatable, Sendable {
    case present
}

public struct ReleaseV0280ReadinessGateEvidence: Codable, Equatable, Sendable {
    public let kind: ReleaseV0280ReadinessGateKind
    public let release: String
    public let environmentScope: String
    public let anchor: String
    public let description: String
    public let state: ReleaseV0280ReadinessGateState
    public let source: String
    public let freshness: String
    public let checksum: String
    public let reason: String
    public let required: Bool
    public let failClosed: Bool

    public init(
        kind: ReleaseV0280ReadinessGateKind,
        release: String = "v0.28.0",
        environmentScope: String = "production-readiness-only",
        anchor: String,
        description: String,
        state: ReleaseV0280ReadinessGateState = .present,
        source: String = "v0.28.1-readiness-semantics-validation",
        freshness: String = "deterministic-current",
        checksum: String = "sha256:v0.28.1-readiness-gate-evidence",
        reason: String = "required gate evidence is present and fail-closed",
        required: Bool,
        failClosed: Bool
    ) {
        self.kind = kind
        self.release = release
        self.environmentScope = environmentScope
        self.anchor = anchor
        self.description = description
        self.state = state
        self.source = source
        self.freshness = freshness
        self.checksum = checksum
        self.reason = reason
        self.required = required
        self.failClosed = failClosed
    }
}

public struct ReleaseV0280ProductionCutoverReadinessGate: Codable, Equatable, Sendable {
    // GH-1429-VERIFY-V0280-BINANCE-PRODUCTION-CUTOVER-READINESS-CONTRACT
    // TVM-RELEASE-V0280-PRODUCTION-CUTOVER-READINESS-GATE
    // V0280-001-BINANCE-ONLY-PRODUCTION-CUTOVER-READINESS
    // V0280-001-NOT-PRODUCTION-CUTOVER
    // V0280-001-SPOT-USDM-FUTURES-ONLY
    // V0280-001-OKX-NOT-ACTIVE
    // GH-1430-VERIFY-V0280-PRODUCTION-CREDENTIAL-SECRET-ACCESS-POLICY
    // V0280-002-SECRET-ACCESS-EXPLICIT-APPROVAL
    // V0280-002-NO-DEFAULT-SECRET-READ
    // V0280-002-REDACTION-REQUIRED
    // GH-1431-VERIFY-V0280-PRODUCTION-ENVIRONMENT-ENDPOINT-ALLOWLIST
    // V0280-003-ENDPOINT-ALLOWLIST
    // V0280-003-PRODUCTION-ENVIRONMENT-ISOLATION
    // V0280-003-BINANCE-SPOT-USDM-FUTURES-ENDPOINTS
    // GH-1432-VERIFY-V0280-MANUAL-APPROVAL-OPERATOR-CONFIRMATION
    // V0280-004-MANUAL-APPROVAL-REQUIRED
    // V0280-004-OPERATOR-CONFIRMATION-REQUIRED
    // V0280-004-NO-AUTO-CUTOVER
    // GH-1433-VERIFY-V0280-CAPITAL-RISK-NOTIONAL-EXPOSURE-LEVERAGE
    // V0280-005-CAPITAL-RISK-GATE
    // V0280-005-NOTIONAL-EXPOSURE-LEVERAGE-LIMITS
    // V0280-005-FUTURES-LEVERAGE-FAIL-CLOSED
    // GH-1434-VERIFY-V0280-KILL-NOTRADE-ROLLBACK-INCIDENT-STOP
    // V0280-006-KILL-SWITCH-REQUIRED
    // V0280-006-NO-TRADE-STATE-REQUIRED
    // V0280-006-ROLLBACK-INCIDENT-STOP-READY
    // GH-1435-VERIFY-V0280-DASHBOARD-CLI-READINESS-SURFACE
    // V0280-007-DASHBOARD-CLI-READINESS
    // V0280-007-NO-TRADING-BUTTON
    // V0280-007-NO-ORDER-FORM
    // V0280-007-NO-LIVE-COMMAND
    // GH-1436-VERIFY-V0280-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT
    // V0280-008-AGGREGATE-VALIDATION
    // V0280-008-STAGE-AUDIT-RELEASE-DOCS
    // V0280-008-NO-PRODUCTION-CUTOVER
    // GH-1439-VERIFY-V0281-V0280-RELEASE-FACT-SYNC
    // GH-1440-VERIFY-V0281-BINANCE-ONLY-CURRENT-BASELINE
    // GH-1441-VERIFY-V0281-PUBLISHED-V0280-STALE-WORDING-GUARD
    // GH-1442-VERIFY-V0281-READINESS-SEMANTIC-STATES
    // V0281-004-EVALUATION-MODE-CONTRACT-ONLY
    // V0281-004-READINESS-STATUS-NOT-EVALUATED
    // V0281-004-CUTOVER-DECISION-BLOCKED
    // GH-1443-VERIFY-V0281-READINESS-GATE-FAIL-CLOSED-EVIDENCE
    // V0281-005-REJECT-INCOMPLETE-DUPLICATE-MALFORMED-GATES
    // GH-1444-VERIFY-V0281-PREPUBLICATION-FULL-MATRIX-EVIDENCE
    // GH-1445-VERIFY-V0281-RELEASE-VERIFICATION-DEDUPE
    // GH-1446-VERIFY-V0281-PATCH-AUDIT-RELEASE-NOTES
    // evaluationMode=contract-only
    // readinessStatus=not-evaluated
    // cutoverDecision=blocked
    // readinessGateEvidenceComplete=true

    public static let cliCommand = "production-cutover-readiness-gate"
    public static let supportedActions = [
        "status",
        "gates",
        "boundaries"
    ]

    public static let validationAnchor =
        "TVM-RELEASE-V0280-PRODUCTION-CUTOVER-READINESS-GATE"
    public static let verificationAnchor =
        "GH-1429-VERIFY-V0280-BINANCE-PRODUCTION-CUTOVER-READINESS-CONTRACT"
    public static let requiredAnchors = [
        "GH-1429-VERIFY-V0280-BINANCE-PRODUCTION-CUTOVER-READINESS-CONTRACT",
        "TVM-RELEASE-V0280-PRODUCTION-CUTOVER-READINESS-GATE",
        "V0280-001-BINANCE-ONLY-PRODUCTION-CUTOVER-READINESS",
        "V0280-001-NOT-PRODUCTION-CUTOVER",
        "V0280-001-SPOT-USDM-FUTURES-ONLY",
        "V0280-001-OKX-NOT-ACTIVE",
        "GH-1430-VERIFY-V0280-PRODUCTION-CREDENTIAL-SECRET-ACCESS-POLICY",
        "V0280-002-SECRET-ACCESS-EXPLICIT-APPROVAL",
        "V0280-002-NO-DEFAULT-SECRET-READ",
        "V0280-002-REDACTION-REQUIRED",
        "GH-1431-VERIFY-V0280-PRODUCTION-ENVIRONMENT-ENDPOINT-ALLOWLIST",
        "V0280-003-ENDPOINT-ALLOWLIST",
        "V0280-003-PRODUCTION-ENVIRONMENT-ISOLATION",
        "V0280-003-BINANCE-SPOT-USDM-FUTURES-ENDPOINTS",
        "GH-1432-VERIFY-V0280-MANUAL-APPROVAL-OPERATOR-CONFIRMATION",
        "V0280-004-MANUAL-APPROVAL-REQUIRED",
        "V0280-004-OPERATOR-CONFIRMATION-REQUIRED",
        "V0280-004-NO-AUTO-CUTOVER",
        "GH-1433-VERIFY-V0280-CAPITAL-RISK-NOTIONAL-EXPOSURE-LEVERAGE",
        "V0280-005-CAPITAL-RISK-GATE",
        "V0280-005-NOTIONAL-EXPOSURE-LEVERAGE-LIMITS",
        "V0280-005-FUTURES-LEVERAGE-FAIL-CLOSED",
        "GH-1434-VERIFY-V0280-KILL-NOTRADE-ROLLBACK-INCIDENT-STOP",
        "V0280-006-KILL-SWITCH-REQUIRED",
        "V0280-006-NO-TRADE-STATE-REQUIRED",
        "V0280-006-ROLLBACK-INCIDENT-STOP-READY",
        "GH-1435-VERIFY-V0280-DASHBOARD-CLI-READINESS-SURFACE",
        "V0280-007-DASHBOARD-CLI-READINESS",
        "V0280-007-NO-TRADING-BUTTON",
        "V0280-007-NO-ORDER-FORM",
        "V0280-007-NO-LIVE-COMMAND",
        "GH-1436-VERIFY-V0280-AGGREGATE-VALIDATION-RELEASE-CLOSEOUT",
        "V0280-008-AGGREGATE-VALIDATION",
        "V0280-008-STAGE-AUDIT-RELEASE-DOCS",
        "V0280-008-NO-PRODUCTION-CUTOVER"
    ]

    public let release: String
    public let venue: String
    public let productTypes: [String]
    public let environmentScope: String
    public let evaluationMode: ReleaseV0280ReadinessEvaluationMode
    public let readinessStatus: ReleaseV0280ReadinessStatus
    public let cutoverDecision: ReleaseV0280CutoverDecision
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionEndpointConnectionEnabledByDefault: Bool
    public let brokerEndpointConnectionEnabledByDefault: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let futuresProductionOrderExecutionEnabled: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let manualApprovalRequired: Bool
    public let operatorConfirmationRequired: Bool
    public let capitalRiskGateRequired: Bool
    public let notionalExposureLeverageGateRequired: Bool
    public let killSwitchRequired: Bool
    public let noTradeStateRequired: Bool
    public let rollbackIncidentStopRequired: Bool
    public let redactionRequired: Bool
    public let endpointAllowlistRequired: Bool
    public let gates: [ReleaseV0280ReadinessGateEvidence]

    public init(
        release: String,
        venue: String,
        productTypes: [String],
        environmentScope: String,
        evaluationMode: ReleaseV0280ReadinessEvaluationMode,
        readinessStatus: ReleaseV0280ReadinessStatus,
        cutoverDecision: ReleaseV0280CutoverDecision,
        productionTradingEnabledByDefault: Bool,
        productionCutoverAuthorized: Bool,
        productionSecretReadEnabledByDefault: Bool,
        productionEndpointConnectionEnabledByDefault: Bool,
        brokerEndpointConnectionEnabledByDefault: Bool,
        productionOrderSubmitCancelReplaceEnabled: Bool,
        futuresProductionOrderExecutionEnabled: Bool,
        okxActiveRuntimeEnabled: Bool,
        dashboardTradingControlsEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        manualApprovalRequired: Bool,
        operatorConfirmationRequired: Bool,
        capitalRiskGateRequired: Bool,
        notionalExposureLeverageGateRequired: Bool,
        killSwitchRequired: Bool,
        noTradeStateRequired: Bool,
        rollbackIncidentStopRequired: Bool,
        redactionRequired: Bool,
        endpointAllowlistRequired: Bool,
        gates: [ReleaseV0280ReadinessGateEvidence]
    ) {
        self.release = release
        self.venue = venue
        self.productTypes = productTypes
        self.environmentScope = environmentScope
        self.evaluationMode = evaluationMode
        self.readinessStatus = readinessStatus
        self.cutoverDecision = cutoverDecision
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionEndpointConnectionEnabledByDefault = productionEndpointConnectionEnabledByDefault
        self.brokerEndpointConnectionEnabledByDefault = brokerEndpointConnectionEnabledByDefault
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.futuresProductionOrderExecutionEnabled = futuresProductionOrderExecutionEnabled
        self.okxActiveRuntimeEnabled = okxActiveRuntimeEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.manualApprovalRequired = manualApprovalRequired
        self.operatorConfirmationRequired = operatorConfirmationRequired
        self.capitalRiskGateRequired = capitalRiskGateRequired
        self.notionalExposureLeverageGateRequired = notionalExposureLeverageGateRequired
        self.killSwitchRequired = killSwitchRequired
        self.noTradeStateRequired = noTradeStateRequired
        self.rollbackIncidentStopRequired = rollbackIncidentStopRequired
        self.redactionRequired = redactionRequired
        self.endpointAllowlistRequired = endpointAllowlistRequired
        self.gates = gates
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.28.0",
            venue: "binance",
            productTypes: ["spot", "usdsPerpetual"],
            environmentScope: "production-readiness-only",
            evaluationMode: .contractOnly,
            readinessStatus: .notEvaluated,
            cutoverDecision: .blocked,
            productionTradingEnabledByDefault: false,
            productionCutoverAuthorized: false,
            productionSecretReadEnabledByDefault: false,
            productionEndpointConnectionEnabledByDefault: false,
            brokerEndpointConnectionEnabledByDefault: false,
            productionOrderSubmitCancelReplaceEnabled: false,
            futuresProductionOrderExecutionEnabled: false,
            okxActiveRuntimeEnabled: false,
            dashboardTradingControlsEnabled: false,
            orderFormEnabled: false,
            liveCommandEnabled: false,
            manualApprovalRequired: true,
            operatorConfirmationRequired: true,
            capitalRiskGateRequired: true,
            notionalExposureLeverageGateRequired: true,
            killSwitchRequired: true,
            noTradeStateRequired: true,
            rollbackIncidentStopRequired: true,
            redactionRequired: true,
            endpointAllowlistRequired: true,
            gates: [
                .init(
                    kind: .contract,
                    anchor: "V0280-001-BINANCE-ONLY-PRODUCTION-CUTOVER-READINESS",
                    description: "Binance-only Spot + USD-M Futures production cutover readiness contract; not cutover authorization.",
                    required: true,
                    failClosed: true
                ),
                .init(
                    kind: .credentialSecretAccessPolicy,
                    anchor: "V0280-002-SECRET-ACCESS-EXPLICIT-APPROVAL",
                    description: "Production secret access requires explicit approval and redacted evidence.",
                    required: true,
                    failClosed: true
                ),
                .init(
                    kind: .endpointAllowlist,
                    anchor: "V0280-003-ENDPOINT-ALLOWLIST",
                    description: "Production endpoint shape is isolated and allowlisted before any future cutover.",
                    required: true,
                    failClosed: true
                ),
                .init(
                    kind: .manualApproval,
                    anchor: "V0280-004-MANUAL-APPROVAL-REQUIRED",
                    description: "Manual approval and operator confirmation are mandatory; auto cutover is rejected.",
                    required: true,
                    failClosed: true
                ),
                .init(
                    kind: .capitalRisk,
                    anchor: "V0280-005-CAPITAL-RISK-GATE",
                    description: "Capital, notional exposure and Futures leverage limits must pass before cutover.",
                    required: true,
                    failClosed: true
                ),
                .init(
                    kind: .incidentRollback,
                    anchor: "V0280-006-KILL-SWITCH-REQUIRED",
                    description: "Kill switch, no-trade state, rollback and incident stop readiness are required.",
                    required: true,
                    failClosed: true
                ),
                .init(
                    kind: .dashboardCLI,
                    anchor: "V0280-007-DASHBOARD-CLI-READINESS",
                    description: "Dashboard and CLI expose read-only readiness status without trading controls.",
                    required: true,
                    failClosed: true
                ),
                .init(
                    kind: .aggregateValidation,
                    anchor: "V0280-008-AGGREGATE-VALIDATION",
                    description: "Aggregate validation and release closeout docs must preserve no-production-cutover facts.",
                    required: true,
                    failClosed: true
                )
            ]
        )
    }

    public var readinessGateEvidenceComplete: Bool {
        guard !gates.isEmpty else {
            return false
        }

        let expectedKinds = Set(ReleaseV0280ReadinessGateKind.allCases)
        var observedKinds = Set<ReleaseV0280ReadinessGateKind>()

        for gate in gates {
            guard observedKinds.insert(gate.kind).inserted else {
                return false
            }
            guard expectedKinds.contains(gate.kind) else {
                return false
            }
            guard gate.release == release,
                  gate.environmentScope == environmentScope,
                  gate.state == .present,
                  gate.required,
                  gate.failClosed else {
                return false
            }
            guard !gate.anchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !gate.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !gate.source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !gate.freshness.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !gate.checksum.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !gate.reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return false
            }
        }

        return observedKinds == expectedKinds
    }

    public var boundaryHeld: Bool {
        productTypes == ["spot", "usdsPerpetual"]
            && venue == "binance"
            && evaluationMode == .contractOnly
            && readinessStatus == .notEvaluated
            && cutoverDecision == .blocked
            && !productionTradingEnabledByDefault
            && !productionCutoverAuthorized
            && !productionSecretReadEnabledByDefault
            && !productionEndpointConnectionEnabledByDefault
            && !brokerEndpointConnectionEnabledByDefault
            && !productionOrderSubmitCancelReplaceEnabled
            && !futuresProductionOrderExecutionEnabled
            && !okxActiveRuntimeEnabled
            && !dashboardTradingControlsEnabled
            && !orderFormEnabled
            && !liveCommandEnabled
            && manualApprovalRequired
            && operatorConfirmationRequired
            && capitalRiskGateRequired
            && notionalExposureLeverageGateRequired
            && killSwitchRequired
            && noTradeStateRequired
            && rollbackIncidentStopRequired
            && redactionRequired
            && endpointAllowlistRequired
            && readinessGateEvidenceComplete
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "releaseSummary=Binance production cutover readiness gate",
            "venue=\(venue)",
            "productTypes=\(productTypes.joined(separator: ","))",
            "environmentScope=\(environmentScope)",
            "evaluationMode=\(evaluationMode.rawValue)",
            "readinessStatus=\(readinessStatus.rawValue)",
            "cutoverDecision=\(cutoverDecision.rawValue)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))",
            "readinessGateEvidenceComplete=\(readinessGateEvidenceComplete)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var gateLines: [String] {
        gates.map {
            "gate=kind:\($0.kind.rawValue);release:\($0.release);environmentScope:\($0.environmentScope);anchor:\($0.anchor);state:\($0.state.rawValue);source:\($0.source);freshness:\($0.freshness);checksum:\($0.checksum);required:\($0.required);failClosed:\($0.failClosed);reason:\($0.reason);description:\($0.description)"
        }
    }

    public var boundaryLines: [String] {
        [
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "productionSecretReadEnabledByDefault=\(productionSecretReadEnabledByDefault)",
            "productionEndpointConnectionEnabledByDefault=\(productionEndpointConnectionEnabledByDefault)",
            "brokerEndpointConnectionEnabledByDefault=\(brokerEndpointConnectionEnabledByDefault)",
            "productionOrderSubmitCancelReplaceEnabled=\(productionOrderSubmitCancelReplaceEnabled)",
            "futuresProductionOrderExecutionEnabled=\(futuresProductionOrderExecutionEnabled)",
            "okxActiveRuntimeEnabled=\(okxActiveRuntimeEnabled)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "tradingButtonVisible=false",
            "orderFormEnabled=\(orderFormEnabled)",
            "liveCommandEnabled=\(liveCommandEnabled)",
            "manualApprovalRequired=\(manualApprovalRequired)",
            "operatorConfirmationRequired=\(operatorConfirmationRequired)",
            "capitalRiskGateRequired=\(capitalRiskGateRequired)",
            "notionalExposureLeverageGateRequired=\(notionalExposureLeverageGateRequired)",
            "killSwitchRequired=\(killSwitchRequired)",
            "noTradeStateRequired=\(noTradeStateRequired)",
            "rollbackIncidentStopRequired=\(rollbackIncidentStopRequired)",
            "redactionRequired=\(redactionRequired)",
            "endpointAllowlistRequired=\(endpointAllowlistRequired)"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0280ProductionCutoverReadinessGateCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let action = arguments.dropFirst().first ?? "status"

        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0280ProductionCutoverReadinessGateCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let lines: [String]
        switch action {
        case "status":
            lines = evidence.statusLines
        case "gates":
            lines = evidence.gateLines
        case "boundaries":
            lines = evidence.boundaryLines
        default:
            lines = evidence.statusLines
        }

        return lines.joined(separator: "\n")
    }
}

public enum ReleaseV0280ProductionCutoverReadinessGateCLIError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidArguments(expected: String, actual: String)

    public var errorDescription: String? {
        switch self {
        case let .invalidArguments(expected, actual):
            "Invalid v0.28.0 production cutover readiness arguments. Expected \(expected); actual \(actual)."
        }
    }
}
