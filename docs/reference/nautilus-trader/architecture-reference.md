# NautilusTrader Architecture Reference

日期：2026-05-19

执行者：Codex（@005 / ARC Architecture Reference Lead）

## 研究边界

本文档是 `MTPRO NautilusTrader Reference Study` 的 Architecture Reference 部分，只提炼 NautilusTrader 对 MTPRO 的架构参考价值。

本文档不创建 Linear Project / Issue，不推进 Todo，不启动 Symphony，不写业务代码，不直接修改 `architecture.md`、`environment.md` 或 `docs/roadmap.md`。

NautilusTrader 只作为系统结构、模块边界、事件流、重放、适配器、运行时、执行、风险和组合语义参考。MTPRO 不复制 NautilusTrader 代码，不引入 NautilusTrader 作为运行依赖。

## 来源范围

本次阅读范围：

- GitHub source：`https://github.com/nautechsystems/nautilus_trader`
- Official docs：`https://nautilustrader.io/docs/latest/`
- Rust API：`https://nautechsystems.github.io/nautilus_docs/rust-api-latest/`
- Python API：`https://nautechsystems.github.io/nautilus_docs/python-api-latest/`

本地源码参考快照：

- Git commit：`c3eed62afb477c3efdb078f6a934f7c5f8f7db61`
- 读取路径：`/tmp/nautilus_trader_ref`

## NautilusTrader 核心系统结构摘要

NautilusTrader 是一个 Rust-native、Python control plane 的多资产、多场所交易系统框架。其官方定位强调：研究、确定性模拟和 live execution 共享同一个 event-driven architecture；Python 主要承担策略逻辑、配置和编排控制面，Rust 承担核心运行时、类型和性能边界。

核心结构可以概括为：

```text
Adapters / DataClient / ExecutionClient
-> DataEngine / RiskEngine / ExecutionEngine
-> MessageBus
-> Cache / Portfolio
-> Strategy / Actor callbacks
-> BacktestNode / LiveNode / NautilusKernel lifecycle
```

它的关键架构选择不是某个单独组件，而是把以下语义组合为统一运行时：

- DDD：交易领域对象、事件、订单、仓位、账户、行情类型都是显式模型。
- Event-driven：状态变化通过 data / command / event 消息流转。
- Ports and adapters：场所 API 被 adapter 归一化为内部 DataClient / ExecutionClient。
- Common kernel：Backtest、Sandbox、Live 共享 `NautilusKernel`、`MessageBus`、`Cache`、Data / Execution / Risk / Portfolio 组件。
- 单线程核心调度：核心消息、策略回调、风险检查、执行协调和 cache 写入在一个确定性核心线程中消费，外部网络和持久化作为边界服务把结果送回核心。
- Backtest-live parity：同一策略、执行语义和时间模型尽量跨 research / live 保持一致。

对 MTPRO 的参考价值：MTPRO 不需要复制 NautilusTrader 的完整交易终端能力，但应学习其“共同核心 + 环境特化 node + adapter 归一化 + event log / replay / projection 可审计”的系统组织方式。

## 模块参考

### Engine / Kernel

NautilusTrader 的 `NautilusKernel` 是统一装配点。源码中的 `crates/system/src/kernel.rs` 显示 Kernel 持有并初始化 `Cache`、`Clock`、`Portfolio`、`DataEngine`、`RiskEngine`、`ExecutionEngine`、`OrderEmulatorAdapter` 和 `Trader`，并注册 Data / Risk / Execution 的 message bus handlers。

MTPRO 映射建议：

- `Runtime` 应承担类似 Kernel 的本地编排边界，但保持 MTPRO v1 的 paper-only 范围。
- `Core` 保留领域模型、命令、事件、MessageBus、Cache、Strategy / Risk / Paper Execution contract。
- `Runtime` 不应直接拥有 UI 状态；它只产出 event log facts、replay result 和 projection snapshot。
- 当前 Swift actor `TradingKernel` 的方向是正确的：串行 ingest、cache、message stream，保证本地确定性。

### Message Bus

NautilusTrader 的 MessageBus 支持 point-to-point、pub/sub、request/response，消息类别包括 Data、Events、Commands。官方文档特别强调消息创建后不应被修改，组件工作状态应保留在组件自己的上下文里，而不是重写原消息。

源码中 `crates/common/src/msgbus/mod.rs` 进一步显示 MessageBus 是线程本地、单线程 runtime 友好的内存 bus，并分为 typed routing 与 any-based routing。这个设计服务两个目标：热路径低开销，以及 Python / custom object 的扩展能力。

MTPRO 映射建议：

- `Core.MessageBus` 应保持 append-only、monotonic sequence、immutable envelope。
- 对 MTPRO 来说，message bus 不需要一开始支持外部 broker 或 Redis stream；当前 event log + replay 已经更适合 v1。
- 所有跨模块命令必须保持显式类型，不允许 UI 或 adapter 私下调用 Runtime object。

### Cache

NautilusTrader 的 Cache 是中心内存状态库，保存行情、订单、仓位、账户、instrument、currency 和 custom data。其文档说明 quotes / trades / bars 由 DataEngine 先写 Cache 再发布给订阅者，保证策略 handler 运行时可以读到最新缓存。源码中 `CacheView` 只暴露不可变借用给 adapter-facing code，避免 adapter 越权写 cache。

MTPRO 映射建议：

- MTPRO `Core.MarketDataCache` 应继续定位为 replay 可重建的内存投影，而不是长期事实源。
- 当前“Event Log 是 append-only facts source，SQLite / DuckDB 是 projection”的边界应保持。
- 可以学习 NautilusTrader 的 `CacheView` 思想：未来 adapter / App / ViewModel 只拿只读 view，不拿可写 cache 或 runtime 引用。

### Adapter

NautilusTrader adapter 由 HTTP client、WebSocket client、InstrumentProvider、DataClient、ExecutionClient 组成。Integration 文档要求 adapter 把交易所 / 数据提供方原始 API 归一化为统一接口和 normalized domain model；官方 integration goals 包括历史行情、实时行情、执行状态 reconciliation、标准订单提交 / 修改 / 取消。

MTPRO 映射建议：

- `Adapters` 只学习 DataClient 归一化边界，不学习 ExecutionClient 的 live order 能力。
- Binance adapter 必须继续保持 public read-only：`exchangeInfo`、`klines`、recent trades、best bid / ask、depth snapshot / delta。
- 不应把 NautilusTrader 的完整 InstrumentProvider / ExecutionClient 复杂度提前搬进 MTPRO。MTPRO v1 只需要稳定 symbol universe、timeframe、public market data decoding 和 fixture parity。

### Data Engine

NautilusTrader DataEngine 是 data stack 中心组件，负责和多个 DataClient 交互，处理 data commands / responses / market data，并把 market data 写入 cache 和 message bus。源码中 `DataEngine` 持有 clients、routing map、bar aggregators、book updaters、option chain managers、deferred command queue 等。

MTPRO 映射建议：

- `Core.DataEngine` 应保持窄边界：只接收已归一化的只读 `MarketEvent`，同步写 `MarketDataCache` 和 `MessageBus`。
- bar aggregation、order book updater、multi-client routing 可作为未来候选能力，不应现在扩展。
- 对当前 Paper Execution Workflow，DataEngine 不应触发 proposal、risk 或 execution；它只提供行情事实。

### Execution

NautilusTrader ExecutionEngine 管理订单生命周期，路由交易命令到 ExecutionClient，处理 venue acknowledgements / fills，更新 Cache，并产出 order / position events。Execution 文档描述了典型路径：

```text
Strategy
-> OrderEmulator / ExecAlgorithm / RiskEngine
-> ExecutionEngine
-> ExecutionClient
-> Execution events
-> Cache / Position / Portfolio / Strategy handlers
```

MTPRO 映射建议：

- MTPRO 当前不应学习真实 `ExecutionClient` 或 live order lifecycle。
- 应学习 execution 的“命令先经过 risk，再形成事件，再由 portfolio 投影消费”的因果链。
- Paper execution 应被命名为 paper-only evidence pipeline，不应伪装成真实 broker execution。
- `PaperOrderIntent`、`SimulatedFillEvidence`、`PortfolioProjectionUpdate` 之间应保持 source sequence 可追溯，而不是共享可变状态。

### Risk

NautilusTrader RiskEngine 是所有 backtest、sandbox、live 系统的组件之一。源码显示 RiskEngine 持有 Cache、Portfolio、Clock、throttlers、max notional、trading state，并把通过的交易命令转发到 ExecutionEngine queue endpoint。官方 Execution 文档说明，除非配置绕过，RiskEngine 会验证订单提交、修改和交易状态。

MTPRO 映射建议：

- MTPRO 应学习 Risk 作为 execution gateway 的位置：proposal / intent 不能越过 risk 直接进入 paper fill 或 portfolio update。
- 当前 v1 的 risk blocker 应继续保持 deterministic fixture 和 paper-only evidence，不引入实时风控、账户余额、保证金、杠杆或 broker rejection。
- 可以在文档中把 Risk 明确为“本地 paper execution authorization gate”，但不能写成 live risk engine。

### Portfolio

NautilusTrader Portfolio 是管理 trading node / backtest 内所有 active strategies 仓位的中心。它聚合 position data，提供 holdings、risk exposure、performance 视图，并支持 PnL / exposure 的 currency conversion。源码显示 Portfolio 订阅 `AccountState`、`PositionEvent`、quotes / bars 等消息，并维护 net positions、realized / unrealized PnL、snapshot buffer 和 analyzer。

MTPRO 映射建议：

- `PortfolioReadModel` 只表达 paper-only projection exposure，不代表真实账户、margin、broker position。
- 未来 portfolio 可学习“由 fill / position events 推导，而不是由 UI 手写”的方向。
- 当前不要学习复杂 currency conversion、account manager、portfolio analyzer 或 long-lived live snapshot buffer。

### Persistence

NautilusTrader 在 Cache 和 MessageBus 配置中支持持久化 backing store，官方文档多处提到 Redis / message streams / cache database，用于 restart recovery、external publishing、execution reconciliation 和 audit。Rust API 也有 `nautilus_persistence` 与 `nautilus_event_store` crates。

MTPRO 映射建议：

- MTPRO 已经采用更适合本阶段的边界：append-only Event Log 是事实源，SQLite / DuckDB 是 projection。
- 不应学习 NautilusTrader 的 Redis-backed runtime persistence 作为 v1 依赖。
- 应学习其“不从 projection 反推事实”的思想：replay 必须从 event log envelope 出发，projection 可重建、可丢弃。

## Event-driven / Replay / Backtest / Paper / Live 分层参考

### Event-driven

NautilusTrader 的事件体系把 order、position、account、time 等状态变化表示为事件对象，并通过 MessageBus 分发给 strategy / actor handlers。Order fill 到 position event 的因果链非常清晰：ExecutionEngine 接收 fill，更新 order cache，决定 position ID，创建或更新 position，再触发 position event。

MTPRO 应学习：

- 所有状态变化都应有事件或 evidence fact。
- 事件必须带 source sequence / timestamp / stream，便于 replay 和 report evidence。
- `allowed risk decision` 不能跳过事件链直接改 portfolio projection。

### Replay

NautilusTrader 的 backtest 以历史数据流驱动系统组件，Cache 和 MessageBus 参与同一套事件处理。它同时提供 high-level `BacktestNode` 和 low-level `BacktestEngine`。文档强调多次 backtest 可通过 fresh engine 或 reset 方式获得 clean state；源码中的 BacktestEngine 持有 `NautilusKernel` 和 simulated venues / execution clients。

MTPRO 应学习：

- replay 是系统级能力，不只是测试 helper。
- 每次 replay 应明确起点、输入数据、stream、sequence 和 projection target。
- 多 run 之间的状态清理必须显式，避免 stale risk / portfolio 数据残留。

### Backtest

NautilusTrader BacktestEngine 处理历史数据流，并使用 simulated exchange / execution client 模拟执行。它的价值在于让策略、cache、portfolio、execution algorithms 在事件驱动系统里跑，而不是离线向量计算后再另写 live 系统。

MTPRO 应学习：

- Backtest 和 Paper 应共享策略 contract、market data query、event timeline 和 validation evidence。
- Backtest result 不应直接授权 Paper / Live execution。
- Backtest 的输出应进入 ReportReadModel，而不是绕过 projection 给 UI。

### Paper

NautilusTrader 的官方环境上下文包括 Backtest、Sandbox、Live；其中 Live 可连接 real-time data 和 live venues，paper trading 或真实账户属于 live venue 上的不同 account / adapter 行为。对 MTPRO 来说，这一点必须谨慎翻译。

MTPRO 应学习：

- Paper 应与 Backtest 共享策略和事件语义。
- Paper 必须有独立 boundary flags，明确不等于 live venue、不等于 broker account、不等于 signed endpoint。

MTPRO 不应学习：

- 不把 NautilusTrader 的 paper/live 同节点能力直接映射到 MTPRO v1。
- 不把 paper-only workflow 建成可切换到 live execution 的隐藏开关。

### Live

NautilusTrader LiveNode 使用单线程 tokio event loop multiplex data events、execution events、trading commands、timers 和 reconciliation / purge / audit 等维护任务。Live 文档强调 execution reconciliation 只在 LiveExecutionEngine 中执行，因为 backtest 同时控制内部和外部状态；live adapter 对未知提交结果不能错误地产生 terminal rejection。

MTPRO 当前边界：

- Live trading、signed endpoint、account endpoint、listenKey、broker action 和真实订单全部禁止。
- 因此 Live 只作为“未来如要开启，需要独立 Project、独立安全边界、独立 adapter contract、独立 reconciliation evidence”的参考。
- 当前不应在代码或文档中暗示 v1 可以从 paper 自动升级 live。

## 对 MTPRO 模块的映射建议

| NautilusTrader 概念 | MTPRO 当前模块 | 建议映射 |
| --- | --- | --- |
| `NautilusKernel` | `Runtime` / `Core.TradingKernel` | `Runtime` 负责编排 ingest、event log、replay、projection；`Core.TradingKernel` 保持串行事件和 cache 不变量。 |
| `MessageBus` | `Core.MessageBus` | 保持 immutable event envelope、monotonic sequence、typed commands/events；不引入外部 message broker。 |
| `Cache` | `Core.MarketDataCache` / read model projections | Cache 是可重建内存状态；事实源仍是 append-only Event Log。 |
| `DataEngine` | `Core.DataEngine` / `Runtime ingest` | 只处理 read-only market events；不要引入 order 或 execution side effect。 |
| `ExecutionEngine` | `Core` paper-only execution contracts | 只学习 command -> risk -> event -> projection 因果链；不学习 live execution client。 |
| `RiskEngine` | `Core` risk blocker / paper authorization | 风险是 paper intent 进入 fill / portfolio projection 前的 gate。 |
| `Portfolio` | `Persistence` / `App` portfolio read model | 只表达 paper-only exposure projection；不表达 broker account 或 real position。 |
| `Adapters` | `Adapters` Binance public boundary | 只学习 DataClient 归一化；不学习 ExecutionClient。 |
| `BacktestEngine` / `BacktestNode` | `Core` backtest flow / `Runtime` replay | Backtest / Paper 共享策略和 event timeline，输出进入 report read model。 |
| `LiveNode` / `LiveExecutionEngine` | 无 v1 对应 | 只作为未来禁区和候选 delta 的参考，不进入当前实现。 |
| Persistence / event store | `Persistence` Event Log / SQLite / DuckDB | 保持 event log facts source 和 projection 可重建。 |

## MTPRO 应该学习什么

- 学习共同核心：Backtest / Paper / future Live 不应各自复制策略、风险、组合和事件语义。
- 学习消息不可变：事件一旦发出就不修改，派生状态放在组件上下文或 projection。
- 学习 cache-then-publish：核心读模型应在 handler / ViewModel 消费前完成投影，避免 UI 读取半成品状态。
- 学习 ports and adapters：adapter 只负责外部协议归一化，不把外部 API 泄漏进 Core / App。
- 学习 execution 因果链：strategy signal -> proposal / intent -> risk -> paper execution decision -> simulated fill evidence -> portfolio projection -> report。
- 学习环境分层：Backtest、Paper、Live 的差异应由 node / runtime boundary 和 adapter capability 表达，而不是在策略里散落 `if live`。
- 学习 reconciliation 思维：未来只要触碰真实外部状态，就必须有 explicit reconciliation contract；当前 v1 应把它列为禁区。
- 学习 one node / process 的警告：如果未来有多个 runtime session，应以明确 session boundary 和 event log path 隔离，而不是共享全局状态。

## MTPRO 不应该学习什么

- 不复制 NautilusTrader 源码、类结构、模块目录或 FFI / PyO3 / Cython 构建模式。
- 不引入 NautilusTrader 作为 SwiftPM、Python、Rust 或运行时依赖。
- 不引入 Redis / external MessageBus / cache database 作为 v1 persistence 必需项。
- 不引入完整 ExecutionClient、LiveExecutionEngine、order submit / cancel / modify 能力。
- 不引入 account state、margin、leverage、broker reconciliation、external order claims。
- 不把 paper-only workflow 设计成隐藏 live switch。
- 不为了“架构完整”提前引入多 venue、多 asset class、options greeks、complex OMS、execution algorithms。
- 不把 UI 接到 cache、runtime object、SQLite / DuckDB schema 或 adapter response。
- 不把 NautilusTrader 的安全 /高保证实现细节直接移植；MTPRO 当前要保留的是 paper-only 禁区和 deterministic local validation。

## 候选 Delta Proposal

以下只是候选修改建议，不在本任务中直接改 `architecture.md`、`environment.md` 或 `docs/roadmap.md`。

### architecture.md 候选 delta

建议补强三个表述：

1. 在“架构定位”下增加：MTPRO 学习 NautilusTrader 的 common kernel / ports-and-adapters / event-driven replay 思想，但实现上保持 Swift-only、本地 paper-only、append-only event log first。
2. 在“目标数据流”下把 paper-only execution 因果链写清楚：

```text
Strategy Signal
-> Paper Action Proposal
-> Risk Decision
-> Paper Execution Decision
-> Paper Order Intent
-> Simulated Fill Evidence
-> Portfolio Projection Update
-> Event Log / Replay
-> Report / Dashboard ReadModel
```

3. 在“不变量”中增加：Paper / Live 不共用 adapter capability；任何 LiveExecutionAdapter、ExecutionClient、signed endpoint、account state、broker reconciliation 都必须由未来 Human Project 明确授权。

### environment.md 候选 delta

建议在“外部系统边界”增加：

- NautilusTrader source / docs / API 只允许作为 reference study 输入，不是 MTPRO dependency。
- Reference study 可以读取 GitHub / official docs / Rust API / Python API；不得复制源码到 MTPRO，不得新增运行依赖。
- Live reconciliation、ExecutionClient、broker account、signed endpoint 相关内容只作为未来禁区说明，不进入本地验证路径。

### docs/roadmap.md 候选 delta

建议在“产品路线”或“非授权边界”增加：

- NautilusTrader Reference Study 的输出只作为 Human + `@001 / PLN` 下一阶段规划输入，不直接创建 Project / Issue。
- Future Live boundary 如果被 Human 重新开启，必须先形成独立 Project Planning Record、adapter capability contract、execution reconciliation contract 和 trading validation matrix 扩展；不能由 Paper Execution Workflow 自动延伸。
- Paper-only execution evidence 完成后，下一阶段优先应继续收紧 event log replay、projection consistency、Report / Dashboard observability，而不是进入 live broker action。

## 对 docs/contracts/* 的候选建议

### `docs/contracts/api-contract.md`

建议增加 `PaperExecutionDecision` 与 `SimulatedFillEvidence` 的 command / event 关系说明：allowed risk decision 只授权 paper-only decision，不授权真实 order command。

### `docs/contracts/backend-use-case-contract.md`

建议把 `ProjectPortfolio` 的输入明确为 paper-only fill / portfolio projection events，并说明 portfolio update 必须来自 event / replay，不来自 UI command。

### `docs/contracts/binance-market-data-contract.md`

建议保持当前 read-only public boundary，不新增 execution adapter。可补充 NautilusTrader adapter 分层参考：MTPRO 只采用 DataClient-like normalization，不采用 ExecutionClient-like capability。

### `docs/contracts/persistence-boundary.md`

建议增加“projection disposable”原则：SQLite / DuckDB projection 可从 append-only event log 重建，projection 失败不改变 facts source。

### `docs/contracts/read-model-projection.md`

建议补充 Report / Dashboard 的 causal chain 字段：source sequence、source stream、paper-only boundary flags、risk decision ID、simulated fill evidence ID、portfolio projection update ID。

### `docs/contracts/frontend-view-model-contract.md`

建议继续强化 ViewModel 只能消费 read model，不得读取 Cache / Runtime / Adapter / DB schema。可以增加 “NautilusTrader Cache 只作为架构参考，不代表 MTPRO UI 可以访问 cache”。

## 来源 URL

- NautilusTrader GitHub repository：`https://github.com/nautechsystems/nautilus_trader`
- NautilusTrader official docs：`https://nautilustrader.io/docs/latest/`
- Concepts index：`https://nautilustrader.io/docs/latest/concepts/`
- Architecture：`https://nautilustrader.io/docs/latest/concepts/architecture/`
- Events：`https://nautilustrader.io/docs/latest/concepts/events/`
- Message Bus：`https://nautilustrader.io/docs/latest/concepts/message_bus/`
- Cache：`https://nautilustrader.io/docs/latest/concepts/cache/`
- Execution：`https://nautilustrader.io/docs/latest/concepts/execution/`
- Portfolio：`https://nautilustrader.io/docs/latest/concepts/portfolio/`
- Backtesting：`https://nautilustrader.io/docs/latest/concepts/backtesting/`
- Live Trading：`https://nautilustrader.io/docs/latest/concepts/live/`
- Adapters：`https://nautilustrader.io/docs/latest/concepts/adapters/`
- Integrations：`https://nautilustrader.io/docs/latest/integrations/`
- Configure Live Trading Node：`https://nautilustrader.io/docs/latest/how_to/configure_live_trading/`
- Rust API：`https://nautechsystems.github.io/nautilus_docs/rust-api-latest/`
- Python API：`https://nautechsystems.github.io/nautilus_docs/python-api-latest/`
- Source reference `NautilusKernel`：`https://github.com/nautechsystems/nautilus_trader/blob/develop/crates/system/src/kernel.rs`
- Source reference `MessageBus`：`https://github.com/nautechsystems/nautilus_trader/blob/develop/crates/common/src/msgbus/mod.rs`
- Source reference `Cache`：`https://github.com/nautechsystems/nautilus_trader/blob/develop/crates/common/src/cache/mod.rs`
- Source reference `DataEngine`：`https://github.com/nautechsystems/nautilus_trader/blob/develop/crates/data/src/engine/mod.rs`
- Source reference `ExecutionEngine`：`https://github.com/nautechsystems/nautilus_trader/blob/develop/crates/execution/src/engine/mod.rs`
- Source reference `RiskEngine`：`https://github.com/nautechsystems/nautilus_trader/blob/develop/crates/risk/src/engine/mod.rs`
- Source reference `Portfolio`：`https://github.com/nautechsystems/nautilus_trader/blob/develop/crates/portfolio/src/portfolio.rs`
- Source reference `BacktestEngine`：`https://github.com/nautechsystems/nautilus_trader/blob/develop/crates/backtest/src/engine.rs`
- Source reference `LiveNode`：`https://github.com/nautechsystems/nautilus_trader/blob/develop/crates/live/src/node.rs`
