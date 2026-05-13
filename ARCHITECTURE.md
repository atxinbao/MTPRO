# ARCHITECTURE.md

## 架构定位

MTPRO 是 Swift-only macOS 交易研究工作台。

架构借鉴 NautilusTrader 的职责拆分：

- Kernel
- MessageBus
- Cache
- DataEngine
- StrategyEngine
- RiskEngine
- ExecutionEngine
- Portfolio
- Adapter

第一版只定义边界和骨架，不实现引擎行为。

## 模块地图

| 模块 | 职责 | 当前状态 |
| --- | --- | --- |
| `MTPROCore` | 领域模型、事件、Kernel / Engine 边界 | skeleton |
| `MTPROAdapters` | Binance read-only market data adapter 边界 | skeleton |
| `MTPROPersistence` | Event Log / SQLite / DuckDB 边界 | skeleton |
| `MTPROApp` | Trader Workstation Dashboard 产品面 | skeleton |

## 数据流目标

```text
Binance public data
-> Adapter
-> DataEngine
-> Cache
-> Strategy
-> Risk
-> Paper Execution
-> Portfolio
-> Event Log
-> Read Models
-> SwiftUI ViewModels
```

当前只定义这条链路，不实现真实数据流。

## 持久化边界

- Event Log：事实源。
- SQLite：运行状态、配置、订单、组合等轻量投影。
- DuckDB：市场数据、回测和分析投影。

数据库不直接作为 UI 展示模型。

## Live 边界

v1 完全禁止 Live trading。

不创建真实 broker action，不提交订单，不接 signed endpoint，不保留可误用的 LiveExecutionAdapter stub。

## 参考项目关系

`macos-trader` 提供已验证产品语义。

`nautilus_trader` 提供架构分层参考。

MTPRO 是独立仓库，不复制参考项目整仓代码。
