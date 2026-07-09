import Foundation

public enum ReleaseV0270FuturesTestnetFailureClass: String, Codable, Equatable, Sendable, CaseIterable {
    case signedStatusTimeout = "signed-status-timeout"
    case signedStatusRetryExhausted = "signed-status-retry-exhausted"
    case cancelStatusAmbiguous = "cancel-status-ambiguous"
    case reconciliationMismatch = "reconciliation-mismatch"
    case missingArtifact = "missing-artifact"
    case corruptArtifact = "corrupt-artifact"
    case duplicateSubmit = "duplicate-submit"
    case runLockAlreadyHeld = "run-lock-already-held"
    case redactionViolation = "redaction-violation"
    case productionEndpointRejected = "production-endpoint-rejected"
}

public enum ReleaseV0270FuturesTestnetArtifactRole: String, Codable, Equatable, Sendable, CaseIterable {
    case runRegistry = "run-registry"
    case artifactManifest = "artifact-manifest"
    case statusRetryEvidence = "status-retry-evidence"
    case cancelRecoveryEvidence = "cancel-recovery-evidence"
    case reconciliationEvidence = "reconciliation-evidence"
    case replayValidationEvidence = "replay-validation-evidence"
    case idempotencyEvidence = "idempotency-evidence"
    case manualWorkflowEvidence = "manual-workflow-evidence"
    case readOnlyDrilldownEvidence = "read-only-drilldown-evidence"
}

public struct ReleaseV0270FuturesTestnetArtifactEvidence: Codable, Equatable, Sendable {
    public let role: ReleaseV0270FuturesTestnetArtifactRole
    public let artifactID: String
    public let checksum: String
    public let redacted: Bool
    public let replayable: Bool
    public let failClosed: Bool

    public init(
        role: ReleaseV0270FuturesTestnetArtifactRole,
        artifactID: String,
        checksum: String,
        redacted: Bool,
        replayable: Bool,
        failClosed: Bool
    ) {
        self.role = role
        self.artifactID = artifactID
        self.checksum = checksum
        self.redacted = redacted
        self.replayable = replayable
        self.failClosed = failClosed
    }
}

public struct ReleaseV0270FuturesTestnetOperatorRuntimeHardeningEvidence:
    Codable,
    Equatable,
    Sendable
{
    // Binance USD-M Futures testnet operator runtime hardening; production cutover not authorized.
    public static let cliCommand = "futures-testnet-operator-hardening"
    public static let supportedActions = [
        "status",
        "registry",
        "failures",
        "recovery",
        "replay",
        "idempotency",
        "surface",
        "workflow",
        "boundaries"
    ]

    public static let validationAnchor =
        "TVM-RELEASE-V0270-FUTURES-TESTNET-OPERATOR-RUNTIME-HARDENING"
    public static let verificationAnchor =
        "GH-1411-VERIFY-V0270-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT"
    public static let requiredAnchors = [
        "GH-1411-VERIFY-V0270-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT",
        "TVM-RELEASE-V0270-FUTURES-TESTNET-OPERATOR-RUNTIME-HARDENING",
        "V0270-001-FUTURES-TESTNET-OPERATOR-RUN-HARDENING-CONTRACT",
        "V0270-001-FAIL-CLOSED-SEMANTICS",
        "GH-1412-VERIFY-V0270-FUTURES-TESTNET-RUN-REGISTRY-ARTIFACT-MANIFEST",
        "V0270-002-RUN-REGISTRY-ARTIFACT-MANIFEST",
        "V0270-002-RUN-IDENTITY-EVIDENCE",
        "GH-1413-VERIFY-V0270-SIGNED-STATUS-RETRY-TIMEOUT-FAILURE-MODEL",
        "V0270-003-SIGNED-STATUS-RETRY-TIMEOUT",
        "V0270-003-CLASSIFIED-FAILURE-EVIDENCE",
        "GH-1414-VERIFY-V0270-CANCEL-STATUS-RECONCILIATION-RECOVERY",
        "V0270-004-CANCEL-STATUS-RECOVERY",
        "V0270-004-RECONCILIATION-RECOVERY",
        "GH-1415-VERIFY-V0270-ARTIFACT-BUNDLE-REPLAY-VALIDATOR",
        "V0270-005-ARTIFACT-BUNDLE-REPLAY-VALIDATOR",
        "V0270-005-CHECKSUM-FAIL-CLOSED",
        "GH-1416-VERIFY-V0270-IDEMPOTENCY-DUPLICATE-SUBMIT-RUN-LOCK",
        "V0270-006-IDEMPOTENCY-DUPLICATE-SUBMIT-GUARD",
        "V0270-006-RUN-LOCK-HARDENING",
        "GH-1417-VERIFY-V0270-DASHBOARD-CLI-FAILURE-DRILLDOWN-READONLY",
        "V0270-007-DASHBOARD-CLI-FAILURE-DRILLDOWN",
        "V0270-007-NO-DASHBOARD-TRADING-CONTROLS",
        "GH-1418-VERIFY-V0270-MANUAL-WORKFLOW-ARTIFACT-REDACTION",
        "V0270-008-MANUAL-WORKFLOW-ARTIFACT-VALIDATION",
        "V0270-008-REDACTION-EVIDENCE",
        "GH-1419-VERIFY-V0270-AGGREGATE-VALIDATION",
        "V0270-009-AGGREGATE-VALIDATION-SUITE",
        "GH-1420-VERIFY-V0270-STAGE-AUDIT-RELEASE-DOCS",
        "V0270-010-STAGE-CODE-AUDIT",
        "V0270-010-RELEASE-NOTES",
        "V0270-010-NO-PRODUCTION-CUTOVER"
    ]

    public let release: String
    public let venue: String
    public let productType: String
    public let environment: String
    public let runID: String
    public let runNamespace: String
    public let artifactManifestID: String
    public let runRegistryRecorded: Bool
    public let runIdentityEvidenceRecorded: Bool
    public let signedStatusMaxRetries: Int
    public let signedStatusTimeoutMillis: Int
    public let statusRetryEvidenceRecorded: Bool
    public let cancelStatusRecoveryEnabled: Bool
    public let reconciliationRecoveryEnabled: Bool
    public let ambiguousStateFailsClosed: Bool
    public let replayValidatorEnabled: Bool
    public let replayChecksumVerified: Bool
    public let corruptArtifactFailsClosed: Bool
    public let missingArtifactFailsClosed: Bool
    public let idempotencyKeyRequired: Bool
    public let duplicateSubmitRejected: Bool
    public let runLockRequired: Bool
    public let runLockHeld: Bool
    public let manualWorkflowArtifactValidationEnabled: Bool
    public let redactionPolicyApplied: Bool
    public let dashboardFailureDrilldownReadOnly: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let productionFuturesOrderExecutionEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let unrestrictedLiveTradingAuthorized: Bool
    public let failureClasses: [ReleaseV0270FuturesTestnetFailureClass]
    public let artifacts: [ReleaseV0270FuturesTestnetArtifactEvidence]

    public static var deterministicFixture: Self {
        let artifacts = ReleaseV0270FuturesTestnetArtifactRole.allCases.enumerated().map {
            ReleaseV0270FuturesTestnetArtifactEvidence(
                role: $0.element,
                artifactID: "v0.27.0/binance/usdsPerpetual/testnet/\($0.element.rawValue)",
                checksum: "sha256:v0270-\($0.offset + 1)-redacted-evidence",
                redacted: true,
                replayable: true,
                failClosed: true
            )
        }

        return Self(
            release: "v0.27.0",
            venue: "binance",
            productType: "usdsPerpetual",
            environment: "testnet",
            runID: "v0270-binance-usdm-testnet-operator-run",
            runNamespace: "binance/usdsPerpetual/testnet/v0.27.0",
            artifactManifestID: "v0270-futures-testnet-operator-artifact-manifest",
            runRegistryRecorded: true,
            runIdentityEvidenceRecorded: true,
            signedStatusMaxRetries: 3,
            signedStatusTimeoutMillis: 5_000,
            statusRetryEvidenceRecorded: true,
            cancelStatusRecoveryEnabled: true,
            reconciliationRecoveryEnabled: true,
            ambiguousStateFailsClosed: true,
            replayValidatorEnabled: true,
            replayChecksumVerified: true,
            corruptArtifactFailsClosed: true,
            missingArtifactFailsClosed: true,
            idempotencyKeyRequired: true,
            duplicateSubmitRejected: true,
            runLockRequired: true,
            runLockHeld: true,
            manualWorkflowArtifactValidationEnabled: true,
            redactionPolicyApplied: true,
            dashboardFailureDrilldownReadOnly: true,
            dashboardTradingControlsEnabled: false,
            productionFuturesOrderExecutionEnabled: false,
            productionTradingEnabledByDefault: false,
            productionCutoverAuthorized: false,
            okxActiveRuntimeEnabled: false,
            unrestrictedLiveTradingAuthorized: false,
            failureClasses: ReleaseV0270FuturesTestnetFailureClass.allCases,
            artifacts: artifacts
        )
    }

    public var boundaryHeld: Bool {
        runRegistryRecorded
            && runIdentityEvidenceRecorded
            && statusRetryEvidenceRecorded
            && cancelStatusRecoveryEnabled
            && reconciliationRecoveryEnabled
            && ambiguousStateFailsClosed
            && replayValidatorEnabled
            && replayChecksumVerified
            && corruptArtifactFailsClosed
            && missingArtifactFailsClosed
            && idempotencyKeyRequired
            && duplicateSubmitRejected
            && runLockRequired
            && manualWorkflowArtifactValidationEnabled
            && redactionPolicyApplied
            && dashboardFailureDrilldownReadOnly
            && !dashboardTradingControlsEnabled
            && !productionFuturesOrderExecutionEnabled
            && !productionTradingEnabledByDefault
            && !productionCutoverAuthorized
            && !okxActiveRuntimeEnabled
            && !unrestrictedLiveTradingAuthorized
            && artifacts.allSatisfy { $0.redacted && $0.replayable && $0.failClosed }
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "releaseSummary=Binance USD-M Futures testnet operator runtime hardening",
            "venue=\(venue)",
            "productType=\(productType)",
            "environment=\(environment)",
            "runID=\(runID)",
            "runNamespace=\(runNamespace)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var registryLines: [String] {
        [
            "runRegistryRecorded=\(runRegistryRecorded)",
            "runIdentityEvidenceRecorded=\(runIdentityEvidenceRecorded)",
            "artifactManifestID=\(artifactManifestID)",
            "artifactCount=\(artifacts.count)"
        ] + artifacts.map {
            "artifact=role:\($0.role.rawValue);id:\($0.artifactID);checksum:\($0.checksum);redacted:\($0.redacted);replayable:\($0.replayable);failClosed:\($0.failClosed)"
        }
    }

    public var failureLines: [String] {
        failureClasses.map { "failureClass=\($0.rawValue);classified=true;failClosed=true" } + [
            "signedStatusMaxRetries=\(signedStatusMaxRetries)",
            "signedStatusTimeoutMillis=\(signedStatusTimeoutMillis)",
            "statusRetryEvidenceRecorded=\(statusRetryEvidenceRecorded)"
        ]
    }

    public var recoveryLines: [String] {
        [
            "cancelStatusRecoveryEnabled=\(cancelStatusRecoveryEnabled)",
            "reconciliationRecoveryEnabled=\(reconciliationRecoveryEnabled)",
            "ambiguousStateFailsClosed=\(ambiguousStateFailsClosed)",
            "nextOperatorAction=inspect-redacted-artifact-and-rerun-status"
        ]
    }

    public var replayLines: [String] {
        [
            "replayValidatorEnabled=\(replayValidatorEnabled)",
            "replayChecksumVerified=\(replayChecksumVerified)",
            "corruptArtifactFailsClosed=\(corruptArtifactFailsClosed)",
            "missingArtifactFailsClosed=\(missingArtifactFailsClosed)"
        ]
    }

    public var idempotencyLines: [String] {
        [
            "idempotencyKeyRequired=\(idempotencyKeyRequired)",
            "duplicateSubmitRejected=\(duplicateSubmitRejected)",
            "runLockRequired=\(runLockRequired)",
            "runLockHeld=\(runLockHeld)"
        ]
    }

    public var surfaceLines: [String] {
        [
            "dashboardFailureDrilldownReadOnly=\(dashboardFailureDrilldownReadOnly)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "tradingButtonVisible=false",
            "orderFormVisible=false",
            "liveCommandVisible=false"
        ]
    }

    public var workflowLines: [String] {
        [
            "manualWorkflowArtifactValidationEnabled=\(manualWorkflowArtifactValidationEnabled)",
            "redactionPolicyApplied=\(redactionPolicyApplied)",
            "manualWorkflowRejectsRawSecret=true",
            "manualWorkflowRejectsProductionHost=true",
            "manualWorkflowRejectsUnredactedPayload=true"
        ]
    }

    public var boundaryLines: [String] {
        [
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionFuturesOrderExecutionEnabled=false",
            "productionTradingEnabledByDefault=false",
            "productionCutoverAuthorized=false",
            "okxActiveRuntimeEnabled=false",
            "dashboardTradingControlsEnabled=false",
            "unrestrictedLiveTradingAuthorized=false"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0270FuturesTestnetOperatorRuntimeHardeningCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let action = arguments.dropFirst().first ?? "status"

        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0270FuturesTestnetOperatorRuntimeHardeningCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let lines: [String]
        switch action {
        case "status":
            lines = evidence.statusLines
        case "registry":
            lines = evidence.registryLines
        case "failures":
            lines = evidence.failureLines
        case "recovery":
            lines = evidence.recoveryLines
        case "replay":
            lines = evidence.replayLines
        case "idempotency":
            lines = evidence.idempotencyLines
        case "surface":
            lines = evidence.surfaceLines
        case "workflow":
            lines = evidence.workflowLines
        case "boundaries":
            lines = evidence.boundaryLines
        default:
            lines = evidence.statusLines
        }

        return lines.joined(separator: "\n")
    }
}

public enum ReleaseV0270FuturesTestnetOperatorRuntimeHardeningCLIError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidArguments(expected: String, actual: String)

    public var errorDescription: String? {
        switch self {
        case let .invalidArguments(expected, actual):
            "Invalid v0.27.0 Futures testnet operator hardening arguments. Expected \(expected); actual \(actual)."
        }
    }
}
