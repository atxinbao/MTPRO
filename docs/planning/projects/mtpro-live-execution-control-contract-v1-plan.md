# MTPRO Live Execution Control Contract v1

日期：2026-05-22

执行者：Codex

本文档是 `MTPRO Live Execution Control Contract v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不写业务代码，不修改 Figma。

完整 issue execution contract 以后以 Linear issue body 为准。

## Project name

`MTPRO Live Execution Control Contract v1`

## Project goal

承接 Final Product Goal Slice #7：实盘执行控制。

本阶段只定义 Future Live Execution 的 execution-control contract / boundary，包括 real order command taxonomy、future gates、forbidden capability tests、paper / real execution 隔离和 read-model-only blocked evidence；不实现任何真实执行能力。

## Scope

- 定义 execution-control terminology。
- 定义 real order command taxonomy：submit / cancel / replace / execution report / reconciliation / incident fallback。
- 定义 Future Live Execution gates。
- 定义 forbidden capability tests。
- 定义 paper order intent / simulated fill 与 future real order command 的隔离。
- 新增 read-model-only 的 `LiveExecutionControlBlockedEvidence` 或等价模型。
- Dashboard / Report / Event Timeline 可展示 execution-control blocked evidence，但只能 read-model-only。
- 收口 validation matrix、automation readiness 和 stage audit input material。

## Non-goals

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不实现 broker fill、execution report、reconciliation。
- 不新增交易按钮、order form、live command 或 order-level command UI。
- 不实现 Live Risk。
- 不实现 Incident Replay / Stop Controls。
- 不把 planning draft 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 Live execution control terminology 和 real order command taxonomy | 定义 Future Live Execution 的 execution-control terminology 和 real order command taxonomy。 | 无 |
| 2 | 定义 submit / cancel / replace future gates 和 forbidden capability tests | 定义 submit / cancel / replace 的 future gates 和 forbidden capability tests，确保当前系统不能提交、撤销或替换真实订单。 | 依赖 Issue 1 |
| 3 | 定义 execution report / broker fill / reconciliation future gates 和 forbidden capability tests | 定义 execution report、broker fill 和 reconciliation 的 future gates 与 forbidden capability tests。 | 依赖 Issue 1、Issue 2 |
| 4 | 定义 paper order intent / simulated fill 与 future real order command 隔离合同 | 定义 paper order intent、paper execution decision、simulated fill、paper portfolio projection 与 future real order command 的隔离合同。 | 依赖 Issue 1、Issue 2、Issue 3 |
| 5 | 新增 read-model-only LiveExecutionControlBlockedEvidence | 新增 read-model-only 的 `LiveExecutionControlBlockedEvidence` 或等价模型，用只读方式表达 execution-control gates 为什么仍被阻断。 | 依赖 Issue 2、Issue 3、Issue 4 |
| 6 | 接入 Dashboard / Report / Event Timeline execution-control blocked evidence | 将 execution-control blocked evidence 接入 Dashboard / Report / Event Timeline 的 read-model-only 展示面。 | 依赖 Issue 5 |
| 7 | 收口 validation matrix、automation readiness 和 stage audit input material | 收口 validation matrix、automation readiness anchor、Dashboard smoke evidence、forbidden capability evidence、read-model-only boundary evidence 和 Stage Audit input material。 | 依赖 Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 1、Issue 2。
- Issue 4 依赖 Issue 1、Issue 2、Issue 3。
- Issue 5 依赖 Issue 2、Issue 3、Issue 4。
- Issue 6 依赖 Issue 5。
- Issue 7 依赖 Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Live execution control contract 相关验证必须满足：

- 必须验证没有 API key / secret storage。
- 必须验证没有 signed endpoint / account endpoint / listenKey。
- 必须验证没有 broker / exchange execution adapter。
- 必须验证没有 `LiveExecutionAdapter`。
- 必须验证没有 real order state machine / OMS。
- 必须验证没有真实 submit / cancel / replace。
- 必须验证没有 broker fill / execution report / reconciliation implementation。
- 必须验证没有交易按钮、order form、live command 或 order-level command UI。
- 必须验证 paper order intent / simulated fill 不能升级为 future real order command。
- 必须验证 Dashboard / Report / Event Timeline 只消费 ViewModel / Read Model。
- 必须验证 `LiveExecutionControlBlockedEvidence` 或等价模型保持 read-model-only。
- 必须包含 deterministic fixtures / forbidden capability tests。
- PR 必须包含 MTPRO-native PR evidence fields：`Feedback Loop Evidence`、`Tracer Bullet / Fixture Evidence`、`Diagnose Evidence`、`Architecture Deepening Candidate`。
- 涉及 production code 时必须包含详细中文注释。

## Evidence requirements

每个 PR 必须包含：

- Linked Linear Issue。
- Scope / Non-goals 确认。
- `bash checks/run.sh` 摘要。
- Pre-PR Codex Code Review。
- GitHub PR Automation evidence。
- MTPRO-native PR evidence fields。
- `.codex/*` 未进入 PR。
- `graphify-out/*` 未进入 PR。
- 如由 symphony-issue 执行，需 handoff marker evidence。
- Live execution control PR 必须记录 no API key、no signed endpoint、no account endpoint、no listenKey、no broker、no `LiveExecutionAdapter`、no real order state machine、no OMS、no submit / cancel / replace、no trading button / command boundary evidence。

Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 Live execution control terminology 和 real order command taxonomy
```

该 issue 只是 first executable issue candidate，初始状态仍必须是 `Backlog / non-executable`，不授权执行，不推进 Todo。

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
- 本 planning record 不启动 `@002 / PAR`。
- symphony-issue 只能在唯一 `Todo` issue 存在后调度。
