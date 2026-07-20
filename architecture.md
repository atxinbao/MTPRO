# MTPRO Architecture

Date: 2026-07-20

Executor: Codex

Status: Canonical

## 架构范围

MTPRO 是 SwiftPM-first、Swift-only、local-first 的 Binance 原生交易系统。当前 active venue 为 Binance，active products 为 Spot 和 USD-M Futures。

## 当前模块

```text
DomainModel
├── MessageBus
├── DataClient/Binance
├── Cache
├── Database
├── DataEngine
├── Trader
│   ├── Accounts
│   ├── Strategies
│   └── Coordination
├── Portfolio
├── RiskEngine
├── ExecutionEngine
├── ExecutionClient
├── MTPROCLI
└── Dashboard
```

| 模块 | 当前职责 | 禁止越界 |
| --- | --- | --- |
| `DomainModel` | venue、product、market、order、account、portfolio 和 execution 领域类型 | 不依赖 UI、存储或网络 |
| `MessageBus` | event、command、query、correlation、replay | 不承载 adapter payload 或 UI state |
| `DataClient/Binance` | Binance public、signed account、private stream 输入边界 | 不执行订单 |
| `DataEngine` | ingest、quality、replay、scenario、运行数据步骤 | 不绕过 MessageBus |
| `Cache` | 可重建内存状态和 read model | 不作为 durable truth |
| `Database` | append-only 事实、运行 journal 和投影 | 不暴露数据库 schema 给 UI |
| `Trader` | Accounts、Strategies、Coordination | 策略不直连 ExecutionClient |
| `Portfolio` | position、cash、PnL、margin 等投影 | 不直接读取 broker payload |
| `RiskEngine` | pre-trade gate、额度、kill switch、no-trade | 不直接提交订单 |
| `ExecutionEngine` | order lifecycle、OMS、reconciliation、rollback 协调 | 不绕过 RiskEngine |
| `ExecutionClient` | Binance Demo / guarded external transport 和证据校验 | 不自动启用 production |
| `MTPROCLI` | operator 命令与状态 | 不保存 secret，不绕过授权 |
| `Dashboard` | 只读消费已验证状态 | 不生成 production authorization |

## 依赖方向

```text
DataClient -> DataEngine -> MessageBus
MessageBus -> Trader -> Portfolio -> RiskEngine
RiskEngine -> ExecutionEngine -> ExecutionClient
Execution events -> MessageBus -> Database / Cache / Portfolio
Validated projections -> CLI / Dashboard
```

关键规则：

- 外部数据先标准化为 DomainModel，再进入内部事件链。
- 策略只生成 signal / intent，不调用交易所。
- RiskEngine 是执行前强制门。
- ExecutionEngine 拥有内部生命周期和 OMS 协调。
- ExecutionClient 只负责外部协议、传输和证据。
- Portfolio 从事件、成交和对账证据构建，不从 UI 或策略猜测状态。
- CLI / Dashboard 只消费统一状态，不创建旁路。

## 运行模式一致性

Research、Backtest、Paper、Demo 和未来 Production 共享：

- DomainModel
- MessageBus 事件语义
- Trader / strategy intent
- RiskEngine 决策合同
- ExecutionEngine / OMS 生命周期
- Portfolio projection

不同环境只替换：

- clock / scheduler
- data source
- execution adapter
- credential / endpoint profile
- authorization gate

因此回测和实盘目标是同一业务代码路径，而不是复制两套策略、风险或 OMS 实现。

## 当前源码地形

```text
Sources/
  DomainModel/
  MessageBus/
  DataClient/Binance/
  DataEngine/
  Cache/
  Database/
  Trader/
  Portfolio/
  RiskEngine/
  ExecutionEngine/
  ExecutionClient/
  MTPROCLI/
  Dashboard/
```

`TargetGraph` 子目录是各 SwiftPM target 的边界锚点，不是独立业务模块。`Core`、`Adapters`、`Persistence` 和 `Runtime` 是 retained compatibility envelopes；新实现必须优先进入真实 owner，维护工作逐步收窄这些 envelope。

`Workbench`、`AppCompatibility`、顶层 `Sources/TargetGraph`、旧 `Sources/Strategies` 和旧 `StrategyBindings` 不属于 active architecture。

## SwiftPM 方向

权威依赖以 `Package.swift` 为准。架构要求：

- foundation target 不反向依赖业务模块。
- Trader 不直接依赖 ExecutionEngine / ExecutionClient。
- RiskEngine 不依赖 broker transport。
- ExecutionClient 不拥有策略、Portfolio 或 UI。
- Dashboard 不依赖 adapter request、runtime object 或数据库 schema。
- compatibility envelope 不得重新成为 active implementation owner。

## 当前运行边界

```text
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

Demo Network 双产品验证已完成。Production 必须通过独立 cutover gate；普通文档、维护 PR、CLI 参数或 Dashboard 操作均不能隐式授权。
