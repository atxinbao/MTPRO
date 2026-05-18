# MTPRO Runtime Research Workbench v1

日期：2026-05-18

执行者：Codex

本文档是 `MTPRO Runtime Research Workbench v1` 的 canonical Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不启动 symphony-issue，不运行 Graphify update，不写业务代码。

完整 issue execution contract 以 Linear issue body 为准。

## Project name

`MTPRO Runtime Research Workbench v1`

## Project goal

把 `MTPRO 引导` 阶段形成的契约优先基线推进为阶段性研究工作台闭环：核心领域边界、追加式事件日志、投影适配器、只读行情入口、ingest / replay / projection 串联、macOS 看板壳和“研究 -> 回测 -> 报告”最小路径。

## Scope

- 按领域边界拆分 `Core.swift`，不改变行为。
- 新增追加式事件日志文件持久化和重放冒烟测试。
- 新增 SQLite 运行时投影适配器最小闭环。
- 新增 DuckDB 分析投影适配器最小闭环。
- 新增 Binance 公开只读行情客户端边界。
- 串联行情 ingest -> event log -> replay -> projection snapshots。
- 新增绑定视图模型快照的 macOS 看板壳。
- 新增“研究 -> 回测 -> 报告”最小路径和阶段证据就绪。

## Non-goals

- 不实现 `LiveExecutionAdapter`。
- 不接 signed endpoint。
- 不做真实 broker action。
- 不把数据库 schema 暴露给 UI。
- UI 只能消费 ViewModel / Read Model。
- 不把 `ROADMAP.md` 或本文档当作执行授权。

## Issue order

| 顺序 | Linear issue | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | `MTP-16` | 按领域边界拆分 `Core.swift`，不改变行为。 | 无 |
| 2 | `MTP-17` | 新增追加式事件日志文件持久化和重放冒烟测试。 | 依赖 `MTP-16` |
| 3 | `MTP-18` | 新增 SQLite 运行时投影适配器最小闭环。 | 依赖 `MTP-17` |
| 4 | `MTP-19` | 新增 DuckDB 分析投影适配器最小闭环。 | 依赖 `MTP-17` |
| 5 | `MTP-20` | 新增 Binance 公开只读行情客户端边界。 | 依赖 `MTP-16` |
| 6 | `MTP-21` | 串联行情 ingest -> event log -> replay -> projection snapshots。 | 依赖 `MTP-17`、`MTP-18`、`MTP-19`、`MTP-20` |
| 7 | `MTP-22` | 新增绑定视图模型快照的 macOS 看板壳。 | 依赖 `MTP-18`、`MTP-19`、`MTP-21` |
| 8 | `MTP-23` | 新增“研究 -> 回测 -> 报告”最小路径和阶段证据就绪。 | 依赖 `MTP-21`、`MTP-22` |

仓库不复制维护完整 issue 正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- `MTP-17` 依赖 `MTP-16`。
- `MTP-18` 依赖 `MTP-17`。
- `MTP-19` 依赖 `MTP-17`。
- `MTP-20` 依赖 `MTP-16`。
- `MTP-21` 依赖 `MTP-17`、`MTP-18`、`MTP-19`、`MTP-20`。
- `MTP-22` 依赖 `MTP-18`、`MTP-19`、`MTP-21`。
- `MTP-23` 依赖 `MTP-21`、`MTP-22`。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

涉及 Binance 的 issue 必须使用 mock transport / fixture parity 完成自动验证；真实网络 smoke test 只能作为可选人工证据。

Project 全部 Done 后，Parent Codex 必须输出覆盖完整 Linear Project 的 Stage Code Audit Report。

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
- 涉及生产代码时，必须包含详细中文注释。

阶段审计证据归入 `MTP-23` 准备，但 Stage Code Audit Report 必须在 Project 全部 Done 后由 Parent Codex 单独输出。

## First executable issue candidate

第一个可执行候选 issue：

```text
MTP-16 按领域边界拆分 Core.swift，不改变行为
```

初始状态仍必须是 `Backlog / non-executable`。Project Planning Facilitator 不操作 `Backlog -> Todo`。

## WIP=1

- 所有 issue 写入 Linear 后初始状态必须是 `Backlog / non-executable`。
- 同一时间最多一个 issue 可进入 `Todo`。
- Project Planning Facilitator 不操作 `Backlog -> Todo`。
- 只有 Parent Codex 在 Human-approved Project 内通过 queue preflight 后，才能推进唯一 eligible issue。
- 本文档不授权执行。

## Linear write boundary

- planning record 不创建 Linear Project。
- planning record 不创建 Linear Issues。
- planning record 不修改 Linear status。
- Human review / merge 后，才允许进入 Linear 写入。
- Linear 写入后，所有 issue 初始必须保持 Backlog / non-executable。
- 完整 issue execution contract 以 Linear issue body 为准。

## Repository record boundary

- 仓库只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 issue 正文。
- 后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。
- 本文档不授权执行。
