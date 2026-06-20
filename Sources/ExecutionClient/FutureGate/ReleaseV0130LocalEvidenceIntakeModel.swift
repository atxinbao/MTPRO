import Crypto
import DomainModel
import Foundation

/// ReleaseV0130LocalEvidenceIntakeAnchors 固定 GH-995 的本地证据 intake 验证锚点。
///
/// 这些锚点只证明 v0.13.0 readiness engine 可以发现并校验显式 local evidence root；
/// 它们不授权 production cutover、secret read、endpoint / broker connection 或任何订单命令。
public enum ReleaseV0130LocalEvidenceIntakeAnchors {
    public static let validationAnchors = [
        "GH-995-VERIFY-V0130-LOCAL-EVIDENCE-INTAKE-MODEL",
        "TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL",
        "V0130-002-LOCAL-EVIDENCE-ROOT-LAYOUT",
        "V0130-002-RUN-LOGS-EVENT-STREAM-ARTIFACTS-REGISTRY-PRIOR-ASSESSMENTS",
        "V0130-002-SCHEMA-VALIDATION-DIAGNOSTICS",
        "V0130-002-MISSING-MALFORMED-FAILS-CLOSED",
        "V0130-002-NO-PRODUCTION-ENDPOINT-SECRET-ORDER",
        "V0130-002-READ-ONLY-INTAKE"
    ]
}

/// ReleaseV0130LocalEvidenceProvenanceAnchors 固定 GH-996 的 v0.13 manifest provenance 替换锚点。
///
/// 这些锚点只证明 v0.13.0 normal readiness manifest 的 sourceCommit、sourceRunIDs
/// 和 artifact metadata 必须来自显式 local evidence root；它们不授权 production
/// cutover、secret read、endpoint / broker connection 或任何订单命令。
public enum ReleaseV0130LocalEvidenceProvenanceAnchors {
    public static let validationAnchors = [
        "GH-996-VERIFY-V0130-SYNTHETIC-PROVENANCE-REJECTION",
        "TVM-RELEASE-V0130-SYNTHETIC-PROVENANCE-REJECTION",
        "V0130-003-INTAKE-DERIVED-MANIFEST-PROVENANCE",
        "V0130-003-SOURCECOMMIT-SOURCERUN-ARTIFACT-METADATA",
        "V0130-003-SYNTHETIC-PROVENANCE-FAILS-CLOSED",
        "V0130-003-FIXTURE-ONLY-ISOLATION",
        "V0130-003-NO-PRODUCTION-CUTOVER"
    ]
}

/// ReleaseV0130LocalEvidenceBuildPipelineAnchors 固定 GH-997 的本地证据 build pipeline 锚点。
///
/// 这些锚点只证明 v0.13.0 readiness build 会按 schema -> checksum -> policy ->
/// manifest -> bundle -> registry 的顺序处理真实本地证据；它们不授权 production
/// cutover、secret read、endpoint / broker connection 或任何订单命令。
public enum ReleaseV0130LocalEvidenceBuildPipelineAnchors {
    public static let validationAnchors = [
        "GH-997-VERIFY-V0130-BUILD-PIPELINE",
        "TVM-RELEASE-V0130-BUILD-PIPELINE",
        "V0130-004-SCHEMA-CHECKSUM-POLICY-REGISTRY-FLOW",
        "V0130-004-MANIFEST-BUNDLE-REGISTRY-WRITE",
        "V0130-004-PROVENANCE-VALIDATION-REPORT",
        "V0130-004-BUILD-FAILS-CLOSED",
        "V0130-004-NO-PRODUCTION-CUTOVER"
    ]
}

/// ReleaseV0130LocalEvidenceChainValidationAnchors 固定 GH-998 的完整 evidence-chain validate 锚点。
///
/// 这些锚点只证明 `readiness validate <assessmentID>` 会检查 registry、Manifest V2、
/// Bundle V2、artifact snapshot、checksum、provenance 和可选 export / comparison identity；
/// 它们不授权 production cutover、secret read、endpoint / broker connection 或任何订单命令。
public enum ReleaseV0130LocalEvidenceChainValidationAnchors {
    public static let validationAnchors = [
        "GH-998-VERIFY-V0130-EVIDENCE-CHAIN-VALIDATE",
        "TVM-RELEASE-V0130-EVIDENCE-CHAIN-VALIDATE",
        "V0130-005-REGISTRY-MANIFEST-BUNDLE-CONSISTENCY",
        "V0130-005-ARTIFACT-POLICY-CHECKSUM-PROVENANCE",
        "V0130-005-EXPORT-COMPARISON-IDENTITY",
        "V0130-005-MISSING-STALE-TAMPERED-FAILS-CLOSED",
        "V0130-005-NO-PRODUCTION-CUTOVER"
    ]
}

/// ReleaseV0130RedactedAuditExportPackageAnchors 固定 GH-999 的 redacted audit export package 锚点。
///
/// 这些锚点只证明 `readiness export <assessmentID>` 会把已通过 #998 validate 的本地证据链
/// 写成可审计、checksum 绑定、redacted-only 的本地导出包；它们不授权 production cutover、
/// secret read、endpoint / broker connection 或任何订单命令。
public enum ReleaseV0130RedactedAuditExportPackageAnchors {
    public static let validationAnchors = [
        "GH-999-VERIFY-V0130-REDACTED-AUDIT-EXPORT-PACKAGE",
        "TVM-RELEASE-V0130-REDACTED-AUDIT-EXPORT-PACKAGE",
        "V0130-006-REDACTED-AUDIT-EXPORT-PACKAGE",
        "V0130-006-COMPLETE-AUDIT-PACKAGE",
        "V0130-006-EXPORT-CHECKSUMS-MATCH-SOURCE",
        "V0130-006-MISSING-EVIDENCE-FAILS-CLOSED",
        "V0130-006-NO-SECRET-PRODUCTION-CUTOVER"
    ]
}

/// ReleaseV0130EvidenceLevelDiffAnchors 固定 GH-1000 的 evidence-level diff / compare 锚点。
///
/// 这些锚点只证明 `readiness compare <baseline> <followUp>` 会在 v0.13.0 本地
/// evidence chain 上比较 source data、policy、risk posture、checksum、provenance
/// 和 evidence completeness；它们不授权 production cutover、secret read、endpoint /
/// broker connection 或任何订单命令。
public enum ReleaseV0130EvidenceLevelDiffAnchors {
    public static let validationAnchors = [
        "GH-1000-VERIFY-V0130-EVIDENCE-LEVEL-DIFF",
        "TVM-RELEASE-V0130-EVIDENCE-LEVEL-DIFF",
        "V0130-007-EVIDENCE-LEVEL-DIFF-COMPARE",
        "V0130-007-SOURCE-POLICY-RISK-CHECKSUM-PROVENANCE-COMPLETENESS",
        "V0130-007-BROKEN-EVIDENCE-LINK-BLOCKER",
        "V0130-007-COMPARISON-EXPORT-VALIDATION",
        "V0130-007-NO-PRODUCTION-CUTOVER"
    ]
}

/// v0.13.0 evidence-level compare 固定的审计维度。
public enum ReleaseV0130EvidenceLevelDiffSection: String, Codable, CaseIterable, Equatable, Sendable {
    case sourceData = "source-data"
    case policy
    case riskPosture = "risk-posture"
    case checksumChain = "checksum-chain"
    case provenance
    case evidenceCompleteness = "evidence-completeness"
}

/// 单个 evidence-level section 的比较状态。
public enum ReleaseV0130EvidenceLevelDiffState: String, Codable, CaseIterable, Equatable, Sendable {
    case unchanged
    case changed
    case blocker
}

/// ReleaseV0130EvidenceLevelDiff 记录某个审计维度的 baseline / follow-up 指纹。
///
/// 如果任一 assessment 的 evidence chain 不完整，该 section 必须进入 `blocker`，而不是
/// 把缺失、stale 或 tampered evidence 当作普通 changed diff。
public struct ReleaseV0130EvidenceLevelDiff: Codable, Equatable, Sendable {
    public let section: ReleaseV0130EvidenceLevelDiffSection
    public let state: ReleaseV0130EvidenceLevelDiffState
    public let baselineFingerprint: String?
    public let followUpFingerprint: String?
    public let evidenceLinkReasons: [String]
    public let blockerReasons: [String]

    public var diffHeld: Bool {
        switch state {
        case .unchanged:
            return baselineFingerprint != nil
                && baselineFingerprint == followUpFingerprint
                && blockerReasons.isEmpty
        case .changed:
            return baselineFingerprint != nil
                && followUpFingerprint != nil
                && baselineFingerprint != followUpFingerprint
                && blockerReasons.isEmpty
        case .blocker:
            return blockerReasons.isEmpty == false
        }
    }

    public init(
        section: ReleaseV0130EvidenceLevelDiffSection,
        state: ReleaseV0130EvidenceLevelDiffState,
        baselineFingerprint: String?,
        followUpFingerprint: String?,
        evidenceLinkReasons: [String],
        blockerReasons: [String]
    ) {
        self.section = section
        self.state = state
        self.baselineFingerprint = baselineFingerprint
        self.followUpFingerprint = followUpFingerprint
        self.evidenceLinkReasons = evidenceLinkReasons.sorted()
        self.blockerReasons = blockerReasons.sorted()
    }
}

/// ReleaseV0130EvidenceLevelComparisonReport 是 GH-1000 的本地 operator review report。
///
/// Report 只写本地 comparison metadata / optional export comparison JSON，不修改 registry
/// entry、不创建 approval、不授权 production cutover。任何 broken evidence link 都必须进入
/// blocker state。
public struct ReleaseV0130EvidenceLevelComparisonReport: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let baselineAssessmentID: Identifier
    public let followUpAssessmentID: Identifier
    public let baselineGenerationID: Identifier?
    public let followUpGenerationID: Identifier?
    public let comparedAt: Date
    public let baselineValidationState: String
    public let followUpValidationState: String
    public let comparedSections: [ReleaseV0130EvidenceLevelDiffSection]
    public let changedSections: [ReleaseV0130EvidenceLevelDiffSection]
    public let unchangedSections: [ReleaseV0130EvidenceLevelDiffSection]
    public let blockedSections: [ReleaseV0130EvidenceLevelDiffSection]
    public let deltas: [ReleaseV0130EvidenceLevelDiff]
    public let blockers: [String]
    public let comparisonState: String
    public let reportChecksum: String
    public let comparisonDoesNotMutateAssessments: Bool
    public let operatorReviewOnly: Bool
    public let localRegistryStoreOnly: Bool
    public let redactedEvidenceOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceLevelComparisonHeld: Bool {
        issueID.rawValue == "GH-1000"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-998", "GH-999"]
            && releaseVersion == "v0.13.0"
            && assessmentID == followUpAssessmentID
            && comparedSections == ReleaseV0130EvidenceLevelDiffSection.allCases
            && deltas.map(\.section) == comparedSections
            && deltas.allSatisfy(\.diffHeld)
            && changedSections == deltas.filter { $0.state == .changed }.map(\.section)
            && unchangedSections == deltas.filter { $0.state == .unchanged }.map(\.section)
            && blockedSections == deltas.filter { $0.state == .blocker }.map(\.section)
            && comparisonState == (blockedSections.isEmpty ? (changedSections.isEmpty ? "unchanged" : "changed") : "blocked")
            && blockers == Array(NSOrderedSet(array: deltas.flatMap(\.blockerReasons))).compactMap { $0 as? String }.sorted()
            && reportChecksum == Self.stableReportChecksum(
                baselineAssessmentID: baselineAssessmentID,
                followUpAssessmentID: followUpAssessmentID,
                baselineGenerationID: baselineGenerationID,
                followUpGenerationID: followUpGenerationID,
                comparedAt: comparedAt,
                deltas: deltas,
                blockers: blockers
            )
            && comparisonDoesNotMutateAssessments
            && operatorReviewOnly
            && localRegistryStoreOnly
            && redactedEvidenceOnly
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-1000"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-998"),
            Identifier.constant("GH-999")
        ],
        releaseVersion: String = "v0.13.0",
        assessmentID: Identifier,
        baselineAssessmentID: Identifier,
        followUpAssessmentID: Identifier,
        baselineGenerationID: Identifier?,
        followUpGenerationID: Identifier?,
        comparedAt: Date,
        baselineValidationState: String,
        followUpValidationState: String,
        deltas: [ReleaseV0130EvidenceLevelDiff],
        comparisonDoesNotMutateAssessments: Bool = true,
        operatorReviewOnly: Bool = true,
        localRegistryStoreOnly: Bool = true,
        redactedEvidenceOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        let orderedDeltas = ReleaseV0130EvidenceLevelDiffSection.allCases.compactMap { section in
            deltas.first { $0.section == section }
        }
        let blockers = Array(NSOrderedSet(array: orderedDeltas.flatMap(\.blockerReasons)))
            .compactMap { $0 as? String }
            .sorted()

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs.sorted { $0.rawValue < $1.rawValue }
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.baselineAssessmentID = baselineAssessmentID
        self.followUpAssessmentID = followUpAssessmentID
        self.baselineGenerationID = baselineGenerationID
        self.followUpGenerationID = followUpGenerationID
        self.comparedAt = comparedAt
        self.baselineValidationState = baselineValidationState
        self.followUpValidationState = followUpValidationState
        self.comparedSections = ReleaseV0130EvidenceLevelDiffSection.allCases
        let changedSections = orderedDeltas.filter { $0.state == .changed }.map(\.section)
        let unchangedSections = orderedDeltas.filter { $0.state == .unchanged }.map(\.section)
        let blockedSections = orderedDeltas.filter { $0.state == .blocker }.map(\.section)
        self.changedSections = changedSections
        self.unchangedSections = unchangedSections
        self.blockedSections = blockedSections
        self.deltas = orderedDeltas
        self.blockers = blockers
        self.comparisonState = blockedSections.isEmpty ? (changedSections.isEmpty ? "unchanged" : "changed") : "blocked"
        self.reportChecksum = Self.stableReportChecksum(
            baselineAssessmentID: baselineAssessmentID,
            followUpAssessmentID: followUpAssessmentID,
            baselineGenerationID: baselineGenerationID,
            followUpGenerationID: followUpGenerationID,
            comparedAt: comparedAt,
            deltas: orderedDeltas,
            blockers: blockers
        )
        self.comparisonDoesNotMutateAssessments = comparisonDoesNotMutateAssessments
        self.operatorReviewOnly = operatorReviewOnly
        self.localRegistryStoreOnly = localRegistryStoreOnly
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func stableReportChecksum(
        baselineAssessmentID: Identifier,
        followUpAssessmentID: Identifier,
        baselineGenerationID: Identifier?,
        followUpGenerationID: Identifier?,
        comparedAt: Date,
        deltas: [ReleaseV0130EvidenceLevelDiff],
        blockers: [String]
    ) -> String {
        let parts = [
            "GH-1000",
            "v0.13.0",
            baselineAssessmentID.rawValue,
            followUpAssessmentID.rawValue,
            baselineGenerationID?.rawValue ?? "missing-baseline-generation",
            followUpGenerationID?.rawValue ?? "missing-followup-generation",
            ISO8601DateFormatter().string(from: comparedAt),
            blockers.sorted().joined(separator: ",")
        ] + deltas.sorted { $0.section.rawValue < $1.section.rawValue }.map { delta in
            [
                delta.section.rawValue,
                delta.state.rawValue,
                delta.baselineFingerprint ?? "missing-baseline-fingerprint",
                delta.followUpFingerprint ?? "missing-followup-fingerprint",
                delta.evidenceLinkReasons.joined(separator: ","),
                delta.blockerReasons.joined(separator: ",")
            ].joined(separator: "=")
        }
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReleaseV0130LocalEvidenceArtifactProvenance 是 GH-996 从真实本地 artifact bytes
/// 派生出的 manifest metadata。
///
/// Artifact metadata 必须绑定 local evidence root 内的安全相对路径、实际 byte count
/// 和 `sha256:<64 lowercase hex>`；不能使用固定 byte count、placeholder checksum 或
/// 伪造 source-run fallback。
public struct ReleaseV0130LocalEvidenceArtifactProvenance: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let relativePath: String
    public let sha256: String
    public let byteCount: Int

    public var provenanceHeld: Bool {
        artifactID.rawValue.isEmpty == false
            && ProductionReadinessArtifactDescriptor.isSafeRelativePath(relativePath)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(sha256)
            && byteCount > 0
    }

    public init(
        artifactID: Identifier,
        relativePath: String,
        sha256: String,
        byteCount: Int
    ) throws {
        guard ProductionReadinessArtifactDescriptor.isSafeRelativePath(relativePath) else {
            throw ReleaseV0130LocalEvidenceProvenanceError.unsafeArtifactPath(relativePath)
        }
        self.artifactID = artifactID
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount

        guard provenanceHeld else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("artifactProvenanceHeld=false")
        }
    }
}

/// ReleaseV0130LocalEvidenceBuildProvenance 汇总 GH-996 可写入 normal manifest 的 provenance。
public struct ReleaseV0130LocalEvidenceBuildProvenance: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let evidenceRootPath: String
    public let evidenceClassification: String
    public let sourceCommit: String
    public let sourceRunIDs: [Identifier]
    public let artifactProvenances: [ReleaseV0130LocalEvidenceArtifactProvenance]
    public let artifactSHA256: String
    public let artifactBytes: Int
    public let syntheticProvenanceRejected: Bool
    public let fixtureOnly: Bool
    public let localEvidenceTraceable: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var normalManifestEligible: Bool {
        issueID.rawValue == "GH-996"
            && releaseVersion == "v0.13.0"
            && evidenceClassification == "normal-local-evidence"
            && ReadinessAssessmentManifestV2.isValidSourceCommit(sourceCommit)
            && sourceRunIDs.isEmpty == false
            && sourceRunIDs.map(\.rawValue) == sourceRunIDs.map(\.rawValue).sorted()
            && sourceRunIDs.allSatisfy { ReadinessAssessmentManifestV2.forbiddenSourceRunIDPlaceholders.contains($0.rawValue) == false }
            && sourceRunIDs.allSatisfy { $0.rawValue.hasPrefix("source-run-") == false }
            && artifactProvenances.isEmpty == false
            && artifactProvenances.allSatisfy(\.provenanceHeld)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(artifactSHA256)
            && artifactBytes > 0
            && syntheticProvenanceRejected
            && fixtureOnly == false
            && localEvidenceTraceable
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-996"),
        releaseVersion: String = "v0.13.0",
        evidenceRootPath: String,
        evidenceClassification: String = "normal-local-evidence",
        sourceCommit: String,
        sourceRunIDs: [Identifier],
        artifactProvenances: [ReleaseV0130LocalEvidenceArtifactProvenance],
        artifactSHA256: String,
        artifactBytes: Int,
        syntheticProvenanceRejected: Bool = true,
        fixtureOnly: Bool = false,
        localEvidenceTraceable: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.evidenceRootPath = evidenceRootPath
        self.evidenceClassification = evidenceClassification
        self.sourceCommit = sourceCommit
        self.sourceRunIDs = sourceRunIDs.sorted { $0.rawValue < $1.rawValue }
        self.artifactProvenances = artifactProvenances.sorted { $0.relativePath < $1.relativePath }
        self.artifactSHA256 = artifactSHA256
        self.artifactBytes = artifactBytes
        self.syntheticProvenanceRejected = syntheticProvenanceRejected
        self.fixtureOnly = fixtureOnly
        self.localEvidenceTraceable = localEvidenceTraceable
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard normalManifestEligible else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("normalManifestEligible=false")
        }
    }
}

/// ReleaseV0130LocalEvidenceArtifactPipelineValidation 记录 GH-997 对单个 artifact 的校验结果。
///
/// 它同时保留 #996 raw artifact provenance checksum 和 #997 content-policy canonical
/// checksum，避免把格式化差异误当成 sourceRun 或 commit provenance。
public struct ReleaseV0130LocalEvidenceArtifactPipelineValidation: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let relativePath: String
    public let rawArtifactSHA256: String
    public let rawArtifactBytes: Int
    public let canonicalArtifactSHA256: String
    public let canonicalArtifactBytes: Int
    public let observedTopLevelJSONFields: [String]
    public let policyChecksum: String
    public let contentValidationChecksum: String
    public let schemaValidated: Bool
    public let checksumValidated: Bool
    public let policyValidated: Bool
    public let noSecretValue: Bool
    public let noEndpointPayload: Bool
    public let noOrderPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var validationHeld: Bool {
        artifactID.rawValue.isEmpty == false
            && ProductionReadinessArtifactDescriptor.isSafeRelativePath(relativePath)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(rawArtifactSHA256)
            && rawArtifactBytes > 0
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(canonicalArtifactSHA256)
            && canonicalArtifactBytes > 0
            && observedTopLevelJSONFields.isEmpty == false
            && observedTopLevelJSONFields == observedTopLevelJSONFields.sorted()
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(policyChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(contentValidationChecksum)
            && schemaValidated
            && checksumValidated
            && policyValidated
            && noSecretValue
            && noEndpointPayload
            && noOrderPayload
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        artifactID: Identifier,
        relativePath: String,
        rawArtifactSHA256: String,
        rawArtifactBytes: Int,
        canonicalArtifactSHA256: String,
        canonicalArtifactBytes: Int,
        observedTopLevelJSONFields: [String],
        policyChecksum: String,
        contentValidationChecksum: String,
        schemaValidated: Bool = true,
        checksumValidated: Bool = true,
        policyValidated: Bool = true,
        noSecretValue: Bool = true,
        noEndpointPayload: Bool = true,
        noOrderPayload: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.artifactID = artifactID
        self.relativePath = relativePath
        self.rawArtifactSHA256 = rawArtifactSHA256
        self.rawArtifactBytes = rawArtifactBytes
        self.canonicalArtifactSHA256 = canonicalArtifactSHA256
        self.canonicalArtifactBytes = canonicalArtifactBytes
        self.observedTopLevelJSONFields = observedTopLevelJSONFields.sorted()
        self.policyChecksum = policyChecksum
        self.contentValidationChecksum = contentValidationChecksum
        self.schemaValidated = schemaValidated
        self.checksumValidated = checksumValidated
        self.policyValidated = policyValidated
        self.noSecretValue = noSecretValue
        self.noEndpointPayload = noEndpointPayload
        self.noOrderPayload = noOrderPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard validationHeld else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("artifactPipelineValidationHeld=false")
        }
    }
}

/// ReleaseV0130LocalEvidenceBuildValidationReport 汇总 GH-997 build pipeline 的可审计结果。
public struct ReleaseV0130LocalEvidenceBuildValidationReport: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let generationID: Identifier
    public let evidenceRootPath: String
    public let sourceCommit: String
    public let sourceRunIDs: [Identifier]
    public let artifactValidations: [ReleaseV0130LocalEvidenceArtifactPipelineValidation]
    public let manifestChecksum: String
    public let readinessBundleChecksum: String
    public let readinessBundleManifestChecksum: String
    public let registryChecksum: String
    public let registryEntryConfirmed: Bool
    public let registryEntryCreated: Bool
    public let schemaValidated: Bool
    public let checksumValidated: Bool
    public let contentPolicyValidated: Bool
    public let manifestWritten: Bool
    public let readinessBundleWritten: Bool
    public let validationReportChecksum: String
    public let noSecretValue: Bool
    public let noEndpointPayload: Bool
    public let noOrderPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var reportHeld: Bool {
        issueID.rawValue == "GH-997"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-954", "GH-956", "GH-957", "GH-958", "GH-995", "GH-996"]
            && releaseVersion == "v0.13.0"
            && assessmentID.rawValue.isEmpty == false
            && generationID.rawValue.isEmpty == false
            && evidenceRootPath.isEmpty == false
            && ReadinessAssessmentManifestV2.isValidSourceCommit(sourceCommit)
            && sourceRunIDs.isEmpty == false
            && sourceRunIDs.map(\.rawValue) == sourceRunIDs.map(\.rawValue).sorted()
            && artifactValidations.isEmpty == false
            && artifactValidations.allSatisfy(\.validationHeld)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(manifestChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(readinessBundleChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(readinessBundleManifestChecksum)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(registryChecksum)
            && registryEntryConfirmed
            && schemaValidated
            && checksumValidated
            && contentPolicyValidated
            && manifestWritten
            && readinessBundleWritten
            && validationReportChecksum == Self.stableValidationReportChecksum(
                assessmentID: assessmentID,
                generationID: generationID,
                sourceCommit: sourceCommit,
                sourceRunIDs: sourceRunIDs,
                artifactValidations: artifactValidations,
                manifestChecksum: manifestChecksum,
                readinessBundleChecksum: readinessBundleChecksum,
                readinessBundleManifestChecksum: readinessBundleManifestChecksum,
                registryChecksum: registryChecksum,
                registryEntryCreated: registryEntryCreated
            )
            && noSecretValue
            && noEndpointPayload
            && noOrderPayload
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-997"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-954"),
            Identifier.constant("GH-956"),
            Identifier.constant("GH-957"),
            Identifier.constant("GH-958"),
            Identifier.constant("GH-995"),
            Identifier.constant("GH-996")
        ],
        releaseVersion: String = "v0.13.0",
        assessmentID: Identifier,
        generationID: Identifier,
        evidenceRootPath: String,
        sourceCommit: String,
        sourceRunIDs: [Identifier],
        artifactValidations: [ReleaseV0130LocalEvidenceArtifactPipelineValidation],
        manifestChecksum: String,
        readinessBundleChecksum: String,
        readinessBundleManifestChecksum: String,
        registryChecksum: String,
        registryEntryConfirmed: Bool = true,
        registryEntryCreated: Bool,
        schemaValidated: Bool = true,
        checksumValidated: Bool = true,
        contentPolicyValidated: Bool = true,
        manifestWritten: Bool = true,
        readinessBundleWritten: Bool = true,
        validationReportChecksum: String? = nil,
        noSecretValue: Bool = true,
        noEndpointPayload: Bool = true,
        noOrderPayload: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs.sorted { $0.rawValue < $1.rawValue }
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.generationID = generationID
        self.evidenceRootPath = evidenceRootPath
        self.sourceCommit = sourceCommit
        self.sourceRunIDs = sourceRunIDs.sorted { $0.rawValue < $1.rawValue }
        self.artifactValidations = artifactValidations.sorted { $0.relativePath < $1.relativePath }
        self.manifestChecksum = manifestChecksum
        self.readinessBundleChecksum = readinessBundleChecksum
        self.readinessBundleManifestChecksum = readinessBundleManifestChecksum
        self.registryChecksum = registryChecksum
        self.registryEntryConfirmed = registryEntryConfirmed
        self.registryEntryCreated = registryEntryCreated
        self.schemaValidated = schemaValidated
        self.checksumValidated = checksumValidated
        self.contentPolicyValidated = contentPolicyValidated
        self.manifestWritten = manifestWritten
        self.readinessBundleWritten = readinessBundleWritten
        self.validationReportChecksum = validationReportChecksum ?? Self.stableValidationReportChecksum(
            assessmentID: assessmentID,
            generationID: generationID,
            sourceCommit: sourceCommit,
            sourceRunIDs: sourceRunIDs,
            artifactValidations: artifactValidations,
            manifestChecksum: manifestChecksum,
            readinessBundleChecksum: readinessBundleChecksum,
            readinessBundleManifestChecksum: readinessBundleManifestChecksum,
            registryChecksum: registryChecksum,
            registryEntryCreated: registryEntryCreated
        )
        self.noSecretValue = noSecretValue
        self.noEndpointPayload = noEndpointPayload
        self.noOrderPayload = noOrderPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func stableValidationReportChecksum(
        assessmentID: Identifier,
        generationID: Identifier,
        sourceCommit: String,
        sourceRunIDs: [Identifier],
        artifactValidations: [ReleaseV0130LocalEvidenceArtifactPipelineValidation],
        manifestChecksum: String,
        readinessBundleChecksum: String,
        readinessBundleManifestChecksum: String,
        registryChecksum: String,
        registryEntryCreated: Bool
    ) -> String {
        stableSHA256([
            "GH-997",
            "v0.13.0",
            assessmentID.rawValue,
            generationID.rawValue,
            sourceCommit,
            sourceRunIDs.map(\.rawValue).sorted().joined(separator: ","),
            manifestChecksum,
            readinessBundleChecksum,
            readinessBundleManifestChecksum,
            registryChecksum,
            "registryEntryCreated=\(registryEntryCreated)",
            "schemaValidated=true",
            "checksumValidated=true",
            "contentPolicyValidated=true",
            "manifestWritten=true",
            "readinessBundleWritten=true",
            "noSecretValue=true",
            "noEndpointPayload=true",
            "noOrderPayload=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "brokerEndpointConnected=false",
            "productionOrderSubmitted=false",
            "testnetOrderSubmissionAllowed=false",
            "productionCutoverAuthorized=false"
        ] + artifactValidations.sorted { $0.relativePath < $1.relativePath }.map { validation in
            [
                validation.artifactID.rawValue,
                validation.relativePath,
                validation.rawArtifactSHA256,
                validation.canonicalArtifactSHA256,
                validation.policyChecksum,
                validation.contentValidationChecksum
            ].joined(separator: "=")
        })
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReleaseV0130LocalEvidenceChainValidationReport 是 GH-998 `readiness validate` 的完整链路结果。
///
/// Report 即使在 blocked 场景也必须可编码并返回 failure reasons，便于 operator 明确看到
/// registry、manifest、bundle、artifact、checksum 或 provenance 的断点；它不把任何 readiness
/// pass 解释为 production cutover authorization。
public struct ReleaseV0130LocalEvidenceChainValidationReport: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let generationID: Identifier?
    public let registryDocumentHeld: Bool
    public let registryEntryHeld: Bool
    public let manifestV2Present: Bool
    public let manifestHeld: Bool
    public let bundleV2Present: Bool
    public let bundleHeld: Bool
    public let bundleManifestPresent: Bool
    public let bundleManifestHeld: Bool
    public let bundleBytesMatchManifest: Bool
    public let registryManifestAssessmentMatches: Bool
    public let manifestBundleIdentityMatches: Bool
    public let manifestBundleProvenanceMatches: Bool
    public let artifactSnapshotsPresent: Bool
    public let artifactSnapshotsMatchManifest: Bool
    public let contentValidationChecksumsPresent: Bool
    public let exportComparisonIdentityConsistent: Bool
    public let validationState: String
    public let failureReasons: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceChainCoherent: Bool {
        registryDocumentHeld
            && registryEntryHeld
            && manifestV2Present
            && manifestHeld
            && bundleV2Present
            && bundleHeld
            && bundleManifestPresent
            && bundleManifestHeld
            && bundleBytesMatchManifest
            && registryManifestAssessmentMatches
            && manifestBundleIdentityMatches
            && manifestBundleProvenanceMatches
            && artifactSnapshotsPresent
            && artifactSnapshotsMatchManifest
            && contentValidationChecksumsPresent
            && exportComparisonIdentityConsistent
            && failureReasons.isEmpty
            && validationState == "valid"
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-998"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-954"),
            Identifier.constant("GH-956"),
            Identifier.constant("GH-957"),
            Identifier.constant("GH-958"),
            Identifier.constant("GH-997")
        ],
        releaseVersion: String = "v0.13.0",
        assessmentID: Identifier,
        generationID: Identifier?,
        registryDocumentHeld: Bool,
        registryEntryHeld: Bool,
        manifestV2Present: Bool,
        manifestHeld: Bool,
        bundleV2Present: Bool,
        bundleHeld: Bool,
        bundleManifestPresent: Bool,
        bundleManifestHeld: Bool,
        bundleBytesMatchManifest: Bool,
        registryManifestAssessmentMatches: Bool,
        manifestBundleIdentityMatches: Bool,
        manifestBundleProvenanceMatches: Bool,
        artifactSnapshotsPresent: Bool,
        artifactSnapshotsMatchManifest: Bool,
        contentValidationChecksumsPresent: Bool,
        exportComparisonIdentityConsistent: Bool,
        failureReasons: [String],
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs.sorted { $0.rawValue < $1.rawValue }
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.generationID = generationID
        self.registryDocumentHeld = registryDocumentHeld
        self.registryEntryHeld = registryEntryHeld
        self.manifestV2Present = manifestV2Present
        self.manifestHeld = manifestHeld
        self.bundleV2Present = bundleV2Present
        self.bundleHeld = bundleHeld
        self.bundleManifestPresent = bundleManifestPresent
        self.bundleManifestHeld = bundleManifestHeld
        self.bundleBytesMatchManifest = bundleBytesMatchManifest
        self.registryManifestAssessmentMatches = registryManifestAssessmentMatches
        self.manifestBundleIdentityMatches = manifestBundleIdentityMatches
        self.manifestBundleProvenanceMatches = manifestBundleProvenanceMatches
        self.artifactSnapshotsPresent = artifactSnapshotsPresent
        self.artifactSnapshotsMatchManifest = artifactSnapshotsMatchManifest
        self.contentValidationChecksumsPresent = contentValidationChecksumsPresent
        self.exportComparisonIdentityConsistent = exportComparisonIdentityConsistent
        self.failureReasons = failureReasons
        self.validationState = failureReasons.isEmpty ? "valid" : "blocked"
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV0130RedactedAuditExportFile 记录 GH-999 导出包单个 JSON 文件的 checksum 证据。
///
/// Source-derived 文件必须和 registry store 中的源 artifact byte-for-byte 一致；generated
/// 文件必须在本地导出目录中落盘并绑定自己的 SHA256。所有文件都必须保持 redacted-only，
/// 且不得包含 secret、endpoint payload 或 order payload。
public struct ReleaseV0130RedactedAuditExportFile: Codable, Equatable, Sendable {
    public let fileName: String
    public let exportRelativePath: String
    public let sourceRelativePath: String?
    public let sourceSHA256: String?
    public let exportSHA256: String
    public let byteCount: Int
    public let checksumMatchesSource: Bool
    public let required: Bool
    public let redactedEvidenceOnly: Bool
    public let noSecretValue: Bool
    public let noEndpointPayload: Bool
    public let noOrderPayload: Bool

    public var fileHeld: Bool {
        ProductionReadinessArtifactDescriptor.isSafeRelativePath(exportRelativePath)
            && exportRelativePath.hasSuffix("/\(fileName)")
            && (sourceRelativePath == nil || sourceRelativePath.map {
                ProductionReadinessArtifactDescriptor.isSafeRelativePath($0)
            } == true)
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(exportSHA256)
            && (sourceSHA256 == nil || ReadinessAssessmentManifestV2.isValidSHA256Checksum(sourceSHA256 ?? ""))
            && byteCount > 0
            && checksumMatchesSource
            && required
            && redactedEvidenceOnly
            && noSecretValue
            && noEndpointPayload
            && noOrderPayload
    }

    public init(
        fileName: String,
        exportRelativePath: String,
        sourceRelativePath: String?,
        sourceSHA256: String?,
        exportSHA256: String,
        byteCount: Int,
        checksumMatchesSource: Bool,
        required: Bool = true,
        redactedEvidenceOnly: Bool = true,
        noSecretValue: Bool = true,
        noEndpointPayload: Bool = true,
        noOrderPayload: Bool = true
    ) throws {
        self.fileName = fileName
        self.exportRelativePath = exportRelativePath
        self.sourceRelativePath = sourceRelativePath
        self.sourceSHA256 = sourceSHA256
        self.exportSHA256 = exportSHA256
        self.byteCount = byteCount
        self.checksumMatchesSource = checksumMatchesSource
        self.required = required
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.noSecretValue = noSecretValue
        self.noEndpointPayload = noEndpointPayload
        self.noOrderPayload = noOrderPayload

        guard fileHeld else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("redactedAuditExportFileHeld=false")
        }
    }
}

/// ReleaseV0130RedactedAuditExportPackageReport 是 GH-999 导出包的落盘证明。
///
/// Report 证明 export directory 内包含完整 redacted audit package，且 Manifest V2 / Bundle V2
/// 的导出字节与源 artifact checksum 一致。它只服务本地审计，不改变 assessment lifecycle，
/// 不创建 comparison diff，也不把 readiness pass 转换成 production cutover authorization。
public struct ReleaseV0130RedactedAuditExportPackageReport: Codable, Equatable, Sendable {
    public static let requiredFileNames = [
        "assessment-summary.json",
        "bundle-v2.json",
        "comparison.json",
        "manifest-v2.json",
        "provenance.json",
        "validation-report.json"
    ]

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let assessmentID: Identifier
    public let generationID: Identifier
    public let exportDirectoryPath: String
    public let provenanceSummaryJSONPath: String
    public let comparisonMetadataJSONPath: String
    public let files: [ReleaseV0130RedactedAuditExportFile]
    public let evidenceChainCoherent: Bool
    public let packageComplete: Bool
    public let exportedChecksumsMatchSource: Bool
    public let missingEvidenceFailsClosed: Bool
    public let redactedEvidenceOnly: Bool
    public let noSecretValue: Bool
    public let noEndpointPayload: Bool
    public let noOrderPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var packageHeld: Bool {
        issueID.rawValue == "GH-999"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-997", "GH-998"]
            && releaseVersion == "v0.13.0"
            && assessmentID.rawValue.isEmpty == false
            && generationID.rawValue.isEmpty == false
            && exportDirectoryPath.hasSuffix("/redacted-export")
            && provenanceSummaryJSONPath.hasSuffix("/provenance-summary.json")
            && comparisonMetadataJSONPath.hasSuffix("/comparison-metadata.json")
            && files.map(\.fileName).sorted() == Self.requiredFileNames
            && files.allSatisfy(\.fileHeld)
            && evidenceChainCoherent
            && packageComplete
            && exportedChecksumsMatchSource
            && missingEvidenceFailsClosed
            && redactedEvidenceOnly
            && noSecretValue
            && noEndpointPayload
            && noOrderPayload
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-999"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-997"),
            Identifier.constant("GH-998")
        ],
        releaseVersion: String = "v0.13.0",
        assessmentID: Identifier,
        generationID: Identifier,
        exportDirectoryPath: String,
        provenanceSummaryJSONPath: String,
        comparisonMetadataJSONPath: String,
        files: [ReleaseV0130RedactedAuditExportFile],
        evidenceChainCoherent: Bool,
        packageComplete: Bool,
        exportedChecksumsMatchSource: Bool,
        missingEvidenceFailsClosed: Bool = true,
        redactedEvidenceOnly: Bool = true,
        noSecretValue: Bool = true,
        noEndpointPayload: Bool = true,
        noOrderPayload: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs.sorted { $0.rawValue < $1.rawValue }
        self.releaseVersion = releaseVersion
        self.assessmentID = assessmentID
        self.generationID = generationID
        self.exportDirectoryPath = exportDirectoryPath
        self.provenanceSummaryJSONPath = provenanceSummaryJSONPath
        self.comparisonMetadataJSONPath = comparisonMetadataJSONPath
        self.files = files.sorted { $0.fileName < $1.fileName }
        self.evidenceChainCoherent = evidenceChainCoherent
        self.packageComplete = packageComplete
        self.exportedChecksumsMatchSource = exportedChecksumsMatchSource
        self.missingEvidenceFailsClosed = missingEvidenceFailsClosed
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.noSecretValue = noSecretValue
        self.noEndpointPayload = noEndpointPayload
        self.noOrderPayload = noOrderPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard packageHeld else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("redactedAuditExportPackageHeld=false")
        }
    }
}

/// ReleaseV0130LocalEvidenceBuildPipelineResult 是 GH-997 build pipeline 的内存返回值。
public struct ReleaseV0130LocalEvidenceBuildPipelineResult: Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let registryEntry: ReadinessAssessmentRegistryEntry
    public let registryDocument: ReadinessAssessmentRegistryDocument
    public let provenance: ReleaseV0130LocalEvidenceBuildProvenance
    public let manifest: ReadinessAssessmentManifestV2
    public let contentValidations: [ReadinessAssessmentArtifactContentValidationResult]
    public let bundleWrite: ReadinessAssessmentBundleV2SnapshotWriteResult
    public let validationReport: ReleaseV0130LocalEvidenceBuildValidationReport
    public let registryEntryCreated: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var pipelineHeld: Bool {
        issueID.rawValue == "GH-997"
            && releaseVersion == "v0.13.0"
            && registryEntry.entryHeld
            && registryDocument.documentHeld
            && registryDocument.entries.contains(registryEntry)
            && provenance.normalManifestEligible
            && manifest.manifestHeld
            && contentValidations.isEmpty == false
            && contentValidations.allSatisfy(\.validationHeld)
            && bundleWrite.bundle.bundleHeld
            && bundleWrite.manifest.manifestHeld
            && validationReport.reportHeld
            && validationReport.registryEntryCreated == registryEntryCreated
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-997"),
        releaseVersion: String = "v0.13.0",
        registryEntry: ReadinessAssessmentRegistryEntry,
        registryDocument: ReadinessAssessmentRegistryDocument,
        provenance: ReleaseV0130LocalEvidenceBuildProvenance,
        manifest: ReadinessAssessmentManifestV2,
        contentValidations: [ReadinessAssessmentArtifactContentValidationResult],
        bundleWrite: ReadinessAssessmentBundleV2SnapshotWriteResult,
        validationReport: ReleaseV0130LocalEvidenceBuildValidationReport,
        registryEntryCreated: Bool,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.registryEntry = registryEntry
        self.registryDocument = registryDocument
        self.provenance = provenance
        self.manifest = manifest
        self.contentValidations = contentValidations.sorted { $0.artifactID.rawValue < $1.artifactID.rawValue }
        self.bundleWrite = bundleWrite
        self.validationReport = validationReport
        self.registryEntryCreated = registryEntryCreated
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard pipelineHeld else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("buildPipelineHeld=false")
        }
    }
}

/// ReleaseV0130LocalEvidenceProvenanceError 描述 GH-996 provenance build 的 fail-closed 原因。
public enum ReleaseV0130LocalEvidenceProvenanceError: Error, Equatable, Sendable, CustomStringConvertible {
    case intakeInvalid([String])
    case missingField(String)
    case conflictingSourceCommit([String])
    case invalidSourceCommit(String)
    case invalidSourceRunID(String)
    case syntheticSourceRunID(String)
    case fixtureOnlyEvidence(String)
    case unsafeArtifactPath(String)
    case missingArtifact(String)
    case artifactMetadataMismatch(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case let .intakeInvalid(diagnostics):
            "GH-996 v0.13 provenance build requires valid #995 intake evidence, diagnostics=\(diagnostics.joined(separator: " | "))"
        case let .missingField(field):
            "GH-996 v0.13 provenance build missing required field \(field)"
        case let .conflictingSourceCommit(commits):
            "GH-996 v0.13 provenance build rejects conflicting source commits \(commits.joined(separator: ","))"
        case let .invalidSourceCommit(commit):
            "GH-996 v0.13 provenance build rejects invalid sourceCommit \(commit)"
        case let .invalidSourceRunID(runID):
            "GH-996 v0.13 provenance build rejects invalid sourceRunID \(runID)"
        case let .syntheticSourceRunID(runID):
            "GH-996 v0.13 provenance build rejects synthetic sourceRunID \(runID)"
        case let .fixtureOnlyEvidence(reason):
            "GH-996 v0.13 provenance build rejects fixture-only evidence: \(reason)"
        case let .unsafeArtifactPath(path):
            "GH-996 v0.13 provenance build rejects unsafe artifact path \(path)"
        case let .missingArtifact(path):
            "GH-996 v0.13 provenance build fails closed because artifact is missing at \(path)"
        case let .artifactMetadataMismatch(path):
            "GH-996 v0.13 provenance build rejects artifact metadata mismatch at \(path)"
        case let .boundaryDrift(field):
            "GH-996 v0.13 provenance build boundary drift: \(field)"
        }
    }
}

/// ReleaseV0130LocalEvidenceCategory 是 #995 local evidence root 的目录级分类。
///
/// 分类固定为 run logs、event stream、artifacts、registry 和 prior assessments；
/// 后续 bundle、registry write、diff / compare 仍由 #996 之后的 issue 分别实现。
public enum ReleaseV0130LocalEvidenceCategory: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case runLogs = "run-logs"
    case eventStream = "event-stream"
    case artifacts
    case registry
    case priorAssessments = "prior-assessments"
}

/// ReleaseV0130LocalEvidenceSchemaKind 描述 #995 intake 当前允许的本地文件 schema。
public enum ReleaseV0130LocalEvidenceSchemaKind: String, Codable, Equatable, Sendable {
    case jsonObject = "json-object"
    case jsonLines = "json-lines"
}

/// ReleaseV0130LocalEvidenceIntakeState 是单条 evidence 文件的 fail-closed 状态。
public enum ReleaseV0130LocalEvidenceIntakeState: String, Codable, Equatable, Sendable {
    case valid
    case missing
    case malformed
    case forbidden
}

/// ReleaseV0130LocalEvidenceDescriptor 描述 #995 允许读取的本地证据文件。
///
/// Descriptor 只接受显式 root 下的安全相对路径。它不会解析环境变量、secret path、
/// production endpoint URL，也不会生成 readiness output。
public struct ReleaseV0130LocalEvidenceDescriptor: Codable, Equatable, Sendable {
    public let category: ReleaseV0130LocalEvidenceCategory
    public let relativePath: String
    public let schemaKind: ReleaseV0130LocalEvidenceSchemaKind
    public let requiredFields: [String]
    public let required: Bool

    public var descriptorHeld: Bool {
        ProductionReadinessArtifactDescriptor.isSafeRelativePath(relativePath)
            && requiredFields.isEmpty == false
            && required
    }

    public init(
        category: ReleaseV0130LocalEvidenceCategory,
        relativePath: String,
        schemaKind: ReleaseV0130LocalEvidenceSchemaKind,
        requiredFields: [String],
        required: Bool = true
    ) throws {
        guard ProductionReadinessArtifactDescriptor.isSafeRelativePath(relativePath) else {
            throw ReleaseV0130LocalEvidenceIntakeError.unsafeRelativePath(relativePath)
        }
        guard requiredFields.isEmpty == false else {
            throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                path: relativePath,
                reason: "requiredFields must not be empty"
            )
        }
        self.category = category
        self.relativePath = relativePath
        self.schemaKind = schemaKind
        self.requiredFields = requiredFields
        self.required = required
    }
}

/// ReleaseV0130LocalEvidenceIntakeError 描述 #995 intake model 的本地失败原因。
public enum ReleaseV0130LocalEvidenceIntakeError: Error, Equatable, Sendable, CustomStringConvertible {
    case nonFileRoot(String)
    case missingEvidenceRoot(String)
    case missingRequiredDirectory(String)
    case missingRequiredFile(String)
    case unsafeRelativePath(String)
    case malformedJSON(String)
    case schemaViolation(path: String, reason: String)
    case forbiddenCapability(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case let .nonFileRoot(path):
            "GH-995 local evidence intake requires a local file root, got \(path)"
        case let .missingEvidenceRoot(path):
            "GH-995 local evidence intake fails closed because evidence root is missing at \(path)"
        case let .missingRequiredDirectory(path):
            "GH-995 local evidence intake fails closed because required directory is missing at \(path)"
        case let .missingRequiredFile(path):
            "GH-995 local evidence intake fails closed because required evidence file is missing at \(path)"
        case let .unsafeRelativePath(path):
            "GH-995 local evidence intake rejects unsafe relative path \(path)"
        case let .malformedJSON(path):
            "GH-995 local evidence intake fails closed because evidence JSON is malformed at \(path)"
        case let .schemaViolation(path, reason):
            "GH-995 local evidence intake schema violation at \(path): \(reason)"
        case let .forbiddenCapability(marker):
            "GH-995 local evidence intake rejects forbidden production capability \(marker)"
        case let .boundaryDrift(field):
            "GH-995 local evidence intake boundary drift: \(field)"
        }
    }
}

/// ReleaseV0130LocalEvidenceIntakeRecord 是单条本地 evidence 文件的检查结果。
///
/// Record 固定所有 production / endpoint / broker / order capability 为 false，确保 #995
/// 只是本地只读 intake diagnostics，而不是 readiness bundle、registry write 或 command path。
public struct ReleaseV0130LocalEvidenceIntakeRecord: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let descriptor: ReleaseV0130LocalEvidenceDescriptor
    public let absolutePath: String
    public let state: ReleaseV0130LocalEvidenceIntakeState
    public let byteCount: Int
    public let diagnostic: String
    public let localFileURLOnly: Bool
    public let readOnlyIntake: Bool
    public let noSecretValue: Bool
    public let noEndpointPayload: Bool
    public let noOrderPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var recordHeld: Bool {
        issueID.rawValue == "GH-995"
            && releaseVersion == "v0.13.0"
            && descriptor.descriptorHeld
            && absolutePath.isEmpty == false
            && byteCount >= 0
            && diagnostic.isEmpty == false
            && localFileURLOnly
            && readOnlyIntake
            && noSecretValue
            && noEndpointPayload
            && noOrderPayload
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-995"),
        releaseVersion: String = "v0.13.0",
        descriptor: ReleaseV0130LocalEvidenceDescriptor,
        absolutePath: String,
        state: ReleaseV0130LocalEvidenceIntakeState,
        byteCount: Int,
        diagnostic: String,
        localFileURLOnly: Bool = true,
        readOnlyIntake: Bool = true,
        noSecretValue: Bool = true,
        noEndpointPayload: Bool = true,
        noOrderPayload: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.descriptor = descriptor
        self.absolutePath = absolutePath
        self.state = state
        self.byteCount = byteCount
        self.diagnostic = diagnostic
        self.localFileURLOnly = localFileURLOnly
        self.readOnlyIntake = readOnlyIntake
        self.noSecretValue = noSecretValue
        self.noEndpointPayload = noEndpointPayload
        self.noOrderPayload = noOrderPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard recordHeld else {
            throw ReleaseV0130LocalEvidenceIntakeError.boundaryDrift("recordHeld=false")
        }
    }
}

/// ReleaseV0130LocalEvidenceIntakeReport 汇总 #995 本地 evidence root 发现结果。
public struct ReleaseV0130LocalEvidenceIntakeReport: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let releaseVersion: String
    public let evidenceRootPath: String
    public let requiredDirectoryPaths: [String]
    public let records: [ReleaseV0130LocalEvidenceIntakeRecord]
    public let diagnostics: [String]
    public let localFileURLOnly: Bool
    public let readOnlyIntake: Bool
    public let assessmentOutputWritten: Bool
    public let registryWritten: Bool
    public let bundleWritten: Bool
    public let diffBuilt: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var valid: Bool {
        records.count == ReleaseV0130LocalEvidenceCategory.allCases.count
            && records.allSatisfy { $0.state == .valid && $0.recordHeld }
            && diagnostics.isEmpty
            && categoryCoverageHeld
            && productionCapabilitiesDisabled
    }

    public var failClosed: Bool {
        valid == false
    }

    public var missingDiagnostics: [String] {
        diagnostics.filter { $0.contains("missing") }
    }

    public var malformedDiagnostics: [String] {
        diagnostics.filter { $0.contains("malformed") || $0.contains("schema violation") }
    }

    public var forbiddenDiagnostics: [String] {
        diagnostics.filter { $0.contains("forbidden") }
    }

    public var categoryCoverageHeld: Bool {
        Set(records.map(\.descriptor.category)) == Set(ReleaseV0130LocalEvidenceCategory.allCases)
    }

    public var productionCapabilitiesDisabled: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && productionCutoverAuthorized == false
            && assessmentOutputWritten == false
            && registryWritten == false
            && bundleWritten == false
            && diffBuilt == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-995"),
        releaseVersion: String = "v0.13.0",
        evidenceRootPath: String,
        requiredDirectoryPaths: [String],
        records: [ReleaseV0130LocalEvidenceIntakeRecord],
        diagnostics: [String],
        localFileURLOnly: Bool = true,
        readOnlyIntake: Bool = true,
        assessmentOutputWritten: Bool = false,
        registryWritten: Bool = false,
        bundleWritten: Bool = false,
        diffBuilt: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.issueID = issueID
        self.releaseVersion = releaseVersion
        self.evidenceRootPath = evidenceRootPath
        self.requiredDirectoryPaths = requiredDirectoryPaths
        self.records = records
        self.diagnostics = diagnostics
        self.localFileURLOnly = localFileURLOnly
        self.readOnlyIntake = readOnlyIntake
        self.assessmentOutputWritten = assessmentOutputWritten
        self.registryWritten = registryWritten
        self.bundleWritten = bundleWritten
        self.diffBuilt = diffBuilt
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV0130LocalEvidenceIntakeModel 只读发现并验证 #995 local evidence root。
///
/// Model 只从调用方显式传入的 file URL 读取五类本地 evidence，不解析 secret provider、
/// 不连接 endpoint / broker、不写 registry、不生成 bundle，也不触发任何 submit / cancel / replace。
public struct ReleaseV0130LocalEvidenceIntakeModel {
    public static let requiredDirectories = [
        "run-logs",
        "event-stream",
        "artifacts",
        "registry",
        "prior-assessments"
    ]

    public static let requiredDescriptors: [ReleaseV0130LocalEvidenceDescriptor] = {
        do {
            return [
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .runLogs,
                    relativePath: "run-logs/run-journal.jsonl",
                    schemaKind: .jsonLines,
                    requiredFields: ["sourceRunID", "sourceCommit", "eventType", "createdAt"]
                ),
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .eventStream,
                    relativePath: "event-stream/events.jsonl",
                    schemaKind: .jsonLines,
                    requiredFields: ["eventID", "sourceRunID", "eventType", "occurredAt"]
                ),
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .artifacts,
                    relativePath: "artifacts/artifact-index.json",
                    schemaKind: .jsonObject,
                    requiredFields: ["sourceRunID", "sourceCommit", "artifacts"]
                ),
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .registry,
                    relativePath: "registry/registry.json",
                    schemaKind: .jsonObject,
                    requiredFields: ["registryVersion", "assessments"]
                ),
                try ReleaseV0130LocalEvidenceDescriptor(
                    category: .priorAssessments,
                    relativePath: "prior-assessments/assessments-index.json",
                    schemaKind: .jsonObject,
                    requiredFields: ["assessmentIDs", "sourceRunIDs"]
                )
            ]
        } catch {
            preconditionFailure("GH-995 local evidence descriptor constants must be valid: \(error)")
        }
    }()

    private static let forbiddenMarkers = [
        "\"productionTradingEnabledByDefault\":true",
        "\"productionCutoverAuthorized\":true",
        "\"productionSecretRead\":true",
        "\"productionEndpointConnected\":true",
        "\"brokerEndpointConnected\":true",
        "\"productionOrderSubmitted\":true",
        "\"testnetOrderSubmissionAllowed\":true",
        "\"secretValue\":\"",
        "\"rawSecret\":\"",
        "\"listenKey\":\"",
        "\"signature\":\"",
        "\"signature=\"",
        "\"orderEndpointPayload\"",
        "\"accountEndpointPayload\"",
        "\"signedEndpointPayload\"",
        "/api/v3/account",
        "/api/v3/order",
        "/api/v3/userDataStream",
        "api.binance.com",
        "fapi.binance.com"
    ]

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func discover(evidenceRootURL: URL) throws -> ReleaseV0130LocalEvidenceIntakeReport {
        let rootPath = evidenceRootURL.path
        guard evidenceRootURL.isFileURL else {
            return try failureReport(
                evidenceRootPath: evidenceRootURL.absoluteString,
                diagnostics: [ReleaseV0130LocalEvidenceIntakeError.nonFileRoot(evidenceRootURL.absoluteString).description]
            )
        }

        guard isDirectory(evidenceRootURL) else {
            return try failureReport(
                evidenceRootPath: rootPath,
                diagnostics: [ReleaseV0130LocalEvidenceIntakeError.missingEvidenceRoot(rootPath).description]
            )
        }

        var records: [ReleaseV0130LocalEvidenceIntakeRecord] = []
        var diagnostics: [String] = []
        for descriptor in Self.requiredDescriptors {
            let record = try inspect(descriptor: descriptor, evidenceRootURL: evidenceRootURL)
            records.append(record)
            if record.state != .valid {
                diagnostics.append(record.diagnostic)
            }
        }

        return ReleaseV0130LocalEvidenceIntakeReport(
            evidenceRootPath: rootPath,
            requiredDirectoryPaths: Self.requiredDirectories,
            records: records,
            diagnostics: diagnostics
        )
    }

    public func validate(evidenceRootURL: URL) throws -> ReleaseV0130LocalEvidenceIntakeReport {
        try discover(evidenceRootURL: evidenceRootURL)
    }

    /// 从 #995 intake 已验证的 local evidence root 派生 normal manifest provenance。
    ///
    /// 该入口只读取本地 evidence 文件，并拒绝 placeholder sourceCommit、synthetic
    /// sourceRunID、fixture-only marker 以及缺失 / mismatch 的 artifact metadata。
    public func buildProvenance(evidenceRootURL: URL) throws -> ReleaseV0130LocalEvidenceBuildProvenance {
        let report = try validate(evidenceRootURL: evidenceRootURL)
        guard report.valid else {
            throw ReleaseV0130LocalEvidenceProvenanceError.intakeInvalid(report.diagnostics)
        }

        let runLogObjects = try jsonLines(relativePath: "run-logs/run-journal.jsonl", under: evidenceRootURL)
        let eventObjects = try jsonLines(relativePath: "event-stream/events.jsonl", under: evidenceRootURL)
        let artifactIndex = try jsonObject(relativePath: "artifacts/artifact-index.json", under: evidenceRootURL)
        let registry = try jsonObject(relativePath: "registry/registry.json", under: evidenceRootURL)
        let priorAssessments = try jsonObject(
            relativePath: "prior-assessments/assessments-index.json",
            under: evidenceRootURL
        )

        let allObjects: [Any] = runLogObjects + eventObjects + [artifactIndex, registry, priorAssessments]
        if allObjects.contains(where: Self.containsFixtureOnlyMarker) {
            throw ReleaseV0130LocalEvidenceProvenanceError.fixtureOnlyEvidence("explicit fixture-only marker")
        }

        let sourceCommits = Set(allObjects.flatMap(Self.sourceCommitValues))
        guard sourceCommits.isEmpty == false else {
            throw ReleaseV0130LocalEvidenceProvenanceError.missingField("sourceCommit")
        }
        guard sourceCommits.count == 1, let sourceCommit = sourceCommits.first else {
            throw ReleaseV0130LocalEvidenceProvenanceError.conflictingSourceCommit(sourceCommits.sorted())
        }
        guard ReadinessAssessmentManifestV2.isValidSourceCommit(sourceCommit) else {
            throw ReleaseV0130LocalEvidenceProvenanceError.invalidSourceCommit(sourceCommit)
        }

        let rawSourceRunIDs = Set(allObjects.flatMap(Self.sourceRunIDValues)).sorted()
        guard rawSourceRunIDs.isEmpty == false else {
            throw ReleaseV0130LocalEvidenceProvenanceError.missingField("sourceRunID")
        }
        let sourceRunIDs = try rawSourceRunIDs.map { rawValue in
            guard ReadinessAssessmentManifestV2.forbiddenSourceRunIDPlaceholders.contains(rawValue) == false,
                  rawValue.hasPrefix("source-run-") == false else {
                throw ReleaseV0130LocalEvidenceProvenanceError.syntheticSourceRunID(rawValue)
            }
            do {
                return try Identifier(rawValue)
            } catch {
                throw ReleaseV0130LocalEvidenceProvenanceError.invalidSourceRunID(rawValue)
            }
        }

        let artifacts = try artifactProvenances(from: artifactIndex, under: evidenceRootURL)
        let manifestArtifactSHA256: String
        let manifestArtifactBytes: Int
        if artifacts.count == 1, let onlyArtifact = artifacts.first?.provenance {
            manifestArtifactSHA256 = onlyArtifact.sha256
            manifestArtifactBytes = onlyArtifact.byteCount
        } else {
            var aggregate = Data()
            for artifact in artifacts.sorted(by: { $0.provenance.relativePath < $1.provenance.relativePath }) {
                aggregate.append(Data(artifact.provenance.relativePath.utf8))
                aggregate.append(Data("\n".utf8))
                aggregate.append(artifact.data)
                aggregate.append(Data("\n".utf8))
            }
            manifestArtifactSHA256 = Self.sha256Hex(aggregate)
            manifestArtifactBytes = artifacts.reduce(0) { $0 + $1.provenance.byteCount }
        }

        return try ReleaseV0130LocalEvidenceBuildProvenance(
            evidenceRootPath: evidenceRootURL.path,
            sourceCommit: sourceCommit,
            sourceRunIDs: sourceRunIDs,
            artifactProvenances: artifacts.map(\.provenance),
            artifactSHA256: manifestArtifactSHA256,
            artifactBytes: manifestArtifactBytes
        )
    }

    /// 执行 GH-997 的 schema、checksum、content policy、manifest、bundle 和 registry flow。
    ///
    /// 该入口复用 #995 / #996 的本地 evidence intake 与 provenance 约束，然后把每个
    /// local artifact 送入 v0.12 registry store 的 content-policy / bundle writer。Registry
    /// entry 缺失时只创建本地 readiness entry；不会读取 secret、连接 endpoint / broker、
    /// 或发送任何 submit / cancel / replace 命令。
    public func buildPipeline(
        assessmentID: Identifier,
        generationID: Identifier,
        evidenceRootURL: URL,
        store: ReadinessAssessmentRegistryStore,
        createdAt: Date
    ) throws -> ReleaseV0130LocalEvidenceBuildPipelineResult {
        let provenance = try buildProvenance(evidenceRootURL: evidenceRootURL)
        let (registryEntry, registryDocumentBeforeArtifacts, registryEntryCreated) = try ensureRegistryEntry(
            assessmentID: assessmentID,
            store: store,
            createdAt: createdAt
        )
        let artifactIndex = try jsonObject(relativePath: "artifacts/artifact-index.json", under: evidenceRootURL)
        let artifacts = try artifactProvenances(from: artifactIndex, under: evidenceRootURL)

        let manifest = try ReadinessAssessmentManifestV2(
            assessmentID: registryEntry.assessmentID,
            generationID: generationID,
            sourceRunIDs: provenance.sourceRunIDs,
            sourceCommit: provenance.sourceCommit,
            artifactContentType: .jsonEvidence,
            artifactSHA256: provenance.artifactSHA256,
            artifactBytes: provenance.artifactBytes,
            createdAt: createdAt,
            producerVersion: "mtpro-v0.13.0-gh997-build-pipeline"
        )
        _ = try store.writeManifestV2(manifest)

        var contentValidations: [ReadinessAssessmentArtifactContentValidationResult] = []
        var artifactValidations: [ReleaseV0130LocalEvidenceArtifactPipelineValidation] = []
        var artifactSnapshots: [ReadinessAssessmentBundleV2ArtifactSnapshot] = []

        for (index, artifact) in artifacts.sorted(by: { $0.provenance.relativePath < $1.provenance.relativePath }).enumerated() {
            let canonicalData = try ProductionReadinessArtifactStore.canonicalJSONData(for: artifact.data)
            let canonicalSHA256 = Self.sha256Hex(canonicalData)
            let observedFields = try Self.topLevelJSONFields(in: canonicalData)
            let contentPolicy = try ReadinessAssessmentArtifactContentPolicy(
                policyVersion: "v0.13.0-gh997-local-evidence-policy.v1",
                artifactID: artifact.provenance.artifactID,
                allowedJSONFields: observedFields,
                requiredJSONFields: observedFields
            )
            let artifactManifest = try ReadinessAssessmentManifestV2(
                assessmentID: registryEntry.assessmentID,
                generationID: generationID,
                sourceRunIDs: provenance.sourceRunIDs,
                sourceCommit: provenance.sourceCommit,
                artifactContentType: .jsonEvidence,
                artifactSHA256: canonicalSHA256,
                artifactBytes: canonicalData.count,
                createdAt: createdAt.addingTimeInterval(TimeInterval(index + 1)),
                producerVersion: "mtpro-v0.13.0-gh997-content-policy"
            )
            let contentValidation = try store.validateArtifactContent(
                data: artifact.data,
                manifest: artifactManifest,
                policy: contentPolicy,
                validatedAt: createdAt.addingTimeInterval(TimeInterval(index + 2))
            )
            contentValidations.append(contentValidation)
            artifactValidations.append(
                try ReleaseV0130LocalEvidenceArtifactPipelineValidation(
                    artifactID: artifact.provenance.artifactID,
                    relativePath: artifact.provenance.relativePath,
                    rawArtifactSHA256: artifact.provenance.sha256,
                    rawArtifactBytes: artifact.provenance.byteCount,
                    canonicalArtifactSHA256: canonicalSHA256,
                    canonicalArtifactBytes: canonicalData.count,
                    observedTopLevelJSONFields: observedFields,
                    policyChecksum: contentPolicy.policyChecksum,
                    contentValidationChecksum: contentValidation.contentValidationChecksum
                )
            )
            let snapshotArtifactPath = Self.bundleArtifactPath(
                assessmentID: registryEntry.assessmentID,
                generationID: generationID,
                artifactID: artifact.provenance.artifactID
            )
            try Self.writeBundleArtifactSnapshot(
                canonicalData,
                relativePath: snapshotArtifactPath,
                store: store
            )
            artifactSnapshots.append(
                try ReadinessAssessmentBundleV2ArtifactSnapshot(
                    artifactID: artifact.provenance.artifactID,
                    manifestChecksum: manifest.manifestChecksum,
                    artifactSHA256: canonicalSHA256,
                    contentValidationChecksum: contentValidation.contentValidationChecksum,
                    artifactPath: snapshotArtifactPath
                )
            )
        }

        let bundle = try ReadinessAssessmentBundleV2(
            assessmentID: registryEntry.assessmentID,
            generationID: generationID,
            reviewState: .inReview,
            sourceRunIDs: manifest.sourceRunIDs,
            sourceCommit: manifest.sourceCommit,
            artifactSnapshots: artifactSnapshots,
            createdAt: createdAt.addingTimeInterval(TimeInterval(artifacts.count + 2)),
            producerVersion: "mtpro-v0.13.0-gh997-build-pipeline"
        )
        let bundleWrite = try store.writeReadinessBundleV2ReviewSnapshot(bundle)
        let registryDocument = try store.load()
        let confirmedEntry = try registryDocument.inspect(assessmentID: registryEntry.assessmentID)
        guard registryDocumentBeforeArtifacts.entries.contains(registryEntry) else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("buildPipelineRegistryEntryMissing")
        }

        let validationReport = ReleaseV0130LocalEvidenceBuildValidationReport(
            assessmentID: confirmedEntry.assessmentID,
            generationID: generationID,
            evidenceRootPath: evidenceRootURL.path,
            sourceCommit: provenance.sourceCommit,
            sourceRunIDs: provenance.sourceRunIDs,
            artifactValidations: artifactValidations,
            manifestChecksum: manifest.manifestChecksum,
            readinessBundleChecksum: bundleWrite.bundle.bundleChecksum,
            readinessBundleManifestChecksum: bundleWrite.manifest.manifestChecksum,
            registryChecksum: registryDocument.registryChecksum,
            registryEntryCreated: registryEntryCreated
        )

        return try ReleaseV0130LocalEvidenceBuildPipelineResult(
            registryEntry: confirmedEntry,
            registryDocument: registryDocument,
            provenance: provenance,
            manifest: manifest,
            contentValidations: contentValidations,
            bundleWrite: bundleWrite,
            validationReport: validationReport,
            registryEntryCreated: registryEntryCreated
        )
    }

    /// 执行 GH-999 的 redacted audit export package 写出。
    ///
    /// 该入口只接受已经通过 #998 evidence-chain validate 的本地 assessment。Manifest V2 和
    /// Bundle V2 会 byte-for-byte 复制到 redacted export directory，其余 summary /
    /// validation / provenance / comparison 文件只包含本地审计 metadata 和 checksum 证据。
    @discardableResult
    public func writeRedactedAuditExportPackage(
        assessmentID: Identifier,
        store: ReadinessAssessmentRegistryStore
    ) throws -> ReleaseV0130RedactedAuditExportPackageReport {
        let preExportReport = try validateEvidenceChain(assessmentID: assessmentID, store: store)
        guard preExportReport.evidenceChainCoherent else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "redactedAuditExport:evidenceChainInvalid:\(preExportReport.failureReasons.joined(separator: ","))"
            )
        }
        guard let generationID = preExportReport.generationID else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "redactedAuditExport:generationIDMissing"
            )
        }

        let registryDocument = try store.load()
        let registryEntry = try registryDocument.inspect(assessmentID: assessmentID)
        let manifest = try store.readManifestV2(assessmentID: assessmentID)
        let bundle = try store.readReadinessBundleV2(
            assessmentID: assessmentID,
            generationID: generationID
        )
        let bundleManifest = try store.readReadinessBundleV2Manifest(
            assessmentID: assessmentID,
            generationID: generationID
        )
        guard registryEntry.productionCapabilitiesDisabled,
              manifest.productionCapabilitiesDisabled,
              bundle.productionCapabilitiesDisabled,
              preExportReport.productionCapabilitiesDisabled else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "redactedAuditExport:productionCapabilitiesEnabled"
            )
        }

        let manifestData = try Data(contentsOf: Self.storeURL(
            for: manifest.manifestV2Path,
            store: store,
            isDirectory: false
        ))
        let bundleData = try Data(contentsOf: Self.bundleJSONURL(
            assessmentID: assessmentID,
            generationID: generationID,
            store: store
        ))
        let validationData = try Self.exportEncoder.encode(preExportReport)
        let manifestSHA256 = Self.sha256Hex(manifestData)
        let bundleSHA256 = Self.sha256Hex(bundleData)
        let validationSHA256 = Self.sha256Hex(validationData)

        let summaryData = try Self.canonicalExportJSONData([
            "assessmentID": assessmentID.rawValue,
            "generationID": generationID.rawValue,
            "issueID": "GH-999",
            "releaseVersion": "v0.13.0",
            "registryChecksum": registryDocument.registryChecksum,
            "manifestChecksum": manifest.manifestChecksum,
            "bundleChecksum": bundle.bundleChecksum,
            "bundleManifestChecksum": bundleManifest.manifestChecksum,
            "evidenceChainCoherent": true,
            "packageFileNames": ReleaseV0130RedactedAuditExportPackageReport.requiredFileNames,
            "redactedEvidenceOnly": true,
            "noSecretValue": true,
            "noEndpointPayload": true,
            "noOrderPayload": true,
            "productionTradingEnabledByDefault": false,
            "productionCutoverAuthorized": false,
            "productionSecretRead": false,
            "productionEndpointConnected": false,
            "brokerEndpointConnected": false,
            "productionOrderSubmitted": false,
            "testnetOrderSubmissionAllowed": false
        ])
        let provenanceData = try Self.canonicalExportJSONData([
            "assessmentID": assessmentID.rawValue,
            "generationID": generationID.rawValue,
            "issueID": "GH-999",
            "releaseVersion": "v0.13.0",
            "sourceManifestPath": manifest.manifestV2Path,
            "sourceManifestSHA256": manifestSHA256,
            "sourceBundlePath": bundle.bundlePath,
            "sourceBundleSHA256": bundleSHA256,
            "sourceValidationReportSHA256": validationSHA256,
            "artifactSnapshotCount": bundle.artifactSnapshots.count,
            "artifactSnapshotSHA256": bundle.artifactSnapshots.map(\.artifactSHA256).sorted(),
            "sourceRunIDs": manifest.sourceRunIDs.map(\.rawValue),
            "sourceCommit": manifest.sourceCommit,
            "redactedEvidenceOnly": true,
            "noSecretValue": true,
            "noEndpointPayload": true,
            "noOrderPayload": true,
            "productionTradingEnabledByDefault": false,
            "productionCutoverAuthorized": false,
            "productionSecretRead": false,
            "productionEndpointConnected": false,
            "brokerEndpointConnected": false,
            "productionOrderSubmitted": false,
            "testnetOrderSubmissionAllowed": false
        ])
        let comparisonData = try Self.canonicalExportJSONData([
            "assessmentID": assessmentID.rawValue,
            "generationID": generationID.rawValue,
            "issueID": "GH-999",
            "releaseVersion": "v0.13.0",
            "comparisonAvailable": false,
            "comparisonReason": "single-assessment redacted audit export package",
            "comparisonDoesNotMutateAssessments": true,
            "operatorReviewOnly": true,
            "redactedEvidenceOnly": true,
            "noSecretValue": true,
            "noEndpointPayload": true,
            "noOrderPayload": true,
            "productionTradingEnabledByDefault": false,
            "productionCutoverAuthorized": false,
            "productionSecretRead": false,
            "productionEndpointConnected": false,
            "brokerEndpointConnected": false,
            "productionOrderSubmitted": false,
            "testnetOrderSubmissionAllowed": false
        ])

        let exportDirectoryURL = Self.storeURL(
            for: registryEntry.artifactPaths.redactedExportDirectoryPath,
            store: store,
            isDirectory: true
        )
        try Self.replaceDirectory(exportDirectoryURL, store: store)

        let files = try [
            Self.writeExportFile(
                fileName: "assessment-summary.json",
                data: summaryData,
                sourceRelativePath: nil,
                sourceSHA256: nil,
                exportDirectoryURL: exportDirectoryURL,
                exportDirectoryPath: registryEntry.artifactPaths.redactedExportDirectoryPath,
                store: store
            ),
            Self.writeExportFile(
                fileName: "manifest-v2.json",
                data: manifestData,
                sourceRelativePath: manifest.manifestV2Path,
                sourceSHA256: manifestSHA256,
                exportDirectoryURL: exportDirectoryURL,
                exportDirectoryPath: registryEntry.artifactPaths.redactedExportDirectoryPath,
                store: store
            ),
            Self.writeExportFile(
                fileName: "bundle-v2.json",
                data: bundleData,
                sourceRelativePath: bundle.bundlePath,
                sourceSHA256: bundleSHA256,
                exportDirectoryURL: exportDirectoryURL,
                exportDirectoryPath: registryEntry.artifactPaths.redactedExportDirectoryPath,
                store: store
            ),
            Self.writeExportFile(
                fileName: "validation-report.json",
                data: validationData,
                sourceRelativePath: nil,
                sourceSHA256: nil,
                exportDirectoryURL: exportDirectoryURL,
                exportDirectoryPath: registryEntry.artifactPaths.redactedExportDirectoryPath,
                store: store
            ),
            Self.writeExportFile(
                fileName: "provenance.json",
                data: provenanceData,
                sourceRelativePath: nil,
                sourceSHA256: nil,
                exportDirectoryURL: exportDirectoryURL,
                exportDirectoryPath: registryEntry.artifactPaths.redactedExportDirectoryPath,
                store: store
            ),
            Self.writeExportFile(
                fileName: "comparison.json",
                data: comparisonData,
                sourceRelativePath: nil,
                sourceSHA256: nil,
                exportDirectoryURL: exportDirectoryURL,
                exportDirectoryPath: registryEntry.artifactPaths.redactedExportDirectoryPath,
                store: store
            )
        ]

        try Self.writeStoreData(
            provenanceData,
            relativePath: registryEntry.artifactPaths.provenanceSummaryJSONPath,
            store: store,
            isDirectory: false
        )
        try Self.writeStoreData(
            comparisonData,
            relativePath: registryEntry.artifactPaths.comparisonMetadataJSONPath,
            store: store,
            isDirectory: false
        )

        let postExportReport = try validateEvidenceChain(assessmentID: assessmentID, store: store)
        guard postExportReport.evidenceChainCoherent,
              postExportReport.exportComparisonIdentityConsistent else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "redactedAuditExport:postExportIdentityInvalid"
            )
        }

        let packageComplete = ReleaseV0130RedactedAuditExportPackageReport.requiredFileNames.allSatisfy { fileName in
            let url = exportDirectoryURL.appendingPathComponent(fileName, isDirectory: false)
            return store.fileManager.fileExists(atPath: url.path)
                && ((try? Data(contentsOf: url).isEmpty) == false)
        }
        let exportedChecksumsMatchSource = files.allSatisfy(\.checksumMatchesSource)

        return try ReleaseV0130RedactedAuditExportPackageReport(
            assessmentID: assessmentID,
            generationID: generationID,
            exportDirectoryPath: registryEntry.artifactPaths.redactedExportDirectoryPath,
            provenanceSummaryJSONPath: registryEntry.artifactPaths.provenanceSummaryJSONPath,
            comparisonMetadataJSONPath: registryEntry.artifactPaths.comparisonMetadataJSONPath,
            files: files,
            evidenceChainCoherent: postExportReport.evidenceChainCoherent,
            packageComplete: packageComplete,
            exportedChecksumsMatchSource: exportedChecksumsMatchSource
        )
    }

    /// 执行 GH-1000 的 evidence-level readiness diff / compare。
    ///
    /// Compare 先复用 #998 evidence-chain validate。任一 assessment 出现 missing、stale、
    /// tampered 或 inconsistent evidence 时，report 会进入 blocker state，而不是输出普通
    /// changed / unchanged diff。该入口只写 follow-up assessment 的本地 comparison metadata；
    /// registry document 必须保持字节语义不变。
    @discardableResult
    public func compareEvidenceLevelAssessments(
        baselineAssessmentID: Identifier,
        followUpAssessmentID: Identifier,
        store: ReadinessAssessmentRegistryStore,
        comparedAt: Date
    ) throws -> ReleaseV0130EvidenceLevelComparisonReport {
        let registryBefore = try store.load()
        _ = try registryBefore.inspect(assessmentID: baselineAssessmentID)
        let followUpEntry = try registryBefore.inspect(assessmentID: followUpAssessmentID)

        let baselineValidation = try validateEvidenceChain(assessmentID: baselineAssessmentID, store: store)
        let followUpValidation = try validateEvidenceChain(assessmentID: followUpAssessmentID, store: store)
        let baselineEvidence = try Self.evidenceLevelFingerprints(
            assessmentID: baselineAssessmentID,
            validationReport: baselineValidation,
            store: store
        )
        let followUpEvidence = try Self.evidenceLevelFingerprints(
            assessmentID: followUpAssessmentID,
            validationReport: followUpValidation,
            store: store
        )

        let deltas = Self.evidenceLevelDeltas(
            baselineValidation: baselineValidation,
            followUpValidation: followUpValidation,
            baselineEvidence: baselineEvidence,
            followUpEvidence: followUpEvidence
        )
        let report = ReleaseV0130EvidenceLevelComparisonReport(
            assessmentID: followUpAssessmentID,
            baselineAssessmentID: baselineAssessmentID,
            followUpAssessmentID: followUpAssessmentID,
            baselineGenerationID: baselineValidation.generationID,
            followUpGenerationID: followUpValidation.generationID,
            comparedAt: comparedAt,
            baselineValidationState: baselineValidation.validationState,
            followUpValidationState: followUpValidation.validationState,
            deltas: deltas
        )
        guard report.evidenceLevelComparisonHeld else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "evidenceLevelCompare:reportHeld=false"
            )
        }

        let registryAfterCompare = try store.load()
        guard registryAfterCompare == registryBefore else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "evidenceLevelCompare:registryMutated"
            )
        }

        try Self.writeComparisonMetadata(report, followUpEntry: followUpEntry, store: store)
        let registryAfterSidecar = try store.load()
        guard registryAfterSidecar == registryBefore else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "evidenceLevelCompare:sidecarMutatedRegistry"
            )
        }

        let postCompareValidation = try validateEvidenceChain(assessmentID: followUpAssessmentID, store: store)
        guard postCompareValidation.exportComparisonIdentityConsistent else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "evidenceLevelCompare:comparisonIdentityInvalid"
            )
        }

        return report
    }

    /// 执行 GH-998 的完整 evidence-chain consistency check。
    ///
    /// 该入口只读取本地 registry store，逐项检查 registry entry、Manifest V2、Bundle V2、
    /// bundle manifest、artifact snapshot checksum 和 provenance 是否互相一致。Optional
    /// export / comparison 文件如果存在，也必须绑定同一个 assessmentID；如果后续 issue
    /// 尚未生成这些文件，validate 不会抢占 #999 / #1000 的 required artifact scope。
    public func validateEvidenceChain(
        assessmentID: Identifier,
        store: ReadinessAssessmentRegistryStore
    ) throws -> ReleaseV0130LocalEvidenceChainValidationReport {
        var failureReasons: [String] = []

        let registryDocument = Self.capture("registry:missing-or-corrupt", into: &failureReasons) {
            try store.load()
        }
        let registryEntry = Self.capture("registryEntry:missing-or-invalid", into: &failureReasons) {
            try registryDocument?.inspect(assessmentID: assessmentID)
        }
        let manifest = Self.capture("manifestV2:missing-or-invalid", into: &failureReasons) {
            try store.readManifestV2(assessmentID: assessmentID)
        }

        let generationID = manifest?.generationID
        let bundle: ReadinessAssessmentBundleV2? = Self.capture("bundleV2:missing-or-invalid", into: &failureReasons) {
            guard let manifest else {
                throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("bundleV2:manifestRequired")
            }
            return try store.readReadinessBundleV2(
                assessmentID: assessmentID,
                generationID: manifest.generationID
            )
        }
        let bundleManifest: ReadinessAssessmentBundleV2Manifest? = Self.capture("bundleManifest:missing-or-invalid", into: &failureReasons) {
            guard let manifest else {
                throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("bundleManifest:manifestRequired")
            }
            return try store.readReadinessBundleV2Manifest(
                assessmentID: assessmentID,
                generationID: manifest.generationID
            )
        }

        let bundleData: Data? = Self.capture("bundleBytes:missing", into: &failureReasons) {
            guard let generationID else {
                throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("bundleBytes:generationRequired")
            }
            return try Data(contentsOf: Self.bundleJSONURL(
                assessmentID: assessmentID,
                generationID: generationID,
                store: store
            ))
        }
        let bundleBytesMatchManifest = {
            guard let bundleData, let bundleManifest else {
                return false
            }
            return Self.sha256Hex(bundleData) == bundleManifest.bundleJSONSHA256
                && bundleData.count == bundleManifest.bundleBytes
        }()
        if bundleData != nil, bundleManifest != nil, bundleBytesMatchManifest == false {
            failureReasons.append("bundleBytes:checksum-or-byte-count-mismatch")
        }

        let registryManifestAssessmentMatches = registryEntry?.assessmentID == manifest?.assessmentID
        if registryEntry != nil, manifest != nil, registryManifestAssessmentMatches == false {
            failureReasons.append("registryManifest:assessmentID-mismatch")
        }

        let manifestBundleIdentityMatches = {
            guard let manifest, let bundle, let bundleManifest else {
                return false
            }
            return bundle.assessmentID == manifest.assessmentID
                && bundle.generationID == manifest.generationID
                && bundleManifest.assessmentID == manifest.assessmentID
                && bundleManifest.generationID == manifest.generationID
                && bundleManifest.bundleChecksum == bundle.bundleChecksum
        }()
        if manifest != nil, bundle != nil, bundleManifest != nil, manifestBundleIdentityMatches == false {
            failureReasons.append("manifestBundle:identity-or-bundle-checksum-mismatch")
        }

        let manifestBundleProvenanceMatches = {
            guard let manifest, let bundle else {
                return false
            }
            return bundle.sourceCommit == manifest.sourceCommit
                && bundle.sourceRunIDs == manifest.sourceRunIDs
        }()
        if manifest != nil, bundle != nil, manifestBundleProvenanceMatches == false {
            failureReasons.append("manifestBundle:source-provenance-mismatch")
        }

        let artifactSnapshotsPresent = bundle?.artifactSnapshots.isEmpty == false
        if bundle != nil, artifactSnapshotsPresent == false {
            failureReasons.append("artifactSnapshots:missing")
        }

        let artifactSnapshotBytesMatch = {
            guard let bundle else {
                return false
            }
            return bundle.artifactSnapshots.allSatisfy {
                Self.artifactSnapshotBytesMatch($0, store: store)
            }
        }()
        if bundle != nil, artifactSnapshotsPresent, artifactSnapshotBytesMatch == false {
            failureReasons.append("artifactSnapshots:artifact-bytes-missing-or-checksum-mismatch")
        }

        let artifactSnapshotsMatchManifest = {
            guard let manifest, let bundle else {
                return false
            }
            return bundle.artifactSnapshots.allSatisfy { snapshot in
                snapshot.snapshotHeld
                    && snapshot.manifestChecksum == manifest.manifestChecksum
                    && Self.artifactSnapshotBytesMatch(snapshot, store: store)
            }
        }()
        if manifest != nil, bundle != nil, artifactSnapshotsPresent, artifactSnapshotsMatchManifest == false {
            failureReasons.append("artifactSnapshots:manifest-checksum-or-policy-mismatch")
        }

        let contentValidationChecksumsPresent = {
            guard let bundle else {
                return false
            }
            return bundle.artifactSnapshots.allSatisfy {
                ReadinessAssessmentManifestV2.isValidSHA256Checksum($0.contentValidationChecksum)
                    && ReadinessAssessmentManifestV2.isValidSHA256Checksum($0.artifactSHA256)
            }
        }()
        if bundle != nil, artifactSnapshotsPresent, contentValidationChecksumsPresent == false {
            failureReasons.append("artifactSnapshots:missing-content-validation-checksum")
        }

        let exportComparisonIdentityConsistent = Self.optionalJSONAssessmentIdentityMatches(
            relativePath: registryEntry?.artifactPaths.provenanceSummaryJSONPath,
            assessmentID: assessmentID,
            store: store
        ) && Self.optionalJSONAssessmentIdentityMatches(
            relativePath: registryEntry?.artifactPaths.comparisonMetadataJSONPath,
            assessmentID: assessmentID,
            store: store
        )
        && Self.optionalExportDirectoryIdentityMatches(
            relativePath: registryEntry?.artifactPaths.redactedExportDirectoryPath,
            assessmentID: assessmentID,
            store: store
        )
        if registryEntry != nil, exportComparisonIdentityConsistent == false {
            failureReasons.append("exportComparison:assessmentID-mismatch")
        }

        let orderedReasons = Array(NSOrderedSet(array: failureReasons)).compactMap { $0 as? String }
        return ReleaseV0130LocalEvidenceChainValidationReport(
            assessmentID: assessmentID,
            generationID: generationID,
            registryDocumentHeld: registryDocument?.documentHeld ?? false,
            registryEntryHeld: registryEntry?.entryHeld ?? false,
            manifestV2Present: manifest != nil,
            manifestHeld: manifest?.manifestHeld ?? false,
            bundleV2Present: bundle != nil,
            bundleHeld: bundle?.bundleHeld ?? false,
            bundleManifestPresent: bundleManifest != nil,
            bundleManifestHeld: bundleManifest?.manifestHeld ?? false,
            bundleBytesMatchManifest: bundleBytesMatchManifest,
            registryManifestAssessmentMatches: registryManifestAssessmentMatches,
            manifestBundleIdentityMatches: manifestBundleIdentityMatches,
            manifestBundleProvenanceMatches: manifestBundleProvenanceMatches,
            artifactSnapshotsPresent: artifactSnapshotsPresent,
            artifactSnapshotsMatchManifest: artifactSnapshotsMatchManifest,
            contentValidationChecksumsPresent: contentValidationChecksumsPresent,
            exportComparisonIdentityConsistent: exportComparisonIdentityConsistent,
            failureReasons: orderedReasons
        )
    }

    private struct EvidenceLevelFingerprintSet {
        let manifest: ReadinessAssessmentManifestV2
        let bundle: ReadinessAssessmentBundleV2
        let bundleManifest: ReadinessAssessmentBundleV2Manifest
        let fingerprints: [ReleaseV0130EvidenceLevelDiffSection: String]
        let evidenceLinkReasons: [ReleaseV0130EvidenceLevelDiffSection: [String]]
    }

    private static func evidenceLevelFingerprints(
        assessmentID: Identifier,
        validationReport: ReleaseV0130LocalEvidenceChainValidationReport,
        store: ReadinessAssessmentRegistryStore
    ) throws -> EvidenceLevelFingerprintSet? {
        guard validationReport.evidenceChainCoherent else {
            return nil
        }
        guard let generationID = validationReport.generationID else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "evidenceLevelCompare:generationIDMissing"
            )
        }

        let registryEntry = try store.inspect(assessmentID: assessmentID)
        let manifest = try store.readManifestV2(assessmentID: assessmentID)
        let bundle = try store.readReadinessBundleV2(
            assessmentID: assessmentID,
            generationID: generationID
        )
        let bundleManifest = try store.readReadinessBundleV2Manifest(
            assessmentID: assessmentID,
            generationID: generationID
        )
        let artifactIDs = bundle.artifactSnapshots.map(\.artifactID.rawValue).sorted()
        let artifactSHA256s = bundle.artifactSnapshots.map(\.artifactSHA256).sorted()
        let contentChecksums = bundle.artifactSnapshots.map(\.contentValidationChecksum).sorted()
        let artifactPaths = bundle.artifactSnapshots.map(\.artifactPath).sorted()

        let fingerprints: [ReleaseV0130EvidenceLevelDiffSection: String] = [
            .sourceData: evidenceFingerprint([
                manifest.sourceCommit,
                manifest.sourceRunIDs.map(\.rawValue).sorted().joined(separator: ",")
            ]),
            .policy: evidenceFingerprint(contentChecksums),
            .riskPosture: evidenceFingerprint([
                registryEntry.state.rawValue,
                registryEntry.lifecycle.rawValue,
                bundle.reviewState.rawValue,
                "productionCapabilitiesDisabled=\(registryEntry.productionCapabilitiesDisabled)",
                "bundleProductionCapabilitiesDisabled=\(bundle.productionCapabilitiesDisabled)"
            ]),
            .checksumChain: evidenceFingerprint([
                manifest.manifestChecksum,
                bundle.bundleChecksum,
                bundleManifest.manifestChecksum,
                bundleManifest.bundleJSONSHA256
            ] + artifactSHA256s + contentChecksums),
            .provenance: evidenceFingerprint([
                manifest.sourceCommit,
                manifest.producerVersion,
                bundle.producerVersion,
                manifest.generationID.rawValue,
                bundle.generationID.rawValue
            ] + manifest.sourceRunIDs.map(\.rawValue).sorted() + artifactIDs + artifactPaths),
            .evidenceCompleteness: evidenceFingerprint([
                validationReport.validationState,
                "artifactSnapshots=\(bundle.artifactSnapshots.count)",
                "artifactSnapshotsPresent=\(validationReport.artifactSnapshotsPresent)",
                "artifactSnapshotsMatchManifest=\(validationReport.artifactSnapshotsMatchManifest)",
                "contentValidationChecksumsPresent=\(validationReport.contentValidationChecksumsPresent)",
                "exportComparisonIdentityConsistent=\(validationReport.exportComparisonIdentityConsistent)"
            ])
        ]
        let reasons: [ReleaseV0130EvidenceLevelDiffSection: [String]] = [
            .sourceData: ["source-data:sourceCommit+sourceRunIDs"],
            .policy: ["policy:artifact-content-validation-checksums"],
            .riskPosture: ["risk-posture:registry-state+lifecycle+bundle-review-state+production-disabled"],
            .checksumChain: ["checksum-chain:manifest+bundle+bundle-manifest+artifact-snapshots"],
            .provenance: ["provenance:sourceCommit+sourceRunIDs+generation+artifact-paths"],
            .evidenceCompleteness: ["evidence-completeness:validate-report+artifact-count+identity"]
        ]

        return EvidenceLevelFingerprintSet(
            manifest: manifest,
            bundle: bundle,
            bundleManifest: bundleManifest,
            fingerprints: fingerprints,
            evidenceLinkReasons: reasons
        )
    }

    private static func evidenceLevelDeltas(
        baselineValidation: ReleaseV0130LocalEvidenceChainValidationReport,
        followUpValidation: ReleaseV0130LocalEvidenceChainValidationReport,
        baselineEvidence: EvidenceLevelFingerprintSet?,
        followUpEvidence: EvidenceLevelFingerprintSet?
    ) -> [ReleaseV0130EvidenceLevelDiff] {
        let validationBlockers = evidenceValidationBlockers(
            prefix: "baseline",
            report: baselineValidation
        ) + evidenceValidationBlockers(
            prefix: "follow-up",
            report: followUpValidation
        )
        let staleBlockers = evidenceStaleInputBlockers(
            baselineEvidence: baselineEvidence,
            followUpEvidence: followUpEvidence
        )

        return ReleaseV0130EvidenceLevelDiffSection.allCases.map { section in
            let sectionBlockers = validationBlockers + (section == .evidenceCompleteness ? staleBlockers : [])
            let baselineFingerprint = baselineEvidence?.fingerprints[section]
            let followUpFingerprint = followUpEvidence?.fingerprints[section]
            let reasons = Array(NSOrderedSet(array:
                (baselineEvidence?.evidenceLinkReasons[section] ?? [])
                    + (followUpEvidence?.evidenceLinkReasons[section] ?? [])
            )).compactMap { $0 as? String }

            if sectionBlockers.isEmpty == false {
                return ReleaseV0130EvidenceLevelDiff(
                    section: section,
                    state: .blocker,
                    baselineFingerprint: baselineFingerprint,
                    followUpFingerprint: followUpFingerprint,
                    evidenceLinkReasons: reasons,
                    blockerReasons: sectionBlockers
                )
            }
            return ReleaseV0130EvidenceLevelDiff(
                section: section,
                state: baselineFingerprint == followUpFingerprint ? .unchanged : .changed,
                baselineFingerprint: baselineFingerprint,
                followUpFingerprint: followUpFingerprint,
                evidenceLinkReasons: reasons,
                blockerReasons: []
            )
        }
    }

    private static func evidenceValidationBlockers(
        prefix: String,
        report: ReleaseV0130LocalEvidenceChainValidationReport
    ) -> [String] {
        guard report.evidenceChainCoherent == false else {
            return []
        }
        let reasons = report.failureReasons.isEmpty ? ["evidenceChain:invalid"] : report.failureReasons
        return reasons.map { "\(prefix):\($0)" }
    }

    private static func evidenceStaleInputBlockers(
        baselineEvidence: EvidenceLevelFingerprintSet?,
        followUpEvidence: EvidenceLevelFingerprintSet?
    ) -> [String] {
        guard let baselineEvidence, let followUpEvidence else {
            return []
        }
        guard followUpEvidence.manifest.createdAt > baselineEvidence.manifest.createdAt else {
            return ["follow-up:stale-input:manifest-createdAt-not-newer-than-baseline"]
        }
        return []
    }

    private static func evidenceFingerprint(_ parts: [String]) -> String {
        sha256Hex(Data(parts.joined(separator: "|").utf8))
    }

    private static func writeComparisonMetadata(
        _ report: ReleaseV0130EvidenceLevelComparisonReport,
        followUpEntry: ReadinessAssessmentRegistryEntry,
        store: ReadinessAssessmentRegistryStore
    ) throws {
        let data = try exportEncoder.encode(report)
        try writeStoreData(
            data,
            relativePath: followUpEntry.artifactPaths.comparisonMetadataJSONPath,
            store: store,
            isDirectory: false
        )

        let exportDirectoryURL = storeURL(
            for: followUpEntry.artifactPaths.redactedExportDirectoryPath,
            store: store,
            isDirectory: true
        )
        var isDirectory: ObjCBool = false
        if store.fileManager.fileExists(atPath: exportDirectoryURL.path, isDirectory: &isDirectory),
           isDirectory.boolValue {
            try writeStoreData(
                data,
                relativePath: "\(followUpEntry.artifactPaths.redactedExportDirectoryPath)/comparison.json",
                store: store,
                isDirectory: false
            )
        }
    }

    private func failureReport(
        evidenceRootPath: String,
        diagnostics: [String]
    ) throws -> ReleaseV0130LocalEvidenceIntakeReport {
        let records = try Self.requiredDescriptors.map { descriptor in
            try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: evidenceRootPath,
                state: .missing,
                byteCount: 0,
                diagnostic: diagnostics.joined(separator: "; ")
            )
        }
        return ReleaseV0130LocalEvidenceIntakeReport(
            evidenceRootPath: evidenceRootPath,
            requiredDirectoryPaths: Self.requiredDirectories,
            records: records,
            diagnostics: diagnostics
        )
    }

    private func inspect(
        descriptor: ReleaseV0130LocalEvidenceDescriptor,
        evidenceRootURL: URL
    ) throws -> ReleaseV0130LocalEvidenceIntakeRecord {
        let evidenceURL = url(for: descriptor.relativePath, under: evidenceRootURL)
        let parentPath = String(descriptor.relativePath.split(separator: "/").dropLast().joined(separator: "/"))
        let parentURL = parentPath.isEmpty ? evidenceRootURL : url(for: parentPath, under: evidenceRootURL)
        let absolutePath = evidenceURL.path

        guard isDirectory(parentURL) else {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .missing,
                byteCount: 0,
                diagnostic: ReleaseV0130LocalEvidenceIntakeError
                    .missingRequiredDirectory(parentURL.path)
                    .description
            )
        }

        guard fileManager.fileExists(atPath: absolutePath) else {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .missing,
                byteCount: 0,
                diagnostic: ReleaseV0130LocalEvidenceIntakeError
                    .missingRequiredFile(descriptor.relativePath)
                    .description
            )
        }

        let data = try Data(contentsOf: evidenceURL)
        let byteCount = data.count
        let content = String(data: data, encoding: .utf8) ?? ""
        if let forbidden = Self.forbiddenMarkers.first(where: { marker in
            Self.normalized(content).contains(Self.normalized(marker))
        }) {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .forbidden,
                byteCount: byteCount,
                diagnostic: ReleaseV0130LocalEvidenceIntakeError
                    .forbiddenCapability(forbidden)
                    .description
            )
        }

        do {
            try validateSchema(data: data, descriptor: descriptor)
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .valid,
                byteCount: byteCount,
                diagnostic: "valid local evidence \(descriptor.relativePath)"
            )
        } catch let error as ReleaseV0130LocalEvidenceIntakeError {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .malformed,
                byteCount: byteCount,
                diagnostic: error.description
            )
        } catch {
            return try ReleaseV0130LocalEvidenceIntakeRecord(
                descriptor: descriptor,
                absolutePath: absolutePath,
                state: .malformed,
                byteCount: byteCount,
                diagnostic: ReleaseV0130LocalEvidenceIntakeError
                    .malformedJSON(descriptor.relativePath)
                    .description
            )
        }
    }

    private func validateSchema(
        data: Data,
        descriptor: ReleaseV0130LocalEvidenceDescriptor
    ) throws {
        switch descriptor.schemaKind {
        case .jsonObject:
            let object = try JSONSerialization.jsonObject(with: data)
            guard let dictionary = object as? [String: Any] else {
                throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                    path: descriptor.relativePath,
                    reason: "expected JSON object"
                )
            }
            try requireFields(descriptor.requiredFields, in: dictionary, path: descriptor.relativePath)
        case .jsonLines:
            guard let string = String(data: data, encoding: .utf8) else {
                throw ReleaseV0130LocalEvidenceIntakeError.malformedJSON(descriptor.relativePath)
            }
            let lines = string.split(whereSeparator: \.isNewline)
            guard lines.isEmpty == false else {
                throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                    path: descriptor.relativePath,
                    reason: "expected at least one JSON line"
                )
            }
            for line in lines {
                let lineData = Data(String(line).utf8)
                let object = try JSONSerialization.jsonObject(with: lineData)
                guard let dictionary = object as? [String: Any] else {
                    throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                        path: descriptor.relativePath,
                        reason: "expected JSON object per line"
                    )
                }
                try requireFields(descriptor.requiredFields, in: dictionary, path: descriptor.relativePath)
            }
        }
    }

    private func requireFields(
        _ fields: [String],
        in dictionary: [String: Any],
        path: String
    ) throws {
        let missingFields = fields.filter { dictionary[$0] == nil }
        guard missingFields.isEmpty else {
            throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                path: path,
                reason: "missing required fields \(missingFields.joined(separator: ","))"
            )
        }
    }

    private struct ResolvedArtifact {
        let provenance: ReleaseV0130LocalEvidenceArtifactProvenance
        let data: Data
    }

    private func ensureRegistryEntry(
        assessmentID: Identifier,
        store: ReadinessAssessmentRegistryStore,
        createdAt: Date
    ) throws -> (ReadinessAssessmentRegistryEntry, ReadinessAssessmentRegistryDocument, Bool) {
        do {
            let document = try store.load()
            return (try document.inspect(assessmentID: assessmentID), document, false)
        } catch let error as ReadinessAssessmentRegistryStoreError {
            switch error {
            case .missingRegistry, .missingAssessmentID:
                let document = try store.create(
                    assessmentID: assessmentID,
                    state: .ready,
                    sourceReleaseVersion: "v0.13.0",
                    sourcePatchVersion: "v0.12.1",
                    assessedBy: "Codex",
                    reason: "GH-997 deterministic local evidence build pipeline",
                    createdAt: createdAt,
                    updatedAt: createdAt
                )
                return (try document.inspect(assessmentID: assessmentID), document, true)
            default:
                throw error
            }
        }
    }

    private func artifactProvenances(
        from artifactIndex: [String: Any],
        under root: URL
    ) throws -> [ResolvedArtifact] {
        guard let artifacts = artifactIndex["artifacts"] as? [[String: Any]],
              artifacts.isEmpty == false else {
            throw ReleaseV0130LocalEvidenceProvenanceError.missingField("artifacts")
        }

        return try artifacts.enumerated().map { index, artifact in
            guard let artifactID = Self.stringField(["id", "artifactID"], in: artifact),
                  artifactID.isEmpty == false else {
                throw ReleaseV0130LocalEvidenceProvenanceError.missingField("artifacts[\(index)].id")
            }
            guard let relativePath = Self.stringField(["path", "relativePath"], in: artifact),
                  relativePath.isEmpty == false else {
                throw ReleaseV0130LocalEvidenceProvenanceError.missingField("artifacts[\(index)].path")
            }
            guard ProductionReadinessArtifactDescriptor.isSafeRelativePath(relativePath) else {
                throw ReleaseV0130LocalEvidenceProvenanceError.unsafeArtifactPath(relativePath)
            }

            let artifactURL = url(for: relativePath, under: root)
            guard fileManager.fileExists(atPath: artifactURL.path) else {
                throw ReleaseV0130LocalEvidenceProvenanceError.missingArtifact(relativePath)
            }
            let data = try Data(contentsOf: artifactURL)
            guard data.isEmpty == false else {
                throw ReleaseV0130LocalEvidenceProvenanceError.missingArtifact(relativePath)
            }
            let sha256 = Self.sha256Hex(data)
            let byteCount = data.count

            if let expectedSHA256 = Self.stringField(["sha256", "artifactSHA256", "checksum"], in: artifact),
               expectedSHA256 != sha256 {
                throw ReleaseV0130LocalEvidenceProvenanceError.artifactMetadataMismatch(relativePath)
            }
            if let expectedBytes = Self.intField(["bytes", "artifactBytes", "byteCount"], in: artifact),
               expectedBytes != byteCount {
                throw ReleaseV0130LocalEvidenceProvenanceError.artifactMetadataMismatch(relativePath)
            }

            return try ResolvedArtifact(
                provenance: ReleaseV0130LocalEvidenceArtifactProvenance(
                    artifactID: try Identifier(artifactID),
                    relativePath: relativePath,
                    sha256: sha256,
                    byteCount: byteCount
                ),
                data: data
            )
        }
    }

    private func jsonObject(relativePath: String, under root: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url(for: relativePath, under: root))
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = object as? [String: Any] else {
            throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                path: relativePath,
                reason: "expected JSON object"
            )
        }
        return dictionary
    }

    private func jsonLines(relativePath: String, under root: URL) throws -> [[String: Any]] {
        let data = try Data(contentsOf: url(for: relativePath, under: root))
        guard let string = String(data: data, encoding: .utf8) else {
            throw ReleaseV0130LocalEvidenceIntakeError.malformedJSON(relativePath)
        }
        let lines = string.split(whereSeparator: \.isNewline)
        guard lines.isEmpty == false else {
            throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                path: relativePath,
                reason: "expected at least one JSON line"
            )
        }
        return try lines.map { line in
            let object = try JSONSerialization.jsonObject(with: Data(String(line).utf8))
            guard let dictionary = object as? [String: Any] else {
                throw ReleaseV0130LocalEvidenceIntakeError.schemaViolation(
                    path: relativePath,
                    reason: "expected JSON object per line"
                )
            }
            return dictionary
        }
    }

    private func isDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    private func url(for relativePath: String, under root: URL) -> URL {
        relativePath.split(separator: "/").reduce(root) { partialURL, component in
            partialURL.appendingPathComponent(String(component))
        }
    }

    private static func normalized(_ value: String) -> String {
        value
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .lowercased()
    }

    private static func sourceCommitValues(from object: Any) -> [String] {
        stringValues(forKeys: ["sourceCommit"], in: object)
    }

    private static func sourceRunIDValues(from object: Any) -> [String] {
        stringValues(forKeys: ["sourceRunID", "sourceRunIDs"], in: object)
    }

    private static func stringValues(forKeys keys: Set<String>, in object: Any) -> [String] {
        if let dictionary = object as? [String: Any] {
            var values: [String] = []
            for (key, value) in dictionary {
                if keys.contains(key) {
                    if let string = value as? String {
                        values.append(string)
                    } else if let strings = value as? [String] {
                        values.append(contentsOf: strings)
                    }
                }
                values.append(contentsOf: stringValues(forKeys: keys, in: value))
            }
            return values
        }
        if let array = object as? [Any] {
            return array.flatMap { stringValues(forKeys: keys, in: $0) }
        }
        return []
    }

    private static func containsFixtureOnlyMarker(_ object: Any) -> Bool {
        if let dictionary = object as? [String: Any] {
            if let fixtureOnly = dictionary["fixtureOnly"] as? Bool, fixtureOnly {
                return true
            }
            if let testFixtureOnly = dictionary["testFixtureOnly"] as? Bool, testFixtureOnly {
                return true
            }
            for key in ["evidenceClassification", "evidenceKind", "fixtureClassification"] {
                if let value = dictionary[key] as? String,
                   value.lowercased().contains("fixture") {
                    return true
                }
            }
            return dictionary.values.contains(where: containsFixtureOnlyMarker)
        }
        if let array = object as? [Any] {
            return array.contains(where: containsFixtureOnlyMarker)
        }
        return false
    }

    private static func stringField(_ names: [String], in dictionary: [String: Any]) -> String? {
        for name in names {
            if let value = dictionary[name] as? String {
                return value
            }
        }
        return nil
    }

    private static func intField(_ names: [String], in dictionary: [String: Any]) -> Int? {
        for name in names {
            if let value = dictionary[name] as? Int {
                return value
            }
            if let number = dictionary[name] as? NSNumber {
                return number.intValue
            }
        }
        return nil
    }

    private static func topLevelJSONFields(in data: Data) throws -> [String] {
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = object as? [String: Any] else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("buildPipeline:artifactJSONTopLevelObject")
        }
        let fields = dictionary.keys.sorted()
        guard fields.isEmpty == false else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("buildPipeline:artifactJSONTopLevelFields")
        }
        return fields
    }

    private static func bundleArtifactPath(
        assessmentID: Identifier,
        generationID: Identifier,
        artifactID: Identifier
    ) -> String {
        ".local/mtpro/readiness/assessments/\(assessmentID.rawValue)/generations/\(generationID.rawValue)/artifacts/\(artifactID.rawValue).json"
    }

    private static func writeBundleArtifactSnapshot(
        _ data: Data,
        relativePath: String,
        store: ReadinessAssessmentRegistryStore
    ) throws {
        let url = storeURL(for: relativePath, store: store, isDirectory: false).standardizedFileURL
        let rootPath = store.storageRootURL.standardizedFileURL.path
        guard url.path.hasPrefix(rootPath + "/") else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("buildPipeline:unsafeBundleArtifactPath")
        }

        if store.fileManager.fileExists(atPath: url.path) {
            let existing = try Data(contentsOf: url)
            guard existing == data else {
                throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift("buildPipeline:bundleArtifactSnapshotImmutable")
            }
            return
        }

        let parentURL = url.deletingLastPathComponent()
        try store.fileManager.createDirectory(
            at: parentURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyDirectoryPermissions]
        )
        try data.write(to: url, options: .atomic)
        try store.fileManager.setAttributes(
            [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyFilePermissions],
            ofItemAtPath: url.path
        )
    }

    private static func writeExportFile(
        fileName: String,
        data: Data,
        sourceRelativePath: String?,
        sourceSHA256: String?,
        exportDirectoryURL: URL,
        exportDirectoryPath: String,
        store: ReadinessAssessmentRegistryStore
    ) throws -> ReleaseV0130RedactedAuditExportFile {
        let exportRelativePath = "\(exportDirectoryPath)/\(fileName)"
        let url = exportDirectoryURL.appendingPathComponent(fileName, isDirectory: false)
        try writeData(data, to: url, store: store)
        let writtenData = try Data(contentsOf: url)
        let exportSHA256 = sha256Hex(writtenData)
        return try ReleaseV0130RedactedAuditExportFile(
            fileName: fileName,
            exportRelativePath: exportRelativePath,
            sourceRelativePath: sourceRelativePath,
            sourceSHA256: sourceSHA256,
            exportSHA256: exportSHA256,
            byteCount: writtenData.count,
            checksumMatchesSource: sourceSHA256.map { $0 == exportSHA256 } ?? true
        )
    }

    private static func replaceDirectory(
        _ directoryURL: URL,
        store: ReadinessAssessmentRegistryStore
    ) throws {
        let rootPath = store.storageRootURL.standardizedFileURL.path
        let standardizedURL = directoryURL.standardizedFileURL
        guard standardizedURL.path.hasPrefix(rootPath + "/") else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "redactedAuditExport:unsafeExportDirectory"
            )
        }
        if store.fileManager.fileExists(atPath: standardizedURL.path) {
            try store.fileManager.removeItem(at: standardizedURL)
        }
        try store.fileManager.createDirectory(
            at: standardizedURL,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyDirectoryPermissions]
        )
        try store.fileManager.setAttributes(
            [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyDirectoryPermissions],
            ofItemAtPath: standardizedURL.path
        )
    }

    private static func writeStoreData(
        _ data: Data,
        relativePath: String,
        store: ReadinessAssessmentRegistryStore,
        isDirectory: Bool
    ) throws {
        let url = storeURL(for: relativePath, store: store, isDirectory: isDirectory)
        try writeData(data, to: url, store: store)
    }

    private static func writeData(
        _ data: Data,
        to url: URL,
        store: ReadinessAssessmentRegistryStore
    ) throws {
        let rootPath = store.storageRootURL.standardizedFileURL.path
        let standardizedURL = url.standardizedFileURL
        guard standardizedURL.path.hasPrefix(rootPath + "/") else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "redactedAuditExport:unsafeWritePath"
            )
        }
        try store.fileManager.createDirectory(
            at: standardizedURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyDirectoryPermissions]
        )
        try data.write(to: standardizedURL, options: .atomic)
        try store.fileManager.setAttributes(
            [.posixPermissions: ReadinessAssessmentRegistryStore.ownerOnlyFilePermissions],
            ofItemAtPath: standardizedURL.path
        )
    }

    private static func canonicalExportJSONData(_ object: [String: Any]) throws -> Data {
        guard JSONSerialization.isValidJSONObject(object) else {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "redactedAuditExport:invalidJSON"
            )
        }
        do {
            return try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys, .withoutEscapingSlashes]
            )
        } catch {
            throw ReleaseV0130LocalEvidenceProvenanceError.boundaryDrift(
                "redactedAuditExport:invalidJSON"
            )
        }
    }

    private static func bundleJSONURL(
        assessmentID: Identifier,
        generationID: Identifier,
        store: ReadinessAssessmentRegistryStore
    ) -> URL {
        store.storageRootURL
            .appendingPathComponent("assessments", isDirectory: true)
            .appendingPathComponent(assessmentID.rawValue, isDirectory: true)
            .appendingPathComponent("generations", isDirectory: true)
            .appendingPathComponent(generationID.rawValue, isDirectory: true)
            .appendingPathComponent("readiness-bundle-v2.json", isDirectory: false)
    }

    private static func capture<T>(
        _ reason: String,
        into failureReasons: inout [String],
        operation: () throws -> T?
    ) -> T? {
        do {
            guard let result = try operation() else {
                failureReasons.append(reason)
                return nil
            }
            return result
        } catch {
            failureReasons.append(reason)
            return nil
        }
    }

    private static func optionalJSONAssessmentIdentityMatches(
        relativePath: String?,
        assessmentID: Identifier,
        store: ReadinessAssessmentRegistryStore
    ) -> Bool {
        guard let relativePath else {
            return true
        }
        let url = storeURL(for: relativePath, store: store, isDirectory: false)
        guard store.fileManager.fileExists(atPath: url.path) else {
            return true
        }
        do {
            let data = try Data(contentsOf: url)
            let object = try JSONSerialization.jsonObject(with: data)
            return Self.containsAssessmentID(assessmentID.rawValue, in: object)
        } catch {
            return false
        }
    }

    private static func optionalExportDirectoryIdentityMatches(
        relativePath: String?,
        assessmentID: Identifier,
        store: ReadinessAssessmentRegistryStore
    ) -> Bool {
        guard let relativePath else {
            return true
        }
        let directoryURL = storeURL(for: relativePath, store: store, isDirectory: true)
        var isDirectory: ObjCBool = false
        guard store.fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return true
        }
        do {
            let urls = try store.fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: nil
            ).filter { $0.pathExtension == "json" }
            return try urls.allSatisfy { url in
                let data = try Data(contentsOf: url)
                let object = try JSONSerialization.jsonObject(with: data)
                return Self.containsAssessmentID(assessmentID.rawValue, in: object)
            }
        } catch {
            return false
        }
    }

    private static func containsAssessmentID(_ assessmentID: String, in object: Any) -> Bool {
        if let dictionary = object as? [String: Any] {
            if dictionary["assessmentID"] as? String == assessmentID {
                return true
            }
            return dictionary.values.contains { containsAssessmentID(assessmentID, in: $0) }
        }
        if let array = object as? [Any] {
            return array.contains { containsAssessmentID(assessmentID, in: $0) }
        }
        return false
    }

    private static func artifactSnapshotBytesMatch(
        _ snapshot: ReadinessAssessmentBundleV2ArtifactSnapshot,
        store: ReadinessAssessmentRegistryStore
    ) -> Bool {
        let url = storeURL(for: snapshot.artifactPath, store: store, isDirectory: false)
        guard store.fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else {
            return false
        }
        return sha256Hex(data) == snapshot.artifactSHA256
            && data.isEmpty == false
    }

    private static func storeURL(
        for relativePath: String,
        store: ReadinessAssessmentRegistryStore,
        isDirectory: Bool
    ) -> URL {
        let normalizedPath = relativePath.replacingOccurrences(
            of: "\(ReadinessAssessmentRegistryStore.defaultRelativeRoot)/",
            with: ""
        )
        return store.storageRootURL.appendingPathComponent(normalizedPath, isDirectory: isDirectory)
    }

    private static func sha256Hex(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }

    private static var exportEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
