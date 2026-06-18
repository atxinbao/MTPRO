import DomainModel
import Foundation

/// ReleaseV0100ShadowDryRunParityEvidenceArtifactKind 固定 GH-886 的 shadow dry-run parity evidence 文件名。
public enum ReleaseV0100ShadowDryRunParityEvidenceArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case shadowDryRunParity = "shadow_dry_run_parity.json"
}

/// ReleaseV0100ShadowDryRunParityStage 固定 GH-886 必须覆盖的 near-production readiness shadow dry-run 链路。
public enum ReleaseV0100ShadowDryRunParityStage: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case marketReadOnlyObservation = "market/read-only observation"
    case strategyIntent = "strategy intent"
    case riskDecision = "risk decision"
    case omsDryRunLifecycle = "OMS dry-run lifecycle"
    case portfolioProjection = "portfolio projection"
    case reconciliationTimeline = "reconciliation timeline"
    case readinessDiff = "readiness diff"
}

/// ReleaseV0100ShadowDryRunParityRequirement 固定 GH-886 的 shadow dry-run parity 验收要求。
public enum ReleaseV0100ShadowDryRunParityRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case previousCapitalExposureReadinessRequired = "previous capital exposure readiness required"
    case previousKillSwitchNoTradeReadinessRequired = "previous kill switch no-trade readiness required"
    case previousCommandSurfaceDisabledProofRequired = "previous command surface disabled proof required"
    case shadowDryRunParityEvidenceExists = "shadow_dry_run_parity.json evidence exists"
    case marketReadOnlyObservationAudited = "market/read-only observation audited"
    case strategyIntentAudited = "strategy intent audited"
    case riskDecisionAudited = "risk decision audited"
    case omsDryRunLifecycleAudited = "OMS dry-run lifecycle audited"
    case portfolioProjectionAudited = "portfolio projection audited"
    case reconciliationTimelineAudited = "reconciliation timeline audited"
    case readinessDiffAudited = "readiness diff audited"
    case ordersSubmittedFalse = "ordersSubmitted false"
    case brokerCommandCreatedFalse = "brokerCommandCreated false"
    case productionCutoverBlocked = "production cutover blocked"
}

/// ReleaseV0100ShadowDryRunParityForbiddenCapability 枚举 GH-886 shadow dry-run parity 必须拒绝的能力。
public enum ReleaseV0100ShadowDryRunParityForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionCutoverAuthorization = "production cutover authorization"
    case productionCutoverUnblocked = "production cutover unblocked"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case productionSecretValueRead = "production secret value read"
    case testnetOrderSubmissionEnabled = "testnet order submission enabled"
    case productionOrderSubmissionEnabled = "production order submission enabled"
    case ordersSubmitted = "orders submitted"
    case brokerCommandCreated = "broker command created"
    case productionOMSRuntimeEnabled = "production OMS runtime enabled"
    case tradingButtonVisible = "trading button visible"
    case orderFormVisible = "order form visible"
    case liveCommandEnabled = "live command enabled"
    case productionCommandEnabled = "production command enabled"
    case shadowDryRunBypassEnabled = "shadow dry-run bypass enabled"
}

/// ReleaseV0100ShadowDryRunParityStageEvidence 是 GH-886 的单段 dry-run parity evidence row。
///
/// Stage evidence 只证明对应链路已经被审计，并且不创建 order payload 或 broker command。它不表示
/// live runtime 已经启动，也不授权任何 production cutover。
public struct ReleaseV0100ShadowDryRunParityStageEvidence: Codable, Equatable, Sendable {
    public let stage: ReleaseV0100ShadowDryRunParityStage
    public let evidenceReference: String
    public let audited: Bool
    public let createsOrderPayload: Bool
    public let createsBrokerCommand: Bool

    public var stageHeld: Bool {
        evidenceReference == stage.rawValue
            && audited
            && createsOrderPayload == false
            && createsBrokerCommand == false
    }

    public init(
        stage: ReleaseV0100ShadowDryRunParityStage,
        evidenceReference: String? = nil,
        audited: Bool = true,
        createsOrderPayload: Bool = false,
        createsBrokerCommand: Bool = false
    ) throws {
        let resolvedEvidenceReference = evidenceReference ?? stage.rawValue
        guard resolvedEvidenceReference == stage.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "shadowDryRunStageEvidence", expected: stage.rawValue, actual: resolvedEvidenceReference)
        }
        guard audited else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "shadowDryRunStageAudited", expected: "true", actual: "false")
        }
        guard createsOrderPayload == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("createsOrderPayload")
        }
        guard createsBrokerCommand == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("createsBrokerCommand")
        }

        self.stage = stage
        self.evidenceReference = resolvedEvidenceReference
        self.audited = audited
        self.createsOrderPayload = createsOrderPayload
        self.createsBrokerCommand = createsBrokerCommand
    }
}

/// ReleaseV0100ShadowDryRunParityArtifact 是 GH-886 的 shadow_dry_run_parity.json evidence file row。
///
/// Artifact 只证明本地 shadow dry-run parity evidence 文件名和审计 flags。它不包含 broker / account
/// response，不来自 endpoint connection，也不包含 order payload。
public struct ReleaseV0100ShadowDryRunParityArtifact: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100ShadowDryRunParityEvidenceArtifactKind
    public let fileName: String
    public let evidenceExists: Bool
    public let containsBrokerOrAccountResponse: Bool
    public let producedByEndpointConnection: Bool
    public let containsOrderPayload: Bool

    public var artifactHeld: Bool {
        fileName == kind.rawValue
            && evidenceExists
            && containsBrokerOrAccountResponse == false
            && producedByEndpointConnection == false
            && containsOrderPayload == false
    }

    public init(
        kind: ReleaseV0100ShadowDryRunParityEvidenceArtifactKind = .shadowDryRunParity,
        fileName: String? = nil,
        evidenceExists: Bool = true,
        containsBrokerOrAccountResponse: Bool = false,
        producedByEndpointConnection: Bool = false,
        containsOrderPayload: Bool = false
    ) throws {
        let resolvedFileName = fileName ?? kind.rawValue
        guard resolvedFileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "shadowDryRunParityEvidenceFile", expected: kind.rawValue, actual: resolvedFileName)
        }
        guard evidenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "shadowDryRunParityEvidenceExists", expected: "true", actual: "false")
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
        self.evidenceExists = evidenceExists
        self.containsBrokerOrAccountResponse = containsBrokerOrAccountResponse
        self.producedByEndpointConnection = producedByEndpointConnection
        self.containsOrderPayload = containsOrderPayload
    }
}

/// ReleaseV0100ShadowDryRunParityAssessment 是 GH-886 的 near-production readiness shadow dry-run 合同。
///
/// Assessment 只证明 market/read-only observation -> strategy intent -> risk decision -> OMS dry-run
/// lifecycle -> portfolio projection -> reconciliation timeline -> readiness diff 的 reference-only parity。
/// 它不提交 testnet / production order，不创建 broker command，不授权 production cutover。
public struct ReleaseV0100ShadowDryRunParityAssessment: Codable, Equatable, Sendable {
    public let assessmentID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let previousCapitalExposureReadinessHeld: Bool
    public let previousKillSwitchNoTradeReadinessHeld: Bool
    public let previousCommandSurfaceDisabledProofHeld: Bool
    public let evidenceArtifact: ReleaseV0100ShadowDryRunParityArtifact
    public let stageEvidence: [ReleaseV0100ShadowDryRunParityStageEvidence]
    public let requirements: [ReleaseV0100ShadowDryRunParityRequirement]
    public let forbiddenCapabilities: [ReleaseV0100ShadowDryRunParityForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let riskDecisionAudited: Bool
    public let portfolioProjectionAudited: Bool
    public let reconciliationTimelineAudited: Bool
    public let readinessDiffAudited: Bool
    public let productionCutoverBlocked: Bool
    public let cutoverAuthorized: Bool
    public let productionCutoverUnblocked: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionSecretValueRead: Bool
    public let testnetOrderSubmissionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let ordersSubmitted: Bool
    public let brokerCommandCreated: Bool
    public let productionOMSRuntimeEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandEnabled: Bool
    public let productionCommandEnabled: Bool
    public let shadowDryRunBypassEnabled: Bool

    public var assessmentHeld: Bool {
        issueID.rawValue == "GH-886"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-883", "GH-884", "GH-885"]
            && downstreamIssueID.rawValue == "GH-887"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && previousCapitalExposureReadinessHeld
            && previousKillSwitchNoTradeReadinessHeld
            && previousCommandSurfaceDisabledProofHeld
            && evidenceArtifact == Self.requiredEvidenceArtifact
            && stageEvidence == Self.requiredStageEvidence
            && stageEvidence.allSatisfy(\.stageHeld)
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && riskDecisionAudited
            && portfolioProjectionAudited
            && reconciliationTimelineAudited
            && readinessDiffAudited
            && productionCutoverBlocked
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        cutoverAuthorized == false
            && productionCutoverUnblocked == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionSecretValueRead == false
            && testnetOrderSubmissionEnabled == false
            && productionOrderSubmissionEnabled == false
            && ordersSubmitted == false
            && brokerCommandCreated == false
            && productionOMSRuntimeEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandEnabled == false
            && productionCommandEnabled == false
            && shadowDryRunBypassEnabled == false
    }

    public init(
        assessmentID: Identifier = Identifier.constant("gh-886-shadow-dry-run-parity-assessment"),
        issueID: Identifier = Identifier.constant("GH-886"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-883"), Identifier.constant("GH-884"), Identifier.constant("GH-885")],
        downstreamIssueID: Identifier = Identifier.constant("GH-887"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        previousCapitalExposureReadinessHeld: Bool = true,
        previousKillSwitchNoTradeReadinessHeld: Bool = true,
        previousCommandSurfaceDisabledProofHeld: Bool = true,
        evidenceArtifact: ReleaseV0100ShadowDryRunParityArtifact = Self.requiredEvidenceArtifact,
        stageEvidence: [ReleaseV0100ShadowDryRunParityStageEvidence] = Self.requiredStageEvidence,
        requirements: [ReleaseV0100ShadowDryRunParityRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100ShadowDryRunParityForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        riskDecisionAudited: Bool = true,
        portfolioProjectionAudited: Bool = true,
        reconciliationTimelineAudited: Bool = true,
        readinessDiffAudited: Bool = true,
        productionCutoverBlocked: Bool = true,
        cutoverAuthorized: Bool = false,
        productionCutoverUnblocked: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionSecretValueRead: Bool = false,
        testnetOrderSubmissionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        ordersSubmitted: Bool = false,
        brokerCommandCreated: Bool = false,
        productionOMSRuntimeEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandEnabled: Bool = false,
        productionCommandEnabled: Bool = false,
        shadowDryRunBypassEnabled: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            upstreamIssueIDs: upstreamIssueIDs,
            evidenceArtifact: evidenceArtifact,
            stageEvidence: stageEvidence,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            previousCapitalExposureReadinessHeld: previousCapitalExposureReadinessHeld,
            previousKillSwitchNoTradeReadinessHeld: previousKillSwitchNoTradeReadinessHeld,
            previousCommandSurfaceDisabledProofHeld: previousCommandSurfaceDisabledProofHeld,
            riskDecisionAudited: riskDecisionAudited,
            portfolioProjectionAudited: portfolioProjectionAudited,
            reconciliationTimelineAudited: reconciliationTimelineAudited,
            readinessDiffAudited: readinessDiffAudited,
            productionCutoverBlocked: productionCutoverBlocked
        )
        try Self.validateForbiddenFlags(
            cutoverAuthorized: cutoverAuthorized,
            productionCutoverUnblocked: productionCutoverUnblocked,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionSecretValueRead: productionSecretValueRead,
            testnetOrderSubmissionEnabled: testnetOrderSubmissionEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            ordersSubmitted: ordersSubmitted,
            brokerCommandCreated: brokerCommandCreated,
            productionOMSRuntimeEnabled: productionOMSRuntimeEnabled,
            tradingButtonVisible: tradingButtonVisible,
            orderFormVisible: orderFormVisible,
            liveCommandEnabled: liveCommandEnabled,
            productionCommandEnabled: productionCommandEnabled,
            shadowDryRunBypassEnabled: shadowDryRunBypassEnabled
        )

        self.assessmentID = assessmentID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.previousCapitalExposureReadinessHeld = previousCapitalExposureReadinessHeld
        self.previousKillSwitchNoTradeReadinessHeld = previousKillSwitchNoTradeReadinessHeld
        self.previousCommandSurfaceDisabledProofHeld = previousCommandSurfaceDisabledProofHeld
        self.evidenceArtifact = evidenceArtifact
        self.stageEvidence = stageEvidence
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.riskDecisionAudited = riskDecisionAudited
        self.portfolioProjectionAudited = portfolioProjectionAudited
        self.reconciliationTimelineAudited = reconciliationTimelineAudited
        self.readinessDiffAudited = readinessDiffAudited
        self.productionCutoverBlocked = productionCutoverBlocked
        self.cutoverAuthorized = cutoverAuthorized
        self.productionCutoverUnblocked = productionCutoverUnblocked
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionSecretValueRead = productionSecretValueRead
        self.testnetOrderSubmissionEnabled = testnetOrderSubmissionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.ordersSubmitted = ordersSubmitted
        self.brokerCommandCreated = brokerCommandCreated
        self.productionOMSRuntimeEnabled = productionOMSRuntimeEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandEnabled = liveCommandEnabled
        self.productionCommandEnabled = productionCommandEnabled
        self.shadowDryRunBypassEnabled = shadowDryRunBypassEnabled
    }

    public static func deterministicFixture() throws -> ReleaseV0100ShadowDryRunParityAssessment {
        try ReleaseV0100ShadowDryRunParityAssessment()
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredRequirements = ReleaseV0100ShadowDryRunParityRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100ShadowDryRunParityForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-009-SHADOW-DRY-RUN-PARITY-ASSESSMENT",
        "V0100-009-SHADOW-DRY-RUN-PARITY-JSON",
        "V0100-009-MARKET-READONLY-OBSERVATION",
        "V0100-009-STRATEGY-INTENT",
        "V0100-009-RISK-DECISION-AUDITED",
        "V0100-009-OMS-DRY-RUN-LIFECYCLE",
        "V0100-009-PORTFOLIO-PROJECTION-AUDITED",
        "V0100-009-RECONCILIATION-TIMELINE-AUDITED",
        "V0100-009-READINESS-DIFF-AUDITED",
        "V0100-009-ORDERS-SUBMITTED-FALSE",
        "V0100-009-BROKER-COMMAND-CREATED-FALSE",
        "V0100-009-PRODUCTION-CAPABILITIES-DISABLED",
        "GH-886-VERIFY-V0100-SHADOW-DRY-RUN-PARITY",
        "TVM-RELEASE-V0100-SHADOW-DRY-RUN-PARITY"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH886ShadowDryRunParityAssessmentAuditsNearProductionPathWithoutOrders",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredEvidenceArtifact: ReleaseV0100ShadowDryRunParityArtifact = {
        do {
            return try ReleaseV0100ShadowDryRunParityArtifact()
        } catch {
            preconditionFailure("GH-886 shadow dry-run parity evidence artifact must be valid: \(error)")
        }
    }()

    public static let requiredStageEvidence: [ReleaseV0100ShadowDryRunParityStageEvidence] = {
        do {
            return try ReleaseV0100ShadowDryRunParityStage.allCases.map {
                try ReleaseV0100ShadowDryRunParityStageEvidence(stage: $0)
            }
        } catch {
            preconditionFailure("GH-886 shadow dry-run parity stage evidence must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100ShadowDryRunParityAssessment {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        upstreamIssueIDs: [Identifier],
        evidenceArtifact: ReleaseV0100ShadowDryRunParityArtifact,
        stageEvidence: [ReleaseV0100ShadowDryRunParityStageEvidence],
        requirements: [ReleaseV0100ShadowDryRunParityRequirement],
        forbiddenCapabilities: [ReleaseV0100ShadowDryRunParityForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == ["GH-883", "GH-884", "GH-885"], "GH-883,GH-884,GH-885", upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("evidenceArtifact", evidenceArtifact == requiredEvidenceArtifact, requiredEvidenceArtifact.fileName, evidenceArtifact.fileName),
            ("stageEvidence", stageEvidence == requiredStageEvidence, requiredStageEvidence.map(\.evidenceReference).joined(separator: ","), stageEvidence.map(\.evidenceReference).joined(separator: ",")),
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
        previousCapitalExposureReadinessHeld: Bool,
        previousKillSwitchNoTradeReadinessHeld: Bool,
        previousCommandSurfaceDisabledProofHeld: Bool,
        riskDecisionAudited: Bool,
        portfolioProjectionAudited: Bool,
        reconciliationTimelineAudited: Bool,
        readinessDiffAudited: Bool,
        productionCutoverBlocked: Bool
    ) throws {
        let requiredTrueFlags = [
            ("previousCapitalExposureReadinessHeld", previousCapitalExposureReadinessHeld),
            ("previousKillSwitchNoTradeReadinessHeld", previousKillSwitchNoTradeReadinessHeld),
            ("previousCommandSurfaceDisabledProofHeld", previousCommandSurfaceDisabledProofHeld),
            ("riskDecisionAudited", riskDecisionAudited),
            ("portfolioProjectionAudited", portfolioProjectionAudited),
            ("reconciliationTimelineAudited", reconciliationTimelineAudited),
            ("readinessDiffAudited", readinessDiffAudited),
            ("productionCutoverBlocked", productionCutoverBlocked)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        cutoverAuthorized: Bool,
        productionCutoverUnblocked: Bool,
        productionEndpointConnectionEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionSecretValueRead: Bool,
        testnetOrderSubmissionEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        ordersSubmitted: Bool,
        brokerCommandCreated: Bool,
        productionOMSRuntimeEnabled: Bool,
        tradingButtonVisible: Bool,
        orderFormVisible: Bool,
        liveCommandEnabled: Bool,
        productionCommandEnabled: Bool,
        shadowDryRunBypassEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("cutoverAuthorized", cutoverAuthorized),
            ("productionCutoverUnblocked", productionCutoverUnblocked),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionSecretValueRead", productionSecretValueRead),
            ("testnetOrderSubmissionEnabled", testnetOrderSubmissionEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("ordersSubmitted", ordersSubmitted),
            ("brokerCommandCreated", brokerCommandCreated),
            ("productionOMSRuntimeEnabled", productionOMSRuntimeEnabled),
            ("tradingButtonVisible", tradingButtonVisible),
            ("orderFormVisible", orderFormVisible),
            ("liveCommandEnabled", liveCommandEnabled),
            ("productionCommandEnabled", productionCommandEnabled),
            ("shadowDryRunBypassEnabled", shadowDryRunBypassEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
