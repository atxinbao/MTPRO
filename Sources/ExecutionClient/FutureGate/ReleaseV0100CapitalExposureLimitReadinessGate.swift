import DomainModel
import Foundation

/// ReleaseV0100CapitalExposureLimitEvidenceArtifactKind 固定 GH-883 的 readiness evidence 文件。
public enum ReleaseV0100CapitalExposureLimitEvidenceArtifactKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case capitalExposureLimits = "capital_exposure_limits.json"
}

/// ReleaseV0100CapitalExposureLimitReadinessRequirement 固定 GH-883 的资本 / 敞口 readiness 要求。
public enum ReleaseV0100CapitalExposureLimitReadinessRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamNoAuthorizationContractRequired = "upstream no-authorization contract required"
    case previousEndpointPolicyReadinessRequired = "previous endpoint policy readiness required"
    case maxCapitalRequired = "maxCapital required"
    case maxNotionalRequired = "maxNotional required"
    case maxSingleOrderNotionalRequired = "maxSingleOrderNotional required"
    case maxSymbolExposureRequired = "maxSymbolExposure required"
    case maxProductExposureRequired = "maxProductExposure required"
    case maxDailyLossRequired = "maxDailyLoss required"
    case maxOpenOrdersRequired = "maxOpenOrders required"
    case maxLeverageRequired = "maxLeverage required"
    case allowedSymbolsRequired = "allowedSymbols required"
    case allowedProductTypesRequired = "allowedProductTypes required"
    case riskPolicyHashBound = "risk policy hash bound"
    case capitalExposureLimitsEvidenceExists = "capital_exposure_limits.json evidence exists"
    case operatorReviewRequired = "operator review required"
}

/// ReleaseV0100CapitalExposureLimitForbiddenCapability 枚举 GH-883 必须保持关闭的能力。
public enum ReleaseV0100CapitalExposureLimitForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionCutoverAuthorization = "production cutover authorization"
    case orderSubmissionEnabled = "order submission enabled"
    case testnetOrderSubmissionEnabled = "testnet order submission enabled"
    case productionEndpointConnection = "production endpoint connection"
    case productionBrokerConnection = "production broker connection"
    case productionSecretValueRead = "production secret value read"
    case productionOMSRuntimeEnabled = "production OMS runtime enabled"
    case tradingButtonEnabled = "trading button enabled"
    case orderFormEnabled = "order form enabled"
    case liveCommandEnabled = "live command enabled"
    case limitBypassEnabled = "capital exposure limit bypass enabled"
    case riskPolicyHashMissing = "risk policy hash missing"
}

/// ReleaseV0100CapitalExposureRiskPolicyIdentity 是 GH-883 的 risk policy identity binding。
///
/// Identity 只记录 policy reference、version、hash algorithm 和 hash value。它不读取 secret、不连接
/// broker，也不把 policy hash 转换为交易授权。
public struct ReleaseV0100CapitalExposureRiskPolicyIdentity: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let policyVersion: String
    public let hashAlgorithm: String
    public let policyHash: String
    public let riskPolicyHashBound: Bool

    public var identityHeld: Bool {
        policyID == ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyID
            && policyVersion == ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyVersion
            && hashAlgorithm == ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyHashAlgorithm
            && policyHash == ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyHash
            && riskPolicyHashBound
    }

    public init(
        policyID: Identifier = ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyID,
        policyVersion: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyVersion,
        hashAlgorithm: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyHashAlgorithm,
        policyHash: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyHash,
        riskPolicyHashBound: Bool = true
    ) throws {
        guard policyID == ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskPolicyID",
                expected: ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyID.rawValue,
                actual: policyID.rawValue
            )
        }
        guard policyVersion == ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyVersion else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskPolicyVersion",
                expected: ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyVersion,
                actual: policyVersion
            )
        }
        guard hashAlgorithm == ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyHashAlgorithm else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskPolicyHashAlgorithm",
                expected: ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyHashAlgorithm,
                actual: hashAlgorithm
            )
        }
        guard policyHash == ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyHash else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskPolicyHash",
                expected: ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyHash,
                actual: policyHash
            )
        }
        guard riskPolicyHashBound else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("riskPolicyHashBound")
        }

        self.policyID = policyID
        self.policyVersion = policyVersion
        self.hashAlgorithm = hashAlgorithm
        self.policyHash = policyHash
        self.riskPolicyHashBound = riskPolicyHashBound
    }
}

/// ReleaseV0100CapitalExposureLimitProfile 是 GH-883 的 capital / exposure limit schema。
///
/// Profile 只保存人工复核前的 limit evidence：资本上限、名义金额上限、单笔上限、symbol / product
/// 敞口、日亏损、未结订单数、杠杆和 allowlist。它不触发 submit / cancel / replace。
public struct ReleaseV0100CapitalExposureLimitProfile: Codable, Equatable, Sendable {
    public let maxCapital: String
    public let maxNotional: String
    public let maxSingleOrderNotional: String
    public let maxSymbolExposure: String
    public let maxProductExposure: String
    public let maxDailyLoss: String
    public let maxOpenOrders: Int
    public let maxLeverage: String
    public let allowedSymbols: [String]
    public let allowedProductTypes: [String]
    public let riskPolicyIdentity: ReleaseV0100CapitalExposureRiskPolicyIdentity
    public let operatorReviewRequired: Bool
    public let orderSubmissionEnabled: Bool

    public var profileHeld: Bool {
        maxCapital == ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxCapital
            && maxNotional == ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxNotional
            && maxSingleOrderNotional == ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxSingleOrderNotional
            && maxSymbolExposure == ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxSymbolExposure
            && maxProductExposure == ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxProductExposure
            && maxDailyLoss == ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxDailyLoss
            && maxOpenOrders == ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxOpenOrders
            && maxLeverage == ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxLeverage
            && allowedSymbols == ReleaseV0100CapitalExposureLimitReadinessGate.requiredAllowedSymbols
            && allowedProductTypes == ReleaseV0100CapitalExposureLimitReadinessGate.requiredAllowedProductTypes
            && riskPolicyIdentity.identityHeld
            && operatorReviewRequired
            && orderSubmissionEnabled == false
    }

    public init(
        maxCapital: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxCapital,
        maxNotional: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxNotional,
        maxSingleOrderNotional: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxSingleOrderNotional,
        maxSymbolExposure: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxSymbolExposure,
        maxProductExposure: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxProductExposure,
        maxDailyLoss: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxDailyLoss,
        maxOpenOrders: Int = ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxOpenOrders,
        maxLeverage: String = ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxLeverage,
        allowedSymbols: [String] = ReleaseV0100CapitalExposureLimitReadinessGate.requiredAllowedSymbols,
        allowedProductTypes: [String] = ReleaseV0100CapitalExposureLimitReadinessGate.requiredAllowedProductTypes,
        riskPolicyIdentity: ReleaseV0100CapitalExposureRiskPolicyIdentity = ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyIdentity,
        operatorReviewRequired: Bool = true,
        orderSubmissionEnabled: Bool = false
    ) throws {
        let exactStringChecks = [
            ("maxCapital", maxCapital, ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxCapital),
            ("maxNotional", maxNotional, ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxNotional),
            ("maxSingleOrderNotional", maxSingleOrderNotional, ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxSingleOrderNotional),
            ("maxSymbolExposure", maxSymbolExposure, ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxSymbolExposure),
            ("maxProductExposure", maxProductExposure, ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxProductExposure),
            ("maxDailyLoss", maxDailyLoss, ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxDailyLoss),
            ("maxLeverage", maxLeverage, ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxLeverage)
        ]
        for (field, actual, expected) in exactStringChecks where actual != expected {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
        guard maxOpenOrders == ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxOpenOrders else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "maxOpenOrders",
                expected: "\(ReleaseV0100CapitalExposureLimitReadinessGate.requiredMaxOpenOrders)",
                actual: "\(maxOpenOrders)"
            )
        }
        guard allowedSymbols == ReleaseV0100CapitalExposureLimitReadinessGate.requiredAllowedSymbols else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedSymbols",
                expected: ReleaseV0100CapitalExposureLimitReadinessGate.requiredAllowedSymbols.joined(separator: ","),
                actual: allowedSymbols.joined(separator: ",")
            )
        }
        guard allowedProductTypes == ReleaseV0100CapitalExposureLimitReadinessGate.requiredAllowedProductTypes else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedProductTypes",
                expected: ReleaseV0100CapitalExposureLimitReadinessGate.requiredAllowedProductTypes.joined(separator: ","),
                actual: allowedProductTypes.joined(separator: ",")
            )
        }
        guard riskPolicyIdentity.identityHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "riskPolicyIdentity",
                expected: ReleaseV0100CapitalExposureLimitReadinessGate.requiredRiskPolicyHash,
                actual: riskPolicyIdentity.policyHash
            )
        }
        guard operatorReviewRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "operatorReviewRequired", expected: "true", actual: "false")
        }
        guard orderSubmissionEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("orderSubmissionEnabled")
        }

        self.maxCapital = maxCapital
        self.maxNotional = maxNotional
        self.maxSingleOrderNotional = maxSingleOrderNotional
        self.maxSymbolExposure = maxSymbolExposure
        self.maxProductExposure = maxProductExposure
        self.maxDailyLoss = maxDailyLoss
        self.maxOpenOrders = maxOpenOrders
        self.maxLeverage = maxLeverage
        self.allowedSymbols = allowedSymbols
        self.allowedProductTypes = allowedProductTypes
        self.riskPolicyIdentity = riskPolicyIdentity
        self.operatorReviewRequired = operatorReviewRequired
        self.orderSubmissionEnabled = orderSubmissionEnabled
    }
}

/// ReleaseV0100CapitalExposureLimitEvidenceArtifact 是 GH-883 的 evidence file row。
///
/// Artifact 只证明 `capital_exposure_limits.json` 文件名和 readiness flags。它不包含 broker / account
/// response，不来自 endpoint connection，也不会变成 order authorization。
public struct ReleaseV0100CapitalExposureLimitEvidenceArtifact: Codable, Equatable, Sendable {
    public let kind: ReleaseV0100CapitalExposureLimitEvidenceArtifactKind
    public let fileName: String
    public let evidenceExists: Bool
    public let containsBrokerOrAccountResponse: Bool
    public let producedByEndpointConnection: Bool

    public var evidenceBoundaryHeld: Bool {
        kind == .capitalExposureLimits
            && fileName == kind.rawValue
            && evidenceExists
            && containsBrokerOrAccountResponse == false
            && producedByEndpointConnection == false
    }

    public init(
        kind: ReleaseV0100CapitalExposureLimitEvidenceArtifactKind = .capitalExposureLimits,
        fileName: String = ReleaseV0100CapitalExposureLimitEvidenceArtifactKind.capitalExposureLimits.rawValue,
        evidenceExists: Bool = true,
        containsBrokerOrAccountResponse: Bool = false,
        producedByEndpointConnection: Bool = false
    ) throws {
        guard fileName == kind.rawValue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "capitalExposureLimitsEvidenceFile", expected: kind.rawValue, actual: fileName)
        }
        guard evidenceExists else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "capitalExposureLimitsEvidenceExists", expected: "true", actual: "false")
        }
        guard containsBrokerOrAccountResponse == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("containsBrokerOrAccountResponse")
        }
        guard producedByEndpointConnection == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("producedByEndpointConnection")
        }

        self.kind = kind
        self.fileName = fileName
        self.evidenceExists = evidenceExists
        self.containsBrokerOrAccountResponse = containsBrokerOrAccountResponse
        self.producedByEndpointConnection = producedByEndpointConnection
    }
}

/// ReleaseV0100CapitalExposureLimitReadinessGate 是 GH-883 的 capital / exposure limit readiness 合同。
///
/// Gate 只证明生产切换前必须人工复核的资本、名义金额、敞口、亏损、订单数、杠杆、symbol / product
/// allowlist 和 risk policy hash 已形成 evidence。它不授权 production cutover，不启用任何 order path。
public struct ReleaseV0100CapitalExposureLimitReadinessGate: Codable, Equatable, Sendable {
    public let gateID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamNoAuthorizationContractHeld: Bool
    public let previousEndpointPolicyReadinessHeld: Bool
    public let limitProfile: ReleaseV0100CapitalExposureLimitProfile
    public let evidenceArtifact: ReleaseV0100CapitalExposureLimitEvidenceArtifact
    public let requirements: [ReleaseV0100CapitalExposureLimitReadinessRequirement]
    public let forbiddenCapabilities: [ReleaseV0100CapitalExposureLimitForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let riskPolicyHashBound: Bool
    public let operatorReviewRequired: Bool
    public let cutoverAuthorized: Bool
    public let orderSubmissionEnabled: Bool
    public let testnetOrderSubmissionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionSecretValueRead: Bool
    public let productionOMSRuntimeEnabled: Bool
    public let tradingButtonEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let capitalExposureLimitBypassEnabled: Bool

    public var gateHeld: Bool {
        issueID.rawValue == "GH-883"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-878", "GH-882"]
            && downstreamIssueID.rawValue == "GH-884"
            && canonicalQueueRange == Self.requiredCanonicalQueueRange
            && projectName == Self.requiredProjectName
            && upstreamNoAuthorizationContractHeld
            && previousEndpointPolicyReadinessHeld
            && limitProfile.profileHeld
            && evidenceArtifact.evidenceBoundaryHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && riskPolicyHashBound
            && operatorReviewRequired
            && productionCapabilitiesDisabled
    }

    public var productionCapabilitiesDisabled: Bool {
        cutoverAuthorized == false
            && orderSubmissionEnabled == false
            && testnetOrderSubmissionEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionSecretValueRead == false
            && productionOMSRuntimeEnabled == false
            && tradingButtonEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
            && capitalExposureLimitBypassEnabled == false
    }

    public init(
        gateID: Identifier = Identifier.constant("gh-883-capital-exposure-limit-readiness-gate"),
        issueID: Identifier = Identifier.constant("GH-883"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-878"), Identifier.constant("GH-882")],
        downstreamIssueID: Identifier = Identifier.constant("GH-884"),
        canonicalQueueRange: String = Self.requiredCanonicalQueueRange,
        projectName: String = Self.requiredProjectName,
        upstreamNoAuthorizationContractHeld: Bool = true,
        previousEndpointPolicyReadinessHeld: Bool = true,
        limitProfile: ReleaseV0100CapitalExposureLimitProfile = Self.requiredLimitProfile,
        evidenceArtifact: ReleaseV0100CapitalExposureLimitEvidenceArtifact = Self.requiredEvidenceArtifact,
        requirements: [ReleaseV0100CapitalExposureLimitReadinessRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV0100CapitalExposureLimitForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        riskPolicyHashBound: Bool = true,
        operatorReviewRequired: Bool = true,
        cutoverAuthorized: Bool = false,
        orderSubmissionEnabled: Bool = false,
        testnetOrderSubmissionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionSecretValueRead: Bool = false,
        productionOMSRuntimeEnabled: Bool = false,
        tradingButtonEnabled: Bool = false,
        orderFormEnabled: Bool = false,
        liveCommandEnabled: Bool = false,
        capitalExposureLimitBypassEnabled: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            upstreamIssueIDs: upstreamIssueIDs,
            limitProfile: limitProfile,
            evidenceArtifact: evidenceArtifact,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamNoAuthorizationContractHeld: upstreamNoAuthorizationContractHeld,
            previousEndpointPolicyReadinessHeld: previousEndpointPolicyReadinessHeld,
            riskPolicyHashBound: riskPolicyHashBound,
            operatorReviewRequired: operatorReviewRequired
        )
        try Self.validateForbiddenFlags(
            cutoverAuthorized: cutoverAuthorized,
            orderSubmissionEnabled: orderSubmissionEnabled,
            testnetOrderSubmissionEnabled: testnetOrderSubmissionEnabled,
            productionEndpointConnectionEnabled: productionEndpointConnectionEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionSecretValueRead: productionSecretValueRead,
            productionOMSRuntimeEnabled: productionOMSRuntimeEnabled,
            tradingButtonEnabled: tradingButtonEnabled,
            orderFormEnabled: orderFormEnabled,
            liveCommandEnabled: liveCommandEnabled,
            capitalExposureLimitBypassEnabled: capitalExposureLimitBypassEnabled
        )

        self.gateID = gateID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamNoAuthorizationContractHeld = upstreamNoAuthorizationContractHeld
        self.previousEndpointPolicyReadinessHeld = previousEndpointPolicyReadinessHeld
        self.limitProfile = limitProfile
        self.evidenceArtifact = evidenceArtifact
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.riskPolicyHashBound = riskPolicyHashBound
        self.operatorReviewRequired = operatorReviewRequired
        self.cutoverAuthorized = cutoverAuthorized
        self.orderSubmissionEnabled = orderSubmissionEnabled
        self.testnetOrderSubmissionEnabled = testnetOrderSubmissionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionSecretValueRead = productionSecretValueRead
        self.productionOMSRuntimeEnabled = productionOMSRuntimeEnabled
        self.tradingButtonEnabled = tradingButtonEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.capitalExposureLimitBypassEnabled = capitalExposureLimitBypassEnabled
    }

    public static func deterministicFixture() throws -> ReleaseV0100CapitalExposureLimitReadinessGate {
        try ReleaseV0100CapitalExposureLimitReadinessGate()
    }

    public static let requiredCanonicalQueueRange = "GH-878..GH-891"
    public static let requiredProjectName = "MTPRO Release v0.10.0 Production Cutover Readiness Gate"
    public static let requiredMaxCapital = "100000.00"
    public static let requiredMaxNotional = "25000.00"
    public static let requiredMaxSingleOrderNotional = "5000.00"
    public static let requiredMaxSymbolExposure = "15000.00"
    public static let requiredMaxProductExposure = "50000.00"
    public static let requiredMaxDailyLoss = "2500.00"
    public static let requiredMaxOpenOrders = 10
    public static let requiredMaxLeverage = "3.0"
    public static let requiredAllowedSymbols = ["BTCUSDT", "ETHUSDT"]
    public static let requiredAllowedProductTypes = ["spot", "usdsPerpetual"]
    public static let requiredRiskPolicyID = Identifier.constant("v0.10.0-capital-exposure-risk-policy")
    public static let requiredRiskPolicyVersion = "v0.10.0-production-readiness"
    public static let requiredRiskPolicyHashAlgorithm = "sha256"
    public static let requiredRiskPolicyHash = "sha256:v0100-capital-exposure-risk-policy-reference"
    public static let requiredRequirements = ReleaseV0100CapitalExposureLimitReadinessRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV0100CapitalExposureLimitForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V0100-006-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE",
        "V0100-006-MAX-CAPITAL-LIMIT",
        "V0100-006-MAX-NOTIONAL-LIMIT",
        "V0100-006-MAX-SINGLE-ORDER-NOTIONAL-LIMIT",
        "V0100-006-MAX-SYMBOL-EXPOSURE-LIMIT",
        "V0100-006-MAX-PRODUCT-EXPOSURE-LIMIT",
        "V0100-006-MAX-DAILY-LOSS-LIMIT",
        "V0100-006-MAX-OPEN-ORDERS-LEVERAGE-LIMIT",
        "V0100-006-ALLOWED-SYMBOLS-PRODUCT-TYPES",
        "V0100-006-RISK-POLICY-HASH-BINDING",
        "V0100-006-CAPITAL-EXPOSURE-LIMITS-JSON",
        "V0100-006-PRODUCTION-CAPABILITIES-DISABLED",
        "GH-883-VERIFY-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE",
        "TVM-RELEASE-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH883CapitalExposureLimitReadinessGateBindsRiskPolicyAndDisablesOrders",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredRiskPolicyIdentity: ReleaseV0100CapitalExposureRiskPolicyIdentity = {
        do {
            return try ReleaseV0100CapitalExposureRiskPolicyIdentity()
        } catch {
            preconditionFailure("GH-883 risk policy identity must be valid: \(error)")
        }
    }()

    public static let requiredLimitProfile: ReleaseV0100CapitalExposureLimitProfile = {
        do {
            return try ReleaseV0100CapitalExposureLimitProfile()
        } catch {
            preconditionFailure("GH-883 capital exposure limit profile must be valid: \(error)")
        }
    }()

    public static let requiredEvidenceArtifact: ReleaseV0100CapitalExposureLimitEvidenceArtifact = {
        do {
            return try ReleaseV0100CapitalExposureLimitEvidenceArtifact()
        } catch {
            preconditionFailure("GH-883 capital exposure evidence artifact must be valid: \(error)")
        }
    }()
}

private extension ReleaseV0100CapitalExposureLimitReadinessGate {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        upstreamIssueIDs: [Identifier],
        limitProfile: ReleaseV0100CapitalExposureLimitProfile,
        evidenceArtifact: ReleaseV0100CapitalExposureLimitEvidenceArtifact,
        requirements: [ReleaseV0100CapitalExposureLimitReadinessRequirement],
        forbiddenCapabilities: [ReleaseV0100CapitalExposureLimitForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == requiredCanonicalQueueRange, requiredCanonicalQueueRange, canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("upstreamIssueIDs", upstreamIssueIDs.map(\.rawValue) == ["GH-878", "GH-882"], "GH-878,GH-882", upstreamIssueIDs.map(\.rawValue).joined(separator: ",")),
            ("limitProfile", limitProfile == requiredLimitProfile, requiredRiskPolicyHash, limitProfile.riskPolicyIdentity.policyHash),
            ("evidenceArtifact", evidenceArtifact == requiredEvidenceArtifact, requiredEvidenceArtifact.fileName, evidenceArtifact.fileName),
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
        previousEndpointPolicyReadinessHeld: Bool,
        riskPolicyHashBound: Bool,
        operatorReviewRequired: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamNoAuthorizationContractHeld", upstreamNoAuthorizationContractHeld),
            ("previousEndpointPolicyReadinessHeld", previousEndpointPolicyReadinessHeld),
            ("riskPolicyHashBound", riskPolicyHashBound),
            ("operatorReviewRequired", operatorReviewRequired)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        cutoverAuthorized: Bool,
        orderSubmissionEnabled: Bool,
        testnetOrderSubmissionEnabled: Bool,
        productionEndpointConnectionEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionSecretValueRead: Bool,
        productionOMSRuntimeEnabled: Bool,
        tradingButtonEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        capitalExposureLimitBypassEnabled: Bool
    ) throws {
        let forbiddenFlags = [
            ("cutoverAuthorized", cutoverAuthorized),
            ("orderSubmissionEnabled", orderSubmissionEnabled),
            ("testnetOrderSubmissionEnabled", testnetOrderSubmissionEnabled),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionSecretValueRead", productionSecretValueRead),
            ("productionOMSRuntimeEnabled", productionOMSRuntimeEnabled),
            ("tradingButtonEnabled", tradingButtonEnabled),
            ("orderFormEnabled", orderFormEnabled),
            ("liveCommandEnabled", liveCommandEnabled),
            ("capitalExposureLimitBypassEnabled", capitalExposureLimitBypassEnabled)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
