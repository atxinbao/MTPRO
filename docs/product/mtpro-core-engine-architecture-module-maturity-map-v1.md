# MTPRO Core Engine Architecture & Module Maturity Map v1

日期：2026-05-25

执行者：Codex

状态：产品 / 架构层蓝图；不授权 Linear execution / Paper runtime implementation / Live trading

## 1. 文档定位

本文用于把 MTPRO 与 `atxinbao/nautilus_trader` 的模块成熟度差距整理为 Engine 级架构地图。它不是 Linear Project Draft，不创建 Project / Issue，不推进 `Todo`，不启动 `@002 / PAR`、Symphony、Graphify，不修改 Figma，不写业务代码。

本文不授权真实交易、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation runtime、live risk engine、Live PRO Console、trading button 或 live command。

## 2. 架构图对齐校准

早期禁止边界用于防止 current scope 越界，不表示目标架构不能出现 `ExecutionClient`、`OMS`、`Trader runtime`、`Strategy runtime`、`Portfolio runtime`、`Risk runtime`、`Cache` 或完整 `MessageBus` 这些模块名。

从 `MTPRO Engine Module Boundary Consolidation v1` 开始，目标架构模块可以被纳入 Engine map；但 current Project 只能定义职责、输入输出、依赖方向、allowed source、forbidden source 和 validation anchors，不自动授权 live runtime、broker / exchange execution adapter、signed endpoint、account endpoint / listenKey、real order lifecycle、OMS implementation、Live PRO Console、trading button 或 live command。

## 3. Core Engine Map

| Engine / Layer | 角色 |
| --- | --- |
| Domain Model Foundation | Instrument、Money、Currency、Price、Quantity、Identifiers、Event schema |
| System Kernel | Kernel、Clock、MessageBus、CommandBus、EventBus、lifecycle |
| Connectivity / Adapter Engine | Data clients、Execution clients、capability matrix、future gates |
| Data Engine | market data、requests、replay、catalog、quality |
| Strategy Engine | strategy lifecycle、quoter、hedger、signals、proposals |
| Analysis / Research Engine | research runs、indicators、analytics、report inputs |
| Simulation / Backtest Engine | simulated exchange、matching、latency、fill、fee / slippage |
| Risk Engine | paper risk、future live risk、gates |
| Execution Engine | paper lifecycle coordinator、simulated lifecycle、future OMS |
| Portfolio Engine | paper account、positions、PnL、exposure、future real account |
| State & Persistence Engine | Cache、Event Log、Snapshot、Projection、Replay、SQLite、DuckDB |
| Workbench Interface | ReadModel、ViewModel、Dashboard、Report、Events Audit |
| Future Live PRO Console | future-gated separate product surface |

## 4. 交易数据流

```text
Data Clients
-> Data Engine
-> Message Bus
-> Strategy instances
-> Risk Engine
-> Execution Engine
-> Execution Clients
-> Portfolio
-> Cache / Event Log / Database
-> Workbench Interface
```

## 5. Engine 成熟度等级

| Level | 含义 |
| --- | --- |
| L0 | docs / boundary only |
| L1 | paper-only local runtime or deterministic evidence |
| L1.5 | catalog / scenario replay / local data foundation |
| L2 | simulated exchange / backtest parity |
| L2+ | Workbench beta / evidence surface |
| L3 | live readiness / read-model-only / simulation gate |
| L4 | live production / trading command boundary with no-default-production-trading |

## 6. 当前成熟度矩阵

| Area | 当前结论 |
| --- | --- |
| Paper / replay / parity / beta | L1、L1.5、L2、L2+ 已完成 |
| Live readiness | L3.0 到 L3.4 已完成的是 readiness / read-model / simulation gate / strategy-trader structural evidence，不等于 live runtime implementation |
| Module boundary | Engine Module Boundary Consolidation、Target Module Layout、Trader-owned strategy correction、SwiftPM target graph split、TargetGraph retirement、Core envelope retirement 已完成 |
| L4 / releases | L4 command boundary、production cutover readiness-only gate、release v0.1.0 到 v0.5.0 evidence 已完成，production trading disabled by default |

## 7. Strategy quoter / hedger 归属

Strategy / quoter / hedger 属于 Trader-owned strategy lifecycle 和 proposal evidence，不允许直连 ExecutionClient、broker、OMS、signed endpoint 或 real order command。当前 active concrete strategy 由 release gate 明确，历史 strategy 只能作为 research / future candidate evidence。

## 8. Non-authorization Boundary

本文不授权：

- Linear / GitHub issue 创建或 status 推进。
- source move、`Package.swift` target graph change。
- Strategy runtime、Trader runtime、Live runtime。
- ExecutionClient production implementation、OMS、broker gateway。
- signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- Live PRO Console、trading button、live command、order form。
- production secret read、production endpoint、production broker connection、production cutover。

## 9. 给后续 Planning 的要求

后续 Project Draft 必须说明补的是哪个 Engine / Layer、目标 maturity level、当前 evidence、允许施工范围、forbidden capabilities 和 validation anchors；不能把 maturity map 直接当成 execution authorization。
