# MTPRO Live Monitoring Console v1 阶段审计输入材料

日期：2026-05-21

执行者：Codex

## 定位

`MTP-74-LIVE-MONITORING-STAGE-AUDIT-INPUT`

本文档是 `MTPRO Live Monitoring Console v1` 的 MTP-74 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-68`、`MTP-69`、`MTP-70`、`MTP-71`、`MTP-72`、`MTP-73`、`MTP-74` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-live-monitoring-console-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一 issue，不启动下一阶段 `symphony-issue`，不实现任何 Live trading、execution、risk、audit 或 stop control capability。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Live Monitoring Console v1`。
- Project ID：`e3c6f7a9-4a90-492b-bc13-30dbc206fa88`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-live-monitoring-console-v1-f78df722e56b`。
- `MTP-68`、`MTP-69`、`MTP-70`、`MTP-71`、`MTP-72`、`MTP-73`：`Done`。
- `MTP-74`：`In Progress`。
- 当前 issue scope 仅限 validation matrix、automation readiness anchor、Dashboard smoke evidence、read-model-only boundary evidence 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-68` | Live monitoring console information architecture、status taxonomy、read-model-only boundary 和 order stream evidence 边界 | [#137 MTP-68 Define live monitoring console IA](https://github.com/atxinbao/MTPRO/pull/137) | `f9c1164e5494eec3017f37715253c29ff35da64d` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26228414000/job/77181670893) |
| `MTP-69` | `LiveRuntimeHealthReadModel` / `LiveConnectionStatusReadModel` 最小 Core read model | [#138 MTP-69 add live runtime health read model](https://github.com/atxinbao/MTPRO/pull/138) | `ac2a8e11a8931275e702abeb69f584712f7cb43a` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26229602117/job/77185950335) |
| `MTP-70` | Market stream public read-only evidence 和 order stream blocked / simulated / future-only evidence | [#139 MTP-70 add live stream monitoring evidence](https://github.com/atxinbao/MTPRO/pull/139) | `f7a80fbda84ceeef442efd6b0961fc119faf9eb7` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26230970162/job/77190937330) |
| `MTP-71` | Latency / error / degraded state monitoring evidence read model | [#140 MTP-71 add latency error degraded monitoring evidence](https://github.com/atxinbao/MTPRO/pull/140) | `e616e669bcce6ea25f1bf4b6895cde887a7df6c4` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26233672605/job/77200739555) |
| `MTP-72` | Dashboard / Report live monitoring evidence surface、`Live Monitoring` Workbench group 和 Dashboard smoke `liveMonitoringHealth=blocked` / `liveMonitoringErrors=3` | [#141 MTP-72 wire live monitoring dashboard report evidence](https://github.com/atxinbao/MTPRO/pull/141) | `85d3fc353c5b2f748a8be309b113ebfa4c5b1a42` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26235131491/job/77206064975) |
| `MTP-73` | Event Timeline / Evidence Explorer live monitoring evidence preview、18 条 live monitoring timeline item 和 no live audit / incident replay / stop control boundary | [#143 MTP-73 wire live monitoring timeline preview](https://github.com/atxinbao/MTPRO/pull/143) | `14dad2be52bdb9acdfb2f839cf8095495e4977b0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26236738205/job/77211892709) |
| `MTP-74` | validation matrix、automation readiness、Dashboard smoke evidence、read-model-only boundary evidence 和 Stage Code Audit 输入材料收口 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Live monitoring validation evidence chain

`MTP-74-LIVE-MONITORING-VALIDATION-EVIDENCE-CHAIN`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-LIVE-MONITORING-CONSOLE` | MTP-68 定义 IA / terminology / status taxonomy；MTP-69 定义 runtime health / connection Core read model；MTP-70 定义 market stream / order stream blocked evidence；MTP-71 定义 latency / error / degraded evidence；MTP-72 接入 Dashboard / Report；MTP-73 接入 Event Timeline / Evidence Explorer preview；MTP-74 机械收口 automation readiness 和 stage audit input。 | 审计时确认实盘监控台仍是 read-model-only evidence surface，不启动 live runtime，不连接真实网络，不接 signed endpoint、account endpoint、listenKey、broker adapter 或 `LiveExecutionAdapter`。 |
| `TVM-REPORT-EVIDENCE` | MTP-72 把 live monitoring evidence 汇总进 `ReportViewModel.liveMonitoringEvidence`，并在 Dashboard Report section 增加 `Monitoring` 指标。 | 审计时确认 Report 只消费 App read model / ViewModel，不读取 adapter、Runtime object、SQLite / DuckDB schema、API key、account payload 或 broker state。 |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | MTP-72 把 live monitoring evidence 接入 Workbench `Live Monitoring` 只读组；MTP-73 把同一 read model 接入 Event Timeline / Evidence Explorer preview。 | 审计时确认 Workbench / Event Timeline 没有新增 live command、order-level command、risk command、position command、query language、live audit、incident replay、stop control、交易按钮或表单。 |
| Dashboard smoke | MTP-73 后 `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`。 | 审计时确认 smoke 能定位八个 Dashboard sections、readModelOnly / workbenchReadModelOnly flags、session-level controls、Live blocked gates、Live monitoring health 和 Live monitoring error count。 |
| Deterministic tests | Core tests 覆盖 MTP-69 / MTP-70 / MTP-71 deterministic fixtures 和 forbidden capability rejection；App tests 覆盖 MTP-72 Dashboard / Report ViewModel、MTP-73 Event Timeline preview、Dashboard smoke、Codable snapshot、no command / no button / no schema / no adapter / no runtime / no broker / no trading execution。 | 审计时确认 deterministic validation 不依赖真实 Binance 网络、secret、account endpoint、listenKey、broker、真实订单、production telemetry、external metrics service、production runtime operations 或人工验收。 |

## Automation readiness evidence

`MTP-74-AUTOMATION-READINESS-STAGE-CLOSEOUT`

- `checks/automation-readiness.sh` 检查本 MTP-74 输入材料、latest verification summary、Trading Validation Matrix、validation plan、Live monitoring console contract、frontend ViewModel contract、product surface map、Core / App source anchors、Core / App deterministic test anchors 和 Dashboard smoke evidence。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档 / 验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-74 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 本 issue 加固 MTP-74 stage audit input、contract、matrix、validation plan、latest summary、source / test anchors 和 Dashboard smoke anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | MTP-73 已通过 | 已有 Dashboard smoke evidence：`sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=24; liveBlockedGates=6; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；146 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只建立 Live monitoring console 的 read-model-only evidence chain；不实现真实 Live trading、execution control、risk control、live audit、incident replay 或 stop control。
- API key、secret storage、request signature、signed endpoint、account endpoint、listenKey user data stream 和 real account payload 均保持 forbidden / future gate。
- Binance 当前仍只允许 public read-only market data；required validation 不依赖真实 Binance 网络、真实 API key、真实账户或 broker state。
- Future private user data stream、future broker session、broker / exchange execution adapter、execution venue connection、`LiveExecutionAdapter`、real order submit / cancel / replace、execution report、broker fill、reconciliation、OMS、real account state 和 broker position sync 均未实现。
- Live monitoring evidence 只表达 runtime health、connection、market stream、order stream、latency、error、degraded state 和 operations evidence 的只读快照，不提供 command surface。
- Dashboard / Report / Event Timeline 只展示 read model / ViewModel，不提供 live command、交易按钮、表单、order-level command、risk command、position command、query language、live audit、incident replay、stop control、alerting、paging、reconnect、incident command 或自动恢复。
- App / Dashboard 不暴露 adapter request、adapter instance、Runtime object、actor、workflow object、SQLite / DuckDB schema、SQL、ORM、table、column 或 persistence adapter direct read。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-74 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 “实盘监控台” 的 read-model-only monitoring evidence surface 已建立；不代表真实 Live trading 或 production runtime 已实现。 |
| `BLUEPRINT.md` | Future Live execution / risk / audit / stop controls 仍保持 Future Construction Zones / 未来建设区；本 Project 只增加 monitoring evidence surface 的事实证据。 |
| `docs/environment.md` | 本 Project 未新增 required validation 入口、secret 读取、broker credential、外部写能力、production telemetry 或网络必需验证；统一验证入口仍是 `bash checks/run.sh`。 |
| `docs/architecture.md` | Core / App / Dashboard 边界继续成立；App / Dashboard 只消费 read model / ViewModel，不读取 adapter、Runtime object、SQLite / DuckDB schema 或真实账户 / broker state。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条同步已发生事实；MTP-74 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-68`、`MTP-69`、`MTP-70`、`MTP-71`、`MTP-72`、`MTP-73`、`MTP-74`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #137、#138、#139、#140、#141、#143 和 MTP-74 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：information architecture、runtime health / connection read model、market / order stream evidence、latency / error / degraded evidence、Dashboard / Report monitoring evidence surface、Event Timeline preview、Dashboard smoke `liveMonitoringHealth=blocked` / `liveMonitoringErrors=3`、API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、real order state machine、live command、trading button、query language、live audit、incident replay、stop control、schema leakage 和 command surface 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-74 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`docs/environment.md`、`docs/architecture.md`、`docs/roadmap.md`。
- Current Phase Progress Bar：Root Docs Refresh Gate closure 后由 `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出，不按 Project closure count 直接计算目标完成度。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
