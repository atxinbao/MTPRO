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
        let url = URL(fileURLWithPath: arguments[1]).standardizedFileURL
        guard url.isFileURL,
              let data = try? Data(contentsOf: url),
              let bundle = try? JSONDecoder().decode(
                  ReleaseV0330DemoValidationEvidenceBundle.self,
                  from: data
              )
        else {
            throw ReleaseV0330DemoValidationStatusCLIFailedValidation(
                renderedOutput: output(
                    ReleaseV0330DemoValidationDecisionEngine.evaluate(bundle: nil)
                )
            )
        }
        let report = ReleaseV0330DemoValidationDecisionEngine.evaluate(bundle: bundle)
        guard report.decision == .accepted else {
            throw ReleaseV0330DemoValidationStatusCLIFailedValidation(
                renderedOutput: output(report)
            )
        }
        return output(report)
    }

    private static func output(_ report: ReleaseV0330DemoValidationDecisionReport) -> String {
        [
            "v0.33-demo-validation-status",
            "demoValidationDecision=\(report.decision.rawValue)",
            "backendClosureDecision=\(report.backendClosureDecision)",
            "productionCutoverAuthorized=\(report.productionCutoverAuthorized)",
            "defaultProductionTradingEnabled=\(report.defaultProductionTradingEnabled)",
            "bundleSHA256=\(report.bundleSHA256 ?? "missing")",
            "reasons=\(report.reasons.joined(separator: ","))",
            "readModelOnly=true",
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
