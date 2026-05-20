# MTPRO Market Data Replay Operations v1

日期：2026-05-20

执行者：Codex

本文档是 `MTPRO Market Data Replay Operations v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不写业务代码。

完整 issue execution contract 以后以 Linear issue body 为准。

## Project name

`MTPRO Market Data Replay Operations v1`

## Project goal

建立本地、paper-only、public-read-only 的 market data batch / replay operations 基线，使更长周期 market data replay 可以通过本地 fixture / batch replay 合同、retention / freshness read model、event log / projection consistency 和 Report / Dashboard / Event Timeline evidence 被确定性验证。

本阶段不绑定真实历史下载规模，不进入 production deployment / runtime operations。

## Scope

- Binance public read-only market data batch / replay boundary。
- 本地 replay operations metadata。
- 本地 fixture / batch replay contract。
- 最小 retention policy。
- 最小 freshness evidence read model。
- deterministic fixture parity。
- event log / projection snapshot consistency。
- Report / Dashboard / Event Timeline read-model-only evidence。
- automation readiness anchor。
- stage audit input material。

## Non-goals

- 不做 Live trading。
- 不接 Binance signed endpoint。
- 不接 account endpoint / listenKey。
- 不连接 broker。
- 不提交 / 撤销 / 替换真实订单。
- 不实现 OMS。
- 不做 real account balance / broker position sync。
- 不做 production deployment / runtime operations。
- 不做大规模数据平台。
- 不做云端数据湖。
- 不做多节点运行系统。
- 不绑定具体真实历史下载规模。
- 不把 planning record 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 Binance public read-only market data batch / replay boundary | 定义本阶段 market data batch / replay 的 public-read-only 边界，固定本地 fixture / batch replay contract 和禁止能力。 | 无 |
| 2 | 新增 local replay operations metadata 和 batch replay contract | 新增本地 replay operations metadata 和 batch replay contract，描述 batch、replay run、symbol、interval、time window、fixture source 和 parity hint。 | 依赖 Issue 1 |
| 3 | 新增最小 retention policy 和 freshness evidence read model | 新增最小 retention policy 和 freshness evidence read model，表达本地 batch 保留、过期、stale 和 freshness evidence。 | 依赖 Issue 2 |
| 4 | 加固 deterministic fixture parity 和 replay consistency | 加固 fixture / batch replay 的 deterministic parity，验证 replay output、record ordering、checksum / parity hint 和 metadata consistency。 | 依赖 Issue 2 |
| 5 | 串联 event log / projection snapshot consistency evidence | 将 batch replay output 与 append-only event log、replay run summary 和 projection snapshot consistency evidence 串联。 | 依赖 Issue 3、Issue 4 |
| 6 | 接入 Report / Dashboard / Event Timeline read-model-only evidence | 将 replay operations、retention / freshness 和 consistency evidence 接入 Report / Dashboard / Event Timeline read-model-only 展示。 | 依赖 Issue 3、Issue 5 |
| 7 | 收口 automation readiness、validation evidence 和 stage audit input material | 收口 validation evidence、automation readiness anchor、Dashboard smoke evidence、known boundaries 和 Stage Code Audit input material。 | 依赖 Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 2。
- Issue 4 依赖 Issue 2。
- Issue 5 依赖 Issue 3、Issue 4。
- Issue 6 依赖 Issue 3、Issue 5。
- Issue 7 依赖 Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Market data replay operations 相关验证必须满足：

- 自动测试必须 deterministic。
- 涉及 Binance / market data 的 issue 必须证明只使用 public read-only boundary。
- 自动验证不得依赖真实 Binance 网络；真实网络 smoke test 只能作为可选人工证据。
- deterministic fixture parity 必须通过 mock transport / fixture parity 完成。
- retention / freshness read model 必须保持 read-model-only。
- Dashboard / Event Timeline 接入不得暴露 adapter、runtime object、SQLite / DuckDB schema 或 raw persistence implementation。
- 必须验证不触碰 Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单行为。
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
- Market data replay operations PR 必须记录 public read-only、no real network required validation、no signed endpoint / no broker boundary evidence。

Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 Binance public read-only market data batch / replay boundary
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
