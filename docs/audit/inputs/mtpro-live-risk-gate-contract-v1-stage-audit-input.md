# MTPRO Live Risk Gate Contract v1 阶段审计输入材料

日期：2026-05-22

执行者：Codex

## 定位

`MTP-88-LIVE-RISK-GATE-STAGE-AUDIT-INPUT`

本文档是 `MTPRO Live Risk Gate Contract v1` 的 MTP-88 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-82`、`MTP-83`、`MTP-84`、`MTP-85`、`MTP-86`、`MTP-87`、`MTP-88` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-live-risk-gate-contract-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一 issue，不启动下一阶段 `symphony-issue`，不实现真实 live risk engine、真实账户读取、broker position sync、margin / leverage / PnL / equity read、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade state runtime、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、risk command surface、position management command、order form、live command 或交易按钮。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Live Risk Gate Contract v1`。
- Project ID：`645376a1-26eb-4be7-baec-f34e69a2413b`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-live-risk-gate-contract-v1-9a2696f3cbde`。
- `MTP-82`、`MTP-83`、`MTP-84`、`MTP-85`、`MTP-86`、`MTP-87`：`Done`。
- `MTP-88`：`In Progress`。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、forbidden capability evidence、read-model-only boundary evidence、Dashboard smoke evidence 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-82` | Live risk terminology、future risk decision taxonomy、paper / live risk isolation 和 no live risk runtime baseline | [#165 MTP-82 define live risk taxonomy](https://github.com/atxinbao/MTPRO/pull/165) | `643612a74d71f49d38f45bba657c8c6e35cbc510` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26286848821/job/77376514320) |
| `MTP-83` | Exposure / order notional future gates、account / position / margin / leverage forbidden capability tests 和 paper exposure isolation | [#167 MTP-83 Define live risk exposure gates](https://github.com/atxinbao/MTPRO/pull/167) | `49ba28ffd8343c969ed37064000d30a635229fa0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26288214173/job/77381140111) |
| `MTP-84` | Frequency / loss / drawdown future gates、PnL / equity / stop command forbidden capability tests 和 paper risk / exposure isolation | [#169 MTP-84 define frequency loss drawdown gates](https://github.com/atxinbao/MTPRO/pull/169) | `76a8f03971b0894e3d35fbe4e49563fda720434d` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26291446322/job/77392466957) |
| `MTP-85` | Circuit breaker / no-trade state future gates、runtime / command / production shutdown forbidden capability tests 和 paper risk / exposure isolation | [#170 MTP-85 live risk circuit breaker gates](https://github.com/atxinbao/MTPRO/pull/170) | `262056accde123ef3f5a1a68c66727f7bc899929` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26292762287/job/77397126541) |
| `MTP-86` | Paper risk blocker / paper exposure 与 future live risk decision 隔离合同、Report / Dashboard / Event Timeline read-model-only flags | [#171 MTP-86 paper risk live decision isolation](https://github.com/atxinbao/MTPRO/pull/171) | `2e72938a15e76ec7f457148a2a3c055ecb0101e1` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26294166908/job/77402101062) |
| `MTP-87` | Read-model-only `LiveRiskGateBlockedEvidence`、Dashboard / Report / Event Timeline live risk gate blocked evidence 展示面和 Dashboard smoke `liveRiskGates=6` | [#172 MTP-87 新增 read-model-only LiveRiskGateBlockedEvidence](https://github.com/atxinbao/MTPRO/pull/172) | `56e105f0855a182a93780a8beceaef9449d6db49` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26299370909/job/77420288078) |
| `MTP-88` | validation matrix、automation readiness、forbidden capability evidence、read-model-only boundary evidence、Dashboard smoke evidence 和 Stage Code Audit 输入材料收口 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Live risk gate validation evidence chain

`MTP-88-LIVE-RISK-GATE-VALIDATION-EVIDENCE-CHAIN`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-LIVE-RISK-GATE` | MTP-82 定义 terminology / taxonomy；MTP-83 定义 exposure / order notional gates；MTP-84 定义 frequency / loss / drawdown gates；MTP-85 定义 circuit breaker / no-trade state gates；MTP-86 定义 paper / live risk isolation；MTP-87 定义 read-model-only blocked evidence 并接入 Dashboard / Report / Event Timeline；MTP-88 机械收口 automation readiness 和 stage audit input。 | 审计时确认实盘风险控制仍是 Future / forbidden boundary 和 read-model-only blocked evidence，不启动 live risk runtime，不读取真实账户、broker position、margin、leverage、PnL 或 equity，不接 signed endpoint、account endpoint、listenKey、broker adapter 或 `LiveExecutionAdapter`。 |
| `TVM-REPORT-EVIDENCE` | MTP-87 把 live risk gate blocked evidence 汇总进 `ReportViewModel.liveRiskGateBlockedEvidence`，并在 Dashboard Report / Workbench snapshot 中输出 `Risk gates` / `Blocked` 只读指标。 | 审计时确认 Report 只消费 App read model / ViewModel，不读取 adapter、Runtime object、SQLite / DuckDB schema、API key、account payload、broker state、real risk decision、PnL、equity、margin 或 leverage。 |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | MTP-87 把 live risk gate blocked evidence 接入 Workbench `Live Risk Gate` 只读组和 Event Timeline / Evidence Explorer preview。 | 审计时确认 Workbench / Event Timeline 没有新增 live command、risk command、position command、order form、交易按钮、circuit breaker command、stop trading command、emergency stop、query language、incident runtime 或真实交易授权。 |
| Dashboard smoke | MTP-87 后 `DASHBOARD_SMOKE=1 swift run Dashboard` 输出包含 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset`、`timelineItems=37`、`liveBlockedGates=6`、`liveExecutionControlGates=7`、`liveRiskGates=6`、`liveMonitoringHealth=blocked` 和 `liveMonitoringErrors=3`。 | 审计时确认 smoke 能定位八个 Dashboard sections、readModelOnly / workbenchReadModelOnly flags、session-level controls、Live blocked gates、Live execution control gates、Live risk gate count、Live monitoring health 和 Live monitoring error count。 |
| Deterministic tests | Core tests 覆盖 MTP-82 / MTP-83 / MTP-84 / MTP-85 / MTP-86 / MTP-87 deterministic fixtures 和 forbidden capability rejection；App tests 覆盖 MTP-87 Dashboard / Report / Event Timeline read-model-only evidence、Dashboard smoke、Codable snapshot、no command / no order form / no trading button / no schema / no adapter / no runtime / no broker / no trading execution。 | 审计时确认 deterministic validation 不依赖真实 Binance 网络、secret、account endpoint、listenKey、broker、真实账户、PnL、equity、margin、leverage、production runtime operations 或人工验收。 |

## Forbidden capability evidence

MTP-88 继续固定以下能力在当前 Project 中全部禁止：

- no API key。
- no secret storage。
- no signed endpoint。
- no account endpoint。
- no listenKey。
- no broker adapter。
- no exchange execution adapter。
- no `LiveExecutionAdapter`。
- no real risk engine。
- no real pre-trade allow / reject runtime。
- no real account balance read。
- no broker position sync。
- no margin read。
- no leverage read。
- no real PnL read。
- no real account equity read。
- no real account exposure calculation。
- no real order notional evaluation。
- no live order frequency runtime。
- no loss / drawdown runtime。
- no circuit breaker runtime。
- no no-trade state runtime。
- no global trading lock。
- no broker session state mutation。
- no circuit breaker command。
- no stop trading command。
- no emergency stop。
- no automatic recovery command。
- no production shutdown control。
- no live command。
- no risk command surface。
- no position management command。
- no order form。
- no trading button。

## Read-model-only boundary evidence

- `LiveRiskGateBlockedEvidence` 只作为 Core deterministic read-model-only blocked evidence。
- `LiveRiskGateBlockedEvidenceReadModel` 和 `LiveRiskGateBlockedEvidenceViewModel` 只复制 Core blocked evidence，不读取 secret、schema、adapter、Runtime object、真实账户、broker position、margin、leverage、PnL 或 equity。
- `ReportViewModel`、`DashboardShellSnapshot` 和 `PaperWorkflowEvidenceExplorerViewModel` 只消费 read model / ViewModel，不暴露 persistence schema、adapter request、Runtime object、broker action、real pre-trade allow / reject runtime、risk command surface、position management command、order form、circuit breaker command、stop trading command、emergency stop 或 live command。
- Dashboard smoke 的 `liveRiskGates=6` 只表示六个 live risk gates 仍被阻断，不表示真实实盘风控能力已实现。

## Automation readiness evidence

`MTP-88-AUTOMATION-READINESS-STAGE-CLOSEOUT`

- `checks/automation-readiness.sh` 检查本 MTP-88 输入材料、latest verification summary、Trading Validation Matrix、validation plan、Live risk gate contract、Core / App source anchors、Core / App deterministic test anchors、Dashboard smoke evidence 和 PR evidence chain。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档 / 验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-88 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 本 issue 加固 MTP-88 stage audit input、contract、matrix、validation plan、latest summary、source / test anchors 和 Dashboard smoke anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=37; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；184 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只建立 Future Live Risk 的 contract、forbidden capability tests、paper / live risk isolation、read-model-only blocked evidence 和 Dashboard / Report / Event Timeline evidence surface；不实现真实 Live trading、execution control runtime、live risk runtime、live audit、incident replay 或 stop control。
- API key、secret storage、request signature、signed endpoint、account endpoint、listenKey user data stream 和 real account payload 均保持 forbidden / future gate。
- Binance 当前仍只允许 public read-only market data；required validation 不依赖真实 Binance 网络、真实 API key、真实账户或 broker state。
- Future broker / exchange execution adapter、execution venue connection、`LiveExecutionAdapter`、real pre-trade allow / reject runtime、real order submit / cancel / replace、real account balance、broker position sync、margin、leverage、PnL、equity、OMS、risk command surface、position management command、order form 和 trading button 均未实现。
- Live risk gate blocked evidence 只表达 exposure、order notional、frequency、loss / drawdown、circuit breaker 和 no-trade state 仍被阻断，不提供 command surface。
- Dashboard / Report / Event Timeline 只展示 read model / ViewModel，不提供 live command、risk command、position command、交易按钮、表单、order-level command、circuit breaker command、stop trading command、emergency stop、automatic recovery command、production shutdown control 或真实交易授权。
- App / Dashboard 不暴露 adapter request、adapter instance、Runtime object、actor、workflow object、SQLite / DuckDB schema、SQL、ORM、table、column 或 persistence adapter direct read。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-88 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明“实盘风险控制”切片的 contract / boundary / blocked evidence 输入已建立；不代表真实 live risk engine、真实账户风控、circuit breaker command、stop trading command 或 production runtime 已实现。 |
| `BLUEPRINT.md` | Future Live risk / audit / stop controls 仍保持 Future Construction Zones / 未来建设区；本 Project 只增加 Live Risk gate contract、forbidden capability tests 和 blocked evidence 的事实证据。 |
| `docs/environment.md` | 本 Project 未新增 required validation 入口、secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或网络必需验证；统一验证入口仍是 `bash checks/run.sh`。 |
| `docs/architecture.md` | Core / App / Dashboard 边界继续成立；App / Dashboard 只消费 read model / ViewModel，不读取 adapter、Runtime object、SQLite / DuckDB schema 或真实账户 / broker state。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条同步已发生事实；MTP-88 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-82`、`MTP-83`、`MTP-84`、`MTP-85`、`MTP-86`、`MTP-87`、`MTP-88`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #165、#167、#169、#170、#171、#172 和 MTP-88 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：live risk terminology、future risk decision taxonomy、exposure / order notional gates、frequency / loss / drawdown gates、circuit breaker / no-trade state gates、paper / live risk isolation、read-model-only blocked evidence、Dashboard / Report / Event Timeline evidence surface、Dashboard smoke `liveRiskGates=6`、API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、real risk engine、real pre-trade allow / reject runtime、real account balance、broker position sync、margin、leverage、PnL、equity、circuit breaker command、stop trading command、emergency stop、schema leakage、command surface、order form 和 trading button 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-88 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`docs/environment.md`、`docs/architecture.md`、`docs/roadmap.md`。
- Current Phase Progress Bar：Root Docs Refresh Gate closure 后由 `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出，不按 Project closure count 直接计算目标完成度。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
