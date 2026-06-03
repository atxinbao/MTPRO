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

  Trader/
    Accounts/
    Strategies/
      EMA/
        Lifecycle/
        Quoter/
        Hedger/
        Signals/
        Proposals/
      <future-strategy>/
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
- `Trader/Strategies` 中的具体 strategy definition 可依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio`、`RiskEngine` read-model inputs；不得依赖 `Trader/Coordination`、`ExecutionEngine` 或 `ExecutionClient`。
- `Trader` 可依赖 `DomainModel`、`MessageBus`、`Cache`、`Trader/Strategies`、`Portfolio`、`RiskEngine`、`ExecutionEngine`，但不得直连 `ExecutionClient`。
- `RiskEngine` 可依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio`，不得调用 broker / execution client。
- `ExecutionEngine` 可依赖 `DomainModel`、`MessageBus`、`Cache`、`RiskEngine`、`ExecutionClient` future gate；真实 `ExecutionClient` implementation 仍 forbidden。
- `Portfolio` 可依赖 `DomainModel`、`MessageBus`、`Cache`、`Database` projection，不得读取 broker account state。
- `Workbench` 只能依赖 read model / view model exports，不得读取 runtime object、adapter request、Database schema 或 broker payload。

## MTP-163 Fixed Layout / Dependency / Forbidden Path Contract

`MTP-163-FIXED-TARGET-SOURCE-MODULE-LAYOUT`

MTP-163 固定后续 issue 的唯一目标 source layout。后续迁移、namespace 收口、validation guard 和 stage closeout 只能引用下表中的目标目录，不得临时新增平行 Engine 目录，不得继续把 `Core / Adapters / Persistence / Runtime / App` 写成最终目标结构。

MTP-191 后续修正了本节的 Strategies 行：`Sources/Strategies/<strategy>/` 保留为 MTP-163 / MTP-171 / MTP-187 已完成事实和迁移期 compatibility evidence，不再是 forward-looking canonical path。MTP-191 之后的具体策略落点是 `Sources/Trader/Strategies/<strategy>/`。

| Target module | 固定目录 | 目录规则 |
| --- | --- | --- |
| DomainModel | `Sources/DomainModel/` | pure domain value object；不携带 adapter / persistence / UI 依赖。 |
| DataClient | `Sources/DataClient/<venue>/` | 一个交易所 / venue 一个目录；Binance 下区分 `PublicMarketData` 与 `FuturePrivateStreamGate`。 |
| DataEngine | `Sources/DataEngine/` | `Ingest`、`ScenarioReplay`、`DataQuality` 只服务 ingest / replay / quality boundary。 |
| MessageBus | `Sources/MessageBus/` | `Events`、`Commands`、`Requests`、`Replay` 只承载 facts / routing / replay invariant。 |
| Cache | `Sources/Cache/` | runtime-derived state；不负责 durability、schema ownership 或 DB adapter。 |
| Database | `Sources/Database/` | append-only event log、snapshots、SQLite / DuckDB projections 和 replay projection。 |
| Strategies | `Sources/Trader/Strategies/<strategy>/` | MTP-191 之后的 forward-looking canonical strategy path；旧 `Sources/Strategies/<strategy>/` 只作为 historical / compatibility / superseded path 和待迁移来源。 |
| Trader | `Sources/Trader/` | MTP-205 后 current active relationship 是 `Trader = Accounts + Strategies/EMA + Coordination`；`StrategyBindings` 只作为 historical / superseded context，不再是 active component。 |
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
- `Trader/Strategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine read-model inputs`；不能直连 Trader/Coordination、ExecutionEngine、ExecutionClient、broker 或 OMS。
- `Trader -> DomainModel / MessageBus / Cache / Trader/Strategies / Portfolio / RiskEngine / ExecutionEngine`；不能直连 ExecutionClient、broker command 或 account endpoint。
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

MTP-163 当时把 `DataClient/<venue>/` 和 `Strategies/<strategy>/` 固定为目录命名不变量。MTP-191 之后该 strategy rule 只作为历史 anchor 保留；后续不得把 venue-specific adapter 散落到 `DataEngine`、`Runtime` 或 `Workbench`，也不得把 strategy-specific lifecycle / quoter / hedger / proposal 逻辑散落到 `Trader/Coordination`、`Trader/StrategyBindings`、`ExecutionEngine` 或 `ExecutionClient`。

MTP-191 将 strategy directory rule 修正为 Trader-owned form：后续 canonical rule 是 `DataClient/<venue>/` 和 `Trader/Strategies/<strategy>/`。旧 `Strategies/<strategy>/` 只作为已完成迁移的历史/兼容路径；MTP-193 已将 EMA 迁入 Trader-owned path，MTP-194 已将 OrderBookImbalance 迁入 Trader-owned path。

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

## MTP-170 Adapter Capability and Data-source Guard Evidence

`MTP-170-ADAPTER-CAPABILITY-GUARD-CONTRACT`

MTP-170 将 adapter capability guard 固定为 DataClient / DataEngine 的 validation evidence：所有 adapter capability 必须先分类为 public market data、fixture replay、scenario replay、future-gated private source 或 forbidden capability。Capability guard 只做边界判定，不实现 endpoint、credential、transport、private stream runtime、broker adapter 或 ExecutionClient。

`MTP-170-FORBIDDEN-ENDPOINT-RUNTIME-COVERAGE`

Capability guard 必须覆盖 signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、broker adapter、exchange execution adapter、ExecutionClient、OMS、real order lifecycle、execution report、broker fill、reconciliation、account payload、broker payload 和 broker state。

`MTP-170-SOURCE-IDENTITY-LABELING-CONTRACT`

所有 DataClient / DataEngine source identity 必须带 source kind、venue、dataset / fixture version、replay window、freshness status、quality gate status 和 capability label。source identity 不包含 endpoint URL、API key、secret、signature、listenKey lease、private stream cursor、broker account id、account payload、broker payload 或 Runtime object。

`MTP-170-FIXTURE-PUBLIC-FUTURE-GATED-SOURCE-LABELS`

合法 source labels 只能是 `fixture-source`、`public-market-data-source`、`scenario-replay-source` 和 `future-gated-private-source-label`。future-gated private source 只是 label-only evidence；它不表示 current private stream、account snapshot runtime、secret storage、signed request、account endpoint read、listenKey lifecycle 或 broker sync。

`MTP-170-DATACLIENT-DATAENGINE-BOUNDARY-GUARD`

DataClient 只能提供 public market data capability 和 future-gated label；DataEngine 只能通过 ingest / replay / quality boundary 消费 public or fixture source 并 publish MessageBus facts / evidence。禁止 DataClient / DataEngine 通过 capability matrix 绕过 MessageBus、Cache、Database、ReadModel / ViewModel、RiskEngine 或 ExecutionEngine。

`MTP-170-NO-CREDENTIAL-SECRET-PRIVATE-NETWORK-TEST-GUARD`

自动验证不得依赖真实凭证、真实 Binance 私有接口、外部 account data、secret / credential / keychain storage、API key input、signed request fixture、listenKey fixture、private WebSocket fixture 或 broker payload fixture。所有 guard evidence 必须由本地 deterministic docs/checks 和 existing public / fixture tests 表达。

`MTP-170-ADAPTER-CAPABILITY-VALIDATION`

MTP-170 只证明 adapter capability and data-source guard anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不新增 endpoint implementation、不新增真实网络私有接口测试、不引入 secret / credential / keychain storage、不实现 signed/account/listenKey endpoint、private WebSocket runtime、account snapshot runtime、broker adapter、ExecutionClient、OMS、UI command surface、Graphify 或 Figma。

## MTP-171 Strategies Lifecycle and Proposal Boundary

`MTP-171-STRATEGIES-LIFECYCLE-PROPOSAL-BOUNDARY-CONTRACT`

MTP-171 当时将 `Sources/Strategies/<strategy>/` 固定为 strategy-scoped lifecycle、quoter / hedger、signals、paper/live-neutral proposals 和 read-model input boundary。MTP-191 之后该路径只作为 historical / compatibility / superseded evidence；forward-looking concrete strategy boundary 是 `Sources/Trader/Strategies/<strategy>/`。Trader-owned Strategies 可以消费 DomainModel、MessageBus、Cache、Portfolio 和 RiskEngine read-model inputs，并发布 signal / proposal / evidence facts；它不是 Trader coordination runtime、ExecutionEngine command path、ExecutionClient request layer、broker gateway 或 OMS。

`MTP-171-EMA-STRATEGY-DIRECTORY-EXAMPLE`

`Sources/Strategies/EMA/` 是 MTP-171 / MTP-187 历史 strategy directory 示例和 MTP-193 historical migration source。MTP-193 后，EMA 的 current canonical source path 是 `Sources/Trader/Strategies/EMA/`；`Lifecycle/`、`Quoter/`、`Hedger/`、`Signals/` 和 `Proposals/` 只表达 future target structure 和 validation labels，不表示已经实现 strategy runtime、scheduler、live quoter、live hedger、broker adapter、ExecutionClient 或 OMS。

`MTP-171-LIFECYCLE-QUOTER-HEDGER-SIGNALS-PROPOSALS-SPLIT`

Lifecycle 只描述 strategy readiness state、enabled / disabled / blocked / unavailable 等本地 evidence；Quoter 只描述 quote intent / market-side evaluation evidence；Hedger 只描述 hedge intent / exposure balancing evidence；Signals 只描述 deterministic signal facts；Proposals 只描述 paper/live-neutral proposal evidence。任何一层都不能输出 executable order command、broker command、ExecutionClient request、OMS order、real submit / cancel / replace 或 UI command payload。

`MTP-171-STRATEGY-READ-MODEL-INPUT-CONTRACT`

Strategy read-model input 只能来自 DomainModel、MessageBus facts、Cache read state、Portfolio projection 和 RiskEngine blocked / allowed evidence。Strategy 不能直接调用 DataEngine、Trader、ExecutionEngine、ExecutionClient、Workbench、Database schema、Adapter request、Runtime object、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime 或 broker state。

`MTP-171-NO-DIRECT-EXECUTIONCLIENT-PATH-GUARD`

禁止 `Strategies -> ExecutionClient`、`Strategies -> broker command`、`Strategies -> OMS`、`Strategies -> real order lifecycle`、`Strategies -> real submit / cancel / replace`、`Strategies -> execution report`、`Strategies -> broker fill`、`Strategies -> reconciliation`、`Strategies -> Live PRO Console command`、`Strategies -> trading button` 或 `Strategies -> order form`。Strategy proposal 必须继续保持 evidence-only / paper-live-neutral semantics，不能升级为 executable order command。

`MTP-171-NO-RUNTIME-SCHEDULER-LIVE-QUOTER-HEDGER-GUARD`

MTP-171 不实现 strategy runtime、scheduler、live quoter runtime、live hedger runtime、Trader runtime、ExecutionClient implementation、OMS implementation、broker adapter、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、secret / credential / keychain storage、Live PRO Console、trading button、live command 或 order form。

`MTP-171-STRATEGIES-BOUNDARY-VALIDATION`

MTP-171 只证明 Strategies lifecycle and proposal boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 strategy runtime / scheduler / live quoter / live hedger、不输出 broker command 或 executable order command、不运行 Graphify、不修改 Figma。

## MTP-172 Trader Coordination Boundary

`MTP-172-TRADER-COORDINATION-BOUNDARY-CONTRACT`

MTP-172 将 `Sources/Trader/` 固定为 strategy / account / risk / execution context 的 coordination boundary。Trader 可以协调 Strategies、Portfolio、RiskEngine 和 ExecutionEngine 的本地 evidence / read-model inputs，但它不是 live coordinator、OMS、broker gateway、ExecutionClient client wrapper、real account service、portfolio ledger 或 executable order command surface。

`MTP-172-ACCOUNTS-COORDINATION-STRATEGYBINDINGS-SPLIT`

`Sources/Trader/Accounts/` 只保存 account context、account identity、source identity 和 future real account gate label；`Sources/Trader/Coordination/` 只表达 strategy / risk / execution context ordering evidence；`Sources/Trader/StrategyBindings/` 只表达 strategy instance 与 Trader context 的 binding evidence。三者都不能拥有 cash、positions、PnL、margin、leverage、broker position、broker state、order form state 或 real account payload。

`MTP-172-STRATEGY-ACCOUNT-RISK-EXECUTION-CONTEXT-COORDINATION`

Trader coordination 只能把 strategy proposals、account context identity、Portfolio read model、RiskEngine evidence 和 ExecutionEngine paper / simulated lifecycle boundary 串成本地 decision context。该 context 不能绕过 MessageBus / Cache / ReadModel / ViewModel，不能直接调用 DataClient / DataEngine / Database schema，也不能产生 broker command、ExecutionClient request、OMS order、live command 或 UI command payload。

`MTP-172-TRADER-ACCOUNT-CONTEXT-IDENTITY-ONLY-GUARD`

Trader/Accounts 的 account context 只表达 account identity、source identity、simulated / paper / future-gated source label 和 readiness evidence。真实 cash、positions、PnL、exposure、margin、open value 和 paper projection 属于 Portfolio；真实 account source、account endpoint payload、listenKey state、broker position、broker account id、broker payload 和 broker state 仍 forbidden。

`MTP-172-NO-LIVE-COORDINATOR-OMS-BROKER-GATEWAY-GUARD`

禁止把 Trader 写成 live coordinator、OMS、broker gateway、broker session manager、private stream coordinator、account snapshot runtime、real account synchronizer、Live PRO Console backend、trading button handler、order form handler、emergency stop runtime、shutdown runtime 或 restore runtime。

`MTP-172-NO-DIRECT-EXECUTIONCLIENT-BROKER-COMMAND-PATH`

禁止 `Trader -> ExecutionClient`、`Trader -> broker command`、`Trader -> OMS`、`Trader -> real order lifecycle`、`Trader -> real submit / cancel / replace`、`Trader -> execution report`、`Trader -> broker fill`、`Trader -> reconciliation`、`Trader -> signed endpoint`、`Trader -> account endpoint / listenKey`、`Trader -> private WebSocket runtime`、`Trader -> order form` 或 `Trader -> live command`。

`MTP-172-TRADER-BOUNDARY-VALIDATION`

MTP-172 只证明 Trader coordination boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 Trader runtime、不实现 live coordinator / OMS / broker gateway、不读取真实 account / broker position、不运行 Graphify、不修改 Figma。

## MTP-191 Trader-owned Strategy Module Boundary Correction

`MTP-191-TRADER-OWNED-STRATEGY-CANONICAL-PATH`

MTP-191 将 forward-looking strategy landing path 从 `Sources/Strategies/<strategy>/` 修正为 `Sources/Trader/Strategies/<strategy>/`。`Sources/Strategies/<strategy>/`、`Sources/Strategies/EMA/` 和 `Sources/Strategies/OrderBookImbalance/` 只保留为 MTP-171 / MTP-183 / MTP-187 已完成事实、迁移期 compatibility envelope 和审计证据；MTP-191 之后不再把它们写成 canonical path。

`MTP-191-TRADER-CONTAINER-SPLIT`

`Sources/Trader/` 是 Trader-owned strategy context 的容器，包含 `Accounts/`、`Strategies/`、`Coordination/` 和 `StrategyBindings/`。`Sources/Trader/Strategies/<strategy>/` 承载具体 strategy definition / strategy instance readiness，包括 lifecycle、signals、paper/live-neutral proposals、quoter / hedger boundary 和 strategy-specific evidence。`Sources/Trader/Coordination/` 只协调 account context、strategy readiness、Portfolio、RiskEngine 和 ExecutionEngine evidence；不拥有具体 strategy implementation。

`MTP-191-STRATEGYBINDINGS-NON-LANDING-GUARD`

`Sources/Trader/StrategyBindings/` 只承载 generic binding protocol / coordination adapter contract，用于表达 strategy instance 与 Trader context、RiskEngine、Portfolio evidence 的连接关系。它不是 EMA、OrderBookImbalance 或未来具体策略的源码落点，不得包含 strategy lifecycle、signals、quoter / hedger、proposal implementation 或 strategy-specific business rules。

`MTP-191-INDEPENDENT-ENGINE-MODULES-GUARD`

Portfolio、RiskEngine、ExecutionEngine 和 ExecutionClient 仍是独立模块边界。Trader 可以消费它们的 read-model / evidence / future-gated context，但不能吸收 Portfolio financial state、RiskEngine decision ownership、ExecutionEngine lifecycle ownership、ExecutionClient broker capability、OMS、signed/account endpoint、private stream runtime 或 live command surface。

`MTP-191-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`

MTP-191 只定义 boundary correction 和 forward-looking canonical path，不移动 production source，不修改 `Package.swift` target graph，不创建 SwiftPM target，不实现 Strategy runtime、Trader runtime、live coordinator、broker gateway、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-191-BOUNDARY-CORRECTION-VALIDATION`

MTP-191 validation 必须证明 `Sources/Trader/Strategies/<strategy>/` 是新的 canonical path，`Sources/Strategies/<strategy>/` 只作为 compatibility / superseded / historical path 出现，`Sources/Trader/StrategyBindings/` 不作为具体策略实现落点，并且本 issue 没有移动 `Sources`、没有修改 `Package.swift`、没有写业务代码、没有运行 Graphify 或 Figma。

## MTP-192 Root Docs Strategy Path Anchor Correction

`MTP-192-ROOT-DOCS-STRATEGY-PATH-ANCHOR-CORRECTION`

MTP-192 将 root docs 中 forward-looking strategy path anchor 收口为 `Sources/Trader/Strategies/<strategy>/`。旧 `Sources/Strategies/<strategy>/`、`Sources/Strategies/EMA/` 和 `Sources/Strategies/OrderBookImbalance/` 只能作为 MTP-171 / MTP-183 / MTP-187 historical evidence、compatibility envelope、superseded path、MTP-193 historical migration source 或 MTP-194 historical migration source。

`MTP-192-HISTORICAL-STRATEGIES-COMPATIBILITY-NOTE`

历史 closure evidence、Stage Audit 和 prior issue evidence 中出现的 `Sources/Strategies/<strategy>/` 不做静默改写。需要继续保留历史事实时，必须配套说明该路径不是 MTP-191 之后的 canonical future layout。

`MTP-192-TRADER-CONTAINER-STRATEGYBINDINGS-ROOT-DOCS`

Root docs 中的 Trader container 表述必须使用 `Trader = Accounts + Strategies + StrategyBindings + Coordination`。`StrategyBindings` 只允许 generic binding protocol / coordination adapter contract，不允许写成 EMA、OrderBookImbalance 或未来具体 strategy implementation landing path。

`MTP-192-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`

MTP-192 只更新 root docs、architecture boundary、domain language、validation anchors 和 automation readiness anchors；不移动 production source，不修改 `Package.swift`，不拆 SwiftPM target graph，不实现 Strategy runtime、Trader runtime、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-192-ROOT-DOCS-ANCHOR-VALIDATION`

MTP-192 validation 必须证明 root docs 不再把 `Sources/Strategies/<strategy>` 写成 forward-looking canonical strategy layout；所有允许保留的旧路径都必须是 historical / compatibility / superseded / migration-source 语义。

## MTP-193 EMA Trader Strategy Physical Migration

`MTP-193-EMA-TRADER-STRATEGIES-PHYSICAL-MIGRATION`

MTP-193 将 EMA strategy lifecycle、shared strategy signal 和 paper/live-neutral proposal source 从 MTP-187 的 superseded `Sources/Strategies/EMA/` 迁入 Trader-owned canonical path `Sources/Trader/Strategies/EMA/`。该迁移只改变 EMA concrete strategy physical placement，不改变 signal semantics、proposal authorization、paper-only boundary、test fixture 或 public API import surface。

`MTP-193-EMA-OLD-PATH-REMOVAL-GUARD`

MTP-193 后 `Sources/Strategies/EMA/` 不再保留 production source。Root docs 中如继续出现 `Sources/Strategies/EMA/`，只能作为 MTP-171 / MTP-187 historical evidence、superseded path 或 migration-source 语义，不得再表达当前 EMA implementation location。

`MTP-193-CORE-COMPATIBILITY-ENVELOPE-SOURCE-PATH`

MTP-193 保留现有 `Core` SwiftPM product / target 名称作为 compatibility envelope，但 `Package.swift` 的 EMA source root 必须从 `"Strategies/EMA"` 更新为 `"Trader/Strategies/EMA"`。该变更不新增 SwiftPM target、product 或 dependency，不做 target graph split；MTP-201 后 OrderBookImbalance 只通过 `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` 作为 historical research evidence 编译。

`MTP-193-BEHAVIOR-UNCHANGED-GUARD`

EMA strategy contract、strategy signal、paper proposal、proposal authorization、deterministic fixtures 和 paper-only no-executable-order boundary 必须保持行为不变。MTP-193 不允许引入 Strategy runtime、scheduler、live quoter、live hedger、Trader runtime、broker adapter、ExecutionClient、OMS、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-193-NO-RUNTIME-TARGET-GRAPH-GUARD`

MTP-193 只迁移 EMA source path、更新 docs / validation anchors 和 automation readiness checks。它不创建 `Strategies` 或 `Trader` SwiftPM target，不实现 runtime object exposure，不把 proposal 升级为 executable order command，不迁移 OrderBookImbalance、StrategyBindings、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard。

`MTP-193-EMA-PATH-MIGRATION-VALIDATION`

MTP-193 validation 必须证明 `Sources/Trader/Strategies/EMA/` 包含 `EMACross.swift`、`StrategySignals.swift` 和 `PaperActionProposal.swift`，`Sources/Strategies/EMA/` 已不存在，`Package.swift` 使用 `"Trader/Strategies/EMA"` 且不再包含 `"Strategies/EMA"`，focused EMA / proposal tests 与完整 `bash checks/run.sh` 仍通过。

## MTP-194 OrderBookImbalance Trader Strategy Physical Migration

`MTP-194-ORDERBOOKIMBALANCE-TRADER-STRATEGIES-PHYSICAL-MIGRATION`

MTP-194 将 OrderBookImbalance research strategy source 从 MTP-187 的 superseded `Sources/Strategies/OrderBookImbalance/` 迁入当时的 Trader-owned path `Sources/Trader/Strategies/OrderBookImbalance/`。MTP-201 已退休该 non-EMA active strategy source root，并把保留的 research / parity / persistence evidence 迁入 `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift`；该退休不改变 imbalance calculation、research bias semantics、input source evidence、tests 或 public API import surface。

`MTP-194-ORDERBOOKIMBALANCE-OLD-PATH-REMOVAL-GUARD`

MTP-194 后 `Sources/Strategies/OrderBookImbalance/` 不再保留 production source。Root docs 中如继续出现 `Sources/Strategies/OrderBookImbalance/`，只能作为 MTP-183 / MTP-187 historical evidence、superseded path 或 migration-source 语义，不得再表达当前 OrderBookImbalance implementation location。

`MTP-194-CORE-COMPATIBILITY-ENVELOPE-SOURCE-PATH`

MTP-201 保留现有 `Core` SwiftPM product / target 名称作为 compatibility envelope，但 `Package.swift` 不再包含 `"Trader/Strategies/OrderBookImbalance"`。OrderBookImbalance research evidence 由 `Core` source root 下的 `Sources/Core/Research/` 编译，不新增 SwiftPM target、product 或 dependency，不做 target graph split。

`MTP-194-BEHAVIOR-UNCHANGED-GUARD`

OrderBookImbalance strategy contract、configuration validation、signal sample、bias calculation、snapshot / delta input-source evidence 和 research-only boundary 必须保持行为不变。Ask dominance 仍只是 research bias，不授权 short、margin、futures、ExecutionClient request、OMS order、broker order、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-194-NO-RUNTIME-TARGET-GRAPH-GUARD`

MTP-194 只迁移 OrderBookImbalance source path、更新 docs / validation anchors 和 automation readiness checks。它不创建 `Strategies` 或 `Trader` SwiftPM target，不实现 runtime object exposure，不迁移 StrategyBindings、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard，不把 research signal 升级为 executable order command。

`MTP-194-ORDERBOOKIMBALANCE-PATH-MIGRATION-VALIDATION`

MTP-201 validation 必须证明 `Sources/Trader/Strategies/OrderBookImbalance/` 已不存在，`Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` 存在，`Package.swift` 不包含 `"Trader/Strategies/OrderBookImbalance"` 或 `"Strategies/OrderBookImbalance"`，focused OrderBookImbalance tests 与完整 `bash checks/run.sh` 仍通过。

## MTP-195 StrategyBindings Binding Protocol / Coordination Adapter

`MTP-195-STRATEGYBINDINGS-BINDING-PROTOCOL-ADAPTER-CONTRACT`

MTP-195 将 `Sources/Trader/StrategyBindings/` 收口为 generic binding protocol / coordination adapter contract。该目录只能表达 strategy instance 与 Trader context / RiskEngine / Portfolio evidence 的通用连接协议和本地 coordination adapter，不是 EMA、OrderBookImbalance 或未来具体 strategy implementation landing path。

`MTP-195-CONCRETE-STRATEGY-NON-LANDING-GUARD`

具体策略 lifecycle、signals、proposals、quoter、hedger 和 strategy-specific business rules 必须继续位于 `Sources/Trader/Strategies/<strategy>/`。当前 active concrete strategy source root 只有 `Sources/Trader/Strategies/EMA/`；OrderBookImbalance 只保留为 `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` historical research evidence；`Sources/Trader/StrategyBindings/` 不得承载具体策略实现。

`MTP-195-STRATEGYBINDINGS-COMPATIBILITY-ENVELOPE`

MTP-195 保留现有 `Core` SwiftPM product / target 名称作为 compatibility envelope，当时继续编译 `Sources/Trader/StrategyBindings/PaperActionRiskLink.swift`。MTP-202 后该 file 已迁入 `Sources/Trader/Coordination/RiskBinding/PaperActionRiskLink.swift`，仍由 `Core` compatibility envelope 编译；不新增 SwiftPM target、product 或 dependency，不做 target graph split，也不创建 Trader runtime。

`MTP-195-NO-DIRECT-EXECUTION-BROKER-OMS-LIVE-GUARD`

StrategyBindings 中的 binding / adapter contract 不得直连 ExecutionClient、broker command、OMS command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command、order form 或 executable order command。`PaperActionRiskLink` 只能把 paper proposal 转成本地 risk query / blocker evidence，不能变成真实风控、broker fallback 或订单执行入口。

`MTP-195-STRATEGYBINDINGS-BOUNDARY-VALIDATION`

MTP-195 / MTP-201 validation 历史上证明 `TraderStrategyBindingsBoundaryEvidence` 固定 `Sources/Trader/StrategyBindings/` 的 generic binding protocol / coordination adapter role。MTP-202 后当前验证必须证明 `TraderCoordinationRiskBindingBoundaryEvidence` 固定 `Sources/Trader/Coordination/RiskBinding/` 的 coordination adapter role，旧 `Sources/Trader/StrategyBindings/` active root 不得回流。

## MTP-196 Trader-owned Strategy Path Validation

`MTP-196-TRADER-OWNED-STRATEGY-PATH-VALIDATION`

MTP-202 后 Trader-owned strategy path validation 必须直接检查 EMA 当前 source files 位于 `Sources/Trader/Strategies/EMA/`，并确认 OrderBookImbalance active source root 已退休、`Package.swift` 只保留 `"Trader/Strategies/EMA"` 和 `"Trader/Coordination/RiskBinding"` 相关 current source roots。

`MTP-196-SUPERSEDED-STRATEGIES-PATH-NON-CANONICAL-GUARD`

MTP-196 validation 必须在旧 `Sources/Strategies/EMA/` 或 `Sources/Strategies/OrderBookImbalance/` 作为当前 implementation directory 回流时失败。Root docs 中允许保留旧路径时，只能是 historical / compatibility / superseded / migration-source 语义，不得恢复为 canonical future path。

`MTP-196-STRATEGYBINDINGS-NON-CONCRETE-STRATEGY-VALIDATION`

MTP-202 validation 必须继续检查旧 `Sources/Trader/StrategyBindings/` 不再作为 first-level active source root，并检查 `Sources/Trader/Coordination/RiskBinding/` 只包含 generic binding protocol / coordination adapter evidence。`TraderCoordinationRiskBindingBoundaryEvidence` 是该检查的 local fixture，不允许把 EMA、OrderBookImbalance 或未来具体 strategy implementation 放入 RiskBinding。

`MTP-196-NO-DIRECT-EXECUTION-PATH-VALIDATION`

MTP-196 validation 必须覆盖 no direct ExecutionClient / broker / OMS / signed endpoint / real order lifecycle / Live PRO Console / trading button / live command path。该检查只证明 forbidden path guard 存在，不实现 Strategy runtime、Trader runtime、ExecutionClient、OMS、broker gateway 或 live command surface。

`MTP-196-VALIDATION-ONLY-GUARD`

MTP-201 只执行 non-EMA active source retirement、docs anchors 和 automation readiness checks；不新增 SwiftPM target、product 或 dependency，不做 target graph split。

## MTP-198 EMA-only Trader Strategy Layout Contract

`MTP-198-EMA-ONLY-TRADER-STRATEGY-LAYOUT-CONTRACT`

MTP-198 将当前 active concrete strategy 收口为 `EMA`。当前唯一 canonical active concrete strategy path 是 `Sources/Trader/Strategies/EMA/`；该目录承载 EMA lifecycle、signals、paper/live-neutral proposals 和 strategy-specific evidence。MTP-198 不移动 source，不修改 `Package.swift`，只修正当前策略规划和管理口径。

`MTP-198-CANONICAL-ACTIVE-EMA-PATH`

`Sources/Trader/Strategies/EMA/` 是当前唯一 active strategy source root。MTP-193 已完成 EMA physical migration，MTP-198 在该事实之上固定“当前 active strategy 只有 EMA”的架构口径，避免把 future candidate、research evidence 或 compatibility debt 误写成 active strategy。

`MTP-198-NON-EMA-FUTURE-CANDIDATE-BOUNDARY`

`RSI`、`OrderBookImbalance`、`Momentum` 和 `MeanReversion` 只能作为 future strategy candidate / future-gated strategy label。MTP-201 已退休 `Sources/Trader/Strategies/OrderBookImbalance/` active source root；当前不得再写成 active concrete strategy。保留的 OrderBookImbalance 类型只位于 `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift`，用于 historical research / parity / persistence evidence。

`MTP-198-STRATEGYBINDINGS-NOT-FIRST-LEVEL-STRATEGY-DIRECTORY`

MTP-202 后 `Sources/Trader/StrategyBindings/` 已从 current active source root 退休。`Sources/Trader/Coordination/RiskBinding/` 是当前 binding / adapter semantics source root，但它不是 concrete strategy implementation landing path，也不是 EMA、RSI、OrderBookImbalance、Momentum 或 MeanReversion 的源码落点。

`MTP-198-TRADER-COORDINATION-BINDING-RESPONSIBILITY`

Binding / adapter semantics 归 `Sources/Trader/Coordination/` 责任边界管理。需要连接 strategy instance、account context、RiskEngine、Portfolio evidence 或 ExecutionEngine evidence 时，应由 `Trader/Coordination/<binding>/` 这类 coordination boundary 表达；MTP-202 当前使用 `Sources/Trader/Coordination/RiskBinding/`，但不实现 runtime。

`MTP-198-FORBIDDEN-STRATEGY-PATH-EXECUTION-BYPASS-TAXONOMY`

禁止 `Strategy -> ExecutionClient`、`Strategy -> broker command`、`Strategy -> OMS`、`Strategy -> executable order command`、`Strategy -> signed endpoint`、`Strategy -> account endpoint / listenKey`、`Strategy -> private WebSocket runtime`、`Strategy -> Live PRO Console`、`Strategy -> trading button`、`Strategy -> live command`、`Strategy -> order form`、`StrategyBindings -> concrete strategy`、`StrategyBindings -> ExecutionClient`、`StrategyBindings -> broker command` 和 `StrategyBindings -> OMS`。Paper proposal、signal、risk decision 和 portfolio projection 只能作为 deterministic local evidence。

`MTP-198-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`

MTP-201 只执行已授权的 non-EMA active source retirement；MTP-202 只执行 StrategyBindings -> Trader Coordination RiskBinding reclassification。不新增 SwiftPM target、product 或 dependency，不拆 target graph，不实现 Strategy runtime、Trader runtime、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

## MTP-202 Trader Coordination RiskBinding Boundary

`MTP-202-TRADER-COORDINATION-RISKBINDING-SOURCE-RECLASSIFICATION`

MTP-202 将 proposal-to-risk binding 从旧 `Sources/Trader/StrategyBindings/PaperActionRiskLink.swift` 迁入 `Sources/Trader/Coordination/RiskBinding/PaperActionRiskLink.swift`。该路径只表达 strategy proposal、risk query、risk blocker 和 portfolio / execution evidence 之间的 deterministic local coordination adapter，不是 concrete strategy source root。

`MTP-202-STRATEGYBINDINGS-FIRST-LEVEL-PATH-RETIREMENT`

`Sources/Trader/StrategyBindings/` 不再是 current active source root，`Package.swift` 不再包含 `"Trader/StrategyBindings"` source root。Root docs 可以在 MTP-187 / MTP-195 historical context 中提及旧路径，但不得把它写成当前或 forward-looking binding source root。

`MTP-202-RISKBINDING-NO-EXECUTION-GATEWAY-GUARD`

`Trader/Coordination/RiskBinding` 不得直连 ExecutionClient、broker command、OMS command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command、order form 或 executable order command。`PaperActionRiskLink` 只能把 paper proposal 转成本地 risk query / blocker evidence，不能变成真实风控、broker fallback 或订单执行入口。

`MTP-202-RISKBINDING-VALIDATION`

MTP-202 validation 必须证明 `TraderCoordinationRiskBindingBoundaryEvidence`、focused XCTest、Package.swift source roots、automation readiness 和完整 `bash checks/run.sh` 一致覆盖：RiskBinding 只是 generic binding protocol / coordination adapter，concrete strategies remain Trader-owned，且无 direct execution / broker / OMS / live command path。

## MTP-203 EMA-only Strategy Path Validation

`MTP-203-EMA-ONLY-ACTIVE-STRATEGY-DIRECTORY-GUARD`

MTP-203 validation 必须把 `Sources/Trader/Strategies/` 的 current active concrete strategy directory set 固定为 only `EMA`。`Sources/Trader/Strategies/EMA/` 是唯一 active source root；`RSI`、`OrderBookImbalance`、`Momentum` 和 `MeanReversion` 只能作为 future candidate、historical evidence 或 Core research evidence，不得作为 active strategy directory 回流。

`MTP-203-NON-EMA-ACTIVE-SOURCE-TEST-PACKAGE-DRIFT-GUARD`

MTP-203 validation 必须机械阻断 non-EMA active source / active test root / `Package.swift` source root drift：`Sources/Trader/Strategies/<non-EMA>/`、`Sources/Strategies/<non-EMA>/`、`Tests/Trader/Strategies/<non-EMA>/`、`Tests/Strategies/<non-EMA>/` 和 `"Trader/Strategies/<non-EMA>"` 均不得回流。OrderBookImbalance 只能保留在 `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` 和 research validation context。

`MTP-203-STRATEGYBINDINGS-FIRST-LEVEL-DRIFT-GUARD`

MTP-203 validation 必须继续阻断旧 `Sources/Trader/StrategyBindings/` first-level root 和 `"Trader/StrategyBindings"` package root 回流。Binding semantics 的唯一 active source root 是 `Sources/Trader/Coordination/RiskBinding/`，并且只表达 generic binding protocol / coordination adapter contract。

`MTP-203-EMA-ONLY-PATH-VALIDATION`

MTP-203 validation 必须由 `testEMAOnlyActiveStrategyPathValidationRejectsNonEMAAndBindingDrift`、automation readiness 和完整 `bash checks/run.sh` 共同覆盖。该 validation-only issue 不移动 production source，不新增 SwiftPM target、product 或 dependency，不拆 target graph，不实现 Strategy runtime、Trader runtime、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

## MTP-204 Trader EMA Strategy Layout Stage Closeout

`MTP-204-TRADER-EMA-LAYOUT-STAGE-CLOSEOUT`

MTP-204 将 `MTPRO Trader EMA Strategy Layout Consolidation v1` 的 MTP-198 至 MTP-203 evidence chain 收口为 stage audit input material。该 closeout 只为 Parent Codex 后续 Stage Code Audit Report 提供输入，不设置 Linear Project `Completed`，不输出最终 Stage Code Audit Report，不授权下一阶段。

`MTP-204-STAGE-AUDIT-INPUT-MATERIAL`

Stage audit input material 位于 `docs/audit/inputs/mtpro-trader-ema-strategy-layout-consolidation-v1-stage-audit-input.md`，必须汇总 EMA-only active layout、non-EMA future candidate / historical evidence、OrderBookImbalance Core research evidence、Trader Coordination RiskBinding boundary、deterministic path validation、validation matrix、automation readiness、compatibility envelope、forbidden implementation audit、unresolved future gates 和 Root Docs Delta input。

`MTP-204-NO-FINAL-STAGE-CODE-AUDIT`

MTP-204 不输出最终 Stage Code Audit Report，不设置 Project Completed，不创建下一 Project / Issue，不推进下一阶段 Todo，不运行 Graphify，不修改 Figma，不启动 Symphony 或 `symphony-issue`。最终 Stage Code Audit Report 必须等待 MTP-198 至 MTP-204 全部 Done，并由 Parent Codex 单独处理 Project closure。

`MTP-204-COMPATIBILITY-ENVELOPE-CLOSEOUT`

MTP-204 closeout 必须明确 `Core` 仍是 compatibility envelope：它继续编译 `Sources/Trader/Strategies/EMA/`、`Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` 和 `Sources/Trader/Coordination/RiskBinding/`，但这不等于 SwiftPM target graph split 完成，也不等于 Strategy runtime 或 Trader runtime 已实现。

`MTP-204-STAGE-CLOSEOUT-VALIDATION`

MTP-204 validation 必须证明 stage audit input material、validation matrix、automation readiness anchors、compatibility envelope closeout 和 forbidden implementation audit 已落仓，并且 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 通过。

`MTP-198-EMA-ONLY-LAYOUT-VALIDATION`

MTP-198 validation 必须证明 EMA-only Trader strategy layout anchors 已落仓，active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`，non-EMA strategy names only future candidate / future-gated label，并且 `bash checks/run.sh` 通过。

## MTP-205 Trader Accounts / Coordination Compatibility Contract

`MTP-205-TRADER-ACCOUNTS-COORDINATION-COMPATIBILITY-CONTRACT`

MTP-205 将 Trader container 的 current active relationship 固定为 `Trader = Accounts + Strategies/EMA + Coordination`。该 contract 只表达当前 source layout / docs / validation 口径，不授权 Trader runtime、strategy scheduler、live coordinator、account session runtime、ExecutionClient、OMS、broker gateway 或 live command。

`MTP-205-TRADER-CONTAINER-AUTHORITATIVE-RELATIONSHIP`

当前 contract Trader component set 是 `Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Coordination/RiskBinding/`。旧 `Trader = Accounts + Strategies + StrategyBindings + Coordination` 只能作为 historical evidence 保留；current / active / forward-looking wording 必须使用 `Trader = Accounts + Strategies/EMA + Coordination`。

`MTP-205-TRADER-ACCOUNTS-IDENTITY-SOURCE-FUTURE-GATE`

`Sources/Trader/Accounts/` 只表达 account identity、source identity 和 future real account gate，不拥有 cash、positions、PnL、exposure、margin、leverage、buying power、real account payload、account endpoint payload、listenKey state 或 private stream runtime state。Portfolio financial state 继续属于 `Sources/Portfolio/`。

`MTP-205-EMA-ONLY-STRATEGY-CURRENT-ACTIVE-GUARD`

当前 active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`。非 EMA strategy 名称只能作为 future candidate、future-gated label、historical evidence 或 compatibility debt 出现，不得写成 execution-ready strategy、Package.swift active source root、ExecutionClient request、OMS command、broker order、trading button 或 order form input。

`MTP-205-RISKBINDING-COORDINATION-BOUNDARY`

`Sources/Trader/Coordination/RiskBinding/` 只表达 proposal / risk / portfolio / execution evidence 的 local coordination adapter contract。它不是 concrete strategy implementation landing path，也不得成为 ExecutionClient gateway、broker gateway、OMS gateway、executable order command、live command 或 real order lifecycle shortcut。

`MTP-205-STRATEGYBINDINGS-SOURCES-STRATEGIES-RETIRED-ACTIVE-PATHS`

`Sources/Trader/StrategyBindings/` 不再是 current active source root、first-level Trader strategy directory 或 active binding implementation path。`Sources/Strategies/` 不再是 current active strategy source path。两者只能作为 historical / compatibility / superseded / migration-source context 出现，不得写回 canonical active layout。

`MTP-205-PACKAGE-COMPATIBILITY-ENVELOPE-CLEANUP-ENTRY`

MTP-205 不修改 `Package.swift`，只把 stale `Strategies` compatibility excludes 作为 MTP-209 cleanup input。后续 cleanup 必须保持 `Core` compatibility envelope buildability，不新增 SwiftPM target、product 或 dependency，不做 target graph split。

`MTP-205-FORBIDDEN-CAPABILITY-TAXONOMY`

MTP-205 禁止 Strategy runtime、Trader runtime、Live runtime、live coordinator、broker gateway、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、broker position sync、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、runtime object exposure、adapter request exposure、database schema exposure 和 credential / secret / keychain storage。

`MTP-205-TRADER-ACCOUNTS-COORDINATION-COMPATIBILITY-VALIDATION`

MTP-205 validation 必须证明 Trader Accounts / Coordination compatibility contract、planning record、module-boundary docs、domain context、validation plan、validation matrix、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` 均包含 MTP-205 anchors，并且 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 通过。

## MTP-206 Trader Accounts Source Boundary

`MTP-206-TRADER-ACCOUNTS-SOURCE-BOUNDARY`

MTP-206 将 `Sources/Trader/Accounts/` 落成当前 Trader container 的 account context source boundary，并通过 `TraderAccountContext` 固定 account identity、source identity、source kind 和 future real account gate。该 source 仍由 `Core` compatibility envelope 编译，不新增 SwiftPM target、product 或 dependency，不做 target graph split。

`MTP-206-ACCOUNT-IDENTITY-SOURCE-FUTURE-GATE`

`TraderAccountContext` 只表达 identity / source / gate。`futureRealAccountGate` 当前只能是 unavailable / requires Human planning 语义，不能授权真实账户读取、signed endpoint、account endpoint、listenKey、private WebSocket runtime、account snapshot runtime、broker gateway、ExecutionClient 或 OMS。

`MTP-206-NO-FINANCIAL-STATE-OWNERSHIP`

`Sources/Trader/Accounts/` 不拥有 cash、positions、PnL、margin、leverage、buying power、broker position、broker account state、account endpoint payload 或 broker payload。Portfolio 继续作为 financial state 权威边界；RiskEngine 和 ExecutionEngine 只消费本地 proposal / risk / paper / simulated evidence。

`MTP-206-NO-ENDPOINT-LISTENKEY-BROKER-RUNTIME`

`Sources/Trader/Accounts/` 不允许 signed endpoint、account endpoint、listenKey、private WebSocket runtime、account snapshot runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker gateway、live command、trading button 或 order form。

`MTP-206-PORTFOLIO-RISK-EXECUTION-RELATIONSHIP`

Trader/Accounts 与 Portfolio、RiskEngine、ExecutionEngine 的关系只允许 read-model / local evidence / coordination context，不允许 direct ExecutionClient path、broker command path、OMS command path、live command path 或 order form path。

`MTP-206-TRADER-ACCOUNTS-BOUNDARY-VALIDATION`

MTP-206 validation 必须证明 `Sources/Trader/Accounts/TraderAccountContext.swift`、`Package.swift` 的 `"Trader/Accounts"` source root、`Tests/CoreTests/CoreTests.swift` 的 `testMTP206TraderAccountContext...` focused tests、automation readiness、validation plan、validation matrix 和 latest verification summary 均覆盖 Accounts source boundary；并且 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 通过。

## MTP-207 Trader Account Context Validation Wiring

`MTP-207-TRADER-ACCOUNT-CONTEXT-VALIDATION-WIRING`

MTP-207 将 `TraderAccountContext` evidence 接入 deterministic validation wiring，覆盖 `Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Coordination/RiskBinding/` 三件套。该 validation 只证明当前 Trader container boundary 完整，不授权 Trader runtime、Strategy runtime、Live runtime 或 L4 implementation。

`MTP-207-ACCOUNTS-EMA-RISKBINDING-COVERAGE`

MTP-207 focused tests 必须同时检查 `"Trader/Accounts"`、`"Trader/Strategies/EMA"` 和 `"Trader/Coordination/RiskBinding"` 仍在 `Core` compatibility envelope sources 内，并确认旧 `"Trader/StrategyBindings"` 和 `"Strategies/EMA"` 不回流为 active source root。

`MTP-207-BROKER-PAYLOAD-LISTENKEY-BYPASS-GUARD`

MTP-207 validation 必须证明 account context 初始化和 Codable decode 都拒绝 broker/account payload、listenKey、signed/account endpoint、ExecutionClient、OMS、broker gateway、Trader runtime、Live runtime 和 private WebSocket runtime bypass。

`MTP-207-VALIDATION-ONLY-NO-RUNTIME-GUARD`

MTP-207 不新增 production runtime、不修改 SwiftPM target graph、不新增 SwiftPM target/product/dependency、不读取真实账户、不接 signed endpoint、account endpoint / listenKey、不实现 ExecutionClient、OMS、broker gateway、Live PRO Console、trading button、live command 或 order form。

`MTP-207-TRADER-ACCOUNT-CONTEXT-VALIDATION`

MTP-207 validation 必须证明 `testMTP207TraderAccountContextValidationAnchorsCoverAccountsEMAAndRiskBinding`、`testMTP207TraderAccountContextValidationRejectsBrokerPayloadListenKeyAndRuntimeDrift`、automation readiness、validation plan、validation matrix 和 latest verification summary 均覆盖 account context evidence wiring；并且 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 通过。

## MTP-208 Root Docs StrategyBindings Wording Retirement

`MTP-208-STRATEGYBINDINGS-ACTIVE-WORDING-RETIREMENT`

MTP-208 后，root / high-weight docs 中 retained `StrategyBindings` wording 只能表示 historical / compatibility / superseded evidence，不得再表达 current active source path、Trader 下一级策略目录、concrete strategy implementation landing path 或 strategy-to-execution shortcut。

`MTP-208-TRADER-COORDINATION-RISKBINDING-CURRENT-LOCATION`

Current binding / adapter location 必须写为 `Sources/Trader/Coordination/RiskBinding/`。RiskBinding 只表达 local coordination adapter contract，不直连 ExecutionClient、OMS、broker gateway、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-208-EMA-ONLY-ACTIVE-STRATEGY-DOC-GUARD`

Current active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`。非 EMA strategy 和旧 `Sources/Strategies/<strategy>` 只能作为 future candidate、historical evidence、compatibility debt 或 superseded context。

`MTP-208-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`

MTP-208 只收口 docs wording，不移动 production source，不修改 `Package.swift`，不新增 SwiftPM target/product/dependency，不做 target graph split，不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker gateway、Live PRO Console、trading button、live command 或 order form。

`MTP-208-ROOT-DOCS-WORDING-VALIDATION`

MTP-208 validation 必须证明 root/high-weight docs 不再把 `StrategyBindings` 写成 active source path；automation readiness、validation plan、validation matrix 和 latest verification summary 必须覆盖该 wording retirement，并且 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 通过。

## MTP-209 Package Stale Strategies Compatibility Exclude Cleanup

`MTP-209-PACKAGE-STALE-STRATEGIES-EXCLUDE-CLEANUP`

MTP-209 只清理 `Package.swift` 中 Runtime / App target exclude list 里的 stale peer-level `Strategies` entry。该 entry 指向已退休的 `Sources/Strategies/` active root；MTP-193 / MTP-201 / MTP-202 / MTP-205 后 current active Trader container 已收口为 `Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Coordination/RiskBinding/`。

`MTP-209-COMPATIBILITY-ENVELOPE-TARGET-GRAPH-PRESERVATION`

`Core` 继续作为 compatibility envelope 编译 `"Trader/Accounts"`、`"Trader/Strategies/EMA"` 和 `"Trader/Coordination/RiskBinding"`。MTP-209 不新增、不删除、不重命名 SwiftPM product / target / dependency，不把 `Strategies` 或 `Trader` 拆成独立 SwiftPM target，不改变 source import surface。

`MTP-209-NO-ACTIVE-SOURCES-STRATEGIES-GUARD`

`Sources/Strategies/` 不得作为 active source directory、Package source root 或 exclude root 回流。Root docs 中 retained `Sources/Strategies/<strategy>` 只能作为 historical / compatibility / superseded / migration-source evidence；current active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`。

`MTP-209-NO-RUNTIME-LIVE-BROKER-L4-GUARD`

MTP-209 不移动 production source，不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

`MTP-209-PACKAGE-CLEANUP-VALIDATION`

MTP-209 validation 必须证明 `Package.swift` 不再包含 stale peer-level `"Strategies"` exclude entry，`Sources/Strategies/` 目录不存在，`Package.swift` 仍保留 `"Trader/Accounts"`、`"Trader/Strategies/EMA"` 和 `"Trader/Coordination/RiskBinding"` source roots，并且 `swift package describe` 不再输出 `Sources/Strategies` invalid exclude warning；同时 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 必须通过。

## MTP-210 Trader Container Completeness Validation

`MTP-210-TRADER-CONTAINER-COMPLETENESS-VALIDATION`

MTP-210 将 current Trader container completeness 固定为 deterministic validation：`Sources/Trader/` 下当前只允许 `Accounts/`、`Strategies/` 和 `Coordination/` 三类目录。该 validation 只证明 source layout / package / fixtures 一致，不授权 Trader runtime、strategy scheduler、account session runtime、live coordinator、ExecutionClient、OMS、broker gateway 或 live command。

`MTP-210-ACCOUNTS-EMA-RISKBINDING-ONLY-COVERAGE`

当前 Trader container completeness 必须覆盖 `Sources/Trader/Accounts/TraderAccountContext.swift`、`Sources/Trader/Strategies/EMA/EMACross.swift`、`Sources/Trader/Strategies/EMA/StrategySignals.swift`、`Sources/Trader/Strategies/EMA/PaperActionProposal.swift` 和 `Sources/Trader/Coordination/RiskBinding/PaperActionRiskLink.swift`。`Sources/Trader/Strategies/` 的 active concrete strategy directory set 必须等于 only `EMA`。

`MTP-210-RETIRED-PATH-DRIFT-BLOCK`

`Sources/Trader/StrategyBindings/`、peer-level `Sources/Strategies/`、`Tests/Trader/StrategyBindings/` 和 `Tests/Strategies/` 不得作为 active source / test root 回流。`Package.swift` 不得恢复 stale peer-level `"Strategies"` exclude、`"Trader/StrategyBindings"` source root、non-EMA strategy source root、`Strategies` target 或 `Trader` target。

`MTP-210-NO-TARGET-GRAPH-RUNTIME-LIVE-GUARD`

MTP-210 不新增 SwiftPM target/product/dependency，不做 target graph split，不移动 production source，不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

`MTP-210-TRADER-COMPLETENESS-VALIDATION`

MTP-210 validation 必须证明 focused XCTest `testMTP210TraderContainerCompletenessValidationLocksAccountsEMAAndRiskBindingOnly`、automation readiness、validation plan、validation matrix 和 latest verification summary 均覆盖 Trader container completeness；并且 `git diff --check`、`swift test --filter CoreTests/testMTP210`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 必须通过。

## MTP-211 Trader Accounts / Coordination Stage Closeout

`MTP-211-TRADER-ACCOUNTS-COORDINATION-STAGE-CLOSEOUT`

MTP-211 只收口 `MTPRO Trader Accounts / Coordination Compatibility Consolidation v1` 的 stage audit input material，汇总 MTP-205 至 MTP-210 的 issue / PR / merge / required check evidence、Trader container compatibility closeout、validation matrix closeout、compatibility envelope closeout、forbidden implementation audit、Root Docs Delta input 和 Parent Codex Stage Code Audit handoff checklist。

`MTP-211-STAGE-AUDIT-INPUT-MATERIAL`

Stage audit input material 位于 `docs/audit/inputs/mtpro-trader-accounts-coordination-compatibility-consolidation-v1-stage-audit-input.md`，必须汇总 `Trader = Accounts + Strategies/EMA + Coordination`、`Sources/Trader/Accounts/` account context、EMA-only active strategy、`Sources/Trader/Coordination/RiskBinding/` coordination adapter、retired `Sources/Trader/StrategyBindings/` 和 peer-level `Sources/Strategies/` treatment、Package stale exclude cleanup、validation matrix、automation readiness、compatibility envelope、forbidden implementation audit 和 Root Docs Delta input。

`MTP-211-NO-FINAL-STAGE-CODE-AUDIT`

MTP-211 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段，不启动新的 `@002 / PAR`、Symphony 或 `symphony-issue`。最终 Stage Code Audit Report 必须由 Parent Codex 在 MTP-205 至 MTP-211 全部 Done 且 Linear Project `Completed/type=completed/completedAt` 后单独输出。

`MTP-211-TRADER-CONTAINER-COMPATIBILITY-CLOSEOUT`

MTP-211 closeout 必须确认当前 Trader compatibility container 是 `Accounts + Strategies/EMA + Coordination`：Accounts 只表达 account identity / source / future gate；EMA 是唯一 active concrete strategy；RiskBinding 只表达 local coordination adapter；旧 StrategyBindings 和 peer-level Sources/Strategies 只能作为 historical / compatibility / superseded context。

`MTP-211-COMPATIBILITY-ENVELOPE-CLOSEOUT`

MTP-211 closeout 必须明确 `Core` 仍是 compatibility envelope：它继续编译 `Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Coordination/RiskBinding/`，但这不等于 SwiftPM target graph split 完成，也不等于 Strategy runtime、Trader runtime、Live runtime 或 broker integration 已实现。

`MTP-211-FORBIDDEN-IMPLEMENTATION-AUDIT`

MTP-211 禁止 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、real account read、Live PRO Console、trading button、live command、order form、Graphify、Figma、next Project / Issue creation 和 next Todo promotion。

`MTP-211-STAGE-CLOSEOUT-VALIDATION`

MTP-211 validation 必须证明 stage audit input material、validation matrix、automation readiness anchors、compatibility envelope closeout、forbidden implementation audit、no final Stage Code Audit boundary 和 no next-stage mutation boundary 均落仓；并且 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 必须通过。

## MTP-173 Account / Portfolio Read-model Boundary

`MTP-173-ACCOUNT-PORTFOLIO-READMODEL-BOUNDARY-CONTRACT`

MTP-173 将 `Sources/Trader/Accounts/` 与 `Sources/Portfolio/` 的职责分层固定为 account context / identity 与 portfolio financial state 的 read-model boundary。Account 只作为 Trader coordination 的本地 context；Portfolio 是独立 financial state 模块，负责 positions、net positions、cash/equity、margin、open value、PnL、exposure 和 paper projection。

`MTP-173-TRADER-ACCOUNT-CONTEXT-IDENTITY-CONTRACT`

`Sources/Trader/Accounts/` 只能保存 account context、account identity、source identity、simulated / paper / future-gated source label 和 readiness evidence。它不拥有 cash、positions、net positions、PnL、exposure、margin、open value、paper projection、broker position、broker account state、account endpoint payload 或 broker payload。

`MTP-173-PORTFOLIO-FINANCIAL-STATE-OWNERSHIP`

`Sources/Portfolio/` 独立拥有 paper / simulated financial state read models：positions、net positions、cash/equity、PnL、exposure、margin、open value 和 paper projection。Portfolio 可以消费 DomainModel、MessageBus facts、Cache read state 和 Database projection input；不得依赖 Trader runtime、ExecutionClient、broker adapter、account endpoint payload 或 broker state。

`MTP-173-CASH-POSITION-PNL-EXPOSURE-PROJECTION-SPLIT`

cash、positions、PnL、exposure、margin、open value 和 projection 必须归 Portfolio；Trader 只能引用 Portfolio read model 形成 coordination context；Workbench / Report / Events 只能消费 ReadModel / ViewModel export。任何 docs、checks 或后续 PR 都不得把这些 financial state 字段放回 Trader/Accounts。

`MTP-173-REAL-ACCOUNT-BROKER-PORTFOLIO-FUTURE-GATE`

真实账户 source、broker portfolio、broker position、real balance、real position、margin / leverage、buying power、real PnL、account endpoint payload、broker payload 和 broker state 只能作为 future-gated forbidden label 出现。MTP-173 不授权 real account runtime、broker position sync、Portfolio live reconciliation、account snapshot runtime 或 private stream runtime。

`MTP-173-NO-BROKER-ACCOUNT-STATE-READ-GUARD`

禁止 `Portfolio -> broker account state`、`Portfolio -> account endpoint payload`、`Portfolio -> broker payload`、`Portfolio -> signed endpoint`、`Portfolio -> account endpoint / listenKey`、`Portfolio -> private WebSocket runtime`、`Portfolio -> broker position sync`、`Trader/Accounts -> broker portfolio` 和 `Workbench -> Portfolio broker state`。

`MTP-173-ACCOUNT-PORTFOLIO-BOUNDARY-VALIDATION`

MTP-173 只证明 Account / Portfolio read-model boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 Portfolio runtime、不读取真实 account / broker portfolio、不运行 Graphify、不修改 Figma。

## MTP-174 Strategies / Trader No-direct-execution Guard

`MTP-174-STRATEGIES-TRADER-NO-DIRECT-EXECUTION-GUARD`

MTP-174 将 Strategies / Trader no-direct-execution guard 固定为 M4 收口检查：Strategies 和 Trader 都不能直连 ExecutionClient、broker command、OMS、real order lifecycle 或 executable order command。Strategy proposal、Trader coordination context、account context、Portfolio read model 和 RiskEngine evidence 必须继续停留在 paper / simulated / read-model-only evidence chain。

`MTP-174-PROPOSAL-ORDER-COMMAND-SEMANTIC-ISOLATION`

Strategy proposal 和 Trader proposal 只能表达 paper/live-neutral intent evidence、blocked reason、read-model references 和 validation trace；不得包含 order id、client order id、broker order id、account id、broker account id、side / quantity / price / timeInForce / orderType executable tuple、ExecutionClient request、OMS order 或 signed request。

`MTP-174-TRADER-NOT-LIVE-COORDINATOR-BROKER-GATEWAY`

Trader coordination 只能串联 Strategies、Trader/Accounts、Portfolio、RiskEngine 和 ExecutionEngine paper / simulated boundary；不得升级为 live coordinator、broker gateway、OMS gateway、private stream coordinator、account snapshot runtime、real account synchronizer、broker session manager 或 command router。

`MTP-174-FORBIDDEN-UI-COMMAND-SURFACE-GUARD`

Workbench、Report、Events、Dashboard 和 future Live PRO Console label 都不能把 Strategies / Trader evidence 暴露为 trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。当前 UI surface 只能消费 ReadModel / ViewModel。

`MTP-174-EXECUTIONCLIENT-OMS-BROKER-PATH-BLOCKLIST`

禁止 `Strategies -> ExecutionClient`、`Strategies -> broker command`、`Strategies -> OMS`、`Trader -> ExecutionClient`、`Trader -> broker command`、`Trader -> OMS`、`Trader -> real submit / cancel / replace`、`Strategy proposal -> executable order command`、`Trader coordination -> real order lifecycle` 和 `Workbench -> Strategy / Trader live command`。

`MTP-174-NO-RUNTIME-ENDPOINT-CREDENTIAL-BYPASS`

MTP-174 guard 不能通过 runtime、endpoint 或 credential 绕过：不创建 Strategy runtime、Trader runtime、ExecutionClient implementation、OMS implementation、broker adapter、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、API key input、secret storage、credential provider 或 keychain storage。

`MTP-174-NO-DIRECT-EXECUTION-GUARD-VALIDATION`

MTP-174 只证明 Strategies / Trader no-direct-execution guard anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 Strategy runtime / Trader runtime / ExecutionClient / OMS / broker command、不运行 Graphify、不修改 Figma。

## MTP-175 RiskEngine Pre-execution Boundary

`MTP-175-RISKENGINE-PRE-EXECUTION-BOUNDARY-CONTRACT`

MTP-175 将 `Sources/RiskEngine/` 固定为 pre-execution risk boundary：RiskEngine 只消费 DomainModel、MessageBus facts、Cache read state 和 Portfolio read model，输出 paper pre-trade risk evidence、allowed / blocked evidence、blocked reason 和 future live risk gate label。它位于 ExecutionEngine 之前，但不是 broker gateway、ExecutionClient wrapper、OMS、live risk runtime 或 real pre-trade allow / reject service。

`MTP-175-PAPER-RISK-BLOCKED-EVIDENCE-CONTRACT`

Paper risk 只能表达 deterministic pre-trade check、risk input trace、Portfolio exposure reference、paper proposal reference、allowed / blocked verdict 和 blocked reason。Blocked evidence 可以进入 MessageBus / Cache / ReadModel / ViewModel / Report / Events，但不得携带 executable order command、broker account id、broker position、real balance、margin、leverage、real PnL、ExecutionClient request、OMS order 或 signed request。

`MTP-175-RISKENGINE-BEFORE-EXECUTIONENGINE-DEPENDENCY`

RiskEngine 的依赖方向是 `Strategies / Trader / Portfolio evidence -> RiskEngine -> ExecutionEngine paper / simulated lifecycle boundary`。ExecutionEngine 只能消费 RiskEngine 的 paper risk evidence 或 future-gated live risk gate label；不得反向要求 RiskEngine 调用 ExecutionClient、broker adapter、OMS、account endpoint 或 private stream runtime。

`MTP-175-FUTURE-LIVE-RISK-GATE-BOUNDARY`

Future live risk gate 只能作为 future-gated boundary label，用于后续 Human decision 和独立 Project Definition。当前 MTP-175 不实现 live risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade state runtime、stop trading command、emergency stop、risk command surface、position management command、order form 或 trading button。

`MTP-175-NO-BROKER-EXECUTIONCLIENT-RISK-PATH-GUARD`

禁止 `RiskEngine -> broker`、`RiskEngine -> ExecutionClient`、`RiskEngine -> OMS`、`RiskEngine -> signed endpoint`、`RiskEngine -> account endpoint / listenKey`、`RiskEngine -> private WebSocket runtime`、`RiskEngine -> broker position`、`RiskEngine -> real account state`、`RiskEngine -> live command` 和 `RiskEngine evidence -> executable order command`。

`MTP-175-NO-LIVE-RISK-RUNTIME-CIRCUIT-BREAKER-GUARD`

RiskEngine pre-execution boundary 不能绕成 current live safety runtime：不创建 live risk runtime、circuit breaker runtime、loss / drawdown enforcement runtime、frequency enforcement runtime、global trading lock、stop trading command、emergency stop command、broker session mutation、API key input、secret storage、credential provider 或 keychain storage。

`MTP-175-RISKENGINE-BOUNDARY-VALIDATION`

MTP-175 只证明 RiskEngine pre-execution boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 RiskEngine runtime、不读取真实 account / broker position、不运行 Graphify、不修改 Figma。

## MTP-176 ExecutionEngine Paper / Simulated Lifecycle Boundary

`MTP-176-EXECUTIONENGINE-PAPER-SIMULATED-LIFECYCLE-BOUNDARY`

MTP-176 将 `Sources/ExecutionEngine/` 固定为 paper / simulated execution lifecycle boundary。ExecutionEngine 只能消费 RiskEngine paper risk evidence、Trader coordination context、paper proposal evidence 和 Portfolio read model，输出 paper lifecycle evidence、simulated fill evidence、fee / slippage evidence 和 Portfolio projection trigger；它不是 ExecutionClient、broker adapter、OMS、real order state machine 或 venue API client。

`MTP-176-PAPER-LIFECYCLE-STATE-CONTRACT`

Paper lifecycle state 只能覆盖 proposed、accepted、rejected、filled、partially filled、expired 和 cancelled-local 等本地 deterministic 状态。状态 transition 必须保留 risk decision reference、paper order intent reference、correlation / causation evidence 和 replay trace；不得包含 broker order id、exchange order id、client order id、execution report id、broker fill id、real account id 或 signed request。

`MTP-176-SIMULATED-FILL-FEE-SLIPPAGE-CONTRACT`

Simulated fill、fee、slippage 和 cost impact 只表示本地 simulated exchange / deterministic fixture evidence。它们可以 feed Portfolio projection 和 Report / Events evidence surface，但不能被解释为 execution report、broker fill、exchange acknowledgement、venue fee report、settlement record、reconciliation input 或 broker statement。

`MTP-176-PORTFOLIO-PROJECTION-EVIDENCE-OUTPUT`

ExecutionEngine 的输出路径必须通过 MessageBus facts、Portfolio projection input、ReadModel / ViewModel export、Report 和 Events evidence surface。它不能直接写 Workbench UI state，不能暴露 runtime object、Adapter request、SQLite / DuckDB schema、broker payload、account payload 或 UI command surface。

`MTP-176-OMS-FUTURE-GATE-BOUNDARY`

OMSFutureGate 只能作为 future-gated boundary label，说明未来 OMS 与 ExecutionEngine 的分界。当前 MTP-176 不实现 OMS、order router、execution venue routing、real order lifecycle、broker session、execution report ingestion、broker fill ingestion、reconciliation runtime 或 production execution audit trail。

`MTP-176-NO-REAL-ORDER-LIFECYCLE-BROKER-PATH-GUARD`

禁止 `ExecutionEngine -> broker submit`、`ExecutionEngine -> broker cancel`、`ExecutionEngine -> broker replace`、`ExecutionEngine -> ExecutionClient request`、`ExecutionEngine -> OMS order`、`ExecutionEngine -> signed endpoint`、`ExecutionEngine -> account endpoint / listenKey`、`ExecutionEngine -> execution report`、`ExecutionEngine -> broker fill`、`ExecutionEngine -> reconciliation` 和 `paper lifecycle -> real order lifecycle`。

`MTP-176-EXECUTIONENGINE-BOUNDARY-VALIDATION`

MTP-176 只证明 ExecutionEngine paper / simulated lifecycle boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 ExecutionEngine runtime、不实现 OMS / broker adapter / ExecutionClient、不运行 Graphify、不修改 Figma。

## MTP-177 ExecutionClient / OMS Future Gate Boundary

`MTP-177-EXECUTIONCLIENT-FUTURE-GATED-BOUNDARY-CONTRACT`

MTP-177 将 `Sources/ExecutionClient/` 固定为 future-gated venue API client boundary。ExecutionClient 只代表未来把内部已通过 RiskEngine 和 ExecutionEngine 的 order intent 翻译成 broker / exchange API request 的外部电话线；当前仓库不得实现 broker client、exchange execution adapter、signed request、account endpoint / listenKey、private WebSocket runtime 或 order submit / cancel / replace。

`MTP-177-BROKER-CAPABILITY-MATRIX-FUTURE-GATE`

BrokerCapabilityMatrix 只能作为 future gate taxonomy，用于列出未来 venue capability、signed endpoint capability、account endpoint capability、execution report capability、broker fill capability 和 reconciliation capability。当前 MTP-177 不授权 capability discovery runtime、credential check、network probe、private endpoint test、API key input、secret storage、credential provider 或 keychain storage。

`MTP-177-OMS-FUTURE-GATE-EXECUTIONENGINE-SPLIT`

OMSFutureGate 只说明未来 OMS 与 ExecutionEngine 的分界：ExecutionEngine 负责 paper / simulated lifecycle evidence，OMS 未来才可能负责 live order orchestration、order state machine 和 venue routing。当前 MTP-177 不实现 OMS、order router、order state store、order amendment engine、real submit / cancel / replace、execution report parser、broker fill parser 或 reconciliation runtime。

`MTP-177-EXECUTIONENGINE-VS-EXECUTIONCLIENT-PLAIN-LANGUAGE`

大白话：ExecutionEngine 是内部执行大脑，负责本地 paper / simulated lifecycle、simulated fill、fee / slippage 和 Portfolio projection evidence；ExecutionClient 是未来外部电话线，只在未来 approved live gate 后才可能拨 broker / exchange API。当前 ExecutionEngine 不能拿起这条电话线，ExecutionClient 也不能作为当前 runtime 存在。

`MTP-177-NO-BROKER-CLIENT-SIGNED-REQUEST-GUARD`

禁止 `ExecutionClient -> broker client`、`ExecutionClient -> signed request`、`ExecutionClient -> order submit`、`ExecutionClient -> order cancel`、`ExecutionClient -> order replace`、`ExecutionClient -> account endpoint / listenKey`、`ExecutionClient -> private WebSocket runtime`、`ExecutionEngine -> ExecutionClient request` 和 `OMSFutureGate -> current OMS implementation`。

`MTP-177-NO-EXECUTION-REPORT-FILL-RECONCILIATION-RUNTIME`

ExecutionClient / OMS future gate 不能绕成 real execution evidence pipeline：不创建 execution report parser、broker fill parser、broker acknowledgement decoder、order status poller、fill reconciliation job、position reconciliation job、settlement importer、broker statement reader 或 production execution audit trail。

`MTP-177-EXECUTIONCLIENT-OMS-FUTURE-GATE-VALIDATION`

MTP-177 只证明 ExecutionClient / OMS future gate boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 ExecutionClient、不实现 OMS、不运行 Graphify、不修改 Figma。

## MTP-178 Broker / Real Order Forbidden Guard Evidence

`MTP-178-BROKER-REAL-ORDER-FORBIDDEN-GUARD`

MTP-178 建立 broker / real order forbidden guard evidence，把 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、LiveExecutionAdapter、real order lifecycle、execution report、broker fill 和 reconciliation 固定为 current implementation forbidden。该 guard 只作为 architecture boundary evidence，不创建 broker client、不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph。

`MTP-178-SIGNED-ACCOUNT-LISTENKEY-ENDPOINT-BLOCKLIST`

当前架构禁止任何 signed request、API key / secret / credential provider、account endpoint、listenKey、private WebSocket runtime、account snapshot runtime、broker account payload、broker state payload 或 private endpoint network test。DataClient、ExecutionClient future gate、RiskEngine、ExecutionEngine、Trader、Portfolio 和 Workbench 都不能通过 endpoint label 绕成真实账户或私有流读取路径。

`MTP-178-BROKER-EXCHANGE-EXECUTION-ADAPTER-BLOCKLIST`

禁止 `BrokerExecutionAdapter`、`ExchangeExecutionAdapter`、`LiveExecutionAdapter`、broker SDK wrapper、exchange venue client、broker gateway、OMS gateway、order router、execution venue routing、broker session manager、broker connect UI 和任何从 paper / simulated evidence 直连 broker / exchange 的 adapter path。

`MTP-178-REAL-SUBMIT-CANCEL-REPLACE-FORBIDDEN`

真实 submit / cancel / replace、order amendment、order status poll、broker acknowledgement、exchange order id、client order id、broker order id、real order state machine 和 production execution audit trail 均为 future-gated forbidden path。Paper lifecycle、simulated fill、RiskEngine blocked evidence 或 Strategy proposal 不得升级成 executable order command、order form payload、live command、trading button 或 Live PRO Console action。

`MTP-178-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-BLOCKLIST`

禁止 execution report parser、broker fill parser、broker fill fact、fill reconciliation job、position reconciliation job、settlement importer、broker statement reader、real PnL source、broker portfolio sync、account position sync 和任何把 broker evidence 写回 Portfolio / Workbench / Report / Events 的 runtime pipeline。当前只允许本地 fixture / read-model-only / simulated evidence，不允许真实 broker fact source。

`MTP-178-LIVEEXECUTIONADAPTER-FUTURE-GATE`

`LiveExecutionAdapter` 仍只能作为 forbidden capability label 或 future gate term 出现在文档、测试和 read-model evidence 中；不得在 `Sources/` 或 `Tests/` 中声明为 production protocol、struct、class、actor、enum 或 runtime implementation。未来 live execution 必须由独立 Human decision、独立 Project Definition、signed / account / broker / ops gates 和新的 validation matrix 授权。

`MTP-178-BROKER-REAL-ORDER-GUARD-VALIDATION`

MTP-178 只证明 broker / real order forbidden guard anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 broker / live execution capability、不读取 real account / broker state、不运行 Graphify、不修改 Figma。

## MTP-179 Workbench Read-Model-Only Consumption Boundary

`MTP-179-WORKBENCH-READ-MODEL-ONLY-CONSUMPTION-BOUNDARY`

MTP-179 将 `Sources/Workbench/` 固定为 Workbench / Report / Dashboard / Events 的 read-model-only consumption boundary。Workbench 只能展示 ReadModel / ViewModel / evidence surface，不拥有 runtime object、不调用 adapter、不读取 Database schema、不读取 account payload、不读取 broker state，也不形成 command surface。

`MTP-179-READMODEL-VIEWMODEL-ONLY-INPUT-CONTRACT`

Workbench / Report / Events 的输入只能是 ReadModel / ViewModel export、MessageBus facts projection、Portfolio / Risk / Execution evidence read model、local fixture summary 和 deterministic validation summary。输入不得包含 Runtime object、Adapter request、SQLite / DuckDB schema、SQL table / column contract、account endpoint payload、broker payload、broker state、ExecutionClient request、OMS order 或 live command payload。

`MTP-179-WORKBENCH-REPORT-EVENTS-SURFACE-SPLIT`

Workbench 是操作者查看和筛选 evidence 的 read-only surface；Report 是 summary / audit / validation evidence surface；Events 是 timeline / fact stream evidence surface。三者都只能消费同一 read-model-only export，不直接消费 engine runtime、adapter request、database implementation、private endpoint payload、broker payload 或 broker state。

`MTP-179-NO-RUNTIME-ADAPTER-SCHEMA-PAYLOAD-EXPOSURE`

禁止 `Workbench -> Runtime object`、`Workbench -> Adapter request`、`Workbench -> SQLite schema`、`Workbench -> DuckDB schema`、`Workbench -> account payload`、`Workbench -> broker payload`、`Workbench -> broker state`、`Report -> Database schema`、`Events -> Runtime object` 和 `Dashboard -> broker state`。Schema、adapter 和 runtime 只能作为 local implementation detail 或 validation evidence，不成为 product surface contract。

`MTP-179-NO-LIVE-COMMAND-SURFACE-GUARD`

Workbench 不得成为 Live PRO Console、trading button、live command、order form、position command、stop trading command、emergency stop、shutdown / restore command、broker connect UI、signed endpoint trigger、account endpoint trigger 或 ExecutionClient trigger。当前 UI surface 必须保持 read-model-only 和 no command side effect。

`MTP-179-UI-COPY-READ-MODEL-ONLY-LABELING`

UI 文案和 docs evidence 必须把 Workbench / Report / Events 描述为 read-model-only、evidence、snapshot、summary、timeline、projection 或 view model，不得暗示 execute、submit、cancel、replace、trade、connect broker、sync account、start live、stop live、emergency stop 或 production operation capability。

`MTP-179-WORKBENCH-READMODEL-BOUNDARY-VALIDATION`

MTP-179 只证明 Workbench read-model-only consumption boundary anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 Workbench runtime、不创建 Live PRO Console、不运行 Graphify、不修改 Figma。

## MTP-180 Future Live PRO Console Product-Surface Split

`MTP-180-FUTURE-LIVE-PRO-CONSOLE-PRODUCT-SURFACE-SPLIT`

MTP-180 将 Future Live PRO Console 固定为独立 future product surface。它不是 current Workbench 的自然扩展，也不是 `Sources/Workbench/` read-model-only boundary 的当前子功能；当前只能作为未来建设区和 product-surface split 证据出现。

`MTP-180-FUTURELIVEPROCONSOLE-BOUNDARY-LABEL`

`Sources/Workbench/FutureLiveProConsole/` 只能作为 future boundary label 写入架构文档，用来说明后续 L4 / Human decision 可能规划独立 command-capable surface。当前 issue 不创建该目录、不创建 SwiftPM target、不声明 FutureLiveProConsole 类型、不添加 App route 或 Dashboard control。

`MTP-180-CURRENT-WORKBENCH-VS-FUTURE-COMMAND-SURFACE`

Current Workbench 继续只消费 ReadModel / ViewModel / evidence surface；Future Live PRO Console 未来才可能承载 command-capable product surface。二者的输入、状态和验证证据必须分离：Workbench 不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload、broker state 或 live command payload；Future Live PRO Console label 也不能反向授权这些 current exposure。

`MTP-180-LIVE-COMMAND-CONTROLS-FUTURE-ONLY`

Live PRO Console、trading button、live command、order form、position command、emergency stop、shutdown、restore、broker connect UI、account connect UI、signed endpoint trigger 和 ExecutionClient trigger 均为 future-only controls。当前只能在 forbidden / future-gated evidence 中命名，不能成为 UI、ViewModel、command handler、route、menu item 或 runtime capability。

`MTP-180-NO-CURRENT-LIVE-PRO-CONSOLE-IMPLEMENTATION`

禁止在当前 scope 创建 Live PRO Console implementation、FutureLiveProConsole implementation、trading button handler、live command handler、order form model、emergency stop command、shutdown command、restore command、production operations command、broker session control、ExecutionClient request UI 或 OMS command UI。

`MTP-180-NEXT-STAGE-PRODUCT-SURFACE-READINESS-INPUT`

MTP-180 只为后续 L4 planning 提供 product-surface readiness input：当前已知 Workbench 是 read-model-only surface，Future Live PRO Console 是 future-gated command-capable candidate，二者之间需要独立 Project Definition、Human decision、signed / account / broker / execution / ops gates、validation matrix 和 forbidden capability audit。

`MTP-180-FUTURE-LIVE-PRO-CONSOLE-VALIDATION`

MTP-180 只证明 Future Live PRO Console product-surface split anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 Live PRO Console、不运行 Graphify、不修改 Figma。

## MTP-181 L4 Planning Input Material

`MTP-181-L4-PLANNING-INPUT-MATERIAL`

MTP-181 将 Engine Module Boundary Consolidation evidence 汇总为 L4 planning input material。该材料只为 Human + `@001 / PLN` 后续独立规划提供输入，不创建 L4 Linear Project / Issue，不推进 Todo，不授权 business-code implementation。

`MTP-181-ENGINE-MODULE-BOUNDARY-MAP`

L4 planning input 必须覆盖 DataClient、DataEngine、MessageBus、Cache、Database、Strategies、Trader / Account context、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient / OMS、Workbench / Report / Events 和 Future Live PRO Console 的 module boundary map。每个 module 必须保留 target boundary、current implementation baseline 和 forbidden capability baseline。

`MTP-181-DEPENDENCY-DIRECTION-SUMMARY`

L4 planning input 的 dependency direction 必须保持 `DataClient -> DataEngine -> MessageBus -> Cache / Database -> ReadModel / ViewModel -> Workbench`，以及 `Strategies / Trader -> RiskEngine -> ExecutionEngine -> Portfolio projection` 的方向；不得反向让 Workbench、Trader、Strategy 或 DataEngine 直连 ExecutionClient、broker adapter、Database schema 或 private endpoint runtime。

`MTP-181-FORBIDDEN-CAPABILITY-AUDIT`

L4 planning input 必须汇总 forbidden capability audit：signed / account / listenKey endpoint、private stream runtime、account snapshot runtime、broker adapter、ExecutionClient implementation、OMS implementation、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console command controls、Runtime object exposure、Adapter request exposure、SQLite / DuckDB schema exposure、account payload exposure 和 broker state exposure 均保持未授权。

`MTP-181-VALIDATION-GAPS-FUTURE-GATES`

L4 planning input 必须列出 validation gaps and future gates：L4 Project Definition、signed / account gate、broker / execution gate、product surface gate、operations gate 和新的 validation matrix gate。当前 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 只证明 boundary consolidation，不授权 L4 execution。

`MTP-181-NO-L4-PROJECT-ISSUE-AUTHORIZATION`

MTP-181 不创建 L4 Project / Issue，不更新任何 next-stage Todo，不启动新的 `@002 / PAR` project，不启动 Symphony，不运行 Graphify，不修改 Figma。L4 必须由 Human + `@001 / PLN` 独立规划，并在未来由 Parent Codex queue preflight 授权唯一 executable issue。

`MTP-181-L4-PLANNING-INPUT-VALIDATION`

MTP-181 只证明 L4 planning input material anchors 已落仓且可被 `checks/automation-readiness.sh` 机械检查；不移动 production source、不创建 SwiftPM target、不修改 `Package.swift` target graph、不实现 L4 runtime / live production / broker path、不输出最终 Stage Code Audit Report。

## MTP-182 Validation Matrix / Automation Readiness / Stage Audit Input

`MTP-182-ENGINE-MODULE-BOUNDARY-STAGE-CLOSEOUT`

MTP-182 将 Engine Module Boundary Consolidation v1 的 M1-M6 evidence chain 收口为 stage audit input material。该 closeout 只为 Parent Codex 后续 Stage Code Audit Report 提供输入，不设置 Linear Project `Completed`，不输出最终 Stage Code Audit Report，不授权下一阶段。

`MTP-182-STAGE-AUDIT-INPUT-MATERIAL`

Stage audit input material 固定在 `docs/audit/inputs/mtpro-engine-module-boundary-consolidation-v1-stage-audit-input.md`，必须覆盖 validation matrix closeout、automation readiness closeout、M1-M6 issue / PR evidence、forbidden implementation audit、unresolved future gates、Root Docs Delta input 和 Stage Code Audit handoff checklist。

`MTP-182-VALIDATION-MATRIX-CLOSEOUT`

MTP-182 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-182 issue backfill，说明 MTP-162 至 MTP-181 的 architecture boundary evidence 已形成可审计链路，但该 matrix 只证明 boundary consolidation，不授权 L4 execution、broker runtime、live runtime 或 command-capable product surface。

`MTP-182-AUTOMATION-READINESS-CLOSEOUT`

Automation readiness closeout 必须由 `checks/automation-readiness.sh` 机械检查 stage audit input、module-boundary docs、domain context、validation matrix、validation plan、latest summary 和 automation readiness doc。MTP-182 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

`MTP-182-FORBIDDEN-IMPLEMENTATION-AUDIT`

Forbidden implementation audit 必须确认当前 Project 未实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker adapter、real order lifecycle、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、Live PRO Console、trading button、live command、order form、emergency stop、shutdown、restore 或 production operations command。

`MTP-182-UNRESOLVED-FUTURE-GATES`

Unresolved future gates 必须明确 L4 Project Definition、signed / account gate、broker / execution gate、product surface gate、operations gate 和新的 validation gate 仍未打开，后续只能由 Human + `@001 / PLN` 独立规划。

`MTP-182-STAGE-CLOSEOUT-VALIDATION`

MTP-182 validation 必须证明 stage audit input material、validation matrix、automation readiness anchors 和 forbidden implementation audit 已落仓，并且 `bash checks/automation-readiness.sh`、`git diff --check` 和 `bash checks/run.sh` 通过。

`MTP-182-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`

MTP-182 不创建 L4 Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR` 或 Symphony，不运行 Graphify，不修改 Figma，不设置 Linear Project `Completed`，不输出最终 Stage Code Audit Report。

## MTP-183 Target Physical Layout / SwiftPM Migration Contract

`MTP-183-TARGET-PHYSICAL-LAYOUT-CONTRACT`

MTP-183 把 `MTPRO Target Module Physical Layout / Source Migration v1` 的第一步固定为 contract-first migration。目标 source layout 继续沿用 MTP-163 已固定的 `Sources/DomainModel/`、`Sources/DataClient/<venue>/`、`Sources/DataEngine/`、`Sources/MessageBus/`、`Sources/Cache/`、`Sources/Database/`、`Sources/Strategies/<strategy>/`、`Sources/Trader/`、`Sources/Portfolio/`、`Sources/RiskEngine/`、`Sources/ExecutionEngine/`、`Sources/ExecutionClient/`、`Sources/Workbench/` 和 `Sources/Dashboard/`。

MTP-191 后续修正了具体 strategy landing path：MTP-183 的 `Sources/Strategies/<strategy>/` 作为历史 migration contract evidence 保留；forward-looking target layout 使用 `Sources/Trader/Strategies/<strategy>/`。

`MTP-183-CURRENT-SWIFTPM-SNAPSHOT`

当前 `Package.swift` 仍保持 coarse target graph：`Core`、`Adapters`、`Persistence`、`Runtime`、`App` 和 `Dashboard`。MTP-183 只记录该 snapshot，不修改 `Package.swift`，不创建 SwiftPM target，不移动 production source。

`MTP-183-SWIFTPM-MIGRATION-CONTRACT`

后续 migration strategy 分三段执行：先 directory-first / namespace-first 并保留 compatibility shell；再优先拆 `DomainModel`、`MessageBus`、`Database`、`Cache`、`DataClient` 和 `DataEngine`；最后拆 `Strategies`、`Trader`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、future-gated `ExecutionClient`、`Workbench` 和 `Dashboard`。任何 `Package.swift` target graph delta 都必须由后续对应 Linear issue 明确授权。

`MTP-183-OLD-TO-NEW-SOURCE-MAP`

MTP-183 的 old-to-new source map 固定：`Core` 拆向 `DomainModel`、`MessageBus`、`DataEngine`、`Cache`、`RiskEngine`、`ExecutionEngine`、`Portfolio` 和 `Strategies/<strategy>`；`Adapters` 拆向 `DataClient/Binance/PublicMarketData`；`Persistence` 与 `CSQLite` 拆向 `Database`；`Runtime` 拆向 `DataEngine`、`MessageBus`、`Cache` 和 `Database` replay / projection 边界；`App` 拆向 `Workbench`；`Dashboard` 保留为 macOS shell / presentation surface。

MTP-191 后的 corrected old-to-new source map 把 concrete strategy code 归向 `Trader/Strategies/<strategy>`；`Strategies/<strategy>` 只表示 MTP-187 已发生的兼容路径和待迁移来源。

`MTP-183-COMPATIBILITY-SHELL-POLICY`

旧 `Core / Adapters / Persistence / Runtime / App / Dashboard / CSQLite` 只允许作为 migration source / compatibility shell。Compatibility shell 只能包含 forwarding imports、typealias、deprecated wrapper 或 minimal adapter glue，不新增业务语义；每个后续 source migration PR 必须列出 moved files、remaining shell 和 planned removal issue。

`MTP-183-IMPORT-DIRECTION-GUARD`

MTP-183 继续固定 import guard：`Strategies -> ExecutionClient`、`Trader -> ExecutionClient`、`Workbench -> Runtime object / Adapter request / Database schema`、`DataClient -> signed/account/listenKey/private runtime`、`RiskEngine -> broker / ExecutionClient`、`Portfolio -> broker account state`、`ExecutionEngine -> current OMS / broker adapter` 和 `Dashboard -> broker command / live command / order form` 必须被阻断。

`MTP-183-VALIDATION-ANCHORS`

MTP-183 的 validation anchors 落在 `docs/contracts/target-module-physical-layout-source-migration-contract.md`、本文档、`docs/domain/context.md`、`docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh`。验证必须证明 target layout、SwiftPM migration strategy、old-to-new map、compatibility shell、import guard 和 no source move / no Package.swift change / no business code 均成立。

`MTP-183-NO-SOURCE-MOVE-PACKAGE-BUSINESS-CODE`

MTP-183 不移动 `Sources` 文件，不修改 `Package.swift` target graph，不写业务代码，不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、real order lifecycle、Live PRO Console、trading button、live command 或 order form。真正 source migration 从 MTP-184 以后按各自 Linear issue scope 执行。

## MTP-184 DomainModel / MessageBus Physical Migration

`MTP-184-DOMAINMODEL-MESSAGEBUS-PHYSICAL-MIGRATION`

MTP-184 执行第一段 directory-first / namespace-first source migration：`Sources/Core/MarketPrimitives.swift`、`Sources/Core/MarketDataModels.swift` 和 `Sources/Core/CoreBaseline.swift` 已迁入 `Sources/DomainModel/`；`Sources/Core/DomainEvents.swift`、`Sources/Core/CommandsAndQueries.swift`、`Sources/Core/EventLog.swift` 和 `Sources/Core/PaperRuntimeBusRouting.swift` 已迁入 `Sources/MessageBus/`。这些文件仍由现有 `Core` target 编译，未新增 SwiftPM target、product 或 dependency。

`MTP-184-CORE-TARGET-COMPATIBILITY-ENVELOPE`

MTP-184 把 `Core` target 的 source roots 调整为 `Sources/Core`、`Sources/DomainModel` 和 `Sources/MessageBus`，并显式排除 `Adapters`、`Persistence`、`Runtime`、`App`、`Dashboard` 和 `CSQLite`。这只是 compatibility envelope，用于保持既有 `import Core` 下游调用不变；它不等同于最终 target graph split，也不授权后续模块提前依赖新 target。

`MTP-184-NO-BEHAVIOR-CHANGE-IMPORT-BOUNDARY`

MTP-184 不改 public type 名称、不改事件语义、不改 message bus routing 行为、不新增 runtime MessageBus。所有既有 callers 仍通过 `Core` target 使用 DomainModel / MessageBus 类型，验证必须证明 `CoreTests` 和 full checks 继续通过。

`MTP-184-REMAINING-COMPATIBILITY-SHELL`

MTP-184 没有保留旧路径 forwarding file；剩余 compatibility shell 是 `Core` target 本身的多 source-root envelope。旧 `Sources/Core` 仍保留未迁出的 Cache、DataEngine、Strategies、Portfolio、RiskEngine、ExecutionEngine、Live boundary 等后续 issue scope 文件，不在本 issue 内移动。

`MTP-184-FORBIDDEN-HIGHER-MODULE-MIGRATION`

MTP-184 不迁移 DataClient、DataEngine、Cache、Database、Strategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard，除非是保持当前 `Core` target 编译所需的 import compatibility。它不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker / live / order capability、signed endpoint、account endpoint / listenKey、private WebSocket runtime、Live PRO Console、trading button、live command 或 order form。

## MTP-185 DataClient / DataEngine Physical Migration

`MTP-185-DATACLIENT-DATAENGINE-PHYSICAL-MIGRATION`

MTP-185 执行 DataClient / DataEngine 的 directory-first source migration：Binance public read-only client、batch replay boundary、replay metadata、freshness 和 deterministic parity 文件已从 `Sources/Adapters/` 迁入 `Sources/DataClient/Binance/PublicMarketData/`；Data Catalog / Scenario Replay、Scenario Manifest、Scenario Fixture、Scenario Replay Evidence 和 deterministic matching 文件已从 `Sources/Core/` 迁入 `Sources/DataEngine/ScenarioReplay/`；Scenario Data Quality / Report Input 文件已迁入 `Sources/DataEngine/DataQuality/`；public market data ingest workflow 已从 `Sources/Runtime/Runtime.swift` 迁入 `Sources/DataEngine/Ingest/MarketDataIngestReplayProjectionWorkflow.swift`。

`MTP-185-DATACLIENT-COMPATIBILITY-ENVELOPE`

MTP-185 保留现有 SwiftPM product / target 名称作为兼容外壳：`Adapters` target 继续编译 `Sources/DataClient/Binance/PublicMarketData/`，`Core` target 继续编译 `Sources/Core`、`Sources/DomainModel`、`Sources/MessageBus`、`Sources/DataEngine/ScenarioReplay` 和 `Sources/DataEngine/DataQuality`，`Runtime` target 继续编译 `Sources/Runtime` 和 `Sources/DataEngine/Ingest`。该兼容壳只保持既有 `import Core`、`import Adapters` 和 `import Runtime` buildability，不等同于最终 target graph split。

`MTP-185-PUBLIC-READ-ONLY-GUARD`

迁入 `DataClient/Binance/PublicMarketData` 的代码仍只能生成 public read-only Binance request、mock transport / fixture / local replay evidence 和 deterministic parity。它不保存 API key，不生成 signature，不访问 account endpoint，不创建 listenKey，不实现 private WebSocket runtime，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、submit / cancel / replace、execution report、broker fill 或 reconciliation。

`MTP-185-DATAENGINE-BOUNDARY-GUARD`

迁入 `DataEngine` 的 scenario replay、data quality 和 ingest 代码只能消费 deterministic local fixture、public read-only client 输出、MessageBus / event log / projection compatibility 边界和 read-model evidence。它不把 DataEngine 升级为完整 streaming runtime，不直接服务 UI / Trader / Strategy / RiskEngine / ExecutionEngine，不绕过 MessageBus / Cache / Database / ReadModel / ViewModel，也不触发 signed/account/listenKey/private stream、broker sync、live command 或 executable order path。

`MTP-185-REMAINING-COMPATIBILITY-SHELL`

MTP-185 后旧 `Sources/Adapters/Adapters.swift`、`Sources/Core/Scenario*.swift`、`Sources/Core/DataCatalogScenarioReplayBoundary.swift` 和 `Sources/Runtime/Runtime.swift` 不再保留文件。MTP-185 当时剩余 compatibility shell 是旧 SwiftPM target 名称和未迁出的 replay projection consistency evidence；该 evidence 已由 MTP-186 迁入 `Sources/Database/ReplayProjection/`。

## MTP-186 Cache / Database Physical Migration

`MTP-186-CACHE-DATABASE-PHYSICAL-MIGRATION`

MTP-186 执行 Cache / Database 的 directory-first source migration：runtime-derived market data cache 和 order book read model 已从旧 `Sources/Core/` 迁入 `Sources/Cache/MarketData/`；SQLite / DuckDB projection adapters 和 CSQLite system library boundary 已从旧 `Sources/Persistence/`、`Sources/CSQLite/` 迁入 `Sources/Database/Projections/SQLite/`、`Sources/Database/Projections/DuckDB/` 和 `Sources/Database/Projections/SQLite/CSQLite/`；market data replay projection consistency evidence 已从旧 `Sources/Runtime/` 迁入 `Sources/Database/ReplayProjection/`。

`MTP-186-CACHE-COMPATIBILITY-ENVELOPE`

MTP-186 保留现有 `Core` SwiftPM product / target 名称作为 Cache 迁移期兼容外壳：`Core` target 继续编译 `Sources/Cache/MarketData/`，让既有 tests 和 downstream target 仍通过 `import Core` 使用 runtime-derived cache / read-model 类型。该兼容壳只保持 buildability，不等同于最终 Cache target graph split。

`MTP-186-DATABASE-COMPATIBILITY-ENVELOPE`

MTP-186 保留现有 `Persistence` 和 `Runtime` SwiftPM product / target 名称作为 Database 迁移期兼容外壳：`Persistence` target 改为从 `Sources/Database/Projections/SQLite/` 与 `Sources/Database/Projections/DuckDB/` 编译 SQLite / DuckDB projection adapters；`Runtime` target 继续编译 `Sources/Database/ReplayProjection/`，只保持 replay projection consistency buildability。该兼容壳不新增 Database target / product，不做 target graph split。

`MTP-186-CSQLITE-SYSTEM-LIBRARY-BOUNDARY`

MTP-186 将 `CSQLite` system library path 固定到 `Sources/Database/Projections/SQLite/CSQLite/`，把 SQLite C shim 归入 Database / SQLite projection ownership。该移动只改变 physical source placement，不改变 SQLite API usage、schema ownership、migration runtime 或 persistence behavior。

`MTP-186-SCHEMA-NON-EXPOSURE-GUARD`

迁入 `Database` 的 SQLite / DuckDB / replay projection code 仍只能提供 local deterministic facts、snapshot 和 projection evidence。它不向 Workbench / Report / Events 暴露 SQLite / DuckDB schema，不暴露 Runtime object、Adapter request、account payload、broker payload 或 broker state，不读取真实 account / position / balance，不触发 signed endpoint、listenKey、private stream、broker sync、live command 或 executable order path。

`MTP-186-REMAINING-COMPATIBILITY-SHELL`

MTP-186 后旧 `Sources/Core/MarketDataCache.swift`、`Sources/Core/OrderBookReadModel.swift`、`Sources/Persistence/`、`Sources/CSQLite/` 和 `Sources/Runtime/MarketDataReplayProjectionConsistency.swift` 不再保留。剩余 compatibility shell 是旧 SwiftPM target 名称和未迁出的 higher-module source roots；后续 Strategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench / Dashboard migration 必须由独立 Linear issue 授权。

## MTP-187 Strategies / Trader / Portfolio Physical Migration

`MTP-187-STRATEGIES-TRADER-PORTFOLIO-PHYSICAL-MIGRATION`

MTP-187 执行 Strategies / Trader / Portfolio 的 directory-first source migration：EMA strategy lifecycle、shared strategy signal 和 paper proposal 已从旧 `Sources/Core/` 迁入 `Sources/Strategies/EMA/`；order-book imbalance research strategy 已迁入 `Sources/Strategies/OrderBookImbalance/`；proposal-to-risk binding 已迁入 `Sources/Trader/StrategyBindings/`；paper account / portfolio projection、portfolio projection update 和 simulated exchange portfolio projection parity 已迁入 `Sources/Portfolio/`。

MTP-191 将 MTP-187 的 `Sources/Strategies/EMA/` 与 `Sources/Strategies/OrderBookImbalance/` 降级为 compatibility / superseded physical location。MTP-193 已把 EMA concrete strategy files 迁入 `Sources/Trader/Strategies/EMA/`；MTP-201 已把 OrderBookImbalance 从 active Trader strategy root 退休到 `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift`。

`MTP-187-STRATEGIES-COMPATIBILITY-ENVELOPE`

MTP-187 保留现有 `Core` SwiftPM product / target 名称作为 Strategies 迁移期兼容外壳。MTP-201 后 `Core` target 继续编译 `Sources/Trader/Strategies/EMA/` 和 `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift`，让既有 tests 和 downstream target 仍通过 `import Core` 使用 EMA signal / proposal 与 OrderBookImbalance research evidence types。该兼容壳只保持 buildability，不等同于 Strategy runtime 或最终 target graph split。

`MTP-187-TRADER-COMPATIBILITY-ENVELOPE`

MTP-187 将 proposal-to-risk binding 归入 `Sources/Trader/StrategyBindings/`，但 `Core` target 继续作为兼容外壳编译。Trader 在当前 issue 只表示 strategy / risk / portfolio coordination evidence，不是 live coordinator、broker gateway、ExecutionClient gateway 或 account session runtime。

`MTP-187-PORTFOLIO-COMPATIBILITY-ENVELOPE`

MTP-187 将 paper / simulated financial projection code 归入 `Sources/Portfolio/`，但 `Core` target 继续作为兼容外壳编译。Portfolio 仍只持有 paper / simulated / read-model financial state，不读取 broker account state、account endpoint payload、real balance、real position、margin、leverage 或 real PnL。

`MTP-187-NO-DIRECT-EXECUTION-GUARD`

Strategies / Trader / Portfolio 迁移后仍禁止 `Strategies -> ExecutionClient`、`Trader -> ExecutionClient`、`Trader -> broker command`、`Portfolio -> broker account state` 和 proposal -> executable order command bypass。Paper proposal、risk decision、portfolio projection 和 simulated parity 只能作为 deterministic local evidence，不授权 OMS、ExecutionClient、broker adapter、real submit / cancel / replace、Live PRO Console、trading button、live command 或 order form。

`MTP-187-REMAINING-COMPATIBILITY-SHELL`

MTP-187 后旧 `Sources/Core/EMACross.swift`、`Sources/Core/StrategySignals.swift`、`Sources/Core/PaperActionProposal.swift`、`Sources/Core/OrderBookImbalance.swift`、`Sources/Core/PaperActionRiskLink.swift`、`Sources/Core/PaperAccountPortfolioProjectionV2.swift`、`Sources/Core/PaperPortfolioProjectionUpdate.swift` 和 `Sources/Core/SimulatedExchangePortfolioProjectionParity.swift` 不再保留。剩余 compatibility shell 是旧 `Core` SwiftPM target 名称和未迁出的 RiskEngine / ExecutionEngine / ExecutionClient / Workbench / Dashboard source roots。

## MTP-188 RiskEngine / ExecutionEngine / ExecutionClient Physical Migration

`MTP-188-RISK-EXECUTION-PHYSICAL-MIGRATION`

MTP-188 执行 RiskEngine / ExecutionEngine / ExecutionClient 的 directory-first source migration：paper pre-trade risk 已从旧 `Sources/Core/` 迁入 `Sources/RiskEngine/PreTrade/`；live risk gate 与 incident / stop blocked evidence 已迁入 `Sources/RiskEngine/LiveGate/`；paper execution workflow、paper runtime kernel、paper session lifecycle、paper order lifecycle、paper decision 和 paper event log 已迁入 `Sources/ExecutionEngine/PaperLifecycle/`；simulated fill、shared order semantics、market / limit execution、partial fill / latency / fee / slippage parity、simulated exchange parity 和 execution cost assumptions 已迁入 `Sources/ExecutionEngine/SimulatedExchange/`；OMS future gate boundary 已进入 `Sources/ExecutionEngine/OMSFutureGate/`；future live execution-control contract 已迁入 `Sources/ExecutionClient/FutureGate/`；BrokerCapabilityMatrix future gate 已进入 `Sources/ExecutionClient/BrokerCapabilityMatrix/`。

`MTP-188-RISKENGINE-COMPATIBILITY-ENVELOPE`

MTP-188 保留现有 `Core` SwiftPM product / target 名称作为 RiskEngine 迁移期兼容外壳：`Core` target 继续编译 `Sources/RiskEngine/PreTrade/` 和 `Sources/RiskEngine/LiveGate/`。该兼容壳只保持 buildability，不等同于 live risk runtime、real pre-trade allow / reject runtime、circuit breaker runtime、stop / emergency command 或 broker / ExecutionClient path。

`MTP-188-EXECUTIONENGINE-COMPATIBILITY-ENVELOPE`

MTP-188 保留现有 `Core` SwiftPM product / target 名称作为 ExecutionEngine 迁移期兼容外壳：`Core` target 继续编译 `Sources/ExecutionEngine/PaperLifecycle/`、`Sources/ExecutionEngine/SimulatedExchange/` 和 `Sources/ExecutionEngine/OMSFutureGate/`。ExecutionEngine 当前仍只表示 paper / simulated lifecycle evidence，不实现 current OMS、order router、venue routing、real order lifecycle、broker submit / cancel / replace、execution report、broker fill 或 reconciliation。

`MTP-188-EXECUTIONCLIENT-FUTURE-GATE-ENVELOPE`

MTP-188 将 ExecutionClient future gate 放入 `Sources/ExecutionClient/FutureGate/`，并将 BrokerCapabilityMatrix future gate 放入 `Sources/ExecutionClient/BrokerCapabilityMatrix/`。这些文件只固定 future-gated capability taxonomy 和 forbidden implementation flags；它们不是 ExecutionClient implementation，不创建 broker adapter、exchange execution adapter、signed request、account endpoint request、order submit / cancel / replace、execution report parser、broker fill parser、reconciliation runtime、credential provider 或 network probe。

`MTP-188-BROKER-REAL-ORDER-FORBIDDEN-GUARD`

RiskEngine / ExecutionEngine / ExecutionClient 迁移后仍禁止 `RiskEngine -> broker`、`RiskEngine -> ExecutionClient`、`ExecutionEngine -> current OMS`、`ExecutionEngine -> broker adapter`、`ExecutionEngine -> ExecutionClient request`、`ExecutionClient -> signed request`、`ExecutionClient -> broker client` 和 paper / simulated evidence -> real order lifecycle bypass。Paper risk decision、paper order intent、paper lifecycle state、simulated fill、fee / slippage 和 BrokerCapabilityMatrix 只能作为 deterministic local evidence 或 future-gated label，不授权真实执行。

`MTP-188-REMAINING-COMPATIBILITY-SHELL`

MTP-188 后旧 `Sources/Core/PaperPreTradeRiskEngine.swift`、`Sources/Core/LiveRiskGateContract.swift`、`Sources/Core/LiveAuditIncidentStopContract.swift`、`Sources/Core/LiveExecutionControlContract.swift`、`Sources/Core/PaperExecutionWorkflowContract.swift`、`Sources/Core/PaperRuntimeKernelBoundary.swift`、`Sources/Core/PaperSessionLifecycle.swift`、`Sources/Core/PaperSessionLocalControlCommand.swift`、`Sources/Core/PaperSessionLocalControlEventLog.swift`、`Sources/Core/PaperSessionReplay.swift`、`Sources/Core/PaperOrderIntent.swift`、`Sources/Core/PaperOrderLifecycleCoordinator.swift`、`Sources/Core/PaperExecutionDecision.swift`、`Sources/Core/PaperExecutionEventLog.swift`、`Sources/Core/PaperSimulatedFillEvidence.swift`、`Sources/Core/SimulatedExchangeBacktestParityBoundary.swift`、`Sources/Core/MarketLimitSimulatedExecutionSemantics.swift`、`Sources/Core/PartialFillLatencyFeeSlippageParity.swift`、`Sources/Core/BacktestPaperSharedOrderSemantics.swift` 和 `Sources/Core/ExecutionCosts.swift` 不再保留。剩余 compatibility shell 是旧 `Core` SwiftPM target 名称，以及仍待 MTP-189 授权迁移的 Workbench / Dashboard source roots；`LiveTradingBoundary.swift` 仍保留在 `Core` 作为既有 L3 read-only multi-boundary compatibility file，不在 MTP-188 中强行迁移。

## MTP-189 Workbench / Dashboard Physical Migration

`MTP-189-WORKBENCH-DASHBOARD-PHYSICAL-MIGRATION`

MTP-189 执行 Workbench / Dashboard 的 directory-first source migration：Workbench read-model source chain 已迁入 `Sources/Workbench/ReadModels/`；Report evidence surfaces 已迁入 `Sources/Workbench/Report/`；Workbench beta / dashboard read-model assembly 已迁入 `Sources/Workbench/Dashboard/`；Event Timeline / Evidence Explorer 已迁入 `Sources/Workbench/Events/`；future Live PRO Console label 只作为 read-model-only boundary 放入 `Sources/Workbench/FutureLiveProConsole/`；macOS shell / smoke source 保持在 `Sources/Dashboard/`。

`MTP-189-APP-COMPATIBILITY-ENVELOPE`

MTP-189 保留现有 `App` SwiftPM product / target 名称作为 Workbench 迁移期兼容外壳：`App` target 继续编译 `Sources/Workbench/ReadModels/`、`Sources/Workbench/Report/`、`Sources/Workbench/Dashboard/`、`Sources/Workbench/Events/`、`Sources/Workbench/FutureLiveProConsole/` 和 `Sources/Dashboard/DashboardShell.swift`。该兼容壳只保持 buildability，不等同于新增 Workbench runtime 或 final target graph split。

`MTP-189-DASHBOARD-SHELL-BOUNDARY`

Dashboard executable 继续只装载 `DashboardApplication.swift` 并消费 App / Workbench 输出的稳定 `DashboardViewModel` 与 `DashboardShellSnapshot`。Dashboard shell 不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload 或 broker state，不提供 Live PRO Console、trading button、live command、order form、broker connect UI 或 account connect UI。

`MTP-189-WORKBENCH-READMODEL-ONLY-GUARD`

MTP-189 后旧 `Sources/App/` 不再作为 Workbench source owner 保留。Workbench / Report / Dashboard / Events 迁移后仍只能消费 ReadModel / ViewModel exports；future Live PRO Console 目录只保存 future-gated label / boundary evidence，不实现 command-capable UI 或 real trading path。

## MTP-190 Target Module Source Migration Stage Closeout

`MTP-190-TARGET-MODULE-SOURCE-MIGRATION-STAGE-CLOSEOUT`

MTP-190 将 `MTPRO Target Module Physical Layout / Source Migration v1` 的 source migration evidence chain 收口为 stage audit input material。该 closeout 只为 Parent Codex 后续 Stage Code Audit Report 提供输入，不设置 Linear Project `Completed`，不输出最终 Stage Code Audit Report，不授权下一阶段。

`MTP-190-STAGE-AUDIT-INPUT-MATERIAL`

Stage audit input material 固定在 `docs/audit/inputs/mtpro-target-module-physical-layout-source-migration-v1-stage-audit-input.md`，必须覆盖 validation matrix closeout、automation readiness closeout、MTP-183 至 MTP-189 issue / PR evidence、source migration closeout、remaining compatibility shell audit、forbidden implementation audit、unresolved future gates、Root Docs Delta input 和 Stage Code Audit handoff checklist。

`MTP-190-VALIDATION-MATRIX-CLOSEOUT`

MTP-190 必须把 `TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION` 扩展到 MTP-190 issue backfill，说明 MTP-183 至 MTP-189 的 target module physical source migration evidence 已形成可审计链路，但该 matrix 只证明 boundary-preserving source placement，不授权 SwiftPM target graph split、L4 execution、broker runtime、live runtime 或 command-capable product surface。

`MTP-190-AUTOMATION-READINESS-CLOSEOUT`

Automation readiness closeout 必须由 `checks/automation-readiness.sh` 机械检查 stage audit input、module-boundary docs、domain context、validation matrix、validation plan、latest summary 和 automation readiness doc。MTP-190 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

`MTP-190-REMAINING-COMPATIBILITY-SHELL-AUDIT`

MTP-190 必须明确当前 Project 完成的是 physical directory migration，而不是 final SwiftPM target graph split。`Core`、`Adapters`、`Runtime`、`App` 和 `Dashboard` 等 target / product 名称仍可作为 compatibility envelope 保持 buildability；后续真正 target split 必须由新的 Project Definition、dependency audit、validation matrix 和 Parent Codex queue preflight 授权。

`MTP-190-FORBIDDEN-IMPLEMENTATION-AUDIT`

Forbidden implementation audit 必须确认本 Project 未实现 Strategy runtime、Trader runtime、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、emergency stop、shutdown、restore 或 production operations command。

`MTP-190-UNRESOLVED-FUTURE-GATES`

Unresolved future gates 必须明确 SwiftPM target split、L4 Project Definition、signed / account gate、broker / execution gate、product surface gate、operations gate 和新的 validation gate 仍未打开，后续只能由 Human + `@001 / PLN` 独立规划。

`MTP-190-STAGE-CLOSEOUT-VALIDATION`

MTP-190 validation 必须证明 stage audit input material、validation matrix、automation readiness anchors、remaining compatibility shell audit 和 forbidden implementation audit 已落仓，并且 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 通过。

`MTP-190-NO-FINAL-STAGE-CODE-AUDIT`

MTP-190 不创建 L4 Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR` 或 Symphony，不运行 Graphify，不修改 Figma，不设置 Linear Project `Completed`，不输出最终 Stage Code Audit Report。

## MTP-216 SwiftPM Target Graph Split Contract

`MTP-216-SWIFTPM-TARGET-GRAPH-SPLIT-CONTRACT`

MTP-216 定义 `MTPRO SwiftPM Target Graph Module Split v1` 的 contract-first baseline。该合同只写明后续 target graph split 的目标模块、依赖方向、禁止导入和下游 issue 边界，不修改 `Package.swift`，不移动 production source，不新增 SwiftPM target / product / dependency。Canonical contract 位于 `docs/contracts/swiftpm-target-graph-split-contract.md`。

`MTP-216-CURRENT-COMPATIBILITY-ENVELOPE-SNAPSHOT`

当前 SwiftPM target graph 仍保留 `Core`、`Adapters`、`Persistence`、`Runtime`、`App`、`Dashboard` 和 `CSQLite` compatibility envelope。`Core` 仍编译 DomainModel、MessageBus、Cache、Trader/Accounts、Trader/Strategies/EMA、Trader/Coordination/RiskBinding、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient future gates 和 retained Core research evidence；该 snapshot 只保持 buildability，不代表 target graph 已拆分。

`MTP-216-CANONICAL-TARGET-GRAPH-BASELINE`

后续目标 SwiftPM module targets 是 `DomainModel`、`MessageBus`、`Database`、`DataClient`、`Cache`、`DataEngine`、`Portfolio`、`RiskEngine`、`ExecutionClient`、`ExecutionEngine`、`TraderStrategies`、`Trader`、`Workbench` 和 `Dashboard`。`TraderStrategies` 是 Trader-owned concrete strategy target，当前 active concrete strategy only `EMA`，canonical path only `Sources/Trader/Strategies/EMA/`。

`MTP-216-DEPENDENCY-DIRECTION-CONTRACT`

Dependency direction 固定为 `MessageBus -> DomainModel`、`Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)`、`DataClient -> DomainModel`、`Cache -> DomainModel / MessageBus`、`DataEngine -> DomainModel / DataClient / MessageBus / Cache`、`Portfolio -> DomainModel / MessageBus / Cache / Database`、`RiskEngine -> DomainModel / MessageBus / Cache / Portfolio`、`ExecutionClient -> DomainModel`、`ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient(future gate types only)`、`TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine`、`Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine / ExecutionEngine`、`Workbench -> ReadModel / ViewModel exports only`、`Dashboard -> Workbench`。

`MTP-216-FORBIDDEN-IMPORT-PATHS`

后续 split 必须继续禁止 `DataClient -> signed/account/listenKey/private runtime`、`DataClient -> ExecutionEngine / ExecutionClient / Trader / Workbench / Dashboard`、`Database -> Workbench / Dashboard / Trader / broker payload`、`TraderStrategies -> ExecutionClient / OMS / broker command / Workbench / Dashboard`、`Trader -> ExecutionClient`、`RiskEngine -> broker / ExecutionClient`、`ExecutionEngine -> current OMS / broker adapter / signed endpoint / account endpoint / listenKey`、`ExecutionClient -> signed request / real order lifecycle`、`Workbench -> Runtime object / Adapter request / Database schema / broker payload / account payload` 和 `Dashboard -> anything except Workbench`。

`MTP-216-TRADER-OWNED-STRATEGIES-TARGET-BOUNDARY`

多个策略后续按 `Sources/Trader/Strategies/<strategy>/` 管理。策略只消费 DomainModel / MessageBus / Cache / Portfolio / RiskEngine evidence/context 并提出 signal / paper-neutral proposal evidence；不能直连 ExecutionClient、broker、OMS、Dashboard、Workbench 或 UI command surface。`Sources/Trader/Coordination/RiskBinding/` 是 coordination adapter / binding boundary，不是 concrete strategy implementation landing path。

`MTP-216-MODULE-TO-TARGET-SPLIT-SEQUENCE`

MTP-217 负责 foundation target split；MTP-218 负责 DataClient / DataEngine / Cache split；MTP-219 负责 TraderStrategies / Trader / Portfolio / RiskEngine split；MTP-220 负责 ExecutionEngine / ExecutionClient future gate split；MTP-221 负责 Workbench / Dashboard read-model-only split；MTP-222 负责 obsolete compatibility envelope retirement；MTP-223 负责 validation matrix / automation readiness / stage audit input closeout。任何 issue 都必须等上一 issue PR/check/merge/root fast-forward/Linear Done/post-issue ledger evidence 完成后，才能由 Parent Codex queue preflight 推进。

`MTP-216-PACKAGE-SPLIT-NON-AUTHORIZATION`

MTP-216 不授权修改 `Package.swift` target graph、products、dependencies、source roots 或 exclude list，不授权新增 / 删除 / 重命名 SwiftPM target，不授权移动 source，不授权退休 compatibility envelope。

`MTP-216-NO-RUNTIME-LIVE-BROKER-L4`

MTP-216 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。

`MTP-216-TARGET-GRAPH-CONTRACT-VALIDATION`

MTP-216 validation 必须证明 contract file、root architecture、module-boundary、domain context、validation plan、validation matrix、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` anchors 已落仓，并且 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh` 通过。

## MTP-217 Foundation Target Split

`MTP-217-FOUNDATION-TARGET-SPLIT-EVIDENCE`

MTP-217 新增 `DomainModel`、`MessageBus` 和 `Database` SwiftPM library products / targets。该 evidence 是 foundation target split 的第一段，只证明 target graph 开始可编译，不退休旧 compatibility envelope。

`MTP-217-DOMAINMODEL-TARGET-SPLIT`

`DomainModel` target 编译 `Sources/TargetGraph/DomainModel/DomainModelTargetBoundary.swift`，不依赖业务 target；canonical source root 仍记录为 `Sources/DomainModel/`。

`MTP-217-MESSAGEBUS-TARGET-SPLIT`

`MessageBus` target 编译 `Sources/TargetGraph/MessageBus/MessageBusTargetBoundary.swift`，只依赖 `DomainModel`。既有 `Sources/MessageBus/` 继续由 `Core` compatibility envelope 编译，后续 retirement 归 MTP-222。

`MTP-217-DATABASE-TARGET-SPLIT`

`Database` target 编译 `Sources/TargetGraph/Database/DatabaseTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`CSQLite` 和 macOS 条件 `DuckDB`。既有 SQLite / DuckDB projection implementation 继续由 `Persistence` compatibility envelope 编译。

`MTP-217-FOUNDATION-DEPENDENCY-DIRECTION`

Foundation direction 固定为 `DomainModel`、`MessageBus -> DomainModel`、`Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)`。禁止 `DomainModel` / `MessageBus` / `Database` 依赖 DataEngine、Trader、TraderStrategies、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench、Dashboard、broker、OMS、account endpoint 或 private stream runtime。

`MTP-217-FOUNDATION-COMPATIBILITY-ENVELOPE-RETAINED`

`Core` 继续保留 `Sources/DomainModel/`、`Sources/MessageBus/` 兼容编译；`Persistence` 继续保留 `Sources/Database/Projections/` 兼容编译；`TargetGraph` 被 `Core` / `Runtime` / `App` compatibility targets 排除。

`MTP-217-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 import `DomainModel`、`MessageBus` 和 `Database`，验证 target graph split evidence、dependency direction 和 no higher-layer runtime / broker / UI drift。

`MTP-217-NO-RUNTIME-LIVE-BROKER-L4-GUARD`

MTP-217 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

## MTP-218 Data Target Split

`MTP-218-DATA-TARGET-SPLIT-EVIDENCE`

MTP-218 新增 `DataClient`、`DataEngine` 和 `Cache` SwiftPM library products / targets。该 evidence 是 data-layer target split 的第二段，只证明 target graph 可编译和 dependency direction 已落仓，不退休旧 compatibility envelope。

`MTP-218-DATACLIENT-TARGET-SPLIT`

`DataClient` target 编译 `Sources/TargetGraph/DataClient/DataClientTargetBoundary.swift`，只依赖 `DomainModel`。既有 `Sources/DataClient/Binance/PublicMarketData/` 继续由 `Adapters` compatibility envelope 编译，后续 retirement 归 MTP-222。

`MTP-218-CACHE-TARGET-SPLIT`

`Cache` target 编译 `Sources/TargetGraph/Cache/CacheTargetBoundary.swift`，依赖 `DomainModel` 和 `MessageBus`。既有 `Sources/Cache/` 继续由 `Core` compatibility envelope 编译；Cache 只表达 read-model state surface，不拥有 durable facts、Database schema、broker state 或 account payload。

`MTP-218-DATAENGINE-TARGET-SPLIT`

`DataEngine` target 编译 `Sources/TargetGraph/DataEngine/DataEngineTargetBoundary.swift`，依赖 `DomainModel`、`DataClient`、`MessageBus` 和 `Cache`。既有 `Sources/DataEngine/Ingest/`、`Sources/DataEngine/ScenarioReplay/` 和 `Sources/DataEngine/DataQuality/` 继续由 `Core` / `Runtime` compatibility envelope 编译。

`MTP-218-DATACLIENT-DATAENGINE-CACHE-DEPENDENCY-DIRECTION`

Data-layer direction 固定为 `DataClient -> DomainModel`、`Cache -> DomainModel / MessageBus`、`DataEngine -> DomainModel / DataClient / MessageBus / Cache`。禁止 `DataClient` / `DataEngine` / `Cache` 依赖 Trader、TraderStrategies、RiskEngine、ExecutionEngine、ExecutionClient、Workbench、Dashboard、broker、OMS、signed endpoint、account endpoint、listenKey、private stream runtime、Database schema 或 broker state。

`MTP-218-PUBLIC-READ-ONLY-DATA-BOUNDARY`

`DataClient` 仍是 public read-only data boundary；不调用 signed endpoint，不调用 account endpoint，不创建 listenKey，不连接 broker / execution adapter，不读取真实账户 / 持仓 / 余额。

`MTP-218-READMODEL-STATE-SURFACE`

`Cache` 仍是 read-model state surface；只表达 instruments、market data、orders、positions 和 portfolio summary 的 runtime-derived state boundary，不表达 durability、schema ownership、broker payload 或 account payload。

`MTP-218-DATA-COMPATIBILITY-ENVELOPE-RETAINED`

`Adapters` 继续保留 DataClient public market data compatibility compile surface；`Core` 继续保留 cache、scenario replay 和 data quality compatibility compile surface；`Runtime` 继续保留 ingest compatibility compile surface；`TargetGraph` 继续从旧 compatibility targets 中排除。

`MTP-218-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 import `DataClient`、`DataEngine` 和 `Cache`，验证 data target split evidence、dependency direction 和 no signed / account / listenKey / broker / runtime drift。

`MTP-218-NO-SIGNED-ACCOUNT-BROKER-GUARD`

MTP-218 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

## MTP-219 Trader / Portfolio / Risk Target Split

`MTP-219-TRADER-PORTFOLIO-RISK-TARGET-SPLIT-EVIDENCE`

MTP-219 新增 `TraderStrategies`、`Trader`、`Portfolio` 和 `RiskEngine` SwiftPM library products / targets。该 evidence 是 coordination / financial state / pre-execution risk target split 的第三段，只证明 target graph 可编译和 dependency direction 已落仓，不退休旧 compatibility envelope。

`MTP-219-TRADERSTRATEGIES-TARGET-SPLIT`

`TraderStrategies` target 编译 `Sources/TargetGraph/TraderStrategies/TraderStrategiesTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio` 和 `RiskEngine`。当前 active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`。

`MTP-219-TRADER-TARGET-SPLIT`

`Trader` target 编译 `Sources/TargetGraph/Trader/TraderTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache`、`TraderStrategies`、`Portfolio` 和 `RiskEngine`。`ExecutionEngine` target 归 MTP-220 拆分，因此本 issue 只记录 deferred dependency。

`MTP-219-PORTFOLIO-TARGET-SPLIT`

`Portfolio` target 编译 `Sources/TargetGraph/Portfolio/PortfolioTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache` 和 `Database`。Portfolio 只表达 financial state projection，不拥有 Trader account identity，不读取 broker account state 或 account endpoint payload。

`MTP-219-RISKENGINE-TARGET-SPLIT`

`RiskEngine` target 编译 `Sources/TargetGraph/RiskEngine/RiskEngineTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache` 和 `Portfolio`。RiskEngine 只表达 pre-execution risk boundary，不实现 live risk runtime、broker route、ExecutionClient wrapper 或 executable order command router。

`MTP-219-TRADER-PORTFOLIO-RISK-DEPENDENCY-DIRECTION`

Direction 固定为 `Portfolio -> DomainModel / MessageBus / Cache / Database`、`RiskEngine -> DomainModel / MessageBus / Cache / Portfolio`、`TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine`、`Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine`，并把 `Trader -> ExecutionEngine` 延后到 MTP-220。

`MTP-219-EMA-ONLY-ACTIVE-STRATEGY-BOUNDARY`

当前 active concrete strategy only `EMA`，canonical active source root only `Sources/Trader/Strategies/EMA/`。非 EMA strategy 不得作为 active source root、Package source root、test root 或 target source root 回流。

`MTP-219-TRADER-CONTAINER-ACCOUNTS-EMA-COORDINATION`

Trader container 保持 `Accounts + Strategies/EMA + Coordination`：`Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Coordination/RiskBinding/` 是当前三段 active container；旧 `Sources/Trader/StrategyBindings/` 和 peer-level `Sources/Strategies/` 不得回流。

`MTP-219-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 import `TraderStrategies`、`Trader`、`Portfolio` 和 `RiskEngine`，验证 target split evidence、dependency direction、Trader container completeness、EMA-only active strategy 和 no direct execution / broker / runtime drift。

`MTP-219-NO-DIRECT-EXECUTION-GUARD`

MTP-219 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real account read、broker payload read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

## MTP-220 ExecutionEngine / ExecutionClient Target Split

`MTP-220-EXECUTION-TARGET-SPLIT-EVIDENCE`

MTP-220 新增 `ExecutionClient` 和 `ExecutionEngine` SwiftPM library products / targets。该 evidence 是 execution target split 的第四段，只证明 target graph 可编译和 dependency direction 已落仓，不退休旧 compatibility envelope。

`MTP-220-EXECUTIONCLIENT-TARGET-SPLIT`

`ExecutionClient` target 编译 `Sources/TargetGraph/ExecutionClient/ExecutionClientTargetBoundary.swift`，依赖 `DomainModel` 和 `MessageBus`。ExecutionClient 只表达 future gate / protocol boundary，不实现 broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、execution report、broker fill 或 reconciliation。

`MTP-220-EXECUTIONENGINE-TARGET-SPLIT`

`ExecutionEngine` target 编译 `Sources/TargetGraph/ExecutionEngine/ExecutionEngineTargetBoundary.swift`，依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio`、`RiskEngine` 和 `ExecutionClient`。ExecutionEngine 只表达 paper / simulated lifecycle boundary 和 OMS future gate evidence，不实现 live execution runtime、OMS implementation、broker gateway 或 executable live order command。

`MTP-220-RISKENGINE-EXECUTIONENGINE-EXECUTIONCLIENT-DIRECTION`

Direction 固定为 `ExecutionClient -> DomainModel / MessageBus`、`ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient`，并把 MTP-219 延后的 `Trader -> ExecutionEngine` dependency 解析为正式 target dependency。RiskEngine 不直连 ExecutionClient / broker；Trader 仍不能直连 ExecutionClient、broker、OMS 或 UI command surface。

`MTP-220-TRADER-EXECUTIONENGINE-DEPENDENCY-RESOLVED`

`TraderTargetBoundary` 在 MTP-220 直接依赖 `ExecutionEngineTargetBoundary`，但继续保持 no direct ExecutionClient、no broker / OMS、no real account payload 和 no live command surface guard。

`MTP-220-EXECUTIONCLIENT-FUTURE-GATE-ONLY`

ExecutionClient 只保留 future-gated outgoing adapter contract；BrokerCapabilityMatrix 仍是 future capability taxonomy，不是 capability discovery runtime、credential check、network probe、API key input 或 secret storage。

`MTP-220-EXECUTION-COMPATIBILITY-ENVELOPE-RETAINED`

`Core` 继续编译既有 `Sources/ExecutionEngine/` 和 `Sources/ExecutionClient/` source roots；MTP-220 不迁移 existing implementation，不退休 compatibility envelope。

`MTP-220-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 import `ExecutionClient` 和 `ExecutionEngine`，验证 target split evidence、dependency direction、Trader dependency resolution 和 no broker / OMS / real order / endpoint drift。

`MTP-220-NO-BROKER-OMS-REAL-ORDER-GUARD`

MTP-220 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real account read、broker payload read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。

## MTP-221 Workbench / Dashboard Target Split

`MTP-221-WORKBENCH-DASHBOARD-TARGET-SPLIT-EVIDENCE`

MTP-221 新增 `Workbench` SwiftPM library product / target，并把既有 `Dashboard` executable target 改为直接依赖 `Workbench`。该 evidence 是 read-model consumption target split 的第五段，只证明 target graph 可编译和 dependency direction 已落仓，不退休旧 `App` compatibility export。

`MTP-221-WORKBENCH-TARGET-SPLIT`

`Workbench` target 编译 `Sources/Workbench/ReadModels/`、`Sources/Workbench/Report/`、`Sources/Workbench/Dashboard/`、`Sources/Workbench/Events/`、`Sources/Workbench/FutureLiveProConsole/`、`Sources/Workbench/TargetGraph/WorkbenchTargetBoundary.swift` 和 `Sources/Dashboard/DashboardShell.swift`，依赖 `Core` 和 `Persistence`。Workbench 只能消费 read model / ViewModel / projection snapshot，不直接读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload 或 broker state。

`MTP-221-DASHBOARD-TARGET-SPLIT`

`Dashboard` executable target 编译 `Sources/Dashboard/DashboardApplication.swift` 和 `Sources/Dashboard/DashboardTargetBoundary.swift`，只依赖 `Workbench`。Dashboard 只装载 Workbench ViewModel snapshot，不直接依赖 Core、Persistence、Adapters、Runtime、ExecutionClient、broker、OMS、schema、account payload 或 live command。

`MTP-221-WORKBENCH-DASHBOARD-DEPENDENCY-DIRECTION`

Direction 固定为 `Workbench -> Core / Persistence read-model and ViewModel exports only`、`Dashboard -> Workbench`、`App -> Workbench compatibility re-export`。`App` compatibility export 的退休归 MTP-222。

`MTP-221-READ-MODEL-VIEWMODEL-ONLY`

Workbench / Dashboard 只能消费已存在的 Report、Dashboard、Events、Evidence Explorer 和 read-model-only evidence surface，不把 UI display surface 升级为 Runtime object、Adapter request、schema access、account payload、broker payload、broker state 或 live command surface。

`MTP-221-APP-COMPATIBILITY-EXPORT-RETAINED`

`App` target 现在只通过 `Sources/AppCompatibility/AppCompatibility.swift` re-export `Workbench`，用来维持既有 `import App` tests / call surface。MTP-221 不删除 `App` product / target。

`MTP-221-TARGETGRAPH-TEST-EVIDENCE`

`Tests/TargetGraphTests/TargetGraphTests.swift` 直接 import `Workbench` 和 `Dashboard`，验证 target split evidence、dependency direction、App compatibility export 和 no runtime / adapter / schema / UI command drift。

`MTP-221-NO-UI-COMMAND-RUNTIME-SCHEMA-GUARD`

MTP-221 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real account read、broker payload read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。

## 架构图模块到目标目录

| 架构图模块 | 固定目标目录 | 边界说明 |
| --- | --- | --- |
| DataClient | `Sources/DataClient/<venue>/` | 一个交易所一个目录；`Binance/PublicMarketData` 承载当前 public read-only client，private stream 只能进入同交易所下的 future gate；signed/account/listenKey 禁止。 |
| DataEngine | `Sources/DataEngine/` | ingest、subscription/request/response contract、scenario replay、data quality。 |
| MessageBus | `Sources/MessageBus/` | facts、events、commands、request/response、engine routing、replay invariant；不能绕过 risk/execution boundary。 |
| Cache | `Sources/Cache/` | in-memory / runtime-derived read state：instruments、market data、orders、positions、portfolio summary；不负责 durability、schema、EventLog 或 DB adapter。 |
| Database | `Sources/Database/` | durable local backing store：append-only event log、snapshot、SQLite / DuckDB projection、replay projection；不直接驱动 UI，不复制 Redis 实现。 |
| Strategies | `Sources/Trader/Strategies/<strategy>/` | Trader-owned concrete strategy definitions；MTP-201 后当前 active concrete strategy 只有 EMA，位于 `Sources/Trader/Strategies/EMA/`；OrderBookImbalance 只保留在 `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` 作为 historical research evidence；具体策略仍不能直连 ExecutionClient。 |
| Trader | `Sources/Trader/` | account / strategy / risk / execution coordination boundary；MTP-205 后 current active relationship 是 `Trader = Accounts + Strategies/EMA + Coordination`，`StrategyBindings` 只作为 historical / superseded context 保留，当前只允许 identity / lifecycle / read-model input。 |
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
| `Core` strategy readiness / proposal contracts | `Sources/Trader/Strategies/<strategy>/`、`Sources/Trader/` | strategy lifecycle、quoter / hedger、signals、proposal 按策略进入 `Trader/Strategies/<strategy>`；旧 `Sources/Strategies/<strategy>/` 仅为 MTP-187 compatibility / superseded source；Trader 保留 coordination / account context / generic strategy binding。 |
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
