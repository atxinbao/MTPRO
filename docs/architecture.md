# docs/architecture.md

## 工程模块地图定位

MTPRO 是 Swift-only macOS 交易研究工作台。

本文档是 Engineering Module Map / 工程模块地图。它是 `BLUEPRINT.md` 的二级权重承接文档，负责把完整蓝图翻译成系统模块、模块边界、数据流、接口关系、依赖方向和架构不变量。

本文档不能推翻 `BLUEPRINT.md`，不重新定义产品目标，不作为 Stage Code Audit、validation 或 PR evidence 流水账。已完成 Project 的事实证据进入 `docs/audit/`、`docs/validation/` 和 `verification.md`。

架构借鉴 NautilusTrader 的职责拆分：Kernel、MessageBus、Cache、DataEngine、StrategyEngine、RiskEngine、ExecutionEngine、Portfolio 和 Adapter。

当前已完成 Research -> Backtest -> Report -> Paper readiness、paper-only execution evidence、本地 Paper workflow 可观察性和 session-level control shell，以及 market data replay operations 本地 evidence baseline。MTPRO 仍不进入 Live trading。

## 模块地图

| 模块 | 职责 |
| --- | --- |
| `Core` | 领域模型、事件、命令、策略契约、MessageBus、Kernel / Engine 边界；当前包含 paper-only execution facts 和本地 Paper session-level control command / event boundary |
| `Adapters` | Binance public read-only market data adapter 边界；当前包含本地 batch / replay contract、metadata、retention / freshness 和 fixture parity evidence |
| `Persistence` | Event Log、SQLite runtime projection、DuckDB analytical projection 边界 |
| `Runtime` | Binance public read-only ingest、Core event log、replay 与 projection snapshot 的本地编排边界；当前包含 market data replay event log / projection consistency evidence |
| `App` | Trader Workstation Dashboard 产品面和 ViewModel 边界；当前包含 Paper workflow observability、Event Timeline / Evidence Explorer read model、Market Data Replay Operations read model 和 Dashboard / Workbench shell snapshot |
| `Dashboard` | SwiftPM 可构建 / smoke-run 的 macOS 只读看板 shell，只装载 App 层 ViewModel snapshot；当前展示 read-model-only Workbench、`start` / `pause` / `close` / `reset` session-level local controls、paper workflow evidence preview 和 market data replay operations evidence |

## 目标数据流

```text
Binance public data
-> Adapter
-> Local batch / replay contract
-> Runtime ingest workflow
-> DataEngine
-> Cache
-> Strategy
-> Risk
-> Paper Execution
-> Portfolio
-> Paper session-level local control facts
-> Event Log
-> Read Models
-> SwiftUI ViewModels
```

## 不变量

- Binance 默认只读 public market data。
- Market data replay operations 自动验证只使用本地 fixture / batch replay evidence，不依赖真实 Binance 网络。
- Event Log 是 append-only facts source。
- SQLite / DuckDB 是 projection，不是 UI 展示模型。
- ViewModel 只能来自稳定 Read Model。
- Paper workflow controls 只能表达本地 session-level paper intent 或 read-only presentation，不得升级为 order-level command。
- Live trading、signed endpoint、account endpoint 和真实 broker action 在 v1 禁止。
- `macos-trader` 只提供产品语义参考。
- `nautilus_trader` 只提供架构分层参考。
- MTPRO 不复制参考项目整仓代码。
