# ARCHITECTURE.md

## 架构定位

MTPRO 是 Swift-only macOS 交易研究工作台。

架构借鉴 NautilusTrader 的职责拆分：Kernel、MessageBus、Cache、DataEngine、StrategyEngine、RiskEngine、ExecutionEngine、Portfolio 和 Adapter。

第一版只做 Research -> Backtest -> Report -> Paper readiness，不进入 Live trading。

## 模块地图

| 模块 | 职责 |
| --- | --- |
| `Core` | 领域模型、事件、命令、策略契约、MessageBus、Kernel / Engine 边界 |
| `Adapters` | Binance public read-only market data adapter 边界 |
| `Persistence` | Event Log、SQLite runtime projection、DuckDB analytical projection 边界 |
| `App` | Trader Workstation Dashboard 产品面和 ViewModel 边界 |

## 目标数据流

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

## 不变量

- Binance 默认只读 public market data。
- Event Log 是 append-only facts source。
- SQLite / DuckDB 是 projection，不是 UI 展示模型。
- ViewModel 只能来自稳定 Read Model。
- Live trading、signed endpoint、account endpoint 和真实 broker action 在 v1 禁止。
- `macos-trader` 只提供产品语义参考。
- `nautilus_trader` 只提供架构分层参考。
- MTPRO 不复制参考项目整仓代码。
