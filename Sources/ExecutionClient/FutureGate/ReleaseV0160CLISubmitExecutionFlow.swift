import Crypto
import DomainModel
import Foundation

// GH-1103 static contract boundary:
// cliCommand=spot-testnet-submit
// delegatedRuntime=ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow
// action=submit
// credentialProvider=testnet-env
// explicitOperatorConfirmationRequired=true
// missingGateCredentialConfirmationFailsClosed=true
// redactedOutputPrinted=true
// artifactPathReturned=true
// checksumReturned=true
// testnetRuntimeDelegated=true
// testnetSubmitRuntimeAuthorizedByIssue=true
// productionTradingEnabledByDefault=false
// productionSecretAutoRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionOrderSubmitted=false
// productionCutoverAuthorized=false

/// ReleaseV0160CLISubmitExecutionFlowError 描述 GH-1103 稳定 submit CLI 的 fail-closed 错误。
///
/// 这些错误只覆盖 Binance Spot Testnet operator beta 的外层 CLI gate。真实 submit 仍委托
/// v0.15.1 guarded runtime；生产 secret、生产 endpoint、broker endpoint 和 production order 始终被拒绝。
public enum ReleaseV0160CLISubmitExecutionFlowError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidArgument(field: String, expected: String, actual: String)
    case forbiddenProductionArgument(String)
    case forbiddenAction(String)
    case boundaryDrift(String)

    public var description: String {
        switch self {
        case let .invalidArgument(field, expected, actual):
            "Release v0.16.0 CLI submit flow invalid argument \(field): expected \(expected), actual \(actual)"
        case let .forbiddenProductionArgument(argument):
            "Release v0.16.0 CLI submit flow forbids production argument: \(argument)"
        case let .forbiddenAction(action):
            "Release v0.16.0 CLI submit flow only supports submit, actual \(action)"
        case let .boundaryDrift(field):
            "Release v0.16.0 CLI submit flow boundary drift: \(field)"
        }
    }
}

/// ReleaseV0160CLISubmitExecutionCommand 是 GH-1103 解析后的稳定 submit-only CLI command。
///
/// Command 只保存 testnet-only provider、run id、symbol、side、quantity 和 correlation identity。
/// 它不会保存 API key、secret、raw broker payload 或 raw order identity。
public struct ReleaseV0160CLISubmitExecutionCommand: Equatable, Sendable {
    public let runID: Identifier
    public let operatorConfirmationPhrase: String
    public let credentialProviderKind: ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind
    public let credentialReferenceID: Identifier
    public let apiKeyEnvironmentName: String
    public let secretEnvironmentName: String
    public let symbol: String
    public let side: String
    public let quantity: String
    public let strategy: String
    public let sourceSequence: Int
    public let correlationID: Identifier
    public let strategySignalID: Identifier
    public let sourceMessageID: Identifier
    public let strategyRunID: Identifier
    public let intentID: Identifier?
    public let timestampMilliseconds: Int64
    public let observedAtMilliseconds: Int64
    public let redactedOutputRequested: Bool

    public var boundaryHeld: Bool {
        operatorConfirmationPhrase == ReleaseV0160OperatorRunMetadata.requiredOperatorConfirmationPhrase
            && credentialProviderKind == .testnetEnvironment
            && apiKeyEnvironmentName.uppercased().contains("TESTNET")
            && secretEnvironmentName.uppercased().contains("TESTNET")
            && redactedOutputRequested
            && runID.rawValue.isEmpty == false
    }

    public var delegatedV0151Arguments: [String] {
        var arguments = [
            ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.cliCommand,
            ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.testnetFlag,
            ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.actionFlag,
            ReleaseV0150BinanceSpotTestnetCLIOperatorAction.submit.rawValue,
            ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.operatorConfirmFlag,
            ReleaseV0150BinanceSpotTestnetCLIOperatorInput.requiredOperatorConfirmationPhrase,
            "--credential-provider",
            credentialProviderKind.rawValue,
            "--credential-reference-id",
            credentialReferenceID.rawValue,
            "--run-id",
            runID.rawValue,
            "--symbol",
            symbol,
            "--side",
            side,
            "--quantity",
            quantity,
            "--strategy",
            strategy,
            "--source-sequence",
            String(sourceSequence),
            "--correlation-id",
            correlationID.rawValue,
            "--strategy-signal-id",
            strategySignalID.rawValue,
            "--source-message-id",
            sourceMessageID.rawValue,
            "--strategy-run-id",
            strategyRunID.rawValue,
            "--timestamp-ms",
            String(timestampMilliseconds),
            "--observed-at-ms",
            String(observedAtMilliseconds),
            "--testnet-api-key-env",
            apiKeyEnvironmentName,
            "--testnet-secret-env",
            secretEnvironmentName,
            ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.outputFlag,
            ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.redactedOutput
        ]
        if let intentID {
            arguments += ["--intent-id", intentID.rawValue]
        }
        return arguments
    }
}

/// ReleaseV0160CLISubmitExecutionResult 是 GH-1103 稳定 CLI submit 输出的脱敏 evidence。
///
/// 结果只返回 command、run id、v0.16 artifact path、checksum、operator run state 和 v0.15.1
/// delegated runtime evidence handles。它不包含 credential value、raw order id 或 raw response body。
public struct ReleaseV0160CLISubmitExecutionResult: Codable, Equatable, Sendable {
    public let resultID: Identifier
    public let command: String
    public let delegatedRuntime: String
    public let action: String
    public let runID: Identifier
    public let operatorRunState: ReleaseV0160OperatorRunState
    public let operatorRunActionSequence: [ReleaseV0160OperatorRunAction]
    public let artifactPath: String
    public let artifactChecksum: String
    public let delegatedArtifactPath: String
    public let delegatedArtifactChecksum: String
    public let delegatedRuntimeEvidenceID: Identifier
    public let delegatedNetworkEventLogID: Identifier
    public let credentialProvider: String
    public let explicitOperatorConfirmationRequired: Bool
    public let operatorConfirmationAccepted: Bool
    public let missingGateCredentialConfirmationFailsClosed: Bool
    public let redactedOutputPrinted: Bool
    public let artifactPathReturned: Bool
    public let checksumReturned: Bool
    public let testnetRuntimeDelegated: Bool
    public let testnetSubmitRuntimeAuthorizedByIssue: Bool
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
        resultID: Identifier,
        runID: Identifier,
        operatorRunModel: ReleaseV0160OperatorRunModel,
        delegatedRuntimeResult: ReleaseV0151BinanceSpotTestnetCLIRuntimeResult,
        artifactPath: String,
        artifactChecksum: String,
        command: String = ReleaseV0160CLISubmitExecutionFlow.cliCommand,
        delegatedRuntime: String = "ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow",
        action: String = ReleaseV0150BinanceSpotTestnetCLIOperatorAction.submit.rawValue,
        credentialProvider: String = ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind.testnetEnvironment.rawValue,
        explicitOperatorConfirmationRequired: Bool = true,
        operatorConfirmationAccepted: Bool = true,
        missingGateCredentialConfirmationFailsClosed: Bool = true,
        redactedOutputPrinted: Bool = true,
        artifactPathReturned: Bool = true,
        checksumReturned: Bool = true,
        testnetRuntimeDelegated: Bool = true,
        testnetSubmitRuntimeAuthorizedByIssue: Bool = true,
        rawSecretPrinted: Bool = false,
        rawCredentialPrinted: Bool = false,
        rawOrderIdentityPrinted: Bool = false,
        rawBrokerPayloadPrinted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        guard operatorRunModel.state == .submitObserved,
              operatorRunModel.actionSequence == [.create, .requestSubmit, .recordSubmitObserved],
              delegatedRuntimeResult.action == .submit,
              delegatedRuntimeResult.boundaryHeld else {
            throw ReleaseV0160CLISubmitExecutionFlowError.boundaryDrift("submitResult.delegatedRuntime")
        }
        guard artifactPath == operatorRunModel.metadata.artifactLinks
            .first(where: { $0.role == .redactedExecutionEvidenceJSON })?.path else {
            throw ReleaseV0160CLISubmitExecutionFlowError.boundaryDrift("artifactPath")
        }
        guard artifactChecksum == Self.artifactChecksum(
            runID: runID,
            artifactPath: artifactPath,
            operatorRunModel: operatorRunModel,
            delegatedRuntimeResult: delegatedRuntimeResult
        ) else {
            throw ReleaseV0160CLISubmitExecutionFlowError.boundaryDrift("artifactChecksum")
        }
        guard resultID == Self.deterministicID(
            runID: runID,
            artifactChecksum: artifactChecksum,
            delegatedRuntimeEvidenceID: delegatedRuntimeResult.runtimeEvidenceID
        ) else {
            throw ReleaseV0160CLISubmitExecutionFlowError.boundaryDrift("resultID")
        }
        guard command == ReleaseV0160CLISubmitExecutionFlow.cliCommand,
              delegatedRuntime == "ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow",
              action == ReleaseV0150BinanceSpotTestnetCLIOperatorAction.submit.rawValue,
              credentialProvider == ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind.testnetEnvironment.rawValue,
              explicitOperatorConfirmationRequired,
              operatorConfirmationAccepted,
              missingGateCredentialConfirmationFailsClosed,
              redactedOutputPrinted,
              artifactPathReturned,
              checksumReturned,
              testnetRuntimeDelegated,
              testnetSubmitRuntimeAuthorizedByIssue,
              validationAnchors == Self.requiredValidationAnchors else {
            throw ReleaseV0160CLISubmitExecutionFlowError.boundaryDrift("resultFlags")
        }
        try Self.forbid(rawSecretPrinted, "rawSecretPrinted")
        try Self.forbid(rawCredentialPrinted, "rawCredentialPrinted")
        try Self.forbid(rawOrderIdentityPrinted, "rawOrderIdentityPrinted")
        try Self.forbid(rawBrokerPayloadPrinted, "rawBrokerPayloadPrinted")
        try Self.forbid(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.forbid(productionSecretAutoRead, "productionSecretAutoRead")
        try Self.forbid(productionEndpointConnected, "productionEndpointConnected")
        try Self.forbid(brokerEndpointConnected, "brokerEndpointConnected")
        try Self.forbid(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.forbid(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.resultID = resultID
        self.command = command
        self.delegatedRuntime = delegatedRuntime
        self.action = action
        self.runID = runID
        self.operatorRunState = operatorRunModel.state
        self.operatorRunActionSequence = operatorRunModel.actionSequence
        self.artifactPath = artifactPath
        self.artifactChecksum = artifactChecksum
        self.delegatedArtifactPath = delegatedRuntimeResult.artifactPath
        self.delegatedArtifactChecksum = delegatedRuntimeResult.artifactChecksum
        self.delegatedRuntimeEvidenceID = delegatedRuntimeResult.runtimeEvidenceID
        self.delegatedNetworkEventLogID = delegatedRuntimeResult.networkEventLogID
        self.credentialProvider = credentialProvider
        self.explicitOperatorConfirmationRequired = explicitOperatorConfirmationRequired
        self.operatorConfirmationAccepted = operatorConfirmationAccepted
        self.missingGateCredentialConfirmationFailsClosed = missingGateCredentialConfirmationFailsClosed
        self.redactedOutputPrinted = redactedOutputPrinted
        self.artifactPathReturned = artifactPathReturned
        self.checksumReturned = checksumReturned
        self.testnetRuntimeDelegated = testnetRuntimeDelegated
        self.testnetSubmitRuntimeAuthorizedByIssue = testnetSubmitRuntimeAuthorizedByIssue
        self.rawSecretPrinted = rawSecretPrinted
        self.rawCredentialPrinted = rawCredentialPrinted
        self.rawOrderIdentityPrinted = rawOrderIdentityPrinted
        self.rawBrokerPayloadPrinted = rawBrokerPayloadPrinted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoRead = productionSecretAutoRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors
    }

    public var boundaryHeld: Bool {
        command == ReleaseV0160CLISubmitExecutionFlow.cliCommand
            && delegatedRuntime == "ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow"
            && action == ReleaseV0150BinanceSpotTestnetCLIOperatorAction.submit.rawValue
            && operatorRunState == .submitObserved
            && operatorRunActionSequence == [.create, .requestSubmit, .recordSubmitObserved]
            && artifactPath.hasPrefix(".local/mtpro/v0.16.0/operator-runs/\(runID.rawValue)/")
            && artifactPath.hasSuffix(ReleaseV0160OperatorRunArtifactRole.redactedExecutionEvidenceJSON.rawValue)
            && Self.isLowercaseSHA256(artifactChecksum)
            && Self.isLowercaseSHA256(delegatedArtifactChecksum)
            && credentialProvider == ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind.testnetEnvironment.rawValue
            && explicitOperatorConfirmationRequired
            && operatorConfirmationAccepted
            && missingGateCredentialConfirmationFailsClosed
            && redactedOutputPrinted
            && artifactPathReturned
            && checksumReturned
            && testnetRuntimeDelegated
            && testnetSubmitRuntimeAuthorizedByIssue
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

    public var operatorRunActionSequenceText: String {
        operatorRunActionSequence.map(\.rawValue).joined(separator: ">")
    }

    public var redactedOutputLines: [String] {
        [
            "mtpro \(ReleaseV0160CLISubmitExecutionFlow.cliCommand)",
            "issue=GH-1103",
            "verificationAnchor=GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW",
            "validationAnchor=TVM-RELEASE-V0160-CLI-SUBMIT-FLOW",
            "requiredAnchors=\(validationAnchors.joined(separator: ","))",
            "command=\(command)",
            "delegatedRuntime=\(delegatedRuntime)",
            "action=\(action)",
            "runID=\(runID.rawValue)",
            "operatorRunState=\(operatorRunState.rawValue)",
            "operatorRunActionSequence=\(operatorRunActionSequenceText)",
            "artifactPath=\(artifactPath)",
            "artifactChecksum=\(artifactChecksum)",
            "delegatedArtifactPath=\(delegatedArtifactPath)",
            "delegatedArtifactChecksum=\(delegatedArtifactChecksum)",
            "delegatedRuntimeEvidenceID=\(delegatedRuntimeEvidenceID.rawValue)",
            "delegatedNetworkEventLogID=\(delegatedNetworkEventLogID.rawValue)",
            "credentialProvider=\(credentialProvider)",
            "credentialReference=<redacted>",
            "explicitOperatorConfirmationRequired=\(explicitOperatorConfirmationRequired)",
            "operatorConfirmationAccepted=\(operatorConfirmationAccepted)",
            "missingGateCredentialConfirmationFailsClosed=\(missingGateCredentialConfirmationFailsClosed)",
            "redactedOutputPrinted=\(redactedOutputPrinted)",
            "artifactPathReturned=\(artifactPathReturned)",
            "checksumReturned=\(checksumReturned)",
            "testnetRuntimeDelegated=\(testnetRuntimeDelegated)",
            "testnetSubmitRuntimeAuthorizedByIssue=\(testnetSubmitRuntimeAuthorizedByIssue)",
            "rawSecretPrinted=\(rawSecretPrinted)",
            "rawCredentialPrinted=\(rawCredentialPrinted)",
            "rawOrderIdentityPrinted=\(rawOrderIdentityPrinted)",
            "rawBrokerPayloadPrinted=\(rawBrokerPayloadPrinted)",
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
        "GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW",
        "TVM-RELEASE-V0160-CLI-SUBMIT-FLOW",
        "V0160-003-STABLE-CLI-SUBMIT",
        "V0160-003-V0151-RUNTIME-DELEGATION",
        "V0160-003-EXPLICIT-OPERATOR-CONFIRMATION",
        "V0160-003-TESTNET-CREDENTIAL-PROFILE",
        "V0160-003-REDACTED-OUTPUT-ARTIFACT-CHECKSUM",
        "V0160-003-MISSING-GATE-CREDENTIAL-CONFIRMATION-FAILS-CLOSED",
        "V0160-003-NO-PRODUCTION-CUTOVER"
    ]

    public static func artifactChecksum(
        runID: Identifier,
        artifactPath: String,
        operatorRunModel: ReleaseV0160OperatorRunModel,
        delegatedRuntimeResult: ReleaseV0151BinanceSpotTestnetCLIRuntimeResult
    ) -> String {
        stableSHA256([
            "GH-1103",
            "v0.16.0",
            "cli-submit-flow",
            runID.rawValue,
            artifactPath,
            operatorRunModel.events.last?.eventChecksum ?? "",
            delegatedRuntimeResult.runtimeEvidenceID.rawValue,
            delegatedRuntimeResult.artifactChecksum,
            delegatedRuntimeResult.networkEventLogID.rawValue
        ])
    }

    public static func deterministicID(
        runID: Identifier,
        artifactChecksum: String,
        delegatedRuntimeEvidenceID: Identifier
    ) -> Identifier {
        .constant(
            [
                "gh-1103-v0160-cli-submit-flow",
                runID.rawValue,
                artifactChecksum,
                delegatedRuntimeEvidenceID.rawValue
            ].joined(separator: ":"),
            field: "releaseV0160CLISubmitExecutionFlow.resultID"
        )
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160CLISubmitFlow.\(field)")
        }
    }

    private static func isLowercaseSHA256(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { "0123456789abcdef".contains($0) }
    }
}

/// ReleaseV0160CLISubmitExecutionFlow 暴露 v0.16.0 稳定 submit-only CLI。
///
/// 外层命令使用 `spot-testnet-submit` 和 v0.16.0 operator confirmation phrase；内层委托
/// `ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow` 执行已存在的 Spot Testnet submit runtime。
public enum ReleaseV0160CLISubmitExecutionFlow {
    public static let cliCommand = ReleaseV0160OperatorBetaMode.spotTestnetSubmit.rawValue

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
    ) async throws -> ReleaseV0160CLISubmitExecutionResult {
        let command = try parse(arguments: arguments)
        let delegated = try await ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.result(
            arguments: command.delegatedV0151Arguments,
            environment: environment,
            submitTransport: submitTransport,
            cancelTransport: cancelTransport
        )
        let operatorRunModel = try ReleaseV0160OperatorRunModel
            .created(
                runID: command.runID,
                createdAt: date(milliseconds: command.timestampMilliseconds)
            )
            .applying(
                .requestSubmit,
                artifactRoles: [.actionEventsJSONL, .redactedExecutionEvidenceJSON],
                at: date(milliseconds: command.timestampMilliseconds + 1)
            )
            .applying(
                .recordSubmitObserved,
                artifactRoles: [.redactedExecutionEvidenceJSON, .statusSnapshotJSON],
                at: date(milliseconds: command.observedAtMilliseconds)
            )
        guard let redactedExecutionArtifact = operatorRunModel.metadata.artifactLinks
            .first(where: { $0.role == .redactedExecutionEvidenceJSON }) else {
            throw ReleaseV0160CLISubmitExecutionFlowError.boundaryDrift("redactedExecutionEvidenceJSON")
        }
        let checksum = ReleaseV0160CLISubmitExecutionResult.artifactChecksum(
            runID: command.runID,
            artifactPath: redactedExecutionArtifact.path,
            operatorRunModel: operatorRunModel,
            delegatedRuntimeResult: delegated
        )
        return try ReleaseV0160CLISubmitExecutionResult(
            resultID: ReleaseV0160CLISubmitExecutionResult.deterministicID(
                runID: command.runID,
                artifactChecksum: checksum,
                delegatedRuntimeEvidenceID: delegated.runtimeEvidenceID
            ),
            runID: command.runID,
            operatorRunModel: operatorRunModel,
            delegatedRuntimeResult: delegated,
            artifactPath: redactedExecutionArtifact.path,
            artifactChecksum: checksum
        )
    }

    public static func parse(arguments: [String]) throws -> ReleaseV0160CLISubmitExecutionCommand {
        guard arguments.first == cliCommand else {
            throw ReleaseV0160CLISubmitExecutionFlowError.invalidArgument(
                field: "command",
                expected: cliCommand,
                actual: arguments.first ?? "missing"
            )
        }
        let parser = try ReleaseV0160SubmitArgumentParser(arguments: arguments)
        try parser.requireFlag(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.testnetFlag)
        try parser.forbidProductionArguments()
        if let action = parser.value(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.actionFlag),
           action != ReleaseV0150BinanceSpotTestnetCLIOperatorAction.submit.rawValue {
            throw ReleaseV0160CLISubmitExecutionFlowError.forbiddenAction(action)
        }

        let confirmation = try parser.requiredValue(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.operatorConfirmFlag)
        guard confirmation == ReleaseV0160OperatorRunMetadata.requiredOperatorConfirmationPhrase else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160CLISubmitFlow.operatorConfirmation")
        }
        let providerRaw = try parser.requiredValue("--credential-provider")
        guard let provider = ReleaseV0151BinanceSpotTestnetCLICredentialProviderKind(rawValue: providerRaw),
              provider == .testnetEnvironment else {
            throw ReleaseV0151BinanceSpotTestnetCLIRuntimeError.forbiddenProvider(providerRaw)
        }
        let output = parser.value(ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.outputFlag)
            ?? ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.redactedOutput
        guard output == ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.redactedOutput else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV0160CLISubmitFlow.output.\(output)")
        }

        let apiKeyEnvironmentName = parser.value("--testnet-api-key-env")
            ?? ReleaseV0151BinanceSpotTestnetCLICredentialProvider.defaultAPIKeyEnvironmentName
        let secretEnvironmentName = parser.value("--testnet-secret-env")
            ?? ReleaseV0151BinanceSpotTestnetCLICredentialProvider.defaultSecretEnvironmentName
        try ReleaseV0151BinanceSpotTestnetCLICredentialProvider
            .validateTestnetEnvironmentName(apiKeyEnvironmentName, field: "apiKeyEnvironmentName")
        try ReleaseV0151BinanceSpotTestnetCLICredentialProvider
            .validateTestnetEnvironmentName(secretEnvironmentName, field: "secretEnvironmentName")

        let runID = Identifier.constant(parser.value("--run-id") ?? "gh-1103-v0160-spot-testnet-submit-run")
        let timestampMilliseconds = try parser.optionalInt64("--timestamp-ms") ?? 1_704_067_200_000
        let observedAtMilliseconds = try parser.optionalInt64("--observed-at-ms") ?? timestampMilliseconds
        guard timestampMilliseconds > 0, observedAtMilliseconds > 0 else {
            throw ReleaseV0160CLISubmitExecutionFlowError.invalidArgument(
                field: "timestamp",
                expected: "positive unix milliseconds",
                actual: "\(timestampMilliseconds):\(observedAtMilliseconds)"
            )
        }

        let command = ReleaseV0160CLISubmitExecutionCommand(
            runID: runID,
            operatorConfirmationPhrase: confirmation,
            credentialProviderKind: provider,
            credentialReferenceID: Identifier.constant(
                parser.value("--credential-reference-id") ?? "gh-1103-binance-spot-testnet-credential"
            ),
            apiKeyEnvironmentName: apiKeyEnvironmentName,
            secretEnvironmentName: secretEnvironmentName,
            symbol: try parser.requiredValue("--symbol"),
            side: try parser.requiredValue("--side"),
            quantity: try parser.requiredValue("--quantity"),
            strategy: parser.value("--strategy") ?? OrderIntentStrategyKind.ema.rawValue,
            sourceSequence: try parser.optionalInt("--source-sequence") ?? 1103,
            correlationID: Identifier.constant(parser.value("--correlation-id") ?? "gh-1103-submit-correlation"),
            strategySignalID: Identifier.constant(parser.value("--strategy-signal-id") ?? "gh-1103-submit-signal"),
            sourceMessageID: Identifier.constant(parser.value("--source-message-id") ?? "gh-1103-submit-message"),
            strategyRunID: Identifier.constant(parser.value("--strategy-run-id") ?? runID.rawValue),
            intentID: optionalIdentifier(parser.value("--intent-id")),
            timestampMilliseconds: timestampMilliseconds,
            observedAtMilliseconds: observedAtMilliseconds,
            redactedOutputRequested: true
        )
        guard command.boundaryHeld else {
            throw ReleaseV0160CLISubmitExecutionFlowError.boundaryDrift("command")
        }
        return command
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

private struct ReleaseV0160SubmitArgumentParser {
    private let values: [String: String]
    private let flags: Set<String>

    init(arguments: [String]) throws {
        var values: [String: String] = [:]
        var flags: Set<String> = []
        var index = 1

        while index < arguments.count {
            let argument = arguments[index]
            guard argument.hasPrefix("--") else {
                throw ReleaseV0160CLISubmitExecutionFlowError.invalidArgument(
                    field: "arguments",
                    expected: "flag",
                    actual: argument
                )
            }
            if argument == ReleaseV0150BinanceSpotTestnetCLIOperatorFlow.testnetFlag
                || argument == "--production" {
                flags.insert(argument)
                index += 1
                continue
            }
            guard index + 1 < arguments.count else {
                throw ReleaseV0160CLISubmitExecutionFlowError.invalidArgument(
                    field: argument,
                    expected: "value",
                    actual: "missing"
                )
            }
            values[argument] = arguments[index + 1]
            index += 2
        }
        self.values = values
        self.flags = flags
    }

    func value(_ name: String) -> String? {
        values[name]
    }

    func requiredValue(_ name: String) throws -> String {
        guard let value = values[name]?.trimmingCharacters(in: .whitespacesAndNewlines),
              value.isEmpty == false else {
            throw ReleaseV0160CLISubmitExecutionFlowError.invalidArgument(
                field: name,
                expected: "non-empty value",
                actual: "missing"
            )
        }
        return value
    }

    func optionalInt(_ name: String) throws -> Int? {
        guard let value = values[name] else { return nil }
        guard let parsed = Int(value) else {
            throw ReleaseV0160CLISubmitExecutionFlowError.invalidArgument(
                field: name,
                expected: "integer",
                actual: value
            )
        }
        return parsed
    }

    func optionalInt64(_ name: String) throws -> Int64? {
        guard let value = values[name] else { return nil }
        guard let parsed = Int64(value) else {
            throw ReleaseV0160CLISubmitExecutionFlowError.invalidArgument(
                field: name,
                expected: "integer",
                actual: value
            )
        }
        return parsed
    }

    func requireFlag(_ name: String) throws {
        guard flags.contains(name) else {
            throw ReleaseV0160CLISubmitExecutionFlowError.invalidArgument(
                field: name,
                expected: "present",
                actual: "missing"
            )
        }
    }

    func forbidProductionArguments() throws {
        for flag in flags where flag.localizedCaseInsensitiveContains("production")
            || flag.localizedCaseInsensitiveContains("prod") {
            throw ReleaseV0160CLISubmitExecutionFlowError.forbiddenProductionArgument(flag)
        }
        for (key, value) in values {
            let combined = "\(key)=\(value)"
            if combined.localizedCaseInsensitiveContains("production")
                || combined.localizedCaseInsensitiveContains("prod")
                || key == "--broker-endpoint"
                || key == "--api-key"
                || key == "--secret-key" {
                throw ReleaseV0160CLISubmitExecutionFlowError.forbiddenProductionArgument(combined)
            }
        }
    }
}

private func stableSHA256(_ parts: [String]) -> String {
    let payload = parts.joined(separator: "\n")
    let digest = SHA256.hash(data: Data(payload.utf8))
    return digest.map { String(format: "%02x", $0) }.joined()
}
