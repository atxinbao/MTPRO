import Crypto
import Foundation

// GH-1536-FETCH-TRUSTED-GITHUB-RUN-ARTIFACT-PROVENANCE
// TVM-RELEASE-V0323-TRUSTED-GITHUB-PROVENANCE
// V0323-002-TRUSTED-GITHUB-PROVENANCE

public struct ReleaseV0323TrustedGitHubProvenanceExpectation: Equatable, Sendable {
    public let repository: String
    public let workflowName: String
    public let runID: Int
    public let runAttempt: Int
    public let headSHA: String
    public let actor: String
    public let artifactID: Int
    public let artifactName: String
    public let artifactArchiveSHA256: String
    public let operationBundleSHA256: String
    public let trustedEvaluationEpochSeconds: Int
    public let maxArtifactAgeSeconds: Int

    public init(
        repository: String,
        workflowName: String,
        runID: Int,
        runAttempt: Int,
        headSHA: String,
        actor: String,
        artifactID: Int,
        artifactName: String,
        artifactArchiveSHA256: String,
        operationBundleSHA256: String,
        trustedEvaluationEpochSeconds: Int,
        maxArtifactAgeSeconds: Int
    ) {
        self.repository = repository
        self.workflowName = workflowName
        self.runID = runID
        self.runAttempt = runAttempt
        self.headSHA = headSHA
        self.actor = actor
        self.artifactID = artifactID
        self.artifactName = artifactName
        self.artifactArchiveSHA256 = artifactArchiveSHA256
        self.operationBundleSHA256 = operationBundleSHA256
        self.trustedEvaluationEpochSeconds = trustedEvaluationEpochSeconds
        self.maxArtifactAgeSeconds = maxArtifactAgeSeconds
    }
}

public struct ReleaseV0323ObservedOperation: Codable, Equatable, Hashable, Sendable {
    public let product: ReleaseV0310Product
    public let action: ReleaseV0320CanaryAction

    public init(product: ReleaseV0310Product, action: ReleaseV0320CanaryAction) {
        self.product = product
        self.action = action
    }
}

public struct ReleaseV0323TrustedGitHubProvenanceExport: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let source: String
    public let repository: String
    public let workflowName: String
    public let runID: Int
    public let runAttempt: Int
    public let headSHA: String
    public let actor: String
    public let environment: String
    public let runAPIURL: String
    public let artifactID: Int
    public let artifactName: String
    public let artifactAPIURL: String
    public let artifactArchiveSHA256: String
    public let operationBundleSHA256: String
    public let createdAtEpochSeconds: Int
    public let completedAtEpochSeconds: Int
    public let jobs: [ReleaseV0322WorkflowJobConclusion]
    public let observedOperations: [ReleaseV0323ObservedOperation]
    public let observedProductionCanary: Bool?
    public let trustedObservedProductionCanaryEvidence: Bool?

    public init(
        schemaVersion: String = "v0323-trusted-github-provenance-export-v1",
        source: String = "github-api-artifact-export",
        repository: String,
        workflowName: String,
        runID: Int,
        runAttempt: Int,
        headSHA: String,
        actor: String,
        environment: String = "github-actions",
        runAPIURL: String,
        artifactID: Int,
        artifactName: String,
        artifactAPIURL: String,
        artifactArchiveSHA256: String,
        operationBundleSHA256: String,
        createdAtEpochSeconds: Int,
        completedAtEpochSeconds: Int,
        jobs: [ReleaseV0322WorkflowJobConclusion],
        observedOperations: [ReleaseV0323ObservedOperation],
        observedProductionCanary: Bool? = nil,
        trustedObservedProductionCanaryEvidence: Bool? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.source = source
        self.repository = repository
        self.workflowName = workflowName
        self.runID = runID
        self.runAttempt = runAttempt
        self.headSHA = headSHA
        self.actor = actor
        self.environment = environment
        self.runAPIURL = runAPIURL
        self.artifactID = artifactID
        self.artifactName = artifactName
        self.artifactAPIURL = artifactAPIURL
        self.artifactArchiveSHA256 = artifactArchiveSHA256
        self.operationBundleSHA256 = operationBundleSHA256
        self.createdAtEpochSeconds = createdAtEpochSeconds
        self.completedAtEpochSeconds = completedAtEpochSeconds
        self.jobs = jobs
        self.observedOperations = observedOperations
        self.observedProductionCanary = observedProductionCanary
        self.trustedObservedProductionCanaryEvidence = trustedObservedProductionCanaryEvidence
    }
}

public struct ReleaseV0323TrustedGitHubProvenanceReport: Codable, Equatable, Sendable {
    public let repository: String
    public let workflowName: String
    public let runID: Int
    public let artifactID: Int
    public let headSHA: String
    public let exportChecksumVerified: Bool
    public let identityVerified: Bool
    public let requiredJobsPassed: Bool
    public let operationBundleChecksumVerified: Bool
    public let trustedObservedProductionCanaryEvidence: Bool
    public let selfReportedObservedProductionCanaryAccepted: Bool
    public let productionCutoverAuthorized: Bool

    public var boundaryHeld: Bool {
        exportChecksumVerified
            && identityVerified
            && requiredJobsPassed
            && operationBundleChecksumVerified
            && trustedObservedProductionCanaryEvidence
            && selfReportedObservedProductionCanaryAccepted == false
            && productionCutoverAuthorized == false
    }
}

public enum ReleaseV0323TrustedGitHubProvenanceError: Error, Equatable, Sendable {
    case exportChecksumMismatch
    case invalidIdentity
    case invalidGitHubURL
    case invalidArtifactChecksum
    case invalidJobConclusions
    case staleArtifact
    case incompleteObservedOperations
}

public enum ReleaseV0323TrustedGitHubProvenanceLoader {
    public static let validationAnchor = "TVM-RELEASE-V0323-TRUSTED-GITHUB-PROVENANCE"
    public static let requiredJobNames = Set([
        "pr-fast-checks",
        "linux-checks",
        "dashboard-macos",
        "release-publication-checks",
    ])
    public static let requiredOperations = Set(
        ReleaseV0310Product.allCases.flatMap { product in
            ReleaseV0320CanaryAction.allCases.map { action in
                ReleaseV0323ObservedOperation(product: product, action: action)
            }
        }
    )

    public static func sha256Hex(for data: Data) -> String {
        "sha256:" + SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    /// export 文件本身不建立信任；expectedExportSHA256 与 expectation 必须来自可信 GitHub API/attestation 通道。
    public static func loadVerifiedExport(
        from exportURL: URL,
        expectedExportSHA256: String,
        expectation: ReleaseV0323TrustedGitHubProvenanceExpectation
    ) throws -> ReleaseV0323TrustedGitHubProvenanceReport {
        let data = try Data(contentsOf: exportURL)
        guard expectedExportSHA256.hasPrefix("sha256:"),
              sha256Hex(for: data) == expectedExportSHA256
        else {
            throw ReleaseV0323TrustedGitHubProvenanceError.exportChecksumMismatch
        }

        let export = try JSONDecoder().decode(ReleaseV0323TrustedGitHubProvenanceExport.self, from: data)
        guard export.schemaVersion == "v0323-trusted-github-provenance-export-v1",
              export.source == "github-api-artifact-export",
              export.repository == expectation.repository,
              export.workflowName == expectation.workflowName,
              export.runID == expectation.runID,
              export.runAttempt == expectation.runAttempt,
              export.headSHA == expectation.headSHA,
              export.actor == expectation.actor,
              export.environment == "github-actions",
              export.artifactID == expectation.artifactID,
              export.artifactName == expectation.artifactName,
              export.createdAtEpochSeconds <= export.completedAtEpochSeconds,
              export.observedProductionCanary == nil,
              export.trustedObservedProductionCanaryEvidence == nil
        else {
            throw ReleaseV0323TrustedGitHubProvenanceError.invalidIdentity
        }

        let expectedRunURL = "https://api.github.com/repos/\(expectation.repository)/actions/runs/\(expectation.runID)"
        let expectedArtifactURL = "https://api.github.com/repos/\(expectation.repository)/actions/artifacts/\(expectation.artifactID)"
        guard export.runAPIURL == expectedRunURL,
              export.artifactAPIURL == expectedArtifactURL
        else {
            throw ReleaseV0323TrustedGitHubProvenanceError.invalidGitHubURL
        }

        guard export.artifactArchiveSHA256 == expectation.artifactArchiveSHA256,
              export.operationBundleSHA256 == expectation.operationBundleSHA256,
              export.artifactArchiveSHA256.hasPrefix("sha256:"),
              export.operationBundleSHA256.hasPrefix("sha256:")
        else {
            throw ReleaseV0323TrustedGitHubProvenanceError.invalidArtifactChecksum
        }

        guard Set(export.jobs.map(\.jobName)).count == export.jobs.count else {
            throw ReleaseV0323TrustedGitHubProvenanceError.invalidJobConclusions
        }
        let jobsByName = Dictionary(uniqueKeysWithValues: export.jobs.map { ($0.jobName, $0) })
        guard Set(jobsByName.keys) == requiredJobNames,
              jobsByName.values.allSatisfy({ $0.conclusion == .passed })
        else {
            throw ReleaseV0323TrustedGitHubProvenanceError.invalidJobConclusions
        }

        guard expectation.maxArtifactAgeSeconds >= 0,
              export.completedAtEpochSeconds <= expectation.trustedEvaluationEpochSeconds,
              expectation.trustedEvaluationEpochSeconds - export.completedAtEpochSeconds <= expectation.maxArtifactAgeSeconds
        else {
            throw ReleaseV0323TrustedGitHubProvenanceError.staleArtifact
        }

        // observed canary 由 checksum 绑定的完整操作集合推导，不接受 manifest 布尔字段。
        guard Set(export.observedOperations) == requiredOperations,
              export.observedOperations.count == requiredOperations.count
        else {
            throw ReleaseV0323TrustedGitHubProvenanceError.incompleteObservedOperations
        }

        return ReleaseV0323TrustedGitHubProvenanceReport(
            repository: export.repository,
            workflowName: export.workflowName,
            runID: export.runID,
            artifactID: export.artifactID,
            headSHA: export.headSHA,
            exportChecksumVerified: true,
            identityVerified: true,
            requiredJobsPassed: true,
            operationBundleChecksumVerified: true,
            trustedObservedProductionCanaryEvidence: true,
            selfReportedObservedProductionCanaryAccepted: false,
            productionCutoverAuthorized: false
        )
    }
}
