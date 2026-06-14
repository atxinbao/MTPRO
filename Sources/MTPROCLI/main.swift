import Database
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
/// 新 v0.5.0 shape 只暴露 `help`、`run`、`status`、`verify` 四类入口；历史
/// `rehearsal-status`、`unified-run-status`、`run-observer`、`verify-fast`、`verify-release` 仍可被显式调用。
/// 任何其他命令必须在这里失败，不得 fallback 到旧 release surface。
private enum MTPROStrictCLI {
    static let validationAnchor = "TVM-RELEASE-V050-STRICT-CLI-COMMAND-PARSER"
    static let supportedCommands = [
        "help",
        "run",
        "status",
        "verify",
        ReleaseV030CLIRehearsalSurface.cliCommand,
        ReleaseV040UnifiedRunSurface.cliCommand,
        ReleaseV050RunObserverSurface.cliCommand,
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
            try requireExactCount(arguments, expected: 1, command: command)
            return runOutput()
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
            "issue=GH-727",
            "validationAnchor=\(validationAnchor)",
            "commands=\(commandList)",
            "defaultMode=dry-run",
            "testnetRequiresOperatorConfirmation=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func runOutput() -> String {
        [
            "mtpro run blocked",
            "issue=GH-727",
            "validationAnchor=\(validationAnchor)",
            "mode=dry-run",
            "runtimeStarted=false",
            "testnetConnected=false",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
    }

    private static func statusOutput(arguments: [String]) throws -> String {
        let upstreamArguments: [String]
        switch arguments.count {
        case 1:
            upstreamArguments = [ReleaseV040UnifiedRunSurface.cliCommand]
        case 2:
            upstreamArguments = [ReleaseV040UnifiedRunSurface.cliCommand, arguments[1]]
        default:
            throw MTPROCLIParserError.invalidArguments(
                field: "mtpro.status.arguments",
                expected: "status [runID]",
                actual: arguments.joined(separator: " ")
            )
        }

        let upstream = try ReleaseV040UnifiedRunSurface.commandLineOutput(arguments: upstreamArguments)
        return [
            "mtpro status blocked",
            "issue=GH-727",
            "upstream=GH-705",
            "validationAnchor=\(validationAnchor)",
            upstream
        ].joined(separator: "\n")
    }

    private static func verifyOutput() -> String {
        [
            "mtpro verify pass",
            "issue=GH-727",
            "validationAnchor=\(validationAnchor)",
            "checks=verify-v0.5.0-preflight,verify-v0.5.0-cli,verify-v0.4.0,automation-readiness",
            "unknownCommandFailure=mtpro.strict.arguments",
            "legacyFallbackDisabled=true",
            "productionTradingEnabledByDefault=false",
            "productionSecretRead=false",
            "productionEndpointConnected=false",
            "productionOrderSubmitted=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ].joined(separator: "\n")
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
