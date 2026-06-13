import Database
import Foundation
import Portfolio

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let output: String
    if arguments == [ReleaseV030CLIRehearsalSurface.cliCommand] {
        output = try ReleaseV030CLIRehearsalSurface.commandLineOutput(arguments: arguments)
    } else if arguments.first == ReleaseV040UnifiedRunSurface.cliCommand {
        output = try ReleaseV040UnifiedRunSurface.commandLineOutput(arguments: arguments)
    } else {
        output = try ReleaseV020CLIProductSurface.commandLineOutput(arguments: arguments)
    }
    print(output)
} catch {
    print("mtpro error: \(error)")
    Foundation.exit(64)
}
