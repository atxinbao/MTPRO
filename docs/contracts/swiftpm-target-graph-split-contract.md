# MTPRO SwiftPM Target Graph Split Contract

日期：2026-06-04

执行者：Codex

本文档是 `MTPRO SwiftPM Target Graph Module Split v1` 的 MTP-216 合同。它只定义后续 SwiftPM target graph split 的目标图、依赖方向、禁止导入和 issue 边界；MTP-216 本身不修改 `Package.swift`，不移动 production source，不新增 SwiftPM target / product / dependency。

## MTP-216-SWIFTPM-TARGET-GRAPH-SPLIT-CONTRACT

SwiftPM target graph split contract 指后续把当前 compatibility envelope 拆成 architecture-graph-aligned module targets 时必须遵守的目标图和依赖方向。当前仓库仍以 `Core`、`Adapters`、`Persistence`、`Runtime`、`App`、`Dashboard` 和 `CSQLite` 作为 SwiftPM build envelope；这些 target name 只维持 buildability，不代表最终 target graph 已拆分。

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
| `Trader` | `DomainModel`, `MessageBus`, `Cache`, `TraderStrategies`, `Portfolio`, `RiskEngine`, `ExecutionEngine` | `Trader = Accounts + Strategies/EMA + Coordination`；只做 identity / account context / strategy proposal / risk / execution coordination boundary。 |
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
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine / ExecutionEngine
Workbench -> ReadModel / ViewModel exports only
Dashboard -> Workbench
```

该方向保留 NautilusTrader 风格的 engine layering，但不复制 NautilusTrader runtime，也不把 MTPRO 当前 evidence 升级为 production trading engine。`TraderStrategies` 只能提出 strategy signal / paper-neutral proposal evidence；`Trader` 负责协调，不能绕过 `RiskEngine` / `ExecutionEngine`。`ExecutionClient` 在 MTP-216 仍只是 future gate contract，不是 current executable dependency。

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
