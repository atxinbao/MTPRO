import Foundation

public enum ReleaseV0290EvidenceKind: String, Codable, Equatable, Sendable, CaseIterable {
    case contract = "contract"
    case configuration = "configuration"
    case credential = "credential"
    case endpoint = "endpoint"
    case risk = "risk"
    case omsReconciliation = "oms-reconciliation"
    case incidentRollback = "incident-rollback"
    case dashboardCLI = "dashboard-cli"
    case aggregateValidation = "aggregate-validation"
}

public enum ReleaseV0290AcceptanceState: String, Codable, Equatable, Sendable {
    case passed
    case blocked
    case failed
}

public struct ReleaseV0290ShadowAcceptanceEvidence: Codable, Equatable, Sendable {
    public let kind: ReleaseV0290EvidenceKind
    public let release: String
    public let venue: String
    public let productType: String
    public let environmentScope: String
    public let state: ReleaseV0290AcceptanceState
    public let source: String
    public let artifactPath: String
    public let checksum: String
    public let reason: String
    public let required: Bool
    public let failClosed: Bool
    public let noSubmit: Bool

    public init(
        kind: ReleaseV0290EvidenceKind,
        release: String = "v0.29.0",
        venue: String = "binance",
        productType: String,
        environmentScope: String = "production-dry-run-shadow-only",
        state: ReleaseV0290AcceptanceState,
        source: String,
        artifactPath: String,
        checksum: String,
        reason: String,
        required: Bool,
        failClosed: Bool,
        noSubmit: Bool
    ) {
        self.kind = kind
        self.release = release
        self.venue = venue
        self.productType = productType
        self.environmentScope = environmentScope
        self.state = state
        self.source = source
        self.artifactPath = artifactPath
        self.checksum = checksum
        self.reason = reason
        self.required = required
        self.failClosed = failClosed
        self.noSubmit = noSubmit
    }
}

public struct ReleaseV0290ProductionDryRunShadowAcceptance: Codable, Equatable, Sendable {
    // GH-1447-VERIFY-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE-CONTRACT
    // TVM-RELEASE-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE
    // V0290-001-BINANCE-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE
    // V0290-001-SHADOW-ACCEPTANCE-NOT-PRODUCTION-ENABLEMENT
    // V0290-001-NO-DEFAULT-TRADING
    // V0290-001-NO-SUBMIT
    // GH-1448-VERIFY-V0290-PRODUCTION-CONFIGURATION-REHEARSAL
    // V0290-002-PRODUCTION-SHADOW-CONFIGURATION
    // V0290-002-NO-SECRET-CONFIGURATION
    // V0290-002-MISMATCH-FAILS-CLOSED
    // GH-1449-VERIFY-V0290-CREDENTIAL-APPROVAL-REDACTION
    // V0290-003-CREDENTIAL-REFERENCE-ONLY
    // V0290-003-OPERATOR-APPROVAL-REQUIRED
    // V0290-003-SECRET-VALUE-NOT-PERSISTED
    // GH-1450-VERIFY-V0290-ENDPOINT-NOSUBMIT-PREFLIGHT
    // V0290-004-ENDPOINT-ALLOWLIST-READONLY
    // V0290-004-MUTATION-ENDPOINTS-BLOCKED
    // GH-1451-VERIFY-V0290-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES
    // V0290-005-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES
    // V0290-005-STALE-MISSING-INPUTS-BLOCKED
    // GH-1452-VERIFY-V0290-OMS-RECONCILIATION-DRY-RUN-BUNDLE
    // V0290-006-OMS-RECONCILIATION-SHADOW-BUNDLE
    // V0290-006-NO-BROKER-FILL-INTERPRETATION
    // GH-1453-VERIFY-V0290-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL
    // V0290-007-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL
    // V0290-007-NO-BROKER-SIDE-EFFECT
    // GH-1454-VERIFY-V0290-DASHBOARD-CLI-SHADOW-ACCEPTANCE-SURFACE
    // V0290-008-DASHBOARD-CLI-READONLY-SHADOW-SURFACE
    // V0290-008-NO-TRADING-CONTROLS
    // GH-1455-VERIFY-V0290-AGGREGATE-VALIDATION
    // V0290-009-AGGREGATE-VALIDATION
    // V0290-009-PREPUBLICATION-LINUX-MACOS-MATRIX
    // GH-1456-VERIFY-V0290-STAGE-AUDIT-RELEASE-DOCS
    // V0290-010-STAGE-AUDIT-RELEASE-DOCS
    // V0290-010-NO-PRODUCTION-CUTOVER
    // productionTradingEnabledByDefault=false
    // productionCutoverAuthorized=false
    // productionSecretAutoReadEnabled=false
    // automaticBrokerConnectionEnabled=false
    // productionSubmitCancelReplaceEnabled=false
    // futuresProductionExecutionEnabled=false
    // leverageMarginPositionMutationEnabled=false
    // okxActiveRuntimeEnabled=false
    // dashboardTradingControlsEnabled=false
    // orderFormEnabled=false
    // liveCommandEnabled=false
    // noSubmitTransportMode=true
    // shadowOnly=true
    // evidenceComplete=true
    // boundaryHeld=true

    public static let cliCommand = "production-shadow-acceptance"
    public static let supportedActions = [
        "status",
        "evidence",
        "boundaries"
    ]

    public static let validationAnchor =
        "TVM-RELEASE-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE"
    public static let verificationAnchor =
        "GH-1447-VERIFY-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE-CONTRACT"
    public static let requiredAnchors = [
        "GH-1447-VERIFY-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE-CONTRACT",
        "TVM-RELEASE-V0290-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE",
        "V0290-001-BINANCE-PRODUCTION-DRY-RUN-SHADOW-ACCEPTANCE",
        "V0290-001-SHADOW-ACCEPTANCE-NOT-PRODUCTION-ENABLEMENT",
        "V0290-001-NO-DEFAULT-TRADING",
        "V0290-001-NO-SUBMIT",
        "GH-1448-VERIFY-V0290-PRODUCTION-CONFIGURATION-REHEARSAL",
        "V0290-002-PRODUCTION-SHADOW-CONFIGURATION",
        "V0290-002-NO-SECRET-CONFIGURATION",
        "V0290-002-MISMATCH-FAILS-CLOSED",
        "GH-1449-VERIFY-V0290-CREDENTIAL-APPROVAL-REDACTION",
        "V0290-003-CREDENTIAL-REFERENCE-ONLY",
        "V0290-003-OPERATOR-APPROVAL-REQUIRED",
        "V0290-003-SECRET-VALUE-NOT-PERSISTED",
        "GH-1450-VERIFY-V0290-ENDPOINT-NOSUBMIT-PREFLIGHT",
        "V0290-004-ENDPOINT-ALLOWLIST-READONLY",
        "V0290-004-MUTATION-ENDPOINTS-BLOCKED",
        "GH-1451-VERIFY-V0290-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES",
        "V0290-005-RISK-CAPITAL-EXPOSURE-NOTIONAL-GATES",
        "V0290-005-STALE-MISSING-INPUTS-BLOCKED",
        "GH-1452-VERIFY-V0290-OMS-RECONCILIATION-DRY-RUN-BUNDLE",
        "V0290-006-OMS-RECONCILIATION-SHADOW-BUNDLE",
        "V0290-006-NO-BROKER-FILL-INTERPRETATION",
        "GH-1453-VERIFY-V0290-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL",
        "V0290-007-INCIDENT-ROLLBACK-KILL-NOTRADE-DRILL",
        "V0290-007-NO-BROKER-SIDE-EFFECT",
        "GH-1454-VERIFY-V0290-DASHBOARD-CLI-SHADOW-ACCEPTANCE-SURFACE",
        "V0290-008-DASHBOARD-CLI-READONLY-SHADOW-SURFACE",
        "V0290-008-NO-TRADING-CONTROLS",
        "GH-1455-VERIFY-V0290-AGGREGATE-VALIDATION",
        "V0290-009-AGGREGATE-VALIDATION",
        "V0290-009-PREPUBLICATION-LINUX-MACOS-MATRIX",
        "GH-1456-VERIFY-V0290-STAGE-AUDIT-RELEASE-DOCS",
        "V0290-010-STAGE-AUDIT-RELEASE-DOCS",
        "V0290-010-NO-PRODUCTION-CUTOVER"
    ]

    public let release: String
    public let prerequisitePatchRelease: String
    public let venue: String
    public let productTypes: [String]
    public let environmentScope: String
    public let runID: String
    public let acceptanceMode: String
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let automaticBrokerConnectionEnabled: Bool
    public let productionSubmitCancelReplaceEnabled: Bool
    public let futuresProductionExecutionEnabled: Bool
    public let leverageMarginPositionMutationEnabled: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let humanApprovalRequired: Bool
    public let redactionRequired: Bool
    public let endpointAllowlistRequired: Bool
    public let noSubmitTransportMode: Bool
    public let shadowOnly: Bool
    public let artifactBundleChecksum: String
    public let sbomOrProvenanceEvidence: String
    public let linuxMatrixRequired: Bool
    public let macOSMatrixRequired: Bool
    public let evidence: [ReleaseV0290ShadowAcceptanceEvidence]

    public init(
        release: String,
        prerequisitePatchRelease: String,
        venue: String,
        productTypes: [String],
        environmentScope: String,
        runID: String,
        acceptanceMode: String,
        productionTradingEnabledByDefault: Bool,
        productionCutoverAuthorized: Bool,
        productionSecretAutoReadEnabled: Bool,
        automaticBrokerConnectionEnabled: Bool,
        productionSubmitCancelReplaceEnabled: Bool,
        futuresProductionExecutionEnabled: Bool,
        leverageMarginPositionMutationEnabled: Bool,
        okxActiveRuntimeEnabled: Bool,
        dashboardTradingControlsEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        humanApprovalRequired: Bool,
        redactionRequired: Bool,
        endpointAllowlistRequired: Bool,
        noSubmitTransportMode: Bool,
        shadowOnly: Bool,
        artifactBundleChecksum: String,
        sbomOrProvenanceEvidence: String,
        linuxMatrixRequired: Bool,
        macOSMatrixRequired: Bool,
        evidence: [ReleaseV0290ShadowAcceptanceEvidence]
    ) {
        self.release = release
        self.prerequisitePatchRelease = prerequisitePatchRelease
        self.venue = venue
        self.productTypes = productTypes
        self.environmentScope = environmentScope
        self.runID = runID
        self.acceptanceMode = acceptanceMode
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.automaticBrokerConnectionEnabled = automaticBrokerConnectionEnabled
        self.productionSubmitCancelReplaceEnabled = productionSubmitCancelReplaceEnabled
        self.futuresProductionExecutionEnabled = futuresProductionExecutionEnabled
        self.leverageMarginPositionMutationEnabled = leverageMarginPositionMutationEnabled
        self.okxActiveRuntimeEnabled = okxActiveRuntimeEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.humanApprovalRequired = humanApprovalRequired
        self.redactionRequired = redactionRequired
        self.endpointAllowlistRequired = endpointAllowlistRequired
        self.noSubmitTransportMode = noSubmitTransportMode
        self.shadowOnly = shadowOnly
        self.artifactBundleChecksum = artifactBundleChecksum
        self.sbomOrProvenanceEvidence = sbomOrProvenanceEvidence
        self.linuxMatrixRequired = linuxMatrixRequired
        self.macOSMatrixRequired = macOSMatrixRequired
        self.evidence = evidence
    }

    public static var deterministicFixture: Self {
        let products = ["spot", "usdsPerpetual"]
        let evidence = products.flatMap { product in
            ReleaseV0290EvidenceKind.allCases.map { kind in
                ReleaseV0290ShadowAcceptanceEvidence(
                    kind: kind,
                    productType: product,
                    state: kind == .endpoint ? .blocked : .passed,
                    source: "v0.29.0-production-dry-run-shadow-acceptance",
                    artifactPath: "artifacts/v0.29.0/\(product)/\(kind.rawValue).json",
                    checksum: "sha256:v0.29.0-\(product)-\(kind.rawValue)",
                    reason: reason(for: kind, productType: product),
                    required: true,
                    failClosed: true,
                    noSubmit: true
                )
            }
        }

        return Self(
            release: "v0.29.0",
            prerequisitePatchRelease: "v0.28.1",
            venue: "binance",
            productTypes: products,
            environmentScope: "production-dry-run-shadow-only",
            runID: "v0.29.0-binance-production-shadow-dry-run",
            acceptanceMode: "dry-run-shadow-acceptance",
            productionTradingEnabledByDefault: false,
            productionCutoverAuthorized: false,
            productionSecretAutoReadEnabled: false,
            automaticBrokerConnectionEnabled: false,
            productionSubmitCancelReplaceEnabled: false,
            futuresProductionExecutionEnabled: false,
            leverageMarginPositionMutationEnabled: false,
            okxActiveRuntimeEnabled: false,
            dashboardTradingControlsEnabled: false,
            orderFormEnabled: false,
            liveCommandEnabled: false,
            humanApprovalRequired: true,
            redactionRequired: true,
            endpointAllowlistRequired: true,
            noSubmitTransportMode: true,
            shadowOnly: true,
            artifactBundleChecksum: "sha256:v0.29.0-production-shadow-acceptance-bundle",
            sbomOrProvenanceEvidence: "release-v0.29.0-prepublication-linux-macos-matrix",
            linuxMatrixRequired: true,
            macOSMatrixRequired: true,
            evidence: evidence
        )
    }

    public var evidenceComplete: Bool {
        guard productTypes == ["spot", "usdsPerpetual"],
              venue == "binance",
              environmentScope == "production-dry-run-shadow-only",
              !evidence.isEmpty else {
            return false
        }

        let expectedProducts = Set(productTypes)
        let expectedKinds = Set(ReleaseV0290EvidenceKind.allCases)
        var observed = Set<String>()

        for item in evidence {
            let pair = "\(item.productType)::\(item.kind.rawValue)"
            guard observed.insert(pair).inserted else {
                return false
            }
            guard expectedProducts.contains(item.productType),
                  expectedKinds.contains(item.kind),
                  item.release == release,
                  item.venue == venue,
                  item.environmentScope == environmentScope,
                  item.state != .failed,
                  item.required,
                  item.failClosed,
                  item.noSubmit else {
                return false
            }
            guard !item.source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !item.artifactPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !item.checksum.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !item.reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return false
            }
        }

        return observed.count == expectedProducts.count * expectedKinds.count
    }

    public var boundaryHeld: Bool {
        prerequisitePatchRelease == "v0.28.1"
            && productTypes == ["spot", "usdsPerpetual"]
            && venue == "binance"
            && environmentScope == "production-dry-run-shadow-only"
            && acceptanceMode == "dry-run-shadow-acceptance"
            && !productionTradingEnabledByDefault
            && !productionCutoverAuthorized
            && !productionSecretAutoReadEnabled
            && !automaticBrokerConnectionEnabled
            && !productionSubmitCancelReplaceEnabled
            && !futuresProductionExecutionEnabled
            && !leverageMarginPositionMutationEnabled
            && !okxActiveRuntimeEnabled
            && !dashboardTradingControlsEnabled
            && !orderFormEnabled
            && !liveCommandEnabled
            && humanApprovalRequired
            && redactionRequired
            && endpointAllowlistRequired
            && noSubmitTransportMode
            && shadowOnly
            && linuxMatrixRequired
            && macOSMatrixRequired
            && !artifactBundleChecksum.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !sbomOrProvenanceEvidence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && evidenceComplete
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "releaseSummary=Binance production dry-run shadow acceptance",
            "prerequisitePatchRelease=\(prerequisitePatchRelease)",
            "venue=\(venue)",
            "productTypes=\(productTypes.joined(separator: ","))",
            "environmentScope=\(environmentScope)",
            "runID=\(runID)",
            "acceptanceMode=\(acceptanceMode)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "requiredAnchors=\(Self.requiredAnchors.joined(separator: ","))",
            "artifactBundleChecksum=\(artifactBundleChecksum)",
            "sbomOrProvenanceEvidence=\(sbomOrProvenanceEvidence)",
            "evidenceComplete=\(evidenceComplete)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var evidenceLines: [String] {
        evidence.map {
            "evidence=kind:\($0.kind.rawValue);release:\($0.release);venue:\($0.venue);productType:\($0.productType);environmentScope:\($0.environmentScope);state:\($0.state.rawValue);source:\($0.source);artifactPath:\($0.artifactPath);checksum:\($0.checksum);required:\($0.required);failClosed:\($0.failClosed);noSubmit:\($0.noSubmit);reason:\($0.reason)"
        }
    }

    public var boundaryLines: [String] {
        [
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "productionSecretAutoReadEnabled=\(productionSecretAutoReadEnabled)",
            "automaticBrokerConnectionEnabled=\(automaticBrokerConnectionEnabled)",
            "productionSubmitCancelReplaceEnabled=\(productionSubmitCancelReplaceEnabled)",
            "futuresProductionExecutionEnabled=\(futuresProductionExecutionEnabled)",
            "leverageMarginPositionMutationEnabled=\(leverageMarginPositionMutationEnabled)",
            "okxActiveRuntimeEnabled=\(okxActiveRuntimeEnabled)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "orderFormEnabled=\(orderFormEnabled)",
            "liveCommandEnabled=\(liveCommandEnabled)",
            "humanApprovalRequired=\(humanApprovalRequired)",
            "redactionRequired=\(redactionRequired)",
            "endpointAllowlistRequired=\(endpointAllowlistRequired)",
            "noSubmitTransportMode=\(noSubmitTransportMode)",
            "shadowOnly=\(shadowOnly)",
            "linuxMatrixRequired=\(linuxMatrixRequired)",
            "macOSMatrixRequired=\(macOSMatrixRequired)"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0290ProductionDryRunShadowAcceptanceCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let action = arguments.dropFirst().first ?? "status"

        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0290ProductionDryRunShadowAcceptanceCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let lines: [String]
        switch action {
        case "status":
            lines = evidence.statusLines
        case "evidence":
            lines = evidence.evidenceLines
        case "boundaries":
            lines = evidence.boundaryLines
        default:
            lines = evidence.statusLines
        }

        return lines.joined(separator: "\n")
    }

    private static func reason(
        for kind: ReleaseV0290EvidenceKind,
        productType: String
    ) -> String {
        switch kind {
        case .contract:
            "v0.29.0 accepts \(productType) production dry-run shadow evidence only; production cutover remains unauthorized."
        case .configuration:
            "\(productType) production configuration rehearsal is no-submit and fail-closed on mismatches."
        case .credential:
            "\(productType) credential evidence stores reference and approval metadata only; secret values are not persisted."
        case .endpoint:
            "\(productType) endpoint preflight is read-only and blocks mutation paths."
        case .risk:
            "\(productType) risk, capital, exposure and notional gates must be present before any later canary."
        case .omsReconciliation:
            "\(productType) OMS and reconciliation bundle is dry-run shadow evidence, not broker fill evidence."
        case .incidentRollback:
            "\(productType) incident, rollback, no-trade and kill-switch drill evidence is required and fail-closed."
        case .dashboardCLI:
            "\(productType) Dashboard and CLI expose read-only shadow acceptance without trading controls."
        case .aggregateValidation:
            "\(productType) aggregate validation requires focused tests, Linux checks and macOS Dashboard smoke."
        }
    }
}

public enum ReleaseV0290ProductionDryRunShadowAcceptanceCLIError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidArguments(expected: String, actual: String)

    public var errorDescription: String? {
        switch self {
        case let .invalidArguments(expected, actual):
            "Invalid v0.29.0 production dry-run shadow acceptance arguments. Expected \(expected); actual \(actual)."
        }
    }
}
