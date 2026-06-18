import DomainModel
import Foundation

/// ReleaseV0100CutoverApprovalWorkflowArtifactKind 固定 GH-888 的审批 workflow evidence 文件名。
public enum ReleaseV0100CutoverApprovalWorkflowArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case cutoverApprovalWorkflow = "cutover_approval_workflow.json"
}

/// ReleaseV0100CutoverApprovalState 枚举 GH-888 必须能表达的生产切换审批状态。
public enum ReleaseV0100CutoverApprovalState: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case requested
    case reviewing
    case approved
    case rejected
    case expired
    case revoked
}

/// ReleaseV0100CutoverApprovalWorkflowRequirement 固定 GH-888 的验收要求。
public enum ReleaseV0100CutoverApprovalWorkflowRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case approvalWorkflowEvidenceExists = "cutover_approval_workflow.json evidence exists"
    case approvalStatesRepresented = "requested/reviewing/approved/rejected/expired/revoked represented"
    case approvedStateIsReviewEvidenceOnly = "approved state is review evidence only"
    case productionCutoverAuthorizedFalse = "productionCutoverAuthorized false"
    case orderSubmissionEnabledFalse = "orderSubmissionEnabled false"
    case productionTradingEnabledFalse = "productionTradingEnabled false"
    case productionCutoverBlocked = "production cutover blocked"
    case noSecretValueTrue = "no_secret_value true"
    case noOrderPayloadTrue = "no_order_payload true"
}

/// ReleaseV0100CutoverApprovalWorkflowForbiddenCapability 枚举 GH-888 审批 workflow 禁止转换出的能力。
public enum ReleaseV0100CutoverApprovalWorkflowForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionCutoverAuthorization = "production cutover authorization"
    case orderSubmissionEnabled = "order submission enabled"
    case productionTradingEnabled = "production trading enabled"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case productionSecretValueRead = "production secret value read"
    case testnetOrderSubmissionEnabled = "testnet order submission enabled"
    case productionOrderSubmissionEnabled = "production order submission enabled"
    case orderPayloadCreated = "order payload created"
    case brokerCommandCreated = "broker command created"
    case productionOMSRuntimeEnabled = "production OMS runtime enabled"
    case tradingButtonVisible = "trading button visible"
    case orderFormVisible = "order form visible"
    case liveCommandEnabled = "live command enabled"
    case readinessApprovalConvertedToTradingPermission = "readiness approval converted to trading permission"
    case approvalWorkflowBypassEnabled = "approval workflow bypass enabled"
}

/// ReleaseV0100CutoverApprovalWorkflowChecksum 提供 GH-888 reference-only workflow checksum 常量。
///
/// 这些 checksum 只标识 deterministic evidence，不来自 secret、endpoint response、broker response 或 order payload。
public enum ReleaseV0100CutoverApprovalWorkflowChecksum {
    public static let workflow = "sha256:7517080ebc392b2a610f4ac56fca227565e810e310529a67af167b819d7c5138"

    public static func stateChecksum(for state: ReleaseV0100CutoverApprovalState) -> String {
        let nibble: String
        switch state {
        case .requested:
            nibble = "1"
        case .reviewing:
            nibble = "2"
        case .approved:
            nibble = "3"
        case .rejected:
            nibble = "4"
        case .expired:
            nibble = "5"
        case .revoked:
            nibble = "6"
        }

        return "sha256:" + String(repeating: nibble, count: 64)
    }
}

/// ReleaseV0100CutoverApprovalStateEvidence 是 GH-888 workflow 中的单个审批状态 evidence row。
///
/// 即使 state 为 approved，它也只代表人工 review 状态已记录；不会变成 cutover、order submission
/// 或 production trading permission。
public struct ReleaseV0100CutoverApprovalStateEvidence: Codable, Equatable, Sendable {
    public let state: ReleaseV0100CutoverApprovalState
    public let checksum: String
    public let represented: Bool
    public let reviewEvidenceOnly: Bool
    public let productionCutoverAuthorized: Bool
    public let orderSubmissionEnabled: Bool
    public let productionTradingEnabled: Bool

    public var stateHeld: Bool {
        checksum == ReleaseV0100CutoverApprovalWorkflowChecksum.stateChecksum(for: state)
            && represented
            && reviewEvidenceOnly
            && productionCutoverAuthorized == false
            && orderSubmissionEnabled == false
            && productionTradingEnabled == false
    }

    public init(
        state: ReleaseV0100CutoverApprovalState,
        checksum: String? = nil,
        represented: Bool = true,
        reviewEvidenceOnly: Bool = true,
        productionCutoverAuthorized: Bool = false,
        orderSubmissionEnabled: Bool = false,
        productionTradingEnabled: Bool = false
    ) throws {
        let resolvedChecksum = checksum ?? ReleaseV0100CutoverApprovalWorkflowChecksum.stateChecksum(for: state)
        guard resolvedChecksum == ReleaseV0100CutoverApprovalWorkflowChecksum.stateChecksum(for: state) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "cutoverApprovalStateChecksum",
                expected: ReleaseV0100CutoverApprovalWorkflowChecksum.stateChecksum(for: state),
                actual: resolvedChecksum
            )
        }
        guard represented else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "cutoverApprovalStateRepresented", expected: "true", actual: "false")
        }
        guard reviewEvidenceOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "cutoverApprovalReviewEvidenceOnly", expected: "true", actual: "false")
        }
        guard productionCutoverAuthorized == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionCutoverAuthorized")
        }
        guard orderSubmissionEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("orderSubmissionEnabled")
        }
        guard productionTradingEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionTradingEnabled")
        }

        self.state = state
        self.checksum = resolvedChecksum
        self.represented = represented
        self.reviewEvidenceOnly = reviewEvidenceOnly
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.orderSubmissionEnabled = orderSubmissionEnabled
        self.productionTradingEnabled = productionTradingEnabled
    }
}

/// ReleaseV0100CutoverApprovalWorkflowArtifact 是 GH-888 的 cutover_approval_workflow.json row。
///
/// Artifact 只证明 workflow evidence 文件、sha256 checksum 和 no-secret / no-order 边界。它不是
/// production cutover authorization，也不会触发 production endpoint、broker 或 OMS。
public struct ReleaseV0100CutoverApprovalWorkflowArtifact: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100CutoverApprovalWorkflowArtifactKind
    public let fileName: String
    public let workflowChecksum: String
    public let evidenceExists: Bool
    public let noSecretValue: Bool
    public let noOrderPayload: Bool
    public let containsBrokerOrAccountResponse: Bool
    public let producedByEndpointConnection: Bool
    public let containsOrderPayload: Bool

    public var artifactHeld: Bool {
        fileName == kind.rawValue
            && workflowChecksum == ReleaseV0100CutoverApprovalWorkflowChecksum.workflow
            && evidenceExists
            && noSecretValue
            && noOrderPayload
            && containsBrokerOrAccountResponse == false
            && producedByEndpointConnection == false
            && containsOrderPayload == false
    }

    public init(
        kind: ReleaseV0100CutoverApprovalWorkflowArtifactKind = .cutoverApprovalWorkflow,
        fileName: String? = nil,
        workflowChecksum: String = ReleaseV0100CutoverApprovalWorkflowChecksum.workflow,
        evidenceExists: Bool = true,
        noSecretValue: Bool = true,
        noOrderPayload: Bool = true,
        containsBrokerOrAccountResponse: Bool = false,
        producedByEndpointConnection: Bool = false,
        containsOrderPayload: Bool = false
    ) throws {
        let resolvedFileName = fileName ?? kind.rawValue
        guard resolvedFileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "cutoverApprovalWorkflowFile", expected: kind.rawValue, actual: resolvedFileName)
        }
        guard workflowChecksum == ReleaseV0100CutoverApprovalWorkflowChecksum.workflow else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "cutoverApprovalWorkflowChecksum",
                expected: ReleaseV0100CutoverApprovalWorkflowChecksum.workflow,
                actual: workflowChecksum
            )
        }
        guard evidenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "cutoverApprovalWorkflowExists", expected: "true", actual: "false")
        }
        guard noSecretValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "noSecretValue", expected: "true", actual: "false")
        }
        guard noOrderPayload else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "noOrderPayload", expected: "true", actual: "false")
        }
        guard containsBrokerOrAccountResponse == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("containsBrokerOrAccountResponse")
        }
        guard producedByEndpointConnection == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("producedByEndpointConnection")
        }
        guard containsOrderPayload == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("containsOrderPayload")
        }

        self.kind = kind
        self.fileName = resolvedFileName
        self.workflowChecksum = workflowChecksum
        self.evidenceExists = evidenceExists
        self.noSecretValue = noSecretValue
        self.noOrderPayload = noOrderPayload
        self.containsBrokerOrAccountResponse = containsBrokerOrAccountResponse
        self.producedByEndpointConnection = producedByEndpointConnection
        self.containsOrderPayload = containsOrderPayload
    }
}

/// ReleaseV0100CutoverApprovalWorkflow 是 GH-888 的 production cutover approval workflow 合同。
///
/// Workflow 可以表达 requested、reviewing、approved、rejected、expired 和 revoked，但 approved 只是
/// readiness review evidence。它不会授权 production cutover，不启用 order submission，也不启用 production trading。
public struct ReleaseV0100CutoverApprovalWorkflow: Codable, Equatable, Sendable {
    public let workflowID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let evidenceArtifact: ReleaseV0100CutoverApprovalWorkflowArtifact
    public let approvalStates: [ReleaseV0100CutoverApprovalStateEvidence]
    public let requirements: [ReleaseV0100CutoverApprovalWorkflowRequirement]
    public let forbiddenCapabilities: [ReleaseV0100CutoverApprovalWorkflowForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let workflowChecksum: String
    public let previousProductionReadinessBundleHeld: Bool
    public let approvalStateEvidenceCanRepresentApproved: Bool
    public let approvalStateEvidenceCanRepresentRejected: Bool
    public let productionCutoverBlocked: Bool
    public let productionCutoverAuthorized: Bool
    public let orderSubmissionEnabled: Bool
    public let productionTradingEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionSecretValueRead: Bool
    public let testnetOrderSubmissionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let orderPayloadCreated: Bool
    public let brokerCommandCreated: Bool
    public let productionOMSRuntimeEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandEnabled: Bool
    public let readinessApprovalConvertedToTradingPermission: Bool
    public let approvalWorkflowBypassEnabled: Bool

    public var workflowHeld: Bool {
        issueID.rawValue == "GH-888"
            && upstreamIssueID.rawValue == "GH-887"
            && downstreamIssueID.rawValue == "GH-889"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && evidenceArtifact == Self.requiredEvidenceArtifact
            && approvalStates == Self.requiredApprovalStates
            && approvalStates.allSatisfy(\.stateHeld)
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && workflowChecksum == ReleaseV0100CutoverApprovalWorkflowChecksum.workflow
            && previousProductionReadinessBundleHeld
            && approvalStateEvidenceCanRepresentApproved
            && approvalStateEvidenceCanRepresentRejected
            && productionCutoverBlocked
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        productionCutoverAuthorized == false
            && orderSubmissionEnabled == false
            && productionTradingEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionSecretValueRead == false
            && testnetOrderSubmissionEnabled == false
            && productionOrderSubmissionEnabled == false
            && orderPayloadCreated == false
            && brokerCommandCreated == false
            && productionOMSRuntimeEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandEnabled == false
            && readinessApprovalConvertedToTradingPermission == false
            && approvalWorkflowBypassEnabled == false
    }

    public init(
        workflowID: Identifier = Identifier.constant("gh-888-cutover-approval-workflow"),
        issueID: Identifier = Identifier.constant("GH-888"),
        upstreamIssueID: Identifier = Identifier.constant("GH-887"),
        downstreamIssueID: Identifier = Identifier.constant("GH-889"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        evidenceArtifact: ReleaseV0100CutoverApprovalWorkflowArtifact = Self.requiredEvidenceArtifact,
        approvalStates: [ReleaseV0100CutoverApprovalStateEvidence] = Self.requiredApprovalStates,
        requirements: [ReleaseV0100CutoverApprovalWorkflowRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100CutoverApprovalWorkflowForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        workflowChecksum: String = ReleaseV0100CutoverApprovalWorkflowChecksum.workflow,
        previousProductionReadinessBundleHeld: Bool = true,
        approvalStateEvidenceCanRepresentApproved: Bool = true,
        approvalStateEvidenceCanRepresentRejected: Bool = true,
        productionCutoverBlocked: Bool = true,
        productionCutoverAuthorized: Bool = false,
        orderSubmissionEnabled: Bool = false,
        productionTradingEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionSecretValueRead: Bool = false,
        testnetOrderSubmissionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        orderPayloadCreated: Bool = false,
        brokerCommandCreated: Bool = false,
        productionOMSRuntimeEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandEnabled: Bool = false,
        readinessApprovalConvertedToTradingPermission: Bool = false,
        approvalWorkflowBypassEnabled: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            evidenceArtifact: evidenceArtifact,
            approvalStates: approvalStates,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands,
            workflowChecksum: workflowChecksum
        )
        try Self.validateRequiredTrueFlags(
            previousProductionReadinessBundleHeld: previousProductionReadinessBundleHeld,
            approvalStateEvidenceCanRepresentApproved: approvalStateEvidenceCanRepresentApproved,
            approvalStateEvidenceCanRepresentRejected: approvalStateEvidenceCanRepresentRejected,
            productionCutoverBlocked: productionCutoverBlocked
        )
        try Self.validateForbiddenFlags(
            productionCutoverAuthorized: productionCutoverAuthorized,
            orderSubmissionEnabled: orderSubmissionEnabled,
            productionTradingEnabled: productionTradingEnabled,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionSecretValueRead: productionSecretValueRead,
            testnetOrderSubmissionEnabled: testnetOrderSubmissionEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            orderPayloadCreated: orderPayloadCreated,
            brokerCommandCreated: brokerCommandCreated,
            productionOMSRuntimeEnabled: productionOMSRuntimeEnabled,
            tradingButtonVisible: tradingButtonVisible,
            orderFormVisible: orderFormVisible,
            liveCommandEnabled: liveCommandEnabled,
            readinessApprovalConvertedToTradingPermission: readinessApprovalConvertedToTradingPermission,
            approvalWorkflowBypassEnabled: approvalWorkflowBypassEnabled
        )

        self.workflowID = workflowID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.evidenceArtifact = evidenceArtifact
        self.approvalStates = approvalStates
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.workflowChecksum = workflowChecksum
        self.previousProductionReadinessBundleHeld = previousProductionReadinessBundleHeld
        self.approvalStateEvidenceCanRepresentApproved = approvalStateEvidenceCanRepresentApproved
        self.approvalStateEvidenceCanRepresentRejected = approvalStateEvidenceCanRepresentRejected
        self.productionCutoverBlocked = productionCutoverBlocked
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.orderSubmissionEnabled = orderSubmissionEnabled
        self.productionTradingEnabled = productionTradingEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionSecretValueRead = productionSecretValueRead
        self.testnetOrderSubmissionEnabled = testnetOrderSubmissionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.orderPayloadCreated = orderPayloadCreated
        self.brokerCommandCreated = brokerCommandCreated
        self.productionOMSRuntimeEnabled = productionOMSRuntimeEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandEnabled = liveCommandEnabled
        self.readinessApprovalConvertedToTradingPermission = readinessApprovalConvertedToTradingPermission
        self.approvalWorkflowBypassEnabled = approvalWorkflowBypassEnabled
    }

    public static func deterministicFixture() throws -> ReleaseV0100CutoverApprovalWorkflow {
        try ReleaseV0100CutoverApprovalWorkflow()
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredRequirements = ReleaseV0100CutoverApprovalWorkflowRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100CutoverApprovalWorkflowForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-011-CUTOVER-APPROVAL-WORKFLOW",
        "V0100-011-CUTOVER-APPROVAL-WORKFLOW-JSON",
        "V0100-011-APPROVAL-STATES-REPRESENTED",
        "V0100-011-APPROVED-NOT-CUTOVER-AUTHORIZED",
        "V0100-011-APPROVED-NOT-ORDER-SUBMISSION-ENABLED",
        "V0100-011-APPROVED-NOT-PRODUCTION-TRADING-ENABLED",
        "V0100-011-PRODUCTION-CUTOVER-AUTHORIZED-FALSE",
        "V0100-011-ORDER-SUBMISSION-ENABLED-FALSE",
        "V0100-011-PRODUCTION-TRADING-ENABLED-FALSE",
        "V0100-011-PRODUCTION-CAPABILITIES-DISABLED",
        "GH-888-VERIFY-V0100-CUTOVER-APPROVAL-WORKFLOW",
        "TVM-RELEASE-V0100-CUTOVER-APPROVAL-WORKFLOW"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH888CutoverApprovalWorkflowRepresentsApprovalWithoutTradingPermission",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredEvidenceArtifact: ReleaseV0100CutoverApprovalWorkflowArtifact = {
        do {
            return try ReleaseV0100CutoverApprovalWorkflowArtifact()
        } catch {
            preconditionFailure("GH-888 cutover approval workflow artifact must be valid: \(error)")
        }
    }()

    public static let requiredApprovalStates: [ReleaseV0100CutoverApprovalStateEvidence] = {
        do {
            return try ReleaseV0100CutoverApprovalState.allCases.map {
                try ReleaseV0100CutoverApprovalStateEvidence(state: $0)
            }
        } catch {
            preconditionFailure("GH-888 cutover approval states must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100CutoverApprovalWorkflow {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        evidenceArtifact: ReleaseV0100CutoverApprovalWorkflowArtifact,
        approvalStates: [ReleaseV0100CutoverApprovalStateEvidence],
        requirements: [ReleaseV0100CutoverApprovalWorkflowRequirement],
        forbiddenCapabilities: [ReleaseV0100CutoverApprovalWorkflowForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String],
        workflowChecksum: String
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("evidenceArtifact", evidenceArtifact == requiredEvidenceArtifact, requiredEvidenceArtifact.fileName, evidenceArtifact.fileName),
            ("approvalStates", approvalStates == requiredApprovalStates, requiredApprovalStates.map { $0.state.rawValue }.joined(separator: ","), approvalStates.map { $0.state.rawValue }.joined(separator: ",")),
            ("requirements", requirements == requiredRequirements, requiredRequirements.map(\.rawValue).joined(separator: ","), requirements.map(\.rawValue).joined(separator: ",")),
            ("forbiddenCapabilities", forbiddenCapabilities == requiredForbiddenCapabilities, requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","), forbiddenCapabilities.map(\.rawValue).joined(separator: ",")),
            ("validationAnchors", validationAnchors == requiredValidationAnchors, requiredValidationAnchors.joined(separator: ","), validationAnchors.joined(separator: ",")),
            ("requiredValidationCommands", requiredValidationCommands == Self.requiredValidationCommands, Self.requiredValidationCommands.joined(separator: ","), requiredValidationCommands.joined(separator: ",")),
            ("workflowChecksum", workflowChecksum == ReleaseV0100CutoverApprovalWorkflowChecksum.workflow, ReleaseV0100CutoverApprovalWorkflowChecksum.workflow, workflowChecksum)
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrueFlags(
        previousProductionReadinessBundleHeld: Bool,
        approvalStateEvidenceCanRepresentApproved: Bool,
        approvalStateEvidenceCanRepresentRejected: Bool,
        productionCutoverBlocked: Bool
    ) throws {
        let requiredTrueFlags = [
            ("previousProductionReadinessBundleHeld", previousProductionReadinessBundleHeld),
            ("approvalStateEvidenceCanRepresentApproved", approvalStateEvidenceCanRepresentApproved),
            ("approvalStateEvidenceCanRepresentRejected", approvalStateEvidenceCanRepresentRejected),
            ("productionCutoverBlocked", productionCutoverBlocked)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        productionCutoverAuthorized: Bool,
        orderSubmissionEnabled: Bool,
        productionTradingEnabled: Bool,
        productionEndpointConnectionEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionSecretValueRead: Bool,
        testnetOrderSubmissionEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        orderPayloadCreated: Bool,
        brokerCommandCreated: Bool,
        productionOMSRuntimeEnabled: Bool,
        tradingButtonVisible: Bool,
        orderFormVisible: Bool,
        liveCommandEnabled: Bool,
        readinessApprovalConvertedToTradingPermission: Bool,
        approvalWorkflowBypassEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("orderSubmissionEnabled", orderSubmissionEnabled),
            ("productionTradingEnabled", productionTradingEnabled),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionSecretValueRead", productionSecretValueRead),
            ("testnetOrderSubmissionEnabled", testnetOrderSubmissionEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("orderPayloadCreated", orderPayloadCreated),
            ("brokerCommandCreated", brokerCommandCreated),
            ("productionOMSRuntimeEnabled", productionOMSRuntimeEnabled),
            ("tradingButtonVisible", tradingButtonVisible),
            ("orderFormVisible", orderFormVisible),
            ("liveCommandEnabled", liveCommandEnabled),
            ("readinessApprovalConvertedToTradingPermission", readinessApprovalConvertedToTradingPermission),
            ("approvalWorkflowBypassEnabled", approvalWorkflowBypassEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
