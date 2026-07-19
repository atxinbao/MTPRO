import ExecutionClient
import Foundation

// GH-1548-ADD-READ-ONLY-DEMO-VALIDATION-STATUS-SURFACE
// TVM-RELEASE-V0330-DEMO-VALIDATION-STATUS
// V0330-007-READ-ONLY-STATUS
public enum ReleaseV0330DemoValidationStatusCLI {
    public static let cliCommand = "v0.33-demo-validation-status"

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.count == 2, arguments[0] == cliCommand else {
            throw ReleaseV0330DemoValidationStatusCLIError.invalidArguments
        }
        let snapshot = ReleaseV0330DemoValidationArtifactValidator.validate(
            bundleURL: URL(fileURLWithPath: arguments[1])
        )
        guard snapshot.decision == .accepted else {
            throw ReleaseV0330DemoValidationStatusCLIFailedValidation(
                renderedOutput: output(snapshot)
            )
        }
        return output(snapshot)
    }

    private static func output(_ snapshot: ReleaseV0330DemoValidationStatusSnapshot) -> String {
        [
            "v0.33-demo-validation-status",
            "demoValidationDecision=\(snapshot.decision.rawValue)",
            "backendClosureDecision=\(snapshot.backendClosureDecision)",
            "productionCutoverAuthorized=\(snapshot.productionCutoverAuthorized)",
            "defaultProductionTradingEnabled=\(snapshot.defaultProductionTradingEnabled)",
            "bundleSHA256=\(snapshot.bundleSHA256 ?? "missing")",
            "reasons=\(snapshot.reasons.joined(separator: ","))",
            "readModelOnly=\(snapshot.readModelOnly)",
        ].joined(separator: "\n")
    }
}

public enum ReleaseV0330DemoValidationStatusCLIError: Error, Equatable, Sendable {
    case invalidArguments
}

public struct ReleaseV0330DemoValidationStatusCLIFailedValidation: Error, Equatable, Sendable {
    public let renderedOutput: String
    public let exitCode: Int32

    public init(renderedOutput: String, exitCode: Int32 = 1) {
        self.renderedOutput = renderedOutput
        self.exitCode = exitCode
    }
}
