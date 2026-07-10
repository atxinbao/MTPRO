import Crypto
import Foundation

/// v0.29.1 将 v0.29.0 acceptance evidence 明确分成 deterministic fixture 与 observed run。
public enum ReleaseV0291EvidenceOrigin: String, Codable, Equatable, Sendable {
    /// 固定夹具只证明 schema、边界和 deterministic contract，不代表真实 operator run。
    case deterministicFixture = "deterministic-fixture"
    /// observed run 必须来自真实 artifact bundle、校验过 SHA-256、freshness、approval 和 provenance。
    case observedRun = "observed-run"
}

/// v0.29.1 的 acceptance decision 明确禁止把 fixture 自动归类为 accepted。
public enum ReleaseV0291AcceptanceDecision: String, Codable, Equatable, Sendable {
    case notEvaluated = "not-evaluated"
    case blocked = "blocked"
    case accepted = "accepted"
    case failed = "failed"
}

/// v0.29.0 已发布事实，用于修正 construction closeout 与 release publication 的文档漂移。
public struct ReleaseV0291PublicationFacts: Codable, Equatable, Sendable {
    public let release: String
    public let releaseURL: String
    public let publishedAt: String
    public let tagName: String
    public let tagTargetCommit: String
    public let pullRequest: String
    public let workflowRunID: String
    public let workflowConclusion: String
    public let workflowCompletedAt: String
    public let milestoneNumbersClosed: [Int]
    public let issueRangeClosed: String

    public init(
        release: String,
        releaseURL: String,
        publishedAt: String,
        tagName: String,
        tagTargetCommit: String,
        pullRequest: String,
        workflowRunID: String,
        workflowConclusion: String,
        workflowCompletedAt: String,
        milestoneNumbersClosed: [Int],
        issueRangeClosed: String
    ) {
        self.release = release
        self.releaseURL = releaseURL
        self.publishedAt = publishedAt
        self.tagName = tagName
        self.tagTargetCommit = tagTargetCommit
        self.pullRequest = pullRequest
        self.workflowRunID = workflowRunID
        self.workflowConclusion = workflowConclusion
        self.workflowCompletedAt = workflowCompletedAt
        self.milestoneNumbersClosed = milestoneNumbersClosed
        self.issueRangeClosed = issueRangeClosed
    }

    public static let current = Self(
        release: "v0.29.0",
        releaseURL: "https://github.com/atxinbao/MTPRO/releases/tag/v0.29.0",
        publishedAt: "2026-07-10T14:23:30Z",
        tagName: "v0.29.0",
        tagTargetCommit: "2b070ea979adfec5fccf90fcd823512d99ec4c3c",
        pullRequest: "PR #1458",
        workflowRunID: "29099609391",
        workflowConclusion: "success",
        workflowCompletedAt: "2026-07-10T14:24:35Z",
        milestoneNumbersClosed: [48, 49],
        issueRangeClosed: "#1439-#1456"
    )

    public var factsHeld: Bool {
        release == "v0.29.0"
            && releaseURL == "https://github.com/atxinbao/MTPRO/releases/tag/v0.29.0"
            && publishedAt == "2026-07-10T14:23:30Z"
            && tagName == "v0.29.0"
            && tagTargetCommit == "2b070ea979adfec5fccf90fcd823512d99ec4c3c"
            && pullRequest == "PR #1458"
            && workflowRunID == "29099609391"
            && workflowConclusion == "success"
            && workflowCompletedAt == "2026-07-10T14:24:35Z"
            && milestoneNumbersClosed == [48, 49]
            && issueRangeClosed == "#1439-#1456"
    }
}

/// v0.29.1 observed artifact manifest 是 acceptance 的最小可校验证据输入。
public struct ReleaseV0291ArtifactManifest: Codable, Equatable, Sendable {
    public let relativePath: String
    public let byteCount: Int
    public let sha256: String
    public let runID: String
    public let sourceCommit: String
    public let operatorApprovalID: String
    public let operatorActor: String
    public let observedAt: String
    public let expiresAt: String
    public let venue: String
    public let productType: String
    public let environment: String
    public let evidenceOrigin: ReleaseV0291EvidenceOrigin
    public let provenanceKind: String
    public let redactionChecked: Bool
    public let immutableManifest: Bool

    public init(
        relativePath: String,
        byteCount: Int,
        sha256: String,
        runID: String,
        sourceCommit: String,
        operatorApprovalID: String,
        operatorActor: String,
        observedAt: String,
        expiresAt: String,
        venue: String,
        productType: String,
        environment: String,
        evidenceOrigin: ReleaseV0291EvidenceOrigin,
        provenanceKind: String,
        redactionChecked: Bool,
        immutableManifest: Bool
    ) {
        self.relativePath = relativePath
        self.byteCount = byteCount
        self.sha256 = sha256
        self.runID = runID
        self.sourceCommit = sourceCommit
        self.operatorApprovalID = operatorApprovalID
        self.operatorActor = operatorActor
        self.observedAt = observedAt
        self.expiresAt = expiresAt
        self.venue = venue
        self.productType = productType
        self.environment = environment
        self.evidenceOrigin = evidenceOrigin
        self.provenanceKind = provenanceKind
        self.redactionChecked = redactionChecked
        self.immutableManifest = immutableManifest
    }
}

/// v0.29.1 artifact validation report 总是 fail-closed：只要任一检查失败，acceptance 就不是 accepted。
public struct ReleaseV0291ArtifactValidationReport: Codable, Equatable, Sendable {
    public let manifest: ReleaseV0291ArtifactManifest
    public let fileExists: Bool
    public let regularFile: Bool
    public let safeRelativePath: Bool
    public let actualByteCount: Int
    public let actualSHA256: String
    public let freshnessHeld: Bool
    public let provenanceHeld: Bool
    public let metadataHeld: Bool
    public let failureReasons: [String]

    public init(
        manifest: ReleaseV0291ArtifactManifest,
        fileExists: Bool,
        regularFile: Bool,
        safeRelativePath: Bool,
        actualByteCount: Int,
        actualSHA256: String,
        freshnessHeld: Bool,
        provenanceHeld: Bool,
        metadataHeld: Bool,
        failureReasons: [String]
    ) {
        self.manifest = manifest
        self.fileExists = fileExists
        self.regularFile = regularFile
        self.safeRelativePath = safeRelativePath
        self.actualByteCount = actualByteCount
        self.actualSHA256 = actualSHA256
        self.freshnessHeld = freshnessHeld
        self.provenanceHeld = provenanceHeld
        self.metadataHeld = metadataHeld
        self.failureReasons = failureReasons
    }

    public var passed: Bool {
        failureReasons.isEmpty
    }

    public var acceptanceDecision: ReleaseV0291AcceptanceDecision {
        passed ? .accepted : .failed
    }
}

/// v0.29.1 的完整性校验工具只做本地 artifact 读取和 deterministic decision，不连接网络。
public enum ReleaseV0291ShadowAcceptanceIntegrity {
    public static let validationAnchor =
        "TVM-RELEASE-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PUBLICATION-GATE-REPAIR"
    public static let verificationAnchor =
        "GH-1459-TO-1467-VERIFY-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PATCH"

    public static let deterministicFixtureOrigin: ReleaseV0291EvidenceOrigin = .deterministicFixture
    public static let deterministicFixtureDecision: ReleaseV0291AcceptanceDecision = .blocked

    public static func sha256Hex(data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public static func sha256Hex(string: String) -> String {
        sha256Hex(data: Data(string.utf8))
    }

    public static func validateObservedArtifact(
        fileURL: URL,
        manifest: ReleaseV0291ArtifactManifest,
        now: Date = Date()
    ) -> ReleaseV0291ArtifactValidationReport {
        var reasons: [String] = []
        let fileManager = FileManager.default
        let safePath = isSafeRelativePath(manifest.relativePath)
        if !safePath {
            reasons.append("unsafe relative path")
        }

        let exists = fileManager.fileExists(atPath: fileURL.path)
        if !exists {
            reasons.append("artifact file missing")
        }

        var regularFile = false
        var data = Data()
        if exists {
            do {
                let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                regularFile = values.isRegularFile == true
                if !regularFile {
                    reasons.append("artifact path is not a regular file")
                }
                data = try Data(contentsOf: fileURL)
            } catch {
                reasons.append("artifact read failed")
            }
        }

        let actualByteCount = data.count
        let actualSHA256 = sha256Hex(data: data)
        if manifest.byteCount != actualByteCount {
            reasons.append("byte count mismatch")
        }
        if !isLowercaseSHA256(manifest.sha256) {
            reasons.append("sha256 format invalid")
        } else if manifest.sha256 != actualSHA256 {
            reasons.append("sha256 mismatch")
        }

        let freshnessHeld = freshnessIsValid(
            observedAt: manifest.observedAt,
            expiresAt: manifest.expiresAt,
            now: now
        )
        if !freshnessHeld {
            reasons.append("freshness window invalid")
        }

        let metadataHeld = [
            manifest.runID,
            manifest.sourceCommit,
            manifest.operatorApprovalID,
            manifest.operatorActor,
            manifest.venue,
            manifest.productType,
            manifest.environment
        ].allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if !metadataHeld {
            reasons.append("required metadata missing")
        }

        let provenanceHeld = manifest.evidenceOrigin == .observedRun
            && manifest.provenanceKind == "observed-run-artifact"
            && manifest.redactionChecked
            && manifest.immutableManifest
        if !provenanceHeld {
            reasons.append("observed-run provenance invalid")
        }

        return ReleaseV0291ArtifactValidationReport(
            manifest: manifest,
            fileExists: exists,
            regularFile: regularFile,
            safeRelativePath: safePath,
            actualByteCount: actualByteCount,
            actualSHA256: actualSHA256,
            freshnessHeld: freshnessHeld,
            provenanceHeld: provenanceHeld,
            metadataHeld: metadataHeld,
            failureReasons: reasons
        )
    }

    public static func observedRunAccepted(_ report: ReleaseV0291ArtifactValidationReport) -> Bool {
        report.acceptanceDecision == .accepted
    }

    private static func isSafeRelativePath(_ relativePath: String) -> Bool {
        let trimmed = relativePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !trimmed.hasPrefix("/"),
              !trimmed.contains("\\"),
              !trimmed.split(separator: "/").contains("..") else {
            return false
        }
        return true
    }

    private static func isLowercaseSHA256(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { character in
            character.isNumber || ("a"..."f").contains(character)
        }
    }

    private static func freshnessIsValid(
        observedAt: String,
        expiresAt: String,
        now: Date
    ) -> Bool {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        guard let observed = formatter.date(from: observedAt),
              let expires = formatter.date(from: expiresAt) else {
            return false
        }
        return observed <= now && now < expires
    }
}
