# GOAL.md

本文档是 MTPRO 的 Project Charter，不是完整蓝图，不是工程模块地图，不是施工计划。

它只回答四个问题：为什么建、服务谁、永久硬边界是什么、怎样判断项目仍然朝正确方向推进。完整产品 / 系统 / 设计蓝图见 `BLUEPRINT.md`；当前施工阶段、目标切片和进度条见 `docs/roadmap.md`。

## 项目使命

MTPRO 的目标是构建一个 local-first 的 macOS 原生专业交易工作台。它先以 Research -> Backtest -> Report -> Paper 建立可追溯、可回放、可验证的交易证据链，再逐步演进为支持 Live trading、实盘监控、实盘执行控制、实盘风险控制和实盘审计 / 事故回放 / 停机控制的专业版本产品。

MTPRO 不是 NautilusTrader 的 Swift 包装，也不是 `macos-trader` 的整仓迁移。它把参考项目和既有产品经验收敛成自己的 SwiftPM-first、macOS-native、evidence-first、local-first 工作台。

## 服务对象

MTPRO 首先服务个人专业交易者 / 独立策略研究者：在本机 Mac 上研究策略、回测策略、生成报告，使用 Binance public market data 建立可追溯 evidence chain，并在不触碰真实交易的前提下观察 Backtest / Paper / Risk / Portfolio consistency。

## 核心承诺

| 承诺 | 含义 |
| --- | --- |
| Local-first | 核心研究、回测、Paper、报告和审计优先在本地工作台闭环完成。 |
| Evidence chain first | 工作台导航以 Research -> Backtest -> Report -> Paper -> Events 为主，不以交易按钮为中心。 |
| 少量可解释策略优先 | 当前 active strategy scope 是 EMA + RSI；其他策略只能作为 future candidate。 |
| Binance boundary | Binance 是当前 active venue；production secret / endpoint / broker / real order 默认关闭。 |
| Paper / Live 隔离 | Paper 证据不能被解释为真实订单、真实成交或 broker action。 |
| Live gated | Live trading 是最终产品目标的一部分，但只能在独立 Human decision、独立 Project Definition、signed endpoint / broker / risk / operations gates 之后进入执行范围。 |

## 当前成功标准

- `BLUEPRINT.md` 保持最终产品 / 系统 / 设计蓝图清楚。
- `architecture.md` 保持工程模块地图、边界、数据流和不变量清楚。
- `docs/roadmap.md` 保持已批准阶段、目标切片和两层进度条清楚。
- Linear / PR / Stage Code Audit evidence 能追溯每个已完成建设阶段。
- SwiftPM baseline、Dashboard smoke 和统一验证入口 `bash checks/run.sh` 持续可运行。
- 正式开发只从唯一 live queue source 中的 configured executable issue 进入。
- Project closure 后必须完成 Stage Code Audit Report 和 Root Docs Refresh Gate closure。

## 当前目标进度

MTPRO 采用两层进度口径：Current Foundation Progress 和 Final Product Goal Progress。截至 2026-06-14：

```text
Current Foundation Progress: 4 / 4 (100%)
Foundation Progress: [##########] 100%

Final Product Goal Progress: 9 / 9 (100%)
Final Product Progress: [##########] 100%

Engine Maturity Roadmap Progress: 4 / 4 (100%)
Engine Maturity Progress: [##########] 100%
```

Current Foundation 已完成 Research / Backtest / Report / Paper readiness、Paper-only execution evidence、Workbench evidence navigation、本地控制壳和 market data replay operations。

Final Product slice anchors：实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制。Final Product 已完成全部 9 项目标切片；第 5 至第 9 项只代表 boundary、contract、blocked evidence 或 read-model-only evidence surface，不代表真实 Live trading、signed/account endpoint、broker adapter、real order lifecycle、production OMS、Live PRO Console command、trading button 或 production operations 已实现或获授权。

完整 9 项目标切片、状态和证据口径见 `docs/roadmap.md`。`GOAL.md` 不复制维护详细进度表。

## 当前模块成熟度

| 口径 | 当前结论 |
| --- | --- |
| Engine maturity | L1 Paper Runtime、L1.5 Data Catalog、L2 Simulated Exchange、L2+ Workbench、L3 read-model-only readiness、module boundary / target graph / Core envelope retirement 均 Done |
| L4 / production readiness | `L4 Live Production / Trading Commands v1 complete with no-default-production-trading policy`；Production Cutover Readiness / Real Broker Enablement Gate Done，但只代表 readiness-only / no-real-broker-authorization，不授权真实 broker |
| Releases | `MTPRO Release v0.1.0` Done / Binance + EMA runtime validation / production disabled by default；`MTPRO Release v0.2.0` Spot + USDⓈ-M Perpetual + EMA/RSI Done；`MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal` Done；`MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline` Done；`MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge` Done；`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening` Done；`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity` Done；`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring` Done；`MTPRO Release v0.9.0 Testnet No-order Observability` Done；`MTPRO Release v0.10.0 Production Cutover Readiness Gate` Done / readiness assessment only / no production cutover authorization；`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening` Done / local readiness evidence runtime / no production cutover authorization；`MTPRO Release v0.12.0 Readiness Assessment Sessions` Done / local redacted readiness assessment evidence / no production cutover authorization；production trading disabled by default |
| Current maturity statement | `MTPRO Release v0.12.0 Readiness Assessment Sessions complete with production trading disabled by default and production cutover not authorized` |

Anchor facts retained for readiness guards:

- Core Envelope Retirement / Real Module Ownership Completion 的 post-audit hardening addendum 已在 PR #448 后完成最终只读审计：production executable `try!` = 0，`@unchecked Sendable` = 0，`bash checks/run.sh` 通过。
- `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 已完成 readiness-only gate；不授权真实 broker、real order、production trading、secret read、production endpoint、broker adapter、LiveExecutionAdapter、production OMS、trading button、live command 或 order form。
- Historical maturity statement retained for release v0.6.0：`MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening complete with production trading disabled by default`。
- Historical maturity statement retained for release v0.7.0：`MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity complete with production trading disabled by default`。
- Historical maturity statement retained for release v0.8.0：`MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring complete with production trading disabled by default`。
- Historical maturity statement retained for release v0.9.0：`MTPRO Release v0.9.0 Testnet No-order Observability complete with production trading disabled by default`。
- Historical maturity statement retained for release v0.11.0：`MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening complete with production trading disabled by default and production cutover not authorized`。
- 无当前可执行推荐；下一阶段必须经 Human + `@001 / PLN` 规划、live queue 写入与 Parent Codex queue preflight。Release v0.12.0 completion 不授权 strategy 直连 ExecutionClient、broker command、production OMS、trading button、Live PRO Console production command、live command、real broker、real order、testnet order routing、production cutover 或任何 production trading。

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

`GOAL.md` 不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动额外调度服务，不授权 future capability 进入当前执行 scope。
