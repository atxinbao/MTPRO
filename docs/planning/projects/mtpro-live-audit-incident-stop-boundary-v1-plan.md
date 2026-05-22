# MTPRO Live Audit Incident Stop Boundary v1

日期：2026-05-23

执行者：Codex

本文档是 `MTPRO Live Audit Incident Stop Boundary v1` 写入 Linear 前的 Project Planning Record，只保存 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable issue candidate、WIP=1 和边界。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不写业务代码，不修改 Figma。

完整 issue execution contract 以后以 Linear issue body 为准。仓库 planning record 不复制维护完整 Linear issue body。

## Project name

`MTPRO Live Audit Incident Stop Boundary v1`

## Project goal

承接 Final Product Goal Slice #9：Live audit / incident replay / stop controls。

本阶段只定义实盘审计、事故回放、停机 / 恢复相关的 contract、boundary、future gates、forbidden capability tests 和 read-model-only blocked evidence；不实现任何真实实盘操作、事故回放运行时、停机 / 恢复命令、production operations、Live PRO Console 或 live command。

## Scope

- 定义 Live audit / incident / stop terminology 和 taxonomy。
- 定义 signal / order / risk decision / fill audit trail future gates。
- 定义 incident replay future gates。
- 定义 emergency stop / shutdown / restore future gates。
- 定义 forbidden capability tests，阻断真实 incident replay runtime、stop command、shutdown / restore command、production operations 和 broker action。
- 定义 Live risk / execution blocked evidence 与 future incident / stop boundary 的隔离合同。
- 新增 read-model-only 的 `LiveIncidentStopBlockedEvidence` 或等价模型。
- Dashboard / Report / Event Timeline 可以只读展示 blocked evidence。
- Workbench 只能消费 ViewModel / Read Model / Command Model。
- 收口 validation matrix、automation readiness 和 stage audit input material。

## Non-goals

- 不实现真实 incident replay runtime。
- 不实现 emergency stop、shutdown、restore。
- 不实现 production operations。
- 不连接 broker，不执行 broker action。
- 不接 signed endpoint、account endpoint / listenKey。
- 不实现 OMS、real order state machine、`LiveExecutionAdapter`。
- 不实现 Live PRO Console。
- 不新增交易按钮、live command、order-level command UI 或 stop control UI。
- 不把 planning draft 当执行授权。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 Live audit / incident / stop terminology 和 taxonomy | 定义 live audit、incident replay、emergency stop、shutdown、restore 和 stop controls 的 Future / gated terminology。 | 无 |
| 2 | 定义 signal / order / risk decision / fill audit trail future gates 和 forbidden capability tests | 定义 signal、order、risk decision、fill 的 future audit trail gates，确保审计链只作为 future contract。 | 依赖 Issue 1 |
| 3 | 定义 incident replay future gates 和 forbidden capability tests | 定义 incident replay 的 future gates 和 forbidden capability tests，避免升级为事故回放运行时或生产恢复系统。 | 依赖 Issue 1、Issue 2 |
| 4 | 定义 emergency stop / shutdown / restore future gates 和 forbidden capability tests | 定义 emergency stop、shutdown、restore 的 future gates 和 forbidden capability tests，确保当前无停机、恢复或紧急停止命令。 | 依赖 Issue 1、Issue 2、Issue 3 |
| 5 | 定义 Live risk / execution blocked evidence 与 future incident / stop boundary 的隔离合同 | 防止 `LiveExecutionControlBlockedEvidence`、`LiveRiskGateBlockedEvidence` 或 paper evidence 升级为 incident command、stop command 或 restore decision。 | 依赖 Issue 2、Issue 3、Issue 4 |
| 6 | 新增 read-model-only LiveIncidentStopBlockedEvidence 并接入 Dashboard / Report / Event Timeline | 新增 read-model-only `LiveIncidentStopBlockedEvidence` 或等价模型，并接入只读展示面。 | 依赖 Issue 5 |
| 7 | 收口 validation matrix、automation readiness 和 stage audit input material | 收口 validation matrix、automation readiness anchor、forbidden capability evidence、read-model-only boundary evidence、Dashboard smoke evidence 和 stage audit input material。 | 依赖 Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Candidate issue summaries

| Issue | Scope 摘要 | Non-goals / Boundary 摘要 | Validation 摘要 |
| --- | --- | --- | --- |
| Issue 1 | Live audit、audit trail、incident、incident replay、stop control、emergency stop、shutdown、restore terminology；future audit / incident / stop taxonomy；validation anchors。 | 不实现 incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command 或交易按钮。 | `bash checks/run.sh`；验证术语不引入 signed/account/listenKey、broker action、incident replay runtime、stop command、shutdown / restore command 或 Live PRO Console。 |
| Issue 2 | signal / order / risk decision / fill audit trail future gates；forbidden capability tests 阻断 execution report ingestion、broker fill fact、real order state machine、OMS 和 broker action。 | 不实现真实 audit trail runtime、execution report parser / ingestion、broker fill recorder、OMS、real order state machine 或 broker reconciliation。 | `bash checks/run.sh`；验证 no broker action、no execution report runtime、no broker fill runtime、no OMS、no real order state machine。 |
| Issue 3 | incident replay terminology、input source future gates、replay scope / evidence / output future gates；forbidden tests 阻断 incident replay runtime、production recovery、auto restore、broker replay 和 account replay。 | 不实现 incident replay runtime、production recovery、真实 account / broker state 读取、自动恢复、自动回滚或生产运行系统。 | `bash checks/run.sh`；验证 no incident replay runtime、no production recovery、no broker replay、no account replay。 |
| Issue 4 | emergency stop、shutdown、restore future gates；stop / shutdown / restore forbidden capability tests；说明这些 gates 不等于 Live Risk circuit breaker runtime 或 no-trade state runtime。 | 不实现 emergency stop、shutdown command、restore command、global trading lock、broker session mutation、production shutdown control、stop button、live command 或 Live PRO Console。 | `bash checks/run.sh`；验证 no emergency stop、no shutdown、no restore command、no live command、no trading button、no broker session mutation、no production operations。 |
| Issue 5 | execution-control blocked evidence、risk gate blocked evidence、paper evidence、simulated fill、paper exposure 与 future incident / stop boundary 的隔离合同。 | 不实现 incident command、stop / shutdown / restore command、live risk engine、execution runtime、production operations；不把 blocked evidence 变成 runtime control。 | `bash checks/run.sh`；验证 execution / risk blocked evidence 不能升级为 incident replay runtime、stop command、shutdown command、restore command 或 production operation。 |
| Issue 6 | `LiveIncidentStopBlockedEvidence` 或等价 read model；audit trail、incident replay、emergency stop、shutdown、restore blocked reason；deterministic fixture / snapshot；Dashboard / Report / Event Timeline 只读展示。 | 不实现 Live PRO Console、完整实盘操作台页面、交易按钮、stop button、live command、order-level command UI、incident replay runtime、emergency stop、shutdown、restore、production operations，也不向 UI 暴露 schema、adapter 或 runtime object。 | `bash checks/run.sh`；验证 read-model-only、只读 blocked evidence surface、no Live PRO Console、no stop button、no trading button、no live command、Workbench 不读取 adapter / runtime / schema。 |
| Issue 7 | validation matrix、automation readiness anchors、forbidden capability evidence、read-model-only boundary evidence、Dashboard smoke evidence、stage audit input material。 | 不输出最终 Stage Code Audit Report，不启动下一阶段 symphony-issue，不推进下一 Project / Issue，不实现 incident replay runtime、emergency stop、shutdown、restore 或 production operations。 | `bash checks/run.sh`；验证 readiness anchors 覆盖 no signed/account/listenKey、no broker、no `LiveExecutionAdapter`、no OMS、no real order state machine、no incident replay runtime、no emergency stop、no shutdown、no restore、no Live PRO Console、no trading button / live command，并验证 `.codex/*` 和 `graphify-out/*` 不进 PR。 |

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

Live Audit Incident Stop Boundary 相关验证必须满足：

- 必须验证 no signed endpoint / account endpoint / listenKey。
- 必须验证 no broker action / no broker adapter / no `LiveExecutionAdapter`。
- 必须验证 no OMS / no real order state machine。
- 必须验证 no incident replay runtime。
- 必须验证 no emergency stop / shutdown / restore command。
- 必须验证 no production operations。
- 必须验证 no Live PRO Console、no trading button、no live command。
- `LiveIncidentStopBlockedEvidence` 或等价模型必须保持 read-model-only。
- Dashboard / Report / Event Timeline 只能展示 blocked evidence。
- Workbench 只能消费 ViewModel / Read Model / Command Model。
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
- Live Audit Incident Stop PR 必须记录 no signed endpoint、no account endpoint、no listenKey、no broker action、no broker adapter、no `LiveExecutionAdapter`、no OMS、no real order state machine、no incident replay runtime、no emergency stop、no shutdown、no restore、no production operations、no Live PRO Console、no trading button、no live command boundary evidence。

Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

Issue 7 只准备 stage audit input material，不输出最终 Stage Code Audit Report。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 Live audit / incident / stop terminology 和 taxonomy
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
- Human review / merge 后，才允许进入 Linear 写入。
- Project 写入 Linear 后，所有 issue 初始必须是 `Backlog / non-executable`。
- 完整 issue execution contract 以后以 Linear issue body 为准。
- Project 写入 Linear 后，由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。

## Repository record boundary

- 仓库 planning record 只保存 Project 级计划摘要和格式门槛。
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
