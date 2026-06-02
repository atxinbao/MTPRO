# MTPRO Account / Position / Balance Read-model-only v1 阶段审计输入材料

日期：2026-05-28

执行者：Codex

## 定位

`MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT`

本文档是 `MTPRO Account / Position / Balance Read-model-only v1` 的 MTP-139 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

`MTP-139-STAGE-AUDIT-INPUT-MATERIAL`

本文档只准备 stage audit input material，集中收口 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence、Workbench / Report / Events APB surface evidence 和 Parent Codex handoff checklist。

`MTP-139-NO-FINAL-STAGE-CODE-AUDIT`

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-133`、`MTP-134`、`MTP-135`、`MTP-136`、`MTP-137`、`MTP-138`、`MTP-139` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、Live read-only runtime、account / position / balance runtime、account snapshot runtime、private stream runtime、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL runtime、Live PRO Console、live command、order form 或交易按钮。

`MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-AUDIT-INPUT`

本文档的审计输入范围只覆盖 `MTPRO Account / Position / Balance Read-model-only v1`，不把 closeout material 写成下一阶段 execution authorization。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Account / Position / Balance Read-model-only v1`。
- Project ID：`c1838a71-afbe-4f55-977c-f192a07b2e41`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-account-position-balance-read-model-only-v1-98eb9b86f624`。
- `MTP-133`、`MTP-134`、`MTP-135`、`MTP-136`、`MTP-137`、`MTP-138`：`Done`。
- `MTP-139`：`In Progress`。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence、stage audit input material、no final Stage Code Audit、no `.codex/*` / no `graphify-out/*` PR boundary。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-133` | L3.1 account / position / balance read-model-only terminology、source semantics、evidence interpretation、L3.1 / L3.2 handoff 和 forbidden capability baseline | [#245 MTP-133 define account position balance boundary](https://github.com/atxinbao/MTPRO/pull/245) | `9b9c8cc7046022b175a46ae144fac5e90c9a8100` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26528240126/job/78137600927) |
| `MTP-134` | account snapshot identity、source / freshness evidence、stale / missing / blocked account evidence 和 account snapshot not runtime | [#246 MTP-134 define account snapshot identity](https://github.com/atxinbao/MTPRO/pull/246) | `62af51ff5e7cbec0ce0295b3e1e42bbe5a3ebfd2` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26528769891/job/78139443676) |
| `MTP-135` | position snapshot identity、exposure evidence、paper / simulated / future real position isolation 和 forbidden broker position interpretation | [#247 MTP-135 define position exposure boundary](https://github.com/atxinbao/MTPRO/pull/247) | `6fb0883fe29c2cbf2c24c1bdc38a61ae5fd12026` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26529245966/job/78141128871) |
| `MTP-136` | balance snapshot identity、paper-vs-real interpretation boundary、real PnL / margin / leverage / buying power forbidden baseline | [#248 MTP-136 define balance boundary](https://github.com/atxinbao/MTPRO/pull/248) | `6c4b9e2deae99487fbc1fe9307be8ef8d97aa6cb` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26529714911/job/78142805610) |
| `MTP-137` | deterministic APB fixture shape、fixture checksum / freshness / source identity、forbidden real account tests 和 payload / schema / runtime isolation | [#249 MTP-137 define account position balance fixture boundary](https://github.com/atxinbao/MTPRO/pull/249) | `0ac3b7191f4074602f3542d9f2ec658cf62db5e5` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26530768193/job/78146521612) |
| `MTP-138` | Workbench / Report / Events APB read-model-only surface、Dashboard smoke APB handle、Event Timeline APB section 和 forbidden UI / runtime flags | [#250 MTP-138 add APB read-model evidence surface](https://github.com/atxinbao/MTPRO/pull/250) | `b96545c5c3e5fe8603238b534550c4a74c15defd` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26576293215/job/78296388110) |
| `MTP-139` | validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence 和 Stage Code Audit 输入材料收口 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Account / Position / Balance validation evidence chain

`MTP-139-VALIDATION-EVIDENCE-CHAIN`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY` | MTP-133 定义 terminology / source / interpretation boundary；MTP-134 固定 account snapshot identity 和 freshness evidence；MTP-135 固定 position snapshot identity 和 exposure evidence；MTP-136 固定 balance snapshot identity 和 paper-vs-real interpretation；MTP-137 固定 deterministic fixture 与 forbidden real account tests；MTP-138 固定 Workbench / Report / Events APB read-model-only surface；MTP-139 收口 validation matrix、automation readiness 和 stage audit input。 | 审计时确认 L3.1 只建立本地 / fixture / paper / simulated account / position / balance read-model-only evidence boundary，不读取真实账户、不连接 broker、不调用 signed/account endpoint、不创建 listenKey、不运行 account snapshot runtime、不提供 command surface。 |
| `TVM-REPORT-EVIDENCE` | MTP-138 将 APB surface 接入 Report read model / ViewModel，展示 APB summary、components、evidence id、freshness、forbidden flags 和 boundary details。 | 审计时确认 Report 只消费 App read model / ViewModel，不读取 Runtime object、Persistence schema、Adapter request、secret、signed endpoint、account endpoint、listenKey、broker payload、real account state、execution report 或 broker fill。 |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | MTP-138 将 APB surface 接入 Dashboard Workbench details、Dashboard smoke `accountPositionBalanceEvidence=3` 和 Event Timeline APB section。 | 审计时确认 Workbench / Dashboard / Events 没有新增 API key input、broker connect、account connect、Live PRO Console、trading button、live command、order form、Runtime action、database console、query language、Graphify update 或 Figma change。 |
| Dashboard smoke | MTP-138 后 smoke summary 包含 `accountPositionBalanceEvidence=3`，并保留 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset`、Live blocked gates、Live execution control gates、Live risk gates、Live incident / stop gates、Live monitoring health / error handles 和 Live read-only Workbench boundary handle。 | 审计时确认 smoke 能定位 APB read-model-only evidence surface、八个 Dashboard sections、read-model-only boundary 和所有 Live forbidden gates。 |
| Deterministic tests | MTP-137 Core tests 覆盖 APB deterministic fixture、forbidden real account bypass、payload / schema / runtime mapping isolation；MTP-138 App tests 覆盖 APB ViewModel、DashboardShell、Report 和 Event Timeline read-only surface。 | 审计时确认 deterministic validation 不依赖真实 Binance private API、secret、account endpoint、listenKey、broker、真实账户、production operations、Graphify、Figma 或人工外包验收。 |

## Forbidden capability evidence

`MTP-139-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-133 至 MTP-138 继续固定以下能力在当前 Project 中全部禁止：

- no signed endpoint。
- no account endpoint。
- no listenKey。
- no private WebSocket runtime。
- no account snapshot runtime。
- no account / position / balance runtime。
- no real account read。
- no broker position sync。
- no real account balance。
- no margin。
- no leverage。
- no real PnL runtime。
- no broker action。
- no broker integration。
- no broker / exchange execution adapter。
- no `LiveExecutionAdapter`。
- no OMS。
- no real order lifecycle。
- no real submit / cancel / replace。
- no execution report runtime / ingestion。
- no broker fill runtime / recorder / fact。
- no reconciliation runtime。
- no API key input。
- no secret storage。
- no account connect。
- no broker connect。
- no Live PRO Console。
- no live command。
- no order form。
- no trading button。
- no emergency stop / shutdown / restore executable action。
- no Graphify update。
- no Figma modification。
- no unauthorized next Project planning / Linear creation。

## Read-model-only boundary evidence

`MTP-139-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`

- `account read-model-only evidence` 只说明 account snapshot identity、source identity、freshness / stale status 和 blocked reason，不表达真实账户资产。
- `position read-model-only evidence` 只说明 symbol、side、quantity、exposure 和 scenario version 的本地 evidence interpretation，不表达 broker position sync。
- `balance read-model-only evidence` 只说明 paper cash、paper equity、simulated balance、fixture balance 和 future-gated real balance interpretation，不表达 buying power、margin、leverage 或 real PnL。
- `AccountPositionBalanceReadModelOnlyFixtureContract` 只输出 deterministic fixture records，不导入 broker payload、account endpoint payload、private stream event、schema object、adapter request 或 Runtime object。
- `AccountPositionBalanceReadModelOnlySurfaceReadModel` / `AccountPositionBalanceReadModelOnlySurfaceViewModel` 只把 fixture evidence 复制到 App / Dashboard / Report / Events read-model-only surface。
- `DashboardShellSnapshot` 的 `accountPositionBalanceEvidence=3` 是 smoke handle，不表示真实账户连接、broker connection、Live PRO Console readiness、trading authorization 或 live command。

## Automation readiness evidence

`MTP-139-AUTOMATION-READINESS-STAGE-CLOSEOUT`

- `checks/automation-readiness.sh` 检查本 MTP-139 输入材料、latest verification summary、Trading Validation Matrix、validation plan、APB read-model-only contract、automation readiness doc、MTP-133 至 MTP-138 source / test / surface anchors、PR #245 至 PR #250 evidence 和 Dashboard smoke APB handle。
- GitHub PR Automation 仍负责 required check `checks`、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*` 与 `graphify-out/*` 不进入 PR。
- MTP-139 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 仍归 Parent Codex closure flow。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`，已机械检查 MTP-139 stage audit input、contract、matrix、validation plan、latest summary、automation readiness、PR evidence 和 Dashboard smoke anchors。 |
| `git diff --check` | pass | 无输出，确认 MTP-139 diff 无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 通过 `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 282 个 XCTest；Dashboard smoke 输出包含 `accountPositionBalanceEvidence=3`；最终输出 `MTPRO checks passed.`。 |

## Known boundaries

`MTP-139-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

- 本 Project 只建立 L3.1 Account / Position / Balance read-model-only evidence boundary，不实现真实账户读取或 Live read-only runtime。
- Account / Position / Balance evidence 只来自本地 / fixture / paper / simulated read model，不来自 signed endpoint、account endpoint、listenKey、private WebSocket、broker adapter、broker payload 或 real account payload。
- Workbench / Dashboard / Report / Event Timeline 只展示 read model / ViewModel，不提供 API key input、broker connect、account connect、Live PRO Console、trading button、live command、order form、Runtime action 或 database console。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。
- 本 issue 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-139 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 L3.1 Account / Position / Balance Read-model-only evidence boundary 已闭环；不代表真实账户读取、private stream、broker readiness、Live PRO Console readiness、live runtime readiness 或真实交易授权。 |
| `BLUEPRINT.md` | Account / Position / Balance read-model-only 可以作为 Future Live 路线的 read-model evidence input；signed endpoint、account endpoint / listenKey、private WebSocket、account snapshot runtime、broker、OMS、production operations 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `environment.md` | 本 Project 未新增 required validation 入口、secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或 production operations；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | Core / App / Dashboard 边界继续成立；L3.1 evidence 沿 contract / deterministic fixture -> App read model / ViewModel -> Dashboard / Report / Event Timeline evidence surface 流动，不读取 adapter、Runtime object、SQLite / DuckDB schema、真实账户 / broker state 或 production operations state。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 同步已发生事实；MTP-139 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-133`、`MTP-134`、`MTP-135`、`MTP-136`、`MTP-137`、`MTP-138`、`MTP-139`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #245、#246、#247、#248、#249、#250 和 MTP-139 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：account / position / balance terminology、account snapshot identity、position snapshot identity、balance snapshot identity、deterministic fixture、forbidden real account tests、Workbench / Report / Events APB surface、Dashboard smoke `accountPositionBalanceEvidence=3`、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、broker position sync、real account balance、margin、leverage、real PnL、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、API key input、secret storage、Live PRO Console、live command、order form、trading button、Graphify update 和 Figma change 禁区。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
