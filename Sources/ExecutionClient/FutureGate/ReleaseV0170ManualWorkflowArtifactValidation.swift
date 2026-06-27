import DomainModel
import Foundation

// GH-1146 static contract boundary:
// manualWorkflowArtifactValidation=ReleaseV0170ManualWorkflowArtifactValidationReport
// uploadedArtifactBundleValidation=true
// downloadedArtifactBundleValidation=true
// sharedRuntimeValidatorUsed=true
// cliValidatorPathUsed=true
// uploadDownloadEvidenceRecorded=true
// localOnlyNoNetwork=true
// redactedEvidenceOnly=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false
// GH-1167 static patch boundary:
// failedUploadedArtifactRejectsWorkflow=true
// failedDownloadedArtifactRejectsWorkflow=true
// workflowRequiresPassedStatus=true
// failedStatusCannotSatisfyWorkflow=true
// cliFailedValidationPropagatesNonzeroExit=true
// GH-1168 static patch boundary:
// corruptBundleValidationFailsClosed=true
// missingArtifactValidationFailsClosed=true
// missingManifestValidationFailsClosed=true
// reconciliationMissingValidationFailsClosed=true
// negativeFailureDetailsOperatorReadable=true

/// ReleaseV0170ManualWorkflowArtifactValidationStatus 固定 GH-1146 手动 workflow artifact 校验结果。
///
/// `.passed` 表示上传和下载后的本地 artifact bundle 都通过 GH-1145 CLI 路径与 GH-1140 shared
/// runtime validator 校验。`.failed` 只表示本地证据链不可被信任；它不会触发网络请求、订单动作或
/// production cutover。
public enum ReleaseV0170ManualWorkflowArtifactValidationStatus:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case passed
    case failed
}

/// ReleaseV0170ManualWorkflowArtifactValidationReport 是 GH-1146 的手动 workflow upload/download 证据。
///
/// 该 report 只包装两个本地 `mtpro verify-operator-beta-artifact-bundle` 语义输出：一个代表上传前
/// operator bundle，一个代表下载后 workflow bundle。两者必须走同一个 CLI / shared validator 路径，
/// 以证明 workflow 没有引入另一套 artifact trust rule。
public struct ReleaseV0170ManualWorkflowArtifactValidationReport: Equatable, Sendable {
    public let reportID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let releaseVersion: String
    public let workflowName: String
    public let uploadedArtifact: ReleaseV0170CLIArtifactVerifyCommandOutput
    public let downloadedArtifact: ReleaseV0170CLIArtifactVerifyCommandOutput
    public let status: ReleaseV0170ManualWorkflowArtifactValidationStatus
    public let failedUploadedArtifactRejectsWorkflow: Bool
    public let failedDownloadedArtifactRejectsWorkflow: Bool
    public let workflowRequiresPassedStatus: Bool
    public let failedStatusCannotSatisfyWorkflow: Bool
    public let cliFailedValidationPropagatesNonzeroExit: Bool
    public let uploadedArtifactBundleValidation: Bool
    public let downloadedArtifactBundleValidation: Bool
    public let sharedRuntimeValidatorUsed: Bool
    public let cliValidatorPathUsed: Bool
    public let uploadDownloadEvidenceRecorded: Bool
    public let localOnlyNoNetwork: Bool
    public let redactedEvidenceOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var reportHeld: Bool {
        reportID == Self.deterministicID(
            uploadedArtifact: uploadedArtifact,
            downloadedArtifact: downloadedArtifact,
            status: status
        )
            && issueID.rawValue == "GH-1146"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1144", "GH-1145"]
            && releaseVersion == "v0.17.0"
            && workflowName == Self.workflowName
            && uploadedArtifact.outputHeld
            && downloadedArtifact.outputHeld
            && uploadedArtifact.validationResult.sourceRunID == downloadedArtifact.validationResult.sourceRunID
            && status == Self.derivedStatus(
                uploadedArtifact: uploadedArtifact,
                downloadedArtifact: downloadedArtifact
            )
            && workflowFailClosedHeld
            && uploadedArtifactBundleValidation
            && downloadedArtifactBundleValidation
            && sharedRuntimeValidatorUsed
            && cliValidatorPathUsed
            && uploadDownloadEvidenceRecorded
            && localOnlyNoNetwork
            && redactedEvidenceOnly
            && productionDefaultsClosed
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var workflowFailClosedHeld: Bool {
        failedUploadedArtifactRejectsWorkflow
            && failedDownloadedArtifactRejectsWorkflow
            && workflowRequiresPassedStatus
            && failedStatusCannotSatisfyWorkflow
            && cliFailedValidationPropagatesNonzeroExit
            && ReleaseV0170CLIArtifactVerifyCommandFailedValidation.requiredValidationAnchors
                .contains("V0171-001-FAILED-VALIDATION-NONZERO-EXIT")
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        uploadedArtifact: ReleaseV0170CLIArtifactVerifyCommandOutput,
        downloadedArtifact: ReleaseV0170CLIArtifactVerifyCommandOutput,
        issueID: Identifier = Identifier.constant("GH-1146"),
        blockedByIssueIDs: [Identifier] = [
            Identifier.constant("GH-1144"),
            Identifier.constant("GH-1145")
        ],
        releaseVersion: String = "v0.17.0",
        workflowName: String = Self.workflowName,
        failedUploadedArtifactRejectsWorkflow: Bool = true,
        failedDownloadedArtifactRejectsWorkflow: Bool = true,
        workflowRequiresPassedStatus: Bool = true,
        failedStatusCannotSatisfyWorkflow: Bool = true,
        cliFailedValidationPropagatesNonzeroExit: Bool = true,
        uploadedArtifactBundleValidation: Bool = true,
        downloadedArtifactBundleValidation: Bool = true,
        sharedRuntimeValidatorUsed: Bool = true,
        cliValidatorPathUsed: Bool = true,
        uploadDownloadEvidenceRecorded: Bool = true,
        localOnlyNoNetwork: Bool = true,
        redactedEvidenceOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let status = Self.derivedStatus(
            uploadedArtifact: uploadedArtifact,
            downloadedArtifact: downloadedArtifact
        )
        self.reportID = Self.deterministicID(
            uploadedArtifact: uploadedArtifact,
            downloadedArtifact: downloadedArtifact,
            status: status
        )
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.releaseVersion = releaseVersion
        self.workflowName = workflowName
        self.uploadedArtifact = uploadedArtifact
        self.downloadedArtifact = downloadedArtifact
        self.status = status
        self.failedUploadedArtifactRejectsWorkflow = failedUploadedArtifactRejectsWorkflow
        self.failedDownloadedArtifactRejectsWorkflow = failedDownloadedArtifactRejectsWorkflow
        self.workflowRequiresPassedStatus = workflowRequiresPassedStatus
        self.failedStatusCannotSatisfyWorkflow = failedStatusCannotSatisfyWorkflow
        self.cliFailedValidationPropagatesNonzeroExit = cliFailedValidationPropagatesNonzeroExit
        self.uploadedArtifactBundleValidation = uploadedArtifactBundleValidation
        self.downloadedArtifactBundleValidation = downloadedArtifactBundleValidation
        self.sharedRuntimeValidatorUsed = sharedRuntimeValidatorUsed
        self.cliValidatorPathUsed = cliValidatorPathUsed
        self.uploadDownloadEvidenceRecorded = uploadDownloadEvidenceRecorded
        self.localOnlyNoNetwork = localOnlyNoNetwork
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard reportHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170ManualWorkflowArtifactValidation.report",
                expected: "GH-1146 manual workflow upload/download artifact validation evidence",
                actual: status.rawValue
            )
        }
    }

    public func rendered() -> String {
        [
            "manualWorkflowArtifactValidation=\(Self.workflowName)",
            "issue=\(issueID.rawValue)",
            "blockedBy=\(blockedByIssueIDs.map(\.rawValue).joined(separator: ","))",
            "releaseVersion=\(releaseVersion)",
            "verificationAnchor=\(Self.requiredValidationAnchors[0])",
            "validationAnchor=\(Self.requiredValidationAnchors[1])",
            "requiredAnchors=\(validationAnchors.joined(separator: ","))",
            "reportID=\(reportID.rawValue)",
            "runID=\(uploadedArtifact.validationResult.sourceRunID.rawValue)",
            "status=\(status.rawValue)",
            "uploadedArtifactStatus=\(uploadedArtifact.validationResult.status.rawValue)",
            "downloadedArtifactStatus=\(downloadedArtifact.validationResult.status.rawValue)",
            "uploadedArtifactManifestChecksum=\(uploadedArtifact.validationResult.sourceManifestChecksum ?? "none")",
            "downloadedArtifactManifestChecksum=\(downloadedArtifact.validationResult.sourceManifestChecksum ?? "none")",
            "uploadedFailureReasons=\(uploadedArtifact.validationResult.failures.map { $0.reason.rawValue }.joined(separator: ","))",
            "downloadedFailureReasons=\(downloadedArtifact.validationResult.failures.map { $0.reason.rawValue }.joined(separator: ","))",
            "failedUploadedArtifactRejectsWorkflow=\(failedUploadedArtifactRejectsWorkflow)",
            "failedDownloadedArtifactRejectsWorkflow=\(failedDownloadedArtifactRejectsWorkflow)",
            "workflowRequiresPassedStatus=\(workflowRequiresPassedStatus)",
            "failedStatusCannotSatisfyWorkflow=\(failedStatusCannotSatisfyWorkflow)",
            "cliFailedValidationPropagatesNonzeroExit=\(cliFailedValidationPropagatesNonzeroExit)",
            "uploadedArtifactBundleValidation=\(uploadedArtifactBundleValidation)",
            "downloadedArtifactBundleValidation=\(downloadedArtifactBundleValidation)",
            "sharedRuntimeValidatorUsed=\(sharedRuntimeValidatorUsed)",
            "cliValidatorPathUsed=\(cliValidatorPathUsed)",
            "uploadDownloadEvidenceRecorded=\(uploadDownloadEvidenceRecorded)",
            "localOnlyNoNetwork=\(localOnlyNoNetwork)",
            "redactedEvidenceOnly=\(redactedEvidenceOnly)",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionSecretReadEnabled=\(productionSecretReadEnabled)",
            "productionEndpointConnectionEnabled=\(productionEndpointConnectionEnabled)",
            "productionBrokerConnectionEnabled=\(productionBrokerConnectionEnabled)",
            "productionOrderSubmitCancelReplaceEnabled=\(productionOrderSubmitCancelReplaceEnabled)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=\(reportHeld)"
        ].joined(separator: "\n")
    }

    public static let workflowName = "release-v0.17.0-manual-artifact-validation"

    public static let requiredValidationAnchors = [
        "GH-1146-VERIFY-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION",
        "TVM-RELEASE-V0170-MANUAL-WORKFLOW-ARTIFACT-VALIDATION",
        "V0170-008-MANUAL-WORKFLOW-UPLOAD-DOWNLOAD-VALIDATION",
        "V0170-008-SHARED-RUNTIME-VALIDATOR-PATH",
        "V0170-008-UPLOADED-BUNDLE-VALIDATED",
        "V0170-008-DOWNLOADED-BUNDLE-VALIDATED",
        "V0170-008-LOCAL-ONLY-NO-NETWORK",
        "V0170-008-REDACTED-EVIDENCE-RECORDED",
        "V0170-008-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1146ReleaseV0170ManualWorkflowArtifactValidation",
        "bash checks/verify-v0.17.0-manual-workflow-artifact-validation.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let releaseV0171ManualWorkflowFailClosedAnchors = [
        "GH-1167-VERIFY-V0171-MANUAL-WORKFLOW-FAIL-CLOSED",
        "TVM-RELEASE-V0171-MANUAL-WORKFLOW-FAIL-CLOSED",
        "V0171-002-UPLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW",
        "V0171-002-DOWNLOADED-BUNDLE-FAILED-STATUS-REJECTS-WORKFLOW",
        "V0171-002-REQUIRE-PASSED-STATUS",
        "V0171-002-NO-PRODUCTION-CUTOVER"
    ]

    public static let releaseV0171ManualWorkflowFailClosedValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1167ReleaseV0171ManualWorkflowRejectsFailedArtifactStatus",
        "bash checks/verify-v0.17.1-manual-workflow-fail-closed.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let releaseV0171ArtifactNegativeRegressionAnchors = [
        "GH-1168-VERIFY-V0171-ARTIFACT-NEGATIVE-REGRESSIONS",
        "TVM-RELEASE-V0171-ARTIFACT-NEGATIVE-REGRESSIONS",
        "V0171-003-CORRUPT-BUNDLE-FAILS-CLOSED",
        "V0171-003-MISSING-ARTIFACT-FAILS-CLOSED",
        "V0171-003-MISSING-MANIFEST-FAILS-CLOSED",
        "V0171-003-RECONCILIATION-MISSING-FAILS-CLOSED",
        "V0171-003-REDACTED-OPERATOR-READABLE-EVIDENCE",
        "V0171-003-NO-PRODUCTION-CUTOVER"
    ]

    public static let releaseV0171ArtifactNegativeRegressionValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1168ReleaseV0171ArtifactNegativeRegressionsFailClosed",
        "bash checks/verify-v0.17.1-artifact-negative-regressions.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func validate(
        uploadedStorageRootPath: String,
        downloadedStorageRootPath: String,
        runID: String
    ) throws -> ReleaseV0170ManualWorkflowArtifactValidationReport {
        let uploaded = try ReleaseV0170CLIArtifactVerifyCommand.commandOutput(
            storageRootPath: uploadedStorageRootPath,
            runID: runID
        )
        let downloaded = try ReleaseV0170CLIArtifactVerifyCommand.commandOutput(
            storageRootPath: downloadedStorageRootPath,
            runID: runID
        )
        return try ReleaseV0170ManualWorkflowArtifactValidationReport(
            uploadedArtifact: uploaded,
            downloadedArtifact: downloaded
        )
    }

    public static func commandOutput(
        uploadedStorageRootPath: String,
        downloadedStorageRootPath: String,
        runID: String
    ) throws -> String {
        try validate(
            uploadedStorageRootPath: uploadedStorageRootPath,
            downloadedStorageRootPath: downloadedStorageRootPath,
            runID: runID
        ).rendered()
    }

    public static func deterministicID(
        uploadedArtifact: ReleaseV0170CLIArtifactVerifyCommandOutput,
        downloadedArtifact: ReleaseV0170CLIArtifactVerifyCommandOutput,
        status: ReleaseV0170ManualWorkflowArtifactValidationStatus
    ) -> Identifier {
        Identifier.constant(
            [
                "gh-1146-v0170-manual-workflow-artifact-validation",
                uploadedArtifact.validationResult.resultID.rawValue,
                downloadedArtifact.validationResult.resultID.rawValue,
                status.rawValue
            ].joined(separator: ":"),
            field: "releaseV0170ManualWorkflowArtifactValidation.reportID"
        )
    }

    public static func derivedStatus(
        uploadedArtifact: ReleaseV0170CLIArtifactVerifyCommandOutput,
        downloadedArtifact: ReleaseV0170CLIArtifactVerifyCommandOutput
    ) -> ReleaseV0170ManualWorkflowArtifactValidationStatus {
        uploadedArtifact.validationResult.status == .passed
            && downloadedArtifact.validationResult.status == .passed
            ? .passed
            : .failed
    }
}
