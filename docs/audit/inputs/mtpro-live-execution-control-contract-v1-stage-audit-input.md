# MTPRO Live Execution Control Contract v1 阶段审计输入材料

日期：2026-05-22

执行者：Codex

## 定位

`MTP-81-LIVE-EXECUTION-CONTROL-STAGE-AUDIT-INPUT`

本文档是 `MTPRO Live Execution Control Contract v1` 的 MTP-81 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-75`、`MTP-76`、`MTP-77`、`MTP-78`、`MTP-79`、`MTP-80`、`MTP-81` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-live-execution-control-contract-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一 issue，不启动下一阶段 `symphony-issue`，不实现 API key / secret storage、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine / OMS、真实 submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation、live command、order form、order-level command UI 或交易按钮。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Live Execution Control Contract v1`。
- Project ID：`01809db3-6ab7-4007-80d7-c99de7bb10e3`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-live-execution-control-contract-v1-cca4c0c8aadd`。
- `MTP-75`、`MTP-76`、`MTP-77`、`MTP-78`、`MTP-79`、`MTP-80`：`Done`。
- `MTP-81`：`In Progress`。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、Dashboard smoke evidence、forbidden capability evidence、read-model-only boundary evidence 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-75` | Live execution control terminology、real order command taxonomy、paper / real command isolation 和 no executable command surface | [#150 MTP-75 define live execution control taxonomy](https://github.com/atxinbao/MTPRO/pull/150) | `68afc43f2d27cf67d6b37d6addc408aca25b0d2c` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26244136671/job/77237939245) |
| `MTP-76` | Submit / cancel / replace future gates、forbidden capability tests 和 paper intent no real command upgrade | [#151 MTP-76 define submit cancel replace gates](https://github.com/atxinbao/MTPRO/pull/151) | `1a2afd51459bd969bdf9e5878886e494661148de` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26245126213/job/77241360328) |
| `MTP-77` | Execution report / broker fill / reconciliation future gates、forbidden capability tests 和 blocked evidence | [#153 MTP-77 define report fill reconciliation gates](https://github.com/atxinbao/MTPRO/pull/153) | `10aa66e072a432dd9fe2dfd5e5c2268a376b8b14` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26246398281/job/77245774262) |
| `MTP-78` | Paper order intent / simulated fill 与 future real order command isolation contract、Report / Dashboard / Timeline read-model-only evidence | [#156 MTP-78 define paper real command isolation](https://github.com/atxinbao/MTPRO/pull/156) | `1cefcbe919c4d3f07caf80a2301e064bdc943ef0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26247906352/job/77250959412) |
| `MTP-79` | Read-model-only `LiveExecutionControlBlockedEvidence`、blocked reason deterministic snapshot 和 forbidden capability tests | [#158 MTP-79 add live execution control blocked evidence](https://github.com/atxinbao/MTPRO/pull/158) | `2f041526a6ea7c6930681129f369977acb4ec66e` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26249448598/job/77256403186) |
| `MTP-80` | Dashboard / Report / Event Timeline execution-control blocked evidence 展示面和 Dashboard smoke `liveExecutionControlGates=7` | [#159 MTP-80 wire execution control blocked evidence](https://github.com/atxinbao/MTPRO/pull/159) | `a68cbe5dccc1f310c684186ecdcd743b11b25e3b` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26256108547/job/77279050533) |
| `MTP-81` | validation matrix、automation readiness、Dashboard smoke、forbidden capability evidence、read-model-only boundary evidence 和 Stage Code Audit 输入材料收口 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Live execution control validation evidence chain

`MTP-81-LIVE-EXECUTION-CONTROL-VALIDATION-EVIDENCE-CHAIN`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-LIVE-EXECUTION-CONTROL` | MTP-75 定义 terminology / taxonomy；MTP-76 定义 submit / cancel / replace future gates；MTP-77 定义 execution report / broker fill / reconciliation future gates；MTP-78 定义 paper / real command isolation；MTP-79 定义 read-model-only blocked evidence；MTP-80 接入 Dashboard / Report / Event Timeline；MTP-81 机械收口 automation readiness 和 stage audit input。 | 审计时确认实盘执行控制仍是 Future / forbidden boundary 和 read-model-only blocked evidence，不启动执行控制 runtime，不接 signed endpoint、account endpoint、listenKey、broker adapter 或 `LiveExecutionAdapter`。 |
| `TVM-REPORT-EVIDENCE` | MTP-80 把 execution-control blocked evidence 汇总进 `ReportViewModel.liveExecutionControlBlockedEvidence`，并在 Dashboard Report section 增加 `Execution control` 指标。 | 审计时确认 Report 只消费 App read model / ViewModel，不读取 adapter、Runtime object、SQLite / DuckDB schema、API key、account payload、broker state、execution report 或 broker fill。 |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | MTP-80 把 execution-control blocked evidence 接入 Workbench `Live Execution Control` 只读组和 Event Timeline / Evidence Explorer preview。 | 审计时确认 Workbench / Event Timeline 没有新增 live command、order-level command、order form、交易按钮、broker action、incident fallback command、query language 或真实交易授权。 |
| Dashboard smoke | MTP-80 后 `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`。 | 审计时确认 smoke 能定位八个 Dashboard sections、readModelOnly / workbenchReadModelOnly flags、session-level controls、Live blocked gates、Live execution control gates、Live monitoring health 和 Live monitoring error count。 |
| Deterministic tests | Core tests 覆盖 MTP-75 / MTP-76 / MTP-77 / MTP-78 / MTP-79 deterministic fixtures 和 forbidden capability rejection；App tests 覆盖 MTP-78 / MTP-80 Dashboard / Report / Event Timeline read-model-only evidence、Dashboard smoke、Codable snapshot、no command / no order form / no trading button / no schema / no adapter / no runtime / no broker / no trading execution。 | 审计时确认 deterministic validation 不依赖真实 Binance 网络、secret、account endpoint、listenKey、broker、真实订单、production runtime operations 或人工验收。 |

## Forbidden capability evidence

MTP-81 继续固定以下能力在当前 Project 中全部禁止：

- no API key。
- no secret storage。
- no signed endpoint。
- no account endpoint。
- no listenKey。
- no broker adapter。
- no exchange execution adapter。
- no `LiveExecutionAdapter`。
- no real order state machine。
- no OMS。
- no real submit / cancel / replace。
- no signed command request。
- no execution report parser / ingestion。
- no broker fill recorder / event fact。
- no reconciliation service / runtime。
- no incident fallback automation。
- no account sync。
- no real account balance read。
- no broker position sync。
- no live command。
- no order-level command UI。
- no order form。
- no trading button。

## Read-model-only boundary evidence

- `LiveExecutionControlBlockedEvidence` 只作为 Core deterministic read-model-only blocked evidence。
- `LiveExecutionControlBlockedEvidenceReadModel` 和 `LiveExecutionControlBlockedEvidenceViewModel` 只复制 Core blocked evidence，不读取 secret、schema、adapter 或 Runtime object。
- `ReportViewModel`、`DashboardShellSnapshot` 和 `PaperWorkflowEvidenceExplorerViewModel` 只消费 read model / ViewModel，不暴露 persistence schema、adapter request、Runtime object、broker action、execution report ingestion、broker fill recorder、reconciliation runtime 或 live command surface。
- Dashboard smoke 的 `liveExecutionControlGates=7` 只表示七个 execution-control gates 仍被阻断，不表示真实执行控制能力已实现。

## Automation readiness evidence

`MTP-81-AUTOMATION-READINESS-STAGE-CLOSEOUT`

- `checks/automation-readiness.sh` 检查本 MTP-81 输入材料、latest verification summary、Trading Validation Matrix、validation plan、Live execution control contract、Core / App source anchors、Core / App deterministic test anchors 和 Dashboard smoke evidence。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档 / 验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-81 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 本 issue 加固 MTP-81 stage audit input、contract、matrix、validation plan、latest summary、source / test anchors 和 Dashboard smoke anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | MTP-80 已通过 | 已有 Dashboard smoke evidence：`sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=31; liveBlockedGates=6; liveExecutionControlGates=7; liveMonitoringHealth=blocked; liveMonitoringErrors=3`；164 个 XCTest 通过，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只建立 Live execution control 的 Future / forbidden contract、blocked evidence 和 read-model-only evidence surface；不实现真实 Live trading、execution control runtime、risk control、live audit、incident replay 或 stop control。
- API key、secret storage、request signature、signed endpoint、account endpoint、listenKey user data stream 和 real account payload 均保持 forbidden / future gate。
- Binance 当前仍只允许 public read-only market data；required validation 不依赖真实 Binance 网络、真实 API key、真实账户或 broker state。
- Future broker / exchange execution adapter、execution venue connection、`LiveExecutionAdapter`、real order submit / cancel / replace、execution report、broker fill、reconciliation、OMS、real account state、broker position sync 和 incident fallback automation 均未实现。
- Execution-control blocked evidence 只表达 submit、cancel、replace、execution report、broker fill、reconciliation 和 incident fallback 仍被阻断，不提供 command surface。
- Dashboard / Report / Event Timeline 只展示 read model / ViewModel，不提供 live command、交易按钮、表单、order-level command、signed command request、broker action、execution report ingestion、broker fill recorder、reconciliation runtime、incident fallback command 或真实交易授权。
- App / Dashboard 不暴露 adapter request、adapter instance、Runtime object、actor、workflow object、SQLite / DuckDB schema、SQL、ORM、table、column 或 persistence adapter direct read。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-81 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明“实盘执行控制”切片的 contract / boundary / blocked evidence 输入已建立；不代表真实 Live trading、真实订单命令或 production runtime 已实现。 |
| `BLUEPRINT.md` | Future Live execution / risk / audit / stop controls 仍保持 Future Construction Zones / 未来建设区；本 Project 只增加 execution-control contract 和 blocked evidence 的事实证据。 |
| `docs/environment.md` | 本 Project 未新增 required validation 入口、secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey 或网络必需验证；统一验证入口仍是 `bash checks/run.sh`。 |
| `docs/architecture.md` | Core / App / Dashboard 边界继续成立；App / Dashboard 只消费 read model / ViewModel，不读取 adapter、Runtime object、SQLite / DuckDB schema 或真实账户 / broker state。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条同步已发生事实；MTP-81 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-75`、`MTP-76`、`MTP-77`、`MTP-78`、`MTP-79`、`MTP-80`、`MTP-81`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #150、#151、#153、#156、#158、#159 和 MTP-81 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：terminology / taxonomy、submit / cancel / replace future gates、execution report / broker fill / reconciliation future gates、paper / real command isolation、read-model-only blocked evidence、Dashboard / Report / Event Timeline evidence surface、Dashboard smoke `liveExecutionControlGates=7`、API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation、schema leakage、command surface、order form 和交易按钮禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-81 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`docs/environment.md`、`docs/architecture.md`、`docs/roadmap.md`。
- Current Phase Progress Bar：Root Docs Refresh Gate closure 后由 `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出，不按 Project closure count 直接计算目标完成度。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
