# 最近验证摘要

日期：2026-05-19

执行者：Codex

## 定位

本文档是 MTPRO 最近一次验证摘要。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不是协议事实源，不替代 PR evidence、Linear evidence 或 `verification.md` 完整历史。

## 最近基线

- 最近验证关联 Linear Project：`MTPRO Trading Validation and Parity Hardening`。
- 最近验证对象：`MTP-29`，目标是汇总 trading validation evidence 到 Report / Dashboard read model。
- Project Planning Record：`docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`。
- 执行事实源是 Linear `MTP-29` issue body；planning record 不单独授权执行。
- Linear 只读查询确认：`MTP-24` 至 `MTP-28` 为 `Done`，`MTP-29` 为 `In Progress`，`MTP-30` 为 `Backlog`。
- 本轮新增 App 层 `ReportExecutionCostEvidence` 和 `TradingValidationEvidenceSummary`。
- 本轮扩展 `ResearchBacktestReportArtifact`、`ReportArtifactViewModel` 和 `ReportViewModel`，汇总 projection-level parity、MTP-27 deterministic cost evidence、risk blocker evidence 和 paper-only portfolio exposure evidence。
- 本轮 Dashboard Report 区域展示 cost evidence count、risk blocker count、exposure evidence count、cost assumption、cost parity、risk blocker evidence ID、exposure symbols 和 gross exposure notional。
- 本轮 deterministic fixture 继续使用 MTP-27 cost assumption `mtp-27-fixed-cost-assumptions`，并从 MTP-28 paper-only exposure projection 派生 maker / taker Backtest / Paper cost parity evidence；该 evidence 不代表 Binance 实际费率、真实成交、broker fill 或账户成本。
- 本轮更新 `docs/validation/trading-validation-matrix.md` 中 `TVM-REPORT-EVIDENCE` 的 MTP-29 回填证据，并在 `docs/validation/validation-plan.md` 记录 MTP-29 required validation。
- MTP-25 已完成并加固 EMA Backtest / Paper signal timeline parity；MTP-26 已完成并加固 Order Book Imbalance research parity 和 bias evidence；MTP-27 已完成 fixed fees / slippage evidence；MTP-28 已完成 risk blocker / portfolio exposure evidence。
- 上一阶段 Stage Code Audit Report 已记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界，并确认审计报告覆盖完整 Linear Project；本轮 MTP-29 未新增临时 CI 平台边界。
- Project 全部 Done 后，Stage Code Audit Report 必须包含 Root Docs Delta，并先完成 Root Docs Refresh Gate，才进入 Next Human Project Planning。
- Root Docs Refresh Gate 只允许 `@002 / PAR` 同步 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 中已发生的事实；方向性变化交给 Human + `@001 / PLN`。
- `graphify-out/*` 未提交，`.codex/*` 未提交。
- 本轮执行上下文中的 `symphony-issue` active Project pointer 指向 `mtpro-trading-validation-and-parity-hardening-4286a197bec0`；child Codex 不修改 pointer，本文档不作为 current issue 或 queue pointer 的事实源。

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter AppTests` | pass | 8 个 AppTests 通过；覆盖 Report / Dashboard trading validation evidence summary、Codable deterministic snapshot、schema leakage 禁区和 research-only execution authorization。 |
| `git diff --check` | pass | 由 `bash checks/run.sh` 串联执行，当前 diff 无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；Trading Validation Matrix 锚点仍完整。 |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 66 个 XCTest 通过；新增 MTP-29 Report / Dashboard trading validation evidence coverage。 |
| `bash checks/run.sh` | pass | macOS 本地执行 `git diff --check`、automation readiness、dashboard build、dashboard smoke run 和 `swift test` 通过；输出 `MTPRO checks passed.` |
| Stage Code Audit Report | n/a | 当前 Project 尚未全部 Done；Project 级 Stage Code Audit Report 仍须在 MTP-24 至 MTP-30 全部 Done 后由 Parent Codex 输出。 |

## 当前边界

- MTP-29 只汇总 Report / Dashboard read model 的 trading validation evidence，不授权 MTP-30 或其他后续 issue。
- Trading Validation Matrix 是 evidence routing 入口，不替代 Linear issue contract、PR evidence 或 Stage Code Audit Report。
- `MTPRO Trading Validation and Parity Hardening` planning record 不单独授权执行。
- 当前 planning record 不创建 Linear Project / Issues，不替代 Linear issue body。
- Report 输入只来自 projection snapshots / read model 和 append-only event timeline。
- Report 可汇总 projection-level Backtest / Paper evidence，但不替代 Core 层完整 signal timeline parity。
- `ReportExecutionCostEvidence` 只从 deterministic fixture 和 paper-only exposure projection 派生，不读取交易所费率表、account tier、真实成交或 broker fill。
- `RiskBlockerEvidence` 只代表本地 Paper 风险阻断证据，不代表真实 broker 拒单、account state 或 Live fallback。
- `PortfolioExposureSnapshot` 只代表 Paper projection 派生的 gross exposure evidence，不代表真实账户余额、margin、leverage、broker position 或真实成交。
- `ReportViewModel` / `DashboardShellSnapshot` 只展示稳定 read model projection，不提供 report execution command、risk control command、position management command 或交易执行入口。
- 不做完整报表系统、交易所费率表、动态滑点模型、执行成本优化、完整风险引擎、实时风控、仓位管理、保证金、杠杆、真实账户余额或完整 Paper execution 工作流。
- 不修改 Linear status。
- 不创建 Linear Project / Issue。
- 不启动 Symphony。
- 不运行 Graphify full rebuild。
- 不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## 完整历史

完整验证流水账见 `../../verification.md`。
