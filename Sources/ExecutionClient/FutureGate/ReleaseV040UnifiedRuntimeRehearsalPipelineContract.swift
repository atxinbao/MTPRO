import DomainModel
import Foundation

/// ReleaseV040UnifiedRuntimeRehearsalMode 固定 GH-694 允许定义的 v0.4.0 rehearsal mode。
///
/// 这些 mode 只用于统一 rehearsal pipeline 合同。`productionBlocked` 是生产能力阻断证据，
/// 不是 production trading 开关，也不会读取 secret、连接 production endpoint 或发送真实订单。
public enum ReleaseV040UnifiedRuntimeRehearsalMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case shadow = "shadow"
    case testnetGuarded = "testnet-guarded"
    case productionBlocked = "production-blocked"
}

/// ReleaseV040UnifiedRuntimeModuleStep 固定一次 runID 必须串起的模块顺序。
///
/// GH-694 只定义顺序和 evidence envelope 要求；后续 issue 才能逐步实现各模块 runtime step。
public enum ReleaseV040UnifiedRuntimeModuleStep: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dataEngine = "DataEngine"
    case messageBus = "MessageBus"
    case traderStrategies = "Trader / EMA / RSI"
    case riskEngine = "RiskEngine"
    case executionEngineOMS = "ExecutionEngine / OMS"
    case binanceExecutionClient = "Binance dry-run / testnet-gated ExecutionClient"
    case eventStore = "Event Store"
    case portfolioProjection = "Portfolio projection"
    case dashboardCLI = "Dashboard / CLI"
}

/// ReleaseV040UnifiedRuntimeForbiddenCapability 枚举 v0.4.0 pipeline contract 必须拒绝的能力漂移。
public enum ReleaseV040UnifiedRuntimeForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case productionSecretAutoRead = "production secret auto-read"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionBrokerConnection = "production broker connection"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case unsupportedActiveStrategy = "unsupported active strategy"
    case missingUnifiedRunID = "missing unified runID"
    case splitEvidenceEnvelope = "split evidence envelope"
    case moduleOrderBypass = "module order bypass"
    case dashboardCLIDirectRuntimeAccess = "Dashboard / CLI direct runtime access"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ReleaseV040UnifiedRuntimeValidationExpectation 写入后续 issue 必须逐步满足的验证期望。
public enum ReleaseV040UnifiedRuntimeValidationExpectation: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case runContextEvidence = "RehearsalRunContext carries one runID"
    case unifiedEnvelopeEvidence = "all module evidence shares one envelope"
    case moduleOrderEvidence = "module order follows the canonical chain"
    case dryRunEvidence = "dry-run mode produces deterministic evidence"
    case shadowEvidence = "shadow mode replays without order submission"
    case testnetGuardEvidence = "guarded testnet mode remains explicitly gated"
    case dashboardCLIProjectionEvidence = "Dashboard / CLI consume unified run projection only"
    case productionBlockedEvidence = "production capability remains blocked by default"
    case releaseVerificationEvidence = "verify-v0.4.0 covers the unified chain"
}

/// ReleaseV040UnifiedRuntimeRehearsalPipelineContract 是 GH-694 的 v0.4.0 顶层合同。
///
/// 合同只定义 unified runtime rehearsal pipeline：一个 runID 串起 DataEngine 到 Dashboard / CLI
/// 的完整 evidence chain。它不实现 pipeline、不连接 testnet / production endpoint、不读取 secret、
/// 不提交真实订单，也不授权 production cutover。
public struct ReleaseV040UnifiedRuntimeRehearsalPipelineContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let allowedStrategies: [String]
    public let rehearsalModes: [ReleaseV040UnifiedRuntimeRehearsalMode]
    public let moduleOrder: [ReleaseV040UnifiedRuntimeModuleStep]
    public let forbiddenCapabilities: [ReleaseV040UnifiedRuntimeForbiddenCapability]
    public let validationExpectations: [ReleaseV040UnifiedRuntimeValidationExpectation]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let runIDRequiredAcrossAllEvidence: Bool
    public let unifiedEvidenceEnvelopeRequired: Bool
    public let dashboardCLIUnifiedProjectionOnly: Bool
    public let dryRunSemanticsDefined: Bool
    public let shadowSemanticsDefined: Bool
    public let guardedTestnetSemanticsDefined: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-694"
            && downstreamIssueID.rawValue == "GH-695"
            && canonicalQueueRange == "GH-694..GH-709"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.4.0"
            && allowedVenue == Self.requiredAllowedVenue
            && allowedProductTypes == Self.requiredAllowedProductTypes
            && allowedStrategies == Self.requiredAllowedStrategies
            && rehearsalModes == Self.requiredRehearsalModes
            && moduleOrder == Self.requiredModuleOrder
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationExpectations == Self.requiredValidationExpectations
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && runIdentityHeld
            && semanticsHeld
            && productionDefaultsClosed
            && startsNextMilestone == false
    }

    public var runIdentityHeld: Bool {
        runIDRequiredAcrossAllEvidence
            && unifiedEvidenceEnvelopeRequired
            && dashboardCLIUnifiedProjectionOnly
    }

    public var semanticsHeld: Bool {
        dryRunSemanticsDefined
            && shadowSemanticsDefined
            && guardedTestnetSemanticsDefined
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-694-release-v0.4.0-unified-runtime-rehearsal-pipeline-contract"),
        issueID: Identifier = Identifier.constant("GH-694"),
        downstreamIssueID: Identifier = Identifier.constant("GH-695"),
        canonicalQueueRange: String = "GH-694..GH-709",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.4.0",
        allowedVenue: String = Self.requiredAllowedVenue,
        allowedProductTypes: [String] = Self.requiredAllowedProductTypes,
        allowedStrategies: [String] = Self.requiredAllowedStrategies,
        rehearsalModes: [ReleaseV040UnifiedRuntimeRehearsalMode] = Self.requiredRehearsalModes,
        moduleOrder: [ReleaseV040UnifiedRuntimeModuleStep] = Self.requiredModuleOrder,
        forbiddenCapabilities: [ReleaseV040UnifiedRuntimeForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationExpectations: [ReleaseV040UnifiedRuntimeValidationExpectation] = Self.requiredValidationExpectations,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        runIDRequiredAcrossAllEvidence: Bool = true,
        unifiedEvidenceEnvelopeRequired: Bool = true,
        dashboardCLIUnifiedProjectionOnly: Bool = true,
        dryRunSemanticsDefined: Bool = true,
        shadowSemanticsDefined: Bool = true,
        guardedTestnetSemanticsDefined: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            allowedVenue: allowedVenue,
            allowedProductTypes: allowedProductTypes,
            allowedStrategies: allowedStrategies,
            rehearsalModes: rehearsalModes,
            moduleOrder: moduleOrder,
            forbiddenCapabilities: forbiddenCapabilities,
            validationExpectations: validationExpectations,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            runIDRequiredAcrossAllEvidence: runIDRequiredAcrossAllEvidence,
            unifiedEvidenceEnvelopeRequired: unifiedEvidenceEnvelopeRequired,
            dashboardCLIUnifiedProjectionOnly: dashboardCLIUnifiedProjectionOnly,
            dryRunSemanticsDefined: dryRunSemanticsDefined,
            shadowSemanticsDefined: shadowSemanticsDefined,
            guardedTestnetSemanticsDefined: guardedTestnetSemanticsDefined
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            startsNextMilestone: startsNextMilestone
        )

        self.contractID = contractID
        self.issueID = issueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.allowedVenue = allowedVenue
        self.allowedProductTypes = allowedProductTypes
        self.allowedStrategies = allowedStrategies
        self.rehearsalModes = rehearsalModes
        self.moduleOrder = moduleOrder
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationExpectations = validationExpectations
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.runIDRequiredAcrossAllEvidence = runIDRequiredAcrossAllEvidence
        self.unifiedEvidenceEnvelopeRequired = unifiedEvidenceEnvelopeRequired
        self.dashboardCLIUnifiedProjectionOnly = dashboardCLIUnifiedProjectionOnly
        self.dryRunSemanticsDefined = dryRunSemanticsDefined
        self.shadowSemanticsDefined = shadowSemanticsDefined
        self.guardedTestnetSemanticsDefined = guardedTestnetSemanticsDefined
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ReleaseV040UnifiedRuntimeRehearsalPipelineContract {
        try ReleaseV040UnifiedRuntimeRehearsalPipelineContract()
    }

    public static let requiredProjectName = "MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline"
    public static let requiredAllowedVenue = "Binance"
    public static let requiredAllowedProductTypes = ["spot", "usdsPerpetual"]
    public static let requiredAllowedStrategies = ["EMA", "RSI"]
    public static let requiredRehearsalModes = ReleaseV040UnifiedRuntimeRehearsalMode.allCases
    public static let requiredModuleOrder = ReleaseV040UnifiedRuntimeModuleStep.allCases
    public static let requiredForbiddenCapabilities = ReleaseV040UnifiedRuntimeForbiddenCapability.allCases
    public static let requiredValidationExpectations = ReleaseV040UnifiedRuntimeValidationExpectation.allCases

    public static let requiredValidationAnchors = [
        "V040-01-UNIFIED-RUNTIME-REHEARSAL-PIPELINE-CONTRACT",
        "V040-01-ONE-RUNID-EVIDENCE-CHAIN",
        "V040-01-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY",
        "V040-01-DRYRUN-SHADOW-TESTNET-GUARDED-SEMANTICS",
        "V040-01-DASHBOARD-CLI-UNIFIED-RUN-PROJECTION",
        "V040-01-FORBIDDEN-PRODUCTION-CAPABILITIES",
        "TVM-RELEASE-V040-UNIFIED-RUNTIME-REHEARSAL-PIPELINE-CONTRACT"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH694ReleaseV040UnifiedRuntimeRehearsalPipelineContractRequiresOneRunID",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV040UnifiedRuntimeRehearsalPipelineContract {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        allowedVenue: String,
        allowedProductTypes: [String],
        allowedStrategies: [String],
        rehearsalModes: [ReleaseV040UnifiedRuntimeRehearsalMode],
        moduleOrder: [ReleaseV040UnifiedRuntimeModuleStep],
        forbiddenCapabilities: [ReleaseV040UnifiedRuntimeForbiddenCapability],
        validationExpectations: [ReleaseV040UnifiedRuntimeValidationExpectation],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-694..GH-709", "GH-694..GH-709", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.4.0", "v0.4.0", releaseVersion),
            ("allowedVenue", allowedVenue == requiredAllowedVenue, requiredAllowedVenue, allowedVenue),
            (
                "allowedProductTypes",
                allowedProductTypes == requiredAllowedProductTypes,
                requiredAllowedProductTypes.joined(separator: ","),
                allowedProductTypes.joined(separator: ",")
            ),
            (
                "allowedStrategies",
                allowedStrategies == requiredAllowedStrategies,
                requiredAllowedStrategies.joined(separator: ","),
                allowedStrategies.joined(separator: ",")
            ),
            (
                "rehearsalModes",
                rehearsalModes == requiredRehearsalModes,
                requiredRehearsalModes.map(\.rawValue).joined(separator: ","),
                rehearsalModes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "moduleOrder",
                moduleOrder == requiredModuleOrder,
                requiredModuleOrder.map(\.rawValue).joined(separator: " -> "),
                moduleOrder.map(\.rawValue).joined(separator: " -> ")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "validationExpectations",
                validationExpectations == requiredValidationExpectations,
                requiredValidationExpectations.map(\.rawValue).joined(separator: ","),
                validationExpectations.map(\.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrueFlags(
        runIDRequiredAcrossAllEvidence: Bool,
        unifiedEvidenceEnvelopeRequired: Bool,
        dashboardCLIUnifiedProjectionOnly: Bool,
        dryRunSemanticsDefined: Bool,
        shadowSemanticsDefined: Bool,
        guardedTestnetSemanticsDefined: Bool
    ) throws {
        let requiredTrueFlags = [
            ("runIDRequiredAcrossAllEvidence", runIDRequiredAcrossAllEvidence),
            ("unifiedEvidenceEnvelopeRequired", unifiedEvidenceEnvelopeRequired),
            ("dashboardCLIUnifiedProjectionOnly", dashboardCLIUnifiedProjectionOnly),
            ("dryRunSemanticsDefined", dryRunSemanticsDefined),
            ("shadowSemanticsDefined", shadowSemanticsDefined),
            ("guardedTestnetSemanticsDefined", guardedTestnetSemanticsDefined)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
