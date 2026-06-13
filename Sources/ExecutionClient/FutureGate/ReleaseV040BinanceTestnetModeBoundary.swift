import DomainModel
import Foundation

/// ReleaseV040BinanceTestnetModeFlag 固定 GH-702 允许的 operator 显式 mode flag。
///
/// `--mode testnet` 只是 testnet-gated rehearsal evidence，不会让 testnet 成为默认模式，
/// 也不会连接 production endpoint、读取 secret 或提交真实订单。
public enum ReleaseV040BinanceTestnetModeFlag: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "--mode dry-run"
    case testnet = "--mode testnet"
}

/// ReleaseV040BinanceTestnetEnvironment 固定 GH-702 唯一允许的外部环境引用。
public enum ReleaseV040BinanceTestnetEnvironment: String, Codable, Equatable, Hashable, Sendable {
    case testnet
}

/// ReleaseV040BinanceTestnetEndpointReference 是 Binance testnet-only endpoint evidence。
///
/// 该类型只保存 endpoint reference，构造阶段拒绝 production host、非 HTTPS、user-info、
/// path/query/fragment 和 fallback-to-production。它不创建 network client。
public struct ReleaseV040BinanceTestnetEndpointReference: Codable, Equatable, Sendable {
    public let endpointID: Identifier
    public let productType: ProductType
    public let environment: ReleaseV040BinanceTestnetEnvironment
    public let baseURL: URL
    public let testnetOnly: Bool
    public let productionEndpoint: Bool
    public let fallbackToProduction: Bool

    public var endpointHeld: Bool {
        environment == .testnet
            && ReleaseV040RehearsalRunContext.requiredProductTypes.contains(productType)
            && baseURL.scheme?.lowercased() == "https"
            && baseURL.host?.lowercased() == Self.expectedHost(for: productType)
            && baseURL.user == nil
            && baseURL.password == nil
            && (baseURL.path.isEmpty || baseURL.path == "/")
            && baseURL.query == nil
            && baseURL.fragment == nil
            && testnetOnly
            && productionEndpoint == false
            && fallbackToProduction == false
    }

    public init(
        endpointID: Identifier,
        productType: ProductType,
        environment: ReleaseV040BinanceTestnetEnvironment = .testnet,
        baseURL: URL,
        testnetOnly: Bool = true,
        productionEndpoint: Bool = false,
        fallbackToProduction: Bool = false
    ) throws {
        guard ReleaseV040RehearsalRunContext.requiredProductTypes.contains(productType) else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceTestnet.unsupportedProductType")
        }
        guard environment == .testnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.environment",
                expected: ReleaseV040BinanceTestnetEnvironment.testnet.rawValue,
                actual: environment.rawValue
            )
        }
        guard baseURL.scheme?.lowercased() == "https" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceTestnet.nonHTTPSBaseURL")
        }
        guard baseURL.user == nil, baseURL.password == nil else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceTestnet.baseURLUserInfo")
        }
        guard baseURL.path.isEmpty || baseURL.path == "/" else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceTestnet.baseURLPath")
        }
        guard baseURL.query == nil, baseURL.fragment == nil else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceTestnet.baseURLQuery")
        }
        guard let host = baseURL.host?.lowercased(), Self.productionHosts.contains(host) == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceTestnet.productionEndpoint")
        }
        guard baseURL.host?.lowercased() == Self.expectedHost(for: productType) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.host",
                expected: Self.expectedHost(for: productType),
                actual: baseURL.host?.lowercased() ?? "nil"
            )
        }
        guard testnetOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.testnetOnly",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(productionEndpoint, "productionEndpoint")
        try Self.forbid(fallbackToProduction, "fallbackToProduction")

        self.endpointID = endpointID
        self.productType = productType
        self.environment = environment
        self.baseURL = baseURL
        self.testnetOnly = testnetOnly
        self.productionEndpoint = productionEndpoint
        self.fallbackToProduction = fallbackToProduction
    }

    public static func expectedHost(for productType: ProductType) -> String {
        switch productType {
        case .spot:
            "testnet.binance.vision"
        case .usdsPerpetual:
            "testnet.binancefuture.com"
        }
    }

    public static let productionHosts: Set<String> = [
        "api.binance.com",
        "fapi.binance.com"
    ]

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceTestnet.endpoint.\(field)")
        }
    }
}

/// ReleaseV040BinanceTestnetOperatorConfirmation 是 testnet mode 的人工显式确认 evidence。
///
/// 该 evidence 只确认 operator 已显式选择 testnet rehearsal，不授权 production cutover、
/// production secret read、production endpoint connection 或真实 submit / cancel / replace。
public struct ReleaseV040BinanceTestnetOperatorConfirmation: Codable, Equatable, Sendable {
    public let confirmationID: Identifier
    public let runContext: ReleaseV040RehearsalRunContext
    public let modeFlag: ReleaseV040BinanceTestnetModeFlag
    public let endpoint: ReleaseV040BinanceTestnetEndpointReference
    public let credentialProfileReference: String
    public let acknowledgedCheckpoints: [String]
    public let confirmedAt: Date
    public let operatorExplicitlyConfirmed: Bool
    public let dryRunDefaultPreserved: Bool
    public let testnetEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let fallbackToProduction: Bool

    public var runID: Identifier { runContext.runID }

    public var confirmationHeld: Bool {
        runContext.mode == .testnetGuarded
            && runContext.boundaryHeld
            && modeFlag == .testnet
            && endpoint.endpointHeld
            && credentialProfileReference.hasPrefix(Self.testnetCredentialPrefix)
            && acknowledgedCheckpoints == Self.requiredAcknowledgedCheckpoints
            && operatorExplicitlyConfirmed
            && dryRunDefaultPreserved
            && testnetEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionOrderSubmitted == false
            && fallbackToProduction == false
    }

    public init(
        confirmationID: Identifier,
        runContext: ReleaseV040RehearsalRunContext,
        modeFlag: ReleaseV040BinanceTestnetModeFlag,
        endpoint: ReleaseV040BinanceTestnetEndpointReference,
        credentialProfileReference: String,
        acknowledgedCheckpoints: [String] = Self.requiredAcknowledgedCheckpoints,
        confirmedAt: Date,
        operatorExplicitlyConfirmed: Bool = true,
        dryRunDefaultPreserved: Bool = true,
        testnetEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        fallbackToProduction: Bool = false
    ) throws {
        guard runContext.mode == .testnetGuarded else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runContext.mode",
                expected: ReleaseV040RehearsalRunMode.testnetGuarded.rawValue,
                actual: runContext.mode.rawValue
            )
        }
        guard modeFlag == .testnet else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.modeFlag",
                expected: ReleaseV040BinanceTestnetModeFlag.testnet.rawValue,
                actual: modeFlag.rawValue
            )
        }
        guard endpoint.endpointHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.endpoint",
                expected: "held testnet endpoint reference",
                actual: endpoint.baseURL.absoluteString
            )
        }
        let trimmedCredentialReference = credentialProfileReference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedCredentialReference.hasPrefix(Self.testnetCredentialPrefix) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.credentialProfileReference",
                expected: "\(Self.testnetCredentialPrefix)*",
                actual: trimmedCredentialReference
            )
        }
        guard acknowledgedCheckpoints == Self.requiredAcknowledgedCheckpoints else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.acknowledgedCheckpoints",
                expected: Self.requiredAcknowledgedCheckpoints.joined(separator: ","),
                actual: acknowledgedCheckpoints.joined(separator: ",")
            )
        }
        guard operatorExplicitlyConfirmed, dryRunDefaultPreserved else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.operatorConfirmation",
                expected: "explicit confirmation with dry-run default preserved",
                actual: "\(operatorExplicitlyConfirmed):\(dryRunDefaultPreserved)"
            )
        }
        try Self.forbid(testnetEnabledByDefault, "testnetEnabledByDefault")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(fallbackToProduction, "fallbackToProduction")

        self.confirmationID = confirmationID
        self.runContext = runContext
        self.modeFlag = modeFlag
        self.endpoint = endpoint
        self.credentialProfileReference = trimmedCredentialReference
        self.acknowledgedCheckpoints = acknowledgedCheckpoints
        self.confirmedAt = confirmedAt
        self.operatorExplicitlyConfirmed = operatorExplicitlyConfirmed
        self.dryRunDefaultPreserved = dryRunDefaultPreserved
        self.testnetEnabledByDefault = testnetEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.fallbackToProduction = fallbackToProduction
    }

    public static let testnetCredentialPrefix = "testnet-profile:"

    public static let requiredAcknowledgedCheckpoints = [
        "explicit --mode testnet requested",
        "testnet endpoint reference only",
        "testnet credential profile reference only",
        "dry-run remains the default mode",
        "production fallback remains blocked"
    ]

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceTestnet.confirmation.\(field)")
        }
    }
}

/// ReleaseV040BinanceTestnetModeBoundaryEvidence 汇总 GH-702 testnet-gated mode evidence。
public struct ReleaseV040BinanceTestnetModeBoundaryEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let upstreamAdapterEvidenceID: Identifier
    public let upstreamAdapterValidationAnchor: String
    public let defaultMode: ReleaseV040RehearsalRunMode
    public let requestedMode: ReleaseV040RehearsalRunMode
    public let runContext: ReleaseV040RehearsalRunContext
    public let endpoints: [ReleaseV040BinanceTestnetEndpointReference]
    public let confirmations: [ReleaseV040BinanceTestnetOperatorConfirmation]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let testnetEnabledByDefault: Bool
    public let networkCallPerformed: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let fallbackToProduction: Bool
    public let productionCutoverAuthorized: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-702"
            && upstreamIssueID.rawValue == "GH-701"
            && downstreamIssueID.rawValue == "GH-707"
            && upstreamAdapterValidationAnchor == ReleaseV040BinanceDryRunExecutionClientAdapterEvidence.validationAnchor
            && defaultMode == .dryRun
            && requestedMode == .testnetGuarded
            && runContext.mode == .testnetGuarded
            && endpointCoverageHeld
            && operatorConfirmationCoverageHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && boundaryHeld
    }

    public var endpointCoverageHeld: Bool {
        Set(endpoints.map(\.productType)) == Set(ReleaseV040RehearsalRunContext.requiredProductTypes)
            && endpoints.count == ReleaseV040RehearsalRunContext.requiredProductTypes.count
            && endpoints.allSatisfy(\.endpointHeld)
    }

    public var operatorConfirmationCoverageHeld: Bool {
        Set(confirmations.map { $0.endpoint.productType }) == Set(ReleaseV040RehearsalRunContext.requiredProductTypes)
            && confirmations.count == endpoints.count
            && confirmations.allSatisfy { $0.runID == runContext.runID && $0.confirmationHeld }
    }

    public var boundaryHeld: Bool {
        testnetEnabledByDefault == false
            && networkCallPerformed == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionOrderSubmitted == false
            && fallbackToProduction == false
            && productionCutoverAuthorized == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-702-v040-binance-testnet-mode-boundary"),
        issueID: Identifier = Identifier.constant("GH-702"),
        upstreamIssueID: Identifier = Identifier.constant("GH-701"),
        downstreamIssueID: Identifier = Identifier.constant("GH-707"),
        upstreamAdapterEvidenceID: Identifier,
        upstreamAdapterValidationAnchor: String = ReleaseV040BinanceDryRunExecutionClientAdapterEvidence.validationAnchor,
        defaultMode: ReleaseV040RehearsalRunMode = .dryRun,
        requestedMode: ReleaseV040RehearsalRunMode = .testnetGuarded,
        runContext: ReleaseV040RehearsalRunContext,
        endpoints: [ReleaseV040BinanceTestnetEndpointReference],
        confirmations: [ReleaseV040BinanceTestnetOperatorConfirmation],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        testnetEnabledByDefault: Bool = false,
        networkCallPerformed: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        fallbackToProduction: Bool = false,
        productionCutoverAuthorized: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-702", upstreamIssueID.rawValue == "GH-701", downstreamIssueID.rawValue == "GH-707" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.issueChain",
                expected: "GH-702<-GH-701->GH-707",
                actual: "\(issueID.rawValue)<-\(upstreamIssueID.rawValue)->\(downstreamIssueID.rawValue)"
            )
        }
        guard defaultMode == .dryRun, requestedMode == .testnetGuarded, runContext.mode == .testnetGuarded else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.mode",
                expected: "default dry-run and requested testnet-guarded",
                actual: "\(defaultMode.rawValue):\(requestedMode.rawValue):\(runContext.mode.rawValue)"
            )
        }
        guard upstreamAdapterValidationAnchor == ReleaseV040BinanceDryRunExecutionClientAdapterEvidence.validationAnchor else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.upstreamAdapterValidationAnchor",
                expected: ReleaseV040BinanceDryRunExecutionClientAdapterEvidence.validationAnchor,
                actual: upstreamAdapterValidationAnchor
            )
        }
        try Self.forbid(testnetEnabledByDefault, "testnetEnabledByDefault")
        try Self.forbid(networkCallPerformed, "networkCallPerformed")
        try Self.forbid(productionSecretRead, "productionSecretRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(fallbackToProduction, "fallbackToProduction")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")
        try Self.forbid(startsNextMilestone, "startsNextMilestone")

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.upstreamAdapterEvidenceID = upstreamAdapterEvidenceID
        self.upstreamAdapterValidationAnchor = upstreamAdapterValidationAnchor
        self.defaultMode = defaultMode
        self.requestedMode = requestedMode
        self.runContext = runContext
        self.endpoints = endpoints
        self.confirmations = confirmations
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.testnetEnabledByDefault = testnetEnabledByDefault
        self.networkCallPerformed = networkCallPerformed
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.fallbackToProduction = fallbackToProduction
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.startsNextMilestone = startsNextMilestone

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.evidenceHeld",
                expected: "held GH-702 evidence",
                actual: "false"
            )
        }
    }

    public static let validationAnchor = "TVM-RELEASE-V040-BINANCE-TESTNET-MODE-BOUNDARY"

    public static let requiredValidationAnchors = [
        "V040-09-BINANCE-TESTNET-MODE-BOUNDARY",
        "V040-09-EXPLICIT-MODE-OPERATOR-CONFIRMATION",
        "V040-09-TESTNET-ONLY-ENDPOINT-ENVIRONMENT",
        "V040-09-PRODUCTION-FALLBACK-BLOCKED",
        validationAnchor
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH702BinanceTestnetModeBoundaryRequiresExplicitOperatorConfirmation",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV040BinanceTestnet.evidence.\(field)")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case evidenceID
        case issueID
        case upstreamIssueID
        case downstreamIssueID
        case upstreamAdapterEvidenceID
        case upstreamAdapterValidationAnchor
        case defaultMode
        case requestedMode
        case runContext
        case endpoints
        case confirmations
        case validationAnchors
        case requiredValidationCommands
        case testnetEnabledByDefault
        case networkCallPerformed
        case productionSecretRead
        case productionEndpointConnected
        case productionOrderSubmitted
        case fallbackToProduction
        case productionCutoverAuthorized
        case startsNextMilestone
    }
}

/// ReleaseV040BinanceTestnetModeBoundary 生成 GH-702 deterministic testnet-gated evidence。
public struct ReleaseV040BinanceTestnetModeBoundary: Sendable {
    public init() {}

    public func run(
        upstreamAdapterEvidence: ReleaseV040BinanceDryRunExecutionClientAdapterEvidence,
        confirmedAt: Date = Date(timeIntervalSince1970: 1_705_002_702)
    ) throws -> ReleaseV040BinanceTestnetModeBoundaryEvidence {
        guard upstreamAdapterEvidence.evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.upstreamAdapterEvidence",
                expected: "held GH-701 adapter evidence",
                actual: upstreamAdapterEvidence.evidenceID.rawValue
            )
        }

        let testnetRunContext = try ReleaseV040RehearsalRunContext(
            runID: upstreamAdapterEvidence.runContext.runID,
            mode: .testnetGuarded,
            correlationID: upstreamAdapterEvidence.runContext.correlationID,
            causationID: upstreamAdapterEvidence.evidenceID
        )
        let endpoints = try ReleaseV040RehearsalRunContext.requiredProductTypes.map { productType in
            try ReleaseV040BinanceTestnetEndpointReference(
                endpointID: Identifier.constant("gh-702-\(productType.rawValue)-testnet-endpoint"),
                productType: productType,
                baseURL: Self.baseURL(for: productType)
            )
        }
        let confirmations = try endpoints.map { endpoint in
            try ReleaseV040BinanceTestnetOperatorConfirmation(
                confirmationID: Identifier.constant("gh-702-\(endpoint.productType.rawValue)-operator-confirmation"),
                runContext: testnetRunContext,
                modeFlag: .testnet,
                endpoint: endpoint,
                credentialProfileReference: "testnet-profile:gh-702-\(endpoint.productType.rawValue)-credential",
                confirmedAt: confirmedAt
            )
        }

        return try ReleaseV040BinanceTestnetModeBoundaryEvidence(
            upstreamAdapterEvidenceID: upstreamAdapterEvidence.evidenceID,
            runContext: testnetRunContext,
            endpoints: endpoints,
            confirmations: confirmations
        )
    }

    public static func baseURL(for productType: ProductType) throws -> URL {
        let rawURL = "https://\(ReleaseV040BinanceTestnetEndpointReference.expectedHost(for: productType))"
        guard let url = URL(string: rawURL) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040BinanceTestnet.baseURL",
                expected: rawURL,
                actual: "nil"
            )
        }
        return url
    }
}
