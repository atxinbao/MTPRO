# docs/architecture.md

## 工程模块地图定位

本文档是 MTPRO 的 Engineering Module Map / 工程模块地图。它是 `BLUEPRINT.md` 的二级权重承接文档，负责把完整蓝图翻译成系统模块、模块边界、数据流、接口关系、依赖方向和架构不变量。

本文档不能推翻 `BLUEPRINT.md`，不重新定义产品目标，不作为 Stage Code Audit、validation 或 PR evidence 流水账。已完成 Project 的事实证据进入 `docs/audit/`、`docs/validation/` 和 `verification.md`。

MTPRO 是 SwiftPM-first、Swift-only、local-first 的 macOS 交易研究工作台。架构借鉴 NautilusTrader 的 Kernel、MessageBus、Cache、DataEngine、StrategyEngine、RiskEngine、ExecutionEngine、Portfolio 和 Adapter 职责拆分，但不引入 NautilusTrader 作为运行依赖。

## Architecture Responsibility / 架构职责

`docs/architecture.md` 只回答五个问题：

1. 当前有哪些模块。
2. 模块之间允许怎么依赖。
3. 数据和事件如何流动。
4. 哪些接口边界不能被绕过。
5. Future Live 能力如何被隔离在当前 scope 之外。

它不复制完整产品蓝图，不维护 Project 进度条，也不记录每个 PR 的审计流水账。

## Package Dependency Direction / SwiftPM 依赖方向

```text
Core
Adapters -> Core
Persistence -> Core, CSQLite, DuckDB(macOS)
Runtime -> Core, Adapters, Persistence
App -> Core, Persistence
Dashboard -> App
```

依赖规则：

- `Core` 不能依赖 Adapter、Persistence、Runtime、App 或 Dashboard。
- `Adapters` 只能表达外部 market data 边界，并通过 Core 类型输出事件或证据。
- `Persistence` 只能保存 facts / projections，不能成为 UI contract。
- `Runtime` 可以编排 Core、Adapters、Persistence，但不能直接变成 UI。
- `App` 只能生成 Read Model / ViewModel / Command Model，不能直接调用 Binance adapter 或真实 broker。
- `Dashboard` 只能装载 App 层模型，不读取 SQLite / DuckDB schema、adapter request 或 runtime object。

## Module Boundary Contracts / 模块边界合同

| 模块 | 职责 |
| --- | --- |
| `Core` | 领域模型、事件、命令、策略契约、MessageBus、Kernel / Engine 边界；当前包含 paper-only execution facts 和本地 Paper session-level control command / event boundary |
| `Adapters` | Binance public read-only market data adapter 边界；当前包含本地 batch / replay contract、metadata、retention / freshness 和 fixture parity evidence |
| `Persistence` | Event Log、SQLite runtime projection、DuckDB analytical projection 边界 |
| `Runtime` | Binance public read-only ingest、Core event log、replay 与 projection snapshot 的本地编排边界；当前包含 market data replay event log / projection consistency evidence |
| `App` | Trader Workstation Dashboard 产品面和 ViewModel 边界；当前包含 Paper workflow observability、Event Timeline / Evidence Explorer read model、Market Data Replay Operations read model 和 Dashboard / Workbench shell snapshot |
| `Dashboard` | SwiftPM 可构建 / smoke-run 的 macOS shell，只装载 App 层 ViewModel snapshot；当前展示 read-model-only Workbench、`start` / `pause` / `close` / `reset` session-level local controls、paper workflow evidence preview 和 market data replay operations evidence |

## Capability Flow Map / 能力流地图

### Market Data Replay / 行情回放

```text
Binance public read-only boundary
-> local batch / replay contract
-> replay operations metadata
-> fixture parity / replay consistency
-> event log / projection snapshot consistency
-> Report / Dashboard / Event Timeline read model
```

该流只处理 public market data 和本地 deterministic replay evidence，不绑定真实历史下载规模，也不进入 production operations。

### Research / Backtest / Report / 研究回测报告

```text
Market events
-> Strategy signal evidence
-> Backtest / Paper parity evidence
-> execution cost assumptions
-> risk blocker evidence
-> report artifact / read model
```

该流用于解释策略证据和报告来源，不产生真实交易授权。

### Paper Workflow / 模拟交易工作流

```text
Strategy signal
-> Paper action proposal
-> Risk decision
-> Paper order intent
-> Simulated fill evidence
-> Paper portfolio projection
-> Event log / replay
-> Workbench read model
```

该流全部是 paper-only evidence，不代表真实订单、broker fill、account update 或 Live fallback。

### Workbench / macOS 工作台

```text
Read Models
-> ViewModels / Command Models
-> Dashboard shell
-> read-only evidence presentation
-> session-level local controls only
```

Workbench 可以表达 `start` / `pause` / `close` / `reset` 本地 paper session control，但不得新增 order-level command。

## Target Data Flow / 目标数据流

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

## Architecture Invariants / 架构不变量

- Binance 默认只读 public market data。
- Market data replay operations 自动验证只使用本地 fixture / batch replay evidence，不依赖真实 Binance 网络。
- Event Log 是 append-only facts source。
- SQLite / DuckDB 是 projection，不是 UI 展示模型。
- ViewModel 只能来自稳定 Read Model。
- Paper workflow controls 只能表达本地 session-level paper intent 或 read-only presentation，不得升级为 order-level command。
- Live trading、signed endpoint、account endpoint 和真实 broker action 在当前 scope 禁止。
- `macos-trader` 只提供产品语义参考。
- `nautilus_trader` 只提供架构分层参考。
- MTPRO 不复制参考项目整仓代码。

## Future Live Isolation / 未来实盘隔离

Future Live 能力可以在 `BLUEPRINT.md` 中定义为最终产品目标，但在当前架构中必须保持隔离：

- future signed endpoint / account endpoint 需要独立 adapter capability。
- future broker integration 需要独立 Project Definition、risk gate、operations gate 和 audit gate。
- future real order lifecycle 不得复用 paper order intent 作为真实订单授权。
- future Live risk control 不能由当前 paper-only risk blocker 直接替代。
- future Live monitoring / execution control / incident replay 进入当前 scope 前，必须先更新 `BLUEPRINT.md`、`docs/architecture.md` 和 `docs/roadmap.md`，再由 Human + `@001 / PLN` 形成 Project plan。

## Architecture Update Gate / 架构更新门槛

以下变更必须同步检查本文档：

- 新增 SwiftPM target、模块或跨模块依赖。
- 改变 Event Log、Replay、Projection、Read Model 或 ViewModel 数据流。
- 新增外部系统能力、adapter capability 或 secret 使用。
- 任何从 paper-only 走向 future Live 的能力。
- UI 从 read model / ViewModel 边界外读取数据。

若只是某个 PR 的验证结果、Stage Audit input 或 Project closure evidence，应写入 `docs/audit/`、`docs/validation/` 或 `verification.md`，不写入本文档。
