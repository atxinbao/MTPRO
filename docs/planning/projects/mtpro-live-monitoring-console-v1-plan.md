# MTPRO Live Monitoring Console v1

日期：2026-05-21

执行者：Codex

本文档是 `MTPRO Live Monitoring Console v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不写业务代码。

完整 issue execution contract 以后以 Linear issue body 为准。

## Project name

`MTPRO Live Monitoring Console v1`

## Project goal

承接 Final Product Goal Slice #6：实盘监控台。

在不实现真实 Live trading 的前提下，建立 read-model-only 的 Live monitoring console 基础，让 Dashboard / Report / Event Timeline 能展示 live runtime health、connection、market stream、order stream / order flow、error、latency、operations evidence 和 blocked / future evidence。

## Scope

- 定义 Live monitoring console 的信息架构和监控语义。
- 新增最小 live runtime health / connection / stream / latency / error read model。
- 定义 market stream 与 order stream / order flow 的 read-model-only 边界。
- 订单流 / 订单事件流，仅表示 blocked / simulated / future evidence，不表示真实订单状态机。
- 接入 Dashboard / Report / Event Timeline 的 live monitoring evidence 区块。
- 保持 UI 只消费 ViewModel / Read Model。
- 增加 deterministic fixtures、snapshot tests、Dashboard smoke 和 automation readiness anchor。
- 收口 validation evidence 和 Stage Audit input material。

## Non-goals

- 不接 signed endpoint。
- 不接 account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不提交、撤销、替换真实订单。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine。
- 不实现 OMS。
- 不提供 live command。
- 不新增交易按钮。
- 不实现实盘执行控制、实盘风险控制、实盘审计 / 停机控制。
- 不处理 Figma / Stitch。
- 不做完整 UI redesign。
- 不新增完整实盘监控台页面重设计。
- 不把 planning record 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 Live monitoring console information architecture 和 read-model-only 边界 | 定义信息架构、监控对象、状态分类和 read-model-only 边界；只定义 validation anchor 名称 / 入口，不实际修改 automation-readiness。 | 无 |
| 2 | 新增 live runtime health / connection status 最小 read model | 用只读方式表达 future live runtime 的 health、connection、blocked / disconnected / unavailable 状态。 | 依赖 Issue 1 |
| 3 | 新增 market stream / order stream blocked evidence read model | 定义 market stream 与 order stream / order flow blocked evidence；订单流 / 订单事件流，仅表示 blocked / simulated / future evidence，不表示真实订单状态机。 | 依赖 Issue 1、Issue 2 |
| 4 | 新增 latency / error / degraded state monitoring evidence | 新增 latency、error、degraded state 的 monitoring evidence read model。 | 依赖 Issue 1、Issue 2 |
| 5 | 接入 Dashboard / Report live monitoring evidence 区块 | 将 live monitoring evidence 接入 Dashboard / Report 的 read-model-only 展示面。 | 依赖 Issue 2、Issue 3、Issue 4 |
| 6 | 接入 Event Timeline live monitoring evidence preview | 将 live monitoring evidence 接入 Event Timeline 的只读 preview。 | 依赖 Issue 3、Issue 4、Issue 5 |
| 7 | 收口 validation matrix、automation readiness 和 stage audit input material | 收口 validation matrix、automation readiness anchor、Dashboard smoke evidence、read-model-only boundary evidence 和 Stage Audit input material。 | 依赖 Issue 5、Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 1、Issue 2。
- Issue 4 依赖 Issue 1、Issue 2。
- Issue 5 依赖 Issue 2、Issue 3、Issue 4。
- Issue 6 依赖 Issue 3、Issue 4、Issue 5。
- Issue 7 依赖 Issue 5、Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Live monitoring console 相关验证必须满足：

- 必须保持 Dashboard build / Dashboard smoke 通过。
- 必须验证 Dashboard / Report / Event Timeline 只消费 ViewModel / Read Model。
- 必须验证没有 live command、交易按钮、order-level command、risk command 或 position command。
- 必须验证没有 signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、real order state machine。
- 必须验证订单流 / 订单事件流仅表示 blocked / simulated / future evidence，不表示真实订单状态机。
- 必须验证 required validation 不依赖真实 Binance 网络、真实 API key、真实账户或 broker state。
- PR 必须包含 MTPRO-native PR evidence fields：`Feedback Loop Evidence`、`Tracer Bullet / Fixture Evidence`、`Diagnose Evidence`、`Architecture Deepening Candidate`。
- Issue 1 只定义 validation anchor 名称 / 入口，不实际修改 automation-readiness；automation readiness 实际收口放到 Issue 7。
- Issue 7 必须增加或更新 automation readiness anchor。
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
- Live monitoring PR 必须记录 read-model-only、no signed endpoint、no account endpoint、no listenKey、no broker、no real order、no LiveExecutionAdapter、no live command、no trading button boundary evidence。

Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 Live monitoring console information architecture 和 read-model-only 边界
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
