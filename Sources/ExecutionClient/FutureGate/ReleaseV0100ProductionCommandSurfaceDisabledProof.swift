import DomainModel
import Foundation

/// ReleaseV0100ProductionCommandSurfaceEvidenceArtifactKind 固定 GH-885 的 Dashboard / CLI evidence 文件名。
public enum ReleaseV0100ProductionCommandSurfaceEvidenceArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dashboardProductionSurfaceDisabled = "dashboard_production_surface_disabled.json"
    case cliProductionSurfaceDisabled = "cli_production_surface_disabled.json"
}

/// ReleaseV0100ProductionCommandSurfaceDisabledRequirement 固定 GH-885 的 production command surface disabled 要求。
public enum ReleaseV0100ProductionCommandSurfaceDisabledRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamNoAuthorizationContractRequired = "upstream no-authorization contract required"
    case upstreamPublicationPolicyRequired = "upstream publication policy required"
    case dashboardProductionSurfaceDisabledEvidenceExists = "dashboard_production_surface_disabled.json evidence exists"
    case cliProductionSurfaceDisabledEvidenceExists = "cli_production_surface_disabled.json evidence exists"
    case tradingButtonHidden = "trading button visible false"
    case orderFormHidden = "order form visible false"
    case liveCommandDisabled = "live command disabled"
    case submitCommandDisabled = "submit command disabled"
    case cancelCommandDisabled = "cancel command disabled"
    case replaceCommandDisabled = "replace command disabled"
    case productionCommandDisabled = "production command disabled"
    case productionCutoverBlocked = "production cutover blocked"
}

/// ReleaseV0100ProductionCommandSurfaceForbiddenCapability 枚举 GH-885 必须保持关闭的能力。
public enum ReleaseV0100ProductionCommandSurfaceForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionCutoverAuthorization = "production cutover authorization"
    case productionCutoverUnblocked = "production cutover unblocked"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case productionSecretValueRead = "production secret value read"
    case testnetOrderSubmissionEnabled = "testnet order submission enabled"
    case productionOrderSubmissionEnabled = "production order submission enabled"
    case productionOMSRuntimeEnabled = "production OMS runtime enabled"
    case tradingButtonVisible = "trading button visible"
    case orderFormVisible = "order form visible"
    case liveCommandEnabled = "live command enabled"
    case submitCommandEnabled = "submit command enabled"
    case cancelCommandEnabled = "cancel command enabled"
    case replaceCommandEnabled = "replace command enabled"
    case productionCommandEnabled = "production command enabled"
    case commandBypassEnabled = "command bypass enabled"
}

/// ReleaseV0100ProductionCommandSurfaceDisabledArtifact 是 GH-885 的 evidence file row。
///
/// Artifact 只证明 Dashboard / CLI 的 production command surface disabled evidence 文件名和本地
/// evidence flags。它不包含 broker / account response，不来自 endpoint connection，也不包含 order payload。
public struct ReleaseV0100ProductionCommandSurfaceDisabledArtifact: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100ProductionCommandSurfaceEvidenceArtifactKind
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
        kind: ReleaseV0100ProductionCommandSurfaceEvidenceArtifactKind,
        fileName: String? = nil,
        evidenceExists: Bool = true,
        containsBrokerOrAccountResponse: Bool = false,
        producedByEndpointConnection: Bool = false,
        containsOrderPayload: Bool = false
    ) throws {
        let resolvedFileName = fileName ?? kind.rawValue
        guard resolvedFileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "commandSurfaceEvidenceFile", expected: kind.rawValue, actual: resolvedFileName)
        }
        guard evidenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "commandSurfaceEvidenceExists", expected: "true", actual: "false")
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

/// ReleaseV0100ProductionCommandSurfaceDisabledProof 是 GH-885 的 Dashboard / CLI command surface disabled 合同。
///
/// Proof 只证明 Dashboard 与 CLI 不暴露 production trading entry point。它不授权 production
/// cutover，不读取 secret、不连接 endpoint / broker，也不启用 submit / cancel / replace。
public struct ReleaseV0100ProductionCommandSurfaceDisabledProof: Codable, Equatable, Sendable {
    public let proofID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamNoAuthorizationContractHeld: Bool
    public let upstreamPublicationPolicyHeld: Bool
    public let dashboardProductionSurfaceDisabled: Bool
    public let cliProductionSurfaceDisabled: Bool
    public let productionCutoverBlocked: Bool
    public let evidenceArtifacts: [ReleaseV0100ProductionCommandSurfaceDisabledArtifact]
    public let requirements: [ReleaseV0100ProductionCommandSurfaceDisabledRequirement]
    public let forbiddenCapabilities: [ReleaseV0100ProductionCommandSurfaceForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let cutoverAuthorized: Bool
    public let productionCutoverUnblocked: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionSecretValueRead: Bool
    public let testnetOrderSubmissionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionOMSRuntimeEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandEnabled: Bool
    public let submitCommandEnabled: Bool
    public let cancelCommandEnabled: Bool
    public let replaceCommandEnabled: Bool
    public let productionCommandEnabled: Bool
    public let commandBypassEnabled: Bool

    public var proofHeld: Bool {
        issueID.rawValue == "GH-885"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-878", "GH-879"]
            && downstreamIssueID.rawValue == "GH-886"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && upstreamNoAuthorizationContractHeld
            && upstreamPublicationPolicyHeld
            && dashboardProductionSurfaceDisabled
            && cliProductionSurfaceDisabled
            && productionCutoverBlocked
            && evidenceArtifacts == Self.requiredEvidenceArtifacts
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionCommandSurfaceDisabled
    }

    public var productionCommandSurfaceDisabled: Bool {
        cutoverAuthorized == false
            && productionCutoverUnblocked == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionSecretValueRead == false
            && testnetOrderSubmissionEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionOMSRuntimeEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandEnabled == false
            && submitCommandEnabled == false
            && cancelCommandEnabled == false
            && replaceCommandEnabled == false
            && productionCommandEnabled == false
            && commandBypassEnabled == false
    }

    public init(
        proofID: Identifier = Identifier.constant("gh-885-production-command-surface-disabled-proof"),
        issueID: Identifier = Identifier.constant("GH-885"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-878"), Identifier.constant("GH-879")],
        downstreamIssueID: Identifier = Identifier.constant("GH-886"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        upstreamNoAuthorizationContractHeld: Bool = true,
        upstreamPublicationPolicyHeld: Bool = true,
        dashboardProductionSurfaceDisabled: Bool = true,
        cliProductionSurfaceDisabled: Bool = true,
        productionCutoverBlocked: Bool = true,
        evidenceArtifacts: [ReleaseV0100ProductionCommandSurfaceDisabledArtifact] = Self.requiredEvidenceArtifacts,
        requirements: [ReleaseV0100ProductionCommandSurfaceDisabledRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100ProductionCommandSurfaceForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        cutoverAuthorized: Bool = false,
        productionCutoverUnblocked: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionSecretValueRead: Bool = false,
        testnetOrderSubmissionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionOMSRuntimeEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandEnabled: Bool = false,
        submitCommandEnabled: Bool = false,
        cancelCommandEnabled: Bool = false,
        replaceCommandEnabled: Bool = false,
        productionCommandEnabled: Bool = false,
        commandBypassEnabled: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            upstreamIssueIDs: upstreamIssueIDs,
            evidenceArtifacts: evidenceArtifacts,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamNoAuthorizationContractHeld: upstreamNoAuthorizationContractHeld,
            upstreamPublicationPolicyHeld: upstreamPublicationPolicyHeld,
            dashboardProductionSurfaceDisabled: dashboardProductionSurfaceDisabled,
            cliProductionSurfaceDisabled: cliProductionSurfaceDisabled,
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
            productionOMSRuntimeEnabled: productionOMSRuntimeEnabled,
            tradingButtonVisible: tradingButtonVisible,
            orderFormVisible: orderFormVisible,
            liveCommandEnabled: liveCommandEnabled,
            submitCommandEnabled: submitCommandEnabled,
            cancelCommandEnabled: cancelCommandEnabled,
            replaceCommandEnabled: replaceCommandEnabled,
            productionCommandEnabled: productionCommandEnabled,
            commandBypassEnabled: commandBypassEnabled
        )

        self.proofID = proofID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamNoAuthorizationContractHeld = upstreamNoAuthorizationContractHeld
        self.upstreamPublicationPolicyHeld = upstreamPublicationPolicyHeld
        self.dashboardProductionSurfaceDisabled = dashboardProductionSurfaceDisabled
        self.cliProductionSurfaceDisabled = cliProductionSurfaceDisabled
        self.productionCutoverBlocked = productionCutoverBlocked
        self.evidenceArtifacts = evidenceArtifacts
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.cutoverAuthorized = cutoverAuthorized
        self.productionCutoverUnblocked = productionCutoverUnblocked
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionSecretValueRead = productionSecretValueRead
        self.testnetOrderSubmissionEnabled = testnetOrderSubmissionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionOMSRuntimeEnabled = productionOMSRuntimeEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandEnabled = liveCommandEnabled
        self.submitCommandEnabled = submitCommandEnabled
        self.cancelCommandEnabled = cancelCommandEnabled
        self.replaceCommandEnabled = replaceCommandEnabled
        self.productionCommandEnabled = productionCommandEnabled
        self.commandBypassEnabled = commandBypassEnabled
    }

    public static func deterministicFixture() throws -> ReleaseV0100ProductionCommandSurfaceDisabledProof {
        try ReleaseV0100ProductionCommandSurfaceDisabledProof()
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredRequirements = ReleaseV0100ProductionCommandSurfaceDisabledRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100ProductionCommandSurfaceForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-008-PRODUCTION-COMMAND-SURFACE-DISABLED-PROOF",
        "V0100-008-DASHBOARD-PRODUCTION-SURFACE-DISABLED-JSON",
        "V0100-008-CLI-PRODUCTION-SURFACE-DISABLED-JSON",
        "V0100-008-TRADING-BUTTON-VISIBLE-FALSE",
        "V0100-008-ORDER-FORM-VISIBLE-FALSE",
        "V0100-008-LIVE-COMMAND-ENABLED-FALSE",
        "V0100-008-SUBMIT-CANCEL-REPLACE-COMMANDS-DISABLED",
        "V0100-008-PRODUCTION-COMMAND-ENABLED-FALSE",
        "V0100-008-PRODUCTION-CUTOVER-BLOCKED",
        "V0100-008-PRODUCTION-CAPABILITIES-DISABLED",
        "GH-885-VERIFY-V0100-COMMAND-SURFACE-DISABLED",
        "TVM-RELEASE-V0100-COMMAND-SURFACE-DISABLED"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH885ProductionCommandSurfaceDisabledProofKeepsDashboardAndCLIReadOnly",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredEvidenceArtifacts: [ReleaseV0100ProductionCommandSurfaceDisabledArtifact] = {
        do {
            return [
                try ReleaseV0100ProductionCommandSurfaceDisabledArtifact(kind: .dashboardProductionSurfaceDisabled),
                try ReleaseV0100ProductionCommandSurfaceDisabledArtifact(kind: .cliProductionSurfaceDisabled)
            ]
        } catch {
            preconditionFailure("GH-885 command surface disabled evidence artifacts must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100ProductionCommandSurfaceDisabledProof {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        upstreamIssueIDs: [Identifier],
        evidenceArtifacts: [ReleaseV0100ProductionCommandSurfaceDisabledArtifact],
        requirements: [ReleaseV0100ProductionCommandSurfaceDisabledRequirement],
        forbiddenCapabilities: [ReleaseV0100ProductionCommandSurfaceForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == ["GH-878", "GH-879"], "GH-878,GH-879", upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("evidenceArtifacts", evidenceArtifacts == requiredEvidenceArtifacts, requiredEvidenceArtifacts.map(\.fileName).joined(separator: ","), evidenceArtifacts.map(\.fileName).joined(separator: ",")),
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
        upstreamNoAuthorizationContractHeld: Bool,
        upstreamPublicationPolicyHeld: Bool,
        dashboardProductionSurfaceDisabled: Bool,
        cliProductionSurfaceDisabled: Bool,
        productionCutoverBlocked: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamNoAuthorizationContractHeld", upstreamNoAuthorizationContractHeld),
            ("upstreamPublicationPolicyHeld", upstreamPublicationPolicyHeld),
            ("dashboardProductionSurfaceDisabled", dashboardProductionSurfaceDisabled),
            ("cliProductionSurfaceDisabled", cliProductionSurfaceDisabled),
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
        productionOMSRuntimeEnabled: Bool,
        tradingButtonVisible: Bool,
        orderFormVisible: Bool,
        liveCommandEnabled: Bool,
        submitCommandEnabled: Bool,
        cancelCommandEnabled: Bool,
        replaceCommandEnabled: Bool,
        productionCommandEnabled: Bool,
        commandBypassEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("cutoverAuthorized", cutoverAuthorized),
            ("productionCutoverUnblocked", productionCutoverUnblocked),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionSecretValueRead", productionSecretValueRead),
            ("testnetOrderSubmissionEnabled", testnetOrderSubmissionEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionOMSRuntimeEnabled", productionOMSRuntimeEnabled),
            ("tradingButtonVisible", tradingButtonVisible),
            ("orderFormVisible", orderFormVisible),
            ("liveCommandEnabled", liveCommandEnabled),
            ("submitCommandEnabled", submitCommandEnabled),
            ("cancelCommandEnabled", cancelCommandEnabled),
            ("replaceCommandEnabled", replaceCommandEnabled),
            ("productionCommandEnabled", productionCommandEnabled),
            ("commandBypassEnabled", commandBypassEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
