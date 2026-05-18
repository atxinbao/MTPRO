# MTPRO 引导

日期：2026-05-18

执行者：Codex

本文档是 `MTPRO 引导` 的 canonical Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不启动 symphony-issue，不运行 Graphify update，不写业务代码。

完整 issue execution contract 以 Linear issue body 为准。

## Project name

`MTPRO 引导`

## Project goal

完成 MTPRO 的项目定义、SwiftPM baseline、Core / Adapter / Persistence / App 契约、验证和自动化就绪。

## Scope

- 记录项目定义和 SwiftPM baseline。
- 建立 Core 领域模型、事件、命令、查询和 event log contract。
- 建立 Binance public read-only market data adapter contract 和 fixture decoder。
- 建立 actor kernel、MessageBus、DataEngine、Cache。
- 建立 EMA strategy、backtest / paper event flow 和 parity contract。
- 建立 order book imbalance research contract。
- 建立 replay、runtime projection 和 analytical projection。
- 建立 Dashboard read model 和 ViewModel contract。
- 固化 validation matrix、PR evidence、WIP=1、Graphify 和 automation readiness。

## Non-goals

- 不授权 Live trading。
- 不实现 `LiveExecutionAdapter`。
- 不调用 Binance signed endpoint。
- 不做真实 broker action。
- 不创建下一阶段 Project / Issue。
- 不把 `ROADMAP.md` 或本文档当作执行授权。

## Issue order

| 顺序 | Linear issue | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | `MTP-7` | 记录项目定义和 SwiftPM baseline。 | 无 |
| 2 | `MTP-8` | 建立 Core 领域模型、事件、命令、查询和 event log contract。 | 依赖 `MTP-7` |
| 3 | `MTP-9` | 建立 Binance 公开只读行情适配器契约和 fixture decoder。 | 依赖 `MTP-8` |
| 4 | `MTP-10` | 建立 actor kernel、MessageBus、DataEngine 和 Cache。 | 依赖 `MTP-8`、`MTP-9` |
| 5 | `MTP-11` | 建立 EMA 回测与 Paper 一致性契约。 | 依赖 `MTP-10` |
| 6 | `MTP-12` | 建立订单簿失衡策略研究链路。 | 依赖 `MTP-10` |
| 7 | `MTP-13` | 建立 SQLite / DuckDB 投影与重放边界。 | 依赖 `MTP-10`、`MTP-11`、`MTP-12` |
| 8 | `MTP-14` | 建立 Trader Workstation 看板 ViewModel 契约。 | 依赖 `MTP-13` |
| 9 | `MTP-15` | 固化验证加固与自动化就绪。 | 依赖 `MTP-14` |

仓库不复制维护完整 issue 正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- `MTP-8` 依赖 `MTP-7`。
- `MTP-9` 依赖 `MTP-8`。
- `MTP-10` 依赖 `MTP-8`、`MTP-9`。
- `MTP-11` 依赖 `MTP-10`。
- `MTP-12` 依赖 `MTP-10`。
- `MTP-13` 依赖 `MTP-10`、`MTP-11`、`MTP-12`。
- `MTP-14` 依赖 `MTP-13`。
- `MTP-15` 依赖 `MTP-14`。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Project 完成后必须由 Parent Codex 输出覆盖完整 Linear Project 的 Stage Code Audit Report。

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

## First executable issue candidate

第一个可执行候选 issue：

```text
MTP-7 记录引导基线
```

Project Planning Record 不授权该 issue 进入 `Todo`。

## WIP=1

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
