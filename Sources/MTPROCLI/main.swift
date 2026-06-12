import Database
import Foundation

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let output = try ReleaseV020CLIProductSurface.commandLineOutput(arguments: arguments)
    print(output)
} catch {
    fputs("mtpro error: \(error)\n", stderr)
    Foundation.exit(64)
}
