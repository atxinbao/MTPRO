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
- `architecture.md` 保持工程模块地图、边界、数据流和不变量清楚。
- `docs/roadmap.md` 保持已批准阶段、目标切片和两层进度条清楚。
- Linear / PR / Stage Code Audit evidence 能追溯每个已完成建设阶段。
- SwiftPM baseline、Dashboard smoke 和统一验证入口 `bash checks/run.sh` 持续可运行。
- 正式开发只从 Linear 中唯一 configured executable issue 进入。
- Project closure 后必须完成 Stage Code Audit Report 和 Root Docs Refresh Gate closure。

## 当前目标进度

MTPRO 采用两层进度口径：

1. Current Foundation Progress：当前已批准 paper-only foundation 的完成度。
2. Final Product Goal Progress：最终专业交易工作台产品目标的完成度。

截至 2026-06-08：

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

9 / 9 后的模块成熟度建设已完成 `MTPRO Event-Driven Paper Trading Runtime v1`、`MTPRO Data Catalog / Scenario Replay v1`、`MTPRO Simulated Exchange / Backtest Parity v1`、`MTPRO Workbench Beta Readiness v1`、`MTPRO Live Read-only Readiness Boundary v1`、`MTPRO Account / Position / Balance Read-model-only v1`、`MTPRO Private Stream / Account Snapshot Simulation Gate v1`、`MTPRO Live Monitoring Read-only Console v2`、`MTPRO Strategy / Trader Instance Readiness v1`、`MTPRO Engine Module Boundary Consolidation v1`、`MTPRO Target Module Physical Layout / Source Migration v1`、`MTPRO Trader-Owned Strategies Layout Correction v1`、`MTPRO Trader EMA Strategy Layout Consolidation v1`、`MTPRO Trader Accounts / Coordination Compatibility Consolidation v1`、`MTPRO Persistence Validation Repair v1`、`MTPRO SwiftPM Target Graph Module Split v1`、`MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1`、`MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1`、`MTPRO Core Envelope Retirement / Real Module Ownership Completion v1`、`MTPRO L4 Live Production / Trading Commands v1`、`MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 和 `MTPRO Release v0.1.0`。上述事实不改变 Final Product Goal Progress `9 / 9 (100%)`，不扩大旧 Engine Maturity Roadmap Progress `4 / 4 (100%)` 分母，也不表示真实 Live trading、Strategy runtime、Trader runtime、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter、Live PRO Console、production release、notarization、App Store distribution、auto-update、production operations、production trading engine、production data platform、large-scale ingestion pipeline、真实 exchange runtime、production backtest engine、真实 Live read-only runtime、signed endpoint、account endpoint / listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、account / position / balance runtime、Live Monitoring runtime、connection manager、real account read、real position sync、real balance、margin、leverage、real PnL runtime、L4 runtime、真实 broker 或 production trading 已实现或获授权。

Core Envelope Retirement / Real Module Ownership Completion 的 post-audit hardening addendum 已在 PR #448 后完成最终只读审计：PR #448 merge commit 为 `2b78f27a8e2b04ba348d2fc90259c96b9a088aff`，required check `checks` SUCCESS；`rg -n "try!" Sources` 只剩注释说明，production executable `try!` = 0；`rg -n "@unchecked Sendable" Sources` = 0；open GitHub issue / PR = 0；`git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 均通过。该事实只补齐已发生 hardening closure，不增加 Project Closure Count，不创建下一 Project / Issue，不推进 L4。

`MTPRO Trader EMA Strategy Layout Consolidation v1` 已完成 Project closure、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：当前 active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`；非 EMA strategy 只能作为 future candidate / future-gated label / historical evidence / compatibility debt；OrderBookImbalance 已收口为 Core research evidence；Trader Coordination RiskBinding 只表达 coordination / binding boundary。该 closure 只同步已发生 layout、validation matrix、compatibility envelope 和 forbidden direct execution audit，不授权 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 SwiftPM target graph split。

`MTPRO Trader Accounts / Coordination Compatibility Consolidation v1` 已完成 Project closure、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：当前 Trader 容器权威关系为 `Trader = Accounts + Strategies/EMA + Coordination`；`Sources/Trader/Accounts/` 只表达 account identity、source identity 和 future real account gate；`Sources/Trader/Strategies/EMA/` 仍是唯一 active concrete strategy；`Sources/Trader/Coordination/RiskBinding/` 只表达 coordination / binding boundary。该 closure 清理旧 `StrategyBindings` wording 和 stale `Sources/Strategies` compatibility excludes，并增加 Trader container completeness validation；不授权 Trader runtime、Strategy runtime、Live runtime、real account read、ExecutionClient implementation、OMS、broker gateway、SwiftPM target graph split、Live PRO Console、trading button、live command、order form 或 L4 implementation。

`MTPRO Persistence Validation Repair v1` 已完成 Project closure、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：原 `PersistenceTests/testFileEventLogStoreRejectsOutOfOrderAppendToProtectAppendOnlyInvariant -> xctest signal 11` 在 clean build 当前 main 未复现，MTP-214 没有做无根据 production repair，MTP-215 已恢复完整 `bash checks/run.sh` baseline，315 个 XCTest、0 failures。该 closure 不修改 Persistence implementation、不修改 `Tests/PersistenceTests` 行为、不移动 source、不修改 `Package.swift`、不拆 SwiftPM target graph、不修改 architecture module layout，也不授权 Trader runtime、Strategy runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway 或 L4 implementation。

`MTPRO SwiftPM Target Graph Module Split v1` 已完成 Project closure、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：当前 active SwiftPM target graph 包含 `DomainModel`、`MessageBus`、`Database`、`DataClient`、`Cache`、`DataEngine`、`TraderStrategies`、`Trader`、`Portfolio`、`RiskEngine`、`ExecutionClient`、`ExecutionEngine` 和 `Dashboard`；`Core`、`Adapters`、`Persistence` 和 `Runtime` 仍作为 retained compatibility envelopes / exports，`Workbench`、`App` 和 `AppCompatibility` 已退休为 historical wording。该 closure 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed/account endpoint、private stream runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

`MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` 已完成 Project closure、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：当前 `Sources/TargetGraph/` directory 不再存在，`Package.swift` 不再包含 active `Sources/TargetGraph` target path，active target roots 已固定到真实 module roots；历史 `Sources/TargetGraph/<Module>` 文字只能作为 before-state / retired evidence 保留。该 closure 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed/account endpoint、private stream runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

`MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1` 已完成 GitHub fallback queue、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：GH-391 至 GH-401 全部 closed / done；real target ownership contract、direct Trader -> ExecutionEngine dependency removal、real target smoke tests、DomainModel / MessageBus / DataClient / Cache / Trader / Portfolio / Risk / Execution ownership migration、Dashboard naming cleanup、unsafe construct allowed-path validation 和 Core envelope retirement matrix 已闭环。`Core`、`Adapters`、`Persistence`、`Runtime` 仍作为 retained compatibility envelopes 被显式追踪；该 closure 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed/account endpoint、private stream runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

`MTPRO Core Envelope Retirement / Real Module Ownership Completion v1` 已完成 GitHub fallback queue、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：GH-413 至 GH-422 全部 closed / done；MessageBus neutral query / replay、DataEngine scenario replay / quality、Portfolio paper projection、RiskEngine paper pre-trade、ExecutionEngine paper / simulated lifecycle、Database / Persistence / Runtime ownership matrix、Dashboard active naming cleanup、all architecture targets real API smoke coverage、retained envelope matrix 和 L4 blocker review 已闭环。`Core`、`Adapters`、`Persistence`、`Runtime` 仍作为 retained compatibility envelopes 被显式追踪；该 closure 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed/account endpoint、private stream runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

`MTPRO L4 Live Production / Trading Commands v1` 已完成 GitHub fallback queue、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：GH-452 至 GH-472 全部 closed / done；PR #473 至 #493 均通过 required check `checks` 后 merge。该 stage 已建立 command / credential / signed boundary、read-only account / private stream evidence、ExecutionClient / ExecutionEngine sandbox path、OMS lifecycle、RiskEngine pre-trade gate、kill switch、reconciliation、audit trail / incident replay、Dashboard / Live PRO Console split、guarded sandbox UI、sandbox validation matrix、production cutover future gate 和 no-default-production-trading policy。该 closure 不打开 production cutover，不读取 secret，不连接 production endpoint，不启用 real broker gateway，不授权真实 submit / cancel / replace、Live PRO Console production command、order form 或 trading button。

Historical L4 maturity statement：`L4 Live Production / Trading Commands v1 complete with no-default-production-trading policy`。

`MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 已完成 GitHub fallback queue、Stage Code Audit 和 Root Docs Refresh Gate 输入事实：GH-503 至 GH-510 全部 closed / done；PR #511 至 #519 均通过 required check `checks` 后 merge，closure PR #519 merge commit 为 `f37707579499391c0d7d93009c797dbfc3440885`。该 stage 已闭环 credential / secret policy gate、production environment isolation gate、broker / venue capability matrix、manual approval / operator confirmation gate、incident stop / rollback / no-trade state gate、capital / risk / order notional / exposure limit gate、dry-run proof / shadow mode / no-default-production-trading evidence、final readiness matrix、automation readiness 和 Stage Code Audit Report。该 closure 不授权真实 broker，不授权 real order，不打开 production trading，不读取真实 secret，不连接 production endpoint，不接 signed endpoint / account endpoint / listenKey，不实现 broker adapter、LiveExecutionAdapter、production OMS、real submit / cancel / replace、broker fill / reconciliation runtime、trading button、live command 或 order form。

`MTPRO Release v0.1.0` 已完成 GitHub fallback queue、Final Stage Code Audit 和 Root Docs Refresh Gate 输入事实：GH-521 至 GH-541 全部按 WIP=1 收口，PR #542 至 #561 已通过 required check `checks` 后 merge；#541 closure PR 落仓 `docs/audit/mtpro-release-v0.1.0-binance-ema-runtime-stage-code-audit.md` 并同步 root docs。该 release 已建立 Binance + EMA 的最小真实交易运行时验证证据，包括 Binance public market data runtime path、signed account read-only runtime、private stream / account snapshot read-model runtime、Trader Accounts + EMA + Coordination lifecycle、EMA proposal runtime、RiskEngine pre-trade gate、ExecutionEngine / OMS local lifecycle、Binance ExecutionClient testnet submit / cancel / replace evidence、execution report / broker fill parser、reconciliation / Portfolio update path、Dashboard monitoring / controlled command surfaces、kill switch / no-trade / rollback controls、dry-run / testnet validation suite、no-default-production-trading automation guard、release docs / operator runbook 和 final validation matrix。该 closure 不授权 production trading，不读取 production secret，不连接 production endpoint 或 production broker endpoint，不自动连接 broker，不把缺失 testnet credential 回退到 production credential，不启用 non-Binance venue 或 non-EMA active strategy。

当前模块成熟度口径为：`L1 Paper Runtime` Done；`L1.5 Data Catalog / Scenario Replay` Done；`L2 Simulated Exchange / Backtest Parity` Done；`L2+ Workbench Beta Readiness` Done；`L3.0 Live Read-only Readiness Boundary` Done / not counted in old denominator；`L3.1 Account / Position / Balance Read-model-only` Done / not counted in old denominator；`L3.2 Private Stream / Account Snapshot Simulation Gate` Done / not counted in old denominator；`L3.3 Live Monitoring Read-only Console v2` Done / not counted in old denominator；`L3.4 Strategy / Trader Instance Readiness v1` Done / not counted in old denominator；`Engine Module Boundary Consolidation before L4` Done / not counted in old denominator；`Target Module Physical Layout / Source Migration before L4` Done / not counted in old denominator；`Trader-Owned Strategies Layout Correction before L4` Done / not counted in old denominator；`Trader EMA Strategy Layout Consolidation before L4` Done / not counted in old denominator；`Trader Accounts / Coordination Compatibility Consolidation before L4` Done / not counted in old denominator；`Persistence Validation Repair baseline restored` Done / not counted in old denominator；`SwiftPM Target Graph Module Split before L4` Done / not counted in old denominator；`TargetGraph Anchor Retirement / Real Module Source Root Migration before L4` Done / not counted in old denominator；`Real Target Source Ownership / Core Envelope Retirement before L4` Done / not counted in old denominator；`Core Envelope Retirement / Real Module Ownership Completion before L4` Done / not counted in old denominator；`L4 Live Production / Trading Commands v1` Done / no-default-production-trading；`Production Cutover Readiness / Real Broker Enablement Gate v1` Done / readiness-only / no-real-broker-authorization；`MTPRO Release v0.1.0` Done / Binance + EMA runtime validation / production disabled by default。当前成熟度结论：`MTPRO Release v0.1.0 Binance + EMA runtime validation complete with production trading disabled by default`。旧 Engine Maturity Roadmap Progress 保持 `4 / 4 (100%)`，不继续扩分母。当前仍为无当前可执行推荐；下一阶段必须经 Human + `@001 / PLN` 规划、Linear 或 approved fallback queue 写入与 Parent Codex queue preflight 后才可能进入唯一 eligible issue execution。Release v0.1.0 completion 不授权 strategy 直连 ExecutionClient、broker command、production OMS、trading button、Live PRO Console production command、live command、real broker、real order 或任何 production trading。

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
