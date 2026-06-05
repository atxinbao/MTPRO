import DomainModel
import Foundation

/// 研究结果类型保存回测、Paper 和订单簿研究的本地事件流输出，是后续 projection 的稳定输入。

/// OrderBookImbalanceResearchResult 保存订单簿研究结果和完成时间，供事件流与分析投影使用。
public struct OrderBookImbalanceResearchResult: Codable, Equatable, Sendable {
    public let researchID: Identifier
    public let command: OrderBookImbalanceResearchCommand
    public let signalSamples: [OrderBookImbalanceSignalSample]
    public let completedAt: Date

    public init(
        researchID: Identifier,
        command: OrderBookImbalanceResearchCommand,
        signalSamples: [OrderBookImbalanceSignalSample],
        completedAt: Date
    ) {
        self.researchID = researchID
        self.command = command
        self.signalSamples = signalSamples
        self.completedAt = completedAt
    }
}

/// BacktestResult 保存回测信号时间线和完成时间，不包含真实成交或账户状态。
public struct BacktestResult: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let command: BacktestCommand
    public let signalSamples: [EMACrossSignalSample]
    public let completedAt: Date

    public init(
        runID: Identifier,
        command: BacktestCommand,
        signalSamples: [EMACrossSignalSample],
        completedAt: Date
    ) {
        self.runID = runID
        self.command = command
        self.signalSamples = signalSamples
        self.completedAt = completedAt
    }
}

/// PaperSessionResult 保存 Paper 信号时间线和完成时间，不提交真实订单。
public struct PaperSessionResult: Codable, Equatable, Sendable {
    public let sessionID: Identifier
    public let command: PaperSessionCommand
    public let signalSamples: [EMACrossSignalSample]
    public let completedAt: Date

    public init(
        sessionID: Identifier,
        command: PaperSessionCommand,
        signalSamples: [EMACrossSignalSample],
        completedAt: Date
    ) {
        self.sessionID = sessionID
        self.command = command
        self.signalSamples = signalSamples
        self.completedAt = completedAt
    }
}

/// BacktestRun 绑定回测结果和事件序列，作为 append-only event log 的输入。
public struct BacktestRun: Codable, Equatable, Sendable {
    public let result: BacktestResult
    public let events: [BacktestEvent]

    public init(result: BacktestResult, events: [BacktestEvent]) {
        self.result = result
        self.events = events
    }
}

/// PaperSessionRun 绑定 Paper 结果和事件序列，保持本地模拟边界。
public struct PaperSessionRun: Codable, Equatable, Sendable {
    public let result: PaperSessionResult
    public let events: [PaperEvent]

    public init(result: PaperSessionResult, events: [PaperEvent]) {
        self.result = result
        self.events = events
    }
}

/// OrderBookImbalanceResearchRun 绑定订单簿研究结果和事件序列，用于 strategy stream 发布。
public struct OrderBookImbalanceResearchRun: Codable, Equatable, Sendable {
    public let result: OrderBookImbalanceResearchResult
    public let events: [OrderBookImbalanceResearchEvent]

    public init(
        result: OrderBookImbalanceResearchResult,
        events: [OrderBookImbalanceResearchEvent]
    ) {
        self.result = result
        self.events = events
    }
}
