# MTPRO Event-Driven Paper Trading Runtime v1 阶段审计输入材料

日期：2026-05-26

执行者：Codex

## 定位

`MTP-102-EVENT-DRIVEN-PAPER-RUNTIME-STAGE-AUDIT-INPUT`

本文档是 `MTPRO Event-Driven Paper Trading Runtime v1` 的 MTP-102 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-96`、`MTP-97`、`MTP-98`、`MTP-99`、`MTP-100`、`MTP-101`、`MTP-102` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-event-driven-paper-trading-runtime-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一 issue，不启动下一阶段 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、real account update、signed endpoint、account endpoint、listenKey、broker action、Live PRO Console、live command、order form、position command 或交易按钮。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Event-Driven Paper Trading Runtime v1`。
- Project ID：`113b4932-5e58-45a8-98ff-f6c4fc5cd3d8`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-event-driven-paper-trading-runtime-v1-2ac84562ae6f`。
- `MTP-96`、`MTP-97`、`MTP-98`、`MTP-99`、`MTP-100`、`MTP-101`：`Done`。
- `MTP-102`：`In Progress`。
- 当前 issue scope 仅限 Event Log / Replay / Report / Dashboard / Event Timeline evidence chain、validation matrix、automation readiness anchors、forbidden capability evidence、read-model-only boundary evidence、Dashboard smoke evidence 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-96` | TradingClock deterministic time、paper runtime kernel boundary、paper command intake、paper event emission 和 no live / signed / broker runtime baseline | [#190 MTP-96 define event-driven paper runtime kernel](https://github.com/atxinbao/MTPRO/pull/190) | `fa2e0ef2d4457a093ef796d66b933068a9bd9bac` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26404774215/job/77725406407) |
| `MTP-97` | Paper-only CommandBus / EventBus / MessageBus deterministic routing 和 replayable route evidence | [#192 MTP-97 paper runtime bus routing](https://github.com/atxinbao/MTPRO/pull/192) | `1936791faf8484fda072ccfef03dc20c88572cd6` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26406391227/job/77730618874) |
| `MTP-98` | Paper Pre-trade RiskEngine accepted / rejected decision、risk route evidence 和 no live account / broker upgrade | [#193 MTP-98 paper pretrade risk engine](https://github.com/atxinbao/MTPRO/pull/193) | `1123faef15a52b0e1d40254e5650f4d85c77c8a9` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26407878500/job/77735463504) |
| `MTP-99` | Paper-only local lifecycle coordinator、local order lifecycle transition facts 和 simulated fill precondition | [#194 MTP-99 paper local lifecycle coordinator](https://github.com/atxinbao/MTPRO/pull/194) | `1700c21b1c5794c1ab6a70a527d5c5a86fcf10a3` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26408949657/job/77738863221) |
| `MTP-100` | Simulated fill / fee / slippage deterministic model、partial / full fill evidence 和 Event Log / Replay fill facts | [#195 MTP-100 simulated fill fee slippage](https://github.com/atxinbao/MTPRO/pull/195) | `bd45a98d73b7422dded902e56a0e95374dd5729c` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26411644898/job/77747183669) |
| `MTP-101` | Paper account / portfolio / position projection v2、paper PnL snapshot 和 App read model consumption | [#196 MTP-101 paper account portfolio projection](https://github.com/atxinbao/MTPRO/pull/196) | `18a715851852dd67d3deb33564c111c2d3fcf63a` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26412976178/job/77751276011) |
| `MTP-102` | Event Log / Replay / Report / Dashboard / Event Timeline evidence chain、automation readiness 和 Stage Code Audit 输入材料收口 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Paper runtime validation evidence chain

`MTP-102-PAPER-RUNTIME-VALIDATION-EVIDENCE-CHAIN`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-PAPER-RUNTIME-KERNEL` | MTP-96 定义 TradingClock 和 kernel boundary；MTP-97 定义 paper-only bus routing；MTP-98 定义 paper pre-trade RiskEngine；MTP-99 定义 local lifecycle transition facts；MTP-100 定义 simulated fill / fee / slippage evidence；MTP-101 定义 replayed simulated fill -> paper account / portfolio / position / PnL projection；MTP-102 把 risk -> local lifecycle -> simulated fill -> account portfolio projection chain 接入 Report / Dashboard / Event Timeline 并收口 stage audit input。 | 审计时确认 paper runtime evidence 全部来自 append-only Event Log / Replay 和 read model / ViewModel，不读取 Runtime object、Persistence schema、adapter request、broker state、真实账户或外部 execution venue。 |
| `TVM-REPORT-EVIDENCE` | `ReportViewModel` 输出 paper runtime replay、local lifecycle transition IDs、paper risk decision IDs、paper order IDs、simulated fill IDs、account portfolio snapshot IDs、gross notional、fee、slippage、cost impact、paper account、position 和 paper PnL evidence。 | 审计时确认 Report 只消费 App read model / ViewModel，不暴露 database schema、Runtime object、adapter request、broker action、real account state、execution report、broker fill 或交易授权。 |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | `DashboardShellSnapshot.smokeSummary` 输出 `paperRuntimeEvidence`、`paperWorkflowEvidence` 和 `paperPortfolioImpact`；Event Timeline 输出 `Paper local lifecycle transition`、`Simulated fill evidence` 和 `Paper account portfolio projection`。 | 审计时确认 Workbench / Dashboard / Event Timeline 没有新增 order form、order-level command、position command、live command、Live PRO Console、stop button、trading button、query language、adapter status、runtime status 或 schema browser。 |
| Dashboard smoke | MTP-102 后 smoke summary 增加 `paperRuntimeEvidence`、`paperWorkflowEvidence` 和 `paperPortfolioImpact`，同时保留 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset`、Live blocked gates、Live execution control gates、Live risk gates、Live incident / stop gates、Live monitoring health 和 Live monitoring errors。 | 审计时确认 smoke 能定位八个 Dashboard sections、read-model-only boundary、Paper runtime chain 和 Live forbidden gates。 |
| Deterministic tests | `testMTP102PaperRuntimeEvidenceChainFeedsReportDashboardAndEventTimeline` 覆盖 risk publication replay evidence、local lifecycle publication replay evidence、partial / full simulated fill publication、account portfolio projection、Report / Dashboard / Event Timeline read-model-only evidence 和 no live / broker / trading authorization flags。 | 审计时确认 deterministic validation 不依赖真实 Binance 网络、secret、account endpoint、listenKey、broker、真实账户、production runtime operations 或人工验收。 |

## Forbidden capability evidence

MTP-102 继续固定以下能力在当前 Project 中全部禁止：

- no API key。
- no secret storage。
- no signed endpoint。
- no account endpoint。
- no listenKey。
- no broker action。
- no broker adapter。
- no exchange execution adapter。
- no `LiveExecutionAdapter`。
- no OMS。
- no broker router。
- no real order state machine。
- no real order submit / cancel / replace。
- no execution report runtime / ingestion。
- no broker fill runtime / recorder / fact。
- no reconciliation runtime。
- no real account update。
- no real account balance read。
- no broker position sync。
- no margin。
- no leverage。
- no real PnL / equity。
- no live risk runtime。
- no production runtime operation。
- no Live PRO Console。
- no live command。
- no order-level command UI。
- no position command。
- no order form。
- no stop button。
- no trading button。

## Read-model-only boundary evidence

- `PaperExecutionWorkflowEvidenceSummary` 只从 append-only replay summary 和 event envelopes 派生 evidence，不读取 Runtime object、Persistence schema、adapter request、broker state 或真实账户。
- `ReportViewModel` 只消费 `ReportReadModel` artifact，新增 paper runtime fields 只表示 local lifecycle、simulated fill、fee / slippage、account portfolio snapshot 和 paper PnL evidence。
- `PaperWorkflowEvidenceExplorerViewModel` 只展示 Event Timeline evidence link，不提供 command surface、query language、order form、cancel / replace、position command、live command 或交易按钮。
- `DashboardShellSnapshot` 只聚合 ViewModel metrics / details / smoke handles；`paperRuntimeEvidence`、`paperWorkflowEvidence` 和 `paperPortfolioImpact` 是 read-model smoke handles，不表示真实执行、真实账户或 broker state。

## Automation readiness evidence

`MTP-102-AUTOMATION-READINESS-STAGE-CLOSEOUT`

- `checks/automation-readiness.sh` 检查本 MTP-102 输入材料、latest verification summary、Trading Validation Matrix、validation plan、paper runtime contract、App source anchors、focused App test anchor 和 Dashboard smoke handles。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交代码、文档、验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-102 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter MTP102` | pass | 1 个 App focused test 通过，覆盖 risk -> local lifecycle -> simulated fill -> account portfolio projection deterministic replay chain、Report / Dashboard / Event Timeline read-model-only evidence 和 no live / broker / trading authorization flags。 |
| `bash checks/automation-readiness.sh` | pass | MTP-102 stage audit input、contract、matrix、validation plan、latest summary、source / test anchors 和 Dashboard smoke handles 均通过机械检查，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；Swift tests 223 个通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只建立 Event-Driven Paper Trading Runtime 的 deterministic paper evidence chain；不实现真实交易 runtime。
- API key、secret storage、request signature、signed endpoint、account endpoint、listenKey user data stream、real account payload 和 broker state 均保持 forbidden / future gate。
- Binance 当前仍只允许 public read-only market data；required validation 不依赖真实 Binance 网络、真实 API key、真实账户或 broker state。
- Future broker / exchange execution adapter、execution venue connection、`LiveExecutionAdapter`、real order submit / cancel / replace、execution report ingestion、broker fill fact、reconciliation runtime、OMS、Live PRO Console、live command、order form、position command、stop button 和 trading button 均未实现。
- Paper local lifecycle transition 只表示本地 paper-only order state，不表示 exchange accepted、broker accepted、broker submitted 或真实订单状态。
- Simulated fill / fee / slippage evidence 只表示 deterministic paper-only fill evidence，不代表真实成交、execution report、broker fill、account update 或 broker position。
- Paper account / portfolio / position projection 只从 replayed simulated fill evidence 派生，不读取真实账户余额、margin、leverage、broker position 或 account endpoint。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-102 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 Event-Driven Paper Trading Runtime 的 local paper evidence chain 已闭环；不代表真实 broker / OMS / execution runtime / Live PRO Console 已实现。 |
| `BLUEPRINT.md` | Paper runtime evidence chain 可以作为 Research -> Backtest -> Paper 一致性工作台的阶段证据；Live / signed endpoint / broker / OMS 仍属于 Future Construction Zones。 |
| `environment.md` | 本 Project 未新增 required validation 入口、secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或网络必需验证；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | Core / Persistence / App / Dashboard 边界继续成立；App / Dashboard 只消费 read model / ViewModel，不读取 adapter、Runtime object、SQLite / DuckDB schema、真实账户 / broker state 或 production operations state。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条同步已发生事实；MTP-102 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-96`、`MTP-97`、`MTP-98`、`MTP-99`、`MTP-100`、`MTP-101`、`MTP-102`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #190、#192、#193、#194、#195、#196 和 MTP-102 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：TradingClock、paper runtime kernel、bus routing、paper risk、local lifecycle、simulated fill / fee / slippage、paper account / portfolio / position projection、Report / Dashboard / Event Timeline evidence chain、Dashboard smoke paper handles、API key、secret storage、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、execution report ingestion、broker fill fact、reconciliation、real account update、Live PRO Console、live command、order form、position command、stop button、trading button、schema leakage 和 command surface 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-102 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`。
- Current Phase Progress Bar：Root Docs Refresh Gate closure 后由 `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出，不按 Project closure count 直接计算目标完成度。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
