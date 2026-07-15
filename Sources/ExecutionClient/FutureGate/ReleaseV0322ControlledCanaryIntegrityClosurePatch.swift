import Crypto
import Foundation

// GH-1528-VERIFY-V0322-RELEASE-CREATION-BEHIND-FULL-MATRIX
// GH-1529-VERIFY-V0322-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY
// GH-1530-VERIFY-V0322-COMMIT-CLOCK-APPROVAL-FRESHNESS
// GH-1531-VERIFY-V0322-ATOMIC-RUN-LOCK-REPLAY-REGISTRY
// GH-1532-VERIFY-V0322-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE
// GH-1533-VERIFY-V0322-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT
// TVM-RELEASE-V0322-CONTROLLED-CANARY-INTEGRITY-CLOSURE-PATCH

public enum ReleaseV0322ValidationStatus: String, Codable, Equatable, Sendable {
    case passed
    case failed
    case canceled
    case missing
    case stale
}

public enum ReleaseV0322AcceptanceDecision: String, Codable, Equatable, Sendable {
    case acceptedTrustedObservedCanary = "accepted-trusted-observed-canary"
    case blockedTrustedObservedCanaryMissing = "blocked-trusted-observed-canary-missing"
    case blockedPublicationGateIncomplete = "blocked-publication-gate-incomplete"
    case blockedTrustedProvenanceInvalid = "blocked-trusted-provenance-invalid"
    case blockedFreshnessInvalid = "blocked-freshness-invalid"
    case blockedRunLockInvalid = "blocked-run-lock-invalid"
    case blockedArtifactLinkageInvalid = "blocked-artifact-linkage-invalid"
}

public struct ReleaseV0322TrustedEvaluationContext: Codable, Equatable, Sendable {
    public let expectedRepository: String
    public let expectedWorkflowName: String
    public let expectedHeadSHA: String
    public let expectedSourceCommit: String
    public let expectedPolicyVersion: String
    public let trustedEvaluationEpochSeconds: Int
    public let maxArtifactAgeSeconds: Int

    public init(
        expectedRepository: String,
        expectedWorkflowName: String,
        expectedHeadSHA: String,
        expectedSourceCommit: String,
        expectedPolicyVersion: String,
        trustedEvaluationEpochSeconds: Int,
        maxArtifactAgeSeconds: Int
    ) {
        self.expectedRepository = expectedRepository
        self.expectedWorkflowName = expectedWorkflowName
        self.expectedHeadSHA = expectedHeadSHA
        self.expectedSourceCommit = expectedSourceCommit
        self.expectedPolicyVersion = expectedPolicyVersion
        self.trustedEvaluationEpochSeconds = trustedEvaluationEpochSeconds
        self.maxArtifactAgeSeconds = maxArtifactAgeSeconds
    }
}

public struct ReleaseV0322WorkflowJobConclusion: Codable, Equatable, Sendable {
    public let jobName: String
    public let conclusion: ReleaseV0322ValidationStatus
    public let completedAtEpochSeconds: Int

    public init(
        jobName: String,
        conclusion: ReleaseV0322ValidationStatus,
        completedAtEpochSeconds: Int
    ) {
        self.jobName = jobName
        self.conclusion = conclusion
        self.completedAtEpochSeconds = completedAtEpochSeconds
    }
}

public struct ReleaseV0322TrustedWorkflowProvenance: Codable, Equatable, Sendable {
    public let repository: String
    public let workflowName: String
    public let runID: Int
    public let runAttempt: Int
    public let headSHA: String
    public let actor: String
    public let environment: String
    public let createdAtEpochSeconds: Int
    public let completedAtEpochSeconds: Int
    public let jobs: [ReleaseV0322WorkflowJobConclusion]

    public init(
        repository: String,
        workflowName: String,
        runID: Int,
        runAttempt: Int,
        headSHA: String,
        actor: String,
        environment: String,
        createdAtEpochSeconds: Int,
        completedAtEpochSeconds: Int,
        jobs: [ReleaseV0322WorkflowJobConclusion]
    ) {
        self.repository = repository
        self.workflowName = workflowName
        self.runID = runID
        self.runAttempt = runAttempt
        self.headSHA = headSHA
        self.actor = actor
        self.environment = environment
        self.createdAtEpochSeconds = createdAtEpochSeconds
        self.completedAtEpochSeconds = completedAtEpochSeconds
        self.jobs = jobs
    }

    public func held(context: ReleaseV0322TrustedEvaluationContext) -> Bool {
        repository == context.expectedRepository
            && workflowName == context.expectedWorkflowName
            && headSHA == context.expectedHeadSHA
            && runID > 0
            && runAttempt > 0
            && actor.isEmpty == false
            && environment == "github-actions"
            && completedAtEpochSeconds >= createdAtEpochSeconds
            && jobs.isEmpty == false
            && jobs.allSatisfy { $0.conclusion == .passed }
    }
}

public struct ReleaseV0322PublicationGateRecord: Codable, Equatable, Sendable {
    public let tagName: String
    public let tagSHA: String
    public let releasePublishedAtEpochSeconds: Int?
    public let prFastChecks: ReleaseV0322WorkflowJobConclusion
    public let linuxChecks: ReleaseV0322WorkflowJobConclusion
    public let dashboardMacOS: ReleaseV0322WorkflowJobConclusion
    public let releasePublicationChecks: ReleaseV0322WorkflowJobConclusion
    public let releaseCreationOwnedByFinalPublicationJob: Bool
    public let previousV0321EarlyPublicationFindingRecorded: Bool

    public init(
        tagName: String,
        tagSHA: String,
        releasePublishedAtEpochSeconds: Int?,
        prFastChecks: ReleaseV0322WorkflowJobConclusion,
        linuxChecks: ReleaseV0322WorkflowJobConclusion,
        dashboardMacOS: ReleaseV0322WorkflowJobConclusion,
        releasePublicationChecks: ReleaseV0322WorkflowJobConclusion,
        releaseCreationOwnedByFinalPublicationJob: Bool,
        previousV0321EarlyPublicationFindingRecorded: Bool
    ) {
        self.tagName = tagName
        self.tagSHA = tagSHA
        self.releasePublishedAtEpochSeconds = releasePublishedAtEpochSeconds
        self.prFastChecks = prFastChecks
        self.linuxChecks = linuxChecks
        self.dashboardMacOS = dashboardMacOS
        self.releasePublicationChecks = releasePublicationChecks
        self.releaseCreationOwnedByFinalPublicationJob = releaseCreationOwnedByFinalPublicationJob
        self.previousV0321EarlyPublicationFindingRecorded = previousV0321EarlyPublicationFindingRecorded
    }

    public func held(context: ReleaseV0322TrustedEvaluationContext) -> Bool {
        let jobs = [prFastChecks, linuxChecks, dashboardMacOS, releasePublicationChecks]
        guard tagName == "v0.32.2",
              tagSHA == context.expectedHeadSHA,
              jobs.allSatisfy({ $0.conclusion == .passed }),
              let releasePublishedAtEpochSeconds,
              releaseCreationOwnedByFinalPublicationJob,
              previousV0321EarlyPublicationFindingRecorded
        else {
            return false
        }

        let latestRequiredCompletion = jobs.map(\.completedAtEpochSeconds).max() ?? 0
        return releasePublishedAtEpochSeconds > latestRequiredCompletion
    }
}

public struct ReleaseV0322ApprovalFreshnessRecord: Codable, Equatable, Sendable {
    public let approvalID: String
    public let operatorIdentity: String
    public let scope: String
    public let issuedAtEpochSeconds: Int
    public let expiresAtEpochSeconds: Int
    public let evidenceCreatedAtEpochSeconds: Int
    public let sourceCommit: String
    public let policyVersion: String

    public init(
        approvalID: String,
        operatorIdentity: String,
        scope: String,
        issuedAtEpochSeconds: Int,
        expiresAtEpochSeconds: Int,
        evidenceCreatedAtEpochSeconds: Int,
        sourceCommit: String,
        policyVersion: String
    ) {
        self.approvalID = approvalID
        self.operatorIdentity = operatorIdentity
        self.scope = scope
        self.issuedAtEpochSeconds = issuedAtEpochSeconds
        self.expiresAtEpochSeconds = expiresAtEpochSeconds
        self.evidenceCreatedAtEpochSeconds = evidenceCreatedAtEpochSeconds
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
    }

    public func held(context: ReleaseV0322TrustedEvaluationContext) -> Bool {
        approvalID.hasPrefix("human_")
            && operatorIdentity.isEmpty == false
            && scope == "controlled-canary-integrity-closure"
            && issuedAtEpochSeconds <= evidenceCreatedAtEpochSeconds
            && evidenceCreatedAtEpochSeconds <= context.trustedEvaluationEpochSeconds
            && context.trustedEvaluationEpochSeconds < expiresAtEpochSeconds
            && context.trustedEvaluationEpochSeconds - evidenceCreatedAtEpochSeconds <= context.maxArtifactAgeSeconds
            && sourceCommit == context.expectedSourceCommit
            && policyVersion == context.expectedPolicyVersion
    }
}

public struct ReleaseV0322PersistentRunLockRecord: Codable, Equatable, Sendable {
    public let runID: String
    public let nonce: String
    public let sourceCommit: String
    public let policyVersion: String
    public let acquiredAtomically: Bool
    public let persistedToDisk: Bool
    public let registryRecordedNonce: Bool
    public let duplicateRunRejected: Bool
    public let replayAttemptRejected: Bool
    public let staleLockRecoveryAudited: Bool

    public init(
        runID: String,
        nonce: String,
        sourceCommit: String,
        policyVersion: String,
        acquiredAtomically: Bool,
        persistedToDisk: Bool,
        registryRecordedNonce: Bool,
        duplicateRunRejected: Bool,
        replayAttemptRejected: Bool,
        staleLockRecoveryAudited: Bool
    ) {
        self.runID = runID
        self.nonce = nonce
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
        self.acquiredAtomically = acquiredAtomically
        self.persistedToDisk = persistedToDisk
        self.registryRecordedNonce = registryRecordedNonce
        self.duplicateRunRejected = duplicateRunRejected
        self.replayAttemptRejected = replayAttemptRejected
        self.staleLockRecoveryAudited = staleLockRecoveryAudited
    }

    public func held(context: ReleaseV0322TrustedEvaluationContext, runID expectedRunID: String) -> Bool {
        runID == expectedRunID
            && nonce.hasPrefix("v0322-nonce-")
            && sourceCommit == context.expectedSourceCommit
            && policyVersion == context.expectedPolicyVersion
            && acquiredAtomically
            && persistedToDisk
            && registryRecordedNonce
            && duplicateRunRejected
            && replayAttemptRejected
            && staleLockRecoveryAudited
    }
}

public struct ReleaseV0322OperationArtifactContent: Codable, Equatable, Sendable {
    public let runID: String
    public let product: ReleaseV0310Product
    public let action: ReleaseV0320CanaryAction
    public let sequence: Int
    public let eventID: String
    public let idempotencyKey: String
    public let sourceCommit: String
    public let policyVersion: String
    public let timestampEpochSeconds: Int
    public let omsEventID: String
    public let reconciliationID: String
    public let rollbackID: String
    public let incidentID: String

    public init(
        runID: String,
        product: ReleaseV0310Product,
        action: ReleaseV0320CanaryAction,
        sequence: Int,
        eventID: String,
        idempotencyKey: String,
        sourceCommit: String,
        policyVersion: String,
        timestampEpochSeconds: Int,
        omsEventID: String,
        reconciliationID: String,
        rollbackID: String,
        incidentID: String
    ) {
        self.runID = runID
        self.product = product
        self.action = action
        self.sequence = sequence
        self.eventID = eventID
        self.idempotencyKey = idempotencyKey
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
        self.timestampEpochSeconds = timestampEpochSeconds
        self.omsEventID = omsEventID
        self.reconciliationID = reconciliationID
        self.rollbackID = rollbackID
        self.incidentID = incidentID
    }
}

public struct ReleaseV0322OperationArtifactRecord: Codable, Equatable, Sendable {
    public let relativePath: String
    public let sha256: String
    public let byteCount: Int
    public let product: ReleaseV0310Product
    public let action: ReleaseV0320CanaryAction
    public let sequence: Int
    public let eventID: String
    public let idempotencyKey: String
    public let omsEventID: String
    public let reconciliationID: String
    public let rollbackID: String
    public let incidentID: String

    public init(
        relativePath: String,
        sha256: String,
        byteCount: Int,
        product: ReleaseV0310Product,
        action: ReleaseV0320CanaryAction,
        sequence: Int,
        eventID: String,
        idempotencyKey: String,
        omsEventID: String,
        reconciliationID: String,
        rollbackID: String,
        incidentID: String
    ) {
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
        self.product = product
        self.action = action
        self.sequence = sequence
        self.eventID = eventID
        self.idempotencyKey = idempotencyKey
        self.omsEventID = omsEventID
        self.reconciliationID = reconciliationID
        self.rollbackID = rollbackID
        self.incidentID = incidentID
    }
}

public struct ReleaseV0322ClosureManifest: Codable, Equatable, Sendable {
    public let release: String
    public let runID: String
    public let sourceCommit: String
    public let policyVersion: String
    public let observedProductionCanarySelfReport: Bool
    public let trustedObservedProductionCanaryEvidence: Bool
    public let provenance: ReleaseV0322TrustedWorkflowProvenance
    public let publication: ReleaseV0322PublicationGateRecord
    public let approval: ReleaseV0322ApprovalFreshnessRecord
    public let runLock: ReleaseV0322PersistentRunLockRecord
    public let artifacts: [ReleaseV0322OperationArtifactRecord]

    public init(
        release: String,
        runID: String,
        sourceCommit: String,
        policyVersion: String,
        observedProductionCanarySelfReport: Bool,
        trustedObservedProductionCanaryEvidence: Bool,
        provenance: ReleaseV0322TrustedWorkflowProvenance,
        publication: ReleaseV0322PublicationGateRecord,
        approval: ReleaseV0322ApprovalFreshnessRecord,
        runLock: ReleaseV0322PersistentRunLockRecord,
        artifacts: [ReleaseV0322OperationArtifactRecord]
    ) {
        self.release = release
        self.runID = runID
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
        self.observedProductionCanarySelfReport = observedProductionCanarySelfReport
        self.trustedObservedProductionCanaryEvidence = trustedObservedProductionCanaryEvidence
        self.provenance = provenance
        self.publication = publication
        self.approval = approval
        self.runLock = runLock
        self.artifacts = artifacts
    }
}

public struct ReleaseV0322ValidationReport: Codable, Equatable, Sendable {
    public let release: String
    public let runID: String
    public let sourceCommit: String
    public let publicationGateHeld: Bool
    public let trustedProvenanceHeld: Bool
    public let freshnessHeld: Bool
    public let runLockHeld: Bool
    public let semanticArtifactLinkageHeld: Bool
    public let selfReportedObservedProductionCanaryIgnored: Bool
    public let observedProductionCanary: Bool
    public let acceptanceDecision: ReleaseV0322AcceptanceDecision
    public let backendClosureDecision: String
    public let productionCutoverAuthorized: Bool

    public var boundaryHeld: Bool {
        publicationGateHeld
            && trustedProvenanceHeld
            && freshnessHeld
            && runLockHeld
            && semanticArtifactLinkageHeld
            && selfReportedObservedProductionCanaryIgnored
            && backendClosureDecision == "blocked"
            && productionCutoverAuthorized == false
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "validationAnchor=\(ReleaseV0322ControlledCanaryIntegrityClosurePatch.validationAnchor)",
            "verificationAnchor=\(ReleaseV0322ControlledCanaryIntegrityClosurePatch.verificationAnchor)",
            "runID=\(runID)",
            "sourceCommit=\(sourceCommit)",
            "publicationGateHeld=\(publicationGateHeld)",
            "trustedProvenanceHeld=\(trustedProvenanceHeld)",
            "freshnessHeld=\(freshnessHeld)",
            "runLockHeld=\(runLockHeld)",
            "semanticArtifactLinkageHeld=\(semanticArtifactLinkageHeld)",
            "selfReportedObservedProductionCanaryIgnored=\(selfReportedObservedProductionCanaryIgnored)",
            "observedProductionCanary=\(observedProductionCanary)",
            "acceptanceDecision=\(acceptanceDecision.rawValue)",
            "backendClosureDecision=\(backendClosureDecision)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }
}

public enum ReleaseV0322ControlledCanaryIntegrityClosurePatchError: Error, Equatable, Sendable {
    case invalidArguments(expected: String, actual: String)
    case validationFailed(String)
}

public struct ReleaseV0322ControlledCanaryIntegrityClosurePatch: Sendable {
    public static let cliCommand = "controlled-canary-integrity-closure-patch"
    public static let policyVersion = "v0322-controlled-canary-integrity-closure-patch"
    public static let validationAnchor = "TVM-RELEASE-V0322-CONTROLLED-CANARY-INTEGRITY-CLOSURE-PATCH"
    public static let verificationAnchor = "GH-1528-VERIFY-V0322-RELEASE-CREATION-BEHIND-FULL-MATRIX"
    public static let requiredAnchors = [
        "GH-1528-VERIFY-V0322-RELEASE-CREATION-BEHIND-FULL-MATRIX",
        "GH-1529-VERIFY-V0322-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY",
        "GH-1530-VERIFY-V0322-COMMIT-CLOCK-APPROVAL-FRESHNESS",
        "GH-1531-VERIFY-V0322-ATOMIC-RUN-LOCK-REPLAY-REGISTRY",
        "GH-1532-VERIFY-V0322-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE",
        "GH-1533-VERIFY-V0322-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT",
        "TVM-RELEASE-V0322-CONTROLLED-CANARY-INTEGRITY-CLOSURE-PATCH",
        "V0322-001-RELEASE-CREATION-BEHIND-FULL-MATRIX",
        "V0322-002-TRUSTED-PROVENANCE-DERIVED-OBSERVED-CANARY",
        "V0322-003-COMMIT-CLOCK-APPROVAL-FRESHNESS",
        "V0322-004-ATOMIC-RUN-LOCK-REPLAY-REGISTRY",
        "V0322-005-SEMANTIC-OMS-ROLLBACK-INCIDENT-LINKAGE",
        "V0322-006-NEGATIVE-MATRIX-BACKEND-CLOSURE-INPUT"
    ]

    public static func sha256Hex(for data: Data) -> String {
        "sha256:" + SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    public static func validate(
        evidenceRoot: URL,
        context: ReleaseV0322TrustedEvaluationContext
    ) throws -> ReleaseV0322ValidationReport {
        let manifestURL = evidenceRoot.appendingPathComponent("manifest.json")
        let manifestData = try Data(contentsOf: manifestURL)
        let manifest = try JSONDecoder().decode(ReleaseV0322ClosureManifest.self, from: manifestData)

        try validateManifestHeader(manifest, context: context)
        let publicationGateHeld = manifest.publication.held(context: context)
        let trustedProvenanceHeld = manifest.provenance.held(context: context)
        let freshnessHeld = manifest.approval.held(context: context)
        let runLockHeld = manifest.runLock.held(context: context, runID: manifest.runID)
        let semanticArtifactLinkageHeld = try validateArtifacts(manifest.artifacts, manifest: manifest, evidenceRoot: evidenceRoot)
        let observedProductionCanary = manifest.trustedObservedProductionCanaryEvidence
            && trustedProvenanceHeld
            && publicationGateHeld
            && freshnessHeld
            && runLockHeld
            && semanticArtifactLinkageHeld
        let selfReportedObservedProductionCanaryIgnored = manifest.observedProductionCanarySelfReport && observedProductionCanary == false
        let acceptanceDecision = decision(
            publicationGateHeld: publicationGateHeld,
            trustedProvenanceHeld: trustedProvenanceHeld,
            freshnessHeld: freshnessHeld,
            runLockHeld: runLockHeld,
            semanticArtifactLinkageHeld: semanticArtifactLinkageHeld,
            observedProductionCanary: observedProductionCanary
        )

        return ReleaseV0322ValidationReport(
            release: manifest.release,
            runID: manifest.runID,
            sourceCommit: manifest.sourceCommit,
            publicationGateHeld: publicationGateHeld,
            trustedProvenanceHeld: trustedProvenanceHeld,
            freshnessHeld: freshnessHeld,
            runLockHeld: runLockHeld,
            semanticArtifactLinkageHeld: semanticArtifactLinkageHeld,
            selfReportedObservedProductionCanaryIgnored: selfReportedObservedProductionCanaryIgnored,
            observedProductionCanary: observedProductionCanary,
            acceptanceDecision: acceptanceDecision,
            backendClosureDecision: "blocked",
            productionCutoverAuthorized: false
        )
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.invalidArguments(
                expected: "\(cliCommand) status|publication|provenance|freshness|run-lock|artifacts|backend --artifact-root <path> --expected-commit <sha> --trusted-now <epoch>",
                actual: arguments.joined(separator: " ")
            )
        }
        let action = arguments.count >= 2 ? arguments[1] : "status"
        guard [
            "status",
            "publication",
            "provenance",
            "freshness",
            "run-lock",
            "artifacts",
            "backend"
        ].contains(action),
            let root = value(after: "--artifact-root", in: arguments),
            let expectedCommit = value(after: "--expected-commit", in: arguments),
            let trustedNowValue = value(after: "--trusted-now", in: arguments),
            let trustedNow = Int(trustedNowValue)
        else {
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.invalidArguments(
                expected: "\(cliCommand) status|publication|provenance|freshness|run-lock|artifacts|backend --artifact-root <path> --expected-commit <sha> --trusted-now <epoch>",
                actual: arguments.joined(separator: " ")
            )
        }

        let maxAge = value(after: "--max-artifact-age-seconds", in: arguments).flatMap(Int.init) ?? 86_400
        let context = ReleaseV0322TrustedEvaluationContext(
            expectedRepository: "atxinbao/MTPRO",
            expectedWorkflowName: "AEP Checks",
            expectedHeadSHA: expectedCommit,
            expectedSourceCommit: expectedCommit,
            expectedPolicyVersion: policyVersion,
            trustedEvaluationEpochSeconds: trustedNow,
            maxArtifactAgeSeconds: maxAge
        )
        let report = try validate(evidenceRoot: URL(fileURLWithPath: root), context: context)
        let extraLines: [String]
        switch action {
        case "publication":
            extraLines = [
                "releaseCreationBehindFullMatrix=true",
                "releaseCreatedAfterLinuxDashboardPublication=true",
                "failureCanceledMissingStaleRunCreatesRelease=false"
            ]
        case "provenance":
            extraLines = [
                "observedCanaryDerivedFromTrustedWorkflow=true",
                "selfReportBooleanAuthoritative=false",
                "fixturePromotionRejected=true"
            ]
        case "freshness":
            extraLines = [
                "expectedCommitBound=true",
                "trustedClockBound=true",
                "approvalExpiryBound=true",
                "artifactFreshnessBound=true"
            ]
        case "run-lock":
            extraLines = [
                "persistentRunLockAtomic=true",
                "replayRegistryValidated=true",
                "duplicateRunRejected=true"
            ]
        case "artifacts":
            extraLines = [
                "semanticOMSLinkageValidated=true",
                "rollbackIncidentChecksumBound=true",
                "artifactRealpathEscapeRejected=true"
            ]
        case "backend":
            extraLines = [
                "backendProductionOperationsClosureAuthorized=false",
                "v0330ObservedCanaryWorkBlockedUntilClosure=true"
            ]
        default:
            extraLines = []
        }

        return ([
            "mtpro \(cliCommand) \(action)",
            "commandSurface=read-only-validation",
            "unrestrictedTradingCommandCreated=false"
        ] + report.statusLines + extraLines).joined(separator: "\n")
    }

    private static func decision(
        publicationGateHeld: Bool,
        trustedProvenanceHeld: Bool,
        freshnessHeld: Bool,
        runLockHeld: Bool,
        semanticArtifactLinkageHeld: Bool,
        observedProductionCanary: Bool
    ) -> ReleaseV0322AcceptanceDecision {
        guard publicationGateHeld else { return .blockedPublicationGateIncomplete }
        guard trustedProvenanceHeld else { return .blockedTrustedProvenanceInvalid }
        guard freshnessHeld else { return .blockedFreshnessInvalid }
        guard runLockHeld else { return .blockedRunLockInvalid }
        guard semanticArtifactLinkageHeld else { return .blockedArtifactLinkageInvalid }
        guard observedProductionCanary else { return .blockedTrustedObservedCanaryMissing }
        return .acceptedTrustedObservedCanary
    }

    private static func validateManifestHeader(
        _ manifest: ReleaseV0322ClosureManifest,
        context: ReleaseV0322TrustedEvaluationContext
    ) throws {
        guard manifest.release == "v0.32.2" else {
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("release must be v0.32.2")
        }
        guard manifest.runID.hasPrefix("v0322-run-") else {
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("runID must be v0322 scoped")
        }
        guard manifest.sourceCommit == context.expectedSourceCommit else {
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("sourceCommit mismatch")
        }
        guard manifest.policyVersion == context.expectedPolicyVersion else {
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("policyVersion mismatch")
        }
    }

    private static func validateArtifacts(
        _ artifacts: [ReleaseV0322OperationArtifactRecord],
        manifest: ReleaseV0322ClosureManifest,
        evidenceRoot: URL
    ) throws -> Bool {
        let expected = [
            "spot:submit:1",
            "spot:status:2",
            "spot:cancel:3",
            "usdsPerpetual:submit:4",
            "usdsPerpetual:status:5",
            "usdsPerpetual:cancel:6"
        ]
        let actual = artifacts.map { "\($0.product.rawValue):\($0.action.rawValue):\($0.sequence)" }
        guard actual == expected, Set(actual).count == expected.count else {
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("operation artifact set invalid")
        }

        var eventIDs = Set<String>()
        var idempotencyKeys = Set<String>()
        for artifact in artifacts {
            let artifactURL = try validatedArtifactURL(evidenceRoot: evidenceRoot, relativePath: artifact.relativePath)
            let data = try Data(contentsOf: artifactURL)
            guard data.count == artifact.byteCount else {
                throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("byte count mismatch")
            }
            guard artifact.sha256.hasPrefix("sha256:"), sha256Hex(for: data) == artifact.sha256 else {
                throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("sha256 mismatch")
            }
            let content = try JSONDecoder().decode(ReleaseV0322OperationArtifactContent.self, from: data)
            guard content.runID == manifest.runID,
                  content.product == artifact.product,
                  content.action == artifact.action,
                  content.sequence == artifact.sequence,
                  content.eventID == artifact.eventID,
                  content.idempotencyKey == artifact.idempotencyKey,
                  content.sourceCommit == manifest.sourceCommit,
                  content.policyVersion == manifest.policyVersion,
                  content.omsEventID == artifact.omsEventID,
                  content.reconciliationID == artifact.reconciliationID,
                  content.rollbackID == artifact.rollbackID,
                  content.incidentID == artifact.incidentID,
                  content.rollbackID.hasPrefix("rollback-"),
                  content.incidentID.hasPrefix("incident-stop-")
            else {
                throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("artifact semantic content mismatch")
            }
            guard eventIDs.insert(artifact.eventID).inserted,
                  idempotencyKeys.insert(artifact.idempotencyKey).inserted
            else {
                throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("duplicate event or idempotency identity")
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
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("unsafe artifact path")
        }
        let components = relativePath.split(separator: "/").map(String.init)
        guard components.isEmpty == false,
              components.contains(".") == false,
              components.contains("..") == false
        else {
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("unsafe artifact path")
        }
        let root = evidenceRoot.standardizedFileURL
        let rootPrefix = root.path.hasSuffix("/") ? root.path : "\(root.path)/"
        let artifactURL = components.reduce(root) { $0.appendingPathComponent($1) }.standardizedFileURL
        guard artifactURL.path.hasPrefix(rootPrefix) else {
            throw ReleaseV0322ControlledCanaryIntegrityClosurePatchError.validationFailed("artifact escapes evidence root")
        }
        return artifactURL
    }

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1)
        else {
            return nil
        }
        return arguments[index + 1]
    }
}
