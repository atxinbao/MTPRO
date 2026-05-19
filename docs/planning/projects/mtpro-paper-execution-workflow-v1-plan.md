# MTPRO Paper Execution Workflow v1

日期：2026-05-19

执行者：Codex

本文档是 `MTPRO Paper Execution Workflow v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 Symphony，不运行 Graphify update，不写业务代码。

完整 issue execution contract 以后以 Linear issue body 为准。

## Project name

`MTPRO Paper Execution Workflow v1`

## Project goal

建立 paper-only execution workflow 的阶段最小闭环，让现有 Paper Session lifecycle、Paper action proposal、risk blocker、paper-only portfolio projection、append-only event log、replay 和 Report / Dashboard read model 串成可验证的本地 paper execution evidence chain。

本 Project 只实现本地 paper-only execution 语义，不进入 Live trading、signed endpoint、broker action、真实订单或完整 OMS。

## Scope

- 定义 paper-only execution workflow 的领域边界。
- 新增 paper order intent / paper order lifecycle / simulated fill evidence 的最小模型。
- 将已存在的 Paper action proposal 和 risk blocker 接入本地 paper execution decision。
- 将 allowed paper execution decision 写入 append-only event log。
- 将 paper order / simulated fill / portfolio projection 串入 deterministic replay。
- 将 paper execution evidence 汇总到 Report / Dashboard read model。
- 加固 validation matrix、automation readiness anchor 和阶段审计输入。

## Non-goals

- 不实现 `LiveExecutionAdapter`。
- 不调用 Binance signed endpoint、account endpoint 或 listenKey user data stream。
- 不连接 broker。
- 不提交、撤销或替换真实订单。
- 不实现完整 OMS。
- 不实现真实撮合、真实成交回报或 broker rejection fallback。
- 不实现保证金、杠杆、真实账户余额或 broker position sync。
- 不做 UI 大改版。
- 不把 planning record 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 paper-only execution workflow contract 和事件边界 | 定义本地 paper-only execution workflow 的领域合同、事件边界和禁止触碰的真实交易能力。 | 无 |
| 2 | 新增 paper order intent / lifecycle 最小模型和夹具 | 新增 paper-only order intent 和 lifecycle 最小模型，使 workflow 可表达本地 paper order 状态。 | 依赖 Issue 1 |
| 3 | 新增 simulated fill evidence 最小模型和 deterministic fixture | 新增本地 simulated fill evidence 与 deterministic fixture，表达模拟成交证据但不代表真实成交。 | 依赖 Issue 2 |
| 4 | 串联 proposal -> risk decision -> paper execution decision | 将 proposal、risk decision、paper order intent 和 simulated fill assumption 串成本地 decision 链路。 | 依赖 Issue 1、Issue 2、Issue 3 |
| 5 | 串联 paper execution events -> event log -> replay -> portfolio projection | 将 paper execution events 接入 append-only event log、deterministic replay 和 paper-only portfolio projection。 | 依赖 Issue 4 |
| 6 | 汇总 paper execution evidence 到 Report / Dashboard read model | 将 paper execution workflow、order lifecycle、simulated fill、replay 和 projection evidence 汇总到 read model。 | 依赖 Issue 5 |
| 7 | 加固 validation docs、automation evidence 和阶段审计输入 | 收口 validation docs、automation evidence、known boundaries 和 Stage Code Audit input。 | 依赖 Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 2。
- Issue 4 依赖 Issue 1、Issue 2、Issue 3。
- Issue 5 依赖 Issue 4。
- Issue 6 依赖 Issue 5。
- Issue 7 依赖 Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Paper execution workflow 相关验证必须满足：

- 自动测试必须 deterministic，不依赖真实 broker、真实账户、真实订单或 Binance signed endpoint。
- 涉及 paper execution / order / fill / portfolio 的 issue 必须验证 paper-only 边界。
- 涉及 replay 的 issue 必须验证 append-only event log 顺序、乱序拒绝或等价不变量。
- 涉及 UI / Report 的 issue 必须验证 UI 只消费 ViewModel / Read Model，不暴露 SQLite / DuckDB schema 或 adapter object。
- 涉及 production code 时必须包含详细中文注释。

## Evidence requirements

每个 PR 必须包含：

- Linked Linear Issue。
- Scope / Non-goals 确认。
- `bash checks/run.sh` 摘要。
- Pre-PR Codex Code Review。
- GitHub PR Automation evidence。
- `.codex/*` 未进入 PR。
- `graphify-out/*` 未进入 PR。
- 如由 symphony-issue 执行，需 handoff marker evidence。
- Paper-only / no-live-trading / no-real-order boundary evidence。

Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 paper-only execution workflow contract 和事件边界
```

该 issue 只是 first executable candidate，初始状态仍必须是 `Backlog / non-executable`，不授权执行，不推进 Todo。

Project 经 Human 确认并写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。

## WIP=1

- 所有 issue 初始状态必须是 `Backlog / non-executable`。
- 当前 Todo：none。
- 同一时间最多一个 issue 可进入 Todo。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 经 Human 确认并写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并推进 Todo。
- symphony-issue 只调度唯一 `Todo` issue。
- 本文档不授权执行。

## Linear write boundary

- 本 draft 不创建 Linear Project。
- 本 draft 不创建 Linear Issues。
- 本 draft 不修改 Linear status。
- 本 draft 不推进任何 issue 到 Todo。
- 本 planning record 不创建 Linear Project。
- 本 planning record 不创建 Linear Issues。
- 本 planning record 不修改 Linear status。
- Human review / merge 后，才允许进入 Linear 写入。
- Project 写入 Linear 后，所有 issue 初始必须是 `Backlog / non-executable`。
- 完整 issue execution contract 以后以 Linear issue body 为准。
- Project 经 Human 确认并写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。

## Repository record boundary

- 仓库只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 issue 正文。
- 仓库不复制维护完整 Linear issue body。
- 后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。
- Project-level planning record 可落仓，但不复制维护完整 Linear issue body。
- Planning record 不授权执行。

## Parent Codex queue preflight rule

- `@001 / PLN` 只负责 Project-level planning record 和 Linear 写入前草案。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 经 Human 确认并写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并推进 Todo。
- Parent Codex queue preflight 必须确认 WIP=1、依赖满足、previous issue Done、execution contract 格式完整，并且当前 Project 没有 `Todo` / `In Progress` / `In Review` active conflict。
- symphony-issue 只能在唯一 `Todo` issue 存在后调度。
