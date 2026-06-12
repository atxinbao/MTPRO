import DomainModel
import Foundation

/// ProductionCutoverRuntimeHardeningGateRequirement 固定 GH-643 的 production cutover runtime hardening 必备门槛。
///
/// 这些 requirement 只表达 release 后继续保持 fail-closed 的合同边界，不会读取 secret、
/// 连接 production endpoint、启用真实 broker、提交真实订单或绕过 CommandGateway / RiskEngine / ExecutionEngine / OMS / Event Store。
public enum ProductionCutoverRuntimeHardeningGateRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingDefaultDisabled = "production trading disabled by default"
    case realBrokerDefaultDisabled = "real broker disabled by default"
    case productionEndpointDefaultDisabled = "production endpoint disabled by default"
    case operatorApprovalRequired = "operator approval required"
    case allGatePassRequired = "all gate pass required"
    case noSecretAutoRead = "no secret auto-read"
    case noEndpointAutoConnect = "no endpoint auto-connect"
    case commandGatewayRequired = "CommandGateway required"
    case riskEngineRequired = "RiskEngine required"
    case executionEngineRequired = "ExecutionEngine required"
    case omsRequired = "OMS required"
    case eventStoreRequired = "Event Store required"
}

/// ProductionCutoverRuntimeHardeningForbiddenCapability 枚举 GH-643 必须拒绝的生产能力与 bypass。
///
/// 它们是 fail-closed evidence，不是 feature flag。任何 true 值都表示当前仓库尝试越过
/// production cutover gate，必须在构造合同证据时直接失败。
public enum ProductionCutoverRuntimeHardeningForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case realBrokerEnabledByDefault = "real broker enabled by default"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretAutoRead = "production secret auto-read"
    case operatorApprovalBypass = "operator approval bypass"
    case gatePassBypass = "gate pass bypass"
    case commandGatewayBypass = "CommandGateway bypass"
    case riskEngineBypass = "RiskEngine bypass"
    case executionEngineBypass = "ExecutionEngine bypass"
    case omsBypass = "OMS bypass"
    case eventStoreBypass = "Event Store bypass"
    case realOrderSubmission = "real order submission"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case unsupportedActiveStrategy = "unsupported active strategy"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ProductionCutoverRuntimeHardeningGatePassRequirement 描述进入任何 production-capable path 前的强制 gate pass。
///
/// `requiredBeforeProductionCapablePath` 必须为 true，`bypassAllowed` 必须为 false，确保
/// CommandGateway / RiskEngine / ExecutionEngine / OMS / Event Store 不能被配置、脚本或 UI 旁路。
public struct ProductionCutoverRuntimeHardeningGatePassRequirement: Codable, Equatable, Sendable {
    public let gateName: String
    public let requiredAnchor: String
    public let requiredBeforeProductionCapablePath: Bool
    public let bypassAllowed: Bool

    public init(
        gateName: String,
        requiredAnchor: String,
        requiredBeforeProductionCapablePath: Bool = true,
        bypassAllowed: Bool = false
    ) throws {
        guard gateName.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "gateName",
                expected: "non-empty production hardening gate name",
                actual: "empty"
            )
        }
        guard requiredAnchor.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredAnchor",
                expected: "non-empty production hardening anchor",
                actual: "empty"
            )
        }
        guard requiredBeforeProductionCapablePath else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredBeforeProductionCapablePath",
                expected: "true",
                actual: "false"
            )
        }
        guard bypassAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("bypassAllowed")
        }

        self.gateName = gateName
        self.requiredAnchor = requiredAnchor
        self.requiredBeforeProductionCapablePath = requiredBeforeProductionCapablePath
        self.bypassAllowed = bypassAllowed
    }
}

/// ProductionCutoverRuntimeHardeningContract 是 GH-643 的生产切换运行时加固合同。
///
/// 合同只定义 release v0.2.0 后生产路径仍应保持的 fail-closed 基线：Binance-only、
/// Spot + USDⓈ-M Perpetual-only、EMA + RSI-only、production trading 默认关闭、
/// secret 与 endpoint 不自动读取或连接，以及 CommandGateway / RiskEngine / ExecutionEngine / OMS / Event Store 不可绕过。
public struct ProductionCutoverRuntimeHardeningContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let allowedStrategies: [String]
    public let requirements: [ProductionCutoverRuntimeHardeningGateRequirement]
    public let forbiddenCapabilities: [ProductionCutoverRuntimeHardeningForbiddenCapability]
    public let gatePassRequirements: [ProductionCutoverRuntimeHardeningGatePassRequirement]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let realBrokerEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let operatorApprovalRequired: Bool
    public let allGatePassesRequired: Bool
    public let commandGatewayBypassAllowed: Bool
    public let riskEngineBypassAllowed: Bool
    public let executionEngineBypassAllowed: Bool
    public let omsBypassAllowed: Bool
    public let eventStoreBypassAllowed: Bool
    public let realOrderSubmissionEnabled: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-643"
            && downstreamIssueID.rawValue == "GH-644"
            && canonicalQueueRange == "GH-643..GH-649"
            && projectName == Self.requiredProjectName
            && allowedVenue == Self.requiredAllowedVenue
            && allowedProductTypes == Self.requiredAllowedProductTypes
            && allowedStrategies == Self.requiredAllowedStrategies
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && gatePassRequirements == Self.requiredGatePassRequirements
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && operatorApprovalRequired
            && allGatePassesRequired
            && productionCapabilityDefaultsClosed
            && gateBypassRejected
            && realOrderSubmissionEnabled == false
            && startsNextMilestone == false
    }

    public var productionCapabilityDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && realBrokerEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
    }

    public var gateBypassRejected: Bool {
        commandGatewayBypassAllowed == false
            && riskEngineBypassAllowed == false
            && executionEngineBypassAllowed == false
            && omsBypassAllowed == false
            && eventStoreBypassAllowed == false
    }

    public var gatePassCoverageHeld: Bool {
        Set(gatePassRequirements.map(\.requiredAnchor)) == Set(Self.requiredGatePassRequirements.map(\.requiredAnchor))
            && gatePassRequirements.allSatisfy(\.requiredBeforeProductionCapablePath)
            && gatePassRequirements.allSatisfy { $0.bypassAllowed == false }
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-643-production-cutover-runtime-hardening-contract"),
        issueID: Identifier = Identifier.constant("GH-643"),
        downstreamIssueID: Identifier = Identifier.constant("GH-644"),
        canonicalQueueRange: String = "GH-643..GH-649",
        projectName: String = Self.requiredProjectName,
        allowedVenue: String = Self.requiredAllowedVenue,
        allowedProductTypes: [String] = Self.requiredAllowedProductTypes,
        allowedStrategies: [String] = Self.requiredAllowedStrategies,
        requirements: [ProductionCutoverRuntimeHardeningGateRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ProductionCutoverRuntimeHardeningForbiddenCapability] = Self.requiredForbiddenCapabilities,
        gatePassRequirements: [ProductionCutoverRuntimeHardeningGatePassRequirement] = Self.requiredGatePassRequirements,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        realBrokerEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        operatorApprovalRequired: Bool = true,
        allGatePassesRequired: Bool = true,
        commandGatewayBypassAllowed: Bool = false,
        riskEngineBypassAllowed: Bool = false,
        executionEngineBypassAllowed: Bool = false,
        omsBypassAllowed: Bool = false,
        eventStoreBypassAllowed: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            allowedVenue: allowedVenue,
            allowedProductTypes: allowedProductTypes,
            allowedStrategies: allowedStrategies,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            gatePassRequirements: gatePassRequirements,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            operatorApprovalRequired: operatorApprovalRequired,
            allGatePassesRequired: allGatePassesRequired
        )
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            realBrokerEnabledByDefault: realBrokerEnabledByDefault,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            riskEngineBypassAllowed: riskEngineBypassAllowed,
            executionEngineBypassAllowed: executionEngineBypassAllowed,
            omsBypassAllowed: omsBypassAllowed,
            eventStoreBypassAllowed: eventStoreBypassAllowed,
            realOrderSubmissionEnabled: realOrderSubmissionEnabled,
            startsNextMilestone: startsNextMilestone
        )

        self.contractID = contractID
        self.issueID = issueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.allowedVenue = allowedVenue
        self.allowedProductTypes = allowedProductTypes
        self.allowedStrategies = allowedStrategies
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.gatePassRequirements = gatePassRequirements
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.realBrokerEnabledByDefault = realBrokerEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.operatorApprovalRequired = operatorApprovalRequired
        self.allGatePassesRequired = allGatePassesRequired
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.riskEngineBypassAllowed = riskEngineBypassAllowed
        self.executionEngineBypassAllowed = executionEngineBypassAllowed
        self.omsBypassAllowed = omsBypassAllowed
        self.eventStoreBypassAllowed = eventStoreBypassAllowed
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ProductionCutoverRuntimeHardeningContract {
        try ProductionCutoverRuntimeHardeningContract()
    }

    public static let requiredProjectName = "MTPRO Production Cutover Runtime Hardening v1"
    public static let requiredAllowedVenue = "Binance"
    public static let requiredAllowedProductTypes = ["spot", "usdsPerpetual"]
    public static let requiredAllowedStrategies = ["EMA", "RSI"]
    public static let requiredRequirements = ProductionCutoverRuntimeHardeningGateRequirement.allCases
    public static let requiredForbiddenCapabilities = ProductionCutoverRuntimeHardeningForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "PCHR-01-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT",
        "PCHR-01-PRODUCTION-TRADING-DEFAULT-DISABLED",
        "PCHR-01-REAL-BROKER-PRODUCTION-ENDPOINT-DEFAULT-OFF",
        "PCHR-01-OPERATOR-APPROVAL-AND-GATE-PASS-REQUIRED",
        "PCHR-01-NO-SECRET-AUTO-READ",
        "PCHR-01-NO-ENDPOINT-AUTO-CONNECT",
        "PCHR-01-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-NO-BYPASS",
        "TVM-PCHR-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH643ProductionCutoverRuntimeHardeningContractFailsClosedWithoutProductionCutover",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredGatePassRequirements: [ProductionCutoverRuntimeHardeningGatePassRequirement] = {
        do {
            return [
                try ProductionCutoverRuntimeHardeningGatePassRequirement(
                    gateName: "CommandGateway",
                    requiredAnchor: "PCHR-01-COMMANDGATEWAY-REQUIRED"
                ),
                try ProductionCutoverRuntimeHardeningGatePassRequirement(
                    gateName: "RiskEngine",
                    requiredAnchor: "PCHR-01-RISKENGINE-REQUIRED"
                ),
                try ProductionCutoverRuntimeHardeningGatePassRequirement(
                    gateName: "ExecutionEngine",
                    requiredAnchor: "PCHR-01-EXECUTIONENGINE-REQUIRED"
                ),
                try ProductionCutoverRuntimeHardeningGatePassRequirement(
                    gateName: "OMS",
                    requiredAnchor: "PCHR-01-OMS-REQUIRED"
                ),
                try ProductionCutoverRuntimeHardeningGatePassRequirement(
                    gateName: "Event Store",
                    requiredAnchor: "PCHR-01-EVENT-STORE-REQUIRED"
                )
            ]
        } catch {
            preconditionFailure("GH-643 production hardening gate pass requirements must be valid: \(error)")
        }
    }()
}

private extension ProductionCutoverRuntimeHardeningContract {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        allowedVenue: String,
        allowedProductTypes: [String],
        allowedStrategies: [String],
        requirements: [ProductionCutoverRuntimeHardeningGateRequirement],
        forbiddenCapabilities: [ProductionCutoverRuntimeHardeningForbiddenCapability],
        gatePassRequirements: [ProductionCutoverRuntimeHardeningGatePassRequirement],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-643..GH-649", "GH-643..GH-649", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
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
                "requirements",
                requirements == requiredRequirements,
                requiredRequirements.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "gatePassRequirements",
                gatePassRequirements == requiredGatePassRequirements,
                requiredGatePassRequirements.map(\.requiredAnchor).joined(separator: ","),
                gatePassRequirements.map(\.requiredAnchor).joined(separator: ",")
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
        operatorApprovalRequired: Bool,
        allGatePassesRequired: Bool
    ) throws {
        let requiredTrueFlags = [
            ("operatorApprovalRequired", operatorApprovalRequired),
            ("allGatePassesRequired", allGatePassesRequired)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        realBrokerEnabledByDefault: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        commandGatewayBypassAllowed: Bool,
        riskEngineBypassAllowed: Bool,
        executionEngineBypassAllowed: Bool,
        omsBypassAllowed: Bool,
        eventStoreBypassAllowed: Bool,
        realOrderSubmissionEnabled: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("realBrokerEnabledByDefault", realBrokerEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("riskEngineBypassAllowed", riskEngineBypassAllowed),
            ("executionEngineBypassAllowed", executionEngineBypassAllowed),
            ("omsBypassAllowed", omsBypassAllowed),
            ("eventStoreBypassAllowed", eventStoreBypassAllowed),
            ("realOrderSubmissionEnabled", realOrderSubmissionEnabled),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
