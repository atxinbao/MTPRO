import Foundation

/// CoreBaseline 暴露当前 Core 模块的产品基线，用于测试和文档核对。

/// CoreBaseline 描述 Core target 当前基线，用于测试确认第一版 universe、timeframe 和 paper-only 边界。
public struct CoreBaseline: Equatable, Sendable {
    public let projectName: String
    public let coreMode: String
    public let executionMode: String
    public let primaryUniverse: [String]
    public let timeframes: [String]

    public init(
        projectName: String = "MTPRO",
        coreMode: String = "Swift-only actor core",
        executionMode: String = "paper-only",
        primaryUniverse: [String] = Symbol.supportedRawValues,
        timeframes: [String] = Timeframe.supportedRawValues
    ) {
        self.projectName = projectName
        self.coreMode = coreMode
        self.executionMode = executionMode
        self.primaryUniverse = primaryUniverse
        self.timeframes = timeframes
    }
}
