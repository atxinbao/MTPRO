# MTPRO Event-Driven Paper Trading Runtime v1

日期：2026-05-25

执行者：Codex

本文档是 `MTPRO Event-Driven Paper Trading Runtime v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不写业务代码，不修改 Figma，不实现 Paper runtime。

完整 issue execution contract 以后以 Linear issue body 为准。仓库 planning record 不复制维护完整 Linear issue body。

## Project name

`MTPRO Event-Driven Paper Trading Runtime v1`

## Project goal

把已落仓的 `MTPRO Paper Trading Runtime Foundation Blueprint v1` 转成 paper-only、event-driven、deterministic runtime 的可执行前规划。

本阶段目标是在不触碰真实交易能力的前提下，建立 TradingClock / runtime kernel、CommandBus / EventBus / MessageBus、Paper Pre-trade RiskEngine、paper lifecycle coordinator、local / simulated order lifecycle、simulated fill、fee / slippage、paper account / portfolio / position projection，以及 Event Log / Replay / Report / Dashboard evidence 闭环。

## Source inputs

- `docs/product/mtpro-paper-trading-runtime-foundation-blueprint-v1.md`
- `docs/product/mtpro-codebase-reference-gap-map-v1.md`
- `docs/product/mtpro-reference-alignment-gap-map-v1.md`
- `BLUEPRINT.md`
- `docs/architecture.md`
- `docs/roadmap.md`
- `docs/validation/latest-verification-summary.md`

## Scope

- 定义并实现 paper-only TradingClock 与 runtime kernel boundary。
- 定义 deterministic CommandBus / EventBus / MessageBus routing。
- 建立 Paper Pre-trade RiskEngine 的最小 runtime path。
- 建立 paper-only lifecycle coordinator，管理 local / simulated order lifecycle。
- 建立 simulated fill / fee / slippage 的 deterministic assumptions。
- 建立 paper account / portfolio / position projection。
- 串联 Event Log -> Replay -> Projection -> Report / Dashboard / Event Timeline evidence。
- 所有生产代码新增或修改必须包含详细中文注释。

## Non-goals

- 不接 signed endpoint。
- 不接 account endpoint / listenKey。
- 不连接 broker。
- 不实现 `LiveExecutionAdapter`。
- 不实现 OMS / real order lifecycle。
- 不实现真实 submit / cancel / replace。
- 不实现 execution report / broker fill / reconciliation。
- 不实现 Live PRO Console / trading button / live command。
- 不把 `PaperOrder*Local` / `PaperOrder*Simulated` 事件解释成真实订单状态。
- 不把 paper account / paper portfolio projection 解释成真实账户或 broker position。
- 不把本 planning record 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 TradingClock 和 paper runtime kernel boundary | 建立 paper-only TradingClock 与 runtime kernel boundary，明确 paper runtime 的时间、session、command intake、event emission 和 replay 不变量。 | 无 |
| 2 | 新增 CommandBus / EventBus / MessageBus deterministic routing | 建立 paper runtime 内部 deterministic routing，使 command、event、message 的流向可测试、可 replay、可追踪。 | 依赖 Issue 1 |
| 3 | 新增 Paper Pre-trade RiskEngine runtime path | 对 paper action proposal 产生 accepted / rejected paper risk decision，并写入可 replay 的 event evidence。 | 依赖 Issue 1、Issue 2 |
| 4 | 新增 paper-only lifecycle coordinator 和 local order lifecycle | 管理 `PaperOrder*Local` / `PaperOrder*Simulated` 状态转换，并确保所有 transition 写入 Event Log。 | 依赖 Issue 1、Issue 2、Issue 3 |
| 5 | 新增 simulated fill / fee / slippage deterministic model | 建立 paper-only simulated fill、fee 和 slippage deterministic model，避免 paper / backtest 结果出现零摩擦幻觉。 | 依赖 Issue 4 |
| 6 | 新增 paper account / portfolio / position projection v2 | 从 replayed simulated fill、fee 和 slippage evidence 推导 paper account、paper portfolio、paper position、paper exposure 和 paper PnL projection。 | 依赖 Issue 5 |
| 7 | 串联 Event Log / Replay / Report / Dashboard evidence 并收口阶段验证材料 | 将 runtime evidence 串成 Event Log / Replay / Report / Dashboard / Event Timeline 闭环，并准备 stage audit input material。 | 依赖 Issue 2、Issue 3、Issue 4、Issue 5、Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Candidate issue summaries

| Issue | Scope 摘要 | Non-goals / Boundary 摘要 | Validation 摘要 |
| --- | --- | --- | --- |
| Issue 1 | TradingClock deterministic 时间来源和 replay 语义；paper runtime kernel 输入、输出、生命周期、模块边界；validation anchor 和 fixture 入口。 | 不实现 live runtime、signed/account/listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、真实 submit / cancel / replace、Live PRO Console、trading button 或 live command。 | `bash checks/run.sh`；验证 TradingClock / kernel fixture deterministic，kernel boundary 不暴露 UI state 或 persistence schema。 |
| Issue 2 | paper-only CommandBus / EventBus / MessageBus routing contract；paper session command、paper risk decision、paper lifecycle event、simulated fill event 的 deterministic route；source / correlation / causation 或等价追踪字段。 | 不实现 live command bus、order-level real command、broker / exchange execution adapter、signed request routing、execution report / broker fill / reconciliation。 | `bash checks/run.sh`；验证 routing 顺序 deterministic，replay 后 route evidence 可复现，且无 live command、broker action、signed/account/listenKey。 |
| Issue 3 | Paper Pre-trade RiskEngine 输入为 paper proposal、paper account snapshot、paper exposure、paper risk rules；输出 accepted / rejected paper risk decision；记录 blocker reason、source anchor 和 deterministic fixture evidence。 | 不实现 live risk engine，不读取真实账户余额、broker position、margin、leverage，不实现 real pre-trade allow / reject、circuit breaker command、stop trading command、emergency stop、live command UI 或交易按钮。 | `bash checks/run.sh`；验证 accepted / rejected paper risk decision deterministic，rejected decision 进入 Event Log / Replay，且无真实账户、broker position、margin、leverage、live risk runtime。 |
| Issue 4 | paper lifecycle coordinator；local lifecycle：proposed、submitted local、accepted local、rejected by paper risk、cancelled local、expired local、failed local；串接 simulated fill 前置状态；`cancelled locally` 只来自 session close / reset、local expiry 或 deterministic local rule。 | 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report / broker fill / reconciliation、单笔 order cancel button 或 order-level command UI。 | `bash checks/run.sh`；验证 lifecycle transition deterministic，每个 transition 有 event fact，且无 OMS、broker adapter、real order state machine、real cancel command。 |
| Issue 5 | simulated fill model 输入为 market snapshot、paper order、fill assumptions；定义 fee assumption、slippage assumption、fill price assumption、cost impact；支持 partial / full simulated fill evidence；写入 Event Log。 | 不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation、broker / signed endpoint / account endpoint。 | `bash checks/run.sh`；验证 simulated fill / fee / slippage fixture deterministic，partial / full fill evidence 可 replay，且无 broker fill、execution report、reconciliation、real account update。 |
| Issue 6 | paper account model、paper portfolio / position projection v2；从 replayed simulated fill 推导 exposure、position、PnL summary；输出 Report / Dashboard / Risk / Portfolio 可消费的 Read Model。 | 不读取真实账户余额，不同步 broker position，不实现 margin / leverage / real PnL、live risk runtime，不把 paper projection 升级为 real account state。 | `bash checks/run.sh`；验证 replay -> projection deterministic，snapshot 稳定，且无 real account balance、broker position、margin、leverage、broker state。 |
| Issue 7 | 串联 append-only Event Log、Replay、Projection、Read Model、ViewModel；Report 展示 paper runtime summary、risk decision、simulated fill、fee / slippage、portfolio impact；Dashboard / Workbench 展示业务摘要和 drill-down entry；Events / Audit 展示完整 event sequence；收口 validation matrix、automation readiness anchors 和 stage audit input material。 | 不输出最终 Stage Code Audit Report，不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`，不实现 Live PRO Console、live command、trading button、signed/account/listenKey 或 broker。 | `bash checks/run.sh`；验证 Event Log -> Replay -> Projection -> Report / Dashboard evidence deterministic，Dashboard smoke 包含 paper runtime evidence，readiness anchors 覆盖 Project 边界。 |

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 1、Issue 2。
- Issue 4 依赖 Issue 1、Issue 2、Issue 3。
- Issue 5 依赖 Issue 4。
- Issue 6 依赖 Issue 5。
- Issue 7 依赖 Issue 2、Issue 3、Issue 4、Issue 5、Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Event-Driven Paper Trading Runtime 相关验证必须满足：

- 必须使用 deterministic fixture / replay evidence，不依赖真实 Binance 网络。
- 必须验证 no signed endpoint / account endpoint / listenKey。
- 必须验证 no broker / exchange execution adapter。
- 必须验证 no `LiveExecutionAdapter`。
- 必须验证 no OMS / real order lifecycle。
- 必须验证 no real submit / cancel / replace。
- 必须验证 no execution report / broker fill / reconciliation。
- 必须验证 no Live PRO Console / trading button / live command。
- 必须验证 UI / Dashboard 只消费 Read Model / ViewModel，不读取 Runtime object、Adapter object、SQLite / DuckDB schema 或 broker object。
- PR 必须包含 MTPRO-native PR evidence fields：`Feedback Loop Evidence`、`Tracer Bullet / Fixture Evidence`、`Diagnose Evidence`、`Architecture Deepening Candidate`。
- 新增或修改生产代码必须包含详细中文注释。

## Evidence requirements

每个 PR 必须包含：

- Linked Linear Issue。
- Scope / Non-goals 确认。
- validation output。
- boundary evidence。
- Pre-PR Codex Code Review。
- GitHub PR Automation evidence。
- MTPRO-native PR evidence fields。
- `.codex/*` 未进入 PR。
- `graphify-out/*` 未进入 PR。
- 如由 symphony-issue 执行，需 handoff marker evidence。

Issue 7 只准备 stage audit input material，不输出最终 Stage Code Audit Report。

Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 TradingClock 和 paper runtime kernel boundary
```

该 issue 只是 first executable issue candidate，初始状态仍必须是 `Backlog / non-executable`，不授权执行，不推进 Todo。

Project 经 Human 确认并写入 Linear 后，由 Parent Codex queue preflight 在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时自动判断唯一 eligible issue，并推进 Todo。

## WIP=1 / queue preflight rule

- Project 执行必须保持 WIP=1。
- 所有 issue 初始状态必须是 `Backlog / non-executable`。
- Linear 写入后不得自动进入执行。
- Parent Codex queue preflight 负责判断唯一 eligible issue。
- Parent Codex queue preflight 必须确认 WIP=1、依赖满足、previous issue Done、execution contract 格式完整，并且当前 Project 没有 `Todo` / `In Progress` / `In Review` active conflict。
- symphony-issue 只允许调度唯一 Todo issue。
- 本 planning record 不授权执行。

## Linear write boundary

- 本 draft 不创建 Linear Project。
- 本 draft 不创建 Linear Issues。
- 本 draft 不修改 Linear status。
- 本 draft 不推进 Todo。
- Human review / merge 后，才允许进入 Linear 写入。
- Project 写入 Linear 后，所有 issue 初始必须是 `Backlog / non-executable`。
- 后续完整 execution contract 以 Linear issue body 为准。
- Project 写入 Linear 后，由 Parent Codex queue preflight 判断唯一 eligible issue。

## Repository record boundary

- 仓库 planning record 只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 Linear issue body。
- 仓库不复制维护完整 candidate issue 正文。
- 后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。
- Planning record 不授权执行。

## Parent Codex queue preflight rule

- `@001 / PLN` 只负责 Project-level planning record 和 Linear 写入前草案。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 写入 Linear 后，由 Parent Codex queue preflight 判断唯一 eligible issue，并推进 Todo。
- 本 planning record 不启动 `@002 / PAR`。
- symphony-issue 只能在唯一 `Todo` issue 存在后调度。
