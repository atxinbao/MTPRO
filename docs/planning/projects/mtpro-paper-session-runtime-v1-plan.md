# MTPRO Paper Session Runtime v1

日期：2026-05-19

执行者：Codex

本文档是 `MTPRO Paper Session Runtime v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 Symphony，不运行 Graphify update，不写业务代码。

完整 issue execution contract 以 Linear issue body 为准。

## Project name

`MTPRO Paper Session Runtime v1`

## Project goal

在已完成的 Trading Validation evidence 基础上，建立 paper-only session runtime 最小闭环，让 MTPRO 可以从 strategy signal 进入 paper action proposal、risk blocker、paper-only portfolio projection、replay 和 report evidence。

本 Project 只做本地 Paper readiness runtime，不进入 Live trading。

## Scope

- 定义 Paper Session lifecycle 和 event boundary。
- 串联 strategy signal -> paper action proposal -> risk blocker -> paper-only portfolio projection。
- 复用 deterministic execution cost evidence。
- 将 paper session events 写入 append-only event log，并支持 replay。
- 将 paper session runtime evidence 汇入 Report / Dashboard read model。
- 固化 validation matrix、automation evidence 和阶段审计输入。

## Non-goals

- 不实现 `LiveExecutionAdapter`。
- 不接 signed endpoint / account endpoint。
- 不连接 broker。
- 不提交、取消或替换真实订单。
- 不实现完整 execution engine。
- 不做 margin / leverage / real account balance。
- 不做完整 order management system。
- 不做 UI 大改版。
- 不把 planning record 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 Paper Session lifecycle 和事件边界 | 定义 paper-only session 生命周期、事件类型和 event log 写入边界。 | 无 |
| 2 | 新增 Paper action proposal 最小模型和验证夹具 | 建立 strategy signal 到 paper-only action intent 的最小 proposal 模型和 deterministic fixture。 | 依赖 Issue 1 |
| 3 | 串联 strategy signal -> paper action proposal -> risk blocker | 将 signal、proposal 和 risk blocker evidence 串成本地链路，覆盖允许 / 阻断证据。 | 依赖 Issue 1、Issue 2 |
| 4 | 新增 paper-only portfolio projection update path | 基于 paper proposal 和 risk result 更新 paper-only portfolio exposure projection。 | 依赖 Issue 3 |
| 5 | 新增 Paper Session replay 和 deterministic evidence | 从 append-only event log replay session / proposal / risk / projection events，得到确定性证据。 | 依赖 Issue 3、Issue 4 |
| 6 | 汇总 Paper Session runtime evidence 到 Report / Dashboard read model | 将 lifecycle、proposal、risk blocker、portfolio exposure 和 replay evidence 汇入 read model。 | 依赖 Issue 5 |
| 7 | 加固 validation docs、automation evidence 和阶段审计输入 | 收口 validation docs、automation evidence、known boundaries 和 Stage Code Audit input。 | 依赖 Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 1、Issue 2。
- Issue 4 依赖 Issue 3。
- Issue 5 依赖 Issue 3、Issue 4。
- Issue 6 依赖 Issue 5。
- Issue 7 依赖 Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Paper runtime 相关验证必须满足：

- 使用 deterministic fixtures / local replay。
- 自动测试不得依赖真实 Binance 网络、signed endpoint、account endpoint 或 broker。
- 证明 Paper Session 不触碰 Live trading / real order behavior。
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
- Paper-only / no-live-trading boundary evidence。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 Paper Session lifecycle 和事件边界
```

该 issue 只是 first executable candidate，初始状态仍必须是 `Backlog / non-executable`，不授权执行，不推进 Todo。

Project 经 Human 确认并写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并推进 Todo。

## WIP=1

- 所有 issue 初始状态必须是 `Backlog / non-executable`。
- 当前 Todo：none。
- 同一时间最多一个 issue 可进入 Todo。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 经 Human 确认并写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并推进 Todo。
- symphony-issue 只调度唯一 `Todo` issue。
- 本文档不授权执行。

## Linear write boundary

- 本 planning record 不创建 Linear Project。
- 本 planning record 不创建 Linear Issues。
- 本 planning record 不修改 Linear status。
- Human review / merge 后，才允许进入 Linear 写入。
- Linear 写入后，所有 issue 初始必须保持 `Backlog / non-executable`。
- 完整 issue execution contract 以 Linear issue body 为准。
- Project 经 Human 确认并写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并推进 Todo。

## Repository record boundary

- 仓库只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 issue 正文。
- 后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。
- Project-level planning record 可落仓，但不复制维护完整 Linear issue body。
- Planning record 不授权执行。

## Parent Codex queue preflight rule

- `@001 / PLN` 只负责 Project-level planning record 和 Linear 写入前草案。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 经 Human 确认并写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并推进 Todo。
- Parent Codex queue preflight 必须确认 WIP=1、依赖满足、previous issue Done、execution contract 格式完整，并且当前 Project 没有 `Todo` / `In Progress` / `In Review` active conflict。
- symphony-issue 只能在唯一 `Todo` issue 存在后调度。
