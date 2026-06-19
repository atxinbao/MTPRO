import Crypto
import DomainModel
import Foundation

/// ReleaseV0110AuditableApprovalWorkflowAnchors 固定 GH-923 的审批 transition state model 验证锚点。
///
/// GH-923 只把人工审批流程建模为本地 readiness evidence。即使 state 为 approved，
/// 它也不会授权 production cutover、production secret read、endpoint / broker connection 或订单命令。
public enum ReleaseV0110AuditableApprovalWorkflowAnchors {
    public static let validationAnchors = [
        "GH-923-VERIFY-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS",
        "TVM-RELEASE-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS",
        "V0110-011-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS",
        "V0110-011-REQUEST-REVIEW-APPROVE-REVOKE-EXPIRE",
        "V0110-011-QUORUM-EXPIRY-REVOCATION-FAIL-CLOSED",
        "V0110-011-LOCAL-APPROVAL-EVIDENCE-ARTIFACT",
        "V0110-011-NO-PRODUCTION-CUTOVER-ORDER"
    ]
}

/// ReleaseV0120ApprovalRoleQuorumSeparationAnchors 固定 GH-960 的审批角色 / quorum hardening 锚点。
///
/// GH-960 只强化本地 approval evidence 的可信度：角色、quorum、职责分离、bundle checksum
/// 和 transition checksum chain 都必须可审计；即使 evidence approved，也不授权 production cutover。
public enum ReleaseV0120ApprovalRoleQuorumSeparationAnchors {
    public static let validationAnchors = [
        "GH-960-VERIFY-V0120-APPROVAL-ROLE-QUORUM-SEPARATION",
        "TVM-RELEASE-V0120-APPROVAL-ROLE-QUORUM-SEPARATION",
        "V0120-009-APPROVAL-ROLE-QUORUM-SEPARATION",
        "V0120-009-REQUESTER-REVIEWER-APPROVER-ROLE-POLICY",
        "V0120-009-QUORUM-SEPARATION-OF-DUTIES",
        "V0120-009-APPROVAL-EXPIRY-REVOCATION-FAIL-CLOSED",
        "V0120-009-BUNDLE-CHECKSUM-BINDING",
        "V0120-009-TRANSITION-CHECKSUM-CHAIN",
        "V0120-009-NO-PRODUCTION-CUTOVER"
    ]
}

/// ReleaseV0110ApprovalWorkflowArtifactKind 固定 GH-923 的本地 approval evidence 文件。
public enum ReleaseV0110ApprovalWorkflowArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case approvalWorkflowTransitions = "approval_workflow_transitions.json"
}

/// ReleaseV0120ApprovalWorkflowRolePolicy 固定 GH-960 的 requester / reviewer / approver 角色边界。
///
/// 这些角色只用于本地 readiness approval evidence。职责分离要求 requester 不得充当 reviewer
/// 或 approver，reviewer 与 approver 也不得互相代替。
public struct ReleaseV0120ApprovalWorkflowRolePolicy: Codable, Equatable, Sendable {
    public let requester: ReleaseV0110ApprovalWorkflowActorReference
    public let reviewers: [ReleaseV0110ApprovalWorkflowActorReference]
    public let approvers: [ReleaseV0110ApprovalWorkflowActorReference]
    public let revokers: [ReleaseV0110ApprovalWorkflowActorReference]
    public let separationOfDutiesRequired: Bool

    public var rolePolicyHeld: Bool {
        reviewers.isEmpty == false
            && approvers.isEmpty == false
            && revokers.isEmpty == false
            && Set(reviewers.map(\.reference)).count == reviewers.count
            && Set(approvers.map(\.reference)).count == approvers.count
            && Set(revokers.map(\.reference)).count == revokers.count
            && separationOfDutiesSatisfied
    }

    public var separationOfDutiesSatisfied: Bool {
        guard separationOfDutiesRequired else {
            return true
        }

        let requesterReference = requester.reference
        let reviewerReferences = Set(reviewers.map(\.reference))
        let approverReferences = Set(approvers.map(\.reference))

        return reviewerReferences.contains(requesterReference) == false
            && approverReferences.contains(requesterReference) == false
            && reviewerReferences.isDisjoint(with: approverReferences)
    }

    public init(
        requester: ReleaseV0110ApprovalWorkflowActorReference,
        reviewers: [ReleaseV0110ApprovalWorkflowActorReference],
        approvers: [ReleaseV0110ApprovalWorkflowActorReference],
        revokers: [ReleaseV0110ApprovalWorkflowActorReference],
        separationOfDutiesRequired: Bool = true
    ) throws {
        self.requester = requester
        self.reviewers = reviewers
        self.approvers = approvers
        self.revokers = revokers
        self.separationOfDutiesRequired = separationOfDutiesRequired

        guard rolePolicyHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "approvalWorkflowRolePolicy",
                expected: "requester/reviewer/approver/revoker separation of duties",
                actual: "invalid"
            )
        }
    }
}

/// ReleaseV0120ApprovalWorkflowQuorumPolicy 固定 GH-960 的 review / approval quorum 规则。
///
/// Approver quorum 与 reviewer quorum 分开计算；approver 不能自动计入 reviewer quorum，
/// reviewer 也不能自动计入 approver quorum。
public struct ReleaseV0120ApprovalWorkflowQuorumPolicy: Codable, Equatable, Sendable {
    public let reviewerQuorumRequired: Int
    public let approverQuorumRequired: Int
    public let approverCountsTowardReviewerQuorum: Bool
    public let reviewerCountsTowardApproverQuorum: Bool

    public var quorumPolicyHeld: Bool {
        reviewerQuorumRequired > 0
            && approverQuorumRequired > 0
            && approverCountsTowardReviewerQuorum == false
            && reviewerCountsTowardApproverQuorum == false
    }

    public init(
        reviewerQuorumRequired: Int,
        approverQuorumRequired: Int,
        approverCountsTowardReviewerQuorum: Bool = false,
        reviewerCountsTowardApproverQuorum: Bool = false
    ) throws {
        self.reviewerQuorumRequired = reviewerQuorumRequired
        self.approverQuorumRequired = approverQuorumRequired
        self.approverCountsTowardReviewerQuorum = approverCountsTowardReviewerQuorum
        self.reviewerCountsTowardApproverQuorum = reviewerCountsTowardApproverQuorum

        guard quorumPolicyHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "approvalWorkflowQuorumPolicy",
                expected: "positive independent reviewer/approver quorum",
                actual: "invalid"
            )
        }
    }
}

/// ReleaseV0110ApprovalWorkflowState 是 GH-923 的可审计审批状态集合。
///
/// `approved` 只代表本地 review evidence 完整；它不等于 production cutover authorization。
public enum ReleaseV0110ApprovalWorkflowState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case notRequested = "not-requested"
    case requested
    case reviewing
    case approved
    case rejected
    case expired
    case revoked
}

/// ReleaseV0110ApprovalWorkflowActorReference 表示 requestedBy / reviewedBy / approvedBy 的本地引用。
///
/// 该引用只用于审计链路，不能包含 secret value、endpoint response、broker account 或 order payload。
public struct ReleaseV0110ApprovalWorkflowActorReference: Codable, Equatable, Hashable, Sendable {
    public let reference: String

    public init(_ reference: String) throws {
        let trimmed = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalActorReference", expected: "non-empty", actual: reference)
        }
        self.reference = trimmed
    }
}

/// ReleaseV0110ApprovalWorkflowTransition 是 GH-923 的单条状态迁移审计记录。
///
/// Transition 必须从上一状态连续推进到下一状态，actor / timestamp / reason 都必须留痕。
public struct ReleaseV0110ApprovalWorkflowTransition: Codable, Equatable, Sendable {
    public let fromState: ReleaseV0110ApprovalWorkflowState
    public let toState: ReleaseV0110ApprovalWorkflowState
    public let actor: ReleaseV0110ApprovalWorkflowActorReference
    public let timestamp: Date
    public let reason: String

    public var transitionHeld: Bool {
        Self.isAllowedTransition(from: fromState, to: toState)
            && reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    public var transitionChecksum: String {
        Self.stableTransitionChecksum(
            fromState: fromState,
            toState: toState,
            actor: actor,
            timestamp: timestamp,
            reason: reason
        )
    }

    public init(
        fromState: ReleaseV0110ApprovalWorkflowState,
        toState: ReleaseV0110ApprovalWorkflowState,
        actor: ReleaseV0110ApprovalWorkflowActorReference,
        timestamp: Date,
        reason: String
    ) throws {
        let trimmedReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.isAllowedTransition(from: fromState, to: toState) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "approvalWorkflowTransition",
                expected: "allowed transition",
                actual: "\(fromState.rawValue)->\(toState.rawValue)"
            )
        }
        guard trimmedReason.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowTransitionReason", expected: "non-empty", actual: reason)
        }

        self.fromState = fromState
        self.toState = toState
        self.actor = actor
        self.timestamp = timestamp
        self.reason = trimmedReason
    }

    public static func isAllowedTransition(
        from fromState: ReleaseV0110ApprovalWorkflowState,
        to toState: ReleaseV0110ApprovalWorkflowState
    ) -> Bool {
        switch (fromState, toState) {
        case (.notRequested, .requested),
             (.requested, .reviewing),
             (.requested, .expired),
             (.requested, .revoked),
             (.reviewing, .approved),
             (.reviewing, .rejected),
             (.reviewing, .expired),
             (.reviewing, .revoked),
             (.approved, .expired),
             (.approved, .revoked):
            true
        default:
            false
        }
    }

    public static func stableTransitionChecksum(
        fromState: ReleaseV0110ApprovalWorkflowState,
        toState: ReleaseV0110ApprovalWorkflowState,
        actor: ReleaseV0110ApprovalWorkflowActorReference,
        timestamp: Date,
        reason: String
    ) -> String {
        stableSHA256([
            fromState.rawValue,
            toState.rawValue,
            actor.reference,
            String(timestamp.timeIntervalSince1970),
            reason.trimmingCharacters(in: .whitespacesAndNewlines)
        ])
    }

    private static func stableSHA256(_ parts: [String]) -> String {
        let digest = SHA256.hash(data: Data(parts.joined(separator: "|").utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "sha256:\(digest)"
    }
}

/// ReleaseV0110AuditableApprovalWorkflowStateModel 是 GH-923 的本地审批工作流状态模型。
///
/// Model 只用于保存和导出本地 approval evidence。quorum 不足、过期、撤销或 review 未完成时
/// 必须 fail closed；quorum 满足且未过期的 approved state 也仍然保持 production cutover blocked。
public struct ReleaseV0110AuditableApprovalWorkflowStateModel: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let artifactDescriptor: ProductionReadinessArtifactDescriptor
    public let currentState: ReleaseV0110ApprovalWorkflowState
    public let requestedBy: ReleaseV0110ApprovalWorkflowActorReference?
    public let reviewedBy: [ReleaseV0110ApprovalWorkflowActorReference]
    public let approvedBy: ReleaseV0110ApprovalWorkflowActorReference?
    public let requestedAt: Date?
    public let reviewedAt: Date?
    public let approvedAt: Date?
    public let expiresAt: Date?
    public let revokedReason: String?
    public let transitionHistory: [ReleaseV0110ApprovalWorkflowTransition]
    public let quorumRequired: Int
    public let rolePolicy: ReleaseV0120ApprovalWorkflowRolePolicy
    public let quorumPolicy: ReleaseV0120ApprovalWorkflowQuorumPolicy
    public let boundBundleChecksum: String
    public let expectedBundleChecksum: String
    public let transitionChecksumChain: [String]
    public let evaluatedAt: Date
    public let localEvidenceOnly: Bool
    public let transitionHistoryAuditable: Bool
    public let productionCutoverBlocked: Bool
    public let productionCutoverAuthorized: Bool
    public let orderSubmissionEnabled: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let orderPayloadCreated: Bool
    public let brokerCommandCreated: Bool
    public let productionOMSRuntimeEnabled: Bool
    public let tradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let readinessApprovalConvertedToTradingPermission: Bool
    public let approvalWorkflowBypassEnabled: Bool
    public let validationAnchors: [String]

    public var quorumSatisfied: Bool {
        reviewerQuorumSatisfied && approverQuorumSatisfied
    }

    public var reviewerQuorumSatisfied: Bool {
        quorumRequired == quorumPolicy.reviewerQuorumRequired
            && Set(reviewedBy.map(\.reference)).count >= quorumPolicy.reviewerQuorumRequired
    }

    public var approverQuorumSatisfied: Bool {
        guard let approvedBy else {
            return false
        }
        return quorumPolicy.approverQuorumRequired == 1
            && rolePolicy.approvers.contains(approvedBy)
    }

    public var rolePolicySatisfied: Bool {
        guard let requestedBy else {
            return false
        }
        let reviewerReferences = Set(reviewedBy.map(\.reference))
        let allowedReviewerReferences = Set(rolePolicy.reviewers.map(\.reference))
        let approvedByAllowed = approvedBy.map { rolePolicy.approvers.contains($0) } ?? true

        return rolePolicy.rolePolicyHeld
            && rolePolicy.requester == requestedBy
            && reviewerReferences.isSubset(of: allowedReviewerReferences)
            && approvedByAllowed
            && rolePolicy.separationOfDutiesSatisfied
    }

    public var bundleChecksumBindingHeld: Bool {
        boundBundleChecksum == expectedBundleChecksum
            && ReadinessAssessmentManifestV2.isValidSHA256Checksum(boundBundleChecksum)
    }

    public var transitionChecksumChainHeld: Bool {
        transitionChecksumChain == transitionHistory.map(\.transitionChecksum)
    }

    public var isExpired: Bool {
        currentState == .expired || expiresAt.map { $0 <= evaluatedAt } ?? true
    }

    public var isRevoked: Bool {
        currentState == .revoked || revokedReason != nil
    }

    public var approvalEvidenceComplete: Bool {
        currentState == .approved
            && requestedBy != nil
            && approvedBy != nil
            && requestedAt != nil
            && reviewedAt != nil
            && approvedAt != nil
            && quorumSatisfied
            && rolePolicySatisfied
            && bundleChecksumBindingHeld
            && transitionChecksumChainHeld
            && isExpired == false
            && isRevoked == false
            && transitionHistoryHeld
            && productionCapabilitiesDisabled
    }

    public var failClosed: Bool {
        approvalEvidenceComplete == false
    }

    public var productionCapabilitiesDisabled: Bool {
        productionCutoverBlocked
            && productionCutoverAuthorized == false
            && orderSubmissionEnabled == false
            && testnetOrderSubmissionAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && orderPayloadCreated == false
            && brokerCommandCreated == false
            && productionOMSRuntimeEnabled == false
            && tradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && readinessApprovalConvertedToTradingPermission == false
            && approvalWorkflowBypassEnabled == false
    }

    public var stateModelHeld: Bool {
        issueIDHeld
            && upstreamIssueIDsHeld
            && artifactDescriptor == Self.requiredArtifactDescriptor
            && transitionHistoryHeld
            && transitionChecksumChainHeld
            && quorumRequired > 0
            && quorumPolicy.quorumPolicyHeld
            && rolePolicy.rolePolicyHeld
            && reviewedByReferencesUnique
            && revokedStateHeld
            && bundleChecksumBindingHeld
            && localEvidenceOnly
            && transitionHistoryAuditable
            && productionCapabilitiesDisabled
            && validationAnchorsHeld
    }

    public var transitionHistoryHeld: Bool {
        guard transitionHistory.isEmpty == false else {
            return false
        }
        guard transitionHistory.first?.fromState == .notRequested else {
            return false
        }
        guard transitionHistory.last?.toState == currentState else {
            return false
        }
        guard transitionHistory.allSatisfy(\.transitionHeld) else {
            return false
        }

        for index in transitionHistory.indices.dropFirst() {
            let previous = transitionHistory[transitionHistory.index(before: index)]
            let current = transitionHistory[index]
            guard previous.toState == current.fromState else {
                return false
            }
            guard previous.timestamp <= current.timestamp else {
                return false
            }
        }
        return true
    }

    private var reviewedByReferencesUnique: Bool {
        Set(reviewedBy.map(\.reference)).count == reviewedBy.count
    }

    private var revokedStateHeld: Bool {
        currentState == .revoked
            ? revokedReason?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            : revokedReason == nil
    }

    private var issueIDHeld: Bool {
        issueID.rawValue == "GH-923" || issueID.rawValue == "GH-960"
    }

    private var upstreamIssueIDsHeld: Bool {
        let rawValues = upstreamIssueIDs.map(\.rawValue)
        return rawValues == ["GH-913", "GH-922"] || rawValues == ["GH-951", "GH-959"]
    }

    private var validationAnchorsHeld: Bool {
        validationAnchors == Self.requiredValidationAnchors || validationAnchors == Self.v0120RoleQuorumValidationAnchors
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-923"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-913"), Identifier.constant("GH-922")],
        artifactDescriptor: ProductionReadinessArtifactDescriptor = Self.requiredArtifactDescriptor,
        currentState: ReleaseV0110ApprovalWorkflowState,
        requestedBy: ReleaseV0110ApprovalWorkflowActorReference?,
        reviewedBy: [ReleaseV0110ApprovalWorkflowActorReference],
        approvedBy: ReleaseV0110ApprovalWorkflowActorReference?,
        requestedAt: Date?,
        reviewedAt: Date?,
        approvedAt: Date?,
        expiresAt: Date?,
        revokedReason: String? = nil,
        transitionHistory: [ReleaseV0110ApprovalWorkflowTransition],
        quorumRequired: Int,
        rolePolicy: ReleaseV0120ApprovalWorkflowRolePolicy? = nil,
        quorumPolicy: ReleaseV0120ApprovalWorkflowQuorumPolicy? = nil,
        boundBundleChecksum: String = Self.defaultBoundBundleChecksum,
        expectedBundleChecksum: String? = nil,
        transitionChecksumChain: [String]? = nil,
        evaluatedAt: Date,
        localEvidenceOnly: Bool = true,
        transitionHistoryAuditable: Bool = true,
        productionCutoverBlocked: Bool = true,
        productionCutoverAuthorized: Bool = false,
        orderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        orderPayloadCreated: Bool = false,
        brokerCommandCreated: Bool = false,
        productionOMSRuntimeEnabled: Bool = false,
        tradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        readinessApprovalConvertedToTradingPermission: Bool = false,
        approvalWorkflowBypassEnabled: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let resolvedRolePolicy = try rolePolicy ?? Self.defaultRolePolicy(
            requestedBy: requestedBy,
            reviewedBy: reviewedBy,
            approvedBy: approvedBy
        )
        let resolvedQuorumPolicy = try quorumPolicy ?? ReleaseV0120ApprovalWorkflowQuorumPolicy(
            reviewerQuorumRequired: quorumRequired,
            approverQuorumRequired: approvedBy == nil ? 1 : 1
        )
        let resolvedExpectedBundleChecksum = expectedBundleChecksum ?? boundBundleChecksum
        let resolvedTransitionChecksumChain = transitionChecksumChain ?? transitionHistory.map(\.transitionChecksum)

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.artifactDescriptor = artifactDescriptor
        self.currentState = currentState
        self.requestedBy = requestedBy
        self.reviewedBy = reviewedBy
        self.approvedBy = approvedBy
        self.requestedAt = requestedAt
        self.reviewedAt = reviewedAt
        self.approvedAt = approvedAt
        self.expiresAt = expiresAt
        self.revokedReason = revokedReason?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.transitionHistory = transitionHistory
        self.quorumRequired = quorumRequired
        self.rolePolicy = resolvedRolePolicy
        self.quorumPolicy = resolvedQuorumPolicy
        self.boundBundleChecksum = boundBundleChecksum
        self.expectedBundleChecksum = resolvedExpectedBundleChecksum
        self.transitionChecksumChain = resolvedTransitionChecksumChain
        self.evaluatedAt = evaluatedAt
        self.localEvidenceOnly = localEvidenceOnly
        self.transitionHistoryAuditable = transitionHistoryAuditable
        self.productionCutoverBlocked = productionCutoverBlocked
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.orderSubmissionEnabled = orderSubmissionEnabled
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.orderPayloadCreated = orderPayloadCreated
        self.brokerCommandCreated = brokerCommandCreated
        self.productionOMSRuntimeEnabled = productionOMSRuntimeEnabled
        self.tradingButtonEnabled = tradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.readinessApprovalConvertedToTradingPermission = readinessApprovalConvertedToTradingPermission
        self.approvalWorkflowBypassEnabled = approvalWorkflowBypassEnabled
        self.validationAnchors = validationAnchors

        try Self.validate(
            model: self,
            artifactDescriptor: artifactDescriptor,
            upstreamIssueIDs: upstreamIssueIDs,
            quorumRequired: quorumRequired,
            rolePolicy: resolvedRolePolicy,
            quorumPolicy: resolvedQuorumPolicy,
            boundBundleChecksum: boundBundleChecksum,
            expectedBundleChecksum: resolvedExpectedBundleChecksum,
            transitionChecksumChain: resolvedTransitionChecksumChain,
            validationAnchors: validationAnchors
        )
    }

    public static let requiredValidationAnchors = ReleaseV0110AuditableApprovalWorkflowAnchors.validationAnchors
    public static let v0120RoleQuorumValidationAnchors = ReleaseV0120ApprovalRoleQuorumSeparationAnchors.validationAnchors
    public static let defaultBoundBundleChecksum = "sha256:\(String(repeating: "9", count: 64))"

    public static let requiredArtifactDescriptor: ProductionReadinessArtifactDescriptor = {
        do {
            return try ProductionReadinessArtifactDescriptor(
                artifactID: Identifier.constant("gh-923-approval-workflow-transitions"),
                relativePath: "approval/approval_workflow_transitions.json",
                artifactType: .jsonEvidence,
                staleAfterSeconds: 86_400
            )
        } catch {
            preconditionFailure("GH-923 approval workflow descriptor must be valid: \(error)")
        }
    }()

    public static func approvedEvidenceFixture(
        evaluatedAt: Date = Date(timeIntervalSince1970: 1_800_000_000)
    ) throws -> ReleaseV0110AuditableApprovalWorkflowStateModel {
        let requestedAt = evaluatedAt.addingTimeInterval(-600)
        let reviewedAt = evaluatedAt.addingTimeInterval(-300)
        let approvedAt = evaluatedAt.addingTimeInterval(-120)
        let expiresAt = evaluatedAt.addingTimeInterval(3_600)
        let requester = try ReleaseV0110ApprovalWorkflowActorReference("operator/requester")
        let reviewerA = try ReleaseV0110ApprovalWorkflowActorReference("operator/reviewer-a")
        let reviewerB = try ReleaseV0110ApprovalWorkflowActorReference("operator/reviewer-b")
        let approver = try ReleaseV0110ApprovalWorkflowActorReference("operator/approver")

        return try ReleaseV0110AuditableApprovalWorkflowStateModel(
            currentState: .approved,
            requestedBy: requester,
            reviewedBy: [reviewerA, reviewerB],
            approvedBy: approver,
            requestedAt: requestedAt,
            reviewedAt: reviewedAt,
            approvedAt: approvedAt,
            expiresAt: expiresAt,
            transitionHistory: [
                try ReleaseV0110ApprovalWorkflowTransition(
                    fromState: .notRequested,
                    toState: .requested,
                    actor: requester,
                    timestamp: requestedAt,
                    reason: "operator requested production readiness approval evidence"
                ),
                try ReleaseV0110ApprovalWorkflowTransition(
                    fromState: .requested,
                    toState: .reviewing,
                    actor: reviewerA,
                    timestamp: reviewedAt,
                    reason: "review quorum collection started"
                ),
                try ReleaseV0110ApprovalWorkflowTransition(
                    fromState: .reviewing,
                    toState: .approved,
                    actor: approver,
                    timestamp: approvedAt,
                    reason: "local readiness evidence approved for record only"
                )
            ],
            quorumRequired: 2,
            evaluatedAt: evaluatedAt
        )
    }

    public static func missingQuorumFixture(
        evaluatedAt: Date = Date(timeIntervalSince1970: 1_800_000_000)
    ) throws -> ReleaseV0110AuditableApprovalWorkflowStateModel {
        let approved = try approvedEvidenceFixture(evaluatedAt: evaluatedAt)
        return try ReleaseV0110AuditableApprovalWorkflowStateModel(
            currentState: approved.currentState,
            requestedBy: approved.requestedBy,
            reviewedBy: Array(approved.reviewedBy.prefix(1)),
            approvedBy: approved.approvedBy,
            requestedAt: approved.requestedAt,
            reviewedAt: approved.reviewedAt,
            approvedAt: approved.approvedAt,
            expiresAt: approved.expiresAt,
            transitionHistory: approved.transitionHistory,
            quorumRequired: 2,
            evaluatedAt: evaluatedAt
        )
    }

    public static func revokedFixture(
        evaluatedAt: Date = Date(timeIntervalSince1970: 1_800_000_000)
    ) throws -> ReleaseV0110AuditableApprovalWorkflowStateModel {
        let approved = try approvedEvidenceFixture(evaluatedAt: evaluatedAt)
        let revoker = try ReleaseV0110ApprovalWorkflowActorReference("operator/revoker")
        let revokedAt = evaluatedAt.addingTimeInterval(-30)
        return try ReleaseV0110AuditableApprovalWorkflowStateModel(
            currentState: .revoked,
            requestedBy: approved.requestedBy,
            reviewedBy: approved.reviewedBy,
            approvedBy: approved.approvedBy,
            requestedAt: approved.requestedAt,
            reviewedAt: approved.reviewedAt,
            approvedAt: approved.approvedAt,
            expiresAt: approved.expiresAt,
            revokedReason: "operator revoked approval evidence before production cutover gate",
            transitionHistory: approved.transitionHistory + [
                try ReleaseV0110ApprovalWorkflowTransition(
                    fromState: .approved,
                    toState: .revoked,
                    actor: revoker,
                    timestamp: revokedAt,
                    reason: "approval evidence revoked"
                )
            ],
            quorumRequired: 2,
            evaluatedAt: evaluatedAt
        )
    }

    public static func v0120ApprovedEvidenceFixture(
        evaluatedAt: Date = Date(timeIntervalSince1970: 1_812_700_000),
        boundBundleChecksum: String = defaultBoundBundleChecksum
    ) throws -> ReleaseV0110AuditableApprovalWorkflowStateModel {
        let requestedAt = evaluatedAt.addingTimeInterval(-600)
        let reviewedAt = evaluatedAt.addingTimeInterval(-300)
        let approvedAt = evaluatedAt.addingTimeInterval(-120)
        let expiresAt = evaluatedAt.addingTimeInterval(3_600)
        let requester = try ReleaseV0110ApprovalWorkflowActorReference("operator/requester")
        let reviewerA = try ReleaseV0110ApprovalWorkflowActorReference("operator/reviewer-a")
        let reviewerB = try ReleaseV0110ApprovalWorkflowActorReference("operator/reviewer-b")
        let approver = try ReleaseV0110ApprovalWorkflowActorReference("operator/approver")
        let revoker = try ReleaseV0110ApprovalWorkflowActorReference("operator/revoker")
        let transitions = [
            try ReleaseV0110ApprovalWorkflowTransition(
                fromState: .notRequested,
                toState: .requested,
                actor: requester,
                timestamp: requestedAt,
                reason: "operator requested v0.12 approval evidence"
            ),
            try ReleaseV0110ApprovalWorkflowTransition(
                fromState: .requested,
                toState: .reviewing,
                actor: reviewerA,
                timestamp: reviewedAt,
                reason: "review quorum collection started"
            ),
            try ReleaseV0110ApprovalWorkflowTransition(
                fromState: .reviewing,
                toState: .approved,
                actor: approver,
                timestamp: approvedAt,
                reason: "local readiness evidence approved for record only"
            )
        ]

        return try ReleaseV0110AuditableApprovalWorkflowStateModel(
            issueID: Identifier.constant("GH-960"),
            upstreamIssueIDs: [Identifier.constant("GH-951"), Identifier.constant("GH-959")],
            currentState: .approved,
            requestedBy: requester,
            reviewedBy: [reviewerA, reviewerB],
            approvedBy: approver,
            requestedAt: requestedAt,
            reviewedAt: reviewedAt,
            approvedAt: approvedAt,
            expiresAt: expiresAt,
            transitionHistory: transitions,
            quorumRequired: 2,
            rolePolicy: try ReleaseV0120ApprovalWorkflowRolePolicy(
                requester: requester,
                reviewers: [reviewerA, reviewerB],
                approvers: [approver],
                revokers: [revoker]
            ),
            quorumPolicy: try ReleaseV0120ApprovalWorkflowQuorumPolicy(
                reviewerQuorumRequired: 2,
                approverQuorumRequired: 1
            ),
            boundBundleChecksum: boundBundleChecksum,
            evaluatedAt: evaluatedAt,
            validationAnchors: Self.v0120RoleQuorumValidationAnchors
        )
    }

    public func canonicalEvidenceData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try ProductionReadinessArtifactStore.canonicalJSONData(for: encoder.encode(self))
    }

    @discardableResult
    public func writeEvidence(
        to store: ProductionReadinessArtifactStore,
        modifiedAt: Date
    ) throws -> ProductionReadinessArtifactRecord {
        try store.writeArtifact(
            descriptor: artifactDescriptor,
            data: canonicalEvidenceData(),
            modifiedAt: modifiedAt
        )
    }
}

private extension ReleaseV0110AuditableApprovalWorkflowStateModel {
    static func defaultRolePolicy(
        requestedBy: ReleaseV0110ApprovalWorkflowActorReference?,
        reviewedBy: [ReleaseV0110ApprovalWorkflowActorReference],
        approvedBy: ReleaseV0110ApprovalWorkflowActorReference?
    ) throws -> ReleaseV0120ApprovalWorkflowRolePolicy {
        let requester = try requestedBy ?? ReleaseV0110ApprovalWorkflowActorReference("operator/requester")
        let reviewers = reviewedBy.isEmpty
            ? [try ReleaseV0110ApprovalWorkflowActorReference("operator/reviewer")]
            : reviewedBy
        let approver = try approvedBy ?? ReleaseV0110ApprovalWorkflowActorReference("operator/approver")
        let revoker = try ReleaseV0110ApprovalWorkflowActorReference("operator/revoker")

        return try ReleaseV0120ApprovalWorkflowRolePolicy(
            requester: requester,
            reviewers: reviewers,
            approvers: [approver],
            revokers: [revoker]
        )
    }

    static func validate(
        model: ReleaseV0110AuditableApprovalWorkflowStateModel,
        artifactDescriptor: ProductionReadinessArtifactDescriptor,
        upstreamIssueIDs: [Identifier],
        quorumRequired: Int,
        rolePolicy: ReleaseV0120ApprovalWorkflowRolePolicy,
        quorumPolicy: ReleaseV0120ApprovalWorkflowQuorumPolicy,
        boundBundleChecksum: String,
        expectedBundleChecksum: String,
        transitionChecksumChain: [String],
        validationAnchors: [String]
    ) throws {
        guard artifactDescriptor == requiredArtifactDescriptor else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "approvalWorkflowArtifactDescriptor",
                expected: requiredArtifactDescriptor.relativePath,
                actual: artifactDescriptor.relativePath
            )
        }
        guard model.upstreamIssueIDsHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "approvalWorkflowUpstreamIssueIDs",
                expected: "GH-913,GH-922 or GH-951,GH-959",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard quorumRequired > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowQuorumRequired", expected: ">0", actual: "\(quorumRequired)")
        }
        guard model.validationAnchorsHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "approvalWorkflowValidationAnchors",
                expected: "\(requiredValidationAnchors.joined(separator: ",")) or \(v0120RoleQuorumValidationAnchors.joined(separator: ","))",
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard rolePolicy.rolePolicyHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowRolePolicy", expected: "held", actual: "invalid")
        }
        guard quorumPolicy.quorumPolicyHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowQuorumPolicy", expected: "held", actual: "invalid")
        }
        guard ReadinessAssessmentManifestV2.isValidSHA256Checksum(boundBundleChecksum) else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowBoundBundleChecksum", expected: "sha256:<64 lowercase hex>", actual: boundBundleChecksum)
        }
        guard ReadinessAssessmentManifestV2.isValidSHA256Checksum(expectedBundleChecksum) else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowExpectedBundleChecksum", expected: "sha256:<64 lowercase hex>", actual: expectedBundleChecksum)
        }
        guard model.transitionHistoryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowTransitionHistory", expected: "contiguous audited transitions", actual: "invalid")
        }
        guard model.reviewedByReferencesUnique else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowReviewedBy", expected: "unique references", actual: "duplicate references")
        }
        guard model.revokedStateHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowRevokedReason", expected: "present only for revoked state", actual: model.revokedReason ?? "nil")
        }
        guard model.localEvidenceOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowLocalEvidenceOnly", expected: "true", actual: "false")
        }
        guard model.transitionHistoryAuditable else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "approvalWorkflowTransitionHistoryAuditable", expected: "true", actual: "false")
        }
        guard model.productionCutoverBlocked else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "productionCutoverBlocked", expected: "true", actual: "false")
        }
        try validateForbiddenFlags(model)
    }

    static func validateForbiddenFlags(_ model: ReleaseV0110AuditableApprovalWorkflowStateModel) throws {
        let forbiddenFlags = [
            ("productionCutoverAuthorized", model.productionCutoverAuthorized),
            ("orderSubmissionEnabled", model.orderSubmissionEnabled),
            ("testnetOrderSubmissionAllowed", model.testnetOrderSubmissionAllowed),
            ("productionTradingEnabledByDefault", model.productionTradingEnabledByDefault),
            ("productionSecretRead", model.productionSecretRead),
            ("productionEndpointConnected", model.productionEndpointConnected),
            ("brokerEndpointConnected", model.brokerEndpointConnected),
            ("orderPayloadCreated", model.orderPayloadCreated),
            ("brokerCommandCreated", model.brokerCommandCreated),
            ("productionOMSRuntimeEnabled", model.productionOMSRuntimeEnabled),
            ("tradingButtonEnabled", model.tradingButtonEnabled),
            ("orderFormEnabled", model.orderFormEnabled),
            ("liveCommandEnabled", model.liveCommandEnabled),
            ("readinessApprovalConvertedToTradingPermission", model.readinessApprovalConvertedToTradingPermission),
            ("approvalWorkflowBypassEnabled", model.approvalWorkflowBypassEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
