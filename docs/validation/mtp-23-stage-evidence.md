# MTP-23 阶段证据材料

日期：2026-05-18

执行者：Codex

## 定位

本文档是 `MTPRO Runtime Research Workbench v1` 的 Issue 8 阶段证据材料，服务 `MTP-23` 的 PR evidence。

本文档不是 Stage Code Audit Report。Stage Code Audit Report 必须在 Project 全部 Done 后由父 Codex 单独输出。

## Research -> Backtest -> Report 最小路径

当前最小路径：

1. Research projection：订单簿失衡研究运行和研究信号进入分析投影。
2. Backtest projection：EMA 回测运行和 signal timeline 进入分析投影。
3. Paper projection evidence：Paper session 运行时投影提供同策略、同 symbol / timeframe 和 signal count 证据。
4. Report read model：`ReportReadModel` 从 projection snapshots 和 append-only event timeline 生成 `ResearchBacktestReportArtifact`。
5. Dashboard snapshot：`ReportViewModel` 和 `DashboardShellSnapshot` 呈现只读 Report 快照。

## Evidence Chain

| 层级 | Evidence | 边界 |
| --- | --- | --- |
| Core | `BacktestEventFlow`、`PaperSessionEventFlow`、`BacktestPaperParity` | 完整信号时间线 parity 仍由 Core 测试验证 |
| Persistence | `DuckDBAnalyticalProjectionSnapshot`、`SQLiteRuntimeProjectionSnapshot` | 只输出稳定 projection snapshot，不暴露 schema |
| App | `ReportReadModel`、`ReportViewModel`、`DashboardShellSnapshot` | 只消费 read model，不调用 Runtime / Adapters |
| Validation | `Tests/AppTests/AppTests.swift`、`bash checks/run.sh` | 本地自动验证，不依赖 CI 或人工外包 |

## 已知边界

- Report 是研究输出，不是交易执行授权。
- Report 只表达 projection-level Backtest / Paper evidence，不替代 Core 层完整 signal timeline parity。
- 当前不做完整报表系统。
- 当前不扩展 Paper execution 工作流。
- 当前不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 当前不把 SQLite / DuckDB schema、table、column、SQL statement 或 payload 编码暴露给 UI。

## 下一阶段观察提示

以下内容只作为 Project 完成后父 Codex 阶段审计和 Human planning 的观察输入，不授权创建 issue，不绕过 queue preflight，不替代 Linear 执行合同：

- 后续如果需要完整 report system，应先定义 report contract、artifact versioning 和导出边界。
- 后续如果需要 Paper execution workflow，应先扩展 Paper 事件模型和 risk / portfolio 验证，不得从 Report 反向触发执行。
- 后续 Stage Code Audit Report 应单独审计本 Project 的 issue 顺序、evidence chain、PR validation 和交易禁区保持情况。
