# MTPRO Live Risk Gate Contract v1

日期：2026-05-22

执行者：Codex

本文档是 `MTPRO Live Risk Gate Contract v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不写业务代码，不修改 Figma。

完整 issue execution contract 以后以 Linear issue body 为准。

## Project name

`MTPRO Live Risk Gate Contract v1`

## Project goal

承接 Final Product Goal Slice #8：Live Risk Control。

本阶段只定义 Future Live Risk 的 risk gate contract / boundary，包括 live pre-trade risk terminology、exposure / order notional / frequency / loss / circuit breaker / no-trade state gates、future risk decision taxonomy、forbidden capability tests、paper risk / future live risk 隔离和 read-model-only blocked evidence；不实现任何真实风控引擎、真实账户读取或 live command。

## Scope

- 定义 live pre-trade risk terminology。
- 定义 exposure gate。
- 定义 order notional gate。
- 定义 frequency gate。
- 定义 loss / drawdown gate。
- 定义 circuit breaker gate。
- 定义 no-trade state gate。
- 定义 future risk decision taxonomy。
- 定义 forbidden capability tests。
- 定义 paper risk blocker / paper portfolio exposure 与 future live risk decision 隔离。
- 新增 read-model-only 的 `LiveRiskGateBlockedEvidence` 或等价模型。
- Dashboard / Report / Event Timeline 展示 read-model-only Live Risk blocked evidence。
- 收口 validation matrix、automation readiness 和 stage audit input material。

## Non-goals

- 不实现真实 live risk engine。
- 不读取真实账户余额、broker position、margin、leverage。
- 不接 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 circuit breaker command。
- 不实现 stop trading command / emergency stop。
- 不实现 live command UI。
- 不新增交易按钮。
- 不提交、撤销、替换真实订单。
- 不实现 production operations 或 incident runtime。
- 不把 planning draft 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 Live risk terminology 和 future risk decision taxonomy | 定义 Future Live Risk 的核心术语和 future risk decision taxonomy。 | 无 |
| 2 | 定义 exposure / order notional gates 和 forbidden capability tests | 定义 exposure gate 和 order notional gate 的 future risk boundary。 | 依赖 Issue 1 |
| 3 | 定义 frequency / loss / drawdown gates 和 forbidden capability tests | 定义 frequency gate、loss gate 和 drawdown gate 的 future risk boundary。 | 依赖 Issue 1 |
| 4 | 定义 circuit breaker / no-trade state gates 和 forbidden capability tests | 定义 circuit breaker gate 和 no-trade state gate 的 future risk boundary。 | 依赖 Issue 1、Issue 2、Issue 3 |
| 5 | 定义 paper risk blocker / paper exposure 与 future live risk decision 隔离合同 | 定义 paper risk blocker、paper portfolio exposure 与 future live risk decision 的隔离合同。 | 依赖 Issue 1、Issue 2、Issue 3、Issue 4 |
| 6 | 新增 read-model-only LiveRiskGateBlockedEvidence 并接入 Dashboard / Report / Event Timeline | 新增 read-model-only `LiveRiskGateBlockedEvidence` 或等价模型，并接入只读展示面。 | 依赖 Issue 5 |
| 7 | 收口 validation matrix、automation readiness 和 stage audit input material | 收口 validation matrix、automation readiness anchor、forbidden capability evidence、read-model-only boundary evidence、Dashboard smoke evidence 和 stage audit input material。 | 依赖 Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 1。
- Issue 4 依赖 Issue 1、Issue 2、Issue 3。
- Issue 5 依赖 Issue 1、Issue 2、Issue 3、Issue 4。
- Issue 6 依赖 Issue 5。
- Issue 7 依赖 Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

Live Risk Gate Contract 相关验证必须满足：

- 必须验证 no API key / secret storage。
- 必须验证 no signed endpoint / account endpoint / listenKey。
- 必须验证 no broker / exchange execution adapter。
- 必须验证 no `LiveExecutionAdapter`。
- 必须验证 no real risk engine / no real pre-trade allow-reject runtime。
- 必须验证 no real account balance / broker position / margin / leverage。
- 必须验证 no circuit breaker command / stop trading command / emergency stop。
- 必须验证 no trading button / live command / order-level command UI。
- 必须验证 paper risk blocker / paper exposure 不能升级为 future live risk decision。
- `LiveRiskGateBlockedEvidence` 或等价模型必须保持 read-model-only。
- Dashboard / Report / Event Timeline 只能展示 blocked evidence。
- PR 必须包含 MTPRO-native PR evidence fields：`Feedback Loop Evidence`、`Tracer Bullet / Fixture Evidence`、`Diagnose Evidence`、`Architecture Deepening Candidate`。
- 涉及 production code 时必须包含详细中文注释。

## Evidence requirements

每个 PR 必须包含：

- Linked Linear Issue。
- Scope / Non-goals 确认。
- validation output。
- boundary evidence。
- Pre-PR Codex Code Review。
- GitHub PR Automation evidence。
- MTPRO-native PR evidence fields。
- `.codex/*` 未进入 PR。
- `graphify-out/*` 未进入 PR。
- 如由 symphony-issue 执行，需 handoff marker evidence。
- Live Risk PR 必须记录 no API key、no signed endpoint、no account endpoint、no listenKey、no broker、no `LiveExecutionAdapter`、no real risk engine、no real account balance、no broker position、no margin、no leverage、no circuit breaker command、no stop trading command、no emergency stop、no trading button / command boundary evidence。

Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

Issue 7 只准备 stage audit input material，不输出最终 Stage Code Audit Report。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 Live risk terminology 和 future risk decision taxonomy
```

该 issue 只是 first executable issue candidate，初始状态仍必须是 `Backlog / non-executable`，不授权执行，不推进 Todo。

Project 写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。

## WIP=1

- Project 执行必须保持 WIP=1。
- 所有 issue 初始状态必须是 `Backlog / non-executable`。
- 当前 Todo：none。
- 同一时间最多一个 issue 可进入 Todo。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 写入 Linear 后，由 Parent Codex queue preflight 判断唯一 eligible issue。
- symphony-issue 只调度唯一 `Todo` issue。
- 本文档不授权执行。

## Linear write boundary

- 本 draft 不创建 Linear Project。
- 本 draft 不创建 Linear Issues。
- 本 draft 不修改 Linear status。
- 本 draft 不推进 Todo。
- 本 planning record 不创建 Linear Project。
- 本 planning record 不创建 Linear Issues。
- 本 planning record 不修改 Linear status。
- Human review / merge 后，才允许进入 Linear 写入。
- Project 写入 Linear 后，所有 issue 初始必须是 `Backlog / non-executable`。
- 完整 issue execution contract 以后以 Linear issue body 为准。
- Project 写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。

## Repository record boundary

- 仓库 planning record 只保存 Project 级计划摘要和格式门槛。
- 仓库只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 issue 正文。
- 仓库不复制维护完整 Linear issue body。
- 后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。
- Planning record 不授权执行。

## Parent Codex queue preflight rule

- `@001 / PLN` 只负责 Project-level planning record 和 Linear 写入前草案。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并推进 Todo。
- Parent Codex queue preflight 必须确认 WIP=1、依赖满足、previous issue Done、execution contract 格式完整，并且当前 Project 没有 `Todo` / `In Progress` / `In Review` active conflict。
- 本 planning record 不启动 `@002 / PAR`。
- symphony-issue 只能在唯一 `Todo` issue 存在后调度。
