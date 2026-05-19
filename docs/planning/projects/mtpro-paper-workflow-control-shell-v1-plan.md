# MTPRO Paper Workflow Control Shell v1

日期：2026-05-20

执行者：Codex

本文档是 `MTPRO Paper Workflow Control Shell v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不写业务代码。

完整 issue execution contract 以后以 Linear issue body 为准。

## Project name

`MTPRO Paper Workflow Control Shell v1`

## Project goal

在已完成的 paper-only execution evidence 基础上，建立 Paper workflow 的 Workbench 可观察性和 session-level 本地控制壳，让用户可以在现有 Dashboard / Workbench shell 中观察 paper session、proposal、risk decision、paper order、simulated fill、portfolio projection、replay freshness、report artifact status 和 read-model-only event timeline，并且只能触发 paper-only session-level local control：`start` / `pause` / `close` / `reset`。

本 Project 不进入 Live trading，不接 signed endpoint，不连接 broker，不提供 order-level command。

## Scope

- 定义 Paper workflow Workbench information architecture。
- 新增 session-level local control shell：`start` / `pause` / `close` / `reset`。
- 定义 paper-only command boundary 和 Command Model。
- 扩展 Dashboard / Workbench ViewModel / Read Model / Command Model。
- 展示 paper execution chain observability。
- 展示 blocked / allowed evidence。
- 展示 replay freshness。
- 展示 report artifact status。
- 纳入 read-model-only Event Timeline / Evidence Explorer 子集。
- 增加 deterministic validation、Dashboard smoke 和 automation readiness anchor。

## Non-goals

- 不做 Live trading。
- 不接 Binance signed endpoint。
- 不接 account endpoint / listenKey。
- 不连接 broker。
- 不提交 / 撤销 / 替换真实订单。
- 不实现 OMS。
- 不做 real account balance / broker position sync。
- 不做完整 UI redesign。
- 不做 deployment / production operations。
- 不允许 order-level command。
- 不把 planning record 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 Paper workflow Workbench information architecture 和控制壳边界 | 定义 Paper workflow 信息架构、观察面、session-level control shell 边界和 forbidden capability 分界。 | 无 |
| 2 | 新增 session-level Paper local control Command Model | 新增 paper-only session-level local control Command Model，只支持 `start` / `pause` / `close` / `reset`。 | 依赖 Issue 1 |
| 3 | 串联 session-level control -> paper-only event boundary | 将 session-level local control command 串到 paper-only event boundary，生成本地 paper session facts。 | 依赖 Issue 2 |
| 4 | 扩展 Paper workflow observability Read Model / ViewModel | 扩展 Paper workflow read model / ViewModel，展示 session status、chain coverage、blocked / allowed evidence、replay freshness 和 report artifact status。 | 依赖 Issue 3 |
| 5 | 新增 read-model-only Event Timeline / Evidence Explorer 子集 | 新增 Event Timeline / Evidence Explorer 的 read-model-only 子集，展示 paper workflow evidence links。 | 依赖 Issue 4 |
| 6 | 增量扩展 Dashboard / Workbench shell 并保持 read-model-only | 在现有 Dashboard / Workbench shell 上增量呈现 control shell、observability read model 和 Event Timeline 子集。 | 依赖 Issue 4、Issue 5 |
| 7 | 加固 deterministic validation、Dashboard smoke 和 automation readiness evidence | 收口 validation docs、Dashboard smoke、automation readiness anchor、known boundaries 和 Stage Code Audit input。 | 依赖 Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 2。
- Issue 4 依赖 Issue 3。
- Issue 5 依赖 Issue 4。
- Issue 6 依赖 Issue 4、Issue 5。
- Issue 7 依赖 Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Paper workflow control shell 相关验证必须满足：

- 自动测试必须 deterministic。
- Session-level local control 只能覆盖 `start` / `pause` / `close` / `reset`。
- 必须验证不允许 order-level command。
- 必须验证不触碰 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。
- UI / Dashboard 必须只消费 ViewModel / Read Model / Command Model。
- Event Timeline / Evidence Explorer 必须保持 read-model-only，不暴露 SQLite / DuckDB schema、adapter request 或 runtime object。
- 必须保留 Dashboard smoke。
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
- Session-level control PR 必须记录 no order-level command / no real trading boundary evidence。

Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 Paper workflow Workbench information architecture 和控制壳边界
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
