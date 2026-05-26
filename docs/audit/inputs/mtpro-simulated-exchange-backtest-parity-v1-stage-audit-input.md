# MTPRO Simulated Exchange / Backtest Parity v1 阶段审计输入材料

日期：2026-05-27

执行者：Codex

## 定位

`MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-AUDIT-INPUT`

本文档是 `MTPRO Simulated Exchange / Backtest Parity v1` 的 MTP-117 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-110`、`MTP-111`、`MTP-112`、`MTP-113`、`MTP-114`、`MTP-115`、`MTP-116`、`MTP-117` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-simulated-exchange-backtest-parity-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一 issue，不启动下一阶段 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、matching runtime、order execution runtime、portfolio projection runtime、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、live command、order-level command UI 或交易按钮。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Simulated Exchange / Backtest Parity v1`。
- Project ID：`95e9fece-089d-456b-80b7-df2c858e9b39`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-simulated-exchange-backtest-parity-v1-92888a913f17`。
- `MTP-110`、`MTP-111`、`MTP-112`、`MTP-113`、`MTP-114`、`MTP-115`、`MTP-116`：`Done`。
- `MTP-117`：`In Progress`。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、forbidden live capability evidence、L2 parity evidence completeness、no Graphify / no Figma / no unauthorized Linear mutation confirmation 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-110` | Simulated Exchange / Backtest Parity terminology、target engine boundary、L1 / L1.5 / L2 handoff boundary 和 forbidden capability baseline | [#211 MTP-110 define simulated exchange parity boundary](https://github.com/atxinbao/MTPRO/pull/211) | `3d035990ada1ac70e7c1d3d7cfe92565a390ddf3` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26430803594/job/77803517150) |
| `MTP-111` | Shared backtest-paper order semantics、shared order input、simulated state taxonomy 和 paper lifecycle replay alignment | [#212 Add MTP-111 shared order semantics contract](https://github.com/atxinbao/MTPRO/pull/212) | `1a4e7dd5792e8f8f2dec2cca7dea9287cd20935a` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26431759032/job/77806239474) |
| `MTP-112` | Scenario replay deterministic matching input、ordering、matching event 和 repeatable output identity | [#213 Add MTP-112 deterministic matching model](https://github.com/atxinbao/MTPRO/pull/213) | `2041973249bb9729d1b39c1c773bbe33289f1700` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26433013303/job/77809888213) |
| `MTP-113` | Market / limit order simulated execution semantics、full fill / reject / expire outcomes 和 deterministic execution replay | [#214 MTP-113 market limit simulated execution semantics](https://github.com/atxinbao/MTPRO/pull/214) | `52cccab9a29e48ab7ee9199d6c7c2ca21ecf99fd` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26447862798/job/77870044984) |
| `MTP-114` | Partial / full fill parity、deterministic latency model、fee / slippage parity assumptions 和 repeatable cost evidence | [#215 Add MTP-114 partial fill latency fee slippage parity](https://github.com/atxinbao/MTPRO/pull/215) | `e99e69a820297dde6b97cbf64c62d79e1e63e78a` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26455038054/job/77886467077) |
| `MTP-115` | Simulated exchange event -> backtest / paper portfolio projection parity、position / cash / PnL / exposure summary 和 report input replay evidence | [#216 MTP-115 Add simulated exchange portfolio projection parity](https://github.com/atxinbao/MTPRO/pull/216) | `1a4239efd58f2b1129c9466d29d3be4c892fc3a6` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26457320340/job/77894937717) |
| `MTP-116` | Report / Dashboard / Events read-model-only parity evidence surface、timeline section 和 Dashboard smoke handle | [#217 MTP-116 Add parity evidence surface](https://github.com/atxinbao/MTPRO/pull/217) | `b5758969df69bcab6ae3a6571eafa314c1f86ba1` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26459955275/job/77904644538) |
| `MTP-117` | validation matrix、automation readiness anchors、forbidden live capability evidence、L2 parity evidence completeness 和 Stage Code Audit 输入材料收口 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## L2 parity validation evidence chain

`MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION-EVIDENCE-CHAIN`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY` | MTP-110 定义 terminology / target engine / handoff boundary；MTP-111 定义 shared backtest-paper order semantics；MTP-112 定义 scenario replay deterministic matching；MTP-113 定义 market / limit simulated execution semantics；MTP-114 定义 partial fill / latency / fee / slippage parity；MTP-115 定义 simulated exchange event -> backtest / paper portfolio projection parity；MTP-116 将 evidence 接入 Report / Dashboard / Events read-model-only surface；MTP-117 收口 validation matrix、automation readiness 和 stage audit input。 | 审计时确认 L2 parity evidence 全部来自本地 deterministic fixture / scenario replay / Core value object / App read model / ViewModel，不读取 Runtime object、Persistence schema、adapter request、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户或外部 execution venue。 |
| `TVM-REPORT-EVIDENCE` | MTP-116 将 scenario id、dataset / fixture version、replay window、matching result、partial / full / reject / expire outcomes、latency、fee、slippage、portfolio projection parity、report input version identity 和 source replay sequence 接入 Report evidence。 | 审计时确认 Report 只消费 App read model / ViewModel，不暴露 database schema、Runtime object、adapter request、broker action、real account state、execution report、broker fill 或交易授权。 |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | MTP-116 将 `simulated exchange parity evidence` 接入 Workbench summary / drill-down 与 Event Timeline / Evidence Explorer，Dashboard smoke 新增 `simulatedParityEvidence` handle。 | 审计时确认 Workbench / Dashboard / Event Timeline 没有新增 order form、order-level command、live command、Live PRO Console、trading button、database console、query language、Runtime action 或 adapter request surface。 |
| Dashboard smoke | MTP-116 后 smoke summary 包含 `simulatedParityEvidence=0`，同时保留 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset`、`timelineItems=42`、scenario replay handles、paper runtime handles、Live blocked gates、Live execution control gates、Live risk gates、Live incident / stop gates、Live monitoring health 和 Live monitoring errors。 | 审计时确认 smoke 能定位八个 Dashboard sections、read-model-only boundary、simulated exchange parity handle 和 Live forbidden gates。 |
| Deterministic tests | MTP-110 至 MTP-115 Core tests 覆盖 terminology、shared order semantics、deterministic matching、market / limit execution、partial fill / latency / fee / slippage 和 portfolio projection parity；MTP-116 App test 覆盖 Report / Dashboard / Events read-model-only surface。 | 审计时确认 deterministic validation 不依赖真实 Binance 网络、secret、account endpoint、listenKey、broker、真实账户、production runtime operations 或人工验收。 |

## Forbidden live capability evidence

`MTP-117-FORBIDDEN-LIVE-CAPABILITY-EVIDENCE-CHAIN`

MTP-110 至 MTP-116 继续固定以下能力在当前 Project 中全部禁止：

- no matching runtime。
- no order execution runtime。
- no portfolio projection runtime。
- no Runtime replay job。
- no database console / schema browser。
- no Runtime object exposure。
- no adapter request exposure。
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
- no live runtime。
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

- `SimulatedExchangeBacktestParityBoundary` 只定义 L2 parity 术语、target engine、handoff 和 forbidden capability baseline，不实现 matching / execution / portfolio runtime。
- `BacktestPaperSharedOrderSemanticsContract` 和 `BacktestPaperSharedOrderInput` 只固定 paper order intent 与 backtest replay order input 的共享字段，不表达 real order command。
- `ScenarioReplayDeterministicMatchingModel` 只用本地 scenario replay evidence 和 shared order input 输出 deterministic matching value object，不访问网络、broker、runtime 或 persistence。
- `MarketLimitSimulatedExecutionModel` 只输出 market / limit simulated execution value evidence，不实现真实 order execution runtime 或 advanced order routing。
- `PartialFillLatencyFeeSlippageParityModel` 只使用 deterministic liquidity cap、fixed latency assumption 和 MTP-27 fixed cost assumptions，不读取真实盘口深度、真实费率表或 broker fill。
- `SimulatedExchangePortfolioProjectionParityModel` 只从同一个 simulated exchange parity event 派生 backtest / paper projection parity，不读取真实账户、broker position、margin 或 leverage。
- `SimulatedExchangeParityEvidenceReadModel` / `SimulatedExchangeParityEvidenceViewModel` 只复制稳定 fields 供 Report / Workbench / Events 展示，不读取 Runtime object、SQLite / DuckDB schema、adapter request 或外部系统 payload。
- `DashboardShellSnapshot` 的 `simulatedParityEvidence` 是 smoke handle，不表示 command surface、order form、live command、trading authorization 或 Live PRO Console。

## Automation readiness evidence

`MTP-117-AUTOMATION-READINESS-STAGE-CLOSEOUT`

- `checks/automation-readiness.sh` 检查本 MTP-117 输入材料、latest verification summary、Trading Validation Matrix、validation plan、Simulated Exchange / Backtest Parity contract、automation readiness doc、MTP-110 至 MTP-116 source / test anchors、PR #211 至 PR #217 evidence 和 Dashboard smoke handle。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档、验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-117 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | pass | 机械检查 MTP-117 stage audit input、contract、matrix、validation plan、latest summary、automation readiness doc、source / test anchors 和 Dashboard smoke handles，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、Dashboard build / smoke 和 Swift tests；Dashboard smoke 输出 `sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`；Swift tests 261 个通过、0 failures，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只建立 L2 Simulated Exchange / Backtest Parity 的 deterministic evidence chain；不实现 production backtest engine 或真实交易 runtime。
- Shared order semantics 只服务 backtest / paper replay evidence，不表达真实订单命令、broker order id、exchange order id、OMS id 或 order form id。
- Scenario replay matching 只消费 local deterministic fixture 和 replay evidence，不读取真实 order book、broker feed、account stream 或 wall clock。
- Market / limit simulated execution 只定义最小 market / buy limit 语义，不实现 stop / OCO / advanced order types、真实 execution engine 或 order routing。
- Partial fill / latency / fee / slippage parity 只使用 deterministic fixture assumptions，不读取真实 liquidity、真实 fee schedule、execution quality、broker fill 或 execution report。
- Portfolio projection parity 只从 simulated exchange parity event 派生，不读取真实账户余额、broker position、margin、leverage、real PnL 或 reconciliation。
- Report / Dashboard / Event Timeline 只消费 App read model / ViewModel，不提供 order form、command model、order-level command UI、query language、database console、Runtime action、live command 或交易按钮。
- Binance 边界仍是 public read-only market data；required validation 不依赖真实 Binance 网络、真实 API key、真实账户或 broker state。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-117 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 L2 Simulated Exchange / Backtest Parity 的 deterministic evidence chain 已形成；不代表真实 Live trading、broker / OMS、signed endpoint、account endpoint / listenKey、Live PRO Console 或 trading button 已实现。 |
| `BLUEPRINT.md` | L2 parity evidence 可以作为 Research -> Backtest -> Paper 一致性工作台、后续 Workbench Beta Readiness 和 report reproducibility 的成熟度证据；Future Live、signed endpoint、broker、OMS 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `docs/environment.md` | 本 Project 未新增 required validation 入口、secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或网络必需验证；统一验证入口仍是 `bash checks/run.sh`。 |
| `docs/architecture.md` | Core / App / Dashboard 边界继续成立；L2 parity evidence 沿 local fixture / scenario replay -> Core deterministic value evidence -> App read model / ViewModel -> Workbench evidence surface 流动，不读取 adapter、Runtime object、SQLite / DuckDB schema、真实账户 / broker state 或 production operations state。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条同步已发生事实；MTP-117 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-110`、`MTP-111`、`MTP-112`、`MTP-113`、`MTP-114`、`MTP-115`、`MTP-116`、`MTP-117`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #211、#212、#213、#214、#215、#216、#217 和 MTP-117 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：terminology、target engine boundary、L1 / L1.5 / L2 handoff、shared backtest-paper order semantics、scenario replay deterministic matching、market / limit execution semantics、partial fill / latency / fee / slippage parity、portfolio projection parity、Report / Dashboard / Events read-model-only evidence、Dashboard smoke parity handle、matching runtime、order execution runtime、portfolio projection runtime、schema leakage、Runtime object leakage、adapter request leakage、Graphify update、Figma change、Linear mutation、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、live command、order form、order-level command UI 和 trading button 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-117 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`docs/environment.md`、`docs/architecture.md`、`docs/roadmap.md`。
- Current Phase Progress Bar：Root Docs Refresh Gate closure 后由 `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出，不按 Project closure count 直接计算目标完成度。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
