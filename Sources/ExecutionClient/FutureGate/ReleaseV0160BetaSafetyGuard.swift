import DomainModel
import Foundation

// GH-1110 static contract boundary:
// betaSafetyGuard=ReleaseV0160BetaSafetyGuard
// maxQuantityGuardEnabled=true
// maxOrdersPerRunGuardEnabled=true
// cooldownGuardEnabled=true
// symbolAllowlistGuardEnabled=true
// testnetOnlyCredentialProfileGuardEnabled=true
// transportPrecheckFailsClosed=true
// redactedSafetyEvidence=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false
// productionCutoverAuthorized=false

/// ReleaseV0160BetaSafetyGuardAction 固定 GH-1110 要保护的 operator transport 动作。
///
/// 这些动作只覆盖 Binance Spot Testnet operator beta 的 submit / cancel / status-query
/// 前置检查。它们不代表 production command，也不授权 broker endpoint 或 production cutover。
public enum ReleaseV0160BetaSafetyGuardAction: String, Codable, CaseIterable, Equatable, Sendable {
    case submit
    case cancel
    case statusQuery = "status-query"
}

/// ReleaseV0160BetaSafetyGuardLimits 定义 v0.16.0 beta 的本地安全阈值。
///
/// 限制值必须先于任何 transport call 检查。默认值刻意保守：单次数量不超过 0.05，
/// 每个 run 只允许一次 transport attempt，冷却窗口为 60 秒，symbol 只允许
/// Binance Spot Testnet beta 明确覆盖的 BTCUSDT / ETHUSDT。
public struct ReleaseV0160BetaSafetyGuardLimits: Codable, Equatable, Sendable {
    public let maxQuantity: Double
    public let maxOrdersPerRun: Int
    public let cooldownMilliseconds: Int64
    public let allowedSymbols: [String]

    public init(
        maxQuantity: Double,
        maxOrdersPerRun: Int,
        cooldownMilliseconds: Int64,
        allowedSymbols: [String]
    ) {
        self.maxQuantity = maxQuantity
        self.maxOrdersPerRun = maxOrdersPerRun
        self.cooldownMilliseconds = cooldownMilliseconds
        self.allowedSymbols = allowedSymbols
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
            .filter { $0.isEmpty == false }
    }

    public static let standard = ReleaseV0160BetaSafetyGuardLimits(
        maxQuantity: 0.05,
        maxOrdersPerRun: 1,
        cooldownMilliseconds: 60_000,
        allowedSymbols: ["BTCUSDT", "ETHUSDT"]
    )
}

/// ReleaseV0160BetaSafetyGuardRequest 是 GH-1110 guard 的统一输入。
///
/// Request 只保存 run id、action、symbol、quantity、credential profile 名称和本地计数。
/// 它不保存 API key、secret、raw broker payload、raw order id 或 production endpoint。
public struct ReleaseV0160BetaSafetyGuardRequest: Equatable, Sendable {
    public let issueID: Identifier
    public let runID: Identifier
    public let action: ReleaseV0160BetaSafetyGuardAction
    public let symbol: String
    public let quantity: String
    public let credentialProviderKind: ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind
    public let credentialReferenceID: Identifier
    public let apiKeyEnvironmentName: String
    public let secretEnvironmentName: String
    public let attemptedOrderCount: Int
    public let timestampMilliseconds: Int64
    public let previousTransportAttemptMilliseconds: Int64?
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        issueID: Identifier = Identifier.constant("GH-1110"),
        runID: Identifier,
        action: ReleaseV0160BetaSafetyGuardAction,
        symbol: String,
        quantity: String,
        credentialProviderKind: ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind,
        credentialReferenceID: Identifier,
        apiKeyEnvironmentName: String,
        secretEnvironmentName: String,
        attemptedOrderCount: Int,
        timestampMilliseconds: Int64,
        previousTransportAttemptMilliseconds: Int64? = nil,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.issueID = issueID
        self.runID = runID
        self.action = action
        self.symbol = symbol
        self.quantity = quantity
        self.credentialProviderKind = credentialProviderKind
        self.credentialReferenceID = credentialReferenceID
        self.apiKeyEnvironmentName = apiKeyEnvironmentName
        self.secretEnvironmentName = secretEnvironmentName
        self.attemptedOrderCount = attemptedOrderCount
        self.timestampMilliseconds = timestampMilliseconds
        self.previousTransportAttemptMilliseconds = previousTransportAttemptMilliseconds
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV0160BetaSafetyGuardEvidence 是 GH-1110 的脱敏 safety precheck evidence。
///
/// Evidence 允许记录失败原因，但永远只输出 credential reference 的 `<redacted>` 表示，
/// 不输出环境变量值、API key、secret、signed payload 或 raw broker response。
public struct ReleaseV0160BetaSafetyGuardEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let runID: Identifier
    public let action: ReleaseV0160BetaSafetyGuardAction
    public let symbol: String
    public let quantity: String
    public let maxQuantity: Double
    public let maxOrdersPerRun: Int
    public let cooldownMilliseconds: Int64
    public let allowedSymbols: [String]
    public let attemptedOrderCount: Int
    public let timestampMilliseconds: Int64
    public let previousTransportAttemptMilliseconds: Int64?
    public let credentialProvider: String
    public let credentialReferenceRedacted: String
    public let apiKeyEnvironmentName: String
    public let secretEnvironmentName: String
    public let quantityWithinLimit: Bool
    public let maxOrdersPerRunHeld: Bool
    public let cooldownHeld: Bool
    public let symbolAllowlistHeld: Bool
    public let testnetOnlyCredentialProfileHeld: Bool
    public let transportPrecheckPassed: Bool
    public let redactedSafetyEvidence: Bool
    public let rawSecretPrinted: Bool
    public let rawCredentialPrinted: Bool
    public let rawOrderIdentityPrinted: Bool
    public let rawBrokerPayloadPrinted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        request: ReleaseV0160BetaSafetyGuardRequest,
        limits: ReleaseV0160BetaSafetyGuardLimits,
        quantityWithinLimit: Bool,
        maxOrdersPerRunHeld: Bool,
        cooldownHeld: Bool,
        symbolAllowlistHeld: Bool,
        testnetOnlyCredentialProfileHeld: Bool,
        transportPrecheckPassed: Bool,
        redactedSafetyEvidence: Bool = true,
        rawSecretPrinted: Bool = false,
        rawCredentialPrinted: Bool = false,
        rawOrderIdentityPrinted: Bool = false,
        rawBrokerPayloadPrinted: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        let normalizedSymbol = request.symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        self.evidenceID = Self.deterministicID(
            runID: request.runID,
            action: request.action,
            symbol: normalizedSymbol,
            quantity: request.quantity,
            attemptedOrderCount: request.attemptedOrderCount,
            timestampMilliseconds: request.timestampMilliseconds
        )
        self.issueID = request.issueID
        self.runID = request.runID
        self.action = request.action
        self.symbol = normalizedSymbol
        self.quantity = request.quantity
        self.maxQuantity = limits.maxQuantity
        self.maxOrdersPerRun = limits.maxOrdersPerRun
        self.cooldownMilliseconds = limits.cooldownMilliseconds
        self.allowedSymbols = limits.allowedSymbols
        self.attemptedOrderCount = request.attemptedOrderCount
        self.timestampMilliseconds = request.timestampMilliseconds
        self.previousTransportAttemptMilliseconds = request.previousTransportAttemptMilliseconds
        self.credentialProvider = request.credentialProviderKind.rawValue
        self.credentialReferenceRedacted = "<redacted>"
        self.apiKeyEnvironmentName = request.apiKeyEnvironmentName
        self.secretEnvironmentName = request.secretEnvironmentName
        self.quantityWithinLimit = quantityWithinLimit
        self.maxOrdersPerRunHeld = maxOrdersPerRunHeld
        self.cooldownHeld = cooldownHeld
        self.symbolAllowlistHeld = symbolAllowlistHeld
        self.testnetOnlyCredentialProfileHeld = testnetOnlyCredentialProfileHeld
        self.transportPrecheckPassed = transportPrecheckPassed
        self.redactedSafetyEvidence = redactedSafetyEvidence
        self.rawSecretPrinted = rawSecretPrinted
        self.rawCredentialPrinted = rawCredentialPrinted
        self.rawOrderIdentityPrinted = rawOrderIdentityPrinted
        self.rawBrokerPayloadPrinted = rawBrokerPayloadPrinted
        self.productionTradingEnabledByDefault = request.productionTradingEnabledByDefault
        self.productionSecretAutoRead = request.productionSecretAutoRead
        self.productionEndpointConnected = request.productionEndpointConnected
        self.brokerEndpointConnected = request.brokerEndpointConnected
        self.productionOrderSubmitted = request.productionOrderSubmitted
        self.productionCutoverAuthorized = request.productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        evidenceID == Self.deterministicID(
            runID: runID,
            action: action,
            symbol: symbol,
            quantity: quantity,
            attemptedOrderCount: attemptedOrderCount,
            timestampMilliseconds: timestampMilliseconds
        )
            && issueID == .constant("GH-1110")
            && runID.rawValue.isEmpty == false
            && symbol.isEmpty == false
            && quantityWithinLimit
            && maxOrdersPerRunHeld
            && cooldownHeld
            && symbolAllowlistHeld
            && testnetOnlyCredentialProfileHeld
            && transportPrecheckPassed
            && redactedSafetyEvidence
            && credentialReferenceRedacted == "<redacted>"
            && rawSecretPrinted == false
            && rawCredentialPrinted == false
            && rawOrderIdentityPrinted == false
            && rawBrokerPayloadPrinted == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var failureReasons: [String] {
        var reasons: [String] = []
        if quantityWithinLimit == false { reasons.append("max-quantity") }
        if maxOrdersPerRunHeld == false { reasons.append("max-orders-per-run") }
        if cooldownHeld == false { reasons.append("cooldown") }
        if symbolAllowlistHeld == false { reasons.append("symbol-allowlist") }
        if testnetOnlyCredentialProfileHeld == false { reasons.append("testnet-only-credential-profile") }
        if transportPrecheckPassed == false { reasons.append("transport-precheck") }
        if redactedSafetyEvidence == false { reasons.append("redacted-evidence") }
        if productionTradingEnabledByDefault { reasons.append("production-trading") }
        if productionSecretAutoRead { reasons.append("production-secret") }
        if productionEndpointConnected { reasons.append("production-endpoint") }
        if brokerEndpointConnected { reasons.append("broker-endpoint") }
        if productionOrderSubmitted { reasons.append("production-order") }
        if productionCutoverAuthorized { reasons.append("production-cutover") }
        return reasons
    }

    public var redactedOutputLines: [String] {
        [
            "issue=GH-1110",
            "guard=ReleaseV0160BetaSafetyGuard",
            "runID=\(runID.rawValue)",
            "action=\(action.rawValue)",
            "symbol=\(symbol)",
            "quantity=\(quantity)",
            "maxQuantity=\(maxQuantity)",
            "maxOrdersPerRun=\(maxOrdersPerRun)",
            "cooldownMilliseconds=\(cooldownMilliseconds)",
            "allowedSymbols=\(allowedSymbols.joined(separator: ","))",
            "credentialProvider=\(credentialProvider)",
            "credentialReference=<redacted>",
            "quantityWithinLimit=\(quantityWithinLimit)",
            "maxOrdersPerRunHeld=\(maxOrdersPerRunHeld)",
            "cooldownHeld=\(cooldownHeld)",
            "symbolAllowlistHeld=\(symbolAllowlistHeld)",
            "testnetOnlyCredentialProfileHeld=\(testnetOnlyCredentialProfileHeld)",
            "transportPrecheckPassed=\(transportPrecheckPassed)",
            "redactedSafetyEvidence=\(redactedSafetyEvidence)",
            "failureReasons=\(failureReasons.joined(separator: ","))",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionSecretAutoRead=\(productionSecretAutoRead)",
            "productionEndpointConnected=\(productionEndpointConnected)",
            "brokerEndpointConnected=\(brokerEndpointConnected)",
            "productionOrderSubmitted=\(productionOrderSubmitted)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)"
        ]
    }

    public static let requiredValidationAnchors = [
        "GH-1110-VERIFY-V0160-BETA-SAFETY-GUARDS",
        "TVM-RELEASE-V0160-BETA-SAFETY-GUARDS",
        "V0160-010-MAX-QUANTITY-GUARD",
        "V0160-010-MAX-ORDERS-PER-RUN-GUARD",
        "V0160-010-COOLDOWN-GUARD",
        "V0160-010-SYMBOL-ALLOWLIST-GUARD",
        "V0160-010-TESTNET-ONLY-CREDENTIAL-PROFILE",
        "V0160-010-TRANSPORT-PRECHECK-FAILS-CLOSED",
        "V0160-010-REDACTED-SAFETY-EVIDENCE",
        "V0160-010-NO-PRODUCTION-CUTOVER"
    ]

    public static func deterministicID(
        runID: Identifier,
        action: ReleaseV0160BetaSafetyGuardAction,
        symbol: String,
        quantity: String,
        attemptedOrderCount: Int,
        timestampMilliseconds: Int64
    ) -> Identifier {
        .constant(
            "gh-1110-v0160-beta-safety-guard:\(runID.rawValue):\(action.rawValue):\(symbol):\(quantity):\(attemptedOrderCount):\(timestampMilliseconds)"
        )
    }
}

/// ReleaseV0160BetaSafetyGuard 在所有 v0.16.0 operator transport 前执行 fail-closed precheck。
///
/// `evaluate` 负责生成脱敏证据，`validate` 负责在任一 guard 不满足时阻断后续 transport。
/// 该类型不读取 credential value，不连接 endpoint，也不持久化 raw order identity。
public enum ReleaseV0160BetaSafetyGuard {
    public static func evaluate(
        request: ReleaseV0160BetaSafetyGuardRequest,
        limits: ReleaseV0160BetaSafetyGuardLimits = .standard
    ) -> ReleaseV0160BetaSafetyGuardEvidence {
        let normalizedSymbol = request.symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let normalizedQuantity = request.quantity.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedQuantity = Double(normalizedQuantity)
        let quantityWithinLimit = parsedQuantity.map { $0 > 0 && $0 <= limits.maxQuantity } ?? false
        let maxOrdersPerRunHeld = request.attemptedOrderCount > 0 && request.attemptedOrderCount <= limits.maxOrdersPerRun
        let cooldownHeld = request.previousTransportAttemptMilliseconds.map {
            request.timestampMilliseconds >= $0
                && request.timestampMilliseconds - $0 >= limits.cooldownMilliseconds
        } ?? true
        let symbolAllowlistHeld = normalizedSymbol.isEmpty == false && limits.allowedSymbols.contains(normalizedSymbol)
        let apiKeyEnv = request.apiKeyEnvironmentName.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let secretEnv = request.secretEnvironmentName.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let testnetOnlyCredentialProfileHeld = request.credentialProviderKind == .testnetEnvironment
            && apiKeyEnv.contains("TESTNET")
            && secretEnv.contains("TESTNET")
            && request.productionSecretAutoRead == false
        let productionBoundaryHeld = request.productionTradingEnabledByDefault == false
            && request.productionSecretAutoRead == false
            && request.productionEndpointConnected == false
            && request.brokerEndpointConnected == false
            && request.productionOrderSubmitted == false
            && request.productionCutoverAuthorized == false
        let transportPrecheckPassed = quantityWithinLimit
            && maxOrdersPerRunHeld
            && cooldownHeld
            && symbolAllowlistHeld
            && testnetOnlyCredentialProfileHeld
            && productionBoundaryHeld

        return ReleaseV0160BetaSafetyGuardEvidence(
            request: request,
            limits: limits,
            quantityWithinLimit: quantityWithinLimit,
            maxOrdersPerRunHeld: maxOrdersPerRunHeld,
            cooldownHeld: cooldownHeld,
            symbolAllowlistHeld: symbolAllowlistHeld,
            testnetOnlyCredentialProfileHeld: testnetOnlyCredentialProfileHeld,
            transportPrecheckPassed: transportPrecheckPassed
        )
    }

    @discardableResult
    public static func validate(
        request: ReleaseV0160BetaSafetyGuardRequest,
        limits: ReleaseV0160BetaSafetyGuardLimits = .standard
    ) throws -> ReleaseV0160BetaSafetyGuardEvidence {
        let evidence = evaluate(request: request, limits: limits)
        guard evidence.boundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0160BetaSafetyGuard.\(evidence.failureReasons.joined(separator: "+"))"
            )
        }
        return evidence
    }

    @discardableResult
    public static func validate(
        command: ReleaseV0160CLISubmitExecutionCommand,
        limits: ReleaseV0160BetaSafetyGuardLimits = .standard
    ) throws -> ReleaseV0160BetaSafetyGuardEvidence {
        try validate(request: request(command: command, action: .submit), limits: limits)
    }

    @discardableResult
    public static func validate(
        command: ReleaseV0160CLICancelExecutionCommand,
        limits: ReleaseV0160BetaSafetyGuardLimits = .standard
    ) throws -> ReleaseV0160BetaSafetyGuardEvidence {
        try validate(request: request(command: command, action: .cancel), limits: limits)
    }

    @discardableResult
    public static func validate(
        command: ReleaseV0160CLIOrderStatusQueryCommand,
        limits: ReleaseV0160BetaSafetyGuardLimits = .standard
    ) throws -> ReleaseV0160BetaSafetyGuardEvidence {
        try validate(request: request(command: command, action: .statusQuery), limits: limits)
    }

    public static func request(
        command: ReleaseV0160CLISubmitExecutionCommand,
        action: ReleaseV0160BetaSafetyGuardAction
    ) -> ReleaseV0160BetaSafetyGuardRequest {
        ReleaseV0160BetaSafetyGuardRequest(
            runID: command.runID,
            action: action,
            symbol: command.symbol,
            quantity: command.quantity,
            credentialProviderKind: command.credentialProviderKind,
            credentialReferenceID: command.credentialReferenceID,
            apiKeyEnvironmentName: command.apiKeyEnvironmentName,
            secretEnvironmentName: command.secretEnvironmentName,
            attemptedOrderCount: 1,
            timestampMilliseconds: command.timestampMilliseconds
        )
    }

    public static func request(
        command: ReleaseV0160CLICancelExecutionCommand,
        action: ReleaseV0160BetaSafetyGuardAction
    ) -> ReleaseV0160BetaSafetyGuardRequest {
        ReleaseV0160BetaSafetyGuardRequest(
            runID: command.runID,
            action: action,
            symbol: command.symbol,
            quantity: command.quantity,
            credentialProviderKind: command.credentialProviderKind,
            credentialReferenceID: command.credentialReferenceID,
            apiKeyEnvironmentName: command.apiKeyEnvironmentName,
            secretEnvironmentName: command.secretEnvironmentName,
            attemptedOrderCount: 1,
            timestampMilliseconds: command.timestampMilliseconds
        )
    }

    public static func request(
        command: ReleaseV0160CLIOrderStatusQueryCommand,
        action: ReleaseV0160BetaSafetyGuardAction
    ) -> ReleaseV0160BetaSafetyGuardRequest {
        ReleaseV0160BetaSafetyGuardRequest(
            runID: command.runID,
            action: action,
            symbol: command.symbol,
            quantity: command.quantity,
            credentialProviderKind: command.credentialProviderKind,
            credentialReferenceID: command.credentialReferenceID,
            apiKeyEnvironmentName: command.apiKeyEnvironmentName,
            secretEnvironmentName: command.secretEnvironmentName,
            attemptedOrderCount: 1,
            timestampMilliseconds: command.timestampMilliseconds
        )
    }
}
