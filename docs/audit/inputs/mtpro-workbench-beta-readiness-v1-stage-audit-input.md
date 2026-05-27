# MTPRO Workbench Beta Readiness v1 阶段审计输入材料

日期：2026-05-27

执行者：Codex

## 定位

`MTP-125-WORKBENCH-BETA-READINESS-STAGE-CLOSEOUT`

本文档是 `MTPRO Workbench Beta Readiness v1` 的 MTP-125 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

`MTP-125-STAGE-AUDIT-INPUT-MATERIAL`

本文档只准备 stage audit input material，集中收口 validation evidence、automation readiness、Project evidence chain、forbidden capability audit 和 Parent Codex handoff checklist。

`MTP-125-NO-FINAL-STAGE-CODE-AUDIT`

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-118`、`MTP-119`、`MTP-120`、`MTP-121`、`MTP-122`、`MTP-123`、`MTP-124`、`MTP-125` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-workbench-beta-readiness-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一阶段，不启动 `@002 / PAR`，不启动下一阶段 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、production release、notarization、App Store distribution、auto-update、production operations、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、live command、order-level command UI 或交易按钮。

`MTP-125-WORKBENCH-BETA-READINESS-STAGE-AUDIT-INPUT`

本文档的审计输入范围只覆盖 `MTPRO Workbench Beta Readiness v1`，不把 closeout material 写成下一阶段 execution authorization。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Workbench Beta Readiness v1`。
- Project ID：`087534ad-f2eb-4aba-b29e-c52bcc9fe6e8`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-workbench-beta-readiness-v1-30b7311e382e`。
- `MTP-118`、`MTP-119`、`MTP-120`、`MTP-121`、`MTP-122`、`MTP-123`、`MTP-124`：`Done`。
- `MTP-125`：`In Progress`。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、Project evidence chain、forbidden capability evidence、no Graphify / no Figma / no unauthorized Linear mutation confirmation 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-118` | Workbench beta readiness terminology、beta acceptance boundary、local-only beta demo path、L1 / L1.5 / L2 / L2+ handoff boundary 和 forbidden capability baseline | [#222 Define MTP-118 Workbench beta readiness contract](https://github.com/atxinbao/MTPRO/pull/222) | `0eadb7b2b261182ce8f1a110374423f65906697f` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26469848346/job/77940031188) |
| `MTP-119` | local launch / install / environment verification path、Dashboard launch runbook、local smoke expectation 和 troubleshooting boundary | [#223 MTP-119 Add local launch verification path](https://github.com/atxinbao/MTPRO/pull/223) | `4e6ba2c1de91e6d5abe39278f3b3370e6920d1ed` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26472273367/job/77948596849) |
| `MTP-120` | demo scenario selection、dataset / fixture version lock、scenario replay fixture wiring、checksum / freshness evidence 和 L1.5 / L2 relationship | [#224 MTP-120 Add demo scenario selection and fixture wiring](https://github.com/atxinbao/MTPRO/pull/224) | `4d618db6d1ab2fec48e033c04432eb59ac8e591c` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26474595749/job/77956711837) |
| `MTP-121` | Workbench first-run / default demo state、read-model-only Dashboard state、fallback states 和 default demo smoke handles | [#225 MTP-121 Add Workbench first-run default demo state](https://github.com/atxinbao/MTPRO/pull/225) | `a219c42fc24ffd6097de92dfac7a4d6f9f86ec04` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26476731737/job/77964113322) |
| `MTP-122` | Report / Dashboard / Events beta acceptance path、same demo scenario trace、portfolio parity trace 和 acceptance smoke handles | [#226 Add MTP-122 beta acceptance path](https://github.com/atxinbao/MTPRO/pull/226) | `812b269338f4198de66df74c14b83e66de21ab88` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26478783327/job/77970939146) |
| `MTP-123` | reproducible beta acceptance checklist / script、operator transcript boundary、stable smoke handles 和 failure triage hints | [#227 MTP-123 add reproducible beta acceptance workflow](https://github.com/atxinbao/MTPRO/pull/227) | `b3580a78a7cbdb8be7c71273a1509a446c18be36` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26480288133/job/77975796326) |
| `MTP-124` | docs index、operator guide、demo workflow guide、known limitations、forbidden capability boundary 和 beta-not-live-readiness docs | [#228 MTP-124 add Workbench beta operator docs](https://github.com/atxinbao/MTPRO/pull/228) | `1065c014499dd259d8da14b1ac99b7b332cf05ed` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26481501933/job/77979564876) |
| `MTP-125` | validation matrix、automation readiness anchors、forbidden capability evidence、Project evidence chain 和 Stage Code Audit 输入材料收口 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Workbench beta readiness validation evidence chain

`MTP-125-WORKBENCH-BETA-READINESS-VALIDATION-EVIDENCE-CHAIN`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-WORKBENCH-BETA-READINESS` | MTP-118 定义 Workbench beta readiness contract；MTP-119 固定 local launch / install / environment verification path；MTP-120 固定 local deterministic demo scenario / fixture wiring；MTP-121 将 demo fixture 接入 first-run default demo state；MTP-122 将同一 demo scenario 串成 Report / Dashboard / Events acceptance path；MTP-123 固定 reproducible beta acceptance checklist / script；MTP-124 增加 docs index、operator guide 和 demo workflow guide；MTP-125 收口 validation matrix、automation readiness 和 stage audit input。 | 审计时确认 L2+ Workbench Beta Readiness 只把 L1 / L1.5 / L2 已完成 evidence productize 成 local macOS Workbench demo / acceptance path，不新增 engine core capability、Runtime replay job、production release、live readiness 或真实交易能力。 |
| `TVM-REPORT-EVIDENCE` | MTP-122 将 Scenario Replay evidence、Simulated Exchange / Backtest Parity evidence、portfolio projection parity evidence 和 first-run default demo state 串成 Report beta acceptance summary。 | 审计时确认 Report 只消费 App read model / ViewModel，不读取 Runtime object、Persistence schema、Adapter request、secret、signed endpoint、account endpoint、listenKey、broker payload、real account state、execution report 或 broker fill。 |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | MTP-121 / MTP-122 / MTP-123 / MTP-124 通过 Dashboard smoke、Workbench beta acceptance path、Events trace、operator checklist 和 docs guide 固定 local beta acceptance surface。 | 审计时确认 Workbench / Dashboard / Events 没有新增 order form、order-level command、live command、Live PRO Console、trading button、download command、repair command、Runtime command、database console、query language、Graphify update 或 Figma change。 |
| Dashboard smoke | MTP-124 后 smoke summary 包含 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset`、`timelineItems=64`、`scenarioReplayEvidence=1`、`scenarioQualityGates=6`、`simulatedParityEvidence=1`、`defaultDemoState=default demo`、`defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaFirstRunFallbacks=3`、`betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。 | 审计时确认 smoke 能定位八个 Dashboard sections、read-model-only boundary、default demo state、beta acceptance path 和 Live forbidden gates。 |
| Deterministic tests / scripts | MTP-120 Core tests、MTP-121 App tests、MTP-122 App test、MTP-123 beta acceptance script 和 MTP-124 docs validation 共同覆盖 deterministic fixture、first-run state、acceptance path、operator reproducibility 和 docs handoff。 | 审计时确认 deterministic validation 不依赖真实 Binance 网络、secret、account endpoint、listenKey、broker、真实账户、production release pipeline、Graphify、Figma 或人工外包验收。 |

## Forbidden capability evidence

`MTP-125-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-118 至 MTP-124 继续固定以下能力在当前 Project 中全部禁止：

- no production release。
- no release package / notarization / App Store distribution。
- no auto-update。
- no production deployment / cloud operations。
- no production operations command。
- no engine core capability expansion。
- no Runtime replay job / production scheduler。
- no production data platform / remote catalog / automatic downloader / repair command。
- no database schema exposure / database console / query language。
- no Runtime object exposure / Core object inspector / Adapter request exposure。
- no secret read。
- no API key。
- no signed endpoint。
- no account endpoint。
- no listenKey。
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
- no real account balance read。
- no broker position sync。
- no margin。
- no leverage。
- no real PnL。
- no live readiness / live runtime。
- no Live PRO Console。
- no live command。
- no order-level command UI。
- no order form。
- no trading button。
- no emergency stop / shutdown / restore。
- no Graphify update。
- no Figma modification。
- no unauthorized Linear mutation。

## Read-model-only boundary evidence

`MTP-125-BETA-READINESS-EVIDENCE-COMPLETE`

- `WorkbenchBetaDemoScenarioSelection` / `WorkbenchBetaDemoFixtureEvidence` 只固定 local deterministic demo input，不新增 network download、fixture records、Runtime replay job 或 production data catalog。
- `WorkbenchBetaFirstRunReadModel` / `WorkbenchBetaFirstRunViewModel` 只复制 demo fixture evidence 进入 App read model / ViewModel，不直接暴露 Core object、Runtime object、Persistence schema 或 Adapter request。
- `WorkbenchBetaAcceptancePathReadModel` / `WorkbenchBetaAcceptancePathViewModel` 只把 Report、Dashboard 和 Events 的 same-scenario evidence 串成 read-model-only acceptance path，不新增 command surface。
- `checks/workbench-beta-acceptance.sh` 只编排 local commands 和 stable smoke handle assertions，operator transcript 写入 `.codex/beta-acceptance/<run-id>/` 且不得进入 PR。
- `docs/index.md`、`docs/validation/workbench-beta-operator-guide.md` 和 `docs/validation/workbench-beta-demo-workflow-guide.md` 只服务 local operator handoff，不是 production release docs、Live PRO Console docs 或下一阶段 execution 授权。
- `DashboardShellSnapshot` 的 `defaultDemoState`、`defaultDemoScenario`、`betaAcceptancePaths`、`betaAcceptanceScenario` 和 `betaAcceptanceTrace` 是 smoke handles，不表示 scenario selector、download action、repair command、order command、live command、trading authorization 或 Live PRO Console。

## Automation readiness evidence

`MTP-125-AUTOMATION-READINESS-STAGE-CLOSEOUT`

- `checks/automation-readiness.sh` 检查本 MTP-125 输入材料、latest verification summary、Trading Validation Matrix、validation plan、Workbench Beta Readiness contract、automation readiness doc、MTP-118 至 MTP-124 anchors、PR #222 至 PR #228 evidence 和 Dashboard smoke handles。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档、验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-125 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 机械检查 MTP-125 stage audit input、contract、matrix、validation plan、latest summary、automation readiness doc、MTP-118 至 MTP-124 anchors、PR evidence 和 Dashboard smoke handles，输出 `MTPRO automation readiness checks passed.`。 |
| `git diff --check` | pass | MTP-125 diff 无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build、Dashboard smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=64; scenarioReplayEvidence=1; scenarioQualityGates=6; simulatedParityEvidence=1; defaultDemoState=default demo; defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario; betaFirstRunFallbacks=3; betaAcceptancePaths=1; betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario; betaAcceptanceTrace=5; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；Swift tests 267 个通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

`MTP-125-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

- 本 Project 只建立 local macOS Workbench beta demo / acceptance path，不实现 production release。
- Local install 只表示 SwiftPM dependency resolution 和本地 `.build` artifact，不表示 `.app` installer、`.pkg`、`.dmg`、notarized artifact、App Store build、auto-update channel 或 production deployment。
- Demo scenario 固定为 `mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`；不提供 scenario selector、remote catalog、download action 或 repair command。
- Report / Dashboard / Events beta acceptance path 只消费 App read model / ViewModel，不提供 command surface、query language、database console、Runtime action、live command、order form 或交易按钮。
- Operator transcript 只写入 `.codex/beta-acceptance/<run-id>/`，不得进入 PR，不包含 secret、API key、account endpoint、listenKey、broker credential、signed request 或 production operations state。
- Binance 边界仍是 public read-only market data；required validation 不依赖真实 Binance 网络、真实 API key、真实账户或 broker state。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。
- 本 issue 不运行 Graphify，不修改 Figma，不修改 Linear status。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-125 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 L2+ Workbench Beta Readiness 的 local macOS Workbench demo / acceptance path 已闭环；不代表 production release、real account readiness、broker readiness、Live PRO Console readiness、live runtime readiness 或真实交易授权。 |
| `BLUEPRINT.md` | Workbench Beta Readiness 可以作为 L1 / L1.5 / L2 evidence productization 的本地 operator acceptance 证据；Future Live、signed endpoint、broker、OMS、production release 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `docs/environment.md` | 本 Project 未新增 required validation 入口、secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或 production operations；统一验证入口仍是 `bash checks/run.sh`。 |
| `docs/architecture.md` | Core / App / Dashboard 边界继续成立；beta readiness evidence 沿 local deterministic fixture -> Core value evidence -> App read model / ViewModel -> Workbench evidence surface -> operator checklist / docs handoff 流动，不读取 adapter、Runtime object、SQLite / DuckDB schema、真实账户 / broker state 或 production operations state。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条同步已发生事实；MTP-125 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-118`、`MTP-119`、`MTP-120`、`MTP-121`、`MTP-122`、`MTP-123`、`MTP-124`、`MTP-125`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #222、#223、#224、#225、#226、#227、#228 和 MTP-125 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：Workbench beta readiness terminology、local launch / install path、demo scenario fixture wiring、first-run default demo state、Report / Dashboard / Events acceptance path、reproducible checklist / script、docs index、operator guide、demo workflow guide、Dashboard smoke beta handles、production release、notarization、App Store distribution、auto-update、production deployment、cloud operations、Graphify update、Figma change、Linear mutation、signed endpoint、account endpoint、listenKey、secret read、broker action、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、Live PRO Console、live command、order form、order-level command UI 和 trading button 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-125 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`docs/environment.md`、`docs/architecture.md`、`docs/roadmap.md`。
- Current Phase Progress Bar：Root Docs Refresh Gate closure 后由 `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出，不按 Project closure count 直接计算目标完成度。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
