# GOAL.md

本文档是 MTPRO 的 Project Charter，不是完整蓝图，不是工程模块地图，不是施工计划。

它只回答四个问题：

- 为什么建。
- 服务谁。
- 永久硬边界是什么。
- 怎样判断项目仍然朝正确方向推进。

完整产品 / 系统 / 设计蓝图见 `BLUEPRINT.md`；当前施工阶段、目标切片和进度条见 `docs/roadmap.md`。

## 项目使命

MTPRO 的目标是构建一个 local-first 的 macOS 原生专业交易工作台。

它先以 Research -> Backtest -> Report -> Paper 建立可追溯、可回放、可验证的交易证据链，再逐步演进为支持 Live trading、实盘监控、实盘执行控制、实盘风险控制和实盘审计 / 事故回放 / 停机控制的专业版本产品。

MTPRO 不是 NautilusTrader 的 Swift 包装，也不是 `macos-trader` 的整仓迁移。它把参考项目和既有产品经验收敛成自己的 SwiftPM-first、macOS-native、evidence-first、local-first 工作台。

## 服务对象

MTPRO 首先服务个人专业交易者 / 独立策略研究者：

- 在本机 Mac 上研究策略、回测策略、生成报告的人。
- 使用 Binance public market data 做可追溯研究的人。
- 需要确认 Backtest / Paper / Risk / Portfolio evidence 是否一致的人。
- 需要在不触碰真实交易的前提下观察 paper workflow 的人。
- 未来需要把成熟 evidence chain 推进到 Live trading 专业版本产品的人。

## 核心承诺

- Local-first：核心研究、回测、Paper、报告和审计能力优先在本地工作台闭环完成。
- Evidence chain first：工作台导航以 Research -> Backtest -> Report -> Paper -> Events 的证据链为主，不以交易按钮为中心。
- 少量可解释策略优先：当前策略能力聚焦 EMA、order book imbalance 等可解释 signal evidence，不做策略市场或复杂黑盒策略平台。
- Binance public read-only market data 是当前行情边界；signed endpoint、account endpoint、listenKey 和 broker action 不能混入当前阶段。
- Core 领域语义、event log、projection、read model、ViewModel 和 Command Model 边界清楚。
- Paper 能力全部保持 paper-only，不能被解释为真实订单、真实成交或 broker action。
- Live trading 是最终产品目标的一部分，但只能在独立 Human decision、独立 Project Definition、signed endpoint / broker / risk / operations gates 之后进入当前执行范围。

## 当前成功标准

- `BLUEPRINT.md` 保持最终产品 / 系统 / 设计蓝图清楚。
- `docs/architecture.md` 保持工程模块地图、边界、数据流和不变量清楚。
- `docs/roadmap.md` 保持已批准阶段、目标切片和两层进度条清楚。
- Linear / PR / Stage Code Audit evidence 能追溯每个已完成建设阶段。
- SwiftPM baseline、Dashboard smoke 和统一验证入口 `bash checks/run.sh` 持续可运行。
- 正式开发只从 Linear 中唯一 configured executable issue 进入。
- Project closure 后必须完成 Stage Code Audit Report 和 Root Docs Refresh Gate closure。

## 当前目标进度

MTPRO 采用两层进度口径：

1. Current Foundation Progress：当前已批准 paper-only foundation 的完成度。
2. Final Product Goal Progress：最终专业交易工作台产品目标的完成度。

截至 2026-06-01：

```text
Current Foundation Progress: 4 / 4 (100%)
Foundation Progress: [##########] 100%

Final Product Goal Progress: 9 / 9 (100%)
Final Product Progress: [##########] 100%

Engine Maturity Roadmap Progress: 4 / 4 (100%)
Engine Maturity Progress: [##########] 100%
```

Current Foundation 已完成：

1. Research / Backtest / Report / Paper readiness。
2. Paper-only execution evidence。
3. Paper workflow 可观察性和本地控制壳。
4. 更长周期 market data replay / operations。

Final Product 已完成全部 9 项目标切片；其中第 5 项只完成实盘交易基础边界、阻断证据和只读展示面，不代表真实 Live trading 已实现或获授权；第 6 项只完成实盘监控台的 read-model-only evidence surface，不代表真实 live runtime、signed/account stream、broker stream 或交易控制已实现或获授权；第 7 项只完成实盘执行控制的 contract、future gates、forbidden capability tests、blocked evidence 和 read-model-only evidence surface，不代表真实 execution runtime、真实订单命令、broker fill、execution report 或 reconciliation 已实现或获授权；第 8 项只完成实盘风险控制的 risk gate contract、future gates、forbidden capability tests、paper / live risk isolation、blocked evidence 和 read-model-only evidence surface，不代表真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、circuit breaker command、stop trading command 或 production runtime 已实现或获授权；第 9 项只完成实盘审计 / 事故回放 / 停机控制的 contract、future gates、forbidden capability tests、blocked evidence 和 read-model-only evidence surface，不代表真实 audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command 或 trading button 已实现或获授权。

9 / 9 后的模块成熟度建设已完成 `MTPRO Event-Driven Paper Trading Runtime v1`、`MTPRO Data Catalog / Scenario Replay v1`、`MTPRO Simulated Exchange / Backtest Parity v1`、`MTPRO Workbench Beta Readiness v1`、`MTPRO Live Read-only Readiness Boundary v1`、`MTPRO Account / Position / Balance Read-model-only v1`、`MTPRO Private Stream / Account Snapshot Simulation Gate v1`、`MTPRO Live Monitoring Read-only Console v2`、`MTPRO Strategy / Trader Instance Readiness v1`、`MTPRO Engine Module Boundary Consolidation v1`、`MTPRO Target Module Physical Layout / Source Migration v1` 和 `MTPRO Trader-Owned Strategies Layout Correction v1`：`L1 Paper Runtime` 的 TradingClock、paper-only routing、Paper Pre-trade RiskEngine、local lifecycle、simulated fill、paper account / portfolio projection、Event Log / Replay / Report / Dashboard evidence 已闭环；`L1.5 Data Catalog / Scenario Replay` 的 local manifest、deterministic fixture、replay window / cursor、checksum / freshness evidence、quality gates、report input versioning 和 Workbench / Report / Events read-model evidence 已闭环；`L2 Simulated Exchange / Backtest Parity` 的 shared backtest-paper order semantics、scenario replay deterministic matching、market / limit simulated execution、partial fill / latency / fee / slippage parity、simulated exchange event -> portfolio projection parity 和 Report / Dashboard / Events read-model-only evidence surface 已闭环；`L2+ Workbench Beta Readiness` 的 local macOS launch / install verification、deterministic demo scenario、first-run default demo state、Report / Dashboard / Events beta acceptance path、可复现 acceptance checklist / script、docs index、operator guide、automation readiness 和 Stage Code Audit evidence 已闭环；`L3.0 Live Read-only Readiness Boundary` 的 terminology、credential / secret policy、endpoint taxonomy、adapter capability matrix、account / position / balance future gates、private stream / account snapshot simulation gate、Workbench read-model-only boundary、validation matrix、automation readiness 和 Stage Code Audit evidence 已闭环；`L3.1 Account / Position / Balance Read-model-only` 的 account / position / balance terminology、snapshot identity、source / freshness evidence、position exposure evidence、balance paper-vs-real interpretation boundary、deterministic fixture、forbidden real account tests、Workbench / Report / Events read-model-only surface、validation matrix、automation readiness 和 Stage Code Audit evidence 已闭环；`L3.2 Private Stream / Account Snapshot Simulation Gate` 的 simulated private account event source identity、simulated account snapshot input、account snapshot update fixture、fresh / stale / blocked / missing evidence、forbidden endpoint / runtime tests、Workbench / Report / Events read-model-only simulation gate surface、validation matrix、automation readiness 和 Stage Code Audit evidence 已闭环；`L3.3 Live Monitoring Read-only Console v2` 的 terminology、monitoring source identity、simulation gate health / freshness evidence、connection readiness explanation、forbidden runtime / endpoint / UI command tests、Workbench / Report / Events read-model-only surface、validation matrix、automation readiness 和 Stage Code Audit evidence 已闭环；`L3.4 Strategy / Trader Instance Readiness v1` 的 terminology、lifecycle / identity、quoter / hedger role taxonomy、account / portfolio / risk read-model input、paper/live-neutral proposal isolation、forbidden Strategy -> Execution / broker / UI command tests、Workbench / Report / Events read-model-only strategy readiness surface、validation matrix、automation readiness 和 Stage Code Audit evidence 已闭环；`Engine Module Boundary Consolidation before L4` 的 architecture-graph-aligned module terminology、fixed target source module layout、dependency direction、MessageBus / Cache / Database / DataClient / DataEngine / Strategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench boundary、Future Live PRO Console split、L4 planning input material、validation matrix、automation readiness 和 Stage Code Audit evidence 已闭环；`Target Module Physical Layout / Source Migration before L4` 已完成 DomainModel / MessageBus / DataClient / DataEngine / Cache / Database / Strategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench / Dashboard 的 directory-first source migration、compatibility envelope、remaining shell audit、validation matrix、automation readiness 和 Stage Code Audit evidence；`Trader-Owned Strategies Layout Correction before L4` 已完成 concrete strategy canonical path correction、EMA Trader-owned source placement、OrderBookImbalance historical / compatibility placement evidence、StrategyBindings boundary、historical path compatibility treatment 和 forbidden direct execution audit；MTP-198 之后当前 active concrete strategy 仅 `EMA`，`OrderBookImbalance` 与其他非 EMA strategy 只能作为 future candidate / future-gated label 或 compatibility debt 处理。该事实不改变 Final Product Goal Progress `9 / 9 (100%)`，不扩大旧 Engine Maturity Roadmap Progress `4 / 4 (100%)` 分母，也不表示真实 Live trading、Strategy runtime、Trader runtime、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter、Live PRO Console、production release、notarization、App Store distribution、auto-update、production operations、production trading engine、production data platform、large-scale ingestion pipeline、真实 exchange runtime、production backtest engine、真实 Live read-only runtime、signed endpoint、account endpoint / listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、account / position / balance runtime、Live Monitoring runtime、connection manager、real account read、real position sync、real balance、margin、leverage、real PnL runtime 或 SwiftPM target graph split 已实现或获授权。

`MTPRO Trader EMA Strategy Layout Consolidation v1` 已完成 Project closure、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：当前 active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`；非 EMA strategy 只能作为 future candidate / future-gated label / historical evidence / compatibility debt；OrderBookImbalance 已收口为 Core research evidence；Trader Coordination RiskBinding 只表达 coordination / binding boundary。该 closure 只同步已发生 layout、validation matrix、compatibility envelope 和 forbidden direct execution audit，不授权 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 SwiftPM target graph split。

当前模块成熟度口径为：`L1 Paper Runtime` Done；`L1.5 Data Catalog / Scenario Replay` Done；`L2 Simulated Exchange / Backtest Parity` Done；`L2+ Workbench Beta Readiness` Done；`L3.0 Live Read-only Readiness Boundary` Done / not counted in old denominator；`L3.1 Account / Position / Balance Read-model-only` Done / not counted in old denominator；`L3.2 Private Stream / Account Snapshot Simulation Gate` Done / not counted in old denominator；`L3.3 Live Monitoring Read-only Console v2` Done / not counted in old denominator；`L3.4 Strategy / Trader Instance Readiness v1` Done / not counted in old denominator；`Engine Module Boundary Consolidation before L4` Done / not counted in old denominator；`Target Module Physical Layout / Source Migration before L4` Done / not counted in old denominator；`Trader-Owned Strategies Layout Correction before L4` Done / not counted in old denominator；`Trader EMA Strategy Layout Consolidation before L4` Done / not counted in old denominator。当前成熟度结论：`Trader EMA Strategy Layout Consolidation before L4 complete`，且当前可执行 / 可规划的 active concrete strategy 仍只允许 `EMA`。旧 Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`，不继续扩分母。当前仍为无当前可执行推荐；下一条 Live Readiness planning candidate 是 `L4 Live Production / Trading Commands`，但仍必须经 Human + `@001 / PLN` 规划、Linear 写入与 Parent Codex queue preflight 后才可能进入唯一 eligible issue execution。`L4 Live Production / Trading Commands` 和 SwiftPM target graph split 仍为 Future Gated；Trader EMA Strategy Layout Consolidation 只证明 EMA-only active strategy layout、compatibility envelope、RiskBinding boundary、validation matrix 和 forbidden direct execution audit 已闭环，不授权 strategy 直连 ExecutionClient、broker command、OMS、trading button、Live PRO Console、live command 或任何 L4 implementation。

完整 9 项目标切片、状态和证据口径见 `docs/roadmap.md`。`GOAL.md` 不复制维护详细进度表。

## 永久硬边界

- 当前阶段不实现真实 Live trading。
- 当前阶段不接 signed endpoint、account endpoint 或 listenKey。
- 当前阶段不连接 broker。
- 当前阶段不提交、撤销、替换真实订单。
- 当前阶段不实现真实账户余额、broker position sync 或 OMS。
- 不迁移 `macos-trader` 整仓代码。
- 不引入 NautilusTrader 作为运行依赖。
- 不把 `BLUEPRINT.md` 中的 Future Construction Zones / 未来建设区自动转成当前 execution scope。

## 非授权边界

- `GOAL.md` 不创建 Linear Project / Issue。
- `GOAL.md` 不修改 Linear status。
- `GOAL.md` 不推进 `Todo`。
- `GOAL.md` 不启动额外调度服务。
- `GOAL.md` 不授权 future capability 进入当前执行 scope。
