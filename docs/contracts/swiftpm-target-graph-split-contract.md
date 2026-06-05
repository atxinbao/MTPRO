# MTPRO SwiftPM Target Graph Split Contract

日期：2026-06-04

执行者：Codex

本文档最初是 `MTPRO SwiftPM Target Graph Module Split v1` 的 MTP-216 合同；MTP-217 至 MTP-222 继续在同一合同文件中记录已发生的 target split evidence、current target graph snapshot、retained compatibility boundary 和 stale anchor retirement。MTP-216 section 保留为 before-state / contract-first evidence，不再代表 MTP-222 当前 active target graph。

## MTP-216-SWIFTPM-TARGET-GRAPH-SPLIT-CONTRACT

SwiftPM target graph split contract 指把 historical compatibility envelope 拆成 architecture-graph-aligned module targets 时必须遵守的目标图和依赖方向。MTP-216 时仓库仍以 `Core`、`Adapters`、`Persistence`、`Runtime`、`App`、`Dashboard` 和 `CSQLite` 作为 SwiftPM build envelope；该 snapshot 只作为 before-state evidence 保留。MTP-222 当前 active graph 以 MTP-217 至 MTP-221 已建立的 buildable targets 为准。

MTP-216 的职责是 contract-first：先固定 target graph baseline、禁止路径、下游 issue 边界和验证锚点，再由 MTP-217 至 MTP-223 按 WIP=1 逐步执行。任何实际 source movement、`Package.swift` target / product / dependency 修改、compatibility envelope 退休，都必须等对应下游 issue live-read 授权。

## MTP-216-CURRENT-COMPATIBILITY-ENVELOPE-SNAPSHOT

当前 SwiftPM target graph baseline 是：

```text
Core
Adapters -> Core
Persistence -> Core, CSQLite, DuckDB(macOS)
Runtime -> Core, Adapters, Persistence
App -> Core, Persistence
Dashboard -> App
CSQLite
```

当前 `Core` 仍作为 compatibility envelope 编译 `Sources/DomainModel/`、`Sources/MessageBus/`、`Sources/Cache/MarketData/`、`Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/`、`Sources/Trader/Coordination/RiskBinding/`、`Sources/Portfolio/`、`Sources/RiskEngine/`、`Sources/ExecutionEngine/`、`Sources/ExecutionClient/` 和 retained Core research / compatibility evidence。`Adapters`、`Persistence`、`Runtime`、`App` 和 `Dashboard` 也仍以旧 target 名称承载对应 source roots。

该 snapshot 不是后续目标结构，只是 MTP-216 的 before-state evidence。后续 issue 不能把 snapshot 当成新增 runtime、broker gateway、OMS、ExecutionClient implementation、Live PRO Console 或 target split 已完成的证据。

## MTP-216-CANONICAL-TARGET-GRAPH-BASELINE

后续目标 SwiftPM module targets 必须按下表拆分。表内 dependency 表达允许方向；未列出的逆向依赖默认禁止。

| Target | 允许依赖 | 目标职责 |
| --- | --- | --- |
| `DomainModel` | 无业务 target 依赖 | 领域对象、shared value types、paper / simulated / future-gated shared vocabulary。 |
| `MessageBus` | `DomainModel` | facts、events、commands、request / response、routing envelope、replay invariant。 |
| `Database` | `DomainModel`, `MessageBus`, `CSQLite`, DuckDB(macOS implementation dependency) | append-only event log、snapshot、SQLite / DuckDB projection、replay projection backing store。 |
| `DataClient` | `DomainModel` | venue-scoped public read-only market data adapter boundary；当前只有 Binance public market data path。 |
| `Cache` | `DomainModel`, `MessageBus` | in-memory / runtime-derived market data、instrument、order、position、portfolio read state cache。 |
| `DataEngine` | `DomainModel`, `DataClient`, `MessageBus`, `Cache` | ingestion、subscription / request / response contract、scenario replay、data quality。 |
| `Portfolio` | `DomainModel`, `MessageBus`, `Cache`, `Database` | paper / simulated portfolio financial state projection、positions、net positions、cash / equity、margin、open value。 |
| `RiskEngine` | `DomainModel`, `MessageBus`, `Cache`, `Portfolio` | paper pre-trade risk、risk blockers、future live risk gates 和 blocked evidence。 |
| `ExecutionClient` | `DomainModel` | future-gated external broker / exchange client capability contract only。 |
| `ExecutionEngine` | `DomainModel`, `MessageBus`, `Cache`, `Portfolio`, `RiskEngine`, `ExecutionClient` | paper lifecycle、simulated lifecycle、matching / fill / fee / slippage、future OMS boundary；`ExecutionClient` 只能作为 future gate / protocol vocabulary，不是 current call path。 |
| `TraderStrategies` | `DomainModel`, `MessageBus`, `Cache`, `Portfolio`, `RiskEngine` | Trader-owned concrete strategies；当前 active concrete strategy only `EMA`，canonical source path only `Sources/Trader/Strategies/EMA/`。 |
| `Trader` | `DomainModel`, `MessageBus`, `Cache`, `TraderStrategies`, `Portfolio`, `RiskEngine` | `Trader = Accounts + Strategies/EMA + Coordination`；只做 identity / account context / strategy proposal / risk coordination boundary。GH-392 后不再直接依赖 `ExecutionEngine`。 |
| `Workbench` | `DomainModel`, `MessageBus`, `DataEngine`, `Portfolio`, `RiskEngine`, `ExecutionEngine`, `Trader`, `Database` read-model exports only | Report / Dashboard / Events read-model-only evidence surface and ViewModel assembly。 |
| `Dashboard` | `Workbench` | macOS shell / smoke executable，只装载 Workbench ViewModel snapshot。 |

## MTP-216-DEPENDENCY-DIRECTION-CONTRACT

依赖方向必须保持：

```text
DomainModel
MessageBus -> DomainModel
Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)
DataClient -> DomainModel
Cache -> DomainModel / MessageBus
DataEngine -> DomainModel / DataClient / MessageBus / Cache
Portfolio -> DomainModel / MessageBus / Cache / Database
RiskEngine -> DomainModel / MessageBus / Cache / Portfolio
ExecutionClient -> DomainModel
ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient(future gate types only)
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine
Workbench -> ReadModel / ViewModel exports only
Dashboard -> Core / Persistence
```

该方向保留 NautilusTrader 风格的 engine layering，但不复制 NautilusTrader runtime，也不把 MTPRO 当前 evidence 升级为 production trading engine。`TraderStrategies` 只能提出 strategy signal / paper-neutral proposal evidence；`Trader` 负责 account / strategy / coordination，不能绕过 `RiskEngine`，也不能直接依赖 `ExecutionEngine` 或 `ExecutionClient`。`ExecutionClient` 在 MTP-216 仍只是 future gate contract，不是 current executable dependency。

## MTP-216-FORBIDDEN-IMPORT-PATHS

后续 target split 必须阻断以下 import / dependency path：

- `DataClient -> signed endpoint / account endpoint / listenKey / private stream runtime` 禁止。
- `DataClient -> ExecutionEngine / ExecutionClient / Trader / Workbench / Dashboard` 禁止。
- `DataEngine -> ExecutionClient / broker / OMS / Workbench / Dashboard` 禁止。
- `Database -> Workbench / Dashboard / Trader / RiskEngine / ExecutionEngine / ExecutionClient / broker payload` 禁止。
- `Cache -> Database schema / Workbench / Dashboard / broker payload` 禁止。
- `TraderStrategies -> ExecutionClient / OMS / broker command / Workbench / Dashboard` 禁止。
- `Trader -> ExecutionClient` 当前禁止；未来即使允许也只能经 L4 独立 Project、RiskEngine 和 ExecutionEngine gate 重新授权。
- `Portfolio -> broker account state / account endpoint payload / signed endpoint / listenKey` 禁止。
- `RiskEngine -> broker / ExecutionClient / signed endpoint / account endpoint / listenKey` 禁止。
- `ExecutionEngine -> current OMS / broker adapter / signed endpoint / account endpoint / listenKey` 禁止。
- `ExecutionClient -> signed request / order submit / cancel / replace / execution report / broker fill / reconciliation runtime` 当前禁止。
- `Workbench -> Runtime object / Adapter request / Database schema / broker payload / account payload` 禁止。
- `Dashboard -> anything except Workbench` 禁止。

## MTP-216-TRADER-OWNED-STRATEGIES-TARGET-BOUNDARY

Strategies 在后续 target graph 中归 Trader ownership，而不是 peer-level `Sources/Strategies/`。目标结构是：

```text
Sources/Trader/
  Accounts/
  Strategies/
    EMA/
  Coordination/
    RiskBinding/
```

当前 active concrete strategy only `EMA`。后续多个策略应继续按 `Sources/Trader/Strategies/<strategy>/` 管理，每个 concrete strategy 只依赖 DomainModel / MessageBus / Cache / Portfolio / RiskEngine 层的 evidence/context，不能直接依赖 ExecutionClient、broker、OMS、Workbench、Dashboard 或 UI command surface。

`Sources/Trader/Coordination/RiskBinding/` 是 Trader coordination adapter / binding boundary，不是 concrete strategy implementation landing path。旧 `Sources/Trader/StrategyBindings/` 和 peer-level `Sources/Strategies/` 只保留为 historical / compatibility / superseded context，不得回流为 active source root、Package source root、test root 或 target name。

## MTP-216-MODULE-TO-TARGET-SPLIT-SEQUENCE

MTP-216 之后的 canonical issue sequence 是：

| Issue | 允许打开的边界 | 必须保持的禁止项 |
| --- | --- | --- |
| `MTP-217` | Split `DomainModel` / `MessageBus` / `Database` foundation targets。 | 不引入 Trader / Strategy / Live runtime，不接 broker / signed / account endpoint。 |
| `MTP-218` | Split `DataClient` / `DataEngine` / `Cache` targets。 | DataClient 仍 public read-only；不接 listenKey、private stream、signed/account path。 |
| `MTP-219` | Split `TraderStrategies` / `Trader` / `Portfolio` / `RiskEngine` targets with EMA-only active boundary。 | Strategies / Trader 不能直连 ExecutionClient、broker、OMS 或 UI command。 |
| `MTP-220` | Split `ExecutionEngine` / `ExecutionClient` future gate targets。 | `ExecutionClient` 仍 future gate；不实现真实 broker / exchange client、OMS、real order lifecycle。 |
| `MTP-221` | Split `Workbench` / `Dashboard` read-model-only consumption targets。 | Workbench / Dashboard 不能读取 runtime object、adapter request、schema、broker payload 或 account payload。 |
| `MTP-222` | Retire obsolete compatibility envelopes and stale target anchors。 | 只退休已经被 split 取代的 envelope；不新增未来方向或 L4 capability。 |
| `MTP-223` | Close validation matrix / automation readiness / stage audit input。 | 不输出最终 Stage Code Audit Report，不设置 Project Completed，不创建下一 Project / Issue。 |

## MTP-216-PACKAGE-SPLIT-NON-AUTHORIZATION

MTP-216 明确不授权以下动作：

- 修改 `Package.swift` target graph、products、dependencies、source roots 或 exclude list。
- 新增、删除、重命名 SwiftPM target / product / dependency。
- 移动 production source 或 tests。
- 退休 compatibility envelope。
- 把 `Core`、`Adapters`、`Persistence`、`Runtime`、`App`、`Dashboard` 当作已完成 final target graph split。

## MTP-216-NO-RUNTIME-LIVE-BROKER-L4

MTP-216 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。

MTP-216 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-216-VALIDATION-ANCHORS

MTP-216 required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-216 必须在 root docs / validation docs / automation readiness 中建立：

- `MTP-216-SWIFTPM-TARGET-GRAPH-SPLIT-CONTRACT`
- `MTP-216-CURRENT-COMPATIBILITY-ENVELOPE-SNAPSHOT`
- `MTP-216-CANONICAL-TARGET-GRAPH-BASELINE`
- `MTP-216-DEPENDENCY-DIRECTION-CONTRACT`
- `MTP-216-FORBIDDEN-IMPORT-PATHS`
- `MTP-216-TRADER-OWNED-STRATEGIES-TARGET-BOUNDARY`
- `MTP-216-MODULE-TO-TARGET-SPLIT-SEQUENCE`
- `MTP-216-PACKAGE-SPLIT-NON-AUTHORIZATION`
- `MTP-216-NO-RUNTIME-LIVE-BROKER-L4`
- `MTP-216-TARGET-GRAPH-CONTRACT-VALIDATION`

## MTP-217 Foundation Target Split Evidence

日期：2026-06-04

执行者：Codex

`MTP-217-FOUNDATION-TARGET-SPLIT-EVIDENCE`

MTP-217 在 `Package.swift` 中新增 buildable SwiftPM library products / targets：`DomainModel`、`MessageBus` 和 `Database`。该变更是 target graph 的第一段 foundation split，只建立可编译的 target 边界和 dependency direction evidence，不退休现有 `Core` / `Persistence` compatibility envelope，不改变既有 `import Core` / `import Persistence` 调用面。

`MTP-217-DOMAINMODEL-TARGET-SPLIT`

`DomainModel` target 当前编译 `Sources/TargetGraph/DomainModel/DomainModelTargetBoundary.swift`。该 target 不依赖任何业务 target，`DomainModelTargetBoundary` 记录 canonical source root `Sources/DomainModel/`、compiled boundary root `Sources/TargetGraph/DomainModel/`、retained compatibility envelope `Core` 和 no runtime / live / broker capability guard。

`MTP-217-MESSAGEBUS-TARGET-SPLIT`

`MessageBus` target 当前编译 `Sources/TargetGraph/MessageBus/MessageBusTargetBoundary.swift`，并只依赖 `DomainModel`。现有 `Sources/MessageBus/` 仍由 `Core` compatibility envelope 编译，因为其中还包含 paper runtime routing、strategy / portfolio / risk / execution evidence types 和旧 `CoreError` coupling；MTP-217 不做越界拆解。

`MTP-217-DATABASE-TARGET-SPLIT`

`Database` target 当前编译 `Sources/TargetGraph/Database/DatabaseTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`CSQLite` 和 macOS 条件 `DuckDB` implementation dependency。现有 SQLite / DuckDB projection implementation 仍由 `Persistence` compatibility envelope 编译，因为旧 projection 文件还消费高层 paper / portfolio / strategy evidence types；MTP-217 不暴露 schema 给 Workbench，不持久化 broker / account payload。

`MTP-217-FOUNDATION-DEPENDENCY-DIRECTION`

MTP-217 的 foundation dependency direction 固定为：

```text
DomainModel
MessageBus -> DomainModel
Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)
```

`DomainModel`、`MessageBus` 和 `Database` 均不得依赖 `DataEngine`、`Trader`、`TraderStrategies`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient`、`Workbench`、`Dashboard`、broker、OMS、account endpoint 或 private stream runtime。

`MTP-217-FOUNDATION-COMPATIBILITY-ENVELOPE-RETAINED`

MTP-217 保留 `Core` 继续编译既有 `Sources/DomainModel/` 和 `Sources/MessageBus/` public types，并保留 `Persistence` 继续编译既有 `Sources/Database/Projections/` implementation。`Package.swift` 对 `Core`、`Runtime` 和 `App` compatibility target 增加 `TargetGraph` exclude，避免新 target boundary anchor 被旧 envelope 误读。

`MTP-217-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 `import DomainModel`、`import MessageBus` 和 `import Database`，验证三个 foundation targets 可编译、依赖方向正确、兼容 envelope 保留，并阻断 higher-layer runtime / broker / UI drift。

`MTP-217-NO-RUNTIME-LIVE-BROKER-L4-GUARD`

MTP-217 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability；不启动 Symphony / symphony-issue，不运行 Graphify 或 code-index，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

`MTP-217-FOUNDATION-TARGET-SPLIT-VALIDATION`

MTP-217 required validation：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTP-218 Data Target Split Evidence

日期：2026-06-04

执行者：Codex

`MTP-218-DATA-TARGET-SPLIT-EVIDENCE`

MTP-218 在 `Package.swift` 中新增 buildable SwiftPM library products / targets：`DataClient`、`DataEngine` 和 `Cache`。该变更是 target graph 的第二段 data-layer split，只建立可编译的 target boundary、dependency direction evidence 和 forbidden capability guard；它不退休 `Core`、`Adapters` 或 `Runtime` compatibility envelope，不迁移既有 production implementation，不改变当前 public data、replay、quality 或 cache behavior。

`MTP-218-DATACLIENT-TARGET-SPLIT`

`DataClient` target 当前编译 `Sources/TargetGraph/DataClient/DataClientTargetBoundary.swift`，并只依赖 `DomainModel`。现有 `Sources/DataClient/Binance/PublicMarketData/` implementation 仍由 `Adapters` compatibility envelope 编译，因为当前 Binance public market data path 仍通过旧 product 暴露。`DataClient` 只能表达 venue-scoped public read-only data input boundary。

`MTP-218-CACHE-TARGET-SPLIT`

`Cache` target 当前编译 `Sources/TargetGraph/Cache/CacheTargetBoundary.swift`，依赖 `DomainModel` 和 `MessageBus`。现有 `Sources/Cache/` implementation 仍由 `Core` compatibility envelope 编译。`Cache` 只能表达可从 facts / replay 重建的 read-model state surface，不能成为 durable store、Database schema owner、broker state cache 或 UI contract。

`MTP-218-DATAENGINE-TARGET-SPLIT`

`DataEngine` target 当前编译 `Sources/TargetGraph/DataEngine/DataEngineTargetBoundary.swift`，依赖 `DomainModel`、`DataClient`、`MessageBus` 和 `Cache`。现有 `Sources/DataEngine/Ingest/`、`Sources/DataEngine/ScenarioReplay/` 和 `Sources/DataEngine/DataQuality/` implementation 仍由 `Core` / `Runtime` compatibility envelope 编译。`DataEngine` 只能表达 ingest / replay / quality boundary，不新增 streaming runtime、private stream、account endpoint、broker route 或 UI route。

`MTP-218-DATACLIENT-DATAENGINE-CACHE-DEPENDENCY-DIRECTION`

MTP-218 的 data-layer dependency direction 固定为：

```text
DataClient -> DomainModel
Cache -> DomainModel / MessageBus
DataEngine -> DomainModel / DataClient / MessageBus / Cache
```

`DataClient` 不得依赖 `DataEngine`、`Trader`、`TraderStrategies`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient`、`Workbench`、`Dashboard`、broker、OMS、signed endpoint、account endpoint、listenKey 或 private stream runtime。`DataEngine` 不得依赖 `Trader`、`ExecutionEngine`、`ExecutionClient`、`Workbench`、`Dashboard`、broker、OMS、signed endpoint、account endpoint、listenKey 或 private stream runtime。`Cache` 不得拥有 Database schema、durable facts、broker state、account payload 或 UI surface。

`MTP-218-PUBLIC-READ-ONLY-DATA-BOUNDARY`

MTP-218 保持 `DataClient` 为 public read-only data boundary。它不调用 signed endpoint，不调用 account endpoint，不创建 listenKey，不连接 broker 或 execution adapter，不读取真实账户 / 持仓 / 余额，也不实现 private WebSocket runtime。

`MTP-218-READMODEL-STATE-SURFACE`

MTP-218 保持 `Cache` 为 read-model state surface。它可以表达 instruments、market data、orders、positions 和 portfolio summary 的 runtime-derived state boundary，但不拥有 durable facts，不暴露 SQLite / DuckDB schema，不保存 broker payload、account payload 或 broker state。

`MTP-218-DATA-COMPATIBILITY-ENVELOPE-RETAINED`

MTP-218 保留 `Adapters` 继续编译既有 Binance public market data implementation，保留 `Core` 继续编译既有 cache / scenario replay / data quality public evidence，保留 `Runtime` 继续编译既有 ingest implementation。`Package.swift` 对 `Core`、`Runtime` 和 `App` compatibility targets 继续排除 `TargetGraph`，避免 boundary anchors 被旧 envelope 重复收编。Compatibility envelope retirement 仍归 MTP-222。

`MTP-218-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 `import DataClient`、`import DataEngine` 和 `import Cache`，验证三个 data-layer targets 可编译、依赖方向正确、compatibility envelope 保留，并阻断 signed / account / listenKey / broker / runtime drift。

`MTP-218-NO-SIGNED-ACCOUNT-BROKER-GUARD`

MTP-218 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability；不启动 Symphony / symphony-issue，不运行 Graphify 或 code-index，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

`MTP-218-DATA-TARGET-SPLIT-VALIDATION`

MTP-218 required validation：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTP-219 Trader / Portfolio / Risk Target Split Evidence

日期：2026-06-04

执行者：Codex

`MTP-219-TRADER-PORTFOLIO-RISK-TARGET-SPLIT-EVIDENCE`

MTP-219 在 `Package.swift` 中新增 buildable SwiftPM library products / targets：`TraderStrategies`、`Trader`、`Portfolio` 和 `RiskEngine`。该变更是 target graph 的第三段 coordination / financial state / pre-execution risk split，只建立可编译的 target boundary、dependency direction evidence、EMA-only active strategy evidence 和 forbidden direct execution guard；它不退休 `Core` compatibility envelope，不迁移既有 production implementation，不改变当前 paper strategy、portfolio projection 或 pre-trade risk behavior。

`MTP-219-TRADERSTRATEGIES-TARGET-SPLIT`

`TraderStrategies` target 当前编译 `Sources/TargetGraph/TraderStrategies/TraderStrategiesTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio` 和 `RiskEngine`。现有 `Sources/Trader/Strategies/EMA/` implementation 仍由 `Core` compatibility envelope 编译。`TraderStrategies` 只能表达 Trader-owned concrete strategy definitions 和 paper-neutral strategy evidence。

`MTP-219-TRADER-TARGET-SPLIT`

`Trader` target 当前编译 `Sources/TargetGraph/Trader/TraderTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache`、`TraderStrategies`、`Portfolio` 和 `RiskEngine`。`ExecutionEngine` target 归 MTP-220 拆分，因此 MTP-219 只记录 `ExecutionEngine(MTP-220)` deferred dependency，不在本 issue 中越界依赖 execution layer。现有 `Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Coordination/RiskBinding/` implementation 仍由 `Core` compatibility envelope 编译。

`MTP-219-PORTFOLIO-TARGET-SPLIT`

`Portfolio` target 当前编译 `Sources/TargetGraph/Portfolio/PortfolioTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache` 和 `Database`。现有 `Sources/Portfolio/` implementation 仍由 `Core` compatibility envelope 编译。`Portfolio` 只表达 positions、net positions、margin、open value 和 paper projection financial state boundary，不拥有 Trader account identity，不读取真实 broker account state。

`MTP-219-RISKENGINE-TARGET-SPLIT`

`RiskEngine` target 当前编译 `Sources/TargetGraph/RiskEngine/RiskEngineTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache` 和 `Portfolio`。现有 `Sources/RiskEngine/PreTrade/` 和 `Sources/RiskEngine/LiveGate/` evidence 仍由 `Core` compatibility envelope 编译。`RiskEngine` 只表达 pre-execution risk boundary，不实现 live risk runtime、broker route、ExecutionClient wrapper 或 executable order command router。

`MTP-219-TRADER-PORTFOLIO-RISK-DEPENDENCY-DIRECTION`

MTP-219 的 dependency direction 固定为：

```text
Portfolio -> DomainModel / MessageBus / Cache / Database
RiskEngine -> DomainModel / MessageBus / Cache / Portfolio
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine
Trader -> ExecutionEngine deferred to MTP-220
```

`TraderStrategies` 和 `Trader` 不得依赖 `ExecutionClient`、broker、OMS、signed endpoint、account endpoint、listenKey、private stream runtime、Workbench、Dashboard 或 UI command surface。`Portfolio` 不得读取 broker account state、account endpoint payload、signed endpoint、listenKey 或 private stream runtime。`RiskEngine` 不得调用 broker、ExecutionClient、signed/account endpoint、listenKey、live risk runtime 或 executable order command。

`MTP-219-EMA-ONLY-ACTIVE-STRATEGY-BOUNDARY`

MTP-219 保持 current active concrete strategy only `EMA`，canonical active source root only `Sources/Trader/Strategies/EMA/`。`RSI`、`OrderBookImbalance`、`Momentum`、`MeanReversion` 或其他 strategy 不能作为 active source root、Package source root、test root 或 target source root 回流。

`MTP-219-TRADER-CONTAINER-ACCOUNTS-EMA-COORDINATION`

MTP-219 保持 Trader container 为 `Accounts + Strategies/EMA + Coordination`：account context root 是 `Sources/Trader/Accounts/`，active strategy root 是 `Sources/Trader/Strategies/EMA/`，coordination root 是 `Sources/Trader/Coordination/RiskBinding/`。旧 `Sources/Trader/StrategyBindings/` 和 peer-level `Sources/Strategies/` 不得回流为 active source directory。

`MTP-219-PORTFOLIO-SEPARATE-FROM-TRADER-ACCOUNT`

MTP-219 保持 Portfolio 独立于 Trader account context。Trader account context 只表达 account identity、source identity 和 future real account gate；Portfolio 才表达 positions、net positions、cash / equity、PnL、margin、open value 和 paper projection financial state。

`MTP-219-PRE-EXECUTION-RISK-BOUNDARY`

MTP-219 保持 RiskEngine 为 pre-execution boundary。RiskEngine 可以消费 Portfolio read model / Cache / MessageBus evidence，输出 paper risk blocker / allowed / blocked evidence，但不能升级为 live risk runtime、broker gateway、ExecutionClient wrapper、OMS command path 或 executable order command source。

`MTP-219-TRADER-PORTFOLIO-RISK-COMPATIBILITY-ENVELOPE-RETAINED`

MTP-219 保留 `Core` 继续编译既有 Trader、EMA strategy、RiskBinding、Portfolio 和 RiskEngine implementation。`Package.swift` 对 `Core`、`Runtime` 和 `App` compatibility targets 继续排除 `TargetGraph`，避免 boundary anchors 被旧 envelope 重复收编。Compatibility envelope retirement 仍归 MTP-222。

`MTP-219-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 `import TraderStrategies`、`import Trader`、`import Portfolio` 和 `import RiskEngine`，验证四个 targets 可编译、依赖方向正确、Trader container 完整、EMA-only active strategy 保留，并阻断 Trader / Strategy / Portfolio / RiskEngine runtime、broker、account endpoint、ExecutionClient、OMS 和 UI command drift。

`MTP-219-NO-DIRECT-EXECUTION-GUARD`

MTP-219 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、broker payload read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability；不启动 Symphony / symphony-issue，不运行 Graphify 或 code-index，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

`MTP-219-TRADER-PORTFOLIO-RISK-TARGET-SPLIT-VALIDATION`

MTP-219 required validation：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTP-220 Execution Target Split Evidence

日期：2026-06-04

执行者：Codex

`MTP-220-EXECUTION-TARGET-SPLIT-EVIDENCE`

MTP-220 在 `Package.swift` 中新增 buildable SwiftPM library products / targets：`ExecutionClient` 和 `ExecutionEngine`。该变更是 target graph 的第四段 execution split，只建立可编译的 target boundary、RiskEngine -> ExecutionEngine -> ExecutionClient future gate dependency direction、Trader -> ExecutionEngine dependency resolution 和 forbidden broker / OMS / real order guard；它不退休 `Core` compatibility envelope，不迁移既有 paper lifecycle、simulated exchange、OMS future gate 或 ExecutionClient future gate implementation。

`MTP-220-EXECUTIONCLIENT-TARGET-SPLIT`

`ExecutionClient` target 当前编译 `Sources/TargetGraph/ExecutionClient/ExecutionClientTargetBoundary.swift`，依赖 `DomainModel` 和 `MessageBus`。现有 `Sources/ExecutionClient/FutureGate/` 与 `Sources/ExecutionClient/BrokerCapabilityMatrix/` evidence 仍由 `Core` compatibility envelope 编译。`ExecutionClient` 当前只能表达 outgoing adapter future gate / protocol boundary，不实现 broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、execution report、broker fill 或 reconciliation。

`MTP-220-EXECUTIONENGINE-TARGET-SPLIT`

`ExecutionEngine` target 当前编译 `Sources/TargetGraph/ExecutionEngine/ExecutionEngineTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio`、`RiskEngine` 和 `ExecutionClient`。现有 `Sources/ExecutionEngine/PaperLifecycle/`、`Sources/ExecutionEngine/SimulatedExchange/` 和 `Sources/ExecutionEngine/OMSFutureGate/` implementation 仍由 `Core` compatibility envelope 编译。`ExecutionEngine` 当前只表达 paper / simulated execution lifecycle boundary 与 OMS future gate evidence，不实现 live execution runtime、OMS implementation、broker gateway 或 executable live order command。

`MTP-220-RISKENGINE-EXECUTIONENGINE-EXECUTIONCLIENT-DIRECTION`

MTP-220 的 dependency direction 固定为：

```text
ExecutionClient -> DomainModel / MessageBus
ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient
Trader -> ExecutionEngine dependency resolved from MTP-219 deferred gate (historical before-state; superseded by GH-392)
```

`RiskEngine` 仍不能直连 broker 或 ExecutionClient；`ExecutionEngine` 可以消费 `RiskEngine` target boundary 和 `ExecutionClient` future gate boundary，但不能升级为 broker adapter、OMS implementation 或 real order lifecycle；MTP-220 historical before-state 曾允许 `Trader` 依赖 `ExecutionEngine` target boundary，GH-392 后该 direct target dependency 已退休，Trader 不能直连 `ExecutionEngine`、`ExecutionClient`、broker、OMS、signed endpoint、account endpoint、listenKey、private stream runtime 或 UI command surface。

`MTP-220-TRADER-EXECUTIONENGINE-DEPENDENCY-RESOLVED`

MTP-220 将 MTP-219 记录的 `Trader -> ExecutionEngine(MTP-220)` deferred dependency 解析为正式 target dependency。该段现在只作为 historical before-state evidence；GH-392 已移除 direct `Trader -> ExecutionEngine` target dependency，并把 `TraderTargetBoundary` 收紧为 no direct ExecutionEngine、no direct ExecutionClient、no broker / OMS、no real account payload 和 no live command surface guard。

`MTP-220-EXECUTIONCLIENT-FUTURE-GATE-ONLY`

`ExecutionClient` 只保留 future gate / protocol boundary semantics。它不能实现 broker SDK wrapper、exchange venue client、signed request builder、credential / secret / keychain storage、account endpoint reader、listenKey manager、private WebSocket connector、order submit / cancel / replace、execution report parser、broker fill parser 或 reconciliation runtime。

`MTP-220-EXECUTION-COMPATIBILITY-ENVELOPE-RETAINED`

MTP-220 保留 `Core` 继续编译既有 ExecutionEngine / ExecutionClient source roots。`Package.swift` 对 `Core`、`Runtime` 和 `App` compatibility targets 继续排除 `TargetGraph`，避免 boundary anchors 被旧 envelope 重复收编。Compatibility envelope retirement 仍归 MTP-222。

`MTP-220-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 `import ExecutionClient` 和 `import ExecutionEngine`，验证两个 targets 可编译、依赖方向正确、Trader deferred dependency 已解析，并阻断 broker gateway、OMS、signed/account endpoint、listenKey、private WebSocket runtime、real order lifecycle、execution report、broker fill、reconciliation 和 live command surface drift。

`MTP-220-NO-BROKER-OMS-REAL-ORDER-GUARD`

MTP-220 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、broker payload read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability；不启动 Symphony / symphony-issue，不运行 Graphify 或 code-index，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

`MTP-220-EXECUTION-TARGET-SPLIT-VALIDATION`

MTP-220 required validation：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTP-221 Dashboard Read-model-only Target Evidence

日期：2026-06-04

执行者：Codex

`MTP-221-DASHBOARD-TARGET-SPLIT-EVIDENCE`

MTP-221 最初建立 Workbench / Dashboard read-model consumption split。后续 direct cleanup 已退休 `Workbench` product / target、`Sources/Workbench/`、`App` product / target 和 `Sources/AppCompatibility`。当前 active UI target 只有 `Dashboard` executable，它直接编译 Dashboard shell、ReadModels、Report、Events 和 FutureLiveProConsole future label，并只依赖 `Core` / `Persistence` 导出的 read model、ViewModel 和 projection snapshot。

`MTP-221-WORKBENCH-TARGET-RETIRED`

`Workbench` target / product 当前已退休。`Package.swift` 不再包含 `Workbench` product / target，`Sources/Workbench/` 不再是 active source root，`Sources/Workbench/TargetGraph/WorkbenchTargetBoundary.swift` 只能作为 historical / forbidden active path 证据引用。

`MTP-221-DASHBOARD-TARGET-SPLIT`

`Dashboard` executable target 当前编译 `Sources/Dashboard/DashboardApplication.swift`、`Sources/Dashboard/DashboardTargetBoundary.swift`、`Sources/Dashboard/DashboardShell.swift`、`Sources/Dashboard/ReadModels/`、`Sources/Dashboard/Report/`、`Sources/Dashboard/Events/` 和 `Sources/Dashboard/FutureLiveProConsole/`，并只依赖 `Core` / `Persistence`。Dashboard 只装载 read model / ViewModel / projection snapshot display surface，不依赖 `Adapters`、`Runtime`、`ExecutionClient`、broker、OMS、schema、account payload 或 live command。

`MTP-221-DASHBOARD-READ-MODEL-DEPENDENCY-DIRECTION`

MTP-221 后续 cleanup 后的 active dependency direction 固定为：

```text
Dashboard -> Core / Persistence read-model and ViewModel exports only
```

`App` compatibility re-export、`Workbench` target 和 `Sources/Workbench` source root 均已退休。`Dashboard` 不能读取 domain runtime、adapter request、persistence schema 或 live command surface。Compatibility envelope retirement 仍归 MTP-222。

`MTP-221-READ-MODEL-VIEWMODEL-ONLY`

Dashboard 只能作为 read-model-only consumption target：允许展示 Report、Dashboard、Events、Evidence Explorer、Live Monitoring / Strategy readiness / Account Position Balance / Private Stream Simulation Gate 等已存在 ViewModel evidence；不得把 evidence surface 升级为 runtime object、adapter call、database schema access、broker payload access、account payload access 或 command surface。

`MTP-221-APP-COMPATIBILITY-EXPORT-RETIRED`

`App` product / target 和 `Sources/AppCompatibility/AppCompatibility.swift` 已退休。既有 App test surface 已改为直接 import `Dashboard`，不再通过 compatibility re-export 维护 `import App`。

`MTP-221-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 `import Dashboard`，验证 Dashboard target 可编译、依赖方向正确、App / Workbench compatibility retired，并阻断 Runtime object、Adapter request、Persistence schema、account payload、broker state、Live PRO Console、trading button、live command 和 order form drift。

`MTP-221-NO-UI-COMMAND-RUNTIME-SCHEMA-GUARD`

MTP-221 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、broker payload read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability；不启动 Symphony / symphony-issue，不运行 Graphify 或 code-index，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

`MTP-221-DASHBOARD-TARGET-SPLIT-VALIDATION`

MTP-221 required validation：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTP-222 Compatibility Anchor Retirement Evidence

日期：2026-06-04

执行者：Codex

`MTP-222-COMPATIBILITY-ANCHOR-RETIREMENT-EVIDENCE`

MTP-222 退休 obsolete compatibility envelopes and stale target anchors 的 active wording。它不删除 production source、不删除 retained compatibility targets、不改变 runtime behavior；只把 root / high-weight docs、validation plan、validation matrix、latest verification summary 和 automation readiness 中仍把旧 envelope 当作 current target graph 的表述降级为 historical / before-state evidence，并补齐当前 target graph snapshot。

`MTP-222-CURRENT-TARGET-GRAPH-SNAPSHOT`

当前 active SwiftPM target graph snapshot 是：

```text
DomainModel
MessageBus -> DomainModel
Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)
DataClient -> DomainModel
Cache -> DomainModel / MessageBus
DataEngine -> DomainModel / DataClient / MessageBus / Cache
Portfolio -> DomainModel / MessageBus / Cache / Database
RiskEngine -> DomainModel / MessageBus / Cache / Portfolio
ExecutionClient -> DomainModel / MessageBus
ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine
Dashboard -> Core / Persistence read-model and ViewModel exports only
```

`Core`、`Adapters`、`Persistence` 和 `Runtime` 仍可存在为 retained compatibility envelopes。它们只说明既有 implementation 和 import surface 的 buildability，不再是 active architecture graph 的唯一 target list。`App` product / target 和 `Sources/AppCompatibility` 已退休，不再作为 retained compatibility export。

`MTP-222-HISTORICAL-COMPATIBILITY-EVIDENCE-RETAINED`

MTP-216 的 compatibility envelope snapshot、MTP-183 至 MTP-211 的 physical source migration / compatibility envelope evidence、旧 `Sources/Strategies/<strategy>`、旧 `Sources/Trader/StrategyBindings/`、旧 `Dashboard -> App`、旧 `App -> Core, Persistence`、旧 `Dashboard -> Workbench` 和旧 `Sources/Workbench/` references 只能作为 historical / compatibility / superseded / before-state evidence 保留。Active docs 必须把 current source anchors 写为 `Sources/Trader/Strategies/EMA/`、`Sources/Trader/Coordination/RiskBinding/`、`TraderStrategies`、`Trader` 和 `Dashboard -> Core / Persistence`。

`MTP-222-STALE-ACTIVE-ANCHOR-RETIREMENT`

退休 stale active anchors 指：不再把 `Core / Adapters / Persistence / Runtime / App / Dashboard` 写成 current only SwiftPM target graph；不再把 `Sources/Strategies/<strategy>` 或 `Sources/Trader/StrategyBindings/` 写成 active strategy / binding landing path；不再把 `Dashboard -> App` 或 `App -> Core, Persistence` 写成 current UI dependency direction。历史 evidence 可以保留，但必须带 before-state / historical / compatibility / superseded 语义。

`MTP-222-NO-BEHAVIOR-RUNTIME-LIVE-GUARD`

MTP-222 不移动 production source，不新增、不删除、不重命名 SwiftPM target / product / dependency，不退休 `Core` / `Adapters` / `Persistence` / `Runtime` / `App` compatibility exports，不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

`MTP-222-COMPATIBILITY-ANCHOR-RETIREMENT-VALIDATION`

MTP-222 required validation：

- scoped fixed-string grep / automation readiness 证明 active docs 包含 current target graph snapshot、historical compatibility retained boundary、stale active anchor retirement 和 no behavior / runtime / live guard。
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTP-223 Target Graph Stage Closeout Evidence

日期：2026-06-04

执行者：Codex

`MTP-223-SWIFTPM-TARGET-GRAPH-STAGE-CLOSEOUT`

MTP-223 只收口 `MTPRO SwiftPM Target Graph Module Split v1` 的 validation matrix、automation readiness 和 stage audit input material。Canonical input 位于 `docs/audit/inputs/mtpro-swiftpm-target-graph-module-split-v1-stage-audit-input.md`。

`MTP-223-STAGE-AUDIT-INPUT-MATERIAL`

Stage audit input material 汇总 MTP-216 至 MTP-222 的 issue / PR / merge / required check evidence、current target graph snapshot、foundation / data / trader / execution / workbench target split evidence、compatibility anchor retirement、validation matrix closeout、automation readiness closeout、forbidden implementation audit、Root Docs Delta input 和 Parent Codex Stage Code Audit handoff checklist。

`MTP-223-TARGET-GRAPH-CLOSEOUT`

MTP-223 closeout 的 current target graph 仍以 MTP-222 snapshot 为准：`DomainModel`、`MessageBus`、`Database`、`DataClient`、`Cache`、`DataEngine`、`Portfolio`、`RiskEngine`、`ExecutionClient`、`ExecutionEngine`、`TraderStrategies`、`Trader`、`Workbench` 和 `Dashboard`。Retained `Core`、`Adapters`、`Persistence`、`Runtime` 和 `App` targets 只表达 existing implementation / import compatibility。

`MTP-223-NO-FINAL-STAGE-CODE-AUDIT`

MTP-223 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段，不启动新的 `@002 / PAR`、Symphony 或 `symphony-issue`。最终 Stage Code Audit Report 必须由 Parent Codex 在 MTP-216 至 MTP-223 全部 Done 且 Linear Project `Completed/completedAt` 后单独输出。

`MTP-223-FORBIDDEN-IMPLEMENTATION-AUDIT`

MTP-223 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability；不运行 Symphony、Graphify、code-index 或 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

`MTP-223-STAGE-CLOSEOUT-VALIDATION`

MTP-223 required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## MTP-224 TargetGraph Anchor Retirement / Real Module Source Root Migration Contract

日期：2026-06-04

执行者：Codex

`MTP-224-TARGETGRAPH-RETIREMENT-CONTRACT`

MTP-224 将 `Sources/TargetGraph` 固定为 transitional compile anchor / historical evidence。它当前仍承载 MTP-217 至 MTP-221 已建立的 SwiftPM target boundary anchors，但不是最终架构模块、不是长期 source ownership、不是新的 engine layer，也不是未来 feature landing path。Canonical MTP-224 contract 位于 `docs/contracts/targetgraph-anchor-retirement-real-module-source-root-migration-contract.md`。

`MTP-224-REAL-MODULE-SOURCE-ROOT-TARGET`

后续 active target path 的目标落点必须迁回真实模块 source roots：`Sources/DomainModel/`、`Sources/MessageBus/`、`Sources/Database/`、`Sources/DataClient/`、`Sources/DataEngine/`、`Sources/Cache/`、`Sources/Portfolio/`、`Sources/RiskEngine/`、`Sources/ExecutionClient/`、`Sources/ExecutionEngine/`、`Sources/Trader/Strategies/EMA/`、`Sources/Trader/Accounts/`、`Sources/Trader/Coordination/` 和 `Sources/Dashboard/`。当前 active concrete strategy only `EMA`；后续多个策略只能进入 `Sources/Trader/Strategies/<strategy>/`。

`MTP-224-MIGRATION-SEQUENCE-COMPATIBILITY-RULE`

后续迁移顺序固定为 MTP-225 audit、MTP-226 foundation、MTP-227 data、MTP-228 trader / portfolio / risk、MTP-229 execution future gate、MTP-230 Workbench / Dashboard、MTP-231 TargetGraph active path retirement、MTP-232 validation / compatibility / stage audit input closeout。每一步必须由 Linear live issue 单独授权，保持 WIP=1，并保留已授权 compatibility envelope，直到对应 issue 允许退休。

`MTP-224-DEPENDENCY-DIRECTION-AND-FORBIDDEN-PATH-TAXONOMY`

真实 module source root 迁移必须保持 MTP-222 current target graph direction，并应用 GH-392 的 Trader dependency correction：不得打开 `DataClient -> signed/account/listenKey/private runtime`、`TraderStrategies -> ExecutionClient / broker / OMS`、`Trader -> ExecutionEngine`、`Trader -> ExecutionClient`、`RiskEngine -> broker / ExecutionClient`、`ExecutionEngine -> current OMS / broker adapter`、`ExecutionClient -> signed request / real order lifecycle`、`Workbench -> Runtime object / Adapter request / Database schema / broker payload / account payload` 或 `Dashboard -> anything except Workbench`。

`MTP-224-NO-PACKAGE-SOURCE-MOVE-RUNTIME-GUARD`

MTP-224 不修改 `Package.swift`，不移动 production source 或 tests，不新增/删除/重命名 SwiftPM target/product/dependency，不退休 active `Sources/TargetGraph/*` path references，不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability；不启动 Symphony / symphony-issue，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

`MTP-224-VALIDATION-ANCHORS`

MTP-224 required validation：

- `git diff --check`
- `bash checks/run.sh`
- PR evidence 确认 `Package.swift` 无 diff、未移动 `Sources` 文件、docs 明确 `Sources/TargetGraph` 只是 transitional compile anchor / historical evidence，且 docs 不授权 `Package.swift` change、source move、target split、runtime、live、broker、L4 capability、Symphony、Graphify、code-index 或 Figma。
