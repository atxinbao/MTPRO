import Crypto
import Foundation

// GH-1519-VERIFY-V0321-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS
// GH-1520-VERIFY-V0321-EVIDENCE-ROOT-MANIFEST-SHA256
// GH-1521-VERIFY-V0321-APPROVAL-SCOPE-RUN-LOCK
// GH-1522-VERIFY-V0321-CAP-VALIDATION-NEGATIVE-MATRIX
// GH-1523-VERIFY-V0321-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS
// GH-1524-VERIFY-V0321-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE
// GH-1525-VERIFY-V0321-FULL-MATRIX-BEFORE-RELEASE
// GH-1526-VERIFY-V0321-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS
// TVM-RELEASE-V0321-CONTROLLED-CANARY-INTEGRITY-PUBLICATION-GATE-REPAIR

public enum ReleaseV0321AcceptanceDecision: String, Codable, Equatable, Sendable {
    case acceptedObservedProductionCanary = "accepted-observed-production-canary"
    case blockedObservedProductionCanaryMissing = "blocked-observed-production-canary-missing"
}

public struct ReleaseV0321ArtifactRecord: Codable, Equatable, Sendable {
    public let relativePath: String
    public let sha256: String
    public let byteCount: Int
    public let kind: String
    public let product: ReleaseV0310Product?
    public let action: ReleaseV0320CanaryAction?
    public let sequence: Int?
    public let idempotencyKey: String?

    public init(
        relativePath: String,
        sha256: String,
        byteCount: Int,
        kind: String,
        product: ReleaseV0310Product? = nil,
        action: ReleaseV0320CanaryAction? = nil,
        sequence: Int? = nil,
        idempotencyKey: String? = nil
    ) {
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
        self.kind = kind
        self.product = product
        self.action = action
        self.sequence = sequence
        self.idempotencyKey = idempotencyKey
    }
}

public struct ReleaseV0321ApprovalRecord: Codable, Equatable, Sendable {
    public let approvalID: String
    public let operatorIdentity: String
    public let scope: String
    public let issuedAtEpochSeconds: Int
    public let expiresAtEpochSeconds: Int
    public let evaluatedAtEpochSeconds: Int
    public let sourceCommit: String
    public let policyVersion: String
    public let productScope: [ReleaseV0310Product]
    public let actionScope: [ReleaseV0320CanaryAction]

    public init(
        approvalID: String,
        operatorIdentity: String,
        scope: String,
        issuedAtEpochSeconds: Int,
        expiresAtEpochSeconds: Int,
        evaluatedAtEpochSeconds: Int,
        sourceCommit: String,
        policyVersion: String,
        productScope: [ReleaseV0310Product],
        actionScope: [ReleaseV0320CanaryAction]
    ) {
        self.approvalID = approvalID
        self.operatorIdentity = operatorIdentity
        self.scope = scope
        self.issuedAtEpochSeconds = issuedAtEpochSeconds
        self.expiresAtEpochSeconds = expiresAtEpochSeconds
        self.evaluatedAtEpochSeconds = evaluatedAtEpochSeconds
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
        self.productScope = productScope
        self.actionScope = actionScope
    }

    public var held: Bool {
        approvalID.hasPrefix("human_")
            && operatorIdentity.isEmpty == false
            && scope == "controlled-production-canary-integrity-repair"
            && evaluatedAtEpochSeconds >= issuedAtEpochSeconds
            && expiresAtEpochSeconds > evaluatedAtEpochSeconds
            && sourceCommit.count >= 12
            && policyVersion == ReleaseV0321ControlledCanaryIntegrityRepair.policyVersion
            && productScope == [.spot, .usdsPerpetual]
            && actionScope == [.submit, .status, .cancel]
    }
}

public struct ReleaseV0321RunLockRecord: Codable, Equatable, Sendable {
    public let runLockID: String
    public let runID: String
    public let nonce: String
    public let sourceCommit: String
    public let policyVersion: String
    public let duplicateRunRejected: Bool
    public let replayAttemptRejected: Bool
    public let staleLockRecoveryValidated: Bool
    public let lockBoundToRun: Bool

    public init(
        runLockID: String,
        runID: String,
        nonce: String,
        sourceCommit: String,
        policyVersion: String,
        duplicateRunRejected: Bool,
        replayAttemptRejected: Bool,
        staleLockRecoveryValidated: Bool,
        lockBoundToRun: Bool
    ) {
        self.runLockID = runLockID
        self.runID = runID
        self.nonce = nonce
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
        self.duplicateRunRejected = duplicateRunRejected
        self.replayAttemptRejected = replayAttemptRejected
        self.staleLockRecoveryValidated = staleLockRecoveryValidated
        self.lockBoundToRun = lockBoundToRun
    }

    public var held: Bool {
        runLockID.hasPrefix("v0321-run-lock-")
            && runID.hasPrefix("v0321-run-")
            && nonce.isEmpty == false
            && sourceCommit.count >= 12
            && policyVersion == ReleaseV0321ControlledCanaryIntegrityRepair.policyVersion
            && duplicateRunRejected
            && replayAttemptRejected
            && staleLockRecoveryValidated
            && lockBoundToRun
    }
}

public struct ReleaseV0321CapEvidenceRecord: Codable, Equatable, Sendable {
    public let product: ReleaseV0310Product
    public let maxNotionalUSDT: Decimal
    public let currentNotionalUSDT: Decimal
    public let maxLeverage: Decimal
    public let currentLeverage: Decimal
    public let maxExposureUSDT: Decimal
    public let currentExposureUSDT: Decimal
    public let maxFreshnessSeconds: Int
    public let freshnessSeconds: Int
    public let maxActionsPerRun: Int
    public let plannedActions: Int
    public let policyScope: String

    public init(
        product: ReleaseV0310Product,
        maxNotionalUSDT: Decimal,
        currentNotionalUSDT: Decimal,
        maxLeverage: Decimal,
        currentLeverage: Decimal,
        maxExposureUSDT: Decimal,
        currentExposureUSDT: Decimal,
        maxFreshnessSeconds: Int,
        freshnessSeconds: Int,
        maxActionsPerRun: Int,
        plannedActions: Int,
        policyScope: String
    ) {
        self.product = product
        self.maxNotionalUSDT = maxNotionalUSDT
        self.currentNotionalUSDT = currentNotionalUSDT
        self.maxLeverage = maxLeverage
        self.currentLeverage = currentLeverage
        self.maxExposureUSDT = maxExposureUSDT
        self.currentExposureUSDT = currentExposureUSDT
        self.maxFreshnessSeconds = maxFreshnessSeconds
        self.freshnessSeconds = freshnessSeconds
        self.maxActionsPerRun = maxActionsPerRun
        self.plannedActions = plannedActions
        self.policyScope = policyScope
    }

    public var held: Bool {
        maxNotionalUSDT > 0
            && currentNotionalUSDT > 0
            && currentNotionalUSDT <= maxNotionalUSDT
            && maxLeverage > 0
            && currentLeverage > 0
            && currentLeverage <= maxLeverage
            && maxExposureUSDT > 0
            && currentExposureUSDT >= 0
            && currentExposureUSDT <= maxExposureUSDT
            && maxFreshnessSeconds > 0
            && freshnessSeconds >= 0
            && freshnessSeconds <= maxFreshnessSeconds
            && maxActionsPerRun > 0
            && plannedActions > 0
            && plannedActions <= maxActionsPerRun
            && policyScope == "v0.32.1-controlled-canary-integrity"
    }
}

public struct ReleaseV0321OMSEvidenceRecord: Codable, Equatable, Sendable {
    public let eventLogAppendOnly: Bool
    public let monotonicEventIdentity: Bool
    public let sequenceGapRejected: Bool
    public let reconciliationReplayMatched: Bool
    public let rollbackArtifactLinked: Bool
    public let incidentStopLinked: Bool
    public let killSwitchNoTradeLinked: Bool
    public let sameRunID: Bool

    public init(
        eventLogAppendOnly: Bool,
        monotonicEventIdentity: Bool,
        sequenceGapRejected: Bool,
        reconciliationReplayMatched: Bool,
        rollbackArtifactLinked: Bool,
        incidentStopLinked: Bool,
        killSwitchNoTradeLinked: Bool,
        sameRunID: Bool
    ) {
        self.eventLogAppendOnly = eventLogAppendOnly
        self.monotonicEventIdentity = monotonicEventIdentity
        self.sequenceGapRejected = sequenceGapRejected
        self.reconciliationReplayMatched = reconciliationReplayMatched
        self.rollbackArtifactLinked = rollbackArtifactLinked
        self.incidentStopLinked = incidentStopLinked
        self.killSwitchNoTradeLinked = killSwitchNoTradeLinked
        self.sameRunID = sameRunID
    }

    public var held: Bool {
        eventLogAppendOnly
            && monotonicEventIdentity
            && sequenceGapRejected
            && reconciliationReplayMatched
            && rollbackArtifactLinked
            && incidentStopLinked
            && killSwitchNoTradeLinked
            && sameRunID
    }
}

public struct ReleaseV0321PublicationGateRecord: Codable, Equatable, Sendable {
    public let prFastChecks: ReleaseV0311ValidationStatus
    public let linuxChecks: ReleaseV0311ValidationStatus
    public let dashboardMacOS: ReleaseV0311ValidationStatus
    public let releasePublicationChecks: ReleaseV0311ValidationStatus
    public let releaseCreatedAfterFullMatrix: Bool
    public let previousV0320EarlyPublicationFindingRecorded: Bool

    public init(
        prFastChecks: ReleaseV0311ValidationStatus,
        linuxChecks: ReleaseV0311ValidationStatus,
        dashboardMacOS: ReleaseV0311ValidationStatus,
        releasePublicationChecks: ReleaseV0311ValidationStatus,
        releaseCreatedAfterFullMatrix: Bool,
        previousV0320EarlyPublicationFindingRecorded: Bool
    ) {
        self.prFastChecks = prFastChecks
        self.linuxChecks = linuxChecks
        self.dashboardMacOS = dashboardMacOS
        self.releasePublicationChecks = releasePublicationChecks
        self.releaseCreatedAfterFullMatrix = releaseCreatedAfterFullMatrix
        self.previousV0320EarlyPublicationFindingRecorded = previousV0320EarlyPublicationFindingRecorded
    }

    public var held: Bool {
        prFastChecks == .passed
            && linuxChecks == .passed
            && dashboardMacOS == .passed
            && releasePublicationChecks == .passed
            && releaseCreatedAfterFullMatrix
            && previousV0320EarlyPublicationFindingRecorded
    }
}

public struct ReleaseV0321ArtifactManifest: Codable, Equatable, Sendable {
    public let release: String
    public let runID: String
    public let sourceCommit: String
    public let policyVersion: String
    public let evidenceMode: String
    public let manifestCreatedAtEpochSeconds: Int
    public let observedProductionCanary: Bool
    public let approval: ReleaseV0321ApprovalRecord
    public let runLock: ReleaseV0321RunLockRecord
    public let artifacts: [ReleaseV0321ArtifactRecord]
    public let caps: [ReleaseV0321CapEvidenceRecord]
    public let oms: ReleaseV0321OMSEvidenceRecord
    public let publication: ReleaseV0321PublicationGateRecord

    public init(
        release: String,
        runID: String,
        sourceCommit: String,
        policyVersion: String,
        evidenceMode: String,
        manifestCreatedAtEpochSeconds: Int,
        observedProductionCanary: Bool,
        approval: ReleaseV0321ApprovalRecord,
        runLock: ReleaseV0321RunLockRecord,
        artifacts: [ReleaseV0321ArtifactRecord],
        caps: [ReleaseV0321CapEvidenceRecord],
        oms: ReleaseV0321OMSEvidenceRecord,
        publication: ReleaseV0321PublicationGateRecord
    ) {
        self.release = release
        self.runID = runID
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
        self.evidenceMode = evidenceMode
        self.manifestCreatedAtEpochSeconds = manifestCreatedAtEpochSeconds
        self.observedProductionCanary = observedProductionCanary
        self.approval = approval
        self.runLock = runLock
        self.artifacts = artifacts
        self.caps = caps
        self.oms = oms
        self.publication = publication
    }
}

public struct ReleaseV0321ValidationReport: Codable, Equatable, Sendable {
    public let release: String
    public let runID: String
    public let sourceCommit: String
    public let artifactIntegrityHeld: Bool
    public let approvalScopeHeld: Bool
    public let runLockHeld: Bool
    public let capValidationHeld: Bool
    public let uniqueOperationArtifactsHeld: Bool
    public let omsLinkageHeld: Bool
    public let publicationGateHeld: Bool
    public let observedProductionCanary: Bool
    public let acceptanceDecision: ReleaseV0321AcceptanceDecision
    public let productionCutoverAuthorized: Bool

    public var boundaryHeld: Bool {
        artifactIntegrityHeld
            && approvalScopeHeld
            && runLockHeld
            && capValidationHeld
            && uniqueOperationArtifactsHeld
            && omsLinkageHeld
            && publicationGateHeld
            && productionCutoverAuthorized == false
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "validationAnchor=\(ReleaseV0321ControlledCanaryIntegrityRepair.validationAnchor)",
            "verificationAnchor=\(ReleaseV0321ControlledCanaryIntegrityRepair.verificationAnchor)",
            "runID=\(runID)",
            "sourceCommit=\(sourceCommit)",
            "artifactIntegrityHeld=\(artifactIntegrityHeld)",
            "approvalScopeHeld=\(approvalScopeHeld)",
            "runLockHeld=\(runLockHeld)",
            "capValidationHeld=\(capValidationHeld)",
            "uniqueOperationArtifactsHeld=\(uniqueOperationArtifactsHeld)",
            "omsLinkageHeld=\(omsLinkageHeld)",
            "publicationGateHeld=\(publicationGateHeld)",
            "observedProductionCanary=\(observedProductionCanary)",
            "acceptanceDecision=\(acceptanceDecision.rawValue)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }
}

public struct ReleaseV0321ControlledCanaryIntegrityRepair: Sendable {
    public static let cliCommand = "controlled-canary-integrity-repair"
    public static let policyVersion = "v0321-controlled-canary-integrity-repair"
    public static let validationAnchor = "TVM-RELEASE-V0321-CONTROLLED-CANARY-INTEGRITY-PUBLICATION-GATE-REPAIR"
    public static let verificationAnchor = "GH-1519-VERIFY-V0321-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS"
    public static let supportedActions = [
        "status",
        "artifacts",
        "approval",
        "caps",
        "operations",
        "oms",
        "publication",
        "boundaries"
    ]
    public static let requiredAnchors = [
        "GH-1519-VERIFY-V0321-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS",
        "GH-1520-VERIFY-V0321-EVIDENCE-ROOT-MANIFEST-SHA256",
        "GH-1521-VERIFY-V0321-APPROVAL-SCOPE-RUN-LOCK",
        "GH-1522-VERIFY-V0321-CAP-VALIDATION-NEGATIVE-MATRIX",
        "GH-1523-VERIFY-V0321-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS",
        "GH-1524-VERIFY-V0321-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE",
        "GH-1525-VERIFY-V0321-FULL-MATRIX-BEFORE-RELEASE",
        "GH-1526-VERIFY-V0321-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS",
        "TVM-RELEASE-V0321-CONTROLLED-CANARY-INTEGRITY-PUBLICATION-GATE-REPAIR",
        "V0321-001-ACCEPTANCE-SEMANTICS-PUBLICATION-FACTS",
        "V0321-002-EVIDENCE-ROOT-MANIFEST-SHA256",
        "V0321-003-APPROVAL-SCOPE-RUN-LOCK",
        "V0321-004-CAP-VALIDATION-NEGATIVE-MATRIX",
        "V0321-005-UNIQUE-SPOT-FUTURES-ARTIFACT-SETS",
        "V0321-006-OMS-RECONCILIATION-ROLLBACK-INCIDENT-LINKAGE",
        "V0321-007-FULL-MATRIX-BEFORE-RELEASE",
        "V0321-008-AGGREGATE-STAGE-AUDIT-RELEASE-DOCS"
    ]

    public static func sha256Hex(for data: Data) -> String {
        "sha256:" + SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    public static func validate(
        evidenceRoot: URL,
        currentSourceCommit: String? = nil,
        maxArtifactAgeSeconds: Int? = nil,
        nowEpochSeconds: Int? = nil
    ) throws -> ReleaseV0321ValidationReport {
        let manifestURL = evidenceRoot.appendingPathComponent("manifest.json")
        let manifestData = try Data(contentsOf: manifestURL)
        let manifest = try JSONDecoder().decode(ReleaseV0321ArtifactManifest.self, from: manifestData)

        try validateManifestHeader(
            manifest,
            currentSourceCommit: currentSourceCommit,
            maxArtifactAgeSeconds: maxArtifactAgeSeconds,
            nowEpochSeconds: nowEpochSeconds
        )
        let artifactIntegrityHeld = try validateArtifacts(manifest.artifacts, evidenceRoot: evidenceRoot)
        let approvalScopeHeld = try validateApproval(manifest.approval, manifest: manifest)
        let runLockHeld = try validateRunLock(manifest.runLock, manifest: manifest)
        let capValidationHeld = try validateCaps(manifest.caps)
        let uniqueOperationArtifactsHeld = try validateOperationArtifacts(manifest.artifacts)
        let omsLinkageHeld = try validateOMS(manifest.oms)
        let publicationGateHeld = try validatePublicationGate(manifest.publication)
        let acceptanceDecision: ReleaseV0321AcceptanceDecision = manifest.observedProductionCanary
            ? .acceptedObservedProductionCanary
            : .blockedObservedProductionCanaryMissing

        return ReleaseV0321ValidationReport(
            release: manifest.release,
            runID: manifest.runID,
            sourceCommit: manifest.sourceCommit,
            artifactIntegrityHeld: artifactIntegrityHeld,
            approvalScopeHeld: approvalScopeHeld,
            runLockHeld: runLockHeld,
            capValidationHeld: capValidationHeld,
            uniqueOperationArtifactsHeld: uniqueOperationArtifactsHeld,
            omsLinkageHeld: omsLinkageHeld,
            publicationGateHeld: publicationGateHeld,
            observedProductionCanary: manifest.observedProductionCanary,
            acceptanceDecision: acceptanceDecision,
            productionCutoverAuthorized: false
        )
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|")) --artifact-root <path>",
                actual: arguments.joined(separator: " ")
            )
        }

        let action = arguments.count >= 2 ? arguments[1] : "status"
        guard supportedActions.contains(action),
              let rootFlagIndex = arguments.firstIndex(of: "--artifact-root"),
              arguments.indices.contains(rootFlagIndex + 1)
        else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|")) --artifact-root <path>",
                actual: arguments.joined(separator: " ")
            )
        }

        let report = try validate(evidenceRoot: URL(fileURLWithPath: arguments[rootFlagIndex + 1]))
        let lines: [String]
        switch action {
        case "status":
            lines = report.statusLines
        case "artifacts":
            lines = report.statusLines + ["manifestLoaded=true", "sha256Recomputed=true", "unsafePathRejected=true"]
        case "approval":
            lines = report.statusLines + ["approvalScopeBound=true", "approvalExpiryBound=true", "sourceCommitPolicyBound=true"]
        case "caps":
            lines = report.statusLines + ["zeroCapRejected=true", "negativeCapRejected=true", "productMismatchRejected=true"]
        case "operations":
            lines = report.statusLines + ["spotSubmitStatusCancelUnique=true", "futuresSubmitStatusCancelUnique=true"]
        case "oms":
            lines = report.statusLines + ["rollbackArtifactLinked=true", "incidentStopLinked=true", "reconciliationReplayMatched=true"]
        case "publication":
            lines = report.statusLines + ["releaseCreatedAfterFullMatrix=true", "v0320EarlyPublicationFindingRecorded=true"]
        case "boundaries":
            lines = report.statusLines + [
                "deterministicFixtureIsNotObservedProductionCanary=true",
                "defaultProductionTradingEnabled=false",
                "automaticSecretReadEnabled=false",
                "automaticBrokerConnectionEnabled=false",
                "okxRuntimeEnabled=false",
                "dashboardTradingButtonEnabled=false"
            ]
        default:
            lines = report.statusLines
        }

        return ([
            "mtpro \(cliCommand) \(action)",
            "commandSurface=read-only-validation",
            "unrestrictedTradingCommandCreated=false"
        ] + lines).joined(separator: "\n")
    }

    private static func validateManifestHeader(
        _ manifest: ReleaseV0321ArtifactManifest,
        currentSourceCommit: String?,
        maxArtifactAgeSeconds: Int?,
        nowEpochSeconds: Int?
    ) throws {
        guard manifest.release == "v0.32.1" else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("release must be v0.32.1")
        }
        guard manifest.runID.hasPrefix("v0321-run-") else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("runID must be v0321 scoped")
        }
        guard manifest.sourceCommit.count >= 12 else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("sourceCommit must be present")
        }
        if let currentSourceCommit, manifest.sourceCommit != currentSourceCommit {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("sourceCommit mismatch")
        }
        guard manifest.policyVersion == policyVersion else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("policyVersion mismatch")
        }
        guard manifest.evidenceMode == "explicit-artifact-root" else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("evidenceMode must be explicit artifact root")
        }
        if let maxArtifactAgeSeconds, let nowEpochSeconds {
            guard nowEpochSeconds >= manifest.manifestCreatedAtEpochSeconds else {
                throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("manifest timestamp is in the future")
            }
            guard nowEpochSeconds - manifest.manifestCreatedAtEpochSeconds <= maxArtifactAgeSeconds else {
                throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("manifest is stale")
            }
        }
    }

    private static func validateArtifacts(
        _ artifacts: [ReleaseV0321ArtifactRecord],
        evidenceRoot: URL
    ) throws -> Bool {
        guard artifacts.isEmpty == false else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("artifact list is empty")
        }
        for artifact in artifacts {
            let artifactURL = try validatedArtifactURL(evidenceRoot: evidenceRoot, relativePath: artifact.relativePath)
            let data = try Data(contentsOf: artifactURL)
            guard data.count == artifact.byteCount else {
                throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("byte count mismatch for \(artifact.relativePath)")
            }
            guard artifact.sha256.hasPrefix("sha256:"), artifact.sha256.count == 71 else {
                throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("invalid sha256 format for \(artifact.relativePath)")
            }
            guard sha256Hex(for: data) == artifact.sha256 else {
                throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("sha256 mismatch for \(artifact.relativePath)")
            }
        }
        return true
    }

    private static func validatedArtifactURL(evidenceRoot: URL, relativePath: String) throws -> URL {
        guard relativePath.isEmpty == false,
              relativePath.hasPrefix("/") == false,
              relativePath.hasPrefix("~") == false,
              relativePath.contains("\\") == false
        else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("unsafe artifact path")
        }
        let components = relativePath.split(separator: "/").map(String.init)
        guard components.isEmpty == false,
              components.contains(".") == false,
              components.contains("..") == false
        else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("unsafe artifact path")
        }

        let root = evidenceRoot.standardizedFileURL
        let rootPrefix = root.path.hasSuffix("/") ? root.path : "\(root.path)/"
        let artifactURL = components.reduce(root) { partial, component in
            partial.appendingPathComponent(component)
        }.standardizedFileURL

        guard artifactURL.path.hasPrefix(rootPrefix) else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("artifact escapes evidence root")
        }
        return artifactURL
    }

    private static func validateApproval(
        _ approval: ReleaseV0321ApprovalRecord,
        manifest: ReleaseV0321ArtifactManifest
    ) throws -> Bool {
        guard approval.held,
              approval.sourceCommit == manifest.sourceCommit,
              approval.policyVersion == manifest.policyVersion
        else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("approval scope or expiry invalid")
        }
        return true
    }

    private static func validateRunLock(
        _ runLock: ReleaseV0321RunLockRecord,
        manifest: ReleaseV0321ArtifactManifest
    ) throws -> Bool {
        guard runLock.held,
              runLock.runID == manifest.runID,
              runLock.sourceCommit == manifest.sourceCommit,
              runLock.policyVersion == manifest.policyVersion
        else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("run lock binding invalid")
        }
        return true
    }

    private static func validateCaps(_ caps: [ReleaseV0321CapEvidenceRecord]) throws -> Bool {
        guard caps.map(\.product) == [.spot, .usdsPerpetual],
              caps.allSatisfy(\.held)
        else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("cap validation failed")
        }
        return true
    }

    private static func validateOperationArtifacts(_ artifacts: [ReleaseV0321ArtifactRecord]) throws -> Bool {
        let operations = artifacts.filter { $0.kind == "operation" }
        let expected = [
            "spot:submit:1",
            "spot:status:2",
            "spot:cancel:3",
            "usdsPerpetual:submit:4",
            "usdsPerpetual:status:5",
            "usdsPerpetual:cancel:6"
        ]
        let actual = operations.compactMap { artifact -> String? in
            guard let product = artifact.product,
                  let action = artifact.action,
                  let sequence = artifact.sequence,
                  let idempotencyKey = artifact.idempotencyKey,
                  idempotencyKey.hasPrefix("v0321-canary-\(product.rawValue)-\(action.rawValue)")
            else {
                return nil
            }
            return "\(product.rawValue):\(action.rawValue):\(sequence)"
        }

        guard actual == expected,
              Set(actual).count == expected.count
        else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("operation artifact set invalid")
        }
        return true
    }

    private static func validateOMS(_ oms: ReleaseV0321OMSEvidenceRecord) throws -> Bool {
        guard oms.held else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("OMS linkage invalid")
        }
        return true
    }

    private static func validatePublicationGate(_ gate: ReleaseV0321PublicationGateRecord) throws -> Bool {
        guard gate.held else {
            throw ReleaseV0321ControlledCanaryIntegrityRepairCLIError.validationFailed("publication gate invalid")
        }
        return true
    }
}

public enum ReleaseV0321ControlledCanaryIntegrityRepairCLIError: Error, Equatable, Sendable {
    case invalidArguments(expected: String, actual: String)
    case validationFailed(String)
}
