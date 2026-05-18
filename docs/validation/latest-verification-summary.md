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
- 最近验证对象：`MTP-26`，目标是加固 Order Book Imbalance research parity 和 bias evidence。
- Project Planning Record：`docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`。
- 执行事实源是 Linear `MTP-26` issue body；planning record 不单独授权执行。
- Linear 只读查询确认：`MTP-24` 和 `MTP-25` 为 `Done`，`MTP-26` 为 `In Progress`，`MTP-27` 至 `MTP-30` 仍为 `Backlog`。
- 本轮变更为 `OrderBookImbalanceSignalSample` 增加 `inputSource` evidence，新增 `OrderBookImbalanceResearchParity` / `OrderBookImbalanceResearchParityResult`，并把 `orderBookInputSource` 写入 DuckDB analytical signal timeline projection。
- 本轮更新 `docs/validation/trading-validation-matrix.md` 中 `TVM-ORDER-BOOK-IMBALANCE-PARITY` 的 MTP-26 回填证据，并在 `docs/validation/validation-plan.md` 记录 MTP-26 required validation。
- MTP-25 已完成并加固 EMA Backtest / Paper signal timeline parity；MTP-25 回填了 `TVM-EMA-PARITY`，并补充了 query range 契约。
- 上一阶段 Stage Code Audit Report 已记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界，并确认审计报告覆盖完整 Linear Project；本轮 MTP-26 未新增临时 CI 平台边界。
- Project 全部 Done 后，Stage Code Audit Report 必须包含 Root Docs Delta，并先完成 Root Docs Refresh Gate，才进入 Next Human Project Planning。
- Root Docs Refresh Gate 只允许 `@002 / PAR` 同步 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 中已发生的事实；方向性变化交给 Human + `@001 / PLN`。
- `graphify-out/*` 未提交，`.codex/*` 未提交。
- 本轮执行上下文中的 `symphony-issue` active Project pointer 指向 `mtpro-trading-validation-and-parity-hardening-4286a197bec0`；child Codex 不修改 pointer，本文档不作为 current issue 或 queue pointer 的事实源。

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testOrderBookImbalance` | pass | 4 个 CoreTests 通过；覆盖订单簿失衡 invalid input、research stream、parity / bias evidence 和 deterministic fixture。 |
| `swift test --filter PersistenceTests/testTemporaryDuckDBProjectionRebuildsAnalyticalState` | pass | 1 个 PersistenceTests 通过；验证 DuckDB analytical signal timeline 保存 order book input source。 |
| `git diff --check` | pass | 由 `bash checks/run.sh` 串联执行，当前 diff 无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；Trading Validation Matrix 锚点仍完整。 |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 62 个 XCTest 通过；新增 MTP-26 order book imbalance parity / bias evidence coverage。 |
| `bash checks/run.sh` | pass | macOS 本地执行 `git diff --check`、automation readiness、dashboard build、dashboard smoke run 和 `swift test` 通过；输出 `MTPRO checks passed.` |
| Stage Code Audit Report | n/a | 当前 Project 尚未全部 Done；Project 级 Stage Code Audit Report 仍须在 MTP-24 至 MTP-30 全部 Done 后由 Parent Codex 输出。 |

## 当前边界

- MTP-26 只加固 Order Book Imbalance research parity、bias evidence、snapshot / delta input source 和矩阵回填，不授权 MTP-27 或其他后续 issue。
- Trading Validation Matrix 是 evidence routing 入口，不替代 Linear issue contract、PR evidence 或 Stage Code Audit Report。
- `MTPRO Trading Validation and Parity Hardening` planning record 不单独授权执行。
- 当前 planning record 不创建 Linear Project / Issues，不替代 Linear issue body。
- `OrderBookImbalanceResearchParity` 只比较本地 deterministic contract 与 research event flow，不代表 Paper、Live 或 broker execution。
- ask dominance 只作为 research bias，signal direction 保持 `.flat`，不得映射为 short、margin、futures leverage 或真实订单动作。
- `orderBookInputSource` 只进入稳定 read model / projection evidence，不暴露 DuckDB schema、SQL、table、column 或 adapter internals。
- Report 输入只来自 projection snapshots / read model 和 append-only event timeline。
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
