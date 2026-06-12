import DomainModel
import Foundation

/// ReleaseV030RuntimeRehearsalMode 固定 GH-657 允许讨论的 v0.3.0 rehearsal mode。
///
/// 这些 mode 只用于 release rehearsal evidence。`productionBlocked` 是阻断状态，不是
/// production trading 开关，也不会读取 secret、连接 production endpoint 或发送真实订单。
public enum ReleaseV030RuntimeRehearsalMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case testnet = "testnet"
    case shadow = "shadow"
    case productionBlocked = "production-blocked"
}

/// ReleaseV030RuntimeRehearsalForbiddenCapability 枚举 GH-657 必须拒绝的生产能力和 bypass。
///
/// 该枚举是 contract guard：任一对应布尔开关为 true 都说明 rehearsal scope 被扩大，
/// 构造 deterministic evidence 时必须 fail closed。
public enum ReleaseV030RuntimeRehearsalForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case productionSecretAutoRead = "production secret auto-read"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case unsupportedActiveStrategy = "unsupported active strategy"
    case dashboardCLICommandGatewayBypass = "Dashboard / CLI CommandGateway bypass"
    case strategyExecutionClientDirectAccess = "Strategy direct ExecutionClient access"
    case riskExecutionOMSEventStoreBypass = "RiskEngine / ExecutionEngine / OMS / Event Store bypass"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ReleaseV030RuntimeRehearsalSuccessCriterion 描述未来 one-command rehearsal 必须覆盖的证据面。
///
/// GH-657 只定义 success criteria，不新增 `verify-v0.3.0` runner，也不连接 testnet 或 production。
/// 后续 issue 必须逐项回填这些 criteria 的 deterministic evidence。
public enum ReleaseV030RuntimeRehearsalSuccessCriterion: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dataEngineCacheEvidence = "DataEngine -> Cache rehearsal evidence"
    case traderStrategyEvidence = "Trader / EMA / RSI rehearsal evidence"
    case riskEngineGateEvidence = "RiskEngine rehearsal gate evidence"
    case executionEngineOMSEvidence = "ExecutionEngine / OMS rehearsal lifecycle evidence"
    case executionClientDryRunTestnetEvidence = "ExecutionClient dry-run / testnet evidence"
    case eventStoreReplayEvidence = "Event Store / replay rehearsal evidence"
    case portfolioProjectionEvidence = "Portfolio projection rehearsal evidence"
    case dashboardCLICommandGatewayEvidence = "Dashboard / CLI CommandGateway rehearsal evidence"
    case killSwitchNoTradeRollbackEvidence = "kill switch / no-trade / rollback rehearsal evidence"
    case forbiddenProductionCapabilityGuardEvidence = "forbidden production capability guard evidence"
}

/// ReleaseV030RuntimeRehearsalContract 是 GH-657 的 v0.3.0 runtime rehearsal 顶层合同。
///
/// 合同固定 v0.3.0 只能是 dry-run / testnet / shadow / production-blocked rehearsal release：
/// Binance-only、Spot + USDⓈ-M Perpetual-only、EMA + RSI-only，并保持 production trading 默认关闭。
public struct ReleaseV030RuntimeRehearsalContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let allowedStrategies: [String]
    public let rehearsalModes: [ReleaseV030RuntimeRehearsalMode]
    public let forbiddenCapabilities: [ReleaseV030RuntimeRehearsalForbiddenCapability]
    public let oneCommandRehearsalName: String
    public let successCriteria: [ReleaseV030RuntimeRehearsalSuccessCriterion]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let commandGatewayRequired: Bool
    public let riskEngineRequired: Bool
    public let executionEngineRequired: Bool
    public let omsRequired: Bool
    public let eventStoreRequired: Bool
    public let dashboardCLICommandGatewayBypassAllowed: Bool
    public let strategyExecutionClientDirectAccessAllowed: Bool
    public let riskExecutionOMSEventStoreBypassAllowed: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-657"
            && downstreamIssueID.rawValue == "GH-658"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.3.0"
            && allowedVenue == Self.requiredAllowedVenue
            && allowedProductTypes == Self.requiredAllowedProductTypes
            && allowedStrategies == Self.requiredAllowedStrategies
            && rehearsalModes == Self.requiredRehearsalModes
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && oneCommandRehearsalName == Self.requiredOneCommandRehearsalName
            && successCriteria == Self.requiredSuccessCriteria
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionDefaultsClosed
            && commandGateChainRequired
            && bypassesRejected
            && startsNextMilestone == false
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
    }

    public var commandGateChainRequired: Bool {
        commandGatewayRequired
            && riskEngineRequired
            && executionEngineRequired
            && omsRequired
            && eventStoreRequired
    }

    public var bypassesRejected: Bool {
        dashboardCLICommandGatewayBypassAllowed == false
            && strategyExecutionClientDirectAccessAllowed == false
            && riskExecutionOMSEventStoreBypassAllowed == false
    }

    public var oneCommandCriteriaHeld: Bool {
        oneCommandRehearsalName == Self.requiredOneCommandRehearsalName
            && successCriteria == Self.requiredSuccessCriteria
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-657-release-v0.3.0-runtime-rehearsal-contract"),
        issueID: Identifier = Identifier.constant("GH-657"),
        downstreamIssueID: Identifier = Identifier.constant("GH-658"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.3.0",
        allowedVenue: String = Self.requiredAllowedVenue,
        allowedProductTypes: [String] = Self.requiredAllowedProductTypes,
        allowedStrategies: [String] = Self.requiredAllowedStrategies,
        rehearsalModes: [ReleaseV030RuntimeRehearsalMode] = Self.requiredRehearsalModes,
        forbiddenCapabilities: [ReleaseV030RuntimeRehearsalForbiddenCapability] = Self.requiredForbiddenCapabilities,
        oneCommandRehearsalName: String = Self.requiredOneCommandRehearsalName,
        successCriteria: [ReleaseV030RuntimeRehearsalSuccessCriterion] = Self.requiredSuccessCriteria,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        commandGatewayRequired: Bool = true,
        riskEngineRequired: Bool = true,
        executionEngineRequired: Bool = true,
        omsRequired: Bool = true,
        eventStoreRequired: Bool = true,
        dashboardCLICommandGatewayBypassAllowed: Bool = false,
        strategyExecutionClientDirectAccessAllowed: Bool = false,
        riskExecutionOMSEventStoreBypassAllowed: Bool = false,
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
            forbiddenCapabilities: forbiddenCapabilities,
            oneCommandRehearsalName: oneCommandRehearsalName,
            successCriteria: successCriteria,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            commandGatewayRequired: commandGatewayRequired,
            riskEngineRequired: riskEngineRequired,
            executionEngineRequired: executionEngineRequired,
            omsRequired: omsRequired,
            eventStoreRequired: eventStoreRequired
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            dashboardCLICommandGatewayBypassAllowed: dashboardCLICommandGatewayBypassAllowed,
            strategyExecutionClientDirectAccessAllowed: strategyExecutionClientDirectAccessAllowed,
            riskExecutionOMSEventStoreBypassAllowed: riskExecutionOMSEventStoreBypassAllowed,
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
        self.forbiddenCapabilities = forbiddenCapabilities
        self.oneCommandRehearsalName = oneCommandRehearsalName
        self.successCriteria = successCriteria
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.commandGatewayRequired = commandGatewayRequired
        self.riskEngineRequired = riskEngineRequired
        self.executionEngineRequired = executionEngineRequired
        self.omsRequired = omsRequired
        self.eventStoreRequired = eventStoreRequired
        self.dashboardCLICommandGatewayBypassAllowed = dashboardCLICommandGatewayBypassAllowed
        self.strategyExecutionClientDirectAccessAllowed = strategyExecutionClientDirectAccessAllowed
        self.riskExecutionOMSEventStoreBypassAllowed = riskExecutionOMSEventStoreBypassAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ReleaseV030RuntimeRehearsalContract {
        try ReleaseV030RuntimeRehearsalContract()
    }

    public static let requiredProjectName = "MTPRO Release v0.3.0 Runtime Rehearsal v1"
    public static let requiredAllowedVenue = "Binance"
    public static let requiredAllowedProductTypes = ["spot", "usdsPerpetual"]
    public static let requiredAllowedStrategies = ["EMA", "RSI"]
    public static let requiredRehearsalModes = ReleaseV030RuntimeRehearsalMode.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030RuntimeRehearsalForbiddenCapability.allCases
    public static let requiredOneCommandRehearsalName = "verify-v0.3.0"
    public static let requiredSuccessCriteria = ReleaseV030RuntimeRehearsalSuccessCriterion.allCases

    public static let requiredValidationAnchors = [
        "V030-01-RUNTIME-REHEARSAL-CONTRACT",
        "V030-01-REHEARSAL-MODES",
        "V030-01-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY",
        "V030-01-FORBIDDEN-PRODUCTION-CAPABILITIES",
        "V030-01-ONE-COMMAND-REHEARSAL-SUCCESS-CRITERIA",
        "V030-01-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-AUDITABLE-GATES",
        "TVM-RELEASE-V030-RUNTIME-REHEARSAL-CONTRACT"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH657ReleaseV030RuntimeRehearsalContractDefinesDryRunTestnetShadowBoundary",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV030RuntimeRehearsalContract {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        allowedVenue: String,
        allowedProductTypes: [String],
        allowedStrategies: [String],
        rehearsalModes: [ReleaseV030RuntimeRehearsalMode],
        forbiddenCapabilities: [ReleaseV030RuntimeRehearsalForbiddenCapability],
        oneCommandRehearsalName: String,
        successCriteria: [ReleaseV030RuntimeRehearsalSuccessCriterion],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.3.0", "v0.3.0", releaseVersion),
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
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "oneCommandRehearsalName",
                oneCommandRehearsalName == requiredOneCommandRehearsalName,
                requiredOneCommandRehearsalName,
                oneCommandRehearsalName
            ),
            (
                "successCriteria",
                successCriteria == requiredSuccessCriteria,
                requiredSuccessCriteria.map(\.rawValue).joined(separator: ","),
                successCriteria.map(\.rawValue).joined(separator: ",")
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
        commandGatewayRequired: Bool,
        riskEngineRequired: Bool,
        executionEngineRequired: Bool,
        omsRequired: Bool,
        eventStoreRequired: Bool
    ) throws {
        let requiredTrueFlags = [
            ("commandGatewayRequired", commandGatewayRequired),
            ("riskEngineRequired", riskEngineRequired),
            ("executionEngineRequired", executionEngineRequired),
            ("omsRequired", omsRequired),
            ("eventStoreRequired", eventStoreRequired)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        dashboardCLICommandGatewayBypassAllowed: Bool,
        strategyExecutionClientDirectAccessAllowed: Bool,
        riskExecutionOMSEventStoreBypassAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("dashboardCLICommandGatewayBypassAllowed", dashboardCLICommandGatewayBypassAllowed),
            ("strategyExecutionClientDirectAccessAllowed", strategyExecutionClientDirectAccessAllowed),
            ("riskExecutionOMSEventStoreBypassAllowed", riskExecutionOMSEventStoreBypassAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
