import Crypto
import DomainModel
import Foundation

// GH-1097 static contract boundary:
// cliCommand=testnet-execution
// guardedRuntimeInvoked=true
// credentialProvider=testnet-env
// explicitOperatorConfirmationRequired=true
// missingCredentialFailsClosed=true
// redactedOutputPrinted=true
// artifactPathReturned=true
// runIDReturned=true
// checksumReturned=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false

/// ReleaseV0151BinanceSpotTestnetCLIRuntimeError 描述 #1097 CLI guarded runtime 的 fail-closed 错误。
///
/// 这些错误只覆盖 testnet-only provider、operator confirmation、输入 artifact 和 CLI 参数。
/// 它们不代表 production cutover，也不会授权 production secret、broker endpoint 或真实生产订单。
public enum ReleaseV0151BinanceSpotTestnetCLIRuntimeError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidArgument(field: String, expected: String, actual: String)
    case missingCredential(String)
    case forbiddenProvider(String)
    case forbiddenProductionArgument(String)
    case sourceArtifactMismatch(field: String, expected: String, actual: String)

    public var description: String {
        switch self {
        case let .invalidArgument(field, expected, actual):
            "Release v0.15.1 CLI guarded runtime invalid argument \(field): expected \(expected), actual \(actual)"
        case let .missingCredential(name):
            "Release v0.15.1 CLI guarded runtime missing required testnet credential: \(name)"
        case let .forbiddenProvider(provider):
            "Release v0.15.1 CLI guarded runtime forbids credential provider: \(provider)"
        case let .forbiddenProductionArgument(argument):
            "Release v0.15.1 CLI guarded runtime forbids production argument: \(argument)"
        case let .sourceArtifactMismatch(field, expected, actual):
            "Release v0.15.1 CLI guarded runtime source artifact mismatch \(field): expected \(expected), actual \(actual)"
        }
    }
}

/// ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind 固定 #1097 允许的 CLI credential provider。
///
/// `testnet-env` 只允许读取显式 testnet 命名的环境变量。CLI 默认不会接受 production provider、
/// production env 名称、API key value 参数或 signing secret value 参数。
public enum ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind: String, Codable, Equatable, Sendable {
    case testnetEnvironment = "testnet-env"
}

/// ReleaseV0151BinanceSpotTestnetCLICredentialProvider 从 testnet-only 环境变量加载短生命周期 material。
///
/// 该 provider 只把 key / secret 交给 v0.15 guarded runtime 的内存 material；它不打印、不编码、
/// 不写入 artifact，也不会读取 production secret。测试可注入本地 environment dictionary，CI 不需要真实 key。
public struct ReleaseV0151BinanceSpotTestnetCLICredentialProvider: Sendable {
    public let kind: ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind
    public let environment: [String: String]
    public let apiKeyEnvironmentName: String
    public let secretEnvironmentName: String

    public init(
        kind: ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind,
        environment: [String: String],
        apiKeyEnvironmentName: String = Self.defaultAPIKeyEnvironmentName,
        secretEnvironmentName: String = Self.defaultSecretEnvironmentName
    ) throws {
        try Self.validateTestnetEnvironmentName(apiKeyEnvironmentName, field: "apiKeyEnvironmentName")
        try Self.validateTestnetEnvironmentName(secretEnvironmentName, field: "secretEnvironmentName")

        self.kind = kind
        self.environment = environment
        self.apiKeyEnvironmentName = apiKeyEnvironmentName
        self.secretEnvironmentName = secretEnvironmentName
    }

    public func credential(
        referenceID: Identifier
    ) throws -> ReleaseV0150BinanceSpotTestnetCredentialMaterial {
        guard kind == .testnetEnvironment else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.forbiddenProvider(kind.rawValue)
        }
        guard let apiKey = environment[apiKeyEnvironmentName]?.trimmingCharacters(in: .whitespacesAndNewlines),
              apiKey.isEmpty == false else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.missingCredential(apiKeyEnvironmentName)
        }
        guard let secret = environment[secretEnvironmentName]?.trimmingCharacters(in: .whitespacesAndNewlines),
              secret.isEmpty == false else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.missingCredential(secretEnvironmentName)
        }

        let reference = try ReleaseV0150BinanceSpotTestnetCredentialReference(
            referenceID: referenceID,
            providerKind: .testnetEnvironmentReference
        )
        return try ReleaseV0150BinanceSpotTestnetCredentialMaterial(
            reference: reference,
            apiKeyHeaderValue: apiKey,
            signingSecretValue: secret
        )
    }

    public static let defaultAPIKeyEnvironmentName = "MTPRO_BINANCE_SPOT_TESTNET_API_KEY"
    public static let defaultSecretEnvironmentName = "MTPRO_BINANCE_SPOT_TESTNET_SECRET_KEY"

    public static func validateTestnetEnvironmentName(_ name: String, field: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: field,
                expected: "non-empty testnet environment variable name",
                actual: "empty"
            )
        }
        let upper = trimmed.uppercased()
        guard upper.contains("TESTNET"),
              upper.contains("PROD") == false,
              upper.contains("PRODUCTION") == false else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.forbiddenProvider(trimmed)
        }
    }
}

/// ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand 是 #1097 解析后的 operator runtime command。
///
/// Command 保存的都是可审计 identity、artifact path 和 testnet-only 参数。credential material、
/// original client order id 和 raw broker payload 只能在 runtime 调用栈内短暂存在，不能进入该 Codable 类型。
public struct ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand: Equatable, Sendable {
    public let action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction
    public let operatorConfirmationPhrase: String
    public let runID: Identifier
    public let credentialProviderKind: ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind
    public let credentialReferenceID: Identifier
    public let apiKeyEnvironmentName: String
    public let secretEnvironmentName: String
    public let symbol: Symbol
    public let side: OrderIntentSide
    public let quantity: Quantity
    public let strategy: OrderIntentStrategyKind
    public let sourceSequence: Int
    public let correlationID: Identifier
    public let strategySignalID: Identifier
    public let sourceMessageID: Identifier
    public let strategyRunID: Identifier
    public let intentID: Identifier?
    public let replacementQuantity: Quantity?
    public let replacementSourceSequence: Int?
    public let replacementCorrelationID: Identifier?
    public let replacementStrategySignalID: Identifier?
    public let replacementSourceMessageID: Identifier?
    public let replacementIntentID: Identifier?
    public let sourceSubmitEvidenceJSONPath: String?
    public let networkEventLogJSONPath: String?
    public let originalClientOrderID: String?
    public let timestampMilliseconds: Int64
    public let observedAtMilliseconds: Int64
    public let artifactPath: String
    public let redactedOutputRequested: Bool

    public var boundaryHeld: Bool {
        credentialProviderKind == .testnetEnvironment
            && redactedOutputRequested
            && operatorConfirmationPhrase == ReleaseV0150BinanceSpotTestnetCLIOperatorInput.requiredOperatorConfirmationPhrase
            && artifactPath.contains("v0.15.1/testnet-execution")
    }
}

/// ReleaseV0151BinanceSpotTestnetCLIRuntimeResult 是 CLI 输出的脱敏 runtime 结果。
///
/// 它只返回 run id、artifact path、checksum 和 runtime evidence identity。该结果不包含 API key、
/// signing secret、raw order id、raw response body 或 broker payload。
public struct ReleaseV0151BinanceSpotTestnetCLIRuntimeResult: Codable, Equatable, Sendable {
    public let resultID: Identifier
    public let action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction
    public let runID: Identifier
    public let artifactPath: String
    public let artifactChecksum: String
    public let runtimeEvidenceID: Identifier
    public let networkEventLogID: Identifier
    public let latestNetworkEventID: Identifier
    public let credentialReferenceID: Identifier
    public let guardedRuntimeInvoked: Bool
    public let credentialProvider: String
    public let explicitOperatorConfirmationRequired: Bool
    public let operatorConfirmationAccepted: Bool
    public let missingCredentialFailsClosed: Bool
    public let redactedOutputPrinted: Bool
    public let artifactPathReturned: Bool
    public let runIDReturned: Bool
    public let checksumReturned: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public init(
        resultID: Identifier,
        action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        runID: Identifier,
        artifactPath: String,
        artifactChecksum: String,
        runtimeEvidenceID: Identifier,
        networkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog,
        credentialReferenceID: Identifier,
        guardedRuntimeInvoked: Bool = true,
        credentialProvider: String = ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind.testnetEnvironment.rawValue,
        explicitOperatorConfirmationRequired: Bool = true,
        operatorConfirmationAccepted: Bool = true,
        missingCredentialFailsClosed: Bool = true,
        redactedOutputPrinted: Bool = true,
        artifactPathReturned: Bool = true,
        runIDReturned: Bool = true,
        checksumReturned: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard networkEventLog.boundaryHeld,
              let latestEvent = networkEventLog.eventArtifacts.last,
              latestEvent.actionEvidenceID == runtimeEvidenceID else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.sourceArtifactMismatch(
                field: "networkEventLog.latestEvent",
                expected: runtimeEvidenceID.rawValue,
                actual: networkEventLog.eventArtifacts.last?.actionEvidenceID.rawValue ?? "missing"
            )
        }
        guard Self.isLowercaseSHA256(artifactChecksum) else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "artifactChecksum",
                expected: "lowercase sha256",
                actual: artifactChecksum
            )
        }
        guard resultID == Self.deterministicID(
            action: action,
            runID: runID,
            runtimeEvidenceID: runtimeEvidenceID,
            artifactChecksum: artifactChecksum
        ) else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "resultID",
                expected: Self.deterministicID(
                    action: action,
                    runID: runID,
                    runtimeEvidenceID: runtimeEvidenceID,
                    artifactChecksum: artifactChecksum
                ).rawValue,
                actual: resultID.rawValue
            )
        }
        guard guardedRuntimeInvoked,
              credentialProvider == ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind.testnetEnvironment.rawValue,
              explicitOperatorConfirmationRequired,
              operatorConfirmationAccepted,
              missingCredentialFailsClosed,
              redactedOutputPrinted,
              artifactPathReturned,
              runIDReturned,
              checksumReturned,
              validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151CLIGuardedRuntime.unheldResult")
        }
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.resultID = resultID
        self.action = action
        self.runID = runID
        self.artifactPath = artifactPath
        self.artifactChecksum = artifactChecksum
        self.runtimeEvidenceID = runtimeEvidenceID
        self.networkEventLogID = networkEventLog.logID
        self.latestNetworkEventID = latestEvent.eventArtifactID
        self.credentialReferenceID = credentialReferenceID
        self.guardedRuntimeInvoked = guardedRuntimeInvoked
        self.credentialProvider = credentialProvider
        self.explicitOperatorConfirmationRequired = explicitOperatorConfirmationRequired
        self.operatorConfirmationAccepted = operatorConfirmationAccepted
        self.missingCredentialFailsClosed = missingCredentialFailsClosed
        self.redactedOutputPrinted = redactedOutputPrinted
        self.artifactPathReturned = artifactPathReturned
        self.runIDReturned = runIDReturned
        self.checksumReturned = checksumReturned
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        guardedRuntimeInvoked
            && credentialProvider == ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind.testnetEnvironment.rawValue
            && explicitOperatorConfirmationRequired
            && operatorConfirmationAccepted
            && missingCredentialFailsClosed
            && redactedOutputPrinted
            && artifactPathReturned
            && runIDReturned
            && checksumReturned
            && Self.isLowercaseSHA256(artifactChecksum)
            && productionTradingEnabledByDefault == false
            && productionSecretAutoRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var redactedOutputLines: [String] {
        [
            "mtpro \(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand)",
            "issue=GH-1097",
            "verificationAnchor=GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME",
            "validationAnchor=TVM-RELEASE-V0151-CLI-TESTNET-EXECUTION-RUNTIME",
            "requiredAnchors=\(validationAnchors.joined(separator: ","))",
            "action=\(action.rawValue)",
            "runID=\(runID.rawValue)",
            "artifactPath=\(artifactPath)",
            "artifactChecksum=\(artifactChecksum)",
            "runtimeEvidenceID=\(runtimeEvidenceID.rawValue)",
            "networkEventLogID=\(networkEventLogID.rawValue)",
            "latestNetworkEventID=\(latestNetworkEventID.rawValue)",
            "credentialProvider=\(credentialProvider)",
            "credentialReference=<redacted>",
            "guardedRuntimeInvoked=\(guardedRuntimeInvoked)",
            "explicitOperatorConfirmationRequired=\(explicitOperatorConfirmationRequired)",
            "operatorConfirmationAccepted=\(operatorConfirmationAccepted)",
            "missingCredentialFailsClosed=\(missingCredentialFailsClosed)",
            "redactedOutputPrinted=\(redactedOutputPrinted)",
            "artifactPathReturned=\(artifactPathReturned)",
            "runIDReturned=\(runIDReturned)",
            "checksumReturned=\(checksumReturned)",
            "rawSecretPrinted=false",
            "rawCredentialPrinted=false",
            "rawOrderIdentityPrinted=false",
            "rawBrokerPayloadPrinted=false",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionSecretAutoRead=\(productionSecretAutoRead)",
            "productionEndpointConnected=\(productionEndpointConnected)",
            "brokerEndpointConnected=\(brokerEndpointConnected)",
            "productionOrderSubmitted=\(productionOrderSubmitted)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public static let requiredValidationAnchors = [
        "GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME",
        "TVM-RELEASE-V0151-CLI-TESTNET-EXECUTION-RUNTIME",
        "V0151-004-CLI-GUARDED-RUNTIME-INVOKED",
        "V0151-004-TESTNET-ONLY-CREDENTIAL-PROVIDER",
        "V0151-004-SUBMIT-CANCEL-CANCEL-REPLACE-RUNTIME",
        "V0151-004-EXPLICIT-OPERATOR-CONFIRMATION",
        "V0151-004-REDACTED-OUTPUT",
        "V0151-004-MISSING-CREDENTIAL-FAIL-CLOSED",
        "V0151-004-RUN-ID-ARTIFACT-CHECKSUM",
        "V0151-004-NO-PRODUCTION-CUTOVER"
    ]

    public static func artifactChecksum(
        action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        runID: Identifier,
        artifactPath: String,
        runtimeEvidenceID: Identifier,
        networkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog
    ) -> String {
        let payload = [
            "gh-1097-v0151-cli-runtime-result",
            action.rawValue,
            runID.rawValue,
            artifactPath,
            runtimeEvidenceID.rawValue,
            networkEventLog.logID.rawValue,
            networkEventLog.latestArtifactChecksum
        ].joined(separator: "\n")
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func deterministicID(
        action: ReleaseV0150BinanceSpotTestnetCLIOperatorAction,
        runID: Identifier,
        runtimeEvidenceID: Identifier,
        artifactChecksum: String
    ) -> Identifier {
        .constant(
            [
                "gh-1097-v0151-cli-runtime-result",
                action.rawValue,
                runID.rawValue,
                runtimeEvidenceID.rawValue,
                artifactChecksum
            ].joined(separator: ":"),
            field: "releaseV0151CLIGuardedRuntime.resultID"
        )
    }

    private static func isLowercaseSHA256(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { "0123456789abcdef".contains($0) }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151CLIGuardedRuntime.result.\(field)")
        }
    }
}

/// ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow 把 `mtpro testnet-execution` 接到 v0.15 runtime。
///
/// submit 直接调用 #1068 submit runtime。cancel / cancel-replace 必须显式提供已有 source submit
/// evidence JSON 与 network event log JSON，避免 CLI 为了取消订单而偷偷发出新的 submit。
public enum ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow {
    public static func commandLineOutput(
        arguments: [String],
        environment: [String: String] = ProcessInfo.processInfo.environment,
        submitTransport: (any ReleaseV0150BinanceSpotTestnetSubmitTransport)? = nil,
        cancelTransport: (any ReleaseV0150BinanceSpotTestnetCancelTransport)? = nil
    ) async throws -> String {
        try await result(
            arguments: arguments,
            environment: environment,
            submitTransport: submitTransport,
            cancelTransport: cancelTransport
        ).redactedOutputLines.joined(separator: "\n")
    }

    public static func result(
        arguments: [String],
        environment: [String: String] = ProcessInfo.processInfo.environment,
        submitTransport: (any ReleaseV0150BinanceSpotTestnetSubmitTransport)? = nil,
        cancelTransport: (any ReleaseV0150BinanceSpotTestnetCancelTransport)? = nil
    ) async throws -> ReleaseV0151BinanceSpotTestnetCLIRuntimeResult {
        let command = try parse(arguments: arguments)
        let credentialProvider = try ReleaseV0151BinanceSpotTestnetCLICredentialProvider(
            kind: command.credentialProviderKind,
            environment: environment,
            apiKeyEnvironmentName: command.apiKeyEnvironmentName,
            secretEnvironmentName: command.secretEnvironmentName
        )
        let credential = try credentialProvider.credential(referenceID: command.credentialReferenceID)
        let resolvedSubmitTransport: any ReleaseV0150BinanceSpotTestnetSubmitTransport
        let resolvedCancelTransport: any ReleaseV0150BinanceSpotTestnetCancelTransport
        if let submitTransport, let cancelTransport {
            resolvedSubmitTransport = submitTransport
            resolvedCancelTransport = cancelTransport
        } else if let submitTransport {
            resolvedSubmitTransport = submitTransport
            resolvedCancelTransport = try ReleaseV0151BinanceSpotTestnetURLSessionTransport()
        } else if let cancelTransport {
            resolvedSubmitTransport = try ReleaseV0151BinanceSpotTestnetURLSessionTransport()
            resolvedCancelTransport = cancelTransport
        } else {
            let transport = try ReleaseV0151BinanceSpotTestnetURLSessionTransport()
            resolvedSubmitTransport = transport
            resolvedCancelTransport = transport
        }

        switch command.action {
        case .submit:
            return try await submit(command: command, credential: credential, transport: resolvedSubmitTransport)
        case .cancel:
            return try await cancel(command: command, credential: credential, transport: resolvedCancelTransport)
        case .cancelReplace:
            return try await cancelReplace(
                command: command,
                credential: credential,
                submitTransport: resolvedSubmitTransport,
                cancelTransport: resolvedCancelTransport
            )
        }
    }

    public static func parse(arguments: [String]) throws -> ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand {
        guard arguments.first == ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "command",
                expected: ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand,
                actual: arguments.first ?? "missing"
            )
        }
        let parser = try ArgumentParser(arguments: arguments)
        try parser.requireFlag(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.testnetFlag)
        try parser.forbidProductionArguments()

        let confirmationPhrase = try parser.requiredValue(
            ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.operatorConfirmFlag
        )
        guard confirmationPhrase == ReleaseV0150BinanceSpotTestnetCLIOperatorInput.requiredOperatorConfirmationPhrase else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151CLIGuardedRuntime.operatorConfirmation")
        }
        let actionRaw = try parser.requiredValue(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.actionFlag)
        guard let action = ReleaseV0150BinanceSpotTestnetCLIOperatorAction(rawValue: actionRaw) else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "action",
                expected: ReleaseV0150BinanceSpotTestnetCLIOperatorAction.allCases.map(\.rawValue).joined(separator: ","),
                actual: actionRaw
            )
        }
        let providerRaw = try parser.requiredValue("--credential-provider")
        guard let providerKind = ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind(rawValue: providerRaw),
              providerKind == .testnetEnvironment else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.forbiddenProvider(providerRaw)
        }
        let output = parser.value(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.outputFlag)
            ?? ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.redactedOutput
        guard output == ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.redactedOutput else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0151CLIGuardedRuntime.output.\(output)")
        }

        let symbol = try Symbol(rawValue: parser.requiredValue("--symbol"))
        let sideRaw = try parser.requiredValue("--side")
        guard let side = OrderIntentSide(rawValue: sideRaw) else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "side",
                expected: OrderIntentSide.allCases.map(\.rawValue).joined(separator: ","),
                actual: sideRaw
            )
        }
        let strategyRaw = parser.value("--strategy") ?? OrderIntentStrategyKind.ema.rawValue
        guard let strategy = OrderIntentStrategyKind(rawValue: strategyRaw.uppercased()) else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "strategy",
                expected: OrderIntentStrategyKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: strategyRaw
            )
        }

        let runID = Identifier.constant(parser.value("--run-id") ?? "gh-1097-v0151-\(action.rawValue)-run")
        let quantity = try Quantity(parser.requiredDouble("--quantity"), field: "releaseV0151CLI.quantity")
        let replacementQuantity = try parser.optionalDouble("--replacement-quantity").map {
            try Quantity($0, field: "releaseV0151CLI.replacementQuantity")
        }
        let timestampMilliseconds = try parser.optionalInt64("--timestamp-ms") ?? 1_704_067_200_000
        let observedAtMilliseconds = try parser.optionalInt64("--observed-at-ms") ?? timestampMilliseconds
        guard timestampMilliseconds > 0, observedAtMilliseconds > 0 else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "timestamp",
                expected: "positive unix milliseconds",
                actual: "\(timestampMilliseconds):\(observedAtMilliseconds)"
            )
        }

        return ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand(
            action: action,
            operatorConfirmationPhrase: confirmationPhrase,
            runID: runID,
            credentialProviderKind: providerKind,
            credentialReferenceID: Identifier.constant(
                parser.value("--credential-reference-id") ?? "gh-1097-binance-spot-testnet-credential"
            ),
            apiKeyEnvironmentName: parser.value("--testnet-api-key-env")
                ?? ReleaseV0151BinanceSpotTestnetCLICredentialProvider.defaultAPIKeyEnvironmentName,
            secretEnvironmentName: parser.value("--testnet-secret-env")
                ?? ReleaseV0151BinanceSpotTestnetCLICredentialProvider.defaultSecretEnvironmentName,
            symbol: symbol,
            side: side,
            quantity: quantity,
            strategy: strategy,
            sourceSequence: try parser.optionalInt("--source-sequence") ?? 1097,
            correlationID: Identifier.constant(parser.value("--correlation-id") ?? "gh-1097-\(action.rawValue)-correlation"),
            strategySignalID: Identifier.constant(parser.value("--strategy-signal-id") ?? "gh-1097-\(action.rawValue)-signal"),
            sourceMessageID: Identifier.constant(parser.value("--source-message-id") ?? "gh-1097-\(action.rawValue)-message"),
            strategyRunID: Identifier.constant(parser.value("--strategy-run-id") ?? runID.rawValue),
            intentID: optionalIdentifier(parser.value("--intent-id")),
            replacementQuantity: replacementQuantity,
            replacementSourceSequence: try parser.optionalInt("--replacement-source-sequence"),
            replacementCorrelationID: optionalIdentifier(parser.value("--replacement-correlation-id")),
            replacementStrategySignalID: optionalIdentifier(parser.value("--replacement-strategy-signal-id")),
            replacementSourceMessageID: optionalIdentifier(parser.value("--replacement-source-message-id")),
            replacementIntentID: optionalIdentifier(parser.value("--replacement-intent-id")),
            sourceSubmitEvidenceJSONPath: parser.value("--source-submit-evidence-json"),
            networkEventLogJSONPath: parser.value("--network-event-log-json"),
            originalClientOrderID: parser.value("--original-client-order-id"),
            timestampMilliseconds: timestampMilliseconds,
            observedAtMilliseconds: observedAtMilliseconds,
            artifactPath: parser.value("--artifact-path") ?? "artifacts/v0.15.1/testnet-execution/\(runID.rawValue)/\(action.rawValue).json",
            redactedOutputRequested: true
        )
    }

    private static func submit(
        command: ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        transport: any ReleaseV0150BinanceSpotTestnetSubmitTransport
    ) async throws -> ReleaseV0151BinanceSpotTestnetCLIRuntimeResult {
        let intent = try makeOrderIntent(command: command)
        try validateExplicitIntentID(command.intentID, actual: intent.intentID)
        let mapping = try makeMapping(intent: intent, operation: .submit, lifecycleState: .riskAccepted)
        let runtime = ReleaseV0150BinanceSpotTestnetSubmitRuntime(
            requestBuilder: try ReleaseV0150BinanceSpotTestnetSignedRequestBuilder(),
            transport: transport
        )
        let evidence = try await runtime.submitMarketOrder(
            intent: intent,
            mapping: mapping,
            credential: credential,
            operatorConfirmationID: operatorConfirmationID(command: command),
            timestamp: date(milliseconds: command.timestampMilliseconds)
        )
        let event = try ReleaseV0150BinanceSpotTestnetNetworkExecutionEventArtifact.fromSubmitRuntimeEvidence(
            evidence,
            sequenceNumber: 1,
            observedAtMilliseconds: command.observedAtMilliseconds
        )
        let log = try ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.make(eventArtifacts: [event])
        return try makeResult(
            command: command,
            runtimeEvidenceID: evidence.runtimeEvidenceID,
            networkEventLog: log,
            credentialReferenceID: credential.reference.referenceID
        )
    }

    private static func cancel(
        command: ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        transport: any ReleaseV0150BinanceSpotTestnetCancelTransport
    ) async throws -> ReleaseV0151BinanceSpotTestnetCLIRuntimeResult {
        let intent = try makeOrderIntent(command: command)
        try validateExplicitIntentID(command.intentID, actual: intent.intentID)
        let sourceSubmitEvidence = try decodeSourceSubmitEvidence(command)
        let existingLog = try decodeNetworkEventLog(command)
        try validateSourceSubmitEvidence(sourceSubmitEvidence, intent: intent, credentialReferenceID: credential.reference.referenceID)
        let cancelIdentity = try makeCancelIdentity(
            sourceSubmitEvidence: sourceSubmitEvidence,
            originalClientOrderID: command.originalClientOrderID
        )
        let runtime = ReleaseV0150BinanceSpotTestnetCancelRuntime(
            requestBuilder: try ReleaseV0150BinanceSpotTestnetSignedRequestBuilder(),
            transport: transport
        )
        let result = try await runtime.cancelSpotTestnetOrder(
            intent: intent,
            cancelMapping: try makeMapping(intent: intent, operation: .cancel, lifecycleState: .accepted),
            sourceSubmitEvidence: sourceSubmitEvidence,
            existingNetworkEventLog: existingLog,
            credential: credential,
            cancelOrderIdentity: cancelIdentity,
            operatorConfirmationID: operatorConfirmationID(command: command),
            timestamp: date(milliseconds: command.timestampMilliseconds),
            observedAtMilliseconds: command.observedAtMilliseconds
        )
        return try makeResult(
            command: command,
            runtimeEvidenceID: result.cancelEvidence.runtimeEvidenceID,
            networkEventLog: result.appendedNetworkEventLog,
            credentialReferenceID: credential.reference.referenceID
        )
    }

    private static func cancelReplace(
        command: ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand,
        credential: ReleaseV0150BinanceSpotTestnetCredentialMaterial,
        submitTransport: any ReleaseV0150BinanceSpotTestnetSubmitTransport,
        cancelTransport: any ReleaseV0150BinanceSpotTestnetCancelTransport
    ) async throws -> ReleaseV0151BinanceSpotTestnetCLIRuntimeResult {
        let sourceIntent = try makeOrderIntent(command: command)
        try validateExplicitIntentID(command.intentID, actual: sourceIntent.intentID)
        let replacementIntent = try makeReplacementOrderIntent(command: command)
        try validateExplicitIntentID(command.replacementIntentID, actual: replacementIntent.intentID)
        let sourceSubmitEvidence = try decodeSourceSubmitEvidence(command)
        let existingLog = try decodeNetworkEventLog(command)
        try validateSourceSubmitEvidence(sourceSubmitEvidence, intent: sourceIntent, credentialReferenceID: credential.reference.referenceID)
        let cancelIdentity = try makeCancelIdentity(
            sourceSubmitEvidence: sourceSubmitEvidence,
            originalClientOrderID: command.originalClientOrderID
        )
        let runtime = ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime(
            requestBuilder: try ReleaseV0150BinanceSpotTestnetSignedRequestBuilder(),
            cancelTransport: cancelTransport,
            submitTransport: submitTransport
        )
        let result = try await runtime.cancelReplaceSpotTestnetOrder(
            sourceIntent: sourceIntent,
            replacementIntent: replacementIntent,
            replaceMapping: try makeMapping(intent: sourceIntent, operation: .replace, lifecycleState: .accepted),
            cancelMapping: try makeMapping(intent: sourceIntent, operation: .cancel, lifecycleState: .accepted),
            replacementSubmitMapping: try makeMapping(intent: replacementIntent, operation: .submit, lifecycleState: .riskAccepted),
            sourceSubmitEvidence: sourceSubmitEvidence,
            existingNetworkEventLog: existingLog,
            credential: credential,
            cancelOrderIdentity: cancelIdentity,
            operatorConfirmationID: operatorConfirmationID(command: command),
            cancelTimestamp: date(milliseconds: command.timestampMilliseconds),
            replacementSubmitTimestamp: date(milliseconds: command.timestampMilliseconds + 1_000),
            cancelObservedAtMilliseconds: command.observedAtMilliseconds,
            replacementSubmitObservedAtMilliseconds: command.observedAtMilliseconds + 1_000,
            cancelReplaceObservedAtMilliseconds: command.observedAtMilliseconds + 2_000
        )
        return try makeResult(
            command: command,
            runtimeEvidenceID: result.cancelReplaceEvidence.runtimeEvidenceID,
            networkEventLog: result.appendedNetworkEventLog,
            credentialReferenceID: credential.reference.referenceID
        )
    }

    private static func makeOrderIntent(
        command: ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand
    ) throws -> OrderIntent {
        let instrument = InstrumentIdentity.binance(productType: .spot, symbol: command.symbol)
        let policy = try OrderIntentPolicy(timeInForce: .goodTillCanceled)
        let correlation = try OrderIntentCorrelationMetadata(
            correlationID: command.correlationID,
            strategySignalID: command.strategySignalID,
            sourceMessageID: command.sourceMessageID,
            strategyRunID: command.strategyRunID,
            sourceSequence: command.sourceSequence
        )
        return try OrderIntent(
            intentID: OrderIntent.deterministicID(
                instrument: instrument,
                side: command.side,
                quantity: command.quantity,
                strategy: command.strategy,
                policy: policy,
                correlation: correlation
            ),
            instrument: instrument,
            side: command.side,
            quantity: command.quantity,
            strategy: command.strategy,
            policy: policy,
            correlation: correlation,
            createdAt: date(milliseconds: command.timestampMilliseconds)
        )
    }

    private static func makeReplacementOrderIntent(
        command: ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand
    ) throws -> OrderIntent {
        guard let replacementQuantity = command.replacementQuantity else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "--replacement-quantity",
                expected: "required for cancel-replace",
                actual: "missing"
            )
        }
        let instrument = InstrumentIdentity.binance(productType: .spot, symbol: command.symbol)
        let policy = try OrderIntentPolicy(timeInForce: .goodTillCanceled)
        let correlation = try OrderIntentCorrelationMetadata(
            correlationID: command.replacementCorrelationID ?? .constant("gh-1097-cancel-replace-replacement-correlation"),
            strategySignalID: command.replacementStrategySignalID ?? .constant("gh-1097-cancel-replace-replacement-signal"),
            sourceMessageID: command.replacementSourceMessageID ?? .constant("gh-1097-cancel-replace-replacement-message"),
            strategyRunID: command.strategyRunID,
            sourceSequence: command.replacementSourceSequence ?? (command.sourceSequence + 1)
        )
        return try OrderIntent(
            intentID: OrderIntent.deterministicID(
                instrument: instrument,
                side: command.side,
                quantity: replacementQuantity,
                strategy: command.strategy,
                policy: policy,
                correlation: correlation
            ),
            instrument: instrument,
            side: command.side,
            quantity: replacementQuantity,
            strategy: command.strategy,
            policy: policy,
            correlation: correlation,
            createdAt: date(milliseconds: command.timestampMilliseconds + 1_000)
        )
    }

    private static func makeMapping(
        intent: OrderIntent,
        operation: ExecutionContractOperation,
        lifecycleState: OrderLifecycleState
    ) throws -> ExecutionContractRequestMapping {
        try ExecutionContractRequestMapping(
            mappingID: ExecutionContractRequestMapping.deterministicID(
                intentID: intent.intentID,
                operation: operation,
                mode: .binanceTestnet,
                lifecycleState: lifecycleState
            ),
            intent: intent,
            operation: operation,
            mode: .binanceTestnet,
            lifecycleState: lifecycleState
        )
    }

    private static func decodeSourceSubmitEvidence(
        _ command: ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand
    ) throws -> ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence {
        guard let path = command.sourceSubmitEvidenceJSONPath else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "--source-submit-evidence-json",
                expected: "required for cancel and cancel-replace",
                actual: "missing"
            )
        }
        return try decode(ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence.self, fromPath: path)
    }

    private static func decodeNetworkEventLog(
        _ command: ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand
    ) throws -> ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog {
        guard let path = command.networkEventLogJSONPath else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "--network-event-log-json",
                expected: "required for cancel and cancel-replace",
                actual: "missing"
            )
        }
        return try decode(ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.self, fromPath: path)
    }

    private static func decode<T: Decodable>(_ type: T.Type, fromPath path: String) throws -> T {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }

    private static func validateSourceSubmitEvidence(
        _ evidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        intent: OrderIntent,
        credentialReferenceID: Identifier
    ) throws {
        guard evidence.boundaryHeld,
              evidence.intentID == intent.intentID,
              evidence.credentialReferenceID == credentialReferenceID else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.sourceArtifactMismatch(
                field: "sourceSubmitEvidence",
                expected: "\(intent.intentID.rawValue):\(credentialReferenceID.rawValue)",
                actual: "\(evidence.intentID.rawValue):\(evidence.credentialReferenceID.rawValue)"
            )
        }
    }

    private static func makeCancelIdentity(
        sourceSubmitEvidence: ReleaseV0150BinanceSpotTestnetSubmitRuntimeEvidence,
        originalClientOrderID: String?
    ) throws -> ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial {
        guard let originalClientOrderID else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "--original-client-order-id",
                expected: "required short-lived Binance Spot Testnet client order id",
                actual: "missing"
            )
        }
        let reference = try ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference(
            referenceID: ReleaseV0150BinanceSpotTestnetCancelOrderIdentityReference.deterministicID(
                sourceSubmitRuntimeEvidenceID: sourceSubmitEvidence.runtimeEvidenceID
            ),
            sourceSubmitEvidence: sourceSubmitEvidence
        )
        return try ReleaseV0150BinanceSpotTestnetCancelOrderIdentityMaterial(
            reference: reference,
            originalClientOrderID: originalClientOrderID
        )
    }

    private static func makeResult(
        command: ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand,
        runtimeEvidenceID: Identifier,
        networkEventLog: ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog,
        credentialReferenceID: Identifier
    ) throws -> ReleaseV0151BinanceSpotTestnetCLIRuntimeResult {
        let checksum = ReleaseV0151BinanceSpotTestnetCLIRuntimeResult.artifactChecksum(
            action: command.action,
            runID: command.runID,
            artifactPath: command.artifactPath,
            runtimeEvidenceID: runtimeEvidenceID,
            networkEventLog: networkEventLog
        )
        return try ReleaseV0151BinanceSpotTestnetCLIRuntimeResult(
            resultID: ReleaseV0151BinanceSpotTestnetCLIRuntimeResult.deterministicID(
                action: command.action,
                runID: command.runID,
                runtimeEvidenceID: runtimeEvidenceID,
                artifactChecksum: checksum
            ),
            action: command.action,
            runID: command.runID,
            artifactPath: command.artifactPath,
            artifactChecksum: checksum,
            runtimeEvidenceID: runtimeEvidenceID,
            networkEventLog: networkEventLog,
            credentialReferenceID: credentialReferenceID
        )
    }

    private static func validateExplicitIntentID(_ explicit: Identifier?, actual: Identifier) throws {
        guard let explicit else { return }
        guard explicit == actual else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: "--intent-id",
                expected: actual.rawValue,
                actual: explicit.rawValue
            )
        }
    }

    private static func operatorConfirmationID(
        command: ReleaseV0151BinanceSpotTestnetCLIRuntimeCommand
    ) -> Identifier {
        .constant("gh-1097-\(command.runID.rawValue)-operator-confirmation")
    }

    private static func date(milliseconds: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1_000)
    }

    private static func optionalIdentifier(_ raw: String?) -> Identifier? {
        guard let raw, raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return nil
        }
        return .constant(raw)
    }
}

private struct ArgumentParser {
    private let arguments: [String]
    private let values: [String: String]
    private let flags: Set<String>

    init(arguments: [String]) throws {
        self.arguments = arguments
        var values: [String: String] = [:]
        var flags: Set<String> = []

        var index = 1
        while index < arguments.count {
            let argument = arguments[index]
            guard argument.hasPrefix("--") else {
                throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                    field: "arguments",
                    expected: "flag",
                    actual: argument
                )
            }
            if argument == ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.testnetFlag {
                flags.insert(argument)
                index += 1
                continue
            }
            guard index + 1 < arguments.count, arguments[index + 1].hasPrefix("--") == false else {
                throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                    field: argument,
                    expected: "value",
                    actual: "missing"
                )
            }
            guard values[argument] == nil else {
                throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                    field: argument,
                    expected: "single value",
                    actual: "duplicate"
                )
            }
            values[argument] = arguments[index + 1]
            index += 2
        }

        self.values = values
        self.flags = flags
    }

    func requireFlag(_ flag: String) throws {
        guard flags.contains(flag) else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: flag,
                expected: "present",
                actual: "missing"
            )
        }
    }

    func value(_ flag: String) -> String? {
        values[flag]
    }

    func requiredValue(_ flag: String) throws -> String {
        guard let value = values[flag]?.trimmingCharacters(in: .whitespacesAndNewlines),
              value.isEmpty == false else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: flag,
                expected: "non-empty value",
                actual: "missing"
            )
        }
        return value
    }

    func requiredDouble(_ flag: String) throws -> Double {
        let raw = try requiredValue(flag)
        guard let value = Double(raw), value.isFinite else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: flag,
                expected: "finite decimal",
                actual: raw
            )
        }
        return value
    }

    func optionalDouble(_ flag: String) throws -> Double? {
        guard let raw = value(flag) else { return nil }
        guard let value = Double(raw), value.isFinite else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: flag,
                expected: "finite decimal",
                actual: raw
            )
        }
        return value
    }

    func optionalInt(_ flag: String) throws -> Int? {
        guard let raw = value(flag) else { return nil }
        guard let value = Int(raw), value > 0 else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: flag,
                expected: "positive integer",
                actual: raw
            )
        }
        return value
    }

    func optionalInt64(_ flag: String) throws -> Int64? {
        guard let raw = value(flag) else { return nil }
        guard let value = Int64(raw), value > 0 else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.invalidArgument(
                field: flag,
                expected: "positive integer",
                actual: raw
            )
        }
        return value
    }

    func forbidProductionArguments() throws {
        for argument in arguments {
            let lowered = argument.lowercased()
            if [
                "--production",
                "--prod",
                "--production-endpoint",
                "--broker-endpoint",
                "--api-key",
                "--secret",
                "--secret-key",
                "--production-secret"
            ].contains(lowered) {
                throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.forbiddenProductionArgument(argument)
            }
        }
    }
}
