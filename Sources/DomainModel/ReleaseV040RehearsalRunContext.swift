import Foundation

/// ReleaseV040RehearsalRunMode 是 v0.4.0 统一 rehearsal run 的 mode 维度。
///
/// `testnetGuarded` 只表示后续 issue 可以显式定义 testnet-gated evidence；本类型不连接网络、
/// 不读取 secret、不提交订单，也不授权 production cutover。
public enum ReleaseV040RehearsalRunMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case shadow = "shadow"
    case testnetGuarded = "testnet-guarded"
    case productionBlocked = "production-blocked"
}

/// ReleaseV040RehearsalStrategyKind 固定 v0.4.0 active strategy identity。
public enum ReleaseV040RehearsalStrategyKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case ema = "EMA"
    case rsi = "RSI"
}

/// ReleaseV040UnifiedEvidenceModule 固定统一 evidence envelope 的 module 维度。
public enum ReleaseV040UnifiedEvidenceModule: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dataEngine = "DataEngine"
    case trader = "Trader"
    case riskEngine = "RiskEngine"
    case executionEngine = "ExecutionEngine"
    case oms = "OMS"
    case executionClient = "ExecutionClient"
    case eventStore = "Event Store"
    case portfolio = "Portfolio"
    case dashboard = "Dashboard"
    case cli = "CLI"
}

/// ReleaseV040RehearsalRunContext 是所有 v0.4.0 module evidence 共享的 run 级上下文。
///
/// 所有 envelope 必须复用同一个 `runID`，并显式携带 mode、venue、product type、strategy、
/// correlation id 和 causation id。该上下文只服务 deterministic rehearsal evidence，不是
/// production runtime session，也不携带任何 secret 或 broker endpoint。
public struct ReleaseV040RehearsalRunContext: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let mode: ReleaseV040RehearsalRunMode
    public let venue: String
    public let productType: ProductType
    public let strategy: ReleaseV040RehearsalStrategyKind
    public let correlationID: Identifier
    public let causationID: Identifier
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var boundaryHeld: Bool {
        venue == Self.requiredVenue
            && Self.requiredProductTypes.contains(productType)
            && Self.requiredStrategies.contains(strategy)
            && productionDefaultsClosed
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
        runID: Identifier = Identifier.constant("gh-695-v040-unified-rehearsal-run"),
        mode: ReleaseV040RehearsalRunMode = .dryRun,
        venue: String = Self.requiredVenue,
        productType: ProductType = .spot,
        strategy: ReleaseV040RehearsalStrategyKind = .ema,
        correlationID: Identifier = Identifier.constant("gh-695-v040-correlation"),
        causationID: Identifier = Identifier.constant("gh-694-v040-contract-causation"),
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard venue == Self.requiredVenue else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "venue", expected: Self.requiredVenue, actual: venue)
        }
        guard Self.requiredProductTypes.contains(productType) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "productType",
                expected: Self.requiredProductTypes.map(\.rawValue).joined(separator: ","),
                actual: productType.rawValue
            )
        }
        guard Self.requiredStrategies.contains(strategy) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "strategy",
                expected: Self.requiredStrategies.map(\.rawValue).joined(separator: ","),
                actual: strategy.rawValue
            )
        }
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionBrokerConnectionEnabled: productionBrokerConnectionEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.runID = runID
        self.mode = mode
        self.venue = venue
        self.productType = productType
        self.strategy = strategy
        self.correlationID = correlationID
        self.causationID = causationID
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static let requiredVenue = "Binance"
    public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]
    public static let requiredStrategies: [ReleaseV040RehearsalStrategyKind] = [.ema, .rsi]
}

/// ReleaseV040UnifiedEvidenceEnvelope 是所有 v0.4.0 module evidence 的共同外壳。
public struct ReleaseV040UnifiedEvidenceEnvelope: Codable, Equatable, Sendable {
    public let envelopeID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let module: ReleaseV040UnifiedEvidenceModule
    public let sourceIssueID: Identifier
    public let evidenceID: Identifier
    public let upstreamEvidenceID: Identifier?
    public let validationAnchor: String
    public let sequence: Int

    public var runID: Identifier { runContext.runID }
    public var mode: ReleaseV040RehearsalRunMode { runContext.mode }
    public var venue: String { runContext.venue }
    public var productType: ProductType { runContext.productType }
    public var strategy: ReleaseV040RehearsalStrategyKind { runContext.strategy }
    public var correlationID: Identifier { runContext.correlationID }
    public var causationID: Identifier { upstreamEvidenceID ?? runContext.causationID }

    public var boundaryHeld: Bool {
        runContext.boundaryHeld
            && sourceIssueID.rawValue.hasPrefix("GH-")
            && validationAnchor.hasPrefix("TVM-RELEASE-V040-")
            && sequence > 0
    }

    public init(
        envelopeID: Identifier,
        runContext: ReleaseV040RehearsalRunContext,
        module: ReleaseV040UnifiedEvidenceModule,
        sourceIssueID: Identifier,
        evidenceID: Identifier,
        upstreamEvidenceID: Identifier?,
        validationAnchor: String,
        sequence: Int
    ) throws {
        guard sourceIssueID.rawValue.hasPrefix("GH-") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIssueID",
                expected: "GH-*",
                actual: sourceIssueID.rawValue
            )
        }
        guard validationAnchor.hasPrefix("TVM-RELEASE-V040-") else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchor",
                expected: "TVM-RELEASE-V040-*",
                actual: validationAnchor
            )
        }
        guard sequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sequence",
                expected: "positive",
                actual: "\(sequence)"
            )
        }

        self.envelopeID = envelopeID
        self.runContext = runContext
        self.module = module
        self.sourceIssueID = sourceIssueID
        self.evidenceID = evidenceID
        self.upstreamEvidenceID = upstreamEvidenceID
        self.validationAnchor = validationAnchor
        self.sequence = sequence
    }
}

/// ReleaseV040UnifiedEvidenceEnvelopeFixture 生成 GH-695 的 deterministic shared envelope evidence。
public enum ReleaseV040UnifiedEvidenceEnvelopeFixture {
    public static func deterministicEnvelopes() throws -> [ReleaseV040UnifiedEvidenceEnvelope] {
        let context = try ReleaseV040RehearsalRunContext()
        var upstreamEvidenceID: Identifier?
        var envelopes: [ReleaseV040UnifiedEvidenceEnvelope] = []

        for (index, module) in ReleaseV040UnifiedEvidenceModule.allCases.enumerated() {
            let sequence = index + 1
            let evidenceID = Identifier.constant("gh-695-v040-\(module.rawValue.normalizedEvidenceComponent)-evidence")
            let envelope = try ReleaseV040UnifiedEvidenceEnvelope(
                envelopeID: Identifier.constant("gh-695-v040-\(module.rawValue.normalizedEvidenceComponent)-envelope"),
                runContext: context,
                module: module,
                sourceIssueID: Identifier.constant("GH-695"),
                evidenceID: evidenceID,
                upstreamEvidenceID: upstreamEvidenceID,
                validationAnchor: "TVM-RELEASE-V040-REHEARSAL-RUN-CONTEXT-ENVELOPE",
                sequence: sequence
            )
            envelopes.append(envelope)
            upstreamEvidenceID = evidenceID
        }

        return envelopes
    }

    public static func allEvidenceSharesOneRunID(_ envelopes: [ReleaseV040UnifiedEvidenceEnvelope]) -> Bool {
        guard let firstRunID = envelopes.first?.runID else { return false }
        return envelopes.count == ReleaseV040UnifiedEvidenceModule.allCases.count
            && envelopes.allSatisfy { $0.runID == firstRunID && $0.boundaryHeld }
            && envelopes.map(\.module) == ReleaseV040UnifiedEvidenceModule.allCases
    }
}

private extension ReleaseV040RehearsalRunContext {
    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionBrokerConnectionEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionBrokerConnectionEnabled", productionBrokerConnectionEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}

private extension String {
    var normalizedEvidenceComponent: String {
        lowercased()
            .replacingOccurrences(of: " / ", with: "-")
            .replacingOccurrences(of: " ", with: "-")
    }
}
