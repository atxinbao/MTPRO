import Foundation

public struct MTPROCoreBaseline: Equatable, Sendable {
    public let projectName: String
    public let coreMode: String
    public let executionMode: String
    public let primaryUniverse: [String]
    public let timeframes: [String]

    public init(
        projectName: String = "MTPRO",
        coreMode: String = "Swift-only actor core",
        executionMode: String = "paper-only",
        primaryUniverse: [String] = ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"],
        timeframes: [String] = ["1m", "5m"]
    ) {
        self.projectName = projectName
        self.coreMode = coreMode
        self.executionMode = executionMode
        self.primaryUniverse = primaryUniverse
        self.timeframes = timeframes
    }
}
