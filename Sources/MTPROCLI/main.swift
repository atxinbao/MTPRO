import Database
import Foundation

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let output = try ReleaseV020CLIProductSurface.commandLineOutput(arguments: arguments)
    print(output)
} catch {
    print("mtpro error: \(error)")
    Foundation.exit(64)
}
