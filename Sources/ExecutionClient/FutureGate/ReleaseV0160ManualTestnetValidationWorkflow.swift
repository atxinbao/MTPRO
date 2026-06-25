import Crypto
import DomainModel
import Foundation

// GH-1111 static contract boundary:
// manualTestnetValidationWorkflow=ReleaseV0160ManualTestnetValidationWorkflow
// manualWorkflowOnly=true
// submitStatusCancelStatusReconciliationSequence=true
// redactedEvidenceBundleRequired=true
// checksumReferencesRequired=true
// githubWorkflowDispatchOnly=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false
// productionCutoverAuthorized=false

/// ReleaseV0160ManualTestnetValidationWorkflowError 描述 #1111 manual workflow 的 fail-closed 错误。
///
/// 这些错误只覆盖 Binance Spot Testnet operator beta 的手动验证证据。该 workflow 不读取
/// credential value，不连接 endpoint，不发送订单，也不授权 production cutover。
public enum ReleaseV0160ManualTestnetValidationWorkflowError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyEvidence(String)
    case invalidSequence(expected: [ReleaseV0160ManualTestnetValidationStep], actual: [ReleaseV0160ManualTestnetValidationStep])
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case let .emptyEvidence(field):
            "Release v0.16.0 manual testnet validation workflow requires non-empty evidence: \(field)"
        case let .invalidSequence(expected, actual):
            "Release v0.16.0 manual testnet validation workflow invalid sequence: expected \(expected.map(\.rawValue).joined(separator: " -> ")), actual \(actual.map(\.rawValue).joined(separator: " -> "))"
        case let .boundaryDrift(field):
            "Release v0.16.0 manual testnet validation workflow boundary drift: \(field)"
        }
    }
}

/// ReleaseV0160ManualTestnetValidationStep 固定 #1111 的 operator 手动验证顺序。
public enum ReleaseV0160ManualTestnetValidationStep: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case statusAfterSubmit = "status-after-submit"
    case cancel
    case statusAfterCancel = "status-after-cancel"
    case reconciliationPassed = "reconciliation-passed"

    public static let requiredSequence: [ReleaseV0160ManualTestnetValidationStep] = [
        .submit,
        .statusAfterSubmit,
        .cancel,
        .statusAfterCancel,
        .reconciliationPassed
    ]
}

/// ReleaseV0160ManualTestnetValidationEvidenceEntry 是 redacted bundle 的单步 evidence。
///
/// Entry 只保存 artifact record id、checksum reference 和 redacted artifact path。它拒绝 raw
/// credential、raw order identity、raw broker payload 和 production endpoint marker。
public struct ReleaseV0160ManualTestnetValidationEvidenceEntry: Codable, Equatable, Sendable {
    public let entryID: Identifier
    public let step: ReleaseV0160ManualTestnetValidationStep
    public let artifactRecordID: Identifier
    public let artifactChecksum: String
    public let checksumReference: String
    public let redactedArtifactPath: String
    public let operatorNoteRedacted: Bool
    public let containsCredentialValue: Bool
    public let containsRawOrderIdentity: Bool
    public let containsRawBrokerPayload: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        step: ReleaseV0160ManualTestnetValidationStep,
        artifactRecordID: Identifier,
        artifactChecksum: String,
        redactedArtifactPath: String,
        checksumReference: String? = nil,
        operatorNoteRedacted: Bool = true,
        containsCredentialValue: Bool = false,
        containsRawOrderIdentity: Bool = false,
        containsRawBrokerPayload: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard artifactRecordID.rawValue.isEmpty == false else {
            throw ReleaseV0160ManualTestnetValidationWorkflowError.emptyEvidence("artifactRecordID")
        }
        guard redactedArtifactPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV0160ManualTestnetValidationWorkflowError.emptyEvidence("redactedArtifactPath")
        }
        guard ReleaseV0160LocalExecutionArtifactRecord.isSHA256(artifactChecksum) else {
            throw ReleaseV0160ManualTestnetValidationWorkflowError.boundaryDrift("artifactChecksum")
        }

        let normalizedPath = redactedArtifactPath.trimmingCharacters(in: .whitespacesAndNewlines)
        let reference = checksumReference ?? "\(normalizedPath)#\(artifactChecksum)"
        self.entryID = Self.deterministicID(step: step, artifactRecordID: artifactRecordID, artifactChecksum: artifactChecksum)
        self.step = step
        self.artifactRecordID = artifactRecordID
        self.artifactChecksum = artifactChecksum
        self.checksumReference = reference
        self.redactedArtifactPath = normalizedPath
        self.operatorNoteRedacted = operatorNoteRedacted
        self.containsCredentialValue = containsCredentialValue
        self.containsRawOrderIdentity = containsRawOrderIdentity
        self.containsRawBrokerPayload = containsRawBrokerPayload
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard entryHeld else {
            throw ReleaseV0160ManualTestnetValidationWorkflowError.boundaryDrift("evidenceEntry.\(step.rawValue)")
        }
    }

    public var entryHeld: Bool {
        entryID == Self.deterministicID(step: step, artifactRecordID: artifactRecordID, artifactChecksum: artifactChecksum)
            && artifactRecordID.rawValue.isEmpty == false
            && ReleaseV0160LocalExecutionArtifactRecord.isSHA256(artifactChecksum)
            && checksumReference.contains(artifactChecksum)
            && redactedArtifactPath.hasPrefix(".local/mtpro/v0.16.0/operator-runs/")
            && redactedArtifactPath.contains("redacted")
            && ReleaseV0160LocalExecutionArtifactPayload.forbiddenRawMarkers(in: redactedArtifactPath).isEmpty
            && ReleaseV0160LocalExecutionArtifactPayload.forbiddenRawMarkers(in: checksumReference).isEmpty
            && operatorNoteRedacted
            && containsCredentialValue == false
            && containsRawOrderIdentity == false
            && containsRawBrokerPayload == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public static func deterministicID(
        step: ReleaseV0160ManualTestnetValidationStep,
        artifactRecordID: Identifier,
        artifactChecksum: String
    ) -> Identifier {
        Identifier.constant(
            "gh-1111-v0160-manual-validation-entry:\(step.rawValue):\(artifactRecordID.rawValue):\(artifactChecksum)",
            field: "releaseV0160ManualTestnetValidationWorkflow.entryID"
        )
    }
}

/// ReleaseV0160ManualTestnetValidationReport 汇总手动 testnet validation bundle。
///
/// Report 证明 operator 已按 submit -> status -> cancel -> status -> reconciliation passed 顺序
/// 产出脱敏 artifact，并且每一步都有 checksum reference。该 report 本身只是本地证据模型，
/// 不触发 network、secret read、broker command 或 production cutover。
public struct ReleaseV0160ManualTestnetValidationReport: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let reportID: Identifier
    public let runID: Identifier
    public let githubWorkflowPath: String
    public let requiredActionSequence: [ReleaseV0160ManualTestnetValidationStep]
    public let evidenceEntries: [ReleaseV0160ManualTestnetValidationEvidenceEntry]
    public let checksumReferences: [String]
    public let submitStatusCancelStatusReconciliationPassed: Bool
    public let manualWorkflowOnly: Bool
    public let githubWorkflowDispatchOnly: Bool
    public let automaticScheduleDisabled: Bool
    public let productionSecretsBlockedInWorkflow: Bool
    public let testnetCredentialProfileRequired: Bool
    public let explicitOperatorConfirmationRequired: Bool
    public let redactedEvidenceBundleRequired: Bool
    public let redactedEvidenceOnly: Bool
    public let containsCredentialValue: Bool
    public let containsRawOrderIdentity: Bool
    public let containsRawBrokerPayload: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        runID: Identifier,
        evidenceEntries: [ReleaseV0160ManualTestnetValidationEvidenceEntry],
        githubWorkflowPath: String = ".github/workflows/release-v0.16.0-manual-testnet-validation.yml",
        requiredActionSequence: [ReleaseV0160ManualTestnetValidationStep] = ReleaseV0160ManualTestnetValidationStep.requiredSequence,
        submitStatusCancelStatusReconciliationPassed: Bool = true,
        manualWorkflowOnly: Bool = true,
        githubWorkflowDispatchOnly: Bool = true,
        automaticScheduleDisabled: Bool = true,
        productionSecretsBlockedInWorkflow: Bool = true,
        testnetCredentialProfileRequired: Bool = true,
        explicitOperatorConfirmationRequired: Bool = true,
        redactedEvidenceBundleRequired: Bool = true,
        redactedEvidenceOnly: Bool = true,
        containsCredentialValue: Bool = false,
        containsRawOrderIdentity: Bool = false,
        containsRawBrokerPayload: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard runID.rawValue.isEmpty == false else {
            throw ReleaseV0160ManualTestnetValidationWorkflowError.emptyEvidence("runID")
        }
        guard githubWorkflowPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV0160ManualTestnetValidationWorkflowError.emptyEvidence("githubWorkflowPath")
        }
        let actualSequence = evidenceEntries.map(\.step)
        guard actualSequence == requiredActionSequence else {
            throw ReleaseV0160ManualTestnetValidationWorkflowError.invalidSequence(
                expected: requiredActionSequence,
                actual: actualSequence
            )
        }

        self.issueID = Identifier.constant("GH-1111")
        self.upstreamIssueIDs = [Identifier.constant("GH-1110")]
        self.releaseVersion = "v0.16.0"
        self.runID = runID
        self.githubWorkflowPath = githubWorkflowPath
        self.requiredActionSequence = requiredActionSequence
        self.evidenceEntries = evidenceEntries
        self.checksumReferences = evidenceEntries.map(\.checksumReference)
        self.submitStatusCancelStatusReconciliationPassed = submitStatusCancelStatusReconciliationPassed
        self.manualWorkflowOnly = manualWorkflowOnly
        self.githubWorkflowDispatchOnly = githubWorkflowDispatchOnly
        self.automaticScheduleDisabled = automaticScheduleDisabled
        self.productionSecretsBlockedInWorkflow = productionSecretsBlockedInWorkflow
        self.testnetCredentialProfileRequired = testnetCredentialProfileRequired
        self.explicitOperatorConfirmationRequired = explicitOperatorConfirmationRequired
        self.redactedEvidenceBundleRequired = redactedEvidenceBundleRequired
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.containsCredentialValue = containsCredentialValue
        self.containsRawOrderIdentity = containsRawOrderIdentity
        self.containsRawBrokerPayload = containsRawBrokerPayload
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
        self.reportID = Self.deterministicID(runID: runID, checksumReferences: evidenceEntries.map(\.checksumReference))

        guard reportHeld else {
            throw ReleaseV0160ManualTestnetValidationWorkflowError.boundaryDrift("manualTestnetValidationReport")
        }
    }

    public var reportHeld: Bool {
        issueID == .constant("GH-1111")
            && upstreamIssueIDs == [.constant("GH-1110")]
            && releaseVersion == "v0.16.0"
            && reportID == Self.deterministicID(runID: runID, checksumReferences: checksumReferences)
            && runID.rawValue.isEmpty == false
            && githubWorkflowPath == ".github/workflows/release-v0.16.0-manual-testnet-validation.yml"
            && requiredActionSequence == ReleaseV0160ManualTestnetValidationStep.requiredSequence
            && evidenceEntries.map(\.step) == ReleaseV0160ManualTestnetValidationStep.requiredSequence
            && evidenceEntries.allSatisfy(\.entryHeld)
            && checksumReferences == evidenceEntries.map(\.checksumReference)
            && checksumReferences.count == ReleaseV0160ManualTestnetValidationStep.requiredSequence.count
            && submitStatusCancelStatusReconciliationPassed
            && manualWorkflowOnly
            && githubWorkflowDispatchOnly
            && automaticScheduleDisabled
            && productionSecretsBlockedInWorkflow
            && testnetCredentialProfileRequired
            && explicitOperatorConfirmationRequired
            && redactedEvidenceBundleRequired
            && redactedEvidenceOnly
            && containsCredentialValue == false
            && containsRawOrderIdentity == false
            && containsRawBrokerPayload == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var redactedBundleSummaryLines: [String] {
        [
            "issue=GH-1111",
            "release=v0.16.0",
            "runID=\(runID.rawValue)",
            "manualWorkflowOnly=\(manualWorkflowOnly)",
            "githubWorkflowDispatchOnly=\(githubWorkflowDispatchOnly)",
            "sequence=\(requiredActionSequence.map(\.rawValue).joined(separator: " -> "))",
            "checksumReferences=\(checksumReferences.joined(separator: ","))",
            "redactedEvidenceOnly=\(redactedEvidenceOnly)",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionSecretAutoRead=\(productionSecretAutoRead)",
            "productionEndpointConnected=\(productionEndpointConnected)",
            "brokerEndpointConnected=\(brokerEndpointConnected)",
            "productionOrderSubmitted=\(productionOrderSubmitted)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)"
        ]
    }

    public static let requiredValidationAnchors = [
        "GH-1111-VERIFY-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW",
        "TVM-RELEASE-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW",
        "V0160-011-MANUAL-WORKFLOW-ONLY",
        "V0160-011-SUBMIT-STATUS-CANCEL-STATUS-SEQUENCE",
        "V0160-011-RECONCILIATION-PASSED",
        "V0160-011-REDACTED-EVIDENCE-BUNDLE",
        "V0160-011-CHECKSUM-REFERENCES",
        "V0160-011-NO-PRODUCTION-CREDENTIALS",
        "V0160-011-NO-PRODUCTION-ENDPOINT",
        "V0160-011-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1111ReleaseV0160ManualTestnetValidationWorkflowRequiresRedactedBundle",
        "bash checks/verify-v0.16.0-manual-testnet-validation-workflow.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicID(runID: Identifier, checksumReferences: [String]) -> Identifier {
        Identifier.constant(
            "gh-1111-v0160-manual-validation-report:\(runID.rawValue):\(checksumReferences.joined(separator: ","))",
            field: "releaseV0160ManualTestnetValidationWorkflow.reportID"
        )
    }
}

/// ReleaseV0160ManualTestnetValidationWorkflow 是 #1111 的本地验证入口。
public enum ReleaseV0160ManualTestnetValidationWorkflow {
    @discardableResult
    public static func validate(
        report: ReleaseV0160ManualTestnetValidationReport
    ) throws -> ReleaseV0160ManualTestnetValidationReport {
        guard report.reportHeld else {
            throw ReleaseV0160ManualTestnetValidationWorkflowError.boundaryDrift("report")
        }
        return report
    }

    public static func fixture(runID: Identifier = .constant("gh-1111-v0160-manual-testnet-validation-run")) throws -> ReleaseV0160ManualTestnetValidationReport {
        let entries = try ReleaseV0160ManualTestnetValidationStep.requiredSequence.enumerated().map { index, step in
            let checksum = releaseV0160ManualWorkflowSHA256([
                "GH-1111",
                "v0.16.0",
                runID.rawValue,
                step.rawValue,
                String(index + 1),
                "redactedEvidenceOnly=true",
                "productionCutoverAuthorized=false"
            ])
            return try ReleaseV0160ManualTestnetValidationEvidenceEntry(
                step: step,
                artifactRecordID: .constant("gh-1111-\(step.rawValue)-record-\(index + 1)"),
                artifactChecksum: checksum,
                redactedArtifactPath: ".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/evidence/\(index + 1)-\(step.rawValue)-redacted.json"
            )
        }
        return try ReleaseV0160ManualTestnetValidationReport(runID: runID, evidenceEntries: entries)
    }
}

private func releaseV0160ManualWorkflowSHA256(_ parts: [String]) -> String {
    let data = Data(parts.joined(separator: "|").utf8)
    let digest = SHA256.hash(data: data)
    return "sha256:" + digest.map { String(format: "%02x", $0) }.joined()
}
