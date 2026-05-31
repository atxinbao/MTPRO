# Module Boundary

本文档定义 MTPRO 对齐交易系统架构图后的目标 Engine 边界，并把当前 SwiftPM target 标记为迁移来源。

日期：2026-05-31

执行者：Codex

## 架构图对齐口径

早期 MTPRO 文档中的大量禁止边界用于防止 paper / simulated / read-model evidence 被误升级成真实交易能力。进入 `MTPRO Engine Module Boundary Consolidation v1` 前，这些边界需要重新解释为：

- `ExecutionClient`、`OMS`、`Strategy runtime`、`Trader runtime`、`Portfolio runtime`、`Risk runtime`、`Cache`、`MessageBus`、`DataClient` 都可以作为目标架构模块名出现。
- 当前仍不授权这些模块的 live / broker / signed endpoint / real order 实现。
- 后续 Project 可以先定义模块职责、依赖方向、输入输出、禁止路径和 validation anchors。
- 只有独立 Human decision、Linear issue contract、Parent Codex queue preflight 和对应 validation gate 通过后，才允许某个 future module 进入实现范围。

大白话：不是“目标架构里不能有 Execution Client / OMS / Trader runtime”，而是“现在只能把它们作为 future-gated module boundary 画清楚，不能把它们实现成真实交易路径”。

## MTP-162 Terminology Contract

`MTP-162-TERMINOLOGY-CONTRACT`

MTP-162 固定 architecture graph module 到 MTPRO target boundary 的术语合同。该合同只约束名称、职责边界、旧 target 映射和 validation anchors，不迁移业务代码，不新增 Swift production code，不把目标模块名解释为当前 runtime implementation。

合同要求：

1. `DomainModel`、`DataClient`、`DataEngine`、`MessageBus`、`Cache`、`Database`、`Strategies`、`Trader`、`Account`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient`、`Workbench` 和 `Future Live PRO Console` 必须都有 MTPRO canonical term。
2. `Core / Adapters / Persistence / Runtime / App / Dashboard / CSQLite` 必须只作为 migration source / compatibility shell，不得继续作为新增能力落点。
3. future-gated module name 可以出现在目标架构、目标目录和后续 issue contract 中，但不得被写成当前可运行 runtime、endpoint、broker adapter、OMS、真实订单生命周期或 UI command surface。
4. 后续 M1 source layout / validation anchors issue 必须消费本合同的术语，不得重新发明平行模块名。

`MTP-162-CURRENT-RUNTIME-NON-AUTHORIZATION`

MTP-162 不授权 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、Graphify 或 Figma。

## 目标 Engine 边界

| Engine / Layer | 目标职责 | 当前允许状态 |
| --- | --- | --- |
| Domain Model | symbol、instrument、time、price、quantity、order/account/position/value object | pure domain allowed；不得携带 adapter / persistence / UI 依赖 |
| DataClient | exchange-scoped public market data client、future provider client、future private stream client boundary | public read-only 已可用；private / signed / account source 只能 future-gated；一个交易所一个目录 |
| DataEngine | market data ingest、request / response、scenario replay、data quality、catalog | local deterministic / public read-only / scenario replay allowed |
| MessageBus | facts、events、commands、request / response、engine routing、replay invariant | append-only facts / paper routing allowed；完整 runtime bus 待 consolidation |
| Cache | instruments、market data、orders、positions、portfolio summary 的 in-memory runtime-derived state | local runtime cache boundary allowed；不负责 durability / schema / DB adapter；real account cache forbidden now |
| Database | append-only event log、snapshot、projection database、event replay backing store | local-first durable backing store allowed；MTPRO 不复制 Redis；UI 不直接读 schema |
| Trader | account/risk/execution/strategy coordination context | identity / lifecycle / read-model input allowed；live runtime coordinator forbidden now |
| Account | Trader 内的 account context、account identity、source identity、future real account gate | fixture / paper / simulated read-model allowed；real account source forbidden now |
| Strategies | strategy lifecycle、quoter / hedger、signals、paper/live-neutral proposals | readiness evidence allowed；runtime scheduling 待 future gate |
| Portfolio | paper account、position、cash、PnL、exposure、future real account boundary | paper / simulated / read-model-only allowed；real broker portfolio forbidden now |
| RiskEngine | paper pre-trade risk、future live risk gates、blocked evidence | paper / blocked evidence allowed；real live risk runtime forbidden now |
| ExecutionEngine | paper lifecycle、simulated lifecycle、future OMS boundary、future execution routing | paper / simulated allowed；OMS / broker execution forbidden now |
| ExecutionClient | future exchange / broker execution client capability boundary | target module name allowed；implementation forbidden now |
| Workbench Interface | ReadModel / ViewModel / Dashboard / Report / Events | allowed read-model-only surface；Live PRO Console remains separate future product |

## 固定目标代码目录关系

`MTPRO Engine Module Boundary Consolidation v1` 必须一次性确定目标模块目录。目标目录以架构图模块为准，不再以早期 `Core / Adapters / Persistence / Runtime / App` 文件夹作为最终结构。后续 Linear issue 只能在这个固定结构内迁移文件、补充类型和增加 validation guard；不得临时新增平行 Engine 目录，也不得把 future-gated module 偷换成 live runtime implementation。

目标目录就是下一版代码结构定义。第一轮可以用文件夹 / namespace 先落地；当迁移进入代码执行时，应逐步把这些目录提升为 SwiftPM target 或等价模块边界。是否一次性修改 `Package.swift` 由对应 Linear issue 明确授权，但最终结构必须以这里为准。

```text
Sources/
  DomainModel/

  DataClient/
    Binance/
      PublicMarketData/
      FuturePrivateStreamGate/

  DataEngine/
    Ingest/
    ScenarioReplay/
    DataQuality/

  MessageBus/
    Events/
    Commands/
    Requests/
    Replay/

  Cache/
    Instruments/
    MarketData/
    Orders/
    Positions/
    PortfolioSummary/

  Database/
    AppendOnlyEventLog/
    Snapshots/
    Projections/
      SQLite/
      DuckDB/
    ReplayProjection/

  Strategies/
    EMA/
      Lifecycle/
      Quoter/
      Hedger/
      Signals/
      Proposals/
    <future-strategy>/

  Trader/
    Accounts/
    Coordination/
    StrategyBindings/

  Portfolio/
    Positions/
    NetPositions/
    Margin/
    OpenValue/
    PaperProjection/

  RiskEngine/
    Commands/
    Events/
    PreTrade/
    LiveGate/

  ExecutionEngine/
    Commands/
    Events/
    PaperLifecycle/
    SimulatedExchange/
    OMSFutureGate/

  ExecutionClient/
    FutureGate/
    BrokerCapabilityMatrix/

  Workbench/
    ReadModels/
    Report/
    Dashboard/
    Events/
    FutureLiveProConsole/

  Dashboard/
```

## 目标模块依赖方向

```text
DomainModel
  -> MessageBus
  -> Database
  -> Cache
  -> DataClient
  -> DataEngine
  -> Strategies
  -> Portfolio
  -> RiskEngine
  -> ExecutionClient
  -> ExecutionEngine
  -> Trader
  -> Workbench
  -> Dashboard
```

允许依赖方向：

- `DataClient` 只依赖 `DomainModel`，并按 `DataClient/<venue>/` 组织交易所适配；不得依赖 `DataEngine`、`Trader`、`ExecutionEngine` 或 UI。
- `DataEngine` 可依赖 `DomainModel`、`DataClient`、`MessageBus`、`Cache`。
- `Strategies` 可依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio`、`RiskEngine` read-model inputs；不得依赖 `Trader`、`ExecutionEngine` 或 `ExecutionClient`。
- `Trader` 可依赖 `DomainModel`、`MessageBus`、`Cache`、`Strategies`、`Portfolio`、`RiskEngine`、`ExecutionEngine`，但不得直连 `ExecutionClient`。
- `RiskEngine` 可依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio`，不得调用 broker / execution client。
- `ExecutionEngine` 可依赖 `DomainModel`、`MessageBus`、`Cache`、`RiskEngine`、`ExecutionClient` future gate；真实 `ExecutionClient` implementation 仍 forbidden。
- `Portfolio` 可依赖 `DomainModel`、`MessageBus`、`Cache`、`Database` projection，不得读取 broker account state。
- `Workbench` 只能依赖 read model / view model exports，不得读取 runtime object、adapter request、Database schema 或 broker payload。

## MTP-163 Fixed Layout / Dependency / Forbidden Path Contract

`MTP-163-FIXED-TARGET-SOURCE-MODULE-LAYOUT`

MTP-163 固定后续 issue 的唯一目标 source layout。后续迁移、namespace 收口、validation guard 和 stage closeout 只能引用下表中的目标目录，不得临时新增平行 Engine 目录，不得继续把 `Core / Adapters / Persistence / Runtime / App` 写成最终目标结构。

| Target module | 固定目录 | 目录规则 |
| --- | --- | --- |
| DomainModel | `Sources/DomainModel/` | pure domain value object；不携带 adapter / persistence / UI 依赖。 |
| DataClient | `Sources/DataClient/<venue>/` | 一个交易所 / venue 一个目录；Binance 下区分 `PublicMarketData` 与 `FuturePrivateStreamGate`。 |
| DataEngine | `Sources/DataEngine/` | `Ingest`、`ScenarioReplay`、`DataQuality` 只服务 ingest / replay / quality boundary。 |
| MessageBus | `Sources/MessageBus/` | `Events`、`Commands`、`Requests`、`Replay` 只承载 facts / routing / replay invariant。 |
| Cache | `Sources/Cache/` | runtime-derived state；不负责 durability、schema ownership 或 DB adapter。 |
| Database | `Sources/Database/` | append-only event log、snapshots、SQLite / DuckDB projections 和 replay projection。 |
| Strategies | `Sources/Strategies/<strategy>/` | 一个策略一个目录；EMA 是首个示例，不直连 Trader 或 ExecutionClient。 |
| Trader | `Sources/Trader/` | `Accounts`、`Coordination`、`StrategyBindings`；只做 coordination / context。 |
| Portfolio | `Sources/Portfolio/` | positions、net positions、margin、open value、paper projection 和 financial read models。 |
| RiskEngine | `Sources/RiskEngine/` | commands / events / pre-trade / live gate；不调用 broker 或 execution client。 |
| ExecutionEngine | `Sources/ExecutionEngine/` | paper lifecycle、simulated exchange 和 `OMSFutureGate`；不提交真实订单。 |
| ExecutionClient | `Sources/ExecutionClient/` | `FutureGate` / `BrokerCapabilityMatrix`；只表达 future venue API client gate。 |
| Workbench | `Sources/Workbench/` | ReadModels / Report / Dashboard / Events / FutureLiveProConsole label；current surface remains read-model-only。 |
| Dashboard | `Sources/Dashboard/` | macOS shell / smoke / presentation surface；不形成 broker command path。 |

`MTP-163-DEPENDENCY-DIRECTION-CONTRACT`

依赖方向固定为：

- `DataClient -> DomainModel` only；不能依赖 `DataEngine`、`Trader`、`ExecutionEngine`、`ExecutionClient`、`Workbench` 或 `Dashboard`。
- `DataEngine -> DomainModel / DataClient / MessageBus / Cache`；不能直接服务 Trader、Workbench 或 broker。
- `Strategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine read-model inputs`；不能直连 Trader、ExecutionEngine、ExecutionClient、broker 或 OMS。
- `Trader -> DomainModel / MessageBus / Cache / Strategies / Portfolio / RiskEngine / ExecutionEngine`；不能直连 ExecutionClient、broker command 或 account endpoint。
- `Portfolio -> DomainModel / MessageBus / Cache / Database projection`；不能读取 broker account state、account endpoint payload 或 Runtime object。
- `RiskEngine -> DomainModel / MessageBus / Cache / Portfolio`；不能调用 broker、ExecutionClient 或 live risk runtime。
- `ExecutionEngine -> DomainModel / MessageBus / Cache / RiskEngine / ExecutionClient future gate`；不能实现 current broker client、OMS implementation 或 real order lifecycle。
- `Workbench -> ReadModel / ViewModel exports`；不能读取 runtime object、adapter request、Database schema、account payload 或 broker state。

`MTP-163-FORBIDDEN-PATH-TAXONOMY`

MTP-163 把 forbidden path taxonomy 固定为 validation 输入：

| Forbidden path | 阻断原因 |
| --- | --- |
| `Strategies -> ExecutionClient` | Strategy proposal 不能升级为 executable order command。 |
| `Trader -> ExecutionClient` | Trader 是 coordination context，不是 broker gateway。 |
| `Workbench -> Runtime object / Adapter request / Database schema` | Workbench 只能消费 ReadModel / ViewModel。 |
| `DataClient -> signed/account/listenKey/private runtime` | 当前 DataClient 只允许 public read-only / fixture / future gate labels。 |
| `RiskEngine -> broker / ExecutionClient` | RiskEngine 只输出 risk evidence，不执行 broker action。 |
| `Portfolio -> broker account state` | Portfolio 当前只持有 paper / simulated / read-model financial state。 |
| `ExecutionEngine -> current OMS / broker adapter` | ExecutionEngine 当前只允许 paper / simulated lifecycle。 |
| `FutureLiveProConsole -> current Workbench command surface` | Future Live PRO Console 是独立 future product surface。 |

`MTP-163-DATACLIENT-VENUE-STRATEGIES-STRATEGY-DIRECTORY-RULE`

`DataClient/<venue>/` 和 `Strategies/<strategy>/` 是目录命名不变量。后续不得把 venue-specific adapter 散落到 `DataEngine`、`Runtime` 或 `Workbench`，也不得把 strategy-specific lifecycle / quoter / hedger / proposal 逻辑散落到 `Trader`、`ExecutionEngine` 或 `ExecutionClient`。

`MTP-163-TRADER-ACCOUNT-PORTFOLIO-SPLIT`

`Trader/Accounts` 只负责 account context / identity / source identity；`Portfolio` 独立负责 cash、positions、PnL、exposure、margin、open value 和 paper projection。后续不得把 Portfolio financial state 塞回 Trader，也不得让 Trader 读取真实账户 payload 或 broker state。

`MTP-163-EXECUTIONENGINE-EXECUTIONCLIENT-SPLIT`

`ExecutionEngine` 是内部 paper / simulated lifecycle module；`ExecutionClient` 是 future venue API client gate。MTP-163 不授权 `Package.swift` target graph change，不实现 current ExecutionClient，不实现 OMS implementation，不连接 broker / exchange execution adapter。

`MTP-163-FIXED-LAYOUT-VALIDATION`

MTP-163 只验证 fixed layout、dependency direction 和 forbidden path taxonomy 已落仓。任何 source move、SwiftPM target 拆分、runtime actor、private stream runtime、account snapshot runtime、signed/account/listenKey endpoint、broker adapter、OMS、Live PRO Console、trading button、live command 或 order form 仍必须由后续独立 Linear issue 明确授权。

## MTP-164 Architecture Boundary Validation Anchors

`MTP-164-ARCHITECTURE-BOUNDARY-VALIDATION-ANCHORS`

MTP-164 把 MTP-162 terminology contract 和 MTP-163 fixed layout contract 固定成后续 milestone 的 validation anchor layer。该 layer 只服务 docs/checks-focused validation，不移动业务代码、不修改 `Package.swift` target graph、不把 future-gated module name 写成 current runtime implementation。

| Validation anchor | 必须阻断的漂移 | 证明方式 |
| --- | --- | --- |
| `MTP-164-OLD-PATH-DRIFT-GUARD` | `Core / Adapters / Persistence / Runtime / App / Dashboard / CSQLite` 被继续写成最终目标结构、长期新增能力落点或新 architecture module name。 | 后续 issue 必须把新增边界映射回 MTP-163 固定 `Sources/*` 目标目录。 |
| `MTP-164-FUTURE-GATED-IMPLEMENTATION-DRIFT-GUARD` | `ExecutionClient`、`OMSFutureGate`、`FuturePrivateStreamGate`、`FutureLiveProConsole`、`Strategy runtime`、`Trader runtime`、`Portfolio runtime`、`Risk runtime` 或完整 `MessageBus` 被写成 current runtime implementation。 | 后续 issue 必须把这些词限定为 target boundary / future gate / validation label。 |
| `MTP-164-FORBIDDEN-CAPABILITY-DRIFT-GUARD` | Strategy / Trader / Workbench / DataClient / ExecutionClient forbidden path 被绕开。 | 后续 issue 必须继续证明 no signed/account/listenKey、no broker adapter、no OMS implementation、no live command surface。 |
| `MTP-164-CROSS-MILESTONE-VALIDATION-INPUT` | M2-M6 各 milestone 重新发明平行模块名、平行目录或局部例外。 | MessageBus / Cache / Database、DataClient / DataEngine、Strategies / Trader / Portfolio、Risk / Execution 和 Workbench issue 必须复用同一 anchor。 |

`MTP-164-OLD-PATH-DRIFT-GUARD`

Old target names 只能作为迁移来源解释。`Core` 不得继续承载新增 engine boundary；`Adapters` 不得继续承载 venue-specific final target；`Persistence` 不得继续被写成 Database 的外部同义词；`Runtime` 不得继续承载 DataEngine / MessageBus / Cache 的最终结构；`App`、`Dashboard` 和 `CSQLite` 只能按 Workbench / Dashboard / Database implementation detail 解释。

`MTP-164-FUTURE-GATED-IMPLEMENTATION-DRIFT-GUARD`

Future-gated target module 可以出现在目标架构，但 current scope 仍禁止 Strategy runtime、Trader runtime、Live runtime、current ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。

`MTP-164-FORBIDDEN-CAPABILITY-DRIFT-GUARD`

Forbidden path taxonomy 继续固定为 validation input：`Strategies -> ExecutionClient`、`Trader -> ExecutionClient`、`Workbench -> Runtime object / Adapter request / Database schema`、`DataClient -> signed/account/listenKey/private runtime`、`RiskEngine -> broker / ExecutionClient`、`Portfolio -> broker account state`、`ExecutionEngine -> current OMS / broker adapter` 和 `FutureLiveProConsole -> current Workbench command surface` 都不能被后续 docs、checks 或 PR evidence 弱化。

`MTP-164-CROSS-MILESTONE-VALIDATION-INPUT`

MTP-164 anchors 必须被 M2 MessageBus / Cache / Database、M3 DataClient / DataEngine、M4 Strategies / Trader / Portfolio、M5 Risk / Execution 和 M6 Workbench / stage closeout 继续消费。后续 issue 可以细化模块输入输出，但不能绕过 MTP-164 anchors 放宽 old path、future gate 或 forbidden capability boundary。

`MTP-164-ARCHITECTURE-BOUNDARY-VALIDATION`

MTP-164 只证明 validation anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不证明任何 source move、SwiftPM target split、runtime actor、private stream runtime、account snapshot runtime、signed/account/listenKey endpoint、broker adapter、OMS、Live PRO Console、trading button、live command 或 order form 已实现。

## MTP-165 MessageBus / Command / Event Boundary

`MTP-165-MESSAGEBUS-FACTS-COMMANDS-EVENTS-CONTRACT`

MTP-165 将 `Sources/MessageBus/` 固定为本地 facts / events / commands / request-response / replay invariant boundary。该边界只服务 deterministic evidence routing，不代表 external message broker、live command bus、OMS bus、ExecutionClient request queue 或 UI command surface。

| MessageBus surface | 当前含义 | 禁止升级 |
| --- | --- | --- |
| Facts | append-only `DomainEvent` evidence；包含 market、strategy、paper、risk、portfolio、replay facts。 | 不等于 broker acknowledgement、execution report、account payload 或 production incident fact。 |
| Events | facts 的领域分类、stream、envelope、correlation / causation evidence。 | 不等于 private WebSocket runtime message、broker event stream 或 UI event handler。 |
| Commands | 本地 paper / replay / research 意图输入和 routed message。 | 不等于 executable order command、broker command、OMS order 或 live command。 |
| Request-response | engine-local deterministic request / response evidence。 | 不暴露 HTTP API、Adapter request、Database schema、Runtime object 或 Workbench command surface。 |
| Replay invariant | Event Log / Replay 可重建 route evidence、stream、correlation 和 causation。 | 不等于 production recovery、broker replay、account replay 或 live incident replay runtime。 |

`MTP-165-REQUEST-RESPONSE-CONTRACT`

Request-response 只允许 DataEngine、Strategies、Trader、RiskEngine、ExecutionEngine 和 Portfolio 交换 read-model / evidence input。请求不能绕开 RiskEngine / ExecutionEngine，响应不能携带 broker payload、account endpoint payload、SQLite / DuckDB schema、Runtime object、Adapter request 或 UI command output。

`MTP-165-PAPER-ROUTING-REPLAY-INVARIANT`

Paper routing 必须继续复用 `PaperRuntimeMessageBusRouting`、`MessageBus.publish`、`AppendOnlyEventLog` 和 `EventReplayCommand` 的 deterministic path。所有 routed facts 都必须可由 Event Log / Replay 重建；Replay 只证明本地 append-only facts consistency，不授权生产恢复、broker replay、real account replay 或 live incident replay runtime。

`MTP-165-ENGINE-DEPENDENCY-BRIDGE`

MessageBus 只能作为 engine evidence bridge：

- `DataEngine -> MessageBus`：publish market ingest、scenario replay 和 data quality facts。
- `Strategies -> MessageBus`：publish signals / proposals，不直连 Trader、ExecutionClient 或 broker。
- `Trader -> MessageBus`：协调 context / bindings，不成为 live coordinator 或 broker gateway。
- `RiskEngine -> MessageBus`：publish pre-trade / blocked evidence，不执行 broker action。
- `ExecutionEngine -> MessageBus`：publish paper lifecycle / simulated fill facts，不提交真实订单。
- `Portfolio -> MessageBus`：consume projection facts，不读取 broker account state。

`MTP-165-RISK-EXECUTION-BYPASS-GUARD`

MessageBus 不允许绕过 risk / execution boundary。禁止 `Strategies -> MessageBus -> ExecutionClient`、`Trader -> MessageBus -> broker command`、`Workbench -> MessageBus -> live command`、`DataClient -> MessageBus -> account endpoint`、`ExecutionEngine -> MessageBus -> current OMS` 或任何 broker / signed / listenKey / private runtime bypass path。

`MTP-165-MESSAGEBUS-BOUNDARY-VALIDATION`

MTP-165 只证明 MessageBus contract anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不实现完整 runtime MessageBus，不修改 UI command surface，不实现 broker、OMS、ExecutionClient、live command path、signed/account/listenKey endpoint、private WebSocket runtime 或 source migration。

## MTP-166 Cache Boundary

`MTP-166-CACHE-RUNTIME-DERIVED-STATE-CONTRACT`

MTP-166 将 `Sources/Cache/` 固定为 runtime-derived state boundary。Cache 只能保存可从 MessageBus facts、Database projection snapshot、local replay output、paper lifecycle 和 simulated lifecycle 重建的本地运行期状态，不是 durable store、schema owner、DB adapter、UI contract 或 broker/account cache。

| Cache surface | 当前含义 | 禁止升级 |
| --- | --- | --- |
| Instruments | 当前运行期可用 symbol、venue、timeframe 和 metadata read state。 | 不等于 exchange source of truth、signed exchange info 或 broker instrument master。 |
| Market data | DataEngine ingest / replay 后的 latest bar、quote、depth summary 和 freshness state。 | 不直连 DataClient，不发起 network request，不替代 Event Log。 |
| Orders | paper / simulated order lifecycle read state。 | 不等于 executable order command、OMS order、ExecutionClient request 或 broker order cache。 |
| Positions | paper / simulated position read state。 | 不等于 broker position、real account position、margin 或 leverage source。 |
| Account / portfolio summary | paper account / portfolio projection summary。 | 不等于 real balance、real PnL、buying power、account endpoint payload 或 broker state。 |

`MTP-166-CACHE-DURABILITY-SCHEMA-SEPARATION`

Cache 不负责 durability、schema ownership、DB adapter、SQLite / DuckDB projection、append-only Event Log、snapshot lifecycle 或 replay persistence。durable facts 继续归 MessageBus / Event Log，persistent projections 归 Database，Cache 只承载运行期可重建 read state。

`MTP-166-CACHE-DATABASE-MESSAGEBUS-RELATIONSHIP`

Cache 只能消费 MessageBus facts、Database projection snapshot 和 local replay output；不得替代 MessageBus publish / replay invariant，不得向 Database 写 schema，不得暴露 SQLite / DuckDB schema 给 Workbench，不得绕过 DataEngine、Portfolio、RiskEngine 或 ExecutionEngine。Cache miss / stale 必须表现为 read-model unavailable evidence，不得触发 broker call、signed request、account endpoint request 或 live command。

`MTP-166-REAL-ACCOUNT-CACHE-FORBIDDEN-GUARD`

禁止把 Cache 扩展为 real account cache、broker position cache、broker state mirror、ExecutionClient request cache、OMS order cache 或 Live PRO Console command state。禁止 `DataClient -> Cache -> account endpoint`、`Cache -> signed request`、`Cache -> private WebSocket runtime`、`Workbench -> Cache -> live command`、`Portfolio -> Cache -> broker state` 和 `ExecutionEngine -> Cache -> OMS order`。

`MTP-166-CACHE-BOUNDARY-VALIDATION`

MTP-166 只证明 Cache boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不实现 Redis、external cache service、real account / broker state cache、Database implementation、UI command surface、runtime object exposure、live command path、signed/account/listenKey endpoint、private WebSocket runtime 或 source migration。

## MTP-167 Database Boundary

`MTP-167-DATABASE-DURABLE-FACTS-SNAPSHOT-PROJECTION-CONTRACT`

MTP-167 将 `Sources/Database/` 固定为 local-first durable backing store boundary。Database 负责 Event Log、Snapshot、Projection、SQLite / DuckDB implementation detail、schema/version 和 replay projection 的职责划分；它不直接驱动 Workbench UI，不复制 Redis，不持久化 broker/account payload。

| Database surface | 当前含义 | 禁止升级 |
| --- | --- | --- |
| Event Log | append-only durable facts；输入来自 MessageBus / local replay。 | 不等于 broker event store、execution report store 或 production incident log。 |
| Snapshot | 从 facts / replay 重建的本地状态切片。 | 不等于 real account snapshot、broker position snapshot 或 source-of-truth account state。 |
| Projection | 面向 query / report / cache 的 local read state。 | 不直接成为 Workbench UI contract，不暴露 raw table / schema。 |
| SQLite | local runtime projection implementation detail。 | 不暴露 table、column、raw SQL 或 adapter handle 给 Workbench。 |
| DuckDB | analytical projection implementation detail。 | 不暴露 analytical schema 给 UI，不承载 broker/account payload archive。 |
| Schema / version | local deterministic validation 和 replay projection compatibility evidence。 | 不等于 public product API、Adapter request contract 或 Runtime object contract。 |

`MTP-167-SQLITE-DUCKDB-SCHEMA-VERSION-CONTRACT`

SQLite / DuckDB schema、version、migration 和 replay projection 只服务 local deterministic validation。schema/version 不能被 Cache 继承为 state ownership，不能作为 Workbench / Report / Dashboard / Events 的 product surface contract，也不能镜像 account endpoint payload、broker payload、Runtime object 或 Adapter request。

`MTP-167-DATABASE-MESSAGEBUS-CACHE-PORTFOLIO-RELATIONSHIP`

Database 从 MessageBus / Event Log 接收 durable facts，产出 snapshot / projection input 给 Cache、Portfolio projection 和 report read model。Cache 不写 Database schema；Portfolio projection 只消费 paper / simulated facts；Workbench 只能消费 ReadModel / ViewModel，不得直接调用 Database adapter。

`MTP-167-WORKBENCH-SCHEMA-BYPASS-GUARD`

禁止 `Workbench -> Database schema`、`Report -> raw SQL query`、`Dashboard -> SQLite table`、`Events -> DuckDB row`、`Cache -> DB adapter schema owner`、`DataClient -> Database account payload archive` 或 `ExecutionEngine -> Database broker fill store`。所有 database-backed evidence 必须通过 ReadModel / ViewModel / report input contract。

`MTP-167-ACCOUNT-BROKER-PERSISTENCE-FORBIDDEN-GUARD`

Database 禁止持久化 real account payload、broker payload、broker state、broker position、real balance、real position、margin、leverage、buying power、real PnL、signed request、account endpoint response、listenKey state、private WebSocket runtime message、ExecutionClient request、OMS order、execution report、broker fill 或 reconciliation record。

`MTP-167-DATABASE-BOUNDARY-VALIDATION`

MTP-167 只证明 Database boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不实现 Database migration、schema exposure、broker/account payload persistence、Redis clone、UI command surface、runtime object exposure、live command path、signed/account/listenKey endpoint、private WebSocket runtime 或 source migration。

## MTP-168 DataClient Exchange Adapter Boundary

`MTP-168-DATACLIENT-VENUE-ADAPTER-BOUNDARY-CONTRACT`

MTP-168 将 `Sources/DataClient/<venue>/` 固定为 venue-scoped exchange adapter boundary。一个交易所只能进入一个 venue 目录；当前 Binance 只能作为 `Sources/DataClient/Binance/` 的示例边界出现。DataClient 负责 source identity、provider client / exchange client capability taxonomy、public market data request contract 和 future private stream gate label；它不依赖 DataEngine、Trader、ExecutionEngine、ExecutionClient、Workbench 或 Database。

| DataClient surface | 当前含义 | 禁止升级 |
| --- | --- | --- |
| Venue directory | `Sources/DataClient/<venue>/`，例如 `Binance/`。 | 不把 `Adapters/`、`Runtime/` 或 per-endpoint 临时目录写成目标结构。 |
| PublicMarketData | public read-only market data source boundary。 | 不带 API key、signature、account、order、listenKey 或 private stream runtime。 |
| FuturePrivateStreamGate | future-gated private stream label。 | 不创建 listenKey，不连接 private WebSocket，不运行 account snapshot runtime。 |
| Provider client | provider / SDK facade taxonomy。 | 不等于 broker adapter、ExecutionClient 或 OMS client。 |
| Exchange client | venue-specific request / response capability taxonomy。 | 不等于 signed execution client、account endpoint client 或 real broker gateway。 |

`MTP-168-BINANCE-PUBLIC-MARKET-DATA-BOUNDARY`

Binance 在当前 scope 只能表达 public market data boundary：symbols、klines、trades、depth、book ticker 和其他 public read-only evidence 可以作为 DataClient source contract；account、order、signed request、listenKey、private stream、execution report、broker fill、reconciliation、margin、leverage、buying power 和 real PnL 不能进入 current DataClient implementation。

`MTP-168-FUTURE-PRIVATE-STREAM-GATE-CONTRACT`

`FuturePrivateStreamGate` 只能是 future-gated label，用于说明未来 private stream 需要 Human decision、独立 Project Definition、credential / endpoint / adapter / operations gates 和 forbidden capability audit。该 label 不授权当前 issue 创建 listenKey、keepalive listenKey、连接 private WebSocket、运行 account snapshot runtime、读取 account endpoint payload 或保存 broker state。

`MTP-168-PROVIDER-EXCHANGE-CAPABILITY-TAXONOMY`

Provider client / exchange client taxonomy 只描述 capability classification：`public-market-data`、`future-private-stream-gated`、`forbidden-signed-account` 和 `forbidden-execution`. Capability taxonomy 不能被 DataEngine、Trader、ExecutionEngine、Workbench 或 Cache 当成 runtime object、Adapter request、Database schema、broker payload 或 UI command contract。

`MTP-168-DATACLIENT-DEPENDENCY-ISOLATION-GUARD`

DataClient 不依赖 DataEngine、Trader、ExecutionEngine、ExecutionClient、Workbench、Cache、Database 或 Portfolio。依赖方向只能是 DataEngine 在后续 issue 通过 request / ingest boundary 消费 DataClient public market data capability；DataClient 不能 publish MessageBus facts、不能写 Database、不能驱动 Workbench，也不能绕过 DataEngine 直接服务 Trader / Strategy / UI。

`MTP-168-SIGNED-ACCOUNT-LISTENKEY-FORBIDDEN-GUARD`

禁止 `DataClient -> signed endpoint`、`DataClient -> account endpoint`、`DataClient -> listenKey create / keepalive`、`DataClient -> private WebSocket runtime`、`DataClient -> account snapshot runtime`、`DataClient -> broker adapter`、`DataClient -> ExecutionClient`、`DataClient -> OMS`、`DataClient -> real order lifecycle`、`DataClient -> broker fill / reconciliation` 或 `DataClient -> Database account payload archive`。

`MTP-168-DATACLIENT-BOUNDARY-VALIDATION`

MTP-168 只证明 DataClient exchange adapter boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不实现 source move、SwiftPM target split、Binance runtime migration、signed/account/listenKey endpoint、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、ExecutionClient、OMS、UI command surface、Graphify 或 Figma。

## MTP-169 DataEngine Ingest / Replay / Quality Boundary

`MTP-169-DATAENGINE-INGEST-REPLAY-QUALITY-CONTRACT`

MTP-169 将 `Sources/DataEngine/` 固定为 market data ingest、request / response、scenario replay、catalog、freshness 和 quality gates 的本地数据引擎边界。DataEngine 只把 local deterministic、public read-only 和 scenario replay evidence 转换成可追溯 facts / evidence；它不直接服务 Workbench UI、Trader、Strategy、RiskEngine 或 ExecutionEngine。

| DataEngine surface | 当前含义 | 禁止升级 |
| --- | --- | --- |
| Ingest | 消费 DataClient public market data capability 或本地 fixture。 | 不直连 signed/account/listenKey/private stream runtime。 |
| Request / response | engine-local deterministic request / response evidence。 | 不暴露 Adapter request、Runtime object、HTTP API 或 UI command surface。 |
| Scenario replay | 固定 replay window、dataset / fixture version 和 source identity。 | 不等于 live recovery、broker replay、private stream replay 或 account replay。 |
| Catalog | source identity、dataset、symbol/timeframe、fixture version 和 replay window registry。 | 不包含 credential、secret、account id、broker state 或 endpoint lease。 |
| Freshness | observedAt、source watermark、fresh / stale / missing / blocked evidence。 | 不触发 network refresh、listenKey keepalive、broker sync 或 live command。 |
| Quality gates | completeness、ordering、checksum、schema-free read evidence。 | 不暴露 SQLite / DuckDB schema，不生成 executable order command。 |

`MTP-169-MARKET-DATA-INGEST-REQUEST-RESPONSE-CONTRACT`

DataEngine 只能通过 request / ingest boundary 消费 DataClient public market data capability，并把 result 解释为 market data facts / evidence input。Request / response 必须保留 source identity、dataset / fixture version、replay window、freshness 和 quality evidence；不能携带 API key、signature、account endpoint payload、listenKey、private stream message、broker payload、Runtime object 或 Adapter request。

`MTP-169-SCENARIO-REPLAY-CATALOG-FRESHNESS-QUALITY-GATES`

Scenario replay、catalog、freshness 和 quality gates 必须保持 local deterministic / public read-only / scenario replay allowed。fresh / stale / missing / blocked 只描述 evidence 可用性；stale 不触发 network refresh，missing 不回退到 signed/account endpoint，blocked 表示 forbidden capability boundary 拒绝 private stream、broker adapter 或 account payload。

`MTP-169-DATAENGINE-MESSAGEBUS-PUBLISHING-CONTRACT`

DataEngine 到 MessageBus 的唯一输出是 market ingest facts、scenario replay facts、catalog facts、freshness evidence 和 quality gate evidence。DataEngine 不能 publish order command、risk decision、execution decision、broker command、OMS request、UI command 或 Workbench event handler。

`MTP-169-DATACLIENT-MESSAGEBUS-CACHE-RELATIONSHIP`

DataClient 只提供 public market data capability；DataEngine 负责 ingest / replay / quality interpretation；MessageBus 承载 facts / evidence；Cache 只能消费 MessageBus facts 和 Database projection snapshot 形成 runtime-derived read state。DataEngine 不写 Cache，不写 Database schema，不直接驱动 Workbench，也不直接服务 Trader。

`MTP-169-UI-TRADER-DIRECT-SERVICE-FORBIDDEN-GUARD`

禁止 `Workbench -> DataEngine`、`Trader -> DataEngine`、`Strategy -> DataEngine`、`RiskEngine -> DataEngine`、`ExecutionEngine -> DataEngine`、`DataEngine -> UI command` 或 `DataEngine -> Trader coordination`。所有 DataEngine evidence 必须先进入 MessageBus / Cache / ReadModel / ViewModel 或 report input contract。

`MTP-169-SIGNED-ACCOUNT-BROKER-PATH-FORBIDDEN-GUARD`

禁止 `DataEngine -> signed endpoint`、`DataEngine -> account endpoint`、`DataEngine -> listenKey create / keepalive`、`DataEngine -> private WebSocket runtime`、`DataEngine -> account snapshot runtime`、`DataEngine -> broker adapter`、`DataEngine -> ExecutionClient`、`DataEngine -> OMS`、`DataEngine -> real order lifecycle`、`DataEngine -> broker fill / reconciliation`、`DataEngine -> real account payload` 或 `DataEngine -> Database account payload archive`。

`MTP-169-DATAENGINE-BOUNDARY-VALIDATION`

MTP-169 只证明 DataEngine ingest / replay / quality boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不实现完整 streaming DataEngine runtime、source move、SwiftPM target split、signed/account/listenKey endpoint、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、ExecutionClient、OMS、UI command surface、Graphify 或 Figma。

## 架构图模块到目标目录

| 架构图模块 | 固定目标目录 | 边界说明 |
| --- | --- | --- |
| DataClient | `Sources/DataClient/<venue>/` | 一个交易所一个目录；`Binance/PublicMarketData` 承载当前 public read-only client，private stream 只能进入同交易所下的 future gate；signed/account/listenKey 禁止。 |
| DataEngine | `Sources/DataEngine/` | ingest、subscription/request/response contract、scenario replay、data quality。 |
| MessageBus | `Sources/MessageBus/` | facts、events、commands、request/response、engine routing、replay invariant；不能绕过 risk/execution boundary。 |
| Cache | `Sources/Cache/` | in-memory / runtime-derived read state：instruments、market data、orders、positions、portfolio summary；不负责 durability、schema、EventLog 或 DB adapter。 |
| Database | `Sources/Database/` | durable local backing store：append-only event log、snapshot、SQLite / DuckDB projection、replay projection；不直接驱动 UI，不复制 Redis 实现。 |
| Strategies | `Sources/Strategies/<strategy>/` | 一个策略一个目录；当前 EMA 进入 `Sources/Strategies/EMA/`，后续不同交易策略继续放在 `Strategies/<strategy>/` 下；Strategies 独立于 Trader，不能直连 ExecutionClient。 |
| Trader | `Sources/Trader/` | account / strategy / risk / execution coordination boundary；当前只允许 identity / lifecycle / read-model input。 |
| Account | `Sources/Trader/Accounts/` | Trader 内的 account context 和 source identity；不拥有 cash / positions / PnL，real account source future-gated。 |
| Portfolio | `Sources/Portfolio/` | positions、net positions、cash/equity、margin、open value、paper projection；拥有 portfolio financial state，不读取 broker portfolio。 |
| RiskEngine | `Sources/RiskEngine/` | paper pre-trade risk、blocked evidence、future live risk gates；real live risk runtime forbidden。 |
| ExecutionEngine | `Sources/ExecutionEngine/` | paper lifecycle、simulated lifecycle、matching / fill / fee / slippage、future OMS boundary。 |
| ExecutionClient | `Sources/ExecutionClient/` | 只允许 future-gated capability contract；不实现 broker / exchange execution adapter。 |
| Workbench / Report / Events | `Sources/Workbench/` | 只能消费 ReadModel / ViewModel；不读 runtime object、adapter request、schema 或 broker payload。 |

## Trader / Account / Portfolio 分层决定

`Account` 可以放在 `Trader/Accounts/` 下，因为它在当前目标结构里只是 Trader 协调时使用的 account context、account identity 和 source identity。它不拥有资金、仓位、PnL、margin、leverage，也不读取真实账户。

`Portfolio` 不建议合并进 `Trader`。原因是 Portfolio 在架构图里是独立于 Trader 的状态投影模块，负责 positions、net positions、cash/equity、margin、open value、paper projection 等 financial state。RiskEngine、Workbench、Report、Events、ExecutionEngine replay 都可能读取 Portfolio read model。如果把 Portfolio 塞进 Trader，后续依赖方向会变成“所有东西都绕 Trader”，模块边界会变脏。

大白话：`Trader` 是调度员，知道当前用哪个 account context、哪些 strategies、先问 risk、再把允许的事交给 execution boundary；`Portfolio` 是账本和仓位视图，记录钱、仓位、敞口和盈亏投影。调度员可以看账本，但账本不应该变成调度员身体的一部分。

## ExecutionEngine / ExecutionClient 分层决定

`ExecutionEngine` 是 MTPRO 内部的执行决策和生命周期模块。它负责理解订单意图、检查 paper / simulated lifecycle、处理 accepted / rejected / filled / expired 等内部事件，并把结果写回 MessageBus、Portfolio projection 或 evidence surface。现在允许的 paper execution、simulated exchange、backtest parity 都属于 ExecutionEngine 范围。

`ExecutionClient` 是未来对外连接真实交易场所或 broker 的客户端边界。它的职责是把内部已经通过 RiskEngine 和 ExecutionEngine 的指令，翻译成某个交易所 / broker 的真实 API 请求，并接收真实回报。比如 Binance signed order submit、cancel、replace、execution report、broker fill、account execution stream，这些都只能属于 future-gated ExecutionClient。

大白话：`ExecutionEngine` 是内部“执行大脑”，决定这张单在系统里怎么走；`ExecutionClient` 是外部“交易所电话线”，真的把请求打到 broker / exchange。现在 MTPRO 只能建设大脑的 paper / simulated 部分，不能接电话线。

## 当前代码迁移来源

当前代码仍采用较粗的 SwiftPM target 分层。它们只是迁移来源和 compatibility shell，不是下一版目标结构：

```text
Core
Adapters
Persistence
Runtime
App
Dashboard
CSQLite
```

迁移时必须按下表归位，不能继续把旧 target 当成新增能力落点：

| 当前 target / 目录 | 迁移目标 | 迁移说明 |
| --- | --- | --- |
| `Core` domain types、events、commands | `Sources/DomainModel/`、`Sources/MessageBus/` | 领域对象进入 `DomainModel`；facts / events / commands / request-response 进入 `MessageBus`。 |
| `Core` paper / simulated execution contracts | `Sources/ExecutionEngine/`、`Sources/RiskEngine/`、`Sources/Portfolio/` | 按职责拆到 paper lifecycle、risk gate、portfolio projection；不得直连 `ExecutionClient`。 |
| `Adapters` public market data | `Sources/DataClient/Binance/PublicMarketData/` | public read-only client 迁入 Binance 交易所适配目录；private / signed / account source 只能留在同交易所下的 future gate。 |
| `Runtime` ingest / replay orchestration | `Sources/DataEngine/`、`Sources/MessageBus/`、`Sources/Cache/` | Data ingest、scenario replay、facts routing、runtime cache 分别归位。 |
| `Persistence` event log / projections | `Sources/Database/`、`Sources/Cache/` | EventLog、snapshot、SQLite / DuckDB projection 归入 `Database`；in-memory / runtime-derived state 归入 `Cache`。 |
| `Core` strategy readiness / proposal contracts | `Sources/Strategies/<strategy>/`、`Sources/Trader/` | strategy lifecycle、quoter / hedger、signals、proposal 按策略进入 `Strategies/<strategy>`；Trader 只保留 coordination / account context / strategy binding。 |
| `App` Workbench / Report / Events | `Sources/Workbench/`、`Sources/Dashboard/` | UI 只能消费 ReadModel / ViewModel；不得读取 runtime object、adapter request、schema 或 broker payload。 |
| `Dashboard` smoke / fixtures | `Sources/Dashboard/`、`Sources/Workbench/` | 保留为可观察 evidence surface，不形成 live command surface。 |
| `CSQLite` | `Sources/Database/SQLiteProjection/` implementation dependency | 仅作为 local projection implementation detail；不得暴露给 UI 或 broker/account payload。 |

## Consolidation 前置规则

后续模块收口必须遵守：

1. 允许把目标架构模块写清楚；不允许把 future module 偷换成当前 runtime implementation。
2. 每个 Engine boundary 必须写明输入、输出、依赖方向、allowed source、forbidden source 和 validation anchors。
3. Paper / simulated / read-model-only evidence 不能升级成 live fact source。
4. Strategies / Trader 不能直连 ExecutionClient；必须经过 MessageBus、RiskEngine 和 ExecutionEngine boundary。
5. Workbench 只能消费 ReadModel / ViewModel；Live PRO Console 仍是独立 future surface。
6. L4 planning 前必须先完成 Engine Module Boundary Consolidation。
