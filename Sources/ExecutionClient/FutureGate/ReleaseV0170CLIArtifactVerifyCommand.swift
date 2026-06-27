import DomainModel
import Foundation

// GH-1145 static contract boundary:
// cliArtifactVerifyCommand=ReleaseV0170CLIArtifactVerifyCommand
// localArtifactBundleVerify=true
// localOnlyNoNetwork=true
// deterministicValidationReplayOutput=true
// redactedOutputOnly=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false

/// ReleaseV0170CLIArtifactVerifyCommandOutput 是 GH-1145 的 CLI 输出模型。
///
/// 该输出只包装 GH-1140 本地 artifact bundle replay validator 的 pass/fail 结果，面向 operator
/// 在本机复核 artifact bundle。它不读取环境变量、credential value 或 secret，也不连接 testnet /
/// production endpoint，不触发 submit / cancel / replace。
public struct ReleaseV0170CLIArtifactVerifyCommandOutput: Equatable, Sendable {
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let releaseVersion: String
    public let command: String
    public let storageRootPath: String
    public let validationResult: ReleaseV0170OperatorBetaArtifactBundleValidationResult
    public let localArtifactBundleVerify: Bool
    public let localOnlyNoNetwork: Bool
    public let deterministicValidationReplayOutput: Bool
    public let redactedOutputOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let validationAnchors: [String]

    public var outputHeld: Bool {
        issueID.rawValue == "GH-1145"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1140", "GH-1143"]
            && releaseVersion == "v0.17.0"
            && command == ReleaseV0170CLIArtifactVerifyCommand.cliCommand
            && storageRootPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && validationResult.resultHeld
            && localArtifactBundleVerify
            && localOnlyNoNetwork
            && deterministicValidationReplayOutput
            && redactedOutputOnly
            && productionDefaultsClosed
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        storageRootPath: String,
        validationResult: ReleaseV0170OperatorBetaArtifactBundleValidationResult,
        issueID: Identifier = Identifier.constant("GH-1145"),
        blockedByIssueIDs: [Identifier] = [
            Identifier.constant("GH-1140"),
            Identifier.constant("GH-1143")
        ],
        releaseVersion: String = "v0.17.0",
        command: String = ReleaseV0170CLIArtifactVerifyCommand.cliCommand,
        localArtifactBundleVerify: Bool = true,
        localOnlyNoNetwork: Bool = true,
        deterministicValidationReplayOutput: Bool = true,
        redactedOutputOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.releaseVersion = releaseVersion
        self.command = command
        self.storageRootPath = storageRootPath
        self.validationResult = validationResult
        self.localArtifactBundleVerify = localArtifactBundleVerify
        self.localOnlyNoNetwork = localOnlyNoNetwork
        self.deterministicValidationReplayOutput = deterministicValidationReplayOutput
        self.redactedOutputOnly = redactedOutputOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.validationAnchors = validationAnchors

        guard outputHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170CLIArtifactVerifyCommand.output",
                expected: "GH-1145 local-only CLI artifact verification output",
                actual: validationResult.status.rawValue
            )
        }
    }

    public func rendered() -> String {
        [
            "mtpro \(command)",
            "issue=\(issueID.rawValue)",
            "blockedBy=\(blockedByIssueIDs.map(\.rawValue).joined(separator: ","))",
            "releaseVersion=\(releaseVersion)",
            "verificationAnchor=\(Self.requiredValidationAnchors[0])",
            "validationAnchor=\(Self.requiredValidationAnchors[1])",
            "requiredAnchors=\(validationAnchors.joined(separator: ","))",
            "storageRootPath=\(storageRootPath)",
            "runID=\(validationResult.sourceRunID.rawValue)",
            "resultID=\(validationResult.resultID.rawValue)",
            "status=\(validationResult.status.rawValue)",
            "schemaValidated=\(validationResult.schemaValidated)",
            "checksumValidated=\(validationResult.checksumValidated)",
            "actionSequenceValidated=\(validationResult.actionSequenceValidated)",
            "reconciliationValidated=\(validationResult.reconciliationValidated)",
            "replayedKinds=\(validationResult.replayedKinds.map(\.rawValue).joined(separator: ","))",
            "expectedActionSequence=\(validationResult.expectedActionSequence.map(\.rawValue).joined(separator: ","))",
            "manifestPath=\(validationResult.sourceManifestPath ?? "none")",
            "manifestChecksum=\(validationResult.sourceManifestChecksum ?? "none")",
            "recordChecksumCount=\(validationResult.sourceRecordChecksums.count)",
            "failureReasons=\(validationResult.failures.map { $0.reason.rawValue }.joined(separator: ","))",
            "localArtifactBundleVerify=\(localArtifactBundleVerify)",
            "localOnlyNoNetwork=\(localOnlyNoNetwork)",
            "deterministicValidationReplayOutput=\(deterministicValidationReplayOutput)",
            "redactedOutputOnly=\(redactedOutputOnly)",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionSecretReadEnabled=\(productionSecretReadEnabled)",
            "productionEndpointConnectionEnabled=\(productionEndpointConnectionEnabled)",
            "productionBrokerConnectionEnabled=\(productionBrokerConnectionEnabled)",
            "productionOrderSubmitCancelReplaceEnabled=\(productionOrderSubmitCancelReplaceEnabled)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=\(outputHeld)"
        ].joined(separator: "\n")
    }

    public static let requiredValidationAnchors = [
        "GH-1145-VERIFY-V0170-CLI-ARTIFACT-VERIFY-COMMAND",
        "TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND",
        "V0170-007-LOCAL-ARTIFACT-BUNDLE-VERIFY",
        "V0170-007-LOCAL-ONLY-NO-NETWORK",
        "V0170-007-DETERMINISTIC-VALIDATION-REPLAY-OUTPUT",
        "V0170-007-REDACTED-OUTPUT",
        "V0170-007-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1145ReleaseV0170CLIArtifactVerifyCommand",
        "bash checks/verify-v0.17.0-cli-artifact-verify-command.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV0170CLIArtifactVerifyCommand 固定 GH-1145 的本地 CLI artifact verification 入口。
///
/// 命令只接受本地 artifact store root 和 runID，委托 GH-1140 validator 读取本地 append-only
/// bundle 并渲染 deterministic output。该入口没有 credential provider、network transport 或 broker
/// adapter 参数，因此不能隐式读取 secret 或连接 endpoint。
public enum ReleaseV0170CLIArtifactVerifyCommand {
    public static let cliCommand = "verify-operator-beta-artifact-bundle"

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.count == 3 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170CLIArtifactVerifyCommand.arguments",
                expected: "\(cliCommand) <storageRootPath> <runID>",
                actual: arguments.joined(separator: " ")
            )
        }
        return try commandOutput(
            storageRootPath: arguments[1],
            runID: arguments[2]
        ).rendered()
    }

    public static func commandOutput(
        storageRootPath: String,
        runID: String
    ) throws -> ReleaseV0170CLIArtifactVerifyCommandOutput {
        let trimmedStorageRoot = storageRootPath.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRunID = runID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedStorageRoot.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170CLIArtifactVerifyCommand.storageRootPath",
                expected: "non-empty local storage root path",
                actual: storageRootPath
            )
        }
        guard trimmedRunID.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0170CLIArtifactVerifyCommand.runID",
                expected: "non-empty runID",
                actual: runID
            )
        }

        let result = try ReleaseV0170OperatorBetaArtifactBundleReplayValidator().validate(
            runID: Identifier.constant(
                trimmedRunID,
                field: "releaseV0170CLIArtifactVerifyCommand.runID"
            ),
            storageRootURL: URL(fileURLWithPath: trimmedStorageRoot, isDirectory: true)
        )
        return try ReleaseV0170CLIArtifactVerifyCommandOutput(
            storageRootPath: trimmedStorageRoot,
            validationResult: result
        )
    }
}
