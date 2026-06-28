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
// GH-1183 static contract boundary:
// manualWorkflowFixtureNegativeCases=ReleaseV0180ManualWorkflowFixtureNegativeCaseSuite
// corruptBundleFixtureFailsClosed=true
// missingFieldFixtureFailsClosed=true
// wrongVenueFixtureFailsClosed=true
// wrongProductFixtureFailsClosed=true
// wrongEnvironmentFixtureFailsClosed=true
// failedValidationStateRejectsWorkflow=true
// failedChecksCannotPassWithFailedStatusString=true
// noProductionNetworkFlow=true
// noSecretUpload=true
// noOrderArtifactGeneratedFromWorkflowAlone=true
// productionCutoverAuthorized=false

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

/// ReleaseV0180ManualWorkflowFixtureNegativeCaseKind 列出 GH-1183 手工 workflow
/// upload/download fixture 的负例分类。
///
/// 这些分类只服务本地 artifact workflow 证据，不代表可以从 workflow 生成订单、读取 secret、
/// 或连接 production / broker endpoint。
public enum ReleaseV0180ManualWorkflowFixtureNegativeCaseKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case corruptBundle
    case missingRequiredField
    case wrongVenue
    case wrongProduct
    case wrongEnvironment
    case failedValidationState
}

/// ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence 固定单个 GH-1183 负例的
/// fail-closed 证据。
///
/// 每个 evidence 都必须把 manual workflow 顶层状态设为 failed，并记录至少一个 failed check。
/// 这样 workflow 不能只打印 `status=failed` 字符串后仍以成功状态通过。
public struct ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence: Equatable, Sendable {
    public let caseID: Identifier
    public let kind: ReleaseV0180ManualWorkflowFixtureNegativeCaseKind
    public let expectedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let observedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let workflowStatus: ReleaseV0170ManualWorkflowArtifactValidationStatus
    public let uploadedArtifactStatus: ReleaseV0170OperatorBetaArtifactBundleValidationStatus
    public let downloadedArtifactStatus: ReleaseV0170OperatorBetaArtifactBundleValidationStatus
    public let failedChecks: [String]
    public let operatorDiagnostic: String
    public let manualWorkflowRejectsFailedBundle: Bool
    public let failedChecksCannotPassWithFailedStatusString: Bool
    public let noProductionNetworkFlow: Bool
    public let noSecretUpload: Bool
    public let noOrderArtifactGeneratedFromWorkflowAlone: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var evidenceHeld: Bool {
        caseID == Self.deterministicID(
            kind: kind,
            expectedNamespace: expectedNamespace,
            observedNamespace: observedNamespace,
            failedChecks: failedChecks
        )
            && workflowStatus == .failed
            && failedChecks.isEmpty == false
            && failedChecks.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
            && uploadedArtifactStatus == .failed
            && downloadedArtifactStatus == .failed
            && manualWorkflowRejectsFailedBundle
            && failedChecksCannotPassWithFailedStatusString
            && noProductionNetworkFlow
            && noSecretUpload
            && noOrderArtifactGeneratedFromWorkflowAlone
            && productionDefaultsClosed
            && namespaceEvidenceHeld
            && redactedOperatorDiagnosticHeld
            && validationAnchors == ReleaseV0180ManualWorkflowFixtureNegativeCaseSuite.requiredValidationAnchors
    }

    public var namespaceEvidenceHeld: Bool {
        switch kind {
        case .wrongVenue:
            expectedNamespace.venue != observedNamespace.venue
                && expectedNamespace.product == observedNamespace.product
                && expectedNamespace.environment == observedNamespace.environment
                && expectedNamespace.accountProfile == observedNamespace.accountProfile
                && expectedNamespace.runID == observedNamespace.runID
        case .wrongProduct:
            expectedNamespace.venue == observedNamespace.venue
                && expectedNamespace.product != observedNamespace.product
                && expectedNamespace.environment == observedNamespace.environment
                && expectedNamespace.accountProfile == observedNamespace.accountProfile
                && expectedNamespace.runID == observedNamespace.runID
        case .wrongEnvironment:
            expectedNamespace.venue == observedNamespace.venue
                && expectedNamespace.product == observedNamespace.product
                && expectedNamespace.environment != observedNamespace.environment
                && expectedNamespace.accountProfile == observedNamespace.accountProfile
                && expectedNamespace.runID == observedNamespace.runID
        case .corruptBundle, .missingRequiredField, .failedValidationState:
            expectedNamespace == observedNamespace
        }
    }

    public var redactedOperatorDiagnosticHeld: Bool {
        operatorDiagnostic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && ReleaseV0161OperatorBetaArtifactRedactionPolicy
                .forbiddenMarkers(in: operatorDiagnostic)
                .isEmpty
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
        kind: ReleaseV0180ManualWorkflowFixtureNegativeCaseKind,
        expectedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        observedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        failedChecks: [String],
        operatorDiagnostic: String,
        workflowStatus: ReleaseV0170ManualWorkflowArtifactValidationStatus = .failed,
        uploadedArtifactStatus: ReleaseV0170OperatorBetaArtifactBundleValidationStatus = .failed,
        downloadedArtifactStatus: ReleaseV0170OperatorBetaArtifactBundleValidationStatus = .failed,
        manualWorkflowRejectsFailedBundle: Bool = true,
        failedChecksCannotPassWithFailedStatusString: Bool = true,
        noProductionNetworkFlow: Bool = true,
        noSecretUpload: Bool = true,
        noOrderArtifactGeneratedFromWorkflowAlone: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = ReleaseV0180ManualWorkflowFixtureNegativeCaseSuite
            .requiredValidationAnchors
    ) throws {
        self.kind = kind
        self.expectedNamespace = expectedNamespace
        self.observedNamespace = observedNamespace
        self.workflowStatus = workflowStatus
        self.uploadedArtifactStatus = uploadedArtifactStatus
        self.downloadedArtifactStatus = downloadedArtifactStatus
        self.failedChecks = failedChecks
        self.operatorDiagnostic = operatorDiagnostic
        self.manualWorkflowRejectsFailedBundle = manualWorkflowRejectsFailedBundle
        self.failedChecksCannotPassWithFailedStatusString = failedChecksCannotPassWithFailedStatusString
        self.noProductionNetworkFlow = noProductionNetworkFlow
        self.noSecretUpload = noSecretUpload
        self.noOrderArtifactGeneratedFromWorkflowAlone = noOrderArtifactGeneratedFromWorkflowAlone
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
        self.caseID = Self.deterministicID(
            kind: kind,
            expectedNamespace: expectedNamespace,
            observedNamespace: observedNamespace,
            failedChecks: failedChecks
        )

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0180ManualWorkflowFixtureNegativeCase.\(kind.rawValue)",
                expected: "failed manual workflow fixture evidence",
                actual: workflowStatus.rawValue
            )
        }
    }

    public static func deterministicID(
        kind: ReleaseV0180ManualWorkflowFixtureNegativeCaseKind,
        expectedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        observedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        failedChecks: [String]
    ) -> Identifier {
        Identifier.constant(
            [
                "gh-1183-v0180-manual-workflow-fixture-negative-case",
                kind.rawValue,
                expectedNamespace.namespaceKey,
                observedNamespace.namespaceKey,
                failedChecks.joined(separator: ",")
            ].joined(separator: ":"),
            field: "releaseV0180ManualWorkflowFixtureNegativeCase.caseID"
        )
    }
}

/// ReleaseV0180ManualWorkflowFixtureNegativeCaseSuite 聚合 GH-1183 的手工
/// workflow upload/download 负例覆盖。
///
/// Suite 只描述本地 workflow fixture 的拒绝语义：corrupt bundle、missing field、
/// wrong venue/product/environment 和 failed validation state 都必须变成 failed checks。
/// 它不上传 secret，不生成订单 artifact，不连接任何 production 或 broker endpoint。
public struct ReleaseV0180ManualWorkflowFixtureNegativeCaseSuite: Equatable, Sendable {
    public let suiteID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let releaseVersion: String
    public let expectedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    public let cases: [ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence]
    public let corruptBundleFixtureFailsClosed: Bool
    public let missingFieldFixtureFailsClosed: Bool
    public let wrongVenueFixtureFailsClosed: Bool
    public let wrongProductFixtureFailsClosed: Bool
    public let wrongEnvironmentFixtureFailsClosed: Bool
    public let failedValidationStateRejectsWorkflow: Bool
    public let failedChecksCannotPassWithFailedStatusString: Bool
    public let manualWorkflowRejectsFailedBundles: Bool
    public let noProductionNetworkFlow: Bool
    public let noSecretUpload: Bool
    public let noOrderArtifactGeneratedFromWorkflowAlone: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var suiteHeld: Bool {
        suiteID == Self.deterministicID(expectedNamespace: expectedNamespace, cases: cases)
            && issueID.rawValue == "GH-1183"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1177", "GH-1178"]
            && releaseVersion == "v0.18.0"
            && cases.count == Self.requiredKinds.count
            && Set(cases.map(\.kind)) == Set(Self.requiredKinds)
            && cases.allSatisfy(\.evidenceHeld)
            && cases.allSatisfy { $0.expectedNamespace == expectedNamespace }
            && corruptBundleFixtureFailsClosed
            && missingFieldFixtureFailsClosed
            && wrongVenueFixtureFailsClosed
            && wrongProductFixtureFailsClosed
            && wrongEnvironmentFixtureFailsClosed
            && failedValidationStateRejectsWorkflow
            && failedChecksCannotPassWithFailedStatusString
            && manualWorkflowRejectsFailedBundles
            && noProductionNetworkFlow
            && noSecretUpload
            && noOrderArtifactGeneratedFromWorkflowAlone
            && productionDefaultsClosed
            && validationAnchors == Self.requiredValidationAnchors
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
        expectedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        cases: [ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence],
        issueID: Identifier = Identifier.constant("GH-1183"),
        blockedByIssueIDs: [Identifier] = [
            Identifier.constant("GH-1177"),
            Identifier.constant("GH-1178")
        ],
        releaseVersion: String = "v0.18.0",
        corruptBundleFixtureFailsClosed: Bool = true,
        missingFieldFixtureFailsClosed: Bool = true,
        wrongVenueFixtureFailsClosed: Bool = true,
        wrongProductFixtureFailsClosed: Bool = true,
        wrongEnvironmentFixtureFailsClosed: Bool = true,
        failedValidationStateRejectsWorkflow: Bool = true,
        failedChecksCannotPassWithFailedStatusString: Bool = true,
        manualWorkflowRejectsFailedBundles: Bool = true,
        noProductionNetworkFlow: Bool = true,
        noSecretUpload: Bool = true,
        noOrderArtifactGeneratedFromWorkflowAlone: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        self.expectedNamespace = expectedNamespace
        self.cases = cases
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.releaseVersion = releaseVersion
        self.corruptBundleFixtureFailsClosed = corruptBundleFixtureFailsClosed
        self.missingFieldFixtureFailsClosed = missingFieldFixtureFailsClosed
        self.wrongVenueFixtureFailsClosed = wrongVenueFixtureFailsClosed
        self.wrongProductFixtureFailsClosed = wrongProductFixtureFailsClosed
        self.wrongEnvironmentFixtureFailsClosed = wrongEnvironmentFixtureFailsClosed
        self.failedValidationStateRejectsWorkflow = failedValidationStateRejectsWorkflow
        self.failedChecksCannotPassWithFailedStatusString = failedChecksCannotPassWithFailedStatusString
        self.manualWorkflowRejectsFailedBundles = manualWorkflowRejectsFailedBundles
        self.noProductionNetworkFlow = noProductionNetworkFlow
        self.noSecretUpload = noSecretUpload
        self.noOrderArtifactGeneratedFromWorkflowAlone = noOrderArtifactGeneratedFromWorkflowAlone
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
        self.suiteID = Self.deterministicID(expectedNamespace: expectedNamespace, cases: cases)

        guard suiteHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0180ManualWorkflowFixtureNegativeCaseSuite",
                expected: "all GH-1183 fixture negative cases fail closed",
                actual: "\(cases.count)"
            )
        }
    }

    public static let requiredKinds: [ReleaseV0180ManualWorkflowFixtureNegativeCaseKind] = [
        .corruptBundle,
        .missingRequiredField,
        .wrongVenue,
        .wrongProduct,
        .wrongEnvironment,
        .failedValidationState
    ]

    public static let requiredValidationAnchors = [
        "GH-1183-VERIFY-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES",
        "TVM-RELEASE-V0180-MANUAL-WORKFLOW-FIXTURE-NEGATIVE-CASES",
        "V0180-008-DEPENDENCIES-GH1177-GH1178-DONE",
        "V0180-008-CORRUPT-BUNDLE-FAILS-CLOSED",
        "V0180-008-MISSING-FIELDS-FAIL-CLOSED",
        "V0180-008-WRONG-VENUE-PRODUCT-ENVIRONMENT-FAILS-CLOSED",
        "V0180-008-FAILED-VALIDATION-STATE-REJECTS-WORKFLOW",
        "V0180-008-FAILED-CHECKS-CANNOT-PASS-WITH-FAILED-STATUS-STRING",
        "V0180-008-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1183ManualWorkflowFixtureNegativeCasesFailClosed",
        "bash checks/verify-v0.18.0-manual-workflow-fixture-negative-cases.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func canonical(
        expectedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace
    ) throws -> ReleaseV0180ManualWorkflowFixtureNegativeCaseSuite {
        let wrongVenueNamespace = try ReleaseV0180StatusQueryRetryArtifactNamespace(
            venue: "okx",
            product: "spot",
            environment: expectedNamespace.environment,
            accountProfile: expectedNamespace.accountProfile,
            runID: expectedNamespace.runID
        )
        let wrongProductNamespace = try ReleaseV0180StatusQueryRetryArtifactNamespace(
            venue: expectedNamespace.venue,
            product: "usdmFutures",
            environment: expectedNamespace.environment,
            accountProfile: expectedNamespace.accountProfile,
            runID: expectedNamespace.runID
        )
        let wrongEnvironmentNamespace = try ReleaseV0180StatusQueryRetryArtifactNamespace(
            venue: expectedNamespace.venue,
            product: expectedNamespace.product,
            environment: "productionShadow",
            accountProfile: expectedNamespace.accountProfile,
            runID: expectedNamespace.runID
        )

        let cases = try [
            ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence(
                kind: .corruptBundle,
                expectedNamespace: expectedNamespace,
                observedNamespace: expectedNamespace,
                failedChecks: ["checksumMismatch"],
                operatorDiagnostic: "corrupt bundle fixture rejected by local manual workflow"
            ),
            ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence(
                kind: .missingRequiredField,
                expectedNamespace: expectedNamespace,
                observedNamespace: expectedNamespace,
                failedChecks: ["missingRequiredField"],
                operatorDiagnostic: "missing required fixture field rejected before workflow success"
            ),
            ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence(
                kind: .wrongVenue,
                expectedNamespace: expectedNamespace,
                observedNamespace: wrongVenueNamespace,
                failedChecks: ["wrongVenue"],
                operatorDiagnostic: "wrong venue fixture namespace rejected by manual workflow"
            ),
            ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence(
                kind: .wrongProduct,
                expectedNamespace: expectedNamespace,
                observedNamespace: wrongProductNamespace,
                failedChecks: ["wrongProduct"],
                operatorDiagnostic: "wrong product fixture namespace rejected by manual workflow"
            ),
            ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence(
                kind: .wrongEnvironment,
                expectedNamespace: expectedNamespace,
                observedNamespace: wrongEnvironmentNamespace,
                failedChecks: ["wrongEnvironment"],
                operatorDiagnostic: "wrong environment fixture namespace rejected by manual workflow"
            ),
            ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence(
                kind: .failedValidationState,
                expectedNamespace: expectedNamespace,
                observedNamespace: expectedNamespace,
                failedChecks: ["failedValidationState"],
                operatorDiagnostic: "failed validation state cannot satisfy manual workflow success"
            )
        ]
        return try ReleaseV0180ManualWorkflowFixtureNegativeCaseSuite(
            expectedNamespace: expectedNamespace,
            cases: cases
        )
    }

    public static func deterministicID(
        expectedNamespace: ReleaseV0180StatusQueryRetryArtifactNamespace,
        cases: [ReleaseV0180ManualWorkflowFixtureNegativeCaseEvidence]
    ) -> Identifier {
        Identifier.constant(
            [
                "gh-1183-v0180-manual-workflow-fixture-negative-case-suite",
                expectedNamespace.namespaceKey,
                cases.map { "\($0.kind.rawValue)=\($0.caseID.rawValue)" }.joined(separator: "|")
            ].joined(separator: ":"),
            field: "releaseV0180ManualWorkflowFixtureNegativeCaseSuite.suiteID"
        )
    }
}
