import Foundation

public enum ReleaseV0260FuturesTestnetFailureClass: String, Codable, Equatable, Sendable, CaseIterable {
    case manualApprovalMissing = "manual-approval-missing"
    case credentialReferenceMissing = "credential-reference-missing"
    case hardCapExceeded = "hard-cap-exceeded"
    case riskGateRejected = "risk-gate-rejected"
    case idempotencyKeyMissing = "idempotency-key-missing"
    case cancelStatusAmbiguous = "cancel-status-ambiguous"
    case reconciliationMismatch = "reconciliation-mismatch"
    case productionEndpointRejected = "production-endpoint-rejected"
}

public enum ReleaseV0260FuturesTestnetEventKind: String, Codable, Equatable, Sendable, CaseIterable {
    case intentValidated = "intent-validated"
    case riskAccepted = "risk-accepted"
    case submitEvidenceRecorded = "submit-evidence-recorded"
    case statusObserved = "status-observed"
    case cancelEvidenceRecorded = "cancel-evidence-recorded"
    case omsEventRecorded = "oms-event-recorded"
    case reconciliationEvidenceRecorded = "reconciliation-evidence-recorded"
}

public struct ReleaseV0260FuturesTestnetLifecycleEvent: Codable, Equatable, Sendable {
    public let sequence: Int
    public let kind: ReleaseV0260FuturesTestnetEventKind
    public let artifactRole: String
    public let failClosed: Bool

    public init(
        sequence: Int,
        kind: ReleaseV0260FuturesTestnetEventKind,
        artifactRole: String,
        failClosed: Bool
    ) {
        self.sequence = sequence
        self.kind = kind
        self.artifactRole = artifactRole
        self.failClosed = failClosed
    }
}

public struct ReleaseV0260FuturesTestnetControlledExecutionFoundationEvidence:
    Codable,
    Equatable,
    Sendable
{
    // Binance USD-M Futures testnet controlled execution foundation; production cutover not authorized.
    public static let cliCommand = "futures-testnet-controlled-execution"
    public static let supportedActions = ["status", "gates", "execution", "reconciliation", "boundaries"]

    public static let validationAnchor = "TVM-RELEASE-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION"
    public static let verificationAnchor = "GH-1394-VERIFY-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION-CONTRACT"
    public static let requiredAnchors = [
        "GH-1394-VERIFY-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION-CONTRACT",
        "TVM-RELEASE-V0260-FUTURES-TESTNET-CONTROLLED-EXECUTION",
        "V0260-001-FUTURES-TESTNET-CONTROLLED-EXECUTION",
        "V0260-001-NO-PRODUCTION-CUTOVER",
        "GH-1395-VERIFY-V0260-FUTURES-TESTNET-ENVIRONMENT-CREDENTIAL-GATE",
        "V0260-002-FUTURES-TESTNET-ENVIRONMENT-GATE",
        "V0260-002-CREDENTIAL-REFERENCE-ONLY",
        "GH-1396-VERIFY-V0260-FUTURES-TESTNET-ORDER-INTENT-VALIDATION",
        "V0260-003-NO-PRODUCTION-CUTOVER",
        "V0260-003-ORDER-INTENT-VALIDATED",
        "GH-1397-VERIFY-V0260-FUTURES-TESTNET-SUBMIT-EVIDENCE",
        "V0260-004-MANUAL-APPROVAL-HARD-CAPS",
        "V0260-004-IDEMPOTENCY-REDACTION",
        "GH-1398-VERIFY-V0260-FUTURES-TESTNET-CANCEL-STATUS-ROLLBACK",
        "V0260-005-CANCEL-STATUS-ROLLBACK",
        "V0260-005-FAIL-CLOSED-STATUS-AMBIGUITY",
        "GH-1399-VERIFY-V0260-FUTURES-TESTNET-OMS-RECONCILIATION",
        "V0260-006-OMS-EVENT-LOG-RECONCILIATION",
        "V0260-006-APPEND-ONLY-EVIDENCE",
        "GH-1400-VERIFY-V0260-FUTURES-TESTNET-RISK-NOTIONAL-LEVERAGE-GUARDS",
        "V0260-007-RISK-NOTIONAL-LEVERAGE-MODE-GUARD",
        "V0260-007-REDUCE-ONLY-HARD-CAP",
        "GH-1401-VERIFY-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE",
        "TVM-RELEASE-V0260-DASHBOARD-CLI-FUTURES-TESTNET-STATUS-SURFACE",
        "V0260-008-DASHBOARD-CLI-READONLY-FUTURES-TESTNET-STATUS",
        "V0260-008-NO-DASHBOARD-TRADING-CONTROLS",
        "GH-1402-VERIFY-V0260-AGGREGATE-VALIDATION",
        "TVM-RELEASE-V0260-AGGREGATE-VALIDATION",
        "V0260-009-AGGREGATE-VALIDATION-SUITE",
        "GH-1403-VERIFY-V0260-STAGE-AUDIT-RELEASE-DOCS",
        "V0260-010-STAGE-CODE-AUDIT",
        "V0260-010-NO-PRODUCTION-CUTOVER",
        "V0260-010-NO-TAG-OR-RELEASE-PUBLICATION"
    ]

    public let release: String
    public let venue: String
    public let productType: String
    public let environment: String
    public let credentialReferenceOnly: Bool
    public let secretValueRead: Bool
    public let manualApprovalRequired: Bool
    public let manualApprovalPresent: Bool
    public let orderIntentValidated: Bool
    public let symbolAllowlist: [String]
    public let orderTypeAllowlist: [String]
    public let maxNotionalUSDT: Decimal
    public let maxQuantity: Decimal
    public let maxLeverage: Int
    public let leverageModeMutationEnabled: Bool
    public let marginModeMutationEnabled: Bool
    public let positionModeMutationEnabled: Bool
    public let riskGatePassed: Bool
    public let killSwitchClear: Bool
    public let noTradeClear: Bool
    public let idempotencyKeyRequired: Bool
    public let redactionEnabled: Bool
    public let submitEvidenceRecorded: Bool
    public let cancelEvidenceRecorded: Bool
    public let statusRollbackEvidenceRecorded: Bool
    public let omsEventLogRecorded: Bool
    public let reconciliationEvidenceRecorded: Bool
    public let failureClasses: [ReleaseV0260FuturesTestnetFailureClass]
    public let lifecycleEvents: [ReleaseV0260FuturesTestnetLifecycleEvent]
    public let testnetSubmitCancelReplaceEnabled: Bool
    public let productionFuturesOrderExecutionEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let boundaryHeld: Bool

    public static var deterministicFixture: Self {
        Self(
            release: "v0.26.0",
            venue: "binance",
            productType: "usdsPerpetual",
            environment: "testnet",
            credentialReferenceOnly: true,
            secretValueRead: false,
            manualApprovalRequired: true,
            manualApprovalPresent: true,
            orderIntentValidated: true,
            symbolAllowlist: ["BTCUSDT"],
            orderTypeAllowlist: ["LIMIT"],
            maxNotionalUSDT: 25,
            maxQuantity: 0.001,
            maxLeverage: 2,
            leverageModeMutationEnabled: false,
            marginModeMutationEnabled: false,
            positionModeMutationEnabled: false,
            riskGatePassed: true,
            killSwitchClear: true,
            noTradeClear: true,
            idempotencyKeyRequired: true,
            redactionEnabled: true,
            submitEvidenceRecorded: true,
            cancelEvidenceRecorded: true,
            statusRollbackEvidenceRecorded: true,
            omsEventLogRecorded: true,
            reconciliationEvidenceRecorded: true,
            failureClasses: ReleaseV0260FuturesTestnetFailureClass.allCases,
            lifecycleEvents: ReleaseV0260FuturesTestnetEventKind.allCases.enumerated().map {
                ReleaseV0260FuturesTestnetLifecycleEvent(
                    sequence: $0.offset + 1,
                    kind: $0.element,
                    artifactRole: "v0.26.0/\($0.element.rawValue)",
                    failClosed: true
                )
            },
            testnetSubmitCancelReplaceEnabled: true,
            productionFuturesOrderExecutionEnabled: false,
            productionTradingEnabledByDefault: false,
            productionCutoverAuthorized: false,
            okxActiveRuntimeEnabled: false,
            dashboardTradingControlsEnabled: false,
            boundaryHeld: true
        )
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "releaseSummary=Binance USD-M Futures testnet controlled execution foundation",
            "venue=\(venue)",
            "productType=\(productType)",
            "environment=\(environment)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))",
            "credentialReferenceOnly=\(credentialReferenceOnly)",
            "secretValueRead=\(secretValueRead)",
            "manualApprovalRequired=\(manualApprovalRequired)",
            "manualApprovalPresent=\(manualApprovalPresent)",
            "orderIntentValidated=\(orderIntentValidated)",
            "testnetSubmitCancelReplaceEnabled=\(testnetSubmitCancelReplaceEnabled)",
            "productionFuturesOrderExecutionEnabled=\(productionFuturesOrderExecutionEnabled)",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "okxActiveRuntimeEnabled=\(okxActiveRuntimeEnabled)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var gateLines: [String] {
        [
            "symbolAllowlist=\(symbolAllowlist.joined(separator: ","))",
            "orderTypeAllowlist=\(orderTypeAllowlist.joined(separator: ","))",
            "maxNotionalUSDT=\(maxNotionalUSDT)",
            "maxQuantity=\(maxQuantity)",
            "maxLeverage=\(maxLeverage)",
            "leverageModeMutationEnabled=\(leverageModeMutationEnabled)",
            "marginModeMutationEnabled=\(marginModeMutationEnabled)",
            "positionModeMutationEnabled=\(positionModeMutationEnabled)",
            "riskGatePassed=\(riskGatePassed)",
            "killSwitchClear=\(killSwitchClear)",
            "noTradeClear=\(noTradeClear)",
            "idempotencyKeyRequired=\(idempotencyKeyRequired)",
            "redactionEnabled=\(redactionEnabled)"
        ]
    }

    public var executionLines: [String] {
        lifecycleEvents.map {
            "lifecycleEvent=sequence:\($0.sequence);kind:\($0.kind.rawValue);artifactRole:\($0.artifactRole);failClosed:\($0.failClosed)"
        } + [
            "submitEvidenceRecorded=\(submitEvidenceRecorded)",
            "cancelEvidenceRecorded=\(cancelEvidenceRecorded)",
            "statusRollbackEvidenceRecorded=\(statusRollbackEvidenceRecorded)",
            "omsEventLogRecorded=\(omsEventLogRecorded)"
        ]
    }

    public var reconciliationLines: [String] {
        [
            "reconciliationEvidenceRecorded=\(reconciliationEvidenceRecorded)",
            "omsEventLogRecorded=\(omsEventLogRecorded)",
            "localOrderStoreRole=deterministic-testnet-evidence",
            "brokerReconciliationRuntime=controlled-testnet-evidence",
            "productionBrokerReconciliationEnabled=false"
        ] + failureClasses.map { "failureClass=\($0.rawValue);failClosed=true" }
    }

    public var boundaryLines: [String] {
        [
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionFuturesOrderExecutionEnabled=false",
            "productionCutoverAuthorized=false",
            "okxActiveRuntimeEnabled=false",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false",
            "unrestrictedLiveTradingAuthorized=false"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0260FuturesTestnetControlledExecutionCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }
        let action = arguments.count == 1 ? "status" : arguments[1]
        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0260FuturesTestnetControlledExecutionCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let actionLines: [String]
        switch action {
        case "status":
            actionLines = evidence.statusLines
        case "gates":
            actionLines = evidence.statusLines + evidence.gateLines
        case "execution":
            actionLines = evidence.statusLines + evidence.executionLines
        case "reconciliation":
            actionLines = evidence.statusLines + evidence.reconciliationLines
        case "boundaries":
            actionLines = evidence.statusLines + evidence.boundaryLines
        default:
            actionLines = []
        }

        return ([
            "mtpro \(cliCommand) \(action)",
            "commandSurface=read-only",
            "tradingCommandCreated=false"
        ] + actionLines).joined(separator: "\n")
    }
}

public enum ReleaseV0260FuturesTestnetControlledExecutionCLIError: Error, Equatable, Sendable {
    case invalidArguments(expected: String, actual: String)
}
