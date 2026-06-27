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
// GH-1166 static patch boundary:
// failedValidationNonzeroExit=true
// validBundleExitZero=true
// failedBundleReportStillRedacted=true
// localReportingPathDoesNotWeakenFailClosedDefault=true
// productionCutoverAuthorized=false
// GH-1168 static patch boundary:
// GH-1168-VERIFY-V0171-ARTIFACT-NEGATIVE-REGRESSIONS
// TVM-RELEASE-V0171-ARTIFACT-NEGATIVE-REGRESSIONS
// V0171-003-CORRUPT-BUNDLE-FAILS-CLOSED
// V0171-003-MISSING-ARTIFACT-FAILS-CLOSED
// V0171-003-MISSING-MANIFEST-FAILS-CLOSED
// V0171-003-RECONCILIATION-MISSING-FAILS-CLOSED
// V0171-003-REDACTED-OPERATOR-READABLE-EVIDENCE
// V0171-003-NO-PRODUCTION-CUTOVER
// corruptBundleValidationFailsClosed=true
// missingArtifactValidationFailsClosed=true
// missingManifestValidationFailsClosed=true
// reconciliationMissingValidationFailsClosed=true
// negativeFailureDetailsOperatorReadable=true

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
            "failureDetails=\(validationResult.failures.map { "\($0.field):\($0.reason.rawValue):\($0.detail)" }.joined(separator: "|"))",
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

/// ReleaseV0170CLIArtifactVerifyCommandFailedValidation 是 GH-1166 的 fail-closed CLI 错误。
///
/// 该错误只在本地 artifact bundle 校验结果为 `status=failed` 时抛出。它保留 redacted
/// rendered output 供 operator 排查，但通过非零 exit code 阻止 shell / workflow 把 failed
/// artifact validation 当作成功执行。
public struct ReleaseV0170CLIArtifactVerifyCommandFailedValidation:
    Error,
    CustomStringConvertible,
    Equatable,
    Sendable
{
    public let output: ReleaseV0170CLIArtifactVerifyCommandOutput
    public let renderedOutput: String
    public let exitCode: Int32
    public let validationAnchors: [String]

    public var description: String {
        renderedOutput
    }

    public var failClosedHeld: Bool {
        output.outputHeld
            && output.validationResult.status == .failed
            && renderedOutput.contains("status=failed")
            && renderedOutput.contains("redactedOutputOnly=true")
            && renderedOutput.contains("productionOrderSubmitCancelReplaceEnabled=false")
            && exitCode != 0
            && validationAnchors == Self.requiredValidationAnchors
    }

    public init(
        output: ReleaseV0170CLIArtifactVerifyCommandOutput,
        exitCode: Int32 = 65,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        self.output = output
        self.renderedOutput = output.rendered()
        self.exitCode = exitCode
        self.validationAnchors = validationAnchors

        guard failClosedHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0171CLIArtifactVerifyCommand.failedValidationExit",
                expected: "failed validation must surface redacted output and exit nonzero",
                actual: output.validationResult.status.rawValue
            )
        }
    }

    public static let requiredValidationAnchors = [
        "GH-1166-VERIFY-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED",
        "TVM-RELEASE-V0171-CLI-ARTIFACT-VERIFY-FAIL-CLOSED",
        "V0171-001-FAILED-VALIDATION-NONZERO-EXIT",
        "V0171-001-VALID-BUNDLE-EXIT-ZERO",
        "V0171-001-LOCAL-REPORTING-PATH-REDACTED",
        "V0171-001-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1166ReleaseV0171CLIArtifactVerifyCommandFailsClosed",
        "bash checks/verify-v0.17.1-cli-artifact-verify-fail-closed.sh",
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
        let output = try commandOutput(arguments: arguments)
        guard output.validationResult.status == .passed else {
            let error = try ReleaseV0170CLIArtifactVerifyCommandFailedValidation(output: output)
            throw error
        }
        return output.rendered()
    }

    /// 只读 report path 保留 failed bundle 的 redacted diagnostic output。
    ///
    /// 默认 CLI path 仍由 `commandLineOutput` fail closed；该函数只供测试、Dashboard read model
    /// 或明确的本地报告调用使用，不能作为 shell / workflow 成功条件。
    public static func commandLineReportOutput(arguments: [String]) throws -> String {
        try commandOutput(arguments: arguments).rendered()
    }

    private static func commandOutput(arguments: [String]) throws -> ReleaseV0170CLIArtifactVerifyCommandOutput {
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
        )
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
