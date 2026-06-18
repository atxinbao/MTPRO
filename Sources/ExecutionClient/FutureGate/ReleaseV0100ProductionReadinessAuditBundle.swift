import DomainModel
import Foundation

/// ReleaseV0100ProductionReadinessBundleArtifactKind 固定 GH-887 的最终 readiness bundle 文件名。
public enum ReleaseV0100ProductionReadinessBundleArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionReadinessBundle = "production_readiness_bundle.json"
}

/// ReleaseV0100ProductionReadinessBundleEntryKind 枚举 GH-887 bundle 必须聚合的上游 readiness evidence。
public enum ReleaseV0100ProductionReadinessBundleEntryKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case environmentProfile = "production_environment_profile.json"
    case secretReadiness = "secret_readiness.json"
    case endpointPolicyReadiness = "endpoint_policy_readiness.json"
    case capitalExposureLimits = "capital_exposure_limits.json"
    case killSwitchReadiness = "kill_switch_readiness.json"
    case noTradeReadiness = "no_trade_readiness.json"
    case dashboardProductionSurfaceDisabled = "dashboard_production_surface_disabled.json"
    case cliProductionSurfaceDisabled = "cli_production_surface_disabled.json"
    case shadowDryRunParity = "shadow_dry_run_parity.json"
    case riskPolicySnapshot = "risk_policy_snapshot.json"
    case portfolioReconciliationSnapshot = "portfolio_reconciliation_snapshot.json"
}

/// ReleaseV0100ProductionReadinessBundleRequirement 固定 GH-887 的 bundle 验收要求。
public enum ReleaseV0100ProductionReadinessBundleRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case environmentProfileIncluded = "environment profile included"
    case secretReadinessIncluded = "secret readiness included"
    case endpointPolicyReadinessIncluded = "endpoint policy readiness included"
    case capitalExposureLimitsIncluded = "capital/exposure limits included"
    case killSwitchNoTradeIncluded = "kill switch and no-trade evidence included"
    case commandSurfaceDisabledIncluded = "command surface disabled evidence included"
    case shadowDryRunParityIncluded = "shadow dry-run parity included"
    case riskPolicySnapshotIncluded = "risk policy snapshot included"
    case portfolioReconciliationSnapshotIncluded = "portfolio reconciliation snapshot included"
    case productionReadinessBundleExists = "production_readiness_bundle.json evidence exists"
    case bundleChecksumSha256Recorded = "bundle checksum recorded as sha256"
    case redactionProofTrue = "redaction_proof true"
    case noSecretValueTrue = "no_secret_value true"
    case noOrderPayloadTrue = "no_order_payload true"
    case productionCutoverBlocked = "production cutover blocked"
}

/// ReleaseV0100ProductionReadinessBundleForbiddenCapability 枚举 GH-887 bundle 必须拒绝的能力。
public enum ReleaseV0100ProductionReadinessBundleForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionCutoverAuthorization = "production cutover authorization"
    case productionCutoverUnblocked = "production cutover unblocked"
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
    case productionCommandEnabled = "production command enabled"
    case readinessApprovalConvertedToTradingPermission = "readiness approval converted to trading permission"
    case bundleBypassEnabled = "production readiness bundle bypass enabled"
}

/// ReleaseV0100ProductionReadinessBundleChecksum 提供 GH-887 reference-only bundle checksum 常量。
///
/// 这些 checksum 是 deterministic evidence identity，不来自 secret、endpoint response、broker response
/// 或 order payload。它们只让 bundle 审计具备稳定、可验证的 sha256 形态。
public enum ReleaseV0100ProductionReadinessBundleChecksum {
    public static let bundle = "sha256:60555a74cbcb67f2e1e785db208e97b96e72b2e0e02f2b60d656fcabbc58d62a"

    public static func entryChecksum(for kind: ReleaseV0100ProductionReadinessBundleEntryKind) -> String {
        let nibble: String
        switch kind {
        case .environmentProfile:
            nibble = "1"
        case .secretReadiness:
            nibble = "2"
        case .endpointPolicyReadiness:
            nibble = "3"
        case .capitalExposureLimits:
            nibble = "4"
        case .killSwitchReadiness:
            nibble = "5"
        case .noTradeReadiness:
            nibble = "6"
        case .dashboardProductionSurfaceDisabled:
            nibble = "7"
        case .cliProductionSurfaceDisabled:
            nibble = "8"
        case .shadowDryRunParity:
            nibble = "9"
        case .riskPolicySnapshot:
            nibble = "a"
        case .portfolioReconciliationSnapshot:
            nibble = "b"
        }

        return "sha256:" + String(repeating: nibble, count: 64)
    }
}

/// ReleaseV0100ProductionReadinessBundleEntry 是 GH-887 bundle 中的单个 evidence row。
///
/// Entry 只记录上游 readiness evidence 的文件名、checksum 和脱敏 / 禁止订单 flags。它不包含
/// broker / account response，不来自 endpoint connection，也不携带 order payload。
public struct ReleaseV0100ProductionReadinessBundleEntry: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100ProductionReadinessBundleEntryKind
    public let fileName: String
    public let checksum: String
    public let includedInBundle: Bool
    public let redactionProof: Bool
    public let noSecretValue: Bool
    public let noOrderPayload: Bool
    public let containsBrokerOrAccountResponse: Bool
    public let producedByEndpointConnection: Bool

    public var entryHeld: Bool {
        fileName == kind.rawValue
            && checksum == ReleaseV0100ProductionReadinessBundleChecksum.entryChecksum(for: kind)
            && includedInBundle
            && redactionProof
            && noSecretValue
            && noOrderPayload
            && containsBrokerOrAccountResponse == false
            && producedByEndpointConnection == false
    }

    public init(
        kind: ReleaseV0100ProductionReadinessBundleEntryKind,
        fileName: String? = nil,
        checksum: String? = nil,
        includedInBundle: Bool = true,
        redactionProof: Bool = true,
        noSecretValue: Bool = true,
        noOrderPayload: Bool = true,
        containsBrokerOrAccountResponse: Bool = false,
        producedByEndpointConnection: Bool = false
    ) throws {
        let resolvedFileName = fileName ?? kind.rawValue
        let resolvedChecksum = checksum ?? ReleaseV0100ProductionReadinessBundleChecksum.entryChecksum(for: kind)
        guard resolvedFileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "bundleEntryFileName", expected: kind.rawValue, actual: resolvedFileName)
        }
        guard resolvedChecksum == ReleaseV0100ProductionReadinessBundleChecksum.entryChecksum(for: kind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "bundleEntryChecksum",
                expected: ReleaseV0100ProductionReadinessBundleChecksum.entryChecksum(for: kind),
                actual: resolvedChecksum
            )
        }
        guard includedInBundle else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "includedInBundle", expected: "true", actual: "false")
        }
        guard redactionProof else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "redactionProof", expected: "true", actual: "false")
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

        self.kind = kind
        self.fileName = resolvedFileName
        self.checksum = resolvedChecksum
        self.includedInBundle = includedInBundle
        self.redactionProof = redactionProof
        self.noSecretValue = noSecretValue
        self.noOrderPayload = noOrderPayload
        self.containsBrokerOrAccountResponse = containsBrokerOrAccountResponse
        self.producedByEndpointConnection = producedByEndpointConnection
    }
}

/// ReleaseV0100ProductionReadinessBundleArtifact 是 GH-887 的 production_readiness_bundle.json row。
///
/// Artifact 只证明 bundle 文件名、sha256 checksum 和三项 hard boundary flags。它不是 production
/// cutover approval，也不会把 readiness bundle 转换成交易许可。
public struct ReleaseV0100ProductionReadinessBundleArtifact: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100ProductionReadinessBundleArtifactKind
    public let fileName: String
    public let bundleChecksum: String
    public let evidenceExists: Bool
    public let redactionProof: Bool
    public let noSecretValue: Bool
    public let noOrderPayload: Bool
    public let containsBrokerOrAccountResponse: Bool
    public let producedByEndpointConnection: Bool
    public let containsOrderPayload: Bool

    public var artifactHeld: Bool {
        fileName == kind.rawValue
            && bundleChecksum == ReleaseV0100ProductionReadinessBundleChecksum.bundle
            && evidenceExists
            && redactionProof
            && noSecretValue
            && noOrderPayload
            && containsBrokerOrAccountResponse == false
            && producedByEndpointConnection == false
            && containsOrderPayload == false
    }

    public init(
        kind: ReleaseV0100ProductionReadinessBundleArtifactKind = .productionReadinessBundle,
        fileName: String? = nil,
        bundleChecksum: String = ReleaseV0100ProductionReadinessBundleChecksum.bundle,
        evidenceExists: Bool = true,
        redactionProof: Bool = true,
        noSecretValue: Bool = true,
        noOrderPayload: Bool = true,
        containsBrokerOrAccountResponse: Bool = false,
        producedByEndpointConnection: Bool = false,
        containsOrderPayload: Bool = false
    ) throws {
        let resolvedFileName = fileName ?? kind.rawValue
        guard resolvedFileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "productionReadinessBundleFile", expected: kind.rawValue, actual: resolvedFileName)
        }
        guard bundleChecksum == ReleaseV0100ProductionReadinessBundleChecksum.bundle else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "productionReadinessBundleChecksum",
                expected: ReleaseV0100ProductionReadinessBundleChecksum.bundle,
                actual: bundleChecksum
            )
        }
        guard evidenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "productionReadinessBundleExists", expected: "true", actual: "false")
        }
        guard redactionProof else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "redactionProof", expected: "true", actual: "false")
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
        self.bundleChecksum = bundleChecksum
        self.evidenceExists = evidenceExists
        self.redactionProof = redactionProof
        self.noSecretValue = noSecretValue
        self.noOrderPayload = noOrderPayload
        self.containsBrokerOrAccountResponse = containsBrokerOrAccountResponse
        self.producedByEndpointConnection = producedByEndpointConnection
        self.containsOrderPayload = containsOrderPayload
    }
}

/// ReleaseV0100ProductionReadinessAuditBundle 是 GH-887 的 production readiness audit bundle 合同。
///
/// Bundle 聚合 environment profile、secret readiness、endpoint policy readiness、capital / exposure
/// limits、kill switch、no-trade、command surface disabled、shadow dry-run parity、risk policy snapshot 和
/// portfolio reconciliation snapshot。它只输出可审计 reference，不授权 production cutover，不读取 secret，
/// 不连接 broker / endpoint，也不生成 order payload。
public struct ReleaseV0100ProductionReadinessAuditBundle: Codable, Equatable, Sendable {
    public let bundleID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let evidenceArtifact: ReleaseV0100ProductionReadinessBundleArtifact
    public let evidenceEntries: [ReleaseV0100ProductionReadinessBundleEntry]
    public let requirements: [ReleaseV0100ProductionReadinessBundleRequirement]
    public let forbiddenCapabilities: [ReleaseV0100ProductionReadinessBundleForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let bundleChecksum: String
    public let redactionProof: Bool
    public let noSecretValue: Bool
    public let noOrderPayload: Bool
    public let upstreamEnvironmentProfileHeld: Bool
    public let upstreamSecretReadinessHeld: Bool
    public let upstreamEndpointPolicyReadinessHeld: Bool
    public let upstreamCapitalExposureReadinessHeld: Bool
    public let upstreamKillSwitchNoTradeReadinessHeld: Bool
    public let upstreamCommandSurfaceDisabledProofHeld: Bool
    public let upstreamShadowDryRunParityHeld: Bool
    public let riskPolicySnapshotIncluded: Bool
    public let portfolioReconciliationSnapshotIncluded: Bool
    public let productionCutoverBlocked: Bool
    public let cutoverAuthorized: Bool
    public let productionCutoverUnblocked: Bool
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
    public let productionCommandEnabled: Bool
    public let readinessApprovalConvertedToTradingPermission: Bool
    public let bundleBypassEnabled: Bool

    public var bundleHeld: Bool {
        issueID.rawValue == "GH-887"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-880", "GH-881", "GH-882", "GH-883", "GH-884", "GH-885", "GH-886"]
            && downstreamIssueID.rawValue == "GH-888"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && evidenceArtifact == Self.requiredEvidenceArtifact
            && evidenceEntries == Self.requiredEvidenceEntries
            && evidenceEntries.allSatisfy(\.entryHeld)
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && bundleChecksum == ReleaseV0100ProductionReadinessBundleChecksum.bundle
            && redactionProof
            && noSecretValue
            && noOrderPayload
            && requiredUpstreamEvidenceHeld
            && riskPolicySnapshotIncluded
            && portfolioReconciliationSnapshotIncluded
            && productionCutoverBlocked
            && productionCapabilitiesDisabled
    }

    public var requiredUpstreamEvidenceHeld: Bool {
        upstreamEnvironmentProfileHeld
            && upstreamSecretReadinessHeld
            && upstreamEndpointPolicyReadinessHeld
            && upstreamCapitalExposureReadinessHeld
            && upstreamKillSwitchNoTradeReadinessHeld
            && upstreamCommandSurfaceDisabledProofHeld
            && upstreamShadowDryRunParityHeld
    }

    public var productionCapabilitiesDisabled: Bool {
        cutoverAuthorized == false
            && productionCutoverUnblocked == false
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
            && productionCommandEnabled == false
            && readinessApprovalConvertedToTradingPermission == false
            && bundleBypassEnabled == false
    }

    public init(
        bundleID: Identifier = Identifier.constant("gh-887-production-readiness-audit-bundle"),
        issueID: Identifier = Identifier.constant("GH-887"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-880"),
            Identifier.constant("GH-881"),
            Identifier.constant("GH-882"),
            Identifier.constant("GH-883"),
            Identifier.constant("GH-884"),
            Identifier.constant("GH-885"),
            Identifier.constant("GH-886")
        ],
        downstreamIssueID: Identifier = Identifier.constant("GH-888"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        evidenceArtifact: ReleaseV0100ProductionReadinessBundleArtifact = Self.requiredEvidenceArtifact,
        evidenceEntries: [ReleaseV0100ProductionReadinessBundleEntry] = Self.requiredEvidenceEntries,
        requirements: [ReleaseV0100ProductionReadinessBundleRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100ProductionReadinessBundleForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        bundleChecksum: String = ReleaseV0100ProductionReadinessBundleChecksum.bundle,
        redactionProof: Bool = true,
        noSecretValue: Bool = true,
        noOrderPayload: Bool = true,
        upstreamEnvironmentProfileHeld: Bool = true,
        upstreamSecretReadinessHeld: Bool = true,
        upstreamEndpointPolicyReadinessHeld: Bool = true,
        upstreamCapitalExposureReadinessHeld: Bool = true,
        upstreamKillSwitchNoTradeReadinessHeld: Bool = true,
        upstreamCommandSurfaceDisabledProofHeld: Bool = true,
        upstreamShadowDryRunParityHeld: Bool = true,
        riskPolicySnapshotIncluded: Bool = true,
        portfolioReconciliationSnapshotIncluded: Bool = true,
        productionCutoverBlocked: Bool = true,
        cutoverAuthorized: Bool = false,
        productionCutoverUnblocked: Bool = false,
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
        productionCommandEnabled: Bool = false,
        readinessApprovalConvertedToTradingPermission: Bool = false,
        bundleBypassEnabled: Bool = false
    ) throws {
        try Self.validateRequired(
            upstreamIssueIDs: upstreamIssueIDs,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            evidenceArtifact: evidenceArtifact,
            evidenceEntries: evidenceEntries,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands,
            bundleChecksum: bundleChecksum
        )
        try Self.validateRequiredTrueFlags(
            redactionProof: redactionProof,
            noSecretValue: noSecretValue,
            noOrderPayload: noOrderPayload,
            upstreamEnvironmentProfileHeld: upstreamEnvironmentProfileHeld,
            upstreamSecretReadinessHeld: upstreamSecretReadinessHeld,
            upstreamEndpointPolicyReadinessHeld: upstreamEndpointPolicyReadinessHeld,
            upstreamCapitalExposureReadinessHeld: upstreamCapitalExposureReadinessHeld,
            upstreamKillSwitchNoTradeReadinessHeld: upstreamKillSwitchNoTradeReadinessHeld,
            upstreamCommandSurfaceDisabledProofHeld: upstreamCommandSurfaceDisabledProofHeld,
            upstreamShadowDryRunParityHeld: upstreamShadowDryRunParityHeld,
            riskPolicySnapshotIncluded: riskPolicySnapshotIncluded,
            portfolioReconciliationSnapshotIncluded: portfolioReconciliationSnapshotIncluded,
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
            orderPayloadCreated: orderPayloadCreated,
            brokerCommandCreated: brokerCommandCreated,
            productionOMSRuntimeEnabled: productionOMSRuntimeEnabled,
            tradingButtonVisible: tradingButtonVisible,
            orderFormVisible: orderFormVisible,
            liveCommandEnabled: liveCommandEnabled,
            productionCommandEnabled: productionCommandEnabled,
            readinessApprovalConvertedToTradingPermission: readinessApprovalConvertedToTradingPermission,
            bundleBypassEnabled: bundleBypassEnabled
        )

        self.bundleID = bundleID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.evidenceArtifact = evidenceArtifact
        self.evidenceEntries = evidenceEntries
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.bundleChecksum = bundleChecksum
        self.redactionProof = redactionProof
        self.noSecretValue = noSecretValue
        self.noOrderPayload = noOrderPayload
        self.upstreamEnvironmentProfileHeld = upstreamEnvironmentProfileHeld
        self.upstreamSecretReadinessHeld = upstreamSecretReadinessHeld
        self.upstreamEndpointPolicyReadinessHeld = upstreamEndpointPolicyReadinessHeld
        self.upstreamCapitalExposureReadinessHeld = upstreamCapitalExposureReadinessHeld
        self.upstreamKillSwitchNoTradeReadinessHeld = upstreamKillSwitchNoTradeReadinessHeld
        self.upstreamCommandSurfaceDisabledProofHeld = upstreamCommandSurfaceDisabledProofHeld
        self.upstreamShadowDryRunParityHeld = upstreamShadowDryRunParityHeld
        self.riskPolicySnapshotIncluded = riskPolicySnapshotIncluded
        self.portfolioReconciliationSnapshotIncluded = portfolioReconciliationSnapshotIncluded
        self.productionCutoverBlocked = productionCutoverBlocked
        self.cutoverAuthorized = cutoverAuthorized
        self.productionCutoverUnblocked = productionCutoverUnblocked
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
        self.productionCommandEnabled = productionCommandEnabled
        self.readinessApprovalConvertedToTradingPermission = readinessApprovalConvertedToTradingPermission
        self.bundleBypassEnabled = bundleBypassEnabled
    }

    public static func deterministicFixture() throws -> ReleaseV0100ProductionReadinessAuditBundle {
        try ReleaseV0100ProductionReadinessAuditBundle()
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredRequirements = ReleaseV0100ProductionReadinessBundleRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100ProductionReadinessBundleForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-010-PRODUCTION-READINESS-AUDIT-BUNDLE",
        "V0100-010-PRODUCTION-READINESS-BUNDLE-JSON",
        "V0100-010-BUNDLE-SHA256-CHECKSUM",
        "V0100-010-ENVIRONMENT-SECRET-ENDPOINT-EVIDENCE",
        "V0100-010-CAPITAL-KILL-SWITCH-NO-TRADE-EVIDENCE",
        "V0100-010-COMMAND-SURFACE-SHADOW-DRY-RUN-EVIDENCE",
        "V0100-010-RISK-POLICY-SNAPSHOT",
        "V0100-010-PORTFOLIO-RECONCILIATION-SNAPSHOT",
        "V0100-010-REDACTION-PROOF-TRUE",
        "V0100-010-NO-SECRET-VALUE-TRUE",
        "V0100-010-NO-ORDER-PAYLOAD-TRUE",
        "V0100-010-PRODUCTION-CAPABILITIES-DISABLED",
        "GH-887-VERIFY-V0100-PRODUCTION-READINESS-BUNDLE",
        "TVM-RELEASE-V0100-PRODUCTION-READINESS-BUNDLE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH887ProductionReadinessAuditBundleAggregatesRedactedNoOrderEvidence",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredEvidenceArtifact: ReleaseV0100ProductionReadinessBundleArtifact = {
        do {
            return try ReleaseV0100ProductionReadinessBundleArtifact()
        } catch {
            preconditionFailure("GH-887 production readiness bundle artifact must be valid: \(error)")
        }
    }()

    public static let requiredEvidenceEntries: [ReleaseV0100ProductionReadinessBundleEntry] = {
        do {
            return try ReleaseV0100ProductionReadinessBundleEntryKind.allCases.map {
                try ReleaseV0100ProductionReadinessBundleEntry(kind: $0)
            }
        } catch {
            preconditionFailure("GH-887 production readiness bundle entries must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100ProductionReadinessAuditBundle {
    static func validateRequired(
        upstreamIssueIDs: [Identifier],
        canonicalQueueRange: String,
        projectName: String,
        evidenceArtifact: ReleaseV0100ProductionReadinessBundleArtifact,
        evidenceEntries: [ReleaseV0100ProductionReadinessBundleEntry],
        requirements: [ReleaseV0100ProductionReadinessBundleRequirement],
        forbiddenCapabilities: [ReleaseV0100ProductionReadinessBundleForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String],
        bundleChecksum: String
    ) throws {
        let requiredUpstreamIssueIDs = ["GH-880", "GH-881", "GH-882", "GH-883", "GH-884", "GH-885", "GH-886"]
        let checks: [(String, Bool, String, String)] = [
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == requiredUpstreamIssueIDs, requiredUpstreamIssueIDs.joined(separator: ","), upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("evidenceArtifact", evidenceArtifact == requiredEvidenceArtifact, requiredEvidenceArtifact.fileName, evidenceArtifact.fileName),
            ("evidenceEntries", evidenceEntries == requiredEvidenceEntries, requiredEvidenceEntries.map(\.fileName).joined(separator: ","), evidenceEntries.map(\.fileName).joined(separator: ",")),
            ("requirements", requirements == requiredRequirements, requiredRequirements.map(\.rawValue).joined(separator: ","), requirements.map(\.rawValue).joined(separator: ",")),
            ("forbiddenCapabilities", forbiddenCapabilities == requiredForbiddenCapabilities, requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","), forbiddenCapabilities.map(\.rawValue).joined(separator: ",")),
            ("validationAnchors", validationAnchors == requiredValidationAnchors, requiredValidationAnchors.joined(separator: ","), validationAnchors.joined(separator: ",")),
            ("requiredValidationCommands", requiredValidationCommands == Self.requiredValidationCommands, Self.requiredValidationCommands.joined(separator: ","), requiredValidationCommands.joined(separator: ",")),
            ("bundleChecksum", bundleChecksum == ReleaseV0100ProductionReadinessBundleChecksum.bundle, ReleaseV0100ProductionReadinessBundleChecksum.bundle, bundleChecksum)
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrueFlags(
        redactionProof: Bool,
        noSecretValue: Bool,
        noOrderPayload: Bool,
        upstreamEnvironmentProfileHeld: Bool,
        upstreamSecretReadinessHeld: Bool,
        upstreamEndpointPolicyReadinessHeld: Bool,
        upstreamCapitalExposureReadinessHeld: Bool,
        upstreamKillSwitchNoTradeReadinessHeld: Bool,
        upstreamCommandSurfaceDisabledProofHeld: Bool,
        upstreamShadowDryRunParityHeld: Bool,
        riskPolicySnapshotIncluded: Bool,
        portfolioReconciliationSnapshotIncluded: Bool,
        productionCutoverBlocked: Bool
    ) throws {
        let requiredTrueFlags = [
            ("redactionProof", redactionProof),
            ("noSecretValue", noSecretValue),
            ("noOrderPayload", noOrderPayload),
            ("upstreamEnvironmentProfileHeld", upstreamEnvironmentProfileHeld),
            ("upstreamSecretReadinessHeld", upstreamSecretReadinessHeld),
            ("upstreamEndpointPolicyReadinessHeld", upstreamEndpointPolicyReadinessHeld),
            ("upstreamCapitalExposureReadinessHeld", upstreamCapitalExposureReadinessHeld),
            ("upstreamKillSwitchNoTradeReadinessHeld", upstreamKillSwitchNoTradeReadinessHeld),
            ("upstreamCommandSurfaceDisabledProofHeld", upstreamCommandSurfaceDisabledProofHeld),
            ("upstreamShadowDryRunParityHeld", upstreamShadowDryRunParityHeld),
            ("riskPolicySnapshotIncluded", riskPolicySnapshotIncluded),
            ("portfolioReconciliationSnapshotIncluded", portfolioReconciliationSnapshotIncluded),
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
        orderPayloadCreated: Bool,
        brokerCommandCreated: Bool,
        productionOMSRuntimeEnabled: Bool,
        tradingButtonVisible: Bool,
        orderFormVisible: Bool,
        liveCommandEnabled: Bool,
        productionCommandEnabled: Bool,
        readinessApprovalConvertedToTradingPermission: Bool,
        bundleBypassEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("cutoverAuthorized", cutoverAuthorized),
            ("productionCutoverUnblocked", productionCutoverUnblocked),
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
            ("productionCommandEnabled", productionCommandEnabled),
            ("readinessApprovalConvertedToTradingPermission", readinessApprovalConvertedToTradingPermission),
            ("bundleBypassEnabled", bundleBypassEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
