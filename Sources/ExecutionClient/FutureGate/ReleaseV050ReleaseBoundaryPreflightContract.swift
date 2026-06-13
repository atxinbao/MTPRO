import DomainModel
import Foundation

/// ReleaseV050RuntimeMode 固定 GH-726 允许进入 v0.5.0 的运行模式语义。
///
/// 这些 mode 只定义 release boundary。`testnetGuarded` 必须显式 operator 确认，
/// `productionBlocked` 只作为阻断证据存在，不授权 production cutover。
public enum ReleaseV050RuntimeMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case testnetGuarded = "testnet-guarded"
    case productionBlocked = "production-blocked"
}

/// ReleaseV050PreflightRequirement 列出后续 V050 issue 执行前必须满足的 preflight 条件。
///
/// 它只描述可验证的 gate，不读取 secret、不连接 endpoint，也不替代 GitHub issue WIP=1 queue。
public enum ReleaseV050PreflightRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case githubQueueWIPOne = "GitHub fallback queue WIP=1"
    case noActiveIssueConflict = "no todo / in-progress / in-review conflict"
    case previousReleaseVerificationPreserved = "previous release verification remains preserved"
    case issueContractReadBeforeWork = "current issue contract is read before work"
    case dryRunDefaultMode = "dry-run remains default mode"
    case testnetRequiresExplicitOperatorConfirmation = "testnet requires explicit operator confirmation"
    case productionBlockedDefaultMode = "production remains blocked by default"
    case binanceOnlyScope = "Binance-only scope"
    case spotAndUSDMScope = "Spot and USDⓈ-M Perpetual only"
    case emaAndRSIScope = "EMA and RSI only"
    case noProductionSecretRead = "no production secret read"
    case noProductionEndpointConnection = "no production endpoint connection"
    case noRealOrderAuthorization = "no real order authorization"
    case verifyV050PreflightScript = "verify-v0.5.0-preflight command exists"
}

/// ReleaseV050ForbiddenCapability 枚举 v0.5.0 guarded foundation 必须继续拒绝的能力。
public enum ReleaseV050ForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionCutoverAuthorization = "production cutover authorization"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case productionSecretRead = "production secret read"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case realOrderSubmitCancelReplace = "real submit / cancel / replace"
    case tradingButtonOrOrderForm = "trading button or order form"
    case livePROConsoleCommand = "Live PRO Console command"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case unsupportedActiveStrategy = "unsupported active strategy"
    case riskExecutionOMSBypass = "RiskEngine / ExecutionEngine / OMS bypass"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ReleaseV050ReleaseBoundaryPreflightContract 是 GH-726 的 v0.5.0 顶层边界合同。
///
/// 合同只定义 guarded testnet runtime foundation 的边界、preflight 和验证锚点。
/// 它不实现 runtime、不读取 secret、不连接 testnet 或 production endpoint、不发送真实订单。
public struct ReleaseV050ReleaseBoundaryPreflightContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let allowedStrategies: [String]
    public let allowedModes: [ReleaseV050RuntimeMode]
    public let preflightRequirements: [ReleaseV050PreflightRequirement]
    public let forbiddenCapabilities: [ReleaseV050ForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let dryRunIsDefault: Bool
    public let testnetRequiresOperatorConfirmation: Bool
    public let testnetSecretValueReadEnabled: Bool
    public let testnetNetworkConnectionEnabledByThisIssue: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let realOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-726"
            && downstreamIssueIDs.map(\.rawValue) == Self.requiredDownstreamIssueIDs.map(\.rawValue)
            && canonicalQueueRange == "GH-726..GH-739"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.5.0"
            && allowedVenue == Self.requiredAllowedVenue
            && allowedProductTypes == Self.requiredAllowedProductTypes
            && allowedStrategies == Self.requiredAllowedStrategies
            && allowedModes == Self.requiredAllowedModes
            && preflightRequirements == Self.requiredPreflightRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && modeBoundaryHeld
            && productionDefaultsClosed
            && startsNextMilestone == false
    }

    public var modeBoundaryHeld: Bool {
        dryRunIsDefault
            && testnetRequiresOperatorConfirmation
            && testnetSecretValueReadEnabled == false
            && testnetNetworkConnectionEnabledByThisIssue == false
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && realOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-726-release-v0.5.0-boundary-preflight-contract"),
        issueID: Identifier = Identifier.constant("GH-726"),
        downstreamIssueIDs: [Identifier] = Self.requiredDownstreamIssueIDs,
        canonicalQueueRange: String = "GH-726..GH-739",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.5.0",
        allowedVenue: String = Self.requiredAllowedVenue,
        allowedProductTypes: [String] = Self.requiredAllowedProductTypes,
        allowedStrategies: [String] = Self.requiredAllowedStrategies,
        allowedModes: [ReleaseV050RuntimeMode] = Self.requiredAllowedModes,
        preflightRequirements: [ReleaseV050PreflightRequirement] = Self.requiredPreflightRequirements,
        forbiddenCapabilities: [ReleaseV050ForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        dryRunIsDefault: Bool = true,
        testnetRequiresOperatorConfirmation: Bool = true,
        testnetSecretValueReadEnabled: Bool = false,
        testnetNetworkConnectionEnabledByThisIssue: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        realOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            downstreamIssueIDs: downstreamIssueIDs,
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            allowedVenue: allowedVenue,
            allowedProductTypes: allowedProductTypes,
            allowedStrategies: allowedStrategies,
            allowedModes: allowedModes,
            preflightRequirements: preflightRequirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            dryRunIsDefault: dryRunIsDefault,
            testnetRequiresOperatorConfirmation: testnetRequiresOperatorConfirmation
        )
        try Self.validateForbiddenFlags(
            testnetSecretValueReadEnabled: testnetSecretValueReadEnabled,
            testnetNetworkConnectionEnabledByThisIssue: testnetNetworkConnectionEnabledByThisIssue,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretReadEnabled: productionSecretReadEnabled,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            realOrderSubmitCancelReplaceEnabled: realOrderSubmitCancelReplaceEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            startsNextMilestone: startsNextMilestone
        )

        self.contractID = contractID
        self.issueID = issueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.allowedVenue = allowedVenue
        self.allowedProductTypes = allowedProductTypes
        self.allowedStrategies = allowedStrategies
        self.allowedModes = allowedModes
        self.preflightRequirements = preflightRequirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.dryRunIsDefault = dryRunIsDefault
        self.testnetRequiresOperatorConfirmation = testnetRequiresOperatorConfirmation
        self.testnetSecretValueReadEnabled = testnetSecretValueReadEnabled
        self.testnetNetworkConnectionEnabledByThisIssue = testnetNetworkConnectionEnabledByThisIssue
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.realOrderSubmitCancelReplaceEnabled = realOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ReleaseV050ReleaseBoundaryPreflightContract {
        try ReleaseV050ReleaseBoundaryPreflightContract()
    }

    public static let requiredProjectName =
        "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge"
    public static let requiredAllowedVenue = "Binance"
    public static let requiredAllowedProductTypes = ["spot", "usdsPerpetual"]
    public static let requiredAllowedStrategies = ["EMA", "RSI"]
    public static let requiredAllowedModes = ReleaseV050RuntimeMode.allCases
    public static let requiredPreflightRequirements = ReleaseV050PreflightRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV050ForbiddenCapability.allCases
    public static let requiredDownstreamIssueIDs = (727...739).map { Identifier.constant("GH-\($0)") }

    public static let requiredValidationAnchors = [
        "V050-01-RELEASE-BOUNDARY-PREFLIGHT-CONTRACT",
        "V050-01-GUARDED-RUNTIME-FOUNDATION",
        "V050-01-DRYRUN-TESTNET-PRODUCTION-BLOCKED-MODES",
        "V050-01-BINANCE-SPOT-PERP-EMA-RSI-ONLY",
        "V050-01-PREFLIGHT-REQUIREMENTS",
        "V050-01-FORBIDDEN-PRODUCTION-CAPABILITIES",
        "TVM-RELEASE-V050-BOUNDARY-PREFLIGHT-CONTRACT"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH726ReleaseV050BoundaryPreflightContractDefinesGuardedRuntimeFoundation",
        "bash checks/verify-v0.5.0-preflight.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

private extension ReleaseV050ReleaseBoundaryPreflightContract {
    static func validateRequired(
        downstreamIssueIDs: [Identifier],
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        allowedVenue: String,
        allowedProductTypes: [String],
        allowedStrategies: [String],
        allowedModes: [ReleaseV050RuntimeMode],
        preflightRequirements: [ReleaseV050PreflightRequirement],
        forbiddenCapabilities: [ReleaseV050ForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            (
                "downstreamIssueIDs",
                downstreamIssueIDs.map(\.rawValue) == requiredDownstreamIssueIDs.map(\.rawValue),
                requiredDownstreamIssueIDs.map(\.rawValue).joined(separator: ","),
                downstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            ),
            ("canonicalQueueRange", canonicalQueueRange == "GH-726..GH-739", "GH-726..GH-739", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.5.0", "v0.5.0", releaseVersion),
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
                "allowedModes",
                allowedModes == requiredAllowedModes,
                requiredAllowedModes.map(\.rawValue).joined(separator: ","),
                allowedModes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "preflightRequirements",
                preflightRequirements == requiredPreflightRequirements,
                requiredPreflightRequirements.map(\.rawValue).joined(separator: ","),
                preflightRequirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
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
        dryRunIsDefault: Bool,
        testnetRequiresOperatorConfirmation: Bool
    ) throws {
        for (field, value) in [
            ("dryRunIsDefault", dryRunIsDefault),
            ("testnetRequiresOperatorConfirmation", testnetRequiresOperatorConfirmation)
        ] where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        testnetSecretValueReadEnabled: Bool,
        testnetNetworkConnectionEnabledByThisIssue: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretReadEnabled: Bool,
        productionEndpointConnectionEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        realOrderSubmitCancelReplaceEnabled: Bool,
        productionCutoverAuthorized: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("testnetSecretValueReadEnabled", testnetSecretValueReadEnabled),
            ("testnetNetworkConnectionEnabledByThisIssue", testnetNetworkConnectionEnabledByThisIssue),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretReadEnabled", productionSecretReadEnabled),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("realOrderSubmitCancelReplaceEnabled", realOrderSubmitCancelReplaceEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
