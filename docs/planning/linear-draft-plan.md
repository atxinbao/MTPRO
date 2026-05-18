# MTPRO Project Planning Records

日期：2026-05-18

执行者：Codex

本文档是 MTPRO Project Planning Record 的入口索引和统一规则文档。

本文档不授权 Codex 执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不启动 symphony-issue，不运行 Graphify update，不授权 Binance、策略、UI 或数据库适配器实现。

## 职责

本文档只承担以下职责：

1. Project Planning Record 入口索引。
2. Project Planning Record 命名规则。
3. Project Planning Record 内容规则。
4. Linear write boundary。
5. Repository record boundary。
6. 当前 Project planning record 指向。

历史 Project planning 内容已迁移到 `docs/planning/projects/`。

## Project Planning Record 索引

| Project | Planning Record | 状态 |
| --- | --- | --- |
| `MTPRO 引导` | `docs/planning/projects/mtpro-guidance-plan.md` | 已写入 Linear；Project 已完成；Stage Code Audit Report 已落仓。 |
| `MTPRO Runtime Research Workbench v1` | `docs/planning/projects/mtpro-runtime-research-workbench-v1-plan.md` | 已写入 Linear；`MTP-16` 至 `MTP-23` 已完成；Stage Code Audit Report 已落仓。 |
| `MTPRO Trading Validation and Parity Hardening` | `docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md` | 写入 Linear 前的当前 Project Planning Record；不授权执行。 |

## 当前 Project planning record

- Project：`MTPRO Trading Validation and Parity Hardening`
- Canonical record：`docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`
- 来源审计：`docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md`
- 当前状态：写入 Linear 前的 Project Planning Record。
- First executable issue candidate：定义 Trading Validation Matrix 和验收证据边界。
- WIP=1：所有候选 issue 写入 Linear 后必须初始保持 `Backlog / non-executable`。

## Project Planning Record 命名规则

- 所有 Project planning record 必须放在 `docs/planning/projects/`。
- 文件名格式：`<linear-project-slug>-plan.md`。
- slug 使用 Project name 的小写 kebab-case。
- 文件名不放日期。
- 一个 Linear Project 对应一份 canonical planning record。

## Project Planning Record 内容规则

每份 Project planning record 必须包含：

1. `Project name`
2. `Project goal`
3. `Scope`
4. `Non-goals`
5. `Issue order`
6. `Dependencies`
7. `Validation requirements`
8. `Evidence requirements`
9. `First executable issue candidate`
10. `WIP=1`
11. `Linear write boundary`
12. `Repository record boundary`

每份 Project planning record 只保留 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable candidate、WIP=1 和边界。

仓库只保存 Project 级计划摘要和格式门槛，不复制维护完整 issue 正文。

不得复制维护完整 issue 正文。历史内容里如果存在完整 issue body，迁移时必须压缩成 issue list 摘要。

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

## 执行边界

- `ROADMAP.md` 不授权执行。
- Project Planning Record 不授权执行。
- Project Planning Facilitator 不操作 `Backlog` -> `Todo`。
- 只有父 Codex 可以操作 `Backlog` -> `Todo`。
- 只有父 Codex 可以在 Human-approved Project 内，通过 queue preflight、WIP=1、依赖、previous issue Done 和 execution contract gate 后，操作唯一 eligible issue 的 `Backlog` -> `Todo`。
- symphony-issue 只能调度唯一 `Todo` issue。
- Codex Execution Agent 只执行当前唯一 Linear issue scope。
