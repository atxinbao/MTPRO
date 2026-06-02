# docs/roadmap.md

本文档是 Construction Plan / 施工路线。它是 `BLUEPRINT.md` 的二级权重承接文档，根据蓝图和工程模块定义施工顺序、进度和下一阶段 handoff。

ROADMAP 只定义阶段地图，不授权执行。正式执行必须来自 Linear live-read 中唯一 configured executable issue，并通过 Parent Codex queue preflight、Codex Execution Agent 和 GitHub PR Automation。

完整产品终局和 Future Construction Zones / 未来建设区见 `BLUEPRINT.md`；工程模块细节见 `docs/architecture.md`。

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
-> docs/architecture.md
-> docs/audit/<project-stage-code-audit>.md
-> docs/validation/latest-verification-summary.md
-> Linear Project live state
```

输入解释：

- `GOAL.md` 提供目标切片和硬边界。
- `BLUEPRINT.md` 提供完整产品终局、Current / Future 分界和 Live gates。
- `docs/architecture.md` 提供工程模块地图和模块依赖方向。
- `docs/audit/` 提供已完成 Project 的事实证据。
- `docs/validation/latest-verification-summary.md` 提供最近验证和当前边界。
- Linear live-read 只用于确认 Project / issue 当前状态，不写死到本文档中。

## Completed Project Map / 已完成阶段地图

| 阶段 | 状态 | 结果 |
| --- | --- | --- |
| MTPRO 引导 | Completed | 根文档、contract-first 文档、SwiftPM baseline、自动化基线 |
| MTPRO Runtime Research Workbench v1 | Completed | Core 拆分、read-only market data boundary、event log / replay、SQLite / DuckDB projection、Dashboard shell、Research -> Backtest -> Report path |
| MTPRO Trading Validation and Parity Hardening | Completed | trading validation matrix、EMA / order book parity、fees / slippage assumptions、risk blocker、portfolio exposure、Report / Dashboard evidence |
| MTPRO Paper Session Runtime v1 | Completed | paper session lifecycle、proposal、risk link、paper-only portfolio projection、replay、report evidence |
| MTPRO Paper Execution Workflow v1 | Completed | paper-only execution workflow、paper order lifecycle、simulated fill、event log replay、Report / Dashboard evidence、Stage Code Audit Report |
| MTPRO Paper Workflow Control Shell v1 | Completed | Paper workflow Workbench information architecture、session-level local controls、observability、Event Timeline / Evidence Explorer preview、Dashboard / Workbench shell evidence、Stage Code Audit Report |
| MTPRO Market Data Replay Operations v1 | Completed | public read-only batch / replay boundary、local replay metadata、retention / freshness evidence、fixture parity、event log / projection consistency、Report / Dashboard / Event Timeline evidence、Stage Code Audit Report |
| MTPRO Live Trading Boundary Definition v1 | Completed | Live trading foundation taxonomy、credential endpoint boundary、adapter capability isolation、real order lifecycle terminology、`LiveReadiness` / `LiveBlockedEvidence` blocked read model、Dashboard / Report / Event Timeline blocked evidence surface、Stage Code Audit Report |
| MTPRO Live Monitoring Console v1 | Completed | Live monitoring console information architecture、runtime health / connection read model、market / order stream blocked evidence、latency / error / degraded evidence、Dashboard / Report / Event Timeline read-model-only evidence surface、Stage Code Audit Report |
| MTPRO Live Execution Control Contract v1 | Completed | Live execution control terminology、submit / cancel / replace future gates、execution report / broker fill / reconciliation future gates、paper / real command isolation、read-model-only blocked evidence、Dashboard / Report / Event Timeline blocked evidence surface、Stage Code Audit Report |
| MTPRO Live Risk Gate Contract v1 | Completed | Live risk terminology、exposure / notional / frequency / loss / drawdown / circuit breaker / no-trade future gates、paper / live risk isolation、read-model-only blocked evidence、Dashboard / Report / Event Timeline blocked evidence surface、Stage Code Audit Report |
| MTPRO Live Audit Incident Stop Boundary v1 | Completed | Live audit / incident / stop terminology、audit trail / incident replay / stop controls future gates、blocked evidence isolation、read-model-only incident / stop blocked evidence、Dashboard / Report / Event Timeline blocked evidence surface、Stage Code Audit Report |
| MTPRO Event-Driven Paper Trading Runtime v1 | Completed | TradingClock / paper runtime kernel、CommandBus / EventBus / MessageBus deterministic routing、Paper Pre-trade RiskEngine、paper-only local lifecycle、simulated fill / fee / slippage、paper account / portfolio / position projection v2、Event Log / Replay / Report / Dashboard / Event Timeline evidence、Stage Code Audit Report |
| MTPRO Data Catalog / Scenario Replay v1 | Completed | Local scenario manifest、scenario id / dataset version / fixture version identity、single-symbol / single-timeframe deterministic fixture、replay window / cursor、checksum / freshness evidence、quality gates、report input versioning、Workbench / Report / Events read-model evidence、Stage Code Audit Report |
| MTPRO Simulated Exchange / Backtest Parity v1 | Completed | Shared backtest-paper order semantics、scenario replay deterministic matching、market / limit simulated execution、partial fill / latency / fee / slippage parity、simulated exchange event -> portfolio projection parity、Report / Dashboard / Events read-model-only evidence surface、Stage Code Audit Report |
| MTPRO Workbench Beta Readiness v1 | Completed | Local macOS launch / install verification、deterministic demo scenario、first-run default demo state、Report / Dashboard / Events beta acceptance path、reproducible acceptance checklist / script、docs index、operator guide、automation readiness、Stage Code Audit Report |
| MTPRO Live Read-only Readiness Boundary v1 | Completed | Live read-only terminology、credential / secret policy、endpoint taxonomy、adapter capability matrix、account / position / balance future gates、private stream / account snapshot simulation gate、Workbench read-model-only boundary、validation matrix、automation readiness、Stage Code Audit Report |
| MTPRO Account / Position / Balance Read-model-only v1 | Completed | Account / position / balance read-model-only terminology、snapshot identity、source / freshness evidence、position exposure evidence、balance paper-vs-real boundary、deterministic fixture、forbidden real account tests、Workbench / Report / Events read-model-only surface、validation matrix、automation readiness、Stage Code Audit Report |
| MTPRO Private Stream / Account Snapshot Simulation Gate v1 | Completed | Private stream / account snapshot simulation gate terminology、simulated private account event source identity、simulated account snapshot input、account snapshot update fixture、fresh / stale / blocked / missing evidence、forbidden endpoint / runtime tests、Workbench / Report / Events read-model-only simulation gate surface、validation matrix、automation readiness、Stage Code Audit Report |
| MTPRO Live Monitoring Read-only Console v2 | Completed | Live Monitoring v2 terminology、monitoring source identity、simulation gate health / freshness evidence、connection readiness explanation、forbidden runtime / endpoint / UI command tests、Workbench / Report / Events read-model-only surface、validation matrix、automation readiness、Stage Code Audit Report |
| MTPRO Strategy / Trader Instance Readiness v1 | Completed | Strategy / Trader Instance readiness terminology、lifecycle / identity、quoter / hedger role taxonomy、account / portfolio / risk read-model input、paper/live-neutral proposal isolation、forbidden Strategy -> Execution / broker / UI command tests、Workbench / Report / Events read-model-only strategy readiness surface、validation matrix、automation readiness、Stage Code Audit Report |
| MTPRO Engine Module Boundary Consolidation v1 | Completed | Architecture-graph-aligned module boundary terminology、fixed target `Sources/*` layout、dependency direction、MessageBus / Cache / Database / DataClient / DataEngine / Strategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench boundary、Future Live PRO Console split、L4 planning input material、validation matrix、automation readiness、Stage Code Audit Report |
| MTPRO Target Module Physical Layout / Source Migration v1 | Completed | DomainModel / MessageBus / DataClient / DataEngine / Cache / Database / Strategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench / Dashboard directory-first source migration、compatibility envelope、remaining compatibility shell audit、forbidden implementation audit、validation matrix、automation readiness、Stage Code Audit Report |
| MTPRO Trader-Owned Strategies Layout Correction v1 | Completed | Trader-owned concrete strategy canonical path correction、EMA active placement under `Sources/Trader/Strategies/EMA/`、OrderBookImbalance historical / compatibility placement evidence、historical `Sources/Strategies/<strategy>` compatibility treatment、StrategyBindings binding protocol / coordination adapter classification、forbidden direct execution path audit、validation matrix、automation readiness、Stage Code Audit Report |

Completed Project 的完整证据见 `docs/audit/`。当前 Project、active issue、Todo / In Progress / In Review 状态必须从 Linear 和 Parent Codex queue preview 实时读取，不写死在仓库文档中。

## Progress Model / 进度模型

MTPRO 采用两层进度口径：

1. Current Foundation Progress：当前已批准 paper-only foundation 的完成度。
2. Final Product Goal Progress：最终专业交易工作台产品目标的完成度。

Project Closure Count 只说明当前已批准、已执行、已 closure 的建设阶段 Project 数量，不代表完整产品蓝图或 Future Construction Zones / 未来建设区已经完成。

```text
Phase: MTPRO professional trading workstation
Project Closure Count: 24 / 24 (100%)
Current Foundation Progress: 4 / 4 (100%)
Final Product Goal Progress: 9 / 9 (100%)
Engine Maturity Roadmap Progress: 4 / 4 (100%)
Foundation Progress: [##########] 100%
Final Product Progress: [##########] 100%
Engine Maturity Progress: [##########] 100%
```

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

Latest Completed Project：`MTPRO Trader-Owned Strategies Layout Correction v1`

Current maturity statement：`Trader-Owned Strategies Layout Correction before L4 complete`

Next recommended maturity slice：无当前可执行推荐。

Next maturity planning candidate：`L4 Live Production / Trading Commands`；当前只作为 Future Gated planning candidate，不授权 execution。

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

| Maturity slice | 状态 | 目标 | 对标 `nautilus_trader` | 当前证据 / 边界 |
| --- | --- | --- | --- | --- |
| L1 Paper Runtime | Done | 建立 paper-only runtime kernel、CommandBus / EventBus / MessageBus、Paper RiskEngine、paper lifecycle coordinator、local / simulated order lifecycle、simulated fill / fee / slippage、paper account / portfolio projection 和 Event Log / Replay / Dashboard evidence 闭环。 | `core` / `common` / `trading` / `execution` / `portfolio` 的 paper-only 安全子集。 | `docs/audit/mtpro-event-driven-paper-trading-runtime-v1-stage-code-audit.md` 已记录 L1 Paper Runtime evidence chain、validation 和 forbidden capability audit。 |
| L1.5 Data Catalog / Scenario Replay | Done | 建立 local scenario manifest、deterministic fixture、replay window / cursor、checksum / freshness evidence、quality gates、report input versioning 和 Workbench / Report / Events read-model evidence。 | `data` / `persistence` / local catalog / replay evidence。 | `docs/audit/mtpro-data-catalog-scenario-replay-v1-stage-code-audit.md` 已记录 L1.5 Data Catalog / Scenario Replay evidence chain、validation 和 forbidden capability audit。 |
| L2 Simulated Exchange / Backtest Parity | Done | 让 backtest 与 paper 共用交易语义，补 simulated exchange、order type semantics、matching、partial fill、latency、fee / slippage parity 和 backtest-paper portfolio parity。 | `backtest` engine、simulated exchange、matching engine。 | `docs/audit/mtpro-simulated-exchange-backtest-parity-v1-stage-code-audit.md` 已记录 L2 deterministic parity evidence chain、validation 和 forbidden capability audit。 |
| L2+ Workbench Beta Readiness | Done | 把 runtime / data / replay 能力产品化为可用 macOS Workbench：安装、启动、demo dataset、daily workflow、docs index、validation matrix 和 beta acceptance。 | 参考项目 release discipline；同时保留 MTPRO 的 macOS native Workbench 差异化。 | `docs/audit/mtpro-workbench-beta-readiness-v1-stage-code-audit.md` 已记录 L2+ local Workbench beta acceptance evidence chain、validation 和 forbidden capability audit；不代表 production release、notarization、App Store distribution、auto-update、production operations 或 live readiness。 |
| L3.0 Live Read-only Readiness Boundary | Done / not counted in old denominator | 定义只读接近真实账户前的术语、凭证策略、endpoint 分类、adapter capability matrix、forbidden write capability baseline 和验证门槛。 | adapters / account boundary / capability matrix，但不实现 endpoint 或 runtime。 | `docs/audit/mtpro-live-read-only-readiness-boundary-v1-stage-code-audit.md` 已记录 L3.0 boundary evidence chain、validation 和 forbidden capability audit；不计入旧 `4 / 4` 分母；不授权 signed / account / broker / listenKey。 |
| L3.1 Account / Position / Balance Read-model-only | Done / not counted in old denominator | 定义 account / position / balance 的只读模型、snapshot identity、source / freshness evidence、deterministic fixture 和 Workbench / Report / Events evidence surface。 | account / position read model，但不进入真实同步。 | `docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md` 已记录 L3.1 read-model-only evidence chain、validation 和 forbidden capability audit；不读取 real account 或 broker position。 |
| L3.2 Private Stream / Account Snapshot Simulation Gate | Done / not counted in old denominator | 用 simulation / fixture gate 证明 private stream 与 account snapshot 只能在受控边界内表达。 | private stream gate / snapshot contract，但不创建 listenKey。 | `docs/audit/mtpro-private-stream-account-snapshot-simulation-gate-v1-stage-code-audit.md` 已记录 L3.2 simulation gate evidence chain、validation 和 forbidden capability audit；不连接 private WebSocket，不运行 production stream。 |
| L3.3 Live Monitoring Read-only Console v2 | Done / not counted in old denominator | 在 L3.0-L3.2 gate 后，升级 Live Monitoring 的只读证据面。 | live monitoring read-model-only surface。 | `docs/audit/mtpro-live-monitoring-read-only-console-v2-stage-code-audit.md` 已记录 L3.3 read-model-only monitoring evidence chain、validation 和 forbidden capability audit；不提供交易控制、Live PRO Console 或 order-level command UI。 |
| L3.4 Strategy / Trader Instance Readiness v1 | Done / not counted in old denominator | 定义 Strategy Instance / Trader Instance 的只读上下文、生命周期、quoter / hedger role、account / portfolio / risk read-model 输入和 paper/live-neutral proposal contract。 | trader / strategy instance readiness，但不进入真实 execution。 | `docs/audit/mtpro-strategy-trader-instance-readiness-v1-stage-code-audit.md` 已记录 L3.4 read-model-only strategy/trader readiness evidence chain、validation 和 forbidden capability audit；不允许 strategy 直连 Execution Client、broker command、OMS、trading button 或 Live PRO Console。 |
| Engine Module Boundary Consolidation before L4 | Done / not counted in old denominator | 把 architecture graph 对齐为 target module boundary、fixed source layout、dependency direction、forbidden path taxonomy 和 L4 planning input material。 | DataClient / DataEngine / MessageBus / Cache / Database / Strategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench boundary planning input，但不进入 runtime implementation。 | `docs/audit/mtpro-engine-module-boundary-consolidation-v1-stage-code-audit.md` 已记录完整 Project closure、PR #283 至 PR #303 evidence、validation、Root Docs Delta 和 forbidden capability audit；不移动 production source，不修改 `Package.swift` target graph，不授权 L4 execution。 |
| Target Module Physical Layout / Source Migration before L4 | Done / not counted in old denominator | 把已固定的 target module boundary 落为 physical source directories 和 compatibility envelope，完成 L4 前 source migration evidence。 | DomainModel / MessageBus / DataClient / DataEngine / Cache / Database / Strategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench / Dashboard physical layout，但不进入 SwiftPM target graph split。 | `docs/audit/mtpro-target-module-physical-layout-source-migration-v1-stage-code-audit.md` 已记录完整 Project closure、PR #306 至 PR #313 evidence、validation、Root Docs Delta 和 forbidden capability audit；不新增 SwiftPM target，不授权 L4 execution。 |
| Trader-Owned Strategies Layout Correction before L4 | Done / not counted in old denominator | 修正 concrete strategy ownership：forward-looking canonical path 是 `Sources/Trader/Strategies/<strategy>/`，旧 `Sources/Strategies/<strategy>` 只作为 historical / compatibility / superseded context；MTP-198 后当前 active concrete strategy 只有 EMA。 | EMA active source placement、OrderBookImbalance historical / compatibility placement evidence、StrategyBindings binding protocol / coordination adapter boundary、forbidden direct execution path audit。 | `docs/audit/mtpro-trader-owned-strategies-layout-correction-v1-stage-code-audit.md` 已记录完整 Project closure、PR #317 至 #323 evidence、validation、Root Docs Delta 和 forbidden capability audit；不新增 SwiftPM target，不授权 Strategy runtime、Trader runtime、ExecutionClient、broker、OMS 或 live command。 |
| L4 Live Production / Trading Commands | Future Gated | 最后进入真实 execution adapter、OMS、execution report、broker fill、reconciliation、live risk runtime、ops / incident / stop 和独立 Live PRO Console 产品面。 | `live`、`execution`、`risk`、`portfolio`、`system`。 | Future Gated；不计入旧 `4 / 4` 分母；必须经过独立 Human decision、Project Definition、signed/account/broker/risk/ops gates。 |

L1 `MTPRO Event-Driven Paper Trading Runtime v1`、L1.5 `MTPRO Data Catalog / Scenario Replay v1`、L2 `MTPRO Simulated Exchange / Backtest Parity v1` 和 L2+ `MTPRO Workbench Beta Readiness v1` 已完成。当前可计数 Engine Maturity Roadmap Progress 已达到 `4 / 4 (100%)`。Live Readiness 作为新路线单独记录，不继续修改旧分母；L3.0 `MTPRO Live Read-only Readiness Boundary v1` 已完成 boundary / forbidden capability / read-model-only evidence chain；L3.1 `MTPRO Account / Position / Balance Read-model-only v1` 已完成 APB read-model-only evidence chain；L3.2 `MTPRO Private Stream / Account Snapshot Simulation Gate v1` 已完成 simulation gate evidence chain；L3.3 `MTPRO Live Monitoring Read-only Console v2` 已完成 read-model-only monitoring evidence chain；L3.4 `MTPRO Strategy / Trader Instance Readiness v1` 已完成 read-model-only strategy/trader structural readiness evidence chain；`MTPRO Engine Module Boundary Consolidation v1` 已完成 architecture-graph-aligned target module boundary、fixed source layout、dependency direction、forbidden path taxonomy 和 L4 planning input material；`MTPRO Target Module Physical Layout / Source Migration v1` 已完成 target module physical directories、compatibility envelope、remaining shell audit 和 source migration evidence；`MTPRO Trader-Owned Strategies Layout Correction v1` 已完成 Trader-owned concrete strategy canonical path correction、EMA active source placement、OrderBookImbalance historical / compatibility source placement、StrategyBindings boundary 和 forbidden direct execution audit；MTP-198 后当前 active concrete strategy 只有 EMA。L4 仍是下一条 planning candidate，必须经过 Human 确认、Linear 写入和 Parent Codex queue preflight 后才可能进入唯一 eligible issue execution。不得从 Trader-Owned Strategies Layout Correction completion 自动规划 SwiftPM target graph split、Live PRO Console、真实 signed / broker / OMS 能力、strategy-to-broker command path、Strategy runtime、Trader runtime、ExecutionClient implementation、private stream runtime、account snapshot runtime、Live Monitoring runtime 或任何 execution。

## Construction Slice Selection / 施工切片选择

下一阶段 planning 只能从 `BLUEPRINT.md` 的 Future Construction Zones / 未来建设区中选择一个清晰切片，并把它收敛为 Project Planning Record。选择切片时必须满足：

- 能对应 `GOAL.md` 的某个 Final Product Goal Slice。
- 能落到 `docs/architecture.md` 中可解释的工程模块或模块边界。
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
