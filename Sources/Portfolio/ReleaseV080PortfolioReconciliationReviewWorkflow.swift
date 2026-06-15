import DomainModel
import Foundation

/// ReleaseV080PortfolioReconciliationReviewWorkflowError 描述 GH-817 review workflow 的合同错误。
///
/// 该错误只覆盖 v0.8.0 本地 operator review evidence，不表达修正命令、broker 写入、
/// account mutation、production account sync 或交易调整路径。
public enum ReleaseV080PortfolioReconciliationReviewWorkflowError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyReviewRecords
    case missingOperatorAcknowledgement(String)
    case auditTrailMismatch
    case statusCoverageMismatch
    case boundaryMismatch(String)
    case forbiddenCapability(String)

    public var description: String {
        switch self {
        case .emptyReviewRecords:
            "Release v0.8.0 Portfolio reconciliation review requires review records"
        case let .missingOperatorAcknowledgement(recordID):
            "Release v0.8.0 Portfolio reconciliation review requires operator acknowledgement for \(recordID)"
        case .auditTrailMismatch:
            "Release v0.8.0 Portfolio reconciliation review audit trail does not match review records"
        case .statusCoverageMismatch:
            "Release v0.8.0 Portfolio reconciliation review must cover matched/delta/missing/stale statuses"
        case let .boundaryMismatch(reason):
            "Release v0.8.0 Portfolio reconciliation review boundary mismatch: \(reason)"
        case let .forbiddenCapability(capability):
            "Release v0.8.0 Portfolio reconciliation review rejected forbidden capability: \(capability)"
        }
    }
}

/// ReleaseV080PortfolioReconciliationReviewStatus 固定 #817 operator review 可见状态。
///
/// 这些状态只用于解释 GH-790 read-only reconciliation diff 的 review 结果；任何状态都不授权
/// correction command、broker write、account mutation、testnet order routing 或 production cutover。
public enum ReleaseV080PortfolioReconciliationReviewStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case matched = "matched"
    case delta = "delta"
    case missing = "missing"
    case stale = "stale"
}

/// ReleaseV080PortfolioReconciliationOperatorAcknowledgement 记录 operator 对 review_required 项的审计确认。
///
/// acknowledgement 是 audit-only metadata：它不能触发 Portfolio correction、broker write、
/// account mutation、order command path 或 production cutover。
public struct ReleaseV080PortfolioReconciliationOperatorAcknowledgement: Codable, Equatable, Sendable {
    public let acknowledgedAt: String
    public let acknowledgedBy: String
    public let operatorNote: String
    public let auditOnly: Bool
    public let correctionCommandCreated: Bool
    public let brokerWritePathCreated: Bool
    public let accountMutationCreated: Bool
    public let tradingAdjustmentCommandCreated: Bool

    public var acknowledgementHeld: Bool {
        acknowledgedAt.isEmpty == false
            && acknowledgedBy.isEmpty == false
            && operatorNote.isEmpty == false
            && auditOnly
            && correctionCommandCreated == false
            && brokerWritePathCreated == false
            && accountMutationCreated == false
            && tradingAdjustmentCommandCreated == false
    }

    public init(
        acknowledgedAt: String,
        acknowledgedBy: String,
        operatorNote: String,
        auditOnly: Bool = true,
        correctionCommandCreated: Bool = false,
        brokerWritePathCreated: Bool = false,
        accountMutationCreated: Bool = false,
        tradingAdjustmentCommandCreated: Bool = false
    ) throws {
        guard auditOnly else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.forbiddenCapability("acknowledgement.auditOnly=false")
        }
        try Self.reject(correctionCommandCreated, "acknowledgement.correctionCommandCreated")
        try Self.reject(brokerWritePathCreated, "acknowledgement.brokerWritePathCreated")
        try Self.reject(accountMutationCreated, "acknowledgement.accountMutationCreated")
        try Self.reject(tradingAdjustmentCommandCreated, "acknowledgement.tradingAdjustmentCommandCreated")

        self.acknowledgedAt = acknowledgedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.acknowledgedBy = acknowledgedBy.trimmingCharacters(in: .whitespacesAndNewlines)
        self.operatorNote = operatorNote.trimmingCharacters(in: .whitespacesAndNewlines)
        self.auditOnly = auditOnly
        self.correctionCommandCreated = correctionCommandCreated
        self.brokerWritePathCreated = brokerWritePathCreated
        self.accountMutationCreated = accountMutationCreated
        self.tradingAdjustmentCommandCreated = tradingAdjustmentCommandCreated

        guard acknowledgementHeld else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.boundaryMismatch("operatorAcknowledgementHeld")
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.forbiddenCapability(field)
        }
    }
}

/// ReleaseV080PortfolioReconciliationReviewAuditArtifact 是 #817 的本地 audit trail 条目。
///
/// artifact path 只指向 `.local/mtpro/.../reconciliation-review` 下的本地审计文件，不保存
/// raw broker payload、account endpoint payload、credential value、order request 或 production endpoint。
public struct ReleaseV080PortfolioReconciliationReviewAuditArtifact: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let sourceDiffRecordID: Identifier
    public let status: ReleaseV080PortfolioReconciliationReviewStatus
    public let reviewRequired: Bool
    public let artifactPath: String
    public let auditOnly: Bool
    public let correctionCommandCreated: Bool
    public let brokerWritePathCreated: Bool
    public let accountMutationCreated: Bool
    public let tradingAdjustmentCommandCreated: Bool

    public var artifactHeld: Bool {
        artifactID.rawValue.isEmpty == false
            && sourceDiffRecordID.rawValue.isEmpty == false
            && artifactPath.contains("reconciliation-review")
            && auditOnly
            && correctionCommandCreated == false
            && brokerWritePathCreated == false
            && accountMutationCreated == false
            && tradingAdjustmentCommandCreated == false
    }

    public init(
        artifactID: Identifier,
        sourceDiffRecordID: Identifier,
        status: ReleaseV080PortfolioReconciliationReviewStatus,
        reviewRequired: Bool,
        runID: Identifier,
        artifactPath: String? = nil,
        auditOnly: Bool = true,
        correctionCommandCreated: Bool = false,
        brokerWritePathCreated: Bool = false,
        accountMutationCreated: Bool = false,
        tradingAdjustmentCommandCreated: Bool = false
    ) throws {
        guard auditOnly else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.forbiddenCapability("auditArtifact.auditOnly=false")
        }
        try Self.reject(correctionCommandCreated, "auditArtifact.correctionCommandCreated")
        try Self.reject(brokerWritePathCreated, "auditArtifact.brokerWritePathCreated")
        try Self.reject(accountMutationCreated, "auditArtifact.accountMutationCreated")
        try Self.reject(tradingAdjustmentCommandCreated, "auditArtifact.tradingAdjustmentCommandCreated")

        self.artifactID = artifactID
        self.sourceDiffRecordID = sourceDiffRecordID
        self.status = status
        self.reviewRequired = reviewRequired
        self.artifactPath = artifactPath
            ?? ".local/mtpro/runs/\(runID.rawValue)/reconciliation-review/\(sourceDiffRecordID.rawValue).json"
        self.auditOnly = auditOnly
        self.correctionCommandCreated = correctionCommandCreated
        self.brokerWritePathCreated = brokerWritePathCreated
        self.accountMutationCreated = accountMutationCreated
        self.tradingAdjustmentCommandCreated = tradingAdjustmentCommandCreated

        guard artifactHeld else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.boundaryMismatch("auditArtifactHeld")
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.forbiddenCapability(field)
        }
    }
}

/// ReleaseV080PortfolioReconciliationReviewRecord 是 GH-817 的 per-diff operator review 值对象。
public struct ReleaseV080PortfolioReconciliationReviewRecord: Codable, Equatable, Sendable {
    public let reviewID: Identifier
    public let sourceDiffRecordID: Identifier
    public let runID: Identifier
    public let asset: String
    public let expectedQuantity: Decimal
    public let observedTotal: Decimal?
    public let delta: Decimal?
    public let status: ReleaseV080PortfolioReconciliationReviewStatus
    public let reviewRequired: Bool
    public let staleObservedState: Bool
    public let operatorNote: String?
    public let acknowledgedAt: String?
    public let acknowledgedBy: String?
    public let auditTrailArtifact: ReleaseV080PortfolioReconciliationReviewAuditArtifact
    public let correctionCommandCreated: Bool
    public let brokerWritePathCreated: Bool
    public let accountMutationCreated: Bool
    public let tradingAdjustmentCommandCreated: Bool

    public var recordHeld: Bool {
        reviewID.rawValue.isEmpty == false
            && sourceDiffRecordID.rawValue.isEmpty == false
            && runID.rawValue.isEmpty == false
            && asset.isEmpty == false
            && reviewRequired == (status != .matched)
            && staleObservedState == (status == .stale)
            && acknowledgementBoundaryHeld
            && auditTrailArtifact.artifactHeld
            && auditTrailArtifact.sourceDiffRecordID == sourceDiffRecordID
            && auditTrailArtifact.status == status
            && auditTrailArtifact.reviewRequired == reviewRequired
            && forbiddenBoundaryHeld
    }

    public var acknowledgementBoundaryHeld: Bool {
        if reviewRequired {
            return operatorNote?.isEmpty == false
                && acknowledgedAt?.isEmpty == false
                && acknowledgedBy?.isEmpty == false
        }

        return operatorNote == nil
            && acknowledgedAt == nil
            && acknowledgedBy == nil
    }

    public var forbiddenBoundaryHeld: Bool {
        correctionCommandCreated == false
            && brokerWritePathCreated == false
            && accountMutationCreated == false
            && tradingAdjustmentCommandCreated == false
    }

    public init(
        reviewID: Identifier,
        sourceDiff: ReleaseV070PortfolioReadOnlyReconciliationDiffRecord,
        status: ReleaseV080PortfolioReconciliationReviewStatus,
        acknowledgement: ReleaseV080PortfolioReconciliationOperatorAcknowledgement?,
        correctionCommandCreated: Bool = false,
        brokerWritePathCreated: Bool = false,
        accountMutationCreated: Bool = false,
        tradingAdjustmentCommandCreated: Bool = false
    ) throws {
        let reviewRequired = status != .matched
        if reviewRequired && acknowledgement == nil {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError
                .missingOperatorAcknowledgement(sourceDiff.recordID.rawValue)
        }
        if reviewRequired == false && acknowledgement != nil {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.boundaryMismatch("matchedReviewMustNotAcknowledge")
        }
        try Self.reject(correctionCommandCreated, "reviewRecord.correctionCommandCreated")
        try Self.reject(brokerWritePathCreated, "reviewRecord.brokerWritePathCreated")
        try Self.reject(accountMutationCreated, "reviewRecord.accountMutationCreated")
        try Self.reject(tradingAdjustmentCommandCreated, "reviewRecord.tradingAdjustmentCommandCreated")

        self.reviewID = reviewID
        self.sourceDiffRecordID = sourceDiff.recordID
        self.runID = sourceDiff.runID
        self.asset = sourceDiff.asset
        self.expectedQuantity = sourceDiff.expectedQuantity
        self.observedTotal = sourceDiff.observedTotal
        self.delta = sourceDiff.delta
        self.status = status
        self.reviewRequired = reviewRequired
        self.staleObservedState = status == .stale
        self.operatorNote = acknowledgement?.operatorNote
        self.acknowledgedAt = acknowledgement?.acknowledgedAt
        self.acknowledgedBy = acknowledgement?.acknowledgedBy
        self.auditTrailArtifact = try ReleaseV080PortfolioReconciliationReviewAuditArtifact(
            artifactID: Identifier.constant("gh-817-v080-review-artifact-\(sourceDiff.recordID.rawValue)"),
            sourceDiffRecordID: sourceDiff.recordID,
            status: status,
            reviewRequired: reviewRequired,
            runID: sourceDiff.runID
        )
        self.correctionCommandCreated = correctionCommandCreated
        self.brokerWritePathCreated = brokerWritePathCreated
        self.accountMutationCreated = accountMutationCreated
        self.tradingAdjustmentCommandCreated = tradingAdjustmentCommandCreated

        guard recordHeld else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.boundaryMismatch("reviewRecordHeld")
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.forbiddenCapability(field)
        }
    }
}

/// ReleaseV080PortfolioReconciliationReviewEvidence 汇总 GH-817 review workflow evidence。
public struct ReleaseV080PortfolioReconciliationReviewEvidence: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let sourceReconciliation: ReleaseV070PortfolioReadOnlyReconciliationEvidence
    public let reviewRecords: [ReleaseV080PortfolioReconciliationReviewRecord]
    public let auditTrailArtifacts: [ReleaseV080PortfolioReconciliationReviewAuditArtifact]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let statusCoverage: [ReleaseV080PortfolioReconciliationReviewStatus]
    public let operatorAcknowledgementAuditOnly: Bool
    public let correctionCommandCreated: Bool
    public let brokerWritePathCreated: Bool
    public let accountMutationCreated: Bool
    public let tradingAdjustmentCommandCreated: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-817"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-813", "GH-816", "GH-790"]
            && previousIssueID.rawValue == "GH-816"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-818", "GH-819", "GH-820"]
            && releaseVersion == "v0.8.0"
            && sourceReconciliation.evidenceHeld
            && reviewRecords.isEmpty == false
            && reviewRecords.allSatisfy(\.recordHeld)
            && auditTrailArtifacts == reviewRecords.map(\.auditTrailArtifact)
            && validationAnchors == ReleaseV080PortfolioReconciliationReviewWorkflowContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV080PortfolioReconciliationReviewWorkflowContract.requiredValidationCommands
            && statusCoverage == ReleaseV080PortfolioReconciliationReviewStatus.allCases
            && reviewRecords.map(\.sourceDiffRecordID) == sourceReconciliation.diffRecords.map(\.recordID)
            && reviewRecords.contains { $0.status == .matched && $0.reviewRequired == false }
            && reviewRecords.contains { $0.status == .delta && $0.reviewRequired }
            && reviewRecords.contains { $0.status == .missing && $0.reviewRequired }
            && reviewRecords.contains { $0.status == .stale && $0.reviewRequired && $0.staleObservedState }
            && operatorAcknowledgementAuditOnly
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        correctionCommandCreated == false
            && brokerWritePathCreated == false
            && accountMutationCreated == false
            && tradingAdjustmentCommandCreated == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && testnetOrderRoutingAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-817"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-813"),
            Identifier.constant("GH-816"),
            Identifier.constant("GH-790")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-816"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-818"),
            Identifier.constant("GH-819"),
            Identifier.constant("GH-820")
        ],
        releaseVersion: String = "v0.8.0",
        sourceReconciliation: ReleaseV070PortfolioReadOnlyReconciliationEvidence,
        reviewRecords: [ReleaseV080PortfolioReconciliationReviewRecord],
        validationAnchors: [String] = ReleaseV080PortfolioReconciliationReviewWorkflowContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV080PortfolioReconciliationReviewWorkflowContract.requiredValidationCommands,
        operatorAcknowledgementAuditOnly: Bool = true,
        correctionCommandCreated: Bool = false,
        brokerWritePathCreated: Bool = false,
        accountMutationCreated: Bool = false,
        tradingAdjustmentCommandCreated: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard reviewRecords.isEmpty == false else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.emptyReviewRecords
        }
        let artifacts = reviewRecords.map(\.auditTrailArtifact)
        let coverage = ReleaseV080PortfolioReconciliationReviewStatus.allCases.filter { status in
            reviewRecords.contains { $0.status == status }
        }
        guard coverage == ReleaseV080PortfolioReconciliationReviewStatus.allCases else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.statusCoverageMismatch
        }
        try Self.reject(correctionCommandCreated, "correctionCommandCreated")
        try Self.reject(brokerWritePathCreated, "brokerWritePathCreated")
        try Self.reject(accountMutationCreated, "accountMutationCreated")
        try Self.reject(tradingAdjustmentCommandCreated, "tradingAdjustmentCommandCreated")
        try Self.reject(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.reject(productionSecretAutoReadEnabled, "productionSecretAutoReadEnabled")
        try Self.reject(productionEndpointConnected, "productionEndpointConnected")
        try Self.reject(productionBrokerConnected, "productionBrokerConnected")
        try Self.reject(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.reject(testnetOrderRoutingAllowed, "testnetOrderRoutingAllowed")
        try Self.reject(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.sourceReconciliation = sourceReconciliation
        self.reviewRecords = reviewRecords
        self.auditTrailArtifacts = artifacts
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.statusCoverage = coverage
        self.operatorAcknowledgementAuditOnly = operatorAcknowledgementAuditOnly
        self.correctionCommandCreated = correctionCommandCreated
        self.brokerWritePathCreated = brokerWritePathCreated
        self.accountMutationCreated = accountMutationCreated
        self.tradingAdjustmentCommandCreated = tradingAdjustmentCommandCreated
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard artifacts == auditTrailArtifacts else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.auditTrailMismatch
        }
        guard evidenceHeld else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.boundaryMismatch("reviewEvidenceHeld")
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.forbiddenCapability(field)
        }
    }
}

/// ReleaseV080PortfolioReconciliationReviewWorkflow 从 GH-790 explain-only diff 派生 operator review。
public enum ReleaseV080PortfolioReconciliationReviewWorkflow {
    public static func review(
        sourceReconciliation: ReleaseV070PortfolioReadOnlyReconciliationEvidence,
        staleObservedAssets: Set<String>,
        acknowledgements: [Identifier: ReleaseV080PortfolioReconciliationOperatorAcknowledgement]
    ) throws -> ReleaseV080PortfolioReconciliationReviewEvidence {
        guard sourceReconciliation.evidenceHeld else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.boundaryMismatch("sourceReconciliationHeld")
        }

        let records = try sourceReconciliation.diffRecords.map { diff in
            let status = reviewStatus(for: diff, staleObservedAssets: staleObservedAssets)
            let acknowledgement = acknowledgements[diff.recordID]
            return try ReleaseV080PortfolioReconciliationReviewRecord(
                reviewID: Identifier.constant("gh-817-v080-review-\(diff.recordID.rawValue)"),
                sourceDiff: diff,
                status: status,
                acknowledgement: acknowledgement
            )
        }

        return try ReleaseV080PortfolioReconciliationReviewEvidence(
            sourceReconciliation: sourceReconciliation,
            reviewRecords: records
        )
    }

    public static func reviewStatus(
        for diff: ReleaseV070PortfolioReadOnlyReconciliationDiffRecord,
        staleObservedAssets: Set<String>
    ) -> ReleaseV080PortfolioReconciliationReviewStatus {
        if staleObservedAssets.contains(diff.asset) {
            return .stale
        }

        switch diff.status {
        case .matchedReadOnlyObservation:
            return .matched
        case .explanatoryDelta:
            return .delta
        case .missingObservedState:
            return .missing
        }
    }
}

/// ReleaseV080PortfolioReconciliationReviewWorkflowContract 固定 GH-817 issue-level 验收合同。
public struct ReleaseV080PortfolioReconciliationReviewWorkflowContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-817"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-813", "GH-816", "GH-790"]
            && previousIssueID.rawValue == "GH-816"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-818", "GH-819", "GH-820"]
            && releaseVersion == "v0.8.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmissionEnabled == false
            && testnetOrderRoutingAllowed == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-817"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-813"),
            Identifier.constant("GH-816"),
            Identifier.constant("GH-790")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-816"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-818"),
            Identifier.constant("GH-819"),
            Identifier.constant("GH-820")
        ],
        releaseVersion: String = "v0.8.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV080PortfolioReconciliationReviewWorkflowError.boundaryMismatch("contractHeld")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV080PortfolioReconciliationReviewWorkflowContract {
        try ReleaseV080PortfolioReconciliationReviewWorkflowContract()
    }

    public static let requiredValidationAnchors = [
        "GH-817-VERIFY-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW",
        "TVM-RELEASE-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW",
        "V080-011-RECONCILIATION-STATUS-MATCHED-DELTA-MISSING-STALE",
        "V080-011-REVIEW-REQUIRED-OPERATOR-NOTE-ACK",
        "V080-011-STALE-OBSERVED-STATE",
        "V080-011-AUDIT-TRAIL-ARTIFACTS",
        "V080-011-NO-CORRECTION-COMMAND-BROKER-WRITE",
        "V080-011-PORTFOLIO-REVIEW-WORKFLOW"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH817PortfolioReconciliationReviewWorkflowRequiresAuditOnlyAcknowledgement",
        "bash checks/verify-v0.8.0-portfolio-reconciliation-review.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
