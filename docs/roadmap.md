# docs/roadmap.md

本文档是 Construction Plan / 施工路线。它是 `BLUEPRINT.md` 的二级权重承接文档，根据蓝图和工程模块定义施工顺序、进度和下一阶段 handoff。

ROADMAP 只定义阶段地图，不授权执行。正式执行必须来自 Human 指定的唯一 live queue source；`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening` 使用 GitHub fallback issue queue，不使用 Linear。

完整产品终局和 Future Construction Zones / 未来建设区见 `BLUEPRINT.md`；工程模块细节见 `architecture.md`。

## Roadmap Responsibility / 路线职责

`docs/roadmap.md` 只回答四个问题：

1. 已完成哪些建设阶段。
2. 当前目标切片完成到哪里。
3. 下一轮 planning 应该从哪些未完成切片里选择。
4. Project closure 后如何反写进度和 handoff。

它不定义最终产品终局，不定义工程模块细节，不授权执行。

## Roadmap Inputs / 路线输入

路线更新必须按以下输入顺序读取：

```text
GOAL.md
-> BLUEPRINT.md
-> architecture.md
-> docs/audit/<project-stage-code-audit>.md
-> docs/validation/latest-verification-summary.md
-> approved live queue source state
```

输入解释：

- `GOAL.md` 提供目标切片和硬边界。
- `BLUEPRINT.md` 提供完整产品终局、Current / Future 分界和 Live gates。
- `architecture.md` 提供工程模块地图和模块依赖方向。
- `docs/audit/` 提供已完成 Project 的事实证据。
- `docs/validation/latest-verification-summary.md` 提供最近验证和当前边界。
- approved live queue source 只用于确认 Project / issue 当前状态，不写死到本文档中；`MTPRO Release v0.9.0 Testnet No-order Observability` 的 live queue source 是 GitHub fallback issue queue。

## Completed Project Map / 已完成阶段地图

| 阶段族群 | 状态 | 压缩结果 |
| --- | --- | --- |
| Foundation / Paper / Workbench | Completed | 引导、Research / Backtest / Report、Paper Session / Execution / Control Shell、Market Replay Operations 已完成；完整证据见 `docs/audit/`。 |
| Live boundary / read-model-only | Completed | Live foundation、monitoring、execution control、risk gate、audit / incident / stop、L3.0-L3.4 read-model-only readiness 已完成；不授权真实 Live runtime、signed endpoint、broker、OMS 或 trading command。 |
| Engine / target graph / ownership | Completed | Event-driven paper runtime、Data Catalog、Simulated Exchange、module boundary、source migration、Trader-owned Strategies、Trader Accounts / Coordination、Persistence validation、SwiftPM target graph、TargetGraph retirement、Core envelope retirement 已完成；保留 final residual hardening PR #448 与 production executable `try!` = 0 evidence。 |
| L4 / production cutover readiness | Completed | `MTPRO L4 Live Production / Trading Commands v1` 与 `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 已完成；PR #473 至 #493 evidence、PR #511 至 #519 evidence 已落在 stage audit / latest summary；不授权真实 broker / real order / production trading。 |
| Releases | Completed | v0.1.0 Binance + EMA、v0.2.0 Binance Spot + USDⓈ-M Perpetual + EMA/RSI、v0.3.0 rehearsal evidence、v0.4.0 unified runtime rehearsal、v0.5.0 guarded testnet runtime foundation、v0.6.0 local operational runtime + testnet read-only probe hardening、v0.7.0 operator runtime session + real testnet read-only connectivity、v0.8.0 persistent operator runtime + testnet read-only monitoring、v0.9.0 testnet no-order observability、v0.10.0 production cutover readiness gate、v0.11.0 production readiness evidence runtime + integrity hardening 均 completed；production trading 默认保持关闭，production cutover 未授权。 |

Completed Project 的完整证据见 `docs/audit/`。当前 Project、active issue、Todo / In Progress / In Review 状态必须从 Human 指定的 live queue source 和 Parent Codex queue preview 实时读取，不写死在仓库文档中。

Machine guard anchors:

- MTPRO Release v0.2.0 | Completed
- Project Closure Count: 44 / 44 (100%)
- Latest Completed Project：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`
- Current maturity statement：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening complete with production trading disabled by default and production cutover not authorized`
- PR #473 至 #493 evidence
- PR #511 至 #519 evidence
- final residual hardening PR #448
- production executable `try!` = 0
- 不授权真实 broker
- TargetGraph Anchor Retirement / Real Module Source Root Migration before L4

## Current Release Construction Scope / 当前 release 建设口径

`GH-924-VERIFY-V0110-FINAL-AUDIT-RELEASE-DOCS`

Historical boundary anchor：`GH-891-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK` 仍作为 release v0.10.0 final audit / docs / runbook evidence 保留；`GH-856-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK` 仍作为 release v0.9.0 final audit / docs / runbook evidence 保留；`GH-820-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK` 仍作为 release v0.8.0 final audit / docs / runbook evidence 保留；`GH-792-RELEASE-V070-FINAL-AUDIT-DOCS-RUNBOOK` 仍作为 release v0.7.0 final audit / docs / runbook evidence 保留；`GH-766-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS` 仍作为 release v0.6.0 final audit / root docs evidence 保留；`GH-739-RELEASE-V050-FINAL-AUDIT-RELEASE-DOCS` 仍作为 release v0.5.0 release docs refresh evidence 保留；`GH-709-RELEASE-V040-FINAL-STAGE-AUDIT-RELEASE-DOCS` 仍作为 release v0.4.0 release docs refresh evidence 保留；`GH-670-RELEASE-V030-FINAL-STAGE-AUDIT-RELEASE-DOCS` 仍作为 release v0.3.0 root docs boundary refresh evidence 保留；`GH-564-RELEASE-V020-ROOT-DOCS-BOUNDARY-REFRESH` 仍作为 release v0.2.0 root docs boundary refresh evidence 保留；当前 release construction scope 已由 GH-924 更新为 v0.11.0 production readiness evidence runtime + integrity hardening closure。

最新完成的 release construction scope 是 `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`。它使用 GitHub fallback issue queue GH-913 至 GH-924 作为唯一队列来源；Linear 不参与本阶段执行。该 closure 已新增 Stage Code Audit Report `docs/audit/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-stage-code-audit.md`、release notes `docs/release/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-notes.md` 和 aggregate verifier `checks/verify-v0.11.0.sh`。#924 construction closeout 本身不创建 public tag / GitHub Release；后续独立 Release Publication Gate 已发布 v0.11.0 public GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`，tag peeled commit：`13f592d0710de91351286e5c5490bfacb63c19b0`，publication timestamp：`2026-06-19T01:20:58Z`。public release publication 和 production cutover 仍是独立 gate；已完成事实不授权创建下一 Project / Issue，不推进 release v0.11.0 之后的阶段，不授权 production cutover。

- activeVenue == Binance
- activeProductTypes == [spot, usdsPerpetual]
- activeStrategies == [ema, rsi]
- productionTradingEnabledByDefault == false
- runtimeModes == [local-dry-run, testnet-read-only-monitor, recovery-observe, production-blocked]
- legacyRuntimeModes == [testnet-read-only-probe]
- historicalV040RehearsalModes == [dry-run, shadow, testnet-guarded, production-blocked]
- productionCapabilityGatedNotMissing == true
- oldPublicReadOnlyPaperOnlyEMAOnlyIsHistorical == true

`GH-687-RELEASE-V031-REHEARSAL-EVIDENCE-DOCS-HANDOFF`

Release v0.11.0、v0.10.0、v0.9.0、v0.8.0、v0.7.0、v0.6.0、v0.5.0、v0.4.0 和 v0.3.x 的版本语义固定如下：

- v0.11.0 是 production readiness evidence runtime + integrity hardening closure：它证明 local readiness artifact store、manifest atomic IO、canonical JSON SHA256、bundle validation、shadow dry-run parity、Dashboard real artifact state、readiness CLI local artifacts、fixed-point capital / exposure policy、kill switch / no-trade state model、auditable approval workflow transitions 和 `checks/verify-v0.11.0.sh` validation command 已闭环。
- v0.11.0 #924 construction closeout 不是 public GitHub Release publication：它不创建 tag，不发布 GitHub Release，不授权 production cutover；后续独立 Release Publication Gate 已完成 public GitHub Release publication，且仍不授权 production cutover。
- v0.10.0 是 production cutover readiness gate closure：它证明 production readiness no-authorization contract、v0.9.1 publication policy carry-forward、production environment profile、secret provider readiness、endpoint policy readiness、capital / exposure limits、kill switch / no-trade、production command surface disabled proof、shadow dry-run parity、production readiness audit bundle、cutover approval workflow、incident / rollback runbook、Dashboard Production Readiness Center、operator runbook 和 `checks/verify-v0.10.0.sh` validation command 已闭环。
- v0.10.0 stable GitHub Release 已通过独立 publication gate 发布：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`；tag target commit 为 `7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`。
- v0.10.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、testnet 或 production submit / cancel / replace、production OMS、Live PRO Console production command、trading button、order form 或 live command。
- v0.9.0 是 testnet no-order observability closure：它证明 v0.9.0 no-order observability contract、v0.8.0 publication alignment carry-forward、persistent TestnetReadOnlyMonitorSession、signed account snapshot freshness monitor、private stream heartbeat / staleness monitor、monitor recovery observe、Dashboard observability timeline、alert read-model、Portfolio reconciliation timeline、Risk policy application audit、run monitor export bundle、validation lanes split、Dashboard / CLI operator UX、operator runbook 和 `checks/verify-v0.9.0.sh` validation command 已闭环。
- v0.9.0 stable GitHub Release 已通过独立 publication gate 发布：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`；tag target commit 为 `4296bf73673fe0fd8f09e34c40ef2a3a9ba7e55c`。
- v0.9.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、testnet 或 production submit / cancel / replace、production OMS、Live PRO Console production command、trading button、order form 或 live command。
- v0.8.0 是 persistent operator runtime + testnet read-only monitoring closure：它证明 persistent no-order operator runtime contract、v0.8 construction / public release publication separation、persistent RunRegistryStore、CLI local session actions、OperationalRunSessionStore、EventLogWriter crash recovery、manual Binance testnet signed account proof、manual private stream monitoring proof、Dashboard testnet read-only monitor、local Risk policy profile management、Portfolio reconciliation review workflow、Dashboard safe local controls、validation lanes split、operator runbook 和 `checks/verify-v0.8.0.sh` validation command 已闭环。
- v0.8.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、testnet 或 production submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。
- v0.7.0 是 operator runtime session + real testnet read-only connectivity closure：它证明 no-order runtime session contract、canonical testnet endpoint policy、top-level CLI runtime session surface、Dashboard macOS focused guards、OperationalRunSession lifecycle、EventLogWriter recovery、RunRegistry / RunSupervisor、real Binance testnet signed account read-only probe、testnet private stream read-only probe、Dashboard read-only run operations、local Risk policy config、Portfolio read-only reconciliation projection、operator runbook 和 `checks/verify-v0.7.0.sh` validation command 已闭环。
- v0.7.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、real submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。
- v0.6.0 是 local operational runtime + testnet read-only probe hardening closure：它证明 local run journal writer、run manifest / artifact checksum validator、sha256 runtime checksum chain、DataEngine local dry-run runner、EMA / RSI strategy runtime runner、RiskEngine runtime runner、ExecutionEngine / OMS dry-run runner、Portfolio journal projection、Dashboard / CLI run detail observer、operator-confirmed testnet read-only probe、operator runbook 和 `checks/verify-v0.6.0.sh` validation command 已闭环。
- v0.6.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、real submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。

- v0.5.0 是 guarded testnet runtime foundation / deterministic-to-operational bridge closure：它证明 strict CLI、fail-closed environment / endpoint / secret policy、typed RuntimeMessageBus、durable local run journal、DataEngine operational dry-run path、testnet read-only no-submit gate、RiskEngine runner、ExecutionEngine / OMS dry-run lifecycle、Portfolio projection、Dashboard / CLI run observer、CI hardening、operator runbook 和 `checks/verify-v0.5.0.sh` validation command 已闭环。
- v0.5.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、real submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。
- v0.4.0 是 unified runtime rehearsal pipeline closure：它证明 single runID evidence envelope、local dry-run RuntimeKernel、DataEngine -> MessageBus -> Trader / Strategy -> RiskEngine -> ExecutionEngine / OMS -> ExecutionClient dry-run / testnet-gated boundary -> Event Store -> Portfolio -> Dashboard / CLI 证据链、shadow replay、operator runbook 和 `checks/verify-v0.4.0.sh` validation suite 已闭环。
- v0.4.0 不是 production cutover：它不授权 production secret、production endpoint、production broker、real submit / cancel / replace、production OMS、Live PRO Console production command 或 trading button。

- v0.3.0 是 deterministic rehearsal evidence release：它证明本地 deterministic evidence chain、dry-run / testnet / shadow / production-blocked mode taxonomy、Dashboard / CLI rehearsal surface、kill switch / no-trade / rollback drill 和 `checks/verify-v0.3.0.sh` validation suite 已闭环。
- v0.3.1 是 rehearsal evidence hardening patch：它只补强 v0.3.0 evidence 边界、URL policy、文档语义和 patch release closeout，不新增 runtime pipeline、network connector、product type、strategy 或 production cutover。
- v0.3.x 不是 real testnet / shadow runtime runner：文档中出现的 `testnet` / `shadow` 表示 rehearsal evidence mode 和 deterministic mapping proof，不表示已启动真实 Binance testnet network loop、shadow production feed、broker connection、secret read、live private stream、real submit / cancel / replace 或 production endpoint。
- release v0.5.0 之后的下一阶段仍必须等待 Human + `@001 / PLN` 重新规划并写入新的 live queue source；本文档不创建下一 Project / Issue，不推进 Todo，不授权 execution。

`GH-564-PRODUCTION-CAPABILITY-GATED-NOT-MISSING`

Release v0.11.0 的 production readiness evidence runtime 是 gated evidence capability，不是 production trading capability，也不是默认开启能力。任何 production secret、production endpoint、broker connection、submit / cancel / replace、OMS、Event Store 或 Dashboard command surface 都必须在 CommandGateway、RiskEngine、ExecutionEngine、OMS、Event Store、kill switch / no-trade 和 validation gates 之后才可由后续 issue 明确授权。

`GH-564-NO-OLD-BOUNDARY-AS-CURRENT`

public-read-only、paper-only、ExecutionClient future-gate、EMA-only、v0.3.x deterministic-only wording、v0.4.0 shadow/unified runtime wording、v0.5.0 guarded testnet wording、v0.6.0 local operational wording、v0.7.0 runtime-session wording、v0.8.0 persistent monitoring wording、v0.9.0 no-order observability wording 和 v0.10.0 readiness assessment wording 可以继续作为历史阶段、审计证据和 compatibility evidence 出现，但不得写成 release v0.11.0 当前边界。当前口径必须保持 Binance-only、Spot + USDⓈ-M Perpetual-only、EMA + RSI-only、local-dry-run / testnet-read-only-monitor / recovery-observe / production-blocked、production readiness evidence runtime、production disabled by default、production cutover not authorized 和 production capability gated-not-missing。

Core Envelope Retirement / Real Module Ownership Completion 的 post-audit hardening 已在 PR #448 后完成最终 closure audit：production executable `try!` = 0，`@unchecked Sendable` = 0，open GitHub issue / PR = 0，`main == origin/main == 2b78f27a8e2b04ba348d2fc90259c96b9a088aff`，完整本地验证通过。该事实只同步已发生 hardening closure，不新增 Project Closure Count，不授权 L4 execution。

## Progress Model / 进度模型

MTPRO 采用两层进度口径：

1. Current Foundation Progress：当前已批准 paper-only foundation 的完成度。
2. Final Product Goal Progress：最终专业交易工作台产品目标的完成度。

Project Closure Count 只说明当前已批准、已执行、已 closure 的建设阶段 Project 数量，不代表完整产品蓝图或 Future Construction Zones / 未来建设区已经完成。

```text
Phase: MTPRO professional trading workstation
Project Closure Count: 44 / 44 (100%)
Current Foundation Progress: 4 / 4 (100%)
Final Product Goal Progress: 9 / 9 (100%)
Engine Maturity Roadmap Progress: 4 / 4 (100%)
Foundation Progress: [##########] 100%
Final Product Progress: [##########] 100%
Engine Maturity Progress: [##########] 100%
```

Historical Project Closure Count: 43 / 43 (100%) recorded the `MTPRO Release v0.9.0 Testnet No-order Observability` closure baseline before GH-891 advanced the current completed Project count to 44 / 44.
Historical Project Closure Count: 42 / 42 (100%) recorded the `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring` closure baseline before GH-856 advanced the current completed Project count to 43 / 43.
Historical Project Closure Count: 41 / 41 (100%) recorded the `MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity` closure baseline before GH-820 advanced the completed Project count to 42 / 42.
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`
Historical guard retains previous Latest completed release construction scope: `MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`
Historical Project Closure Count: 40 / 40 (100%) recorded the `MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening` closure baseline before GH-792 advanced the completed Project count to 41 / 41.
Historical Project Closure Count: 39 / 39 (100%) recorded the `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge` closure baseline before GH-766 advanced the completed Project count to 40 / 40.
Historical Project Closure Count: 38 / 38 (100%) recorded the `MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline` closure baseline before GH-739 advanced the completed Project count to 39 / 39.
Historical Project Closure Count: 37 / 37 (100%) recorded the `MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal` closure baseline before GH-709 advanced the completed Project count to 38 / 38.
Historical Project Closure Count: 36 / 36 recorded the `MTPRO Release v0.2.0` closure baseline before GH-670 advanced the completed Project count to 37 / 37.
Historical Project Closure Count: 36 / 36 (100%)

Current Foundation Progress 基于 `GOAL.md` 的当前 foundation 目标切片计算：

| Foundation 目标切片 | 状态 | 证据 |
| --- | --- | --- |
| Research / Backtest / Report / Paper readiness | Complete | Runtime Research Workbench、Trading Validation、Paper Session Runtime 已完成 |
| Paper-only execution evidence | Complete | Paper Execution Workflow v1 已完成 |
| Paper workflow 可观察性和本地控制壳 | Complete | Paper Workflow Control Shell v1 已完成 |
| 更长周期 market data replay / operations | Complete | Market Data Replay Operations v1 已完成 |

Final Product Goal Progress 基于 `GOAL.md` 的完整产品目标切片计算：

| # | 最终产品目标切片 | 状态 | 证据 / 下一步 |
| --- | --- | --- | --- |
| 1 | 研究 / 回测 / 报告基础能力（Research / Backtest / Report foundation） | Complete | Runtime Research Workbench、Trading Validation 和 Report evidence 已完成 |
| 2 | Paper 模拟执行基础能力（Paper execution foundation） | Complete | Paper Session Runtime 和 Paper Execution Workflow 已完成 |
| 3 | 工作台证据导航与本地控制壳（Workbench evidence navigation and local control shell） | Complete | Paper Workflow Control Shell v1 已完成 |
| 4 | 行情数据回放运营能力（Market data replay operations） | Complete | Market Data Replay Operations v1 已完成 |
| 5 | 实盘交易基础边界（Live trading foundation） | Complete | Live Trading Boundary Definition v1 已完成 boundary taxonomy、credential endpoint boundary、adapter isolation、real order lifecycle terminology、blocked evidence 和只读展示面；真实 Live trading、signed endpoint、broker adapter 和 real order lifecycle 仍未实现 |
| 6 | 实盘监控台（Live monitoring console） | Complete / read-model-only evidence surface | Live Monitoring Console v1 已完成 information architecture、runtime health / connection read model、market / order stream blocked evidence、latency / error / degraded evidence、Dashboard / Report / Event Timeline evidence surface；真实 live runtime、signed/account stream、broker stream 和交易控制仍未实现 |
| 7 | 实盘执行控制（Live execution control） | Complete / contract + blocked evidence | Live Execution Control Contract v1 已完成 terminology、submit / cancel / replace future gates、execution report / broker fill / reconciliation future gates、paper / real command isolation、read-model-only blocked evidence、Dashboard / Report / Event Timeline evidence surface；真实 execution runtime、真实 submit / cancel / replace、broker fill、execution report 和 reconciliation 仍未实现 |
| 8 | 实盘风险控制（Live risk control） | Complete / contract + blocked evidence | Live Risk Gate Contract v1 已完成 risk terminology、exposure / notional / frequency / loss / drawdown / circuit breaker / no-trade future gates、paper / live risk isolation、read-model-only blocked evidence 和 Dashboard / Report / Event Timeline evidence surface；真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command 和 emergency stop 仍未实现 |
| 9 | 实盘审计 / 事故回放 / 停机控制（Live audit / incident replay / stop controls） | Complete / contract + blocked evidence | Live Audit Incident Stop Boundary v1 已完成 audit / incident / stop terminology、audit trail / incident replay / stop controls future gates、blocked evidence isolation、read-model-only evidence surface 和 forbidden capability tests；真实 audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command 和 trading button 仍未实现 |

Latest Completed Project：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`

Historical Latest Completed Project：`MTPRO Release v0.9.0 Testnet No-order Observability`
Historical Latest Completed Project：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`
Historical Latest Completed Project：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`
Historical Latest Completed Project：`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening`
Historical Latest Completed Project：`MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge`
Historical Latest Completed Project：`MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline`
Historical Latest Completed Project：`MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal`
Historical Latest Completed Project：`MTPRO Release v0.2.0`
Historical guard retains previous Latest Completed Project：`MTPRO Release v0.2.0`

Current maturity statement：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening complete with production trading disabled by default and production cutover not authorized`
Historical maturity statement：`MTPRO Release v0.9.0 Testnet No-order Observability complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity complete with production trading disabled by default`
Historical guard retains previous Current maturity statement：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity complete with production trading disabled by default`
Historical guard retains previous Current maturity statement：`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline complete with production trading disabled by default`
Historical maturity statement：`MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal complete with production trading disabled by default`
Historical guard retains previous Current maturity statement：`MTPRO Release v0.2.0 Binance Spot + USDⓈ-M Perpetual + EMA/RSI validation complete with production trading disabled by default`

Next recommended maturity slice：无当前可执行推荐。

Next maturity planning candidate：无当前可执行推荐；real broker / production trading / next Project 仍必须经 Human + `@001 / PLN` 重新规划。

Next Handoff：Human + `@001 / PLN`

本进度条不统计未授权 future capability，不授权下一阶段执行。下一阶段方向、目标、架构路线和优先级仍交给 Human + `@001 / PLN`。

## Product Route / 产品路线

1. 研究 / 回测 / 报告基础能力：Completed。
2. Paper 模拟执行基础能力：Completed。
3. 工作台证据导航与本地控制壳：Completed。
4. 行情数据回放运营能力：Completed。
5. 实盘交易基础边界：Completed；仅完成基础边界、阻断证据和只读展示面，不实现真实 Live trading。
6. 实盘监控台：Completed；仅完成 read-model-only monitoring evidence surface，不实现真实 live runtime、signed/account stream、broker stream 或交易控制。
7. 实盘执行控制：Completed / contract + blocked evidence；不实现真实 execution runtime、真实订单命令、broker fill、execution report 或 reconciliation。
8. 实盘风险控制：Completed / contract + blocked evidence；不实现真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command 或 emergency stop。
9. 实盘审计 / 事故回放 / 停机控制：Completed / contract + blocked evidence；不实现真实 audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command 或 trading button。

## Module Maturity Development Plan / 模块成熟度开发计划

Final Product Goal Progress `9 / 9 (100%)` 表示原定 contract / evidence / Workbench / Live boundary 切片已完成，不表示 MTPRO 已达到 `atxinbao/nautilus_trader` 级别的 production trading engine 成熟度。9 / 9 后的新开发路线以“引擎成熟度”推进：先完成 MTPRO 自身 paper-only event-driven runtime，再完成 local-first Data Catalog / Scenario Replay 数据地基，之后才进入 Simulated Exchange / Backtest Parity、Workbench Beta Readiness 和 Future Gated live readiness。

该计划是开发路线地图，不授权执行，不创建 Linear Project / Issue，不推进 `Todo`。每个阶段都必须先由 Human 确认，再由 `@001 / PLN` 输出 Project Planning Record，经 Linear 写入和 Parent Codex queue preflight 后，才能让唯一 eligible issue 进入 `Todo`。

Engine 级分层和成熟度门槛由 `docs/product/mtpro-core-engine-architecture-module-maturity-map-v1.md` 维护。后续任何 Project Planning Record 必须说明目标 Engine / Layer、目标 maturity level、当前 evidence、允许施工范围和 forbidden capabilities，避免把单个页面、证据面或零散模块误当成完整 trading engine maturity。

| Maturity family | 状态 | 边界 |
| --- | --- | --- |
| L1-L2+ paper / data / parity / Workbench | Done | Engine Maturity Roadmap Progress `4 / 4 (100%)`；证据见对应 `docs/audit/mtpro-*-stage-code-audit.md`。 |
| L3 read-model-only readiness | Done / not counted in old denominator | Live read-only、APB、private stream simulation、Live Monitoring v2、Strategy / Trader Instance readiness 都只是 read-model-only / simulation / forbidden capability evidence。 |
| Module / target graph / Core envelope | Done / not counted in old denominator | Module boundary、physical layout、Trader strategy/account/coordination、Persistence validation、SwiftPM target graph、TargetGraph retirement、real target ownership 和 Core envelope retirement 已闭环；保留 final residual hardening PR #448 与 production executable `try!` = 0。 |
| L4 / production readiness | Done / no-default-production-trading | Historical L4 maturity statement：`L4 Live Production / Trading Commands v1 complete with no-default-production-trading policy`；PR #473 至 #493 evidence 与 PR #511 至 #519 evidence 只证明 future-gated / readiness-only gates，不授权真实 broker、production endpoint、signed endpoint、account endpoint / listenKey、production OMS、real submit / cancel / replace、trading button、live command、order form 或 production trading。 |
| Release v0.1.0 baseline | Done / Binance + EMA runtime validation / production disabled by default | `MTPRO Release v0.1.0` 只证明 Binance + EMA dry-run / testnet validation、operator runbook 和 no-default-production-trading guard；production trading 默认关闭，不读取 production secret，不连接 production endpoint 或 production broker endpoint。 |

## Construction Slice Selection / 施工切片选择

下一阶段 planning 只能从 `BLUEPRINT.md` 的 Future Construction Zones / 未来建设区中选择一个清晰切片，并把它收敛为 Project Planning Record。选择切片时必须满足：

- 能对应 `GOAL.md` 的某个 Final Product Goal Slice。
- 能落到 `architecture.md` 中可解释的工程模块或模块边界。
- 能被拆成 WIP=1 的 Linear issue queue。
- 能用 deterministic validation、PR evidence、Stage Code Audit 和 Root Docs Refresh 收口。
- 不把多个 future capability 一次性打包成模糊大 Project。

当前已完成的 live-route 候选顺序：

```text
实盘监控台
-> 实盘执行控制
-> 实盘风险控制
-> 实盘审计 / 事故回放 / 停机控制
```

上述四个 live-route 目标切片均已完成各自的 read-model-only / contract + blocked evidence 切片。该顺序不是执行授权。Human + `@001 / PLN` 可以基于最新 Stage Audit、风险和产品优先级重新定义下一轮 planning；`docs/roadmap.md` 不自动决定下一阶段方向。

## Live Route Gates / 实盘路线门槛

实盘相关目标切片必须按门槛推进，不能从 paper-only foundation 直接跳到真实订单：

| 目标切片 | 进入前置 | 当前状态 |
| --- | --- | --- |
| 实盘交易基础边界 | Human 独立决策、独立 Project Definition、secret / signed endpoint / account endpoint / broker adapter / real order lifecycle gates | Complete：已定义 foundation taxonomy、credential endpoint boundary、adapter isolation、real order lifecycle terminology、blocked evidence 和只读 evidence surface；未实现真实 Live trading |
| 实盘监控台 | 已定义 live runtime health、connection、market stream、order stream、error、latency 和 operations evidence | Complete / read-model-only evidence surface：已完成 health、connection、stream、latency、error evidence 展示面；真实 live runtime、signed/account stream、broker stream 和交易控制仍未实现 |
| 实盘执行控制 | 已定义 real order submit / cancel / replace、execution report、reconciliation 和 incident fallback | Complete / contract + blocked evidence；真实 execution runtime、真实订单命令、broker fill、execution report 和 reconciliation 仍 gated |
| 实盘风险控制 | 已定义 live pre-trade risk、exposure / order notional / frequency / loss / drawdown / circuit breaker / no-trade gates 和 read-model-only blocked evidence | Complete / contract + blocked evidence；真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command 和 emergency stop 仍 gated |
| 实盘审计 / 事故回放 / 停机控制 | 已定义 live event chain、audit trail、incident replay、shutdown / restore policy | Complete / contract + blocked evidence；真实 audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command 和 trading button 仍 gated |

任何缺少对应 gate 的变更只能停留在蓝图或 planning 草案中，不能进入 Linear execution。

## Project Closure Rule / Project 收口规则

当前 Project 全部有效 issues `Done` 后，必须按顺序关闭：

```text
Linear Project status Completed
-> Stage Code Audit Report
-> Root Docs Refresh Gate
-> Current Phase Progress Bar
-> Next Human Project Planning
```

`@002 / PAR` 只同步已发生事实；下一阶段方向、目标、架构路线和优先级必须由 Human + `@001 / PLN` 决定。

Project closure 后，`docs/roadmap.md` 只更新这些事实：

- Project 是否 Completed。
- Stage Code Audit Report 路径。
- Root Docs Refresh Gate 是否 closure。
- Project Closure Count。
- Current Foundation Progress。
- Final Product Goal Progress。
- Next Handoff。

不把 child issue 细节、PR 流水账或临时 CI 失败详情写入本文档；这些进入 `docs/audit/`、`docs/validation/` 或 `verification.md`。

## Next Handoff Contract / 下一轮交接合同

下一轮交给 Human + `@001 / PLN` 时，必须带上：

- 当前 Final Product Goal Progress。
- 当前 pending / gated 目标切片。
- 最近 Stage Code Audit Report。
- Root Docs Refresh Gate closure 结果。
- 不能触碰的禁止能力。
- 候选 Project 方向，但不创建 Linear Project / Issue。

`@001 / PLN` 输出 Project / Issue draft 后，也仍然不授权执行。只有 Human review / merge、Linear 写入、`@002 / PAR` startup gate 和 queue preflight 全部完成后，唯一 eligible issue 才能进入 `Todo`。

## 非授权边界

- `docs/roadmap.md` 不创建 Linear Project / Issue。
- `docs/roadmap.md` 不修改 Linear status。
- `docs/roadmap.md` 不启动额外调度服务。
- `docs/roadmap.md` 不运行图谱更新服务。
- `docs/roadmap.md` 不解锁下一个 issue。
- `docs/roadmap.md` 不授权任何 Agent 直接把 issue 改为 `Todo`。
