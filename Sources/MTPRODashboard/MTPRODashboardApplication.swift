import App
#if canImport(SwiftUI) && os(macOS)
import Darwin
import OSLog
import SwiftUI

/// MTPRODashboardApplication 是 SwiftPM 可构建和可 smoke-run 的 macOS 看板入口。
///
/// 入口只装载 App 模块提供的 `DashboardViewModel.emptyResearchWorkbench`，用于验证
/// Dashboard shell 能从稳定 ViewModel snapshot 启动；它不读取 secret、不连接外部系统、
/// 不触发真实交易行为，也不绕过后续 runtime / projection issue 的边界。
@main
struct MTPRODashboardApplication: SwiftUI.App {
    private let viewModel: DashboardViewModel
    private let logger = Logger(subsystem: "MTPRODashboard", category: "launch")

    init() {
        let viewModel = DashboardViewModel.emptyResearchWorkbench
        self.viewModel = viewModel

        logger.info("MTPRO dashboard app launch")
        logger.info("MTPRO dashboard ViewModel snapshot generated")

        if DashboardSmokeRun.isEnabled {
            DashboardSmokeRun.finish(with: DashboardShellSnapshot(viewModel: viewModel))
        }
    }

    var body: some Scene {
        WindowGroup("MTPRO") {
            DashboardShellView(viewModel: viewModel)
                .frame(minWidth: 980, minHeight: 680)
        }
        .windowStyle(.automatic)
    }
}

private enum DashboardSmokeRun {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.environment["MTPRO_DASHBOARD_SMOKE"] == "1"
    }

    static func finish(with snapshot: DashboardShellSnapshot) -> Never {
        print(snapshot.smokeSummary)
        exit(EXIT_SUCCESS)
    }
}
#else
/// 非 macOS runner 的 executable fallback 只验证 dashboard snapshot contract 可生成。
///
/// Linux CI 会在 `swift test` 期间编译 executable target，但不提供 SwiftUI / Darwin；
/// 该入口不代表可运行 macOS UI，只保留 smoke summary 输出能力，真实窗口仍由 macOS 分支负责。
@main
struct MTPRODashboardApplication {
    static func main() {
        let snapshot = DashboardShellSnapshot(viewModel: .emptyResearchWorkbench)
        print(snapshot.smokeSummary)
    }
}
#endif
