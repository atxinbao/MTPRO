# 最近验证摘要

日期：2026-05-18

执行者：Codex

## 定位

本文档是 MTPRO 最近一次验证摘要。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不是协议事实源，不替代 PR evidence、Linear evidence 或 `verification.md` 完整历史。

## 最近基线

- 最近验证关联 Linear Project：`MTPRO Trading Validation and Parity Hardening`。
- 最近验证对象：`MTP-25`，目标是加固 EMA Backtest / Paper signal timeline parity。
- Project Planning Record：`docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`。
- 执行事实源是 Linear `MTP-25` issue body；planning record 不单独授权执行。
- 本轮变更加固 `BacktestEventFlow` / `PaperSessionEventFlow` 的 `MarketDataQuery.range` 校验，防止 bars 超出查询窗口时生成 parity 假阳性。
- 本轮新增 deterministic Core tests，覆盖同一 strategy config、同一 `MarketDataQuery`、symbol、timeframe、long EMA warm-up、signal direction、timestamp 和 query range too narrow 错误边界。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-EMA-PARITY` 已回填 MTP-25 新增测试和 edge case 证据入口。
- `docs/contracts/backend-use-case-contract.md` 与 `docs/contracts/api-contract.md` 已补充 MTP-25 的 query range 契约。
- `MTP-24` 已完成并定义 Trading Validation Matrix；`MTP-26` 到 `MTP-30` 仍必须等 Parent Codex queue preflight 和唯一 eligible issue 调度。
- 上一阶段 Stage Code Audit Report 已记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界，并确认审计报告覆盖完整 Linear Project；本轮 MTP-25 未新增临时 CI 平台边界。
- `graphify-out/*` 未提交，`.codex/*` 未提交。
- 本轮执行上下文中的 `symphony-issue` active Project pointer 指向 `mtpro-trading-validation-and-parity-hardening-4286a197bec0`；child Codex 不修改 pointer，本文档不作为 current issue 或 queue pointer 的事实源。

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testEMA` | pass | 4 个 EMA 聚焦 XCTest 通过，覆盖 deterministic signal fixture、strategy/query/warm-up/timestamp parity 和 query range too narrow 拒绝路径。 |
| `git diff --check` | pass | 由 `bash checks/run.sh` 串联执行，当前 diff 无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；Trading Validation Matrix 锚点仍完整。 |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 61 个 XCTest 通过；CoreTests 增至 24 个，新增 MTP-25 EMA parity coverage。 |
| `bash checks/run.sh` | pass | macOS 本地执行 `git diff --check`、automation readiness、dashboard build、dashboard smoke run 和 `swift test` 通过；输出 `MTPRO checks passed.` |
| Stage Code Audit Report | n/a | 当前 Project 尚未全部 Done；Project 级 Stage Code Audit Report 仍须在 MTP-24 至 MTP-30 全部 Done 后由 Parent Codex 输出。 |

## 当前边界

- MTP-25 只加固 EMA Backtest / Paper signal timeline parity，不授权 MTP-26 或其他后续 issue。
- Trading Validation Matrix 是 evidence routing 入口，不替代 Linear issue contract、PR evidence 或 Stage Code Audit Report。
- Report 只表达 projection-level Backtest / Paper evidence，不替代 Core 层完整 signal timeline parity。
- 不做完整 Paper execution 工作流。
- 不修改 Linear status。
- 不创建 Linear Project / Issue。
- 不启动 Symphony。
- 不运行 Graphify full rebuild。
- 不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## 完整历史

完整验证流水账见 `../../verification.md`。
