import DomainModel
import Foundation

/// ReleaseV0100IncidentRollbackReadinessArtifactKind 固定 GH-889 的 incident / rollback evidence 文件名。
public enum ReleaseV0100IncidentRollbackReadinessArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case incidentRollbackReadiness = "incident_rollback_readiness.json"
}

/// ReleaseV0100IncidentRollbackClassification 枚举 GH-889 runbook 必须覆盖的事件分类。
public enum ReleaseV0100IncidentRollbackClassification: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case monitorAnomaly = "monitor anomaly"
    case credentialExposureSuspected = "credential exposure suspected"
    case endpointPolicyDrift = "endpoint policy drift"
    case riskLimitBreach = "risk limit breach"
    case commandSurfaceRegression = "command surface regression"
    case readinessEvidenceMismatch = "readiness evidence mismatch"
}

/// ReleaseV0100IncidentRollbackReadinessSection 枚举 GH-889 operator runbook 必须包含的章节。
public enum ReleaseV0100IncidentRollbackReadinessSection: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case incidentClassification = "incident classification"
    case stopProcedure = "stop procedure"
    case rollbackProcedure = "rollback procedure"
    case operatorChain = "operator chain"
    case evidenceExport = "evidence export"
    case postIncidentAudit = "post-incident audit"
    case killSwitchChecklist = "kill switch checklist"
    case noTradeChecklist = "no-trade checklist"
}

/// ReleaseV0100IncidentRollbackReadinessRequirement 固定 GH-889 的 runbook 验收要求。
public enum ReleaseV0100IncidentRollbackReadinessRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionReadinessRunbookExists = "docs/operators/release-v0.10.0-production-readiness-runbook.md exists"
    case incidentRollbackReadinessEvidenceExists = "incident_rollback_readiness.json evidence exists"
    case incidentClassificationCovered = "incident classification covered"
    case stopProcedureCovered = "stop procedure covered"
    case rollbackProcedureCovered = "rollback procedure covered"
    case operatorChainCovered = "operator chain covered"
    case evidenceExportCovered = "evidence export covered"
    case postIncidentAuditCovered = "post-incident audit covered"
    case killSwitchChecklistCovered = "kill switch checklist covered"
    case noTradeChecklistCovered = "no-trade checklist covered"
    case productionCutoverBlocked = "production cutover blocked"
    case noSecretValueTrue = "no_secret_value true"
    case noOrderPayloadTrue = "no_order_payload true"
}

/// ReleaseV0100IncidentRollbackReadinessForbiddenCapability 枚举 GH-889 runbook 禁止授权的能力。
public enum ReleaseV0100IncidentRollbackReadinessForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
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
    case incidentRunbookConvertedToTradingPermission = "incident runbook converted to trading permission"
    case rollbackBypassEnabled = "incident rollback bypass enabled"
}

/// ReleaseV0100IncidentRollbackReadinessChecksum 提供 GH-889 reference-only runbook checksum 常量。
///
/// 这些 checksum 只标识 deterministic evidence，不来自 secret、endpoint response、broker response 或 order payload。
public enum ReleaseV0100IncidentRollbackReadinessChecksum {
    public static let evidence = "sha256:7777777777777777777777777777777777777777777777777777777777777777"
    public static let runbook = "sha256:8888888888888888888888888888888888888888888888888888888888888888"

    public static func classificationChecksum(for classification: ReleaseV0100IncidentRollbackClassification) -> String {
        let nibble: String
        switch classification {
        case .monitorAnomaly:
            nibble = "1"
        case .credentialExposureSuspected:
            nibble = "2"
        case .endpointPolicyDrift:
            nibble = "3"
        case .riskLimitBreach:
            nibble = "4"
        case .commandSurfaceRegression:
            nibble = "5"
        case .readinessEvidenceMismatch:
            nibble = "6"
        }

        return "sha256:" + String(repeating: nibble, count: 64)
    }

    public static func sectionChecksum(for section: ReleaseV0100IncidentRollbackReadinessSection) -> String {
        let nibble: String
        switch section {
        case .incidentClassification:
            nibble = "a"
        case .stopProcedure:
            nibble = "b"
        case .rollbackProcedure:
            nibble = "c"
        case .operatorChain:
            nibble = "d"
        case .evidenceExport:
            nibble = "e"
        case .postIncidentAudit:
            nibble = "f"
        case .killSwitchChecklist:
            nibble = "9"
        case .noTradeChecklist:
            nibble = "0"
        }

        return "sha256:" + String(repeating: nibble, count: 64)
    }
}

/// ReleaseV0100IncidentRollbackClassificationEvidence 是 GH-889 的单个 incident classification row。
///
/// Classification 只能驱动人工 stop / rollback review，不会变成 production cutover、order submission
/// 或 production trading permission。
public struct ReleaseV0100IncidentRollbackClassificationEvidence: Codable, Equatable, Sendable {
    public let classification: ReleaseV0100IncidentRollbackClassification
    public let checksum: String
    public let documented: Bool
    public let stopProcedureRequired: Bool
    public let rollbackReviewRequired: Bool
    public let productionCutoverAuthorized: Bool
    public let orderSubmissionEnabled: Bool
    public let productionTradingEnabled: Bool

    public var classificationHeld: Bool {
        checksum == ReleaseV0100IncidentRollbackReadinessChecksum.classificationChecksum(for: classification)
            && documented
            && stopProcedureRequired
            && rollbackReviewRequired
            && productionCutoverAuthorized == false
            && orderSubmissionEnabled == false
            && productionTradingEnabled == false
    }

    public init(
        classification: ReleaseV0100IncidentRollbackClassification,
        checksum: String? = nil,
        documented: Bool = true,
        stopProcedureRequired: Bool = true,
        rollbackReviewRequired: Bool = true,
        productionCutoverAuthorized: Bool = false,
        orderSubmissionEnabled: Bool = false,
        productionTradingEnabled: Bool = false
    ) throws {
        let resolvedChecksum = checksum ?? ReleaseV0100IncidentRollbackReadinessChecksum.classificationChecksum(for: classification)
        guard resolvedChecksum == ReleaseV0100IncidentRollbackReadinessChecksum.classificationChecksum(for: classification) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "incidentClassificationChecksum",
                expected: ReleaseV0100IncidentRollbackReadinessChecksum.classificationChecksum(for: classification),
                actual: resolvedChecksum
            )
        }
        guard documented else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "incidentClassificationDocumented", expected: "true", actual: "false")
        }
        guard stopProcedureRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "stopProcedureRequired", expected: "true", actual: "false")
        }
        guard rollbackReviewRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "rollbackReviewRequired", expected: "true", actual: "false")
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

        self.classification = classification
        self.checksum = resolvedChecksum
        self.documented = documented
        self.stopProcedureRequired = stopProcedureRequired
        self.rollbackReviewRequired = rollbackReviewRequired
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.orderSubmissionEnabled = orderSubmissionEnabled
        self.productionTradingEnabled = productionTradingEnabled
    }
}

/// ReleaseV0100IncidentRollbackSectionEvidence 是 GH-889 operator runbook 的单个章节 evidence row。
///
/// Section 只证明人工操作步骤已记录；它不会直接调用 broker、OMS、endpoint 或 command surface。
public struct ReleaseV0100IncidentRollbackSectionEvidence: Codable, Equatable, Sendable {
    public let section: ReleaseV0100IncidentRollbackReadinessSection
    public let checksum: String
    public let documented: Bool
    public let operatorManualOnly: Bool
    public let checklistRequired: Bool
    public let productionCutoverAuthorized: Bool
    public let orderSubmissionEnabled: Bool
    public let productionTradingEnabled: Bool

    public var sectionHeld: Bool {
        checksum == ReleaseV0100IncidentRollbackReadinessChecksum.sectionChecksum(for: section)
            && documented
            && operatorManualOnly
            && checklistRequired
            && productionCutoverAuthorized == false
            && orderSubmissionEnabled == false
            && productionTradingEnabled == false
    }

    public init(
        section: ReleaseV0100IncidentRollbackReadinessSection,
        checksum: String? = nil,
        documented: Bool = true,
        operatorManualOnly: Bool = true,
        checklistRequired: Bool = true,
        productionCutoverAuthorized: Bool = false,
        orderSubmissionEnabled: Bool = false,
        productionTradingEnabled: Bool = false
    ) throws {
        let resolvedChecksum = checksum ?? ReleaseV0100IncidentRollbackReadinessChecksum.sectionChecksum(for: section)
        guard resolvedChecksum == ReleaseV0100IncidentRollbackReadinessChecksum.sectionChecksum(for: section) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "incidentRollbackSectionChecksum",
                expected: ReleaseV0100IncidentRollbackReadinessChecksum.sectionChecksum(for: section),
                actual: resolvedChecksum
            )
        }
        guard documented else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "incidentRollbackSectionDocumented", expected: "true", actual: "false")
        }
        guard operatorManualOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "operatorManualOnly", expected: "true", actual: "false")
        }
        guard checklistRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "checklistRequired", expected: "true", actual: "false")
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

        self.section = section
        self.checksum = resolvedChecksum
        self.documented = documented
        self.operatorManualOnly = operatorManualOnly
        self.checklistRequired = checklistRequired
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.orderSubmissionEnabled = orderSubmissionEnabled
        self.productionTradingEnabled = productionTradingEnabled
    }
}

/// ReleaseV0100IncidentRollbackReadinessArtifact 是 GH-889 的 incident_rollback_readiness.json row。
///
/// Artifact 只证明 evidence 文件名、sha256 checksum 和 no-secret / no-order 边界。它不是 production
/// cutover authorization，也不会触发 production endpoint、broker 或 OMS。
public struct ReleaseV0100IncidentRollbackReadinessArtifact: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100IncidentRollbackReadinessArtifactKind
    public let fileName: String
    public let evidenceChecksum: String
    public let evidenceExists: Bool
    public let noSecretValue: Bool
    public let noOrderPayload: Bool
    public let containsBrokerOrAccountResponse: Bool
    public let producedByEndpointConnection: Bool
    public let containsOrderPayload: Bool

    public var artifactHeld: Bool {
        fileName == kind.rawValue
            && evidenceChecksum == ReleaseV0100IncidentRollbackReadinessChecksum.evidence
            && evidenceExists
            && noSecretValue
            && noOrderPayload
            && containsBrokerOrAccountResponse == false
            && producedByEndpointConnection == false
            && containsOrderPayload == false
    }

    public init(
        kind: ReleaseV0100IncidentRollbackReadinessArtifactKind = .incidentRollbackReadiness,
        fileName: String? = nil,
        evidenceChecksum: String = ReleaseV0100IncidentRollbackReadinessChecksum.evidence,
        evidenceExists: Bool = true,
        noSecretValue: Bool = true,
        noOrderPayload: Bool = true,
        containsBrokerOrAccountResponse: Bool = false,
        producedByEndpointConnection: Bool = false,
        containsOrderPayload: Bool = false
    ) throws {
        let resolvedFileName = fileName ?? kind.rawValue
        guard resolvedFileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "incidentRollbackReadinessFile", expected: kind.rawValue, actual: resolvedFileName)
        }
        guard evidenceChecksum == ReleaseV0100IncidentRollbackReadinessChecksum.evidence else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "incidentRollbackReadinessChecksum",
                expected: ReleaseV0100IncidentRollbackReadinessChecksum.evidence,
                actual: evidenceChecksum
            )
        }
        guard evidenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "incidentRollbackReadinessExists", expected: "true", actual: "false")
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
        self.evidenceChecksum = evidenceChecksum
        self.evidenceExists = evidenceExists
        self.noSecretValue = noSecretValue
        self.noOrderPayload = noOrderPayload
        self.containsBrokerOrAccountResponse = containsBrokerOrAccountResponse
        self.producedByEndpointConnection = producedByEndpointConnection
        self.containsOrderPayload = containsOrderPayload
    }
}

/// ReleaseV0100IncidentRollbackReadinessRunbook 是 GH-889 的 production incident / rollback readiness 合同。
///
/// Runbook 只描述人工事件分级、停止、回滚、证据导出和复盘清单。它不会授权 production cutover，
/// 不读取 secret，不连接 production endpoint / broker，也不启用订单提交。
public struct ReleaseV0100IncidentRollbackReadinessRunbook: Codable, Equatable, Sendable {
    public let runbookID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let runbookFile: String
    public let runbookChecksum: String
    public let evidenceArtifact: ReleaseV0100IncidentRollbackReadinessArtifact
    public let incidentClassifications: [ReleaseV0100IncidentRollbackClassificationEvidence]
    public let runbookSections: [ReleaseV0100IncidentRollbackSectionEvidence]
    public let requirements: [ReleaseV0100IncidentRollbackReadinessRequirement]
    public let forbiddenCapabilities: [ReleaseV0100IncidentRollbackReadinessForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let previousCutoverApprovalWorkflowHeld: Bool
    public let incidentClassificationCovered: Bool
    public let stopProcedureCovered: Bool
    public let rollbackProcedureCovered: Bool
    public let operatorChainCovered: Bool
    public let evidenceExportCovered: Bool
    public let postIncidentAuditCovered: Bool
    public let killSwitchChecklistCovered: Bool
    public let noTradeChecklistCovered: Bool
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
    public let incidentRunbookConvertedToTradingPermission: Bool
    public let rollbackBypassEnabled: Bool

    public var runbookHeld: Bool {
        issueID.rawValue == "GH-889"
            && upstreamIssueID.rawValue == "GH-888"
            && downstreamIssueID.rawValue == "GH-890"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && runbookFile == Self.requiredRunbookFile
            && runbookChecksum == ReleaseV0100IncidentRollbackReadinessChecksum.runbook
            && evidenceArtifact == Self.requiredEvidenceArtifact
            && incidentClassifications == Self.requiredIncidentClassifications
            && incidentClassifications.allSatisfy(\.classificationHeld)
            && runbookSections == Self.requiredRunbookSections
            && runbookSections.allSatisfy(\.sectionHeld)
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && previousCutoverApprovalWorkflowHeld
            && incidentClassificationCovered
            && stopProcedureCovered
            && rollbackProcedureCovered
            && operatorChainCovered
            && evidenceExportCovered
            && postIncidentAuditCovered
            && killSwitchChecklistCovered
            && noTradeChecklistCovered
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
            && incidentRunbookConvertedToTradingPermission == false
            && rollbackBypassEnabled == false
    }

    public init(
        runbookID: Identifier = Identifier.constant("gh-889-incident-rollback-readiness-runbook"),
        issueID: Identifier = Identifier.constant("GH-889"),
        upstreamIssueID: Identifier = Identifier.constant("GH-888"),
        downstreamIssueID: Identifier = Identifier.constant("GH-890"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        runbookFile: String = Self.requiredRunbookFile,
        runbookChecksum: String = ReleaseV0100IncidentRollbackReadinessChecksum.runbook,
        evidenceArtifact: ReleaseV0100IncidentRollbackReadinessArtifact = Self.requiredEvidenceArtifact,
        incidentClassifications: [ReleaseV0100IncidentRollbackClassificationEvidence] = Self.requiredIncidentClassifications,
        runbookSections: [ReleaseV0100IncidentRollbackSectionEvidence] = Self.requiredRunbookSections,
        requirements: [ReleaseV0100IncidentRollbackReadinessRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100IncidentRollbackReadinessForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        previousCutoverApprovalWorkflowHeld: Bool = true,
        incidentClassificationCovered: Bool = true,
        stopProcedureCovered: Bool = true,
        rollbackProcedureCovered: Bool = true,
        operatorChainCovered: Bool = true,
        evidenceExportCovered: Bool = true,
        postIncidentAuditCovered: Bool = true,
        killSwitchChecklistCovered: Bool = true,
        noTradeChecklistCovered: Bool = true,
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
        incidentRunbookConvertedToTradingPermission: Bool = false,
        rollbackBypassEnabled: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            runbookFile: runbookFile,
            runbookChecksum: runbookChecksum,
            evidenceArtifact: evidenceArtifact,
            incidentClassifications: incidentClassifications,
            runbookSections: runbookSections,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            previousCutoverApprovalWorkflowHeld: previousCutoverApprovalWorkflowHeld,
            incidentClassificationCovered: incidentClassificationCovered,
            stopProcedureCovered: stopProcedureCovered,
            rollbackProcedureCovered: rollbackProcedureCovered,
            operatorChainCovered: operatorChainCovered,
            evidenceExportCovered: evidenceExportCovered,
            postIncidentAuditCovered: postIncidentAuditCovered,
            killSwitchChecklistCovered: killSwitchChecklistCovered,
            noTradeChecklistCovered: noTradeChecklistCovered,
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
            incidentRunbookConvertedToTradingPermission: incidentRunbookConvertedToTradingPermission,
            rollbackBypassEnabled: rollbackBypassEnabled
        )

        self.runbookID = runbookID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.runbookFile = runbookFile
        self.runbookChecksum = runbookChecksum
        self.evidenceArtifact = evidenceArtifact
        self.incidentClassifications = incidentClassifications
        self.runbookSections = runbookSections
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.previousCutoverApprovalWorkflowHeld = previousCutoverApprovalWorkflowHeld
        self.incidentClassificationCovered = incidentClassificationCovered
        self.stopProcedureCovered = stopProcedureCovered
        self.rollbackProcedureCovered = rollbackProcedureCovered
        self.operatorChainCovered = operatorChainCovered
        self.evidenceExportCovered = evidenceExportCovered
        self.postIncidentAuditCovered = postIncidentAuditCovered
        self.killSwitchChecklistCovered = killSwitchChecklistCovered
        self.noTradeChecklistCovered = noTradeChecklistCovered
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
        self.incidentRunbookConvertedToTradingPermission = incidentRunbookConvertedToTradingPermission
        self.rollbackBypassEnabled = rollbackBypassEnabled
    }

    public static func deterministicFixture() throws -> ReleaseV0100IncidentRollbackReadinessRunbook {
        try ReleaseV0100IncidentRollbackReadinessRunbook()
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredRunbookFile = "docs/operators/release-v0.10.0-production-readiness-runbook.md"
    public static let requiredRequirements = ReleaseV0100IncidentRollbackReadinessRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100IncidentRollbackReadinessForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-012-INCIDENT-ROLLBACK-READINESS-RUNBOOK",
        "V0100-012-PRODUCTION-READINESS-RUNBOOK-MD",
        "V0100-012-INCIDENT-ROLLBACK-READINESS-JSON",
        "V0100-012-INCIDENT-CLASSIFICATION",
        "V0100-012-STOP-PROCEDURE",
        "V0100-012-ROLLBACK-PROCEDURE",
        "V0100-012-OPERATOR-CHAIN",
        "V0100-012-EVIDENCE-EXPORT",
        "V0100-012-POST-INCIDENT-AUDIT",
        "V0100-012-KILL-SWITCH-CHECKLIST",
        "V0100-012-NO-TRADE-CHECKLIST",
        "V0100-012-PRODUCTION-CAPABILITIES-DISABLED",
        "GH-889-VERIFY-V0100-INCIDENT-ROLLBACK-RUNBOOK",
        "TVM-RELEASE-V0100-INCIDENT-ROLLBACK-RUNBOOK"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH889IncidentRollbackReadinessRunbookKeepsProductionCutoverDisabled",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredEvidenceArtifact: ReleaseV0100IncidentRollbackReadinessArtifact = {
        do {
            return try ReleaseV0100IncidentRollbackReadinessArtifact()
        } catch {
            preconditionFailure("GH-889 incident rollback readiness artifact must be valid: \(error)")
        }
    }()

    public static let requiredIncidentClassifications: [ReleaseV0100IncidentRollbackClassificationEvidence] = {
        do {
            return try ReleaseV0100IncidentRollbackClassification.allCases.map {
                try ReleaseV0100IncidentRollbackClassificationEvidence(classification: $0)
            }
        } catch {
            preconditionFailure("GH-889 incident classifications must be valid: \(error)")
        }
    }()

    public static let requiredRunbookSections: [ReleaseV0100IncidentRollbackSectionEvidence] = {
        do {
            return try ReleaseV0100IncidentRollbackReadinessSection.allCases.map {
                try ReleaseV0100IncidentRollbackSectionEvidence(section: $0)
            }
        } catch {
            preconditionFailure("GH-889 incident rollback runbook sections must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100IncidentRollbackReadinessRunbook {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        runbookFile: String,
        runbookChecksum: String,
        evidenceArtifact: ReleaseV0100IncidentRollbackReadinessArtifact,
        incidentClassifications: [ReleaseV0100IncidentRollbackClassificationEvidence],
        runbookSections: [ReleaseV0100IncidentRollbackSectionEvidence],
        requirements: [ReleaseV0100IncidentRollbackReadinessRequirement],
        forbiddenCapabilities: [ReleaseV0100IncidentRollbackReadinessForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("runbookFile", runbookFile == requiredRunbookFile, requiredRunbookFile, runbookFile),
            ("runbookChecksum", runbookChecksum == ReleaseV0100IncidentRollbackReadinessChecksum.runbook, ReleaseV0100IncidentRollbackReadinessChecksum.runbook, runbookChecksum),
            ("evidenceArtifact", evidenceArtifact == requiredEvidenceArtifact, requiredEvidenceArtifact.fileName, evidenceArtifact.fileName),
            ("incidentClassifications", incidentClassifications == requiredIncidentClassifications, requiredIncidentClassifications.map { $0.classification.rawValue }.joined(separator: ","), incidentClassifications.map { $0.classification.rawValue }.joined(separator: ",")),
            ("runbookSections", runbookSections == requiredRunbookSections, requiredRunbookSections.map { $0.section.rawValue }.joined(separator: ","), runbookSections.map { $0.section.rawValue }.joined(separator: ",")),
            ("requirements", requirements == requiredRequirements, requiredRequirements.map(\.rawValue).joined(separator: ","), requirements.map(\.rawValue).joined(separator: ",")),
            ("forbiddenCapabilities", forbiddenCapabilities == requiredForbiddenCapabilities, requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","), forbiddenCapabilities.map(\.rawValue).joined(separator: ",")),
            ("validationAnchors", validationAnchors == requiredValidationAnchors, requiredValidationAnchors.joined(separator: ","), validationAnchors.joined(separator: ",")),
            ("requiredValidationCommands", requiredValidationCommands == Self.requiredValidationCommands, Self.requiredValidationCommands.joined(separator: ","), requiredValidationCommands.joined(separator: ","))
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrueFlags(
        previousCutoverApprovalWorkflowHeld: Bool,
        incidentClassificationCovered: Bool,
        stopProcedureCovered: Bool,
        rollbackProcedureCovered: Bool,
        operatorChainCovered: Bool,
        evidenceExportCovered: Bool,
        postIncidentAuditCovered: Bool,
        killSwitchChecklistCovered: Bool,
        noTradeChecklistCovered: Bool,
        productionCutoverBlocked: Bool
    ) throws {
        let requiredTrueFlags = [
            ("previousCutoverApprovalWorkflowHeld", previousCutoverApprovalWorkflowHeld),
            ("incidentClassificationCovered", incidentClassificationCovered),
            ("stopProcedureCovered", stopProcedureCovered),
            ("rollbackProcedureCovered", rollbackProcedureCovered),
            ("operatorChainCovered", operatorChainCovered),
            ("evidenceExportCovered", evidenceExportCovered),
            ("postIncidentAuditCovered", postIncidentAuditCovered),
            ("killSwitchChecklistCovered", killSwitchChecklistCovered),
            ("noTradeChecklistCovered", noTradeChecklistCovered),
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
        incidentRunbookConvertedToTradingPermission: Bool,
        rollbackBypassEnabled: Bool
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
            ("incidentRunbookConvertedToTradingPermission", incidentRunbookConvertedToTradingPermission),
            ("rollbackBypassEnabled", rollbackBypassEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
