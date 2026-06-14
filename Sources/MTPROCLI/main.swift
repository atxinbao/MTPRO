import Database
import DataClient
import Foundation
import Portfolio

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let output = try await MTPROStrictCLI.commandLineOutput(arguments: arguments)
    print(output)
} catch {
    print("mtpro error: \(error)")
    Foundation.exit(64)
}

/// MTPROCLIParserError 是 GH-727 strict CLI parser 的本地错误类型。
///
/// 它让未知命令在进入旧 release surface 前就失败，避免旧 v0.2 / v0.3 / v0.4
/// fallback 把不属于当前命令集合的输入误解释为历史验收入口。
private enum MTPROCLIParserError: Error, CustomStringConvertible, Equatable {
    case invalidArguments(field: String, expected: String, actual: String)

    var description: String {
        switch self {
        case let .invalidArguments(field, expected, actual):
            "\(field) expected \(expected), actual \(actual)"
        }
    }
}

/// MTPROStrictCLI 固定 GH-727 的严格命令路由。
///
/// 新 v0.7.0 shape 只暴露 `help`、`run`、`status`、`verify` 四类入口；历史
/// `rehearsal-status`、`unified-run-status`、`run-observer`、`run-detail-observer`、
/// `testnet-readonly-probe`、`verify-fast`、`verify-release` 仍可被显式调用。
/// 任何其他命令必须在这里失败，不得 fallback 到旧 release surface。
private enum MTPROStrictCLI {
    static let validationAnchor = "TVM-RELEASE-V070-CLI-RUNTIME-SESSION-SURFACE"
    static let strictParserAnchor = "TVM-RELEASE-V050-STRICT-CLI-COMMAND-PARSER"
    static let supportedCommands = [
        "help",
        "run",
        "status",
        "verify",
        ReleaseV030CLIRehearsalSurface.cliCommand,
        ReleaseV040UnifiedRunSurface.cliCommand,
        ReleaseV050RunObserverSurface.cliCommand,
        ReleaseV060RunDetailObserverSurface.cliCommand,
        ReleaseV060TestnetReadOnlyProbe.cliCommand,
        "verify-fast",
        "verify-release"
    ]

    static func commandLineOutput(arguments: [String]) async throws -> String {
        guard let command = arguments.first else {
            return helpOutput()
        }

        switch command {
        case "help", "--help", "-h":
            try requireExactCount(arguments, expected: 1, command: command)
            return helpOutput()
        case "run":
            return try runOutput(arguments: arguments)
        case "status":
            return try statusOutput(arguments: arguments)
        case "verify":
            try requireExactCount(arguments, expected: 1, command: command)
            return verifyOutput()
        case ReleaseV030CLIRehearsalSurface.cliCommand:
            return try ReleaseV030CLIRehearsalSurface.commandLineOutput(arguments: arguments)
        case ReleaseV040UnifiedRunSurface.cliCommand:
            return try ReleaseV040UnifiedRunSurface.commandLineOutput(arguments: arguments)
        case ReleaseV050RunObserverSurface.cliCommand:
            return try await ReleaseV050RunObserverSurface.commandLineOutput(arguments: arguments)
        case ReleaseV060RunDetailObserverSurface.cliCommand:
            return try ReleaseV060RunDetailObserverSurface.commandLineOutput(arguments: arguments)
        case ReleaseV060TestnetReadOnlyProbe.cliCommand:
            return try await ReleaseV060TestnetReadOnlyProbe.commandLineOutput(arguments: arguments)
        case "verify-fast", "verify-release":
            return try ReleaseV020CLIProductSurface.commandLineOutput(arguments: arguments)
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.strict.arguments",
                expected: supportedCommands.joined(separator: ","),
                actual: arguments.joined(separator: " ")
            )
        }
    }

    static func unknownCommandRejected(_ arguments: [String]) async -> Bool {
        (try? await commandLineOutput(arguments: arguments)) == nil
    }

    private static func helpOutput() -> String {
        let commandList = supportedCommands.joined(separator: ",")
        return [
            "mtpro help",
            "issue=GH-781",
            "validationAnchor=\(validationAnchor)",
            "strictParserAnchor=\(strictParserAnchor)",
            "commands=\(commandList)",
            "defaultMode=local-dry-run",
            "runtimeSessionContract=v0.7.0",
            "runtimeModes=local-dry-run,testnet-read-only-probe,production-blocked",
            "testnetRequiresOperatorConfirmation=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func runOutput(arguments: [String]) throws -> String {
        let mode = try runMode(arguments: arguments)
        return [
            "mtpro run no-order-runtime-session",
            "issue=GH-781",
            "validationAnchor=\(validationAnchor)",
            "mode=\(mode)",
            "runtimeSessionContract=v0.7.0",
            "noOrderRuntimeSession=true",
            "localNoOrderSessionFlow=gh-783-operational-run-session",
            "sessionStarted=false",
            "runRegistryState=awaiting-gh-785-run-registry",
            "testnetConnected=false",
            "orderSubmissionAllowed=false",
            "submitCancelReplaceAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func statusOutput(arguments: [String]) throws -> String {
        let runID: String
        switch arguments.count {
        case 1:
            runID = "latest"
        case 2:
            runID = arguments[1]
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.status.arguments",
                expected: "status [runID]",
                actual: arguments.joined(separator: " ")
            )
        }

        return [
            "mtpro status no-order-runtime-session",
            "issue=GH-781",
            "validationAnchor=\(validationAnchor)",
            "runID=\(runID)",
            "runtimeSessionContract=v0.7.0",
            "activeTopLevelStatusSurface=v0.7.0",
            "noOrderRuntimeSession=true",
            "legacyV040StatusSurface=false",
            "legacyV050ObserverSurface=false",
            "sessionRegistrySource=gh-785-run-registry",
            "sessionState=not-started",
            "readOnlyProbeState=not-connected",
            "orderSubmissionAllowed=false",
            "submitCancelReplaceAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func verifyOutput() -> String {
        [
            "mtpro verify v0.7.0",
            "issue=GH-781",
            "validationAnchor=\(validationAnchor)",
            "checks=verify-v0.7.0-contract,verify-v0.7.0-testnet-endpoint-policy,verify-v0.7.0-cli,automation-readiness,checks-run",
            "unknownCommandFailure=mtpro.strict.arguments",
            "legacyFallbackDisabled=true",
            "legacyV040ActiveTopLevelSurface=false",
            "legacyV050ActiveTopLevelSurface=false",
            "noOrderRuntimeSession=true",
            "orderSubmissionAllowed=false",
            "submitCancelReplaceAllowed=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func runMode(arguments: [String]) throws -> String {
        switch arguments {
        case ["run"]:
            return "local-dry-run"
        case ["run", "--mode", "dry-run"], ["run", "--mode", "local-dry-run"]:
            return "local-dry-run"
        case ["run", "--mode", "testnet-read-only-probe"]:
            return "testnet-read-only-probe"
        case ["run", "--mode", "production"], ["run", "--production"]:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.run.production",
                expected: "production-blocked",
                actual: arguments.joined(separator: " ")
            )
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.run.arguments",
                expected: "run [--mode dry-run|testnet-read-only-probe]",
                actual: arguments.joined(separator: " ")
            )
        }
    }

    private static func requireExactCount(_ arguments: [String], expected: Int, command: String) throws {
        guard arguments.count == expected else {
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.\(command).arguments",
                expected: command,
                actual: arguments.joined(separator: " ")
            )
        }
    }
}
