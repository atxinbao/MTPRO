# MTPRO Real Target Source Ownership / Core Envelope Retirement Contract

日期：2026-06-05

执行者：Codex

本文档服务 GitHub fallback issue `GH-391 Define real target ownership and dependency direction contract`。它只定义 real target source ownership、retained compatibility envelope、target dependency correction 和后续 migration / validation 顺序；不修改 `Package.swift`，不移动 `Sources`，不写业务代码，不实现 runtime / live / broker / L4 capability。

## GH-391-REAL-TARGET-OWNERSHIP-CONTRACT

当前 MTPRO 已完成 architecture-graph-aligned source roots 和 SwiftPM target names 的主体对齐，但这不等于所有真实实现已经由对应 module target 独立承载。当前状态必须拆成四类：

| 类型 | 含义 | 当前例子 |
| --- | --- | --- |
| Real module source root | 最终模块目录和后续实现归属目标。 | `Sources/Trader/`、`Sources/DataEngine/`、`Sources/ExecutionEngine/`。 |
| Target boundary anchor | SwiftPM target 当前可编译的边界声明 / validation anchor。 | `Sources/*/TargetGraph/*TargetBoundary.swift`。 |
| Retained compatibility envelope | 仍承载既有 implementation / import surface 的过渡 target。 | `Core`、`Adapters`、`Persistence`、`Runtime`。 |
| Future gate | 只表达未来能力边界，不实现当前能力。 | `ExecutionClient` broker / exchange outgoing adapter boundary。 |

GH-391 的目标是先固定这四类语言，避免把 target name 或 boundary anchor 误读成 implementation ownership 已完成。

## GH-391-CURRENT-BLOCKERS

当前阻塞 L4 readiness 的主要问题是：

- 多数 architecture target 已存在，但很多 target 只编译 module-local `TargetGraph/*TargetBoundary.swift`，真实 implementation 仍由 `Core`、`Adapters`、`Persistence` 或 `Runtime` compatibility envelope 承载。
- `Trader` target 当前仍直接依赖 `ExecutionEngine`。这可以解释为历史 coordination boundary evidence，但不应成为后续目标方向。更干净的目标是 Trader 只管理 account context、EMA strategy proposal 和 coordination evidence，下游 Risk / Execution context 通过 contract / MessageBus / read-model evidence 消费，不让 Trader 直接拥有 ExecutionEngine implementation。
- `TargetGraphTests` 当前主要证明 target boundary anchors、allowed dependency strings 和 active path retirement，不足以证明每个 target 能独立 import 并使用自己的核心类型。
- Dashboard active source 中仍存在 Workbench 历史命名 residue；后续应单独清理到 `Dashboard read-model-only boundary` 口径。
- 大文件仍集中在 `Sources/Core/LiveTradingBoundary.swift` 和 `Sources/Dashboard/ReadModels/App.swift` 等 compatibility / read-model surfaces，需要后续按子边界拆文件，但不能和 target ownership migration 混在同一个 issue。
- `try!` / `preconditionFailure` 仍大量出现在 deterministic fixture / evidence helper 中。后续需要验证规则，确保它们不会进入 runtime-facing path。

## GH-391-AUTHORITATIVE-TARGET-OWNERSHIP-MODEL

当前 authoritative target names 是：

```text
DomainModel
MessageBus
Database
DataClient
Cache
DataEngine
TraderStrategies
Trader
Portfolio
RiskEngine
ExecutionClient
ExecutionEngine
Dashboard
```

当前 authoritative source ownership target 是：

```text
Sources/DomainModel/
Sources/MessageBus/
Sources/Database/
Sources/DataClient/
Sources/Cache/
Sources/DataEngine/
Sources/Trader/Strategies/EMA/
Sources/Trader/
Sources/Portfolio/
Sources/RiskEngine/
Sources/ExecutionClient/
Sources/ExecutionEngine/
Sources/Dashboard/
```

当前 active strategy only `EMA`，canonical path only `Sources/Trader/Strategies/EMA/`。`Trader = Accounts + Strategies/EMA + Coordination`。`ExecutionClient` remains future gate / protocol boundary only; it is not a broker gateway, OMS implementation, signed endpoint client, account endpoint client, listenKey runtime, private WebSocket runtime, order submit / cancel / replace client, execution report parser, broker fill parser or reconciliation runtime.

## GH-391-DEPENDENCY-DIRECTION-CORRECTION

当前 `Package.swift` 仍包含 `Trader -> ExecutionEngine`。GH-391 不修改它，但把它登记为下游 correction blocker。

后续目标方向：

```text
Trader = Accounts + Strategies/EMA + Coordination
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine
RiskEngine -> Portfolio / Cache / MessageBus / DomainModel
ExecutionEngine -> RiskEngine / Portfolio / Cache / MessageBus / DomainModel / ExecutionClient future-gate vocabulary
ExecutionClient -> DomainModel / MessageBus future-gate vocabulary only
```

大白话：Trader 负责组织账户、策略和协调上下文；策略只产出 proposal / signal；RiskEngine 做风险门；ExecutionEngine 处理 paper / simulated execution lifecycle；ExecutionClient 未来才可能负责把订单发到外部 broker / exchange。Trader 不应该直接拥有 ExecutionEngine implementation。

## GH-391-REAL-TARGET-SMOKE-TEST-CONTRACT

后续 real target smoke tests 不能只检查 `Package.swift` 字符串或 boundary struct。它们必须证明对应 target 能独立 import 并使用该 target 自己拥有的核心类型。

后续 smoke-test expectation：

- Foundation：只 import `DomainModel` / `MessageBus` / `Database`，能使用领域值对象、event / command envelope 和 event-log / projection contract。
- Data：只 import `DataClient` / `DataEngine` / `Cache`，能使用 public read-only venue data boundary、ingest / replay / quality contract 和 cache read-model contract。
- Trader / Portfolio / Risk：只 import `TraderStrategies` / `Trader` / `Portfolio` / `RiskEngine`，能使用 EMA strategy signal / proposal、account context、coordination evidence、portfolio projection 和 risk gate contract。
- Execution：只 import `ExecutionEngine` / `ExecutionClient`，能使用 paper / simulated lifecycle boundary 和 ExecutionClient future-gate vocabulary；不能 create broker gateway, OMS, signed endpoint or live order command.
- Dashboard：只 import / build `Dashboard` read-model-only surface，不能读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload or broker state.

## GH-391-MIGRATION-SEQUENCE

后续 issue 顺序固定为：

1. `GH-392` Remove direct Trader to ExecutionEngine target dependency.
2. `GH-393` Add real target smoke tests for foundation targets.
3. `GH-394` Migrate DomainModel and MessageBus implementation ownership out of Core.
4. `GH-395` Add real target smoke tests for data targets.
5. `GH-396` Migrate DataClient / DataEngine / Cache implementation ownership out of Core / Adapters / Runtime.
6. `GH-397` Add real target smoke tests for Trader / Portfolio / Risk / Execution boundaries.
7. `GH-398` Migrate Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient implementation ownership.
8. `GH-399` Clean Dashboard Workbench naming residue.
9. `GH-400` Add try! and preconditionFailure allowed-path validation.
10. `GH-401` Close Core envelope retirement matrix / stage audit input.

每个 migration issue 都必须保持 WIP=1，并且只能在前置 PR merged、required check `checks` success、main fast-forward 后执行。

## GH-391-CORE-ENVELOPE-RETIREMENT-RULE

`Core`、`Adapters`、`Persistence` 和 `Runtime` 当前仍是 retained compatibility envelopes。后续 retirement 只能按目标模块逐段进行：

- 先加 real target smoke tests，证明目标 target 可独立使用核心类型。
- 再迁移 implementation ownership。
- 再更新 compatibility envelope exclude / dependency。
- 最后清理 stale docs / validation anchors。

不能为了“看起来完成架构拆分”而直接删除 `Core` 或一次性移动大批实现。任何 source move 都必须由对应 issue 明确授权。

## GH-391-FORBIDDEN-CAPABILITY-GUARD

GH-391 和后续 Core envelope retirement planning 不授权：

- Trader runtime、Strategy runtime、Live runtime。
- ExecutionClient implementation、OMS、broker gateway。
- signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- real account read、real order lifecycle、submit / cancel / replace。
- execution report、broker fill、reconciliation。
- Live PRO Console、trading button、live command、order form。
- L4 implementation。
- Symphony / symphony-issue、Graphify / code-index、Figma。
- `.codex/*`、`.build/*`、`graphify-out/*` 提交。

## GH-391-VALIDATION-ANCHORS

GH-391 required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-391 readiness anchors：

- `GH-391-REAL-TARGET-OWNERSHIP-CONTRACT`
- `GH-391-CURRENT-BLOCKERS`
- `GH-391-AUTHORITATIVE-TARGET-OWNERSHIP-MODEL`
- `GH-391-DEPENDENCY-DIRECTION-CORRECTION`
- `GH-391-REAL-TARGET-SMOKE-TEST-CONTRACT`
- `GH-391-MIGRATION-SEQUENCE`
- `GH-391-CORE-ENVELOPE-RETIREMENT-RULE`
- `GH-391-FORBIDDEN-CAPABILITY-GUARD`
- `GH-391-VALIDATION-ANCHORS`
