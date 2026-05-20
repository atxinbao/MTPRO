# MTPRO Live Trading Boundary Definition v1

日期：2026-05-20

执行者：Codex

本文档是 `MTPRO Live Trading Boundary Definition v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不写业务代码。

完整 issue execution contract 以后以 Linear issue body 为准。

## Project name

`MTPRO Live Trading Boundary Definition v1`

## Project goal

定义 MTPRO 进入实盘交易基础边界前必须具备的 gate、contract、blocked evidence 和 forbidden capability tests，使 Live trading foundation 可以被清楚表达、验证和展示，但不实现任何真实 API key、signed endpoint、account endpoint、broker adapter、真实订单或 LiveExecutionAdapter。

## Scope

- Live trading foundation capability taxonomy。
- API key / secret / signed endpoint / account endpoint / listenKey 的 future gate 和禁止边界。
- Public read-only adapter 与 future live adapter capability 的隔离合同。
- Real order lifecycle 术语、future gate 和 forbidden capability tests。
- 最小 `LiveReadiness` / `LiveBlockedEvidence` read model。
- Dashboard / Report / Event Timeline 的 read-model-only blocked evidence 展示。
- Validation matrix 和 automation readiness anchor。
- Stage Audit input material。

## Non-goals

- 不使用真实 API key。
- 不做 secret 存储。
- 不实现 signed endpoint。
- 不实现 account endpoint。
- 不实现 listenKey user data stream。
- 不连接 broker / exchange execution adapter。
- 不提交、撤销、替换真实订单。
- 不实现 OMS。
- 不实现 LiveExecutionAdapter。
- 不实现 real order state machine。
- 不做实盘监控台。
- 不做实盘执行控制。
- 不做实盘风险控制。
- 不做实盘审计 / 事故回放 / 停机控制。
- 不提供 live command。
- 不新增交易按钮。
- 不把 planning record 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 Live trading foundation capability taxonomy 和 gate | 定义 Live trading foundation 的能力分类、gate 顺序和当前禁止边界。 | 无 |
| 2 | 定义 API key / signed endpoint / account endpoint / listenKey 禁止边界 | 定义真实 API key、secret、signed endpoint、account endpoint 和 listenKey user data stream 的禁止边界与 future gate。 | 依赖 Issue 1 |
| 3 | 定义 public read-only adapter 与 future live adapter capability 隔离合同 | 定义当前 Binance public read-only adapter 与 future live adapter capability 的隔离合同。 | 依赖 Issue 1、Issue 2 |
| 4 | 定义 real order lifecycle 术语、future gate 和 forbidden capability tests | 定义 real order lifecycle 的术语、future gate 和 forbidden capability tests，保持 paper / real order 隔离。 | 依赖 Issue 1、Issue 2、Issue 3 |
| 5 | 新增最小 LiveReadiness / LiveBlockedEvidence read model | 新增 read-model-only 的 Live readiness / blocked evidence，表达当前 Live gates 的 blocked 状态。 | 依赖 Issue 1、Issue 2、Issue 3、Issue 4 |
| 6 | 接入 Dashboard / Report / Event Timeline read-model-only Live blocked evidence | 将 Live blocked evidence 接入 Dashboard / Report / Event Timeline 的 read-model-only 展示。 | 依赖 Issue 5 |
| 7 | 收口 validation matrix、automation readiness 和 stage audit input material | 收口 validation matrix、automation readiness anchor、known boundaries、Dashboard smoke evidence 和 Stage Code Audit input material。 | 依赖 Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 1、Issue 2。
- Issue 4 依赖 Issue 1、Issue 2、Issue 3。
- Issue 5 依赖 Issue 1、Issue 2、Issue 3、Issue 4。
- Issue 6 依赖 Issue 5。
- Issue 7 依赖 Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Live trading boundary definition 相关验证必须满足：

- 自动测试必须 deterministic。
- 必须验证没有真实 API key、secret 存储、signed endpoint、account endpoint、listenKey 代码。
- 必须验证没有 broker / exchange execution adapter 连接。
- 必须验证没有真实订单 submit / cancel / replace。
- 必须验证没有 OMS、LiveExecutionAdapter 或 real order state machine。
- `LiveReadiness` / `LiveBlockedEvidence` 必须保持 read-model-only。
- Dashboard / Report / Event Timeline 只能展示 blocked evidence，不得提供 live command 或交易按钮。
- Real order lifecycle 只能作为术语、future gate 和 forbidden capability tests 出现。
- 必须增加或更新 automation readiness anchor。
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
- Live boundary PR 必须记录 no API key、no secret storage、no signed endpoint、no account endpoint、no listenKey、no broker、no real order、no LiveExecutionAdapter boundary evidence。

Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 Live trading foundation capability taxonomy 和 gate
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
- 本 planning record 不启动 `@002 / PAR`。
- symphony-issue 只能在唯一 `Todo` issue 存在后调度。
