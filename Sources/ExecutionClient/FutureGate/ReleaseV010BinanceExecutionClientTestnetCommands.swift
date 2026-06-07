import DomainModel
import Foundation

/// ReleaseV010BinanceExecutionClientTestnetCommandKind 固定 GH-531 允许的 Binance testnet 命令族。
///
/// 这些 case 只代表 Binance Spot testnet submit / cancel / replace request mapping。它们不能被解释为
/// production order command，也不能绕过 RiskEngine、ExecutionEngine / OMS 或后续 kill switch gate。
public enum ReleaseV010BinanceExecutionClientTestnetCommandKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case submit
    case cancel
    case replace
}

/// ReleaseV010BinanceExecutionClientVenueEnvironment 区分 release v0.1.0 允许的 testnet 和仍禁止的 production。
public enum ReleaseV010BinanceExecutionClientVenueEnvironment:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case testnet
    case production
}

/// ReleaseV010BinanceExecutionClientHTTPMethod 固定 Binance Spot command mapping 使用的 HTTP method。
public enum ReleaseV010BinanceExecutionClientHTTPMethod:
    String,
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    case post = "POST"
    case delete = "DELETE"
}

/// ReleaseV010BinanceExecutionClientTestnetQueryItem 是 GH-531 的 redacted request mapping 参数。
///
/// Query item 只保存可审计参数名和值；signature 和 credential value 不进入该结构。
public struct ReleaseV010BinanceExecutionClientTestnetQueryItem: Codable, Equatable, Hashable, Sendable {
    public let name: String
    public let value: String

    public init(name: String, value: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "queryItem.name",
                expected: "non-empty Binance testnet query item name",
                actual: "empty"
            )
        }
        guard trimmedValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "queryItem.value",
                expected: "non-empty Binance testnet query item value",
                actual: "empty"
            )
        }
        guard trimmedName.lowercased() != "signature" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.signatureValue")
        }

        self.name = trimmedName
        self.value = trimmedValue
    }
}

/// ReleaseV010BinanceExecutionClientCredentialGuard 固定 GH-531 testnet credential reference 边界。
///
/// Guard 只允许 testnet credential reference 进入 evidence，不保存 key / secret value，不读取 production
/// secret，也不允许 testnet credential 被提升为 production credential。
/// `GH-531-TESTNET-CREDENTIAL-GUARD`
public struct ReleaseV010BinanceExecutionClientCredentialGuard: Codable, Equatable, Sendable {
    public let guardID: Identifier
    public let credentialReferenceID: Identifier
    public let environment: ReleaseV010BinanceExecutionClientVenueEnvironment
    public let credentialReferenceOnly: Bool
    public let credentialValueStored: Bool
    public let credentialValueExposed: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionCredentialAccepted: Bool
    public let testnetCredentialPromotesProduction: Bool

    public var guardHeld: Bool {
        environment == .testnet
            && credentialReferenceOnly
            && credentialValueStored == false
            && credentialValueExposed == false
            && productionSecretReadEnabledByDefault == false
            && productionCredentialAccepted == false
            && testnetCredentialPromotesProduction == false
    }

    public init(
        guardID: Identifier = Identifier.constant("gh-531-testnet-credential-guard"),
        credentialReferenceID: Identifier,
        environment: ReleaseV010BinanceExecutionClientVenueEnvironment = .testnet,
        credentialReferenceOnly: Bool = true,
        credentialValueStored: Bool = false,
        credentialValueExposed: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        productionCredentialAccepted: Bool = false,
        testnetCredentialPromotesProduction: Bool = false
    ) throws {
        guard environment == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.productionCredential")
        }
        guard credentialReferenceOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "credentialReferenceOnly",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("credentialValueStored", credentialValueStored),
            ("credentialValueExposed", credentialValueExposed),
            ("productionSecretReadEnabledByDefault", productionSecretReadEnabledByDefault),
            ("productionCredentialAccepted", productionCredentialAccepted),
            ("testnetCredentialPromotesProduction", testnetCredentialPromotesProduction)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.\(forbiddenFlag.0)")
        }

        self.guardID = guardID
        self.credentialReferenceID = credentialReferenceID
        self.environment = environment
        self.credentialReferenceOnly = credentialReferenceOnly
        self.credentialValueStored = credentialValueStored
        self.credentialValueExposed = credentialValueExposed
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionCredentialAccepted = productionCredentialAccepted
        self.testnetCredentialPromotesProduction = testnetCredentialPromotesProduction
    }

    public static func deterministicFixture() throws -> ReleaseV010BinanceExecutionClientCredentialGuard {
        try ReleaseV010BinanceExecutionClientCredentialGuard(
            credentialReferenceID: Identifier.constant("gh-531-binance-testnet-credential-reference")
        )
    }
}

/// ReleaseV010BinanceExecutionClientCapabilityMatrix 固定 GH-531 的 capability / forbidden matrix。
///
/// Matrix 明确 testnet submit / cancel / replace 被当前 issue 授权，但 production endpoint、production
/// credential、production order command、broker gateway、Dashboard command surface 和非 Binance / 非 EMA
/// scope 仍全部默认关闭。
/// `GH-531-BINANCE-TESTNET-CAPABILITY-MATRIX`
public struct ReleaseV010BinanceExecutionClientCapabilityMatrix: Codable, Equatable, Sendable {
    public let matrixID: Identifier
    public let releaseVenue: String
    public let activeConcreteStrategy: String
    public let supportedCommands: [ReleaseV010BinanceExecutionClientTestnetCommandKind]
    public let requiresCredentialGuard: Bool
    public let requiresRiskEngineDecision: Bool
    public let requiresOMSStateMachineEvidence: Bool
    public let killSwitchGateFutureRequired: Bool
    public let productionEndpointEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionSubmitEnabledByDefault: Bool
    public let productionCancelEnabledByDefault: Bool
    public let productionReplaceEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let liveCommandSurfaceTouched: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesOMS: Bool
    public let bypassesKillSwitch: Bool
    public let nonBinanceVenueEnabled: Bool
    public let nonEMAStrategyEnabled: Bool

    public var matrixHeld: Bool {
        releaseVenue == Self.requiredReleaseVenue
            && activeConcreteStrategy == Self.requiredActiveConcreteStrategy
            && supportedCommands == ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases
            && requiresCredentialGuard
            && requiresRiskEngineDecision
            && requiresOMSStateMachineEvidence
            && killSwitchGateFutureRequired
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            productionEndpointEnabledByDefault,
            productionTradingEnabledByDefault,
            productionSecretReadEnabledByDefault,
            productionSubmitEnabledByDefault,
            productionCancelEnabledByDefault,
            productionReplaceEnabledByDefault,
            brokerGatewayTouched,
            liveCommandSurfaceTouched,
            bypassesRiskEngine,
            bypassesOMS,
            bypassesKillSwitch,
            nonBinanceVenueEnabled,
            nonEMAStrategyEnabled
        ].allSatisfy { $0 == false }
    }

    public init(
        matrixID: Identifier = Identifier.constant("gh-531-binance-testnet-capability-matrix"),
        releaseVenue: String = Self.requiredReleaseVenue,
        activeConcreteStrategy: String = Self.requiredActiveConcreteStrategy,
        supportedCommands: [ReleaseV010BinanceExecutionClientTestnetCommandKind] =
            ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases,
        requiresCredentialGuard: Bool = true,
        requiresRiskEngineDecision: Bool = true,
        requiresOMSStateMachineEvidence: Bool = true,
        killSwitchGateFutureRequired: Bool = true,
        productionEndpointEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        productionSubmitEnabledByDefault: Bool = false,
        productionCancelEnabledByDefault: Bool = false,
        productionReplaceEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        liveCommandSurfaceTouched: Bool = false,
        bypassesRiskEngine: Bool = false,
        bypassesOMS: Bool = false,
        bypassesKillSwitch: Bool = false,
        nonBinanceVenueEnabled: Bool = false,
        nonEMAStrategyEnabled: Bool = false
    ) throws {
        self.matrixID = matrixID
        self.releaseVenue = releaseVenue
        self.activeConcreteStrategy = activeConcreteStrategy
        self.supportedCommands = supportedCommands
        self.requiresCredentialGuard = requiresCredentialGuard
        self.requiresRiskEngineDecision = requiresRiskEngineDecision
        self.requiresOMSStateMachineEvidence = requiresOMSStateMachineEvidence
        self.killSwitchGateFutureRequired = killSwitchGateFutureRequired
        self.productionEndpointEnabledByDefault = productionEndpointEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionSubmitEnabledByDefault = productionSubmitEnabledByDefault
        self.productionCancelEnabledByDefault = productionCancelEnabledByDefault
        self.productionReplaceEnabledByDefault = productionReplaceEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
        self.bypassesRiskEngine = bypassesRiskEngine
        self.bypassesOMS = bypassesOMS
        self.bypassesKillSwitch = bypassesKillSwitch
        self.nonBinanceVenueEnabled = nonBinanceVenueEnabled
        self.nonEMAStrategyEnabled = nonEMAStrategyEnabled

        try validate()
    }

    public static func deterministicFixture() throws -> ReleaseV010BinanceExecutionClientCapabilityMatrix {
        try ReleaseV010BinanceExecutionClientCapabilityMatrix()
    }

    public static let requiredReleaseVenue = "Binance"
    public static let requiredActiveConcreteStrategy = "EMA"

    private func validate() throws {
        guard releaseVenue == Self.requiredReleaseVenue else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.nonBinanceVenue")
        }
        guard activeConcreteStrategy == Self.requiredActiveConcreteStrategy else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.nonEMAStrategy")
        }
        guard supportedCommands == ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "supportedCommands",
                expected: ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: supportedCommands.map(\.rawValue).joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("requiresCredentialGuard", requiresCredentialGuard),
            ("requiresRiskEngineDecision", requiresRiskEngineDecision),
            ("requiresOMSStateMachineEvidence", requiresOMSStateMachineEvidence),
            ("killSwitchGateFutureRequired", killSwitchGateFutureRequired)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredFlag.0,
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionEndpointEnabledByDefault", productionEndpointEnabledByDefault),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretReadEnabledByDefault", productionSecretReadEnabledByDefault),
            ("productionSubmitEnabledByDefault", productionSubmitEnabledByDefault),
            ("productionCancelEnabledByDefault", productionCancelEnabledByDefault),
            ("productionReplaceEnabledByDefault", productionReplaceEnabledByDefault),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched),
            ("bypassesRiskEngine", bypassesRiskEngine),
            ("bypassesOMS", bypassesOMS),
            ("bypassesKillSwitch", bypassesKillSwitch),
            ("nonBinanceVenueEnabled", nonBinanceVenueEnabled),
            ("nonEMAStrategyEnabled", nonEMAStrategyEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.\(forbiddenFlag.0)")
        }
    }
}

/// ReleaseV010BinanceExecutionClientTestnetCommandRequest 是 GH-531 的 Binance testnet request mapping。
///
/// Request 必须引用 GH-530 local OMS evidence，并只映射到 Binance Spot testnet command endpoint。
/// 它不携带 secret、signature value、production host、broker payload、Dashboard command identity 或 raw fill。
/// `GH-531-BINANCE-TESTNET-REQUEST-MAPPING`
public struct ReleaseV010BinanceExecutionClientTestnetCommandRequest: Codable, Equatable, Sendable {
    public let requestID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let commandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind
    public let environment: ReleaseV010BinanceExecutionClientVenueEnvironment
    public let baseURL: URL
    public let method: ReleaseV010BinanceExecutionClientHTTPMethod
    public let endpointPath: String
    public let credentialReferenceID: Identifier
    public let sourceOMSOrderID: Identifier
    public let sourceOMSEventLogID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let clientOrderID: Identifier
    public let symbol: String
    public let queryItems: [ReleaseV010BinanceExecutionClientTestnetQueryItem]
    public let signatureRequired: Bool
    public let signatureValueExposed: Bool
    public let productionEndpointTouched: Bool
    public let productionSecretRead: Bool
    public let brokerGatewayTouched: Bool
    public let liveCommandSurfaceTouched: Bool

    public var requestMappingHeld: Bool {
        issueID.rawValue == "GH-531"
            && upstreamIssueID.rawValue == "GH-530"
            && environment == .testnet
            && baseURL.host?.lowercased() == Self.testnetHost
            && method == Self.method(for: commandKind)
            && endpointPath == Self.endpointPath(for: commandKind)
            && queryItemNames == Self.requiredQueryItemNames(for: commandKind)
            && signatureRequired
            && allForbiddenFlagsRemainClosed
    }

    public var queryItemNames: [String] {
        queryItems.map(\.name)
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            signatureValueExposed,
            productionEndpointTouched,
            productionSecretRead,
            brokerGatewayTouched,
            liveCommandSurfaceTouched
        ].allSatisfy { $0 == false }
    }

    public init(
        requestID: Identifier,
        issueID: Identifier = Identifier.constant("GH-531"),
        upstreamIssueID: Identifier = Identifier.constant("GH-530"),
        commandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind,
        environment: ReleaseV010BinanceExecutionClientVenueEnvironment = .testnet,
        baseURL: URL = Self.defaultTestnetBaseURL,
        method: ReleaseV010BinanceExecutionClientHTTPMethod? = nil,
        endpointPath: String? = nil,
        credentialReferenceID: Identifier,
        sourceOMSOrderID: Identifier,
        sourceOMSEventLogID: Identifier,
        sourceRiskDecisionID: Identifier,
        clientOrderID: Identifier,
        symbol: String,
        queryItems: [ReleaseV010BinanceExecutionClientTestnetQueryItem],
        signatureRequired: Bool = true,
        signatureValueExposed: Bool = false,
        productionEndpointTouched: Bool = false,
        productionSecretRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedMethod = method ?? Self.method(for: commandKind)
        let resolvedEndpointPath = endpointPath ?? Self.endpointPath(for: commandKind)
        let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)

        guard issueID.rawValue == "GH-531" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-531",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-530" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-530",
                actual: upstreamIssueID.rawValue
            )
        }
        guard environment == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.productionEnvironment")
        }
        guard baseURL.scheme == "https", baseURL.host?.lowercased() == Self.testnetHost else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.productionEndpoint")
        }
        guard resolvedMethod == Self.method(for: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "method",
                expected: Self.method(for: commandKind).rawValue,
                actual: resolvedMethod.rawValue
            )
        }
        guard resolvedEndpointPath == Self.endpointPath(for: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointPath",
                expected: Self.endpointPath(for: commandKind),
                actual: resolvedEndpointPath
            )
        }
        guard trimmedSymbol.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "symbol",
                expected: "non-empty Binance symbol",
                actual: "empty"
            )
        }
        guard queryItems.map(\.name) == Self.requiredQueryItemNames(for: commandKind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "queryItems",
                expected: Self.requiredQueryItemNames(for: commandKind).joined(separator: ","),
                actual: queryItems.map(\.name).joined(separator: ",")
            )
        }
        guard signatureRequired else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "signatureRequired",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("signatureValueExposed", signatureValueExposed),
            ("productionEndpointTouched", productionEndpointTouched),
            ("productionSecretRead", productionSecretRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.\(forbiddenFlag.0)")
        }

        self.requestID = requestID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.commandKind = commandKind
        self.environment = environment
        self.baseURL = baseURL
        self.method = resolvedMethod
        self.endpointPath = resolvedEndpointPath
        self.credentialReferenceID = credentialReferenceID
        self.sourceOMSOrderID = sourceOMSOrderID
        self.sourceOMSEventLogID = sourceOMSEventLogID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.clientOrderID = clientOrderID
        self.symbol = trimmedSymbol
        self.queryItems = queryItems
        self.signatureRequired = signatureRequired
        self.signatureValueExposed = signatureValueExposed
        self.productionEndpointTouched = productionEndpointTouched
        self.productionSecretRead = productionSecretRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public static let testnetHost = "testnet.binance.vision"

    public static var defaultTestnetBaseURL: URL {
        guard let url = URL(string: "https://\(testnetHost)") else {
            preconditionFailure("Invalid deterministic GH-531 Binance testnet base URL")
        }
        return url
    }

    public static func endpointPath(
        for commandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind
    ) -> String {
        switch commandKind {
        case .submit, .cancel:
            "/api/v3/order"
        case .replace:
            "/api/v3/order/cancelReplace"
        }
    }

    public static func method(
        for commandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind
    ) -> ReleaseV010BinanceExecutionClientHTTPMethod {
        switch commandKind {
        case .submit, .replace:
            .post
        case .cancel:
            .delete
        }
    }

    public static func requiredQueryItemNames(
        for commandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind
    ) -> [String] {
        switch commandKind {
        case .submit:
            ["symbol", "side", "type", "timeInForce", "quantity", "price", "newClientOrderId", "recvWindow", "timestamp"]
        case .cancel:
            ["symbol", "origClientOrderId", "newClientOrderId", "recvWindow", "timestamp"]
        case .replace:
            [
                "symbol",
                "side",
                "type",
                "timeInForce",
                "quantity",
                "price",
                "cancelOrigClientOrderId",
                "newClientOrderId",
                "cancelReplaceMode",
                "recvWindow",
                "timestamp"
            ]
        }
    }
}

/// ReleaseV010BinanceExecutionClientTestnetCommandAck 是 GH-531 testnet transport acknowledgement evidence。
///
/// Ack 只证明 testnet adapter 接受了 request mapping。它不代表 production exchange fill、broker fill、
/// execution report parser、Portfolio update 或 reconciliation runtime。
public struct ReleaseV010BinanceExecutionClientTestnetCommandAck: Codable, Equatable, Sendable {
    public let ackID: Identifier
    public let requestID: Identifier
    public let commandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind
    public let environment: ReleaseV010BinanceExecutionClientVenueEnvironment
    public let acceptedByTestnetAdapter: Bool
    public let deterministicTraceID: Identifier
    public let responseStatus: String
    public let productionEndpointTouched: Bool
    public let productionOrderTouched: Bool
    public let brokerGatewayTouched: Bool
    public let executionReportParsed: Bool
    public let brokerFillParsed: Bool
    public let reconciliationPerformed: Bool

    public var ackBoundaryHeld: Bool {
        environment == .testnet
            && acceptedByTestnetAdapter
            && responseStatus.isEmpty == false
            && [
                productionEndpointTouched,
                productionOrderTouched,
                brokerGatewayTouched,
                executionReportParsed,
                brokerFillParsed,
                reconciliationPerformed
            ].allSatisfy { $0 == false }
    }

    public init(
        ackID: Identifier,
        requestID: Identifier,
        commandKind: ReleaseV010BinanceExecutionClientTestnetCommandKind,
        environment: ReleaseV010BinanceExecutionClientVenueEnvironment = .testnet,
        acceptedByTestnetAdapter: Bool = true,
        deterministicTraceID: Identifier,
        responseStatus: String,
        productionEndpointTouched: Bool = false,
        productionOrderTouched: Bool = false,
        brokerGatewayTouched: Bool = false,
        executionReportParsed: Bool = false,
        brokerFillParsed: Bool = false,
        reconciliationPerformed: Bool = false
    ) throws {
        guard environment == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.productionAck")
        }
        guard acceptedByTestnetAdapter else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "acceptedByTestnetAdapter",
                expected: "true",
                actual: "false"
            )
        }
        guard responseStatus.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "responseStatus",
                expected: "non-empty Binance testnet command status",
                actual: "empty"
            )
        }
        for forbiddenFlag in [
            ("productionEndpointTouched", productionEndpointTouched),
            ("productionOrderTouched", productionOrderTouched),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("executionReportParsed", executionReportParsed),
            ("brokerFillParsed", brokerFillParsed),
            ("reconciliationPerformed", reconciliationPerformed)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.\(forbiddenFlag.0)")
        }

        self.ackID = ackID
        self.requestID = requestID
        self.commandKind = commandKind
        self.environment = environment
        self.acceptedByTestnetAdapter = acceptedByTestnetAdapter
        self.deterministicTraceID = deterministicTraceID
        self.responseStatus = responseStatus
        self.productionEndpointTouched = productionEndpointTouched
        self.productionOrderTouched = productionOrderTouched
        self.brokerGatewayTouched = brokerGatewayTouched
        self.executionReportParsed = executionReportParsed
        self.brokerFillParsed = brokerFillParsed
        self.reconciliationPerformed = reconciliationPerformed
    }
}

/// ReleaseV010BinanceExecutionClientTestnetTransport 是 GH-531 的 ExecutionClient transport protocol。
///
/// Protocol 只接受已经过 credential guard 和 GH-530 OMS evidence 绑定的 testnet request mapping。
/// Production URLSession / broker gateway transport 不属于当前 issue。
public protocol ReleaseV010BinanceExecutionClientTestnetTransport: Sendable {
    func send(_ request: ReleaseV010BinanceExecutionClientTestnetCommandRequest) throws
        -> ReleaseV010BinanceExecutionClientTestnetCommandAck
}

/// ReleaseV010BinanceDeterministicTestnetTransport 是 required validation 使用的 testnet transport fixture。
///
/// 该 transport 不连网、不读 secret、不生成真实签名，只对 request mapping 返回 deterministic ack。
public struct ReleaseV010BinanceDeterministicTestnetTransport: ReleaseV010BinanceExecutionClientTestnetTransport {
    public init() {}

    public func send(
        _ request: ReleaseV010BinanceExecutionClientTestnetCommandRequest
    ) throws -> ReleaseV010BinanceExecutionClientTestnetCommandAck {
        guard request.requestMappingHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requestMappingHeld",
                expected: "true",
                actual: "false"
            )
        }
        return try ReleaseV010BinanceExecutionClientTestnetCommandAck(
            ackID: Identifier.constant("gh-531-binance-testnet-\(request.commandKind.rawValue)-ack"),
            requestID: request.requestID,
            commandKind: request.commandKind,
            deterministicTraceID: Identifier.constant("gh-531-binance-testnet-\(request.commandKind.rawValue)-trace"),
            responseStatus: "accepted by deterministic Binance testnet \(request.commandKind.rawValue) adapter"
        )
    }
}

/// ReleaseV010BinanceExecutionClientTestnetCommandEvidence 汇总 GH-531 submit / cancel / replace evidence。
///
/// Evidence 必须覆盖三类 command、credential reference guard、GH-530 OMS source IDs、testnet endpoint
/// mapping 和 production disabled flags。
/// `GH-531-TESTNET-SUBMIT-CANCEL-REPLACE-EVIDENCE`
/// `TVM-RELEASE-V010-BINANCE-EXECUTIONCLIENT-TESTNET-SCR`
public struct ReleaseV010BinanceExecutionClientTestnetCommandEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let capabilityMatrix: ReleaseV010BinanceExecutionClientCapabilityMatrix
    public let credentialGuard: ReleaseV010BinanceExecutionClientCredentialGuard
    public let requests: [ReleaseV010BinanceExecutionClientTestnetCommandRequest]
    public let acknowledgements: [ReleaseV010BinanceExecutionClientTestnetCommandAck]
    public let validationAnchors: [String]
    public let productionEndpointDisabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let productionSubmitEnabledByDefault: Bool
    public let productionCancelEnabledByDefault: Bool
    public let productionReplaceEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let executionReportParsed: Bool
    public let brokerFillParsed: Bool
    public let reconciliationPerformed: Bool
    public let liveCommandSurfaceTouched: Bool

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-531"
            && upstreamIssueID.rawValue == "GH-530"
            && capabilityMatrix.matrixHeld
            && credentialGuard.guardHeld
            && Set(requests.map(\.commandKind)) == Set(ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases)
            && Set(acknowledgements.map(\.commandKind)) == Set(ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases)
            && requests.allSatisfy(\.requestMappingHeld)
            && acknowledgements.allSatisfy(\.ackBoundaryHeld)
            && requests.map(\.requestID) == acknowledgements.map(\.requestID)
            && validationAnchors == ReleaseV010BinanceExecutionClientTestnetAdapter.requiredValidationAnchors
            && productionEndpointDisabled
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            productionTradingEnabledByDefault,
            productionSecretReadEnabledByDefault,
            productionSubmitEnabledByDefault,
            productionCancelEnabledByDefault,
            productionReplaceEnabledByDefault,
            brokerGatewayTouched,
            executionReportParsed,
            brokerFillParsed,
            reconciliationPerformed,
            liveCommandSurfaceTouched
        ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-531-binance-testnet-command-evidence"),
        issueID: Identifier = Identifier.constant("GH-531"),
        upstreamIssueID: Identifier = Identifier.constant("GH-530"),
        capabilityMatrix: ReleaseV010BinanceExecutionClientCapabilityMatrix,
        credentialGuard: ReleaseV010BinanceExecutionClientCredentialGuard,
        requests: [ReleaseV010BinanceExecutionClientTestnetCommandRequest],
        acknowledgements: [ReleaseV010BinanceExecutionClientTestnetCommandAck],
        validationAnchors: [String] = ReleaseV010BinanceExecutionClientTestnetAdapter.requiredValidationAnchors,
        productionEndpointDisabled: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        productionSubmitEnabledByDefault: Bool = false,
        productionCancelEnabledByDefault: Bool = false,
        productionReplaceEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        executionReportParsed: Bool = false,
        brokerFillParsed: Bool = false,
        reconciliationPerformed: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-531" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-531",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-530" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-530",
                actual: upstreamIssueID.rawValue
            )
        }
        guard capabilityMatrix.matrixHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "capabilityMatrix",
                expected: "GH-531 capability matrix held",
                actual: "mismatch"
            )
        }
        guard credentialGuard.guardHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "credentialGuard",
                expected: "GH-531 credential guard held",
                actual: "mismatch"
            )
        }
        guard Set(requests.map(\.commandKind)) == Set(ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requests",
                expected: ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: requests.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard Set(acknowledgements.map(\.commandKind)) == Set(ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "acknowledgements",
                expected: ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: acknowledgements.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard requests.map(\.requestID) == acknowledgements.map(\.requestID) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requestAckCorrelation",
                expected: "request IDs match acknowledgement IDs by command order",
                actual: "mismatch"
            )
        }
        guard validationAnchors == ReleaseV010BinanceExecutionClientTestnetAdapter.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: ReleaseV010BinanceExecutionClientTestnetAdapter.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard productionEndpointDisabled else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.productionEndpointDisabled")
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretReadEnabledByDefault", productionSecretReadEnabledByDefault),
            ("productionSubmitEnabledByDefault", productionSubmitEnabledByDefault),
            ("productionCancelEnabledByDefault", productionCancelEnabledByDefault),
            ("productionReplaceEnabledByDefault", productionReplaceEnabledByDefault),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("executionReportParsed", executionReportParsed),
            ("brokerFillParsed", brokerFillParsed),
            ("reconciliationPerformed", reconciliationPerformed),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.\(forbiddenFlag.0)")
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.capabilityMatrix = capabilityMatrix
        self.credentialGuard = credentialGuard
        self.requests = requests
        self.acknowledgements = acknowledgements
        self.validationAnchors = validationAnchors
        self.productionEndpointDisabled = productionEndpointDisabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.productionSubmitEnabledByDefault = productionSubmitEnabledByDefault
        self.productionCancelEnabledByDefault = productionCancelEnabledByDefault
        self.productionReplaceEnabledByDefault = productionReplaceEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.executionReportParsed = executionReportParsed
        self.brokerFillParsed = brokerFillParsed
        self.reconciliationPerformed = reconciliationPerformed
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }
}

/// ReleaseV010BinanceExecutionClientTestnetAdapter 是 GH-531 的 ExecutionClient testnet adapter 实现。
///
/// Adapter 只把 GH-530 OMS evidence identity 映射为 Binance Spot testnet submit / cancel / replace
/// request，并通过 transport protocol 输出 deterministic ack。它不连接 production endpoint，不读取
/// production secret，不生成 production order，也不解析 execution report / broker fill。
/// `GH-531-BINANCE-TESTNET-SUBMIT-CANCEL-REPLACE`
public struct ReleaseV010BinanceExecutionClientTestnetAdapter: Codable, Equatable, Sendable {
    public let adapterID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let capabilityMatrix: ReleaseV010BinanceExecutionClientCapabilityMatrix
    public let credentialGuard: ReleaseV010BinanceExecutionClientCredentialGuard
    public let environment: ReleaseV010BinanceExecutionClientVenueEnvironment
    public let validationAnchors: [String]
    public let productionEndpointEnabledByDefault: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabledByDefault: Bool
    public let brokerGatewayTouched: Bool
    public let bypassesRiskEngine: Bool
    public let bypassesOMS: Bool
    public let bypassesKillSwitch: Bool
    public let liveCommandSurfaceTouched: Bool

    public var adapterBoundaryHeld: Bool {
        issueID.rawValue == "GH-531"
            && upstreamIssueID.rawValue == "GH-530"
            && capabilityMatrix.matrixHeld
            && credentialGuard.guardHeld
            && environment == .testnet
            && validationAnchors == Self.requiredValidationAnchors
            && [
                productionEndpointEnabledByDefault,
                productionTradingEnabledByDefault,
                productionSecretReadEnabledByDefault,
                brokerGatewayTouched,
                bypassesRiskEngine,
                bypassesOMS,
                bypassesKillSwitch,
                liveCommandSurfaceTouched
            ].allSatisfy { $0 == false }
    }

    public init(
        adapterID: Identifier = Identifier.constant("gh-531-binance-executionclient-testnet-adapter"),
        issueID: Identifier = Identifier.constant("GH-531"),
        upstreamIssueID: Identifier = Identifier.constant("GH-530"),
        capabilityMatrix: ReleaseV010BinanceExecutionClientCapabilityMatrix? = nil,
        credentialGuard: ReleaseV010BinanceExecutionClientCredentialGuard? = nil,
        environment: ReleaseV010BinanceExecutionClientVenueEnvironment = .testnet,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionEndpointEnabledByDefault: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabledByDefault: Bool = false,
        brokerGatewayTouched: Bool = false,
        bypassesRiskEngine: Bool = false,
        bypassesOMS: Bool = false,
        bypassesKillSwitch: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedMatrix = try capabilityMatrix ?? ReleaseV010BinanceExecutionClientCapabilityMatrix.deterministicFixture()
        let resolvedGuard = try credentialGuard ?? ReleaseV010BinanceExecutionClientCredentialGuard.deterministicFixture()
        guard issueID.rawValue == "GH-531" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-531",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-530" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-530",
                actual: upstreamIssueID.rawValue
            )
        }
        guard resolvedMatrix.matrixHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "capabilityMatrix",
                expected: "GH-531 capability matrix held",
                actual: "mismatch"
            )
        }
        guard resolvedGuard.guardHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "credentialGuard",
                expected: "GH-531 credential guard held",
                actual: "mismatch"
            )
        }
        guard environment == .testnet else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.productionEnvironment")
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("productionEndpointEnabledByDefault", productionEndpointEnabledByDefault),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretReadEnabledByDefault", productionSecretReadEnabledByDefault),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("bypassesRiskEngine", bypassesRiskEngine),
            ("bypassesOMS", bypassesOMS),
            ("bypassesKillSwitch", bypassesKillSwitch),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.\(forbiddenFlag.0)")
        }

        self.adapterID = adapterID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.capabilityMatrix = resolvedMatrix
        self.credentialGuard = resolvedGuard
        self.environment = environment
        self.validationAnchors = validationAnchors
        self.productionEndpointEnabledByDefault = productionEndpointEnabledByDefault
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabledByDefault = productionSecretReadEnabledByDefault
        self.brokerGatewayTouched = brokerGatewayTouched
        self.bypassesRiskEngine = bypassesRiskEngine
        self.bypassesOMS = bypassesOMS
        self.bypassesKillSwitch = bypassesKillSwitch
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }

    public func submit(
        _ request: ReleaseV010BinanceExecutionClientTestnetCommandRequest,
        transport: ReleaseV010BinanceExecutionClientTestnetTransport = ReleaseV010BinanceDeterministicTestnetTransport()
    ) throws -> ReleaseV010BinanceExecutionClientTestnetCommandAck {
        try send(request, expectedKind: .submit, transport: transport)
    }

    public func cancel(
        _ request: ReleaseV010BinanceExecutionClientTestnetCommandRequest,
        transport: ReleaseV010BinanceExecutionClientTestnetTransport = ReleaseV010BinanceDeterministicTestnetTransport()
    ) throws -> ReleaseV010BinanceExecutionClientTestnetCommandAck {
        try send(request, expectedKind: .cancel, transport: transport)
    }

    public func replace(
        _ request: ReleaseV010BinanceExecutionClientTestnetCommandRequest,
        transport: ReleaseV010BinanceExecutionClientTestnetTransport = ReleaseV010BinanceDeterministicTestnetTransport()
    ) throws -> ReleaseV010BinanceExecutionClientTestnetCommandAck {
        try send(request, expectedKind: .replace, transport: transport)
    }

    /// 生成 GH-531 deterministic submit / cancel / replace evidence。
    public func deterministicCommandEvidence() throws -> ReleaseV010BinanceExecutionClientTestnetCommandEvidence {
        let submitRequest = try Self.deterministicRequest(
            kind: .submit,
            credentialReferenceID: credentialGuard.credentialReferenceID
        )
        let cancelRequest = try Self.deterministicRequest(
            kind: .cancel,
            credentialReferenceID: credentialGuard.credentialReferenceID
        )
        let replaceRequest = try Self.deterministicRequest(
            kind: .replace,
            credentialReferenceID: credentialGuard.credentialReferenceID
        )
        return try ReleaseV010BinanceExecutionClientTestnetCommandEvidence(
            capabilityMatrix: capabilityMatrix,
            credentialGuard: credentialGuard,
            requests: [submitRequest, cancelRequest, replaceRequest],
            acknowledgements: [
                submit(submitRequest),
                cancel(cancelRequest),
                replace(replaceRequest)
            ]
        )
    }

    public static func deterministicFixture() throws -> ReleaseV010BinanceExecutionClientTestnetAdapter {
        try ReleaseV010BinanceExecutionClientTestnetAdapter()
    }

    public static let requiredValidationAnchors = [
        "GH-531-BINANCE-TESTNET-SUBMIT-CANCEL-REPLACE",
        "GH-531-BINANCE-TESTNET-REQUEST-MAPPING",
        "GH-531-TESTNET-CREDENTIAL-GUARD",
        "GH-531-BINANCE-TESTNET-CAPABILITY-MATRIX",
        "GH-531-TESTNET-SUBMIT-CANCEL-REPLACE-EVIDENCE",
        "GH-531-PRODUCTION-ENDPOINT-EXPLICIT-GATE",
        "TVM-RELEASE-V010-BINANCE-EXECUTIONCLIENT-TESTNET-SCR"
    ]

    static func deterministicRequest(
        kind: ReleaseV010BinanceExecutionClientTestnetCommandKind,
        credentialReferenceID: Identifier
    ) throws -> ReleaseV010BinanceExecutionClientTestnetCommandRequest {
        try ReleaseV010BinanceExecutionClientTestnetCommandRequest(
            requestID: Identifier.constant("gh-531-binance-testnet-\(kind.rawValue)-request"),
            commandKind: kind,
            credentialReferenceID: credentialReferenceID,
            sourceOMSOrderID: Identifier.constant("gh-530-oms-\(kind.rawValue)-order"),
            sourceOMSEventLogID: Identifier.constant("gh-530-oms-\(kind.rawValue)-event-log"),
            sourceRiskDecisionID: Identifier.constant("gh-529-approved-risk-decision"),
            clientOrderID: Identifier.constant("gh-531-client-order-\(kind.rawValue)"),
            symbol: "BTCUSDT",
            queryItems: try deterministicQueryItems(kind: kind)
        )
    }

    private func send(
        _ request: ReleaseV010BinanceExecutionClientTestnetCommandRequest,
        expectedKind: ReleaseV010BinanceExecutionClientTestnetCommandKind,
        transport: ReleaseV010BinanceExecutionClientTestnetTransport
    ) throws -> ReleaseV010BinanceExecutionClientTestnetCommandAck {
        guard adapterBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "adapterBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard request.commandKind == expectedKind else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandKind",
                expected: expectedKind.rawValue,
                actual: request.commandKind.rawValue
            )
        }
        guard request.credentialReferenceID == credentialGuard.credentialReferenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "credentialReferenceID",
                expected: credentialGuard.credentialReferenceID.rawValue,
                actual: request.credentialReferenceID.rawValue
            )
        }
        return try transport.send(request)
    }

    private static func deterministicQueryItems(
        kind: ReleaseV010BinanceExecutionClientTestnetCommandKind
    ) throws -> [ReleaseV010BinanceExecutionClientTestnetQueryItem] {
        switch kind {
        case .submit:
            return try [
                item("symbol", "BTCUSDT"),
                item("side", "BUY"),
                item("type", "LIMIT"),
                item("timeInForce", "GTC"),
                item("quantity", "0.0100"),
                item("price", "42120.70"),
                item("newClientOrderId", "gh-531-submit-client-order"),
                item("recvWindow", "5000"),
                item("timestamp", "1704067531000")
            ]
        case .cancel:
            return try [
                item("symbol", "BTCUSDT"),
                item("origClientOrderId", "gh-531-submit-client-order"),
                item("newClientOrderId", "gh-531-cancel-client-order"),
                item("recvWindow", "5000"),
                item("timestamp", "1704067532000")
            ]
        case .replace:
            return try [
                item("symbol", "BTCUSDT"),
                item("side", "BUY"),
                item("type", "LIMIT"),
                item("timeInForce", "GTC"),
                item("quantity", "0.0100"),
                item("price", "42130.70"),
                item("cancelOrigClientOrderId", "gh-531-submit-client-order"),
                item("newClientOrderId", "gh-531-replace-client-order"),
                item("cancelReplaceMode", "STOP_ON_FAILURE"),
                item("recvWindow", "5000"),
                item("timestamp", "1704067533000")
            ]
        }
    }

    private static func item(
        _ name: String,
        _ value: String
    ) throws -> ReleaseV010BinanceExecutionClientTestnetQueryItem {
        try ReleaseV010BinanceExecutionClientTestnetQueryItem(name: name, value: value)
    }
}
