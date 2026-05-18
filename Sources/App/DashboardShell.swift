import Foundation
import Core
#if canImport(SwiftUI) && os(macOS)
import SwiftUI
#endif

/// DashboardShellMetric 是 macOS 看板壳用于渲染单个只读指标的稳定展示快照。
///
/// 输入必须来自 `DashboardViewModel` 派生的 shell snapshot；输出只包含 label / value 文本，
/// 不携带数据库行、运行时对象或任何可触发交易动作的命令。
public struct DashboardShellMetric: Codable, Equatable, Identifiable, Sendable {
    public let label: String
    public let value: String

    public var id: String {
        label
    }

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

/// DashboardShellSectionSnapshot 是 SwiftUI section panel 的只读输入模型。
///
/// 每个 section 只绑定现有 ViewModel snapshot，`source` 保留 read-model-only 证据；
/// detail rows 只用于观察，不暴露表名、SQL、adapter 请求、账户信息或 broker side effect。
public struct DashboardShellSectionSnapshot: Codable, Equatable, Identifiable, Sendable {
    public let section: DashboardSection
    public let title: String
    public let systemImage: String
    public let source: ViewModelSourceContract
    public let metrics: [DashboardShellMetric]
    public let details: [String]

    public var id: DashboardSection {
        section
    }

    public init(
        section: DashboardSection,
        title: String,
        systemImage: String,
        source: ViewModelSourceContract,
        metrics: [DashboardShellMetric],
        details: [String]
    ) {
        self.section = section
        self.title = title
        self.systemImage = systemImage
        self.source = source
        self.metrics = metrics
        self.details = details
    }
}

/// DashboardShellSnapshot 是 macOS 看板壳的唯一 View input。
///
/// 它从 `DashboardViewModel` 生成可渲染快照，保证 UI 只消费 App 层 ViewModel / Read Model；
/// shell 不直接连接外部行情 adapter、数据库 schema、runtime object 或任何真实交易能力。
public struct DashboardShellSnapshot: Codable, Equatable, Sendable {
    public let title: String
    public let subtitle: String
    public let sections: [DashboardShellSectionSnapshot]

    public init(
        title: String = "MTPRO Research Workbench",
        subtitle: String = "Research -> Backtest -> Report",
        viewModel: DashboardViewModel
    ) {
        self.title = title
        self.subtitle = subtitle
        self.sections = viewModel.sections.map { section in
            Self.makeSectionSnapshot(for: section, viewModel: viewModel)
        }
    }

    public var viewModelSources: [ViewModelSourceContract] {
        sections.map(\.source)
    }

    public var isReadModelOnly: Bool {
        viewModelSources.allSatisfy(\.isReadModelOnly)
    }

    public var smokeSummary: String {
        let sectionNames = sections.map(\.title).joined(separator: ",")
        return "MTPRO Dashboard smoke: sections=\(sections.count); readModelOnly=\(isReadModelOnly); sections=\(sectionNames)"
    }

    private static func makeSectionSnapshot(
        for section: DashboardSection,
        viewModel: DashboardViewModel
    ) -> DashboardShellSectionSnapshot {
        switch section {
        case .market:
            return makeMarketSnapshot(viewModel.market)
        case .strategy:
            return makeStrategySnapshot(viewModel.strategy)
        case .backtest:
            return makeBacktestSnapshot(viewModel.backtest)
        case .report:
            return makeReportSnapshot(viewModel.report)
        case .paper:
            return makePaperSnapshot(viewModel.paper)
        case .risk:
            return makeRiskSnapshot(viewModel.risk)
        case .portfolio:
            return makePortfolioSnapshot(viewModel.portfolio)
        case .events:
            return makeEventsSnapshot(viewModel.events)
        }
    }

    private static func makeMarketSnapshot(
        _ viewModel: MarketViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .market,
            title: viewModel.section.rawValue,
            systemImage: "chart.xyaxis.line",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Symbols", value: "\(viewModel.symbols.count)"),
                DashboardShellMetric(label: "Bars", value: "\(viewModel.barCount)"),
                DashboardShellMetric(label: "Trades", value: "\(viewModel.tradeCount)"),
                DashboardShellMetric(label: "Latest close", value: format(viewModel.latestBarClose))
            ],
            details: [
                "Universe: \(joined(viewModel.symbols))",
                "Best bid / ask: \(viewModel.bestBidAskCount)",
                "Order book snapshots: \(viewModel.orderBookSnapshotCount)",
                "Order book deltas: \(viewModel.orderBookDeltaCount)",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeStrategySnapshot(
        _ viewModel: StrategyViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .strategy,
            title: viewModel.section.rawValue,
            systemImage: "point.3.connected.trianglepath.dotted",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Strategies", value: "\(viewModel.strategyIDs.count)"),
                DashboardShellMetric(label: "Signals", value: "\(viewModel.signalCount)"),
                DashboardShellMetric(label: "Latest signal", value: format(viewModel.latestSignalDirection))
            ],
            details: [
                "Strategy IDs: \(joined(viewModel.strategyIDs))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeBacktestSnapshot(
        _ viewModel: BacktestViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .backtest,
            title: viewModel.section.rawValue,
            systemImage: "clock.arrow.circlepath",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Runs", value: "\(viewModel.runs.count)"),
                DashboardShellMetric(label: "Completed", value: "\(viewModel.completedRunCount)"),
                DashboardShellMetric(label: "Signals", value: "\(viewModel.totalSignalCount)"),
                DashboardShellMetric(label: "Latest signal", value: format(viewModel.latestSignalDirection))
            ],
            details: [
                "Run IDs: \(joined(viewModel.runs.map(\.runID)))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeReportSnapshot(
        _ viewModel: ReportViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .report,
            title: viewModel.section.rawValue,
            systemImage: "doc.richtext",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Reports", value: "\(viewModel.artifactCount)"),
                DashboardShellMetric(label: "Backtests", value: "\(viewModel.completedBacktestCount)"),
                DashboardShellMetric(label: "Research", value: "\(viewModel.researchRunCount)"),
                DashboardShellMetric(label: "Parity", value: "\(viewModel.matchedParityEvidenceCount)")
            ],
            details: [
                "Report IDs: \(joined(viewModel.artifacts.map(\.reportID)))",
                "Backtest run IDs: \(joined(viewModel.artifacts.map(\.backtestRunID)))",
                "Paper sessions: \(joined(viewModel.artifacts.flatMap(\.paperSessionIDs)))",
                "Execution: \(format(viewModel.authorizesTradingExecution))",
                "Latest parity: \(format(viewModel.latestParityStatus))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makePaperSnapshot(
        _ viewModel: PaperViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .paper,
            title: viewModel.section.rawValue,
            systemImage: "doc.text.magnifyingglass",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Sessions", value: "\(viewModel.sessions.count)"),
                DashboardShellMetric(label: "Active", value: "\(viewModel.activeSessionCount)"),
                DashboardShellMetric(label: "Completed", value: "\(viewModel.completedSessionCount)")
            ],
            details: [
                "Session IDs: \(joined(viewModel.sessions.map(\.sessionID)))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeRiskSnapshot(
        _ viewModel: RiskViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .risk,
            title: viewModel.section.rawValue,
            systemImage: "exclamationmark.triangle",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Blockers", value: "\(viewModel.rejectionCount)")
            ],
            details: [
                "Rejected paper order IDs: \(joined(viewModel.rejectedPaperOrderIDs))",
                "Reasons: \(joined(viewModel.blockerReasons.map(\.rawValue)))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makePortfolioSnapshot(
        _ viewModel: PortfolioViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .portfolio,
            title: viewModel.section.rawValue,
            systemImage: "briefcase",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Portfolios", value: "\(viewModel.portfolioIDs.count)"),
                DashboardShellMetric(label: "Updated", value: "\(viewModel.updatedPortfolioCount)"),
                DashboardShellMetric(label: "Exposures", value: "\(viewModel.exposureCount)"),
                DashboardShellMetric(label: "Gross exposure", value: format(viewModel.totalGrossExposureNotional))
            ],
            details: [
                "Portfolio IDs: \(joined(viewModel.portfolioIDs))",
                "Exposure symbols: \(joined(viewModel.exposures.map(\.symbol)))",
                "Last sequence: \(format(viewModel.lastAppliedSequence))"
            ]
        )
    }

    private static func makeEventsSnapshot(
        _ viewModel: EventLogViewModel
    ) -> DashboardShellSectionSnapshot {
        DashboardShellSectionSnapshot(
            section: .events,
            title: viewModel.section.rawValue,
            systemImage: "list.bullet.rectangle",
            source: viewModel.source,
            metrics: [
                DashboardShellMetric(label: "Events", value: "\(viewModel.eventCount)"),
                DashboardShellMetric(label: "Streams", value: "\(viewModel.streams.count)"),
                DashboardShellMetric(label: "Last sequence", value: format(viewModel.lastSequence))
            ],
            details: [
                "Streams: \(joined(viewModel.streams))"
            ]
        )
    }

    private static func format(_ value: Double?) -> String {
        guard let value else {
            return "n/a"
        }
        return String(format: "%.2f", value)
    }

    private static func format(_ value: Int?) -> String {
        guard let value else {
            return "n/a"
        }
        return "\(value)"
    }

    private static func format(_ value: SignalDirection?) -> String {
        guard let value else {
            return "n/a"
        }
        return value.rawValue
    }

    private static func format(_ value: Bool) -> String {
        value ? "authorized" : "research-only"
    }

    private static func format(_ value: ReportParityStatus?) -> String {
        guard let value else {
            return "n/a"
        }
        return value.rawValue
    }

    private static func joined(_ values: [String]) -> String {
        values.isEmpty ? "n/a" : values.joined(separator: ", ")
    }
}

public extension DashboardReadModel {
    /// 空研究工作台 read model 是可运行 shell 的安全初始快照。
    ///
    /// 该快照只表达“当前没有已重放事实”，不会伪造 market、paper、risk 或 portfolio 状态；
    /// 后续真实数据必须继续通过稳定 read model projection 注入。
    static var emptyResearchWorkbench: DashboardReadModel {
        DashboardReadModel(
            market: MarketReadModel(),
            strategy: StrategyReadModel(),
            backtest: BacktestReadModel(),
            report: ReportReadModel(),
            paper: PaperReadModel(),
            risk: RiskReadModel(),
            portfolio: PortfolioReadModel(),
            events: EventTimelineReadModel()
        )
    }
}

public extension DashboardViewModel {
    /// 可运行 macOS shell 的默认 ViewModel snapshot。
    ///
    /// 输入来自空 read model projection，仅用于 app launch 和 smoke validation；
    /// 它不打开网络、不读取数据库 schema、不创建 broker action，也不提供真实交易控制。
    static var emptyResearchWorkbench: DashboardViewModel {
        DashboardViewModel(readModel: .emptyResearchWorkbench)
    }
}

/// DashboardShellView 是 MTPRO 第一版 macOS 只读看板壳。
///
/// 该 View 只接收 `DashboardViewModel`，内部立即转换为 `DashboardShellSnapshot` 渲染
/// Market、Strategy、Backtest、Report、Paper、Risk、Portfolio 和 Events 八个区域；它没有按钮、
/// 表单或命令出口，因此不会触发外部系统、副作用或真实交易行为。
#if canImport(SwiftUI) && os(macOS)
public struct DashboardShellView: View {
    public let snapshot: DashboardShellSnapshot

    public init(viewModel: DashboardViewModel) {
        self.snapshot = DashboardShellSnapshot(viewModel: viewModel)
    }

    public init(snapshot: DashboardShellSnapshot) {
        self.snapshot = snapshot
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(snapshot.title)
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                    Text(snapshot.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                LazyVGrid(
                    columns: [
                        GridItem(
                            .adaptive(minimum: 260, maximum: 420),
                            spacing: 12,
                            alignment: .top
                        )
                    ],
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(snapshot.sections) { section in
                        DashboardSectionPanel(section: section)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
#else
/// DashboardShellView 的非 macOS fallback 只保留 snapshot binding contract。
///
/// GitHub Linux runner 不提供 SwiftUI；该 fallback 让 App target 和 XCTest 仍能验证
/// ViewModel snapshot 绑定、只读来源和 forbidden integration 边界。真实 macOS UI 只在
/// `canImport(SwiftUI) && os(macOS)` 分支中构建。
public struct DashboardShellView: Equatable, Sendable {
    public let snapshot: DashboardShellSnapshot

    public init(viewModel: DashboardViewModel) {
        self.snapshot = DashboardShellSnapshot(viewModel: viewModel)
    }

    public init(snapshot: DashboardShellSnapshot) {
        self.snapshot = snapshot
    }
}
#endif

#if canImport(SwiftUI) && os(macOS)
private struct DashboardSectionPanel: View {
    let section: DashboardShellSectionSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(section.title, systemImage: section.systemImage)
                .font(.headline)

            HStack(alignment: .top, spacing: 8) {
                ForEach(section.metrics) { metric in
                    DashboardMetricTile(metric: metric)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(section.details, id: \.self) { detail in
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 172, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }
}

private struct DashboardMetricTile: View {
    let metric: DashboardShellMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(metric.value)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(metric.label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
#endif
