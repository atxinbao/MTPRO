# MTPRO Domain Context

日期：2026-05-20

执行者：Codex

## 定位

本文档是 MTPRO 的 shared language / 领域上下文入口。

它只定义稳定词汇和禁止混用的说法，不是 spec，不是 implementation plan，不授权创建 Linear Project / Issue，不授权推进 `Todo`，不启动 Symphony，不写业务代码。

来源：`mattpocock/skills` 的 shared language / `CONTEXT.md` 思路。参考 `https://github.com/mattpocock/skills`、`https://github.com/mattpocock/skills/blob/main/CONTEXT.md`、`https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs`。

## Project / Execution Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Project Charter` | `GOAL.md`，说明为什么建、服务谁、硬边界和成功标准 | 不叫完整蓝图 |
| `Root Blueprint` | `BLUEPRINT.md`，项目总览、默认读取顺序和完整蓝图入口 | 不授权执行 |
| `Complete Blueprint` | `BLUEPRINT.md`，最终产品 / 系统 / 设计蓝图 | 不叫当前 sprint，不叫 issue plan |
| `Engineering Module Map / 工程模块地图` | `docs/architecture.md`，承接 `BLUEPRINT.md` 的工程模块、模块边界、数据流、接口关系和架构不变量 | 不等于完整未来蓝图，不推翻蓝图 |
| `Construction Plan` | `docs/roadmap.md`，根据蓝图和工程模块定义施工顺序、当前施工阶段、完成进度和非授权边界 | 不等于 Linear queue |
| `Current Construction Scope` | Human 当前允许进入规划的施工范围 | 不包含 Future Construction Zones / 未来建设区 |
| `Future Construction Zones / 未来建设区` | 完整蓝图中的长期能力区，例如 Live、signed endpoint、broker、OMS；可以设计，但当前不施工 | 不得自动变成 Linear issue |
| `Project Planning Record` | 仓库中的 Project 级计划摘要，位于 `docs/planning/projects/` | 不复制完整 Linear issue body |
| `Linear execution contract` | Linear issue body 中的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements | 不由仓库文档替代 |
| `configured executable issue` | Linear live-read 中通过 Parent Codex queue preflight 后唯一可执行 issue | 不等于 Backlog issue |
| `Parent Codex queue preflight` | `@002 / PAR` 在 Project 内确认 WIP=1、依赖、contract 和 active conflict 的检查 | 不等于 symphony-issue 执行 |
| `symphony-issue` | 调度唯一 `Todo` issue 的执行层 actor | 不创建 Project，不做 planning |
| `Stage Code Audit Report` | Project 全部 Done 后由 Parent Codex 单独输出并落仓的 Project 级审计报告 | 不由 child issue 输出 |
| `Root Docs Refresh Gate` | Project closure 后把已发生代码事实同步回 root docs 的 gate | 不决定下一阶段方向 |
| `Current Phase Progress Bar` | `@002 / PAR` 按 `GOAL.md` / `docs/roadmap.md` 目标切片输出的阶段完成进度 | 不按 Project 数量直接计算 |

## Runtime / App Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Market Data` | Binance public read-only 行情数据 | 不包含 account、listenKey、signed endpoint |
| `Event Log` | append-only facts source | 不叫 UI model，不保存 runtime object |
| `Replay` | 从 facts source 重建 projection / evidence 的确定性路径 | 不叫生产恢复系统 |
| `Projection` | SQLite / DuckDB 或内存读模型中的派生视图 | 不作为 UI contract |
| `Read Model` | App / Dashboard 可以消费的稳定只读数据结构 | 不暴露 database schema |
| `ViewModel` | Dashboard / Workbench 绑定的 UI 输入 | 不直接读取 adapter、runtime object 或 persistence schema |
| `Command Model` | 本地 paper-only session-level 控制意图模型 | 不表示真实交易命令 |
| `Report Artifact` | 汇总 research / backtest / paper / risk / event evidence 的研究输出 | 不授权真实交易 |
| `Event Timeline` | read-model-only 的 evidence 浏览视图 | 不做完整查询语言，不暴露 persistence |

## Architecture-Graph-Aligned Module Boundary Terms

`MTP-162-ARCHITECTURE-GRAPH-ALIGNED-MODULE-BOUNDARY-TERMS`

以下术语由 MTP-162 定义为 `MTPRO Engine Module Boundary Consolidation v1` 的第一层 architecture-graph-aligned module boundary language。它们只用于把架构图模块翻译成 MTPRO target boundary、source layout 输入和 validation anchors，不授权移动业务代码，不授权 Strategy runtime / Trader runtime / Live runtime，不授权 ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、real order lifecycle、Live PRO Console、trading button、live command 或 order form。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `architecture-graph-aligned module boundary` | 架构图模块和 MTPRO 目标目录 / 目标职责之间的 canonical translation layer | 不等于当前 SwiftPM target，不授权立即迁移代码 |
| `target module name` | 可以进入 `docs/architecture/module-boundary.md`、规划记录和后续 issue contract 的目标模块名 | 不表示模块已存在运行时实现 |
| `migration source / compatibility shell` | 当前 `Core / Adapters / Persistence / Runtime / App / Dashboard / CSQLite` 只作为迁移来源和兼容壳 | 不作为新增能力落点，不作为最终架构名 |
| `DomainModel` | symbol、instrument、time、price、quantity、order / account / position value object 的 pure domain boundary | 不依赖 adapter、persistence、Runtime actor 或 UI |
| `DataClient` | exchange-scoped client boundary；当前只允许 Binance public read-only market data，future private stream / signed / account source 只能 gated | 不等于 execution adapter，不调用 account endpoint 或 listenKey |
| `DataEngine` | ingest、request / response、scenario replay、data quality 和 catalog 的 engine boundary | 不承担 broker connection、execution routing 或 UI state |
| `MessageBus` | facts、events、commands、request / response、engine routing 和 replay invariant 的边界 | 不绕过 RiskEngine / ExecutionEngine，不表示 live command bus |
| `Cache` | instruments、market data、orders、positions、portfolio summary 的 in-memory / runtime-derived read state boundary | 不负责 durability、schema、DB adapter 或真实 account cache |
| `Database` | append-only event log、snapshot、projection database 和 replay backing store 的 local durable boundary | 不暴露 SQLite / DuckDB schema 给 UI，不复制 Redis |
| `Strategies` | strategy lifecycle、quoter / hedger、signals 和 paper/live-neutral proposals 的 strategy-scoped boundary | 不直连 Trader、ExecutionClient、broker command 或 OMS |
| `Trader` | account context、strategy binding、risk / execution coordination 的 orchestration boundary | 不表示当前 Trader runtime、process manager 或 broker session |
| `Account context` | `Trader/Accounts` 内的 account identity、source identity 和 future real account gate | 不拥有 cash、positions、PnL、margin、leverage 或真实账户 payload |
| `Portfolio` | positions、net positions、cash / equity、margin、open value、paper projection 和 exposure read model boundary | 不读取 broker portfolio，不等于 Trader 子状态 |
| `RiskEngine` | paper pre-trade risk、blocked evidence 和 future live risk gates 的 risk boundary | 不调用 broker / ExecutionClient，不实现 live risk runtime |
| `ExecutionEngine` | paper lifecycle、simulated lifecycle、future OMS boundary 和 future execution routing 的 internal execution boundary | 不等于 broker client，不提交 / 取消 / 替换真实订单 |
| `ExecutionClient` | future exchange / broker execution client capability boundary | 当前只允许 module name / future gate，不实现 broker / exchange execution adapter |
| `Workbench` | ReadModel / ViewModel / Dashboard / Report / Events 的 read-model-only consumption boundary | 不读取 runtime object、adapter request、Database schema 或 broker payload |
| `Future Live PRO Console` | 完整蓝图中的 future product surface，用于后续 Human + `@001 / PLN` 决策和独立 Project planning | 不等于当前 Workbench，不提供交易按钮、live command 或 order form |

`MTP-162-OLD-TO-TARGET-MODULE-MAPPING`

旧 target 到目标模块只能按迁移来源解释：`Core` 拆向 `DomainModel` / `MessageBus` / `RiskEngine` / `ExecutionEngine` / `Portfolio` / `Strategies` / `Trader`；`Adapters` 拆向 `DataClient`；`Runtime` 拆向 `DataEngine` / `MessageBus` / `Cache`；`Persistence` 拆向 `Database` / `Cache`；`App` 和 `Dashboard` 拆向 `Workbench` / `Dashboard`；`CSQLite` 只保留为 `Database` implementation detail。该 mapping 不授权新增 runtime，不授权把旧 target 继续当作最终模块。

`MTP-162-FUTURE-GATED-MODULE-NAME-NON-AUTHORIZATION`

`ExecutionClient`、`OMSFutureGate`、`FuturePrivateStreamGate`、`FutureLiveProConsole`、`Strategy runtime`、`Trader runtime`、`Portfolio runtime`、`Risk runtime` 和完整 `MessageBus` 可以作为目标架构词出现，但出现本身不表示当前 runtime implementation。后续实现必须重新满足 Human decision、Linear issue contract、Parent Codex queue preflight、PR evidence 和 validation gate。

`MTP-162-ARCHITECTURE-MODULE-TERMINOLOGY-VALIDATION`

MTP-162 的验证只证明目标模块术语、旧术语映射、future-gated module non-authorization 和 forbidden capability baseline 已落仓；不证明任何 source move、SwiftPM target move、runtime actor、signed/account/listenKey endpoint、broker / exchange execution adapter、OMS、real order lifecycle、Live PRO Console、trading button、live command 或 order form 已实现。

`MTP-163-FIXED-TARGET-SOURCE-MODULE-LAYOUT`

MTP-163 把 MTP-162 的术语固定成唯一 source layout contract：后续模块迁移只能落到 `Sources/DomainModel/`、`Sources/DataClient/<venue>/`、`Sources/DataEngine/`、`Sources/MessageBus/`、`Sources/Cache/`、`Sources/Database/`、`Sources/Strategies/<strategy>/`、`Sources/Trader/`、`Sources/Portfolio/`、`Sources/RiskEngine/`、`Sources/ExecutionEngine/`、`Sources/ExecutionClient/`、`Sources/Workbench/` 和 `Sources/Dashboard/`。该 layout 是后续 issue 的目标地形，不表示本 issue 已移动文件、修改 `Package.swift` 或创建 SwiftPM target。

MTP-191 之后，MTP-163 中的 `Sources/Strategies/<strategy>/` 只作为 historical / compatibility / superseded layout anchor 保留；forward-looking concrete strategy canonical path 是 `Sources/Trader/Strategies/<strategy>/`。

`MTP-163-DEPENDENCY-DIRECTION-CONTRACT`

MTP-163 固定依赖方向：`DataClient` 只依赖 `DomainModel`；`DataEngine` 通过 `DataClient` / `MessageBus` / `Cache` 处理 ingest 和 replay；`Strategies` 只能消费 domain / bus / cache / Portfolio / RiskEngine read-model inputs；`Trader` 可以协调 Strategies / Portfolio / RiskEngine / ExecutionEngine，但不得直连 `ExecutionClient`；`Workbench` 只能消费 ReadModel / ViewModel export。

`MTP-163-FORBIDDEN-PATH-TAXONOMY`

MTP-163 的 forbidden path taxonomy 包括：Strategies -> ExecutionClient、Trader -> ExecutionClient、Workbench -> Runtime object、Workbench -> Adapter request、Workbench -> Database schema、DataClient -> signed/account/listenKey endpoint、RiskEngine -> broker / execution client、Portfolio -> broker account state、ExecutionEngine -> current broker / OMS implementation，以及任何 Live PRO Console / trading button / live command / order form 路径。该 taxonomy 只用于 validation 和后续 migration guard。

`MTP-163-DATACLIENT-VENUE-STRATEGIES-STRATEGY-DIRECTORY-RULE`

`DataClient/<venue>/` 是 exchange / venue scoped rule，一个交易所一个目录；MTP-163 的 `Strategies/<strategy>` 是历史 strategy scoped rule。MTP-191 之后，后续 strategy scoped rule 是 `Trader/Strategies/<strategy>`，一个策略一个目录；当前示例只能表达 `DataClient/Binance/PublicMarketData`、`DataClient/Binance/FuturePrivateStreamGate` 和 historical / compatibility `Strategies/EMA/` 目录语义，不授权 private stream runtime、signed/account endpoint、strategy runtime 或 trader process manager。

`MTP-163-TRADER-ACCOUNT-PORTFOLIO-SPLIT`

`Trader/Accounts` 只保存 account context、account identity、source identity 和 future real account gate；cash、positions、PnL、exposure、margin、open value、paper projection 和 future real account read-model boundary 属于独立 `Portfolio`。这条 split 防止后续把 Trader 变成账户账本、broker gateway 或 live coordinator。

`MTP-163-EXECUTIONENGINE-EXECUTIONCLIENT-SPLIT`

`ExecutionEngine` 只表达内部 paper / simulated lifecycle、simulated fill、fee / slippage、portfolio projection 和 future OMS boundary；`ExecutionClient` 只表达 future venue API client gate。MTP-163 不实现 broker / exchange execution adapter、signed request、order submit / cancel / replace、execution report parser、broker fill 或 reconciliation runtime。

`MTP-163-FIXED-LAYOUT-VALIDATION`

MTP-163 的验证只证明 fixed layout、dependency direction、forbidden path taxonomy 和 source layout anchors 已落仓；不证明任何 source move、Package.swift target graph change、runtime implementation、live broker path、OMS 或 command-capable product surface 已实现。

`MTP-164-ARCHITECTURE-BOUNDARY-VALIDATION-ANCHORS`

MTP-164 把 MTP-162 terminology 与 MTP-163 fixed layout 转成 cross-milestone validation anchors。后续 M2-M6 issue 必须继续证明 target module name、fixed target source layout、dependency direction 和 forbidden path taxonomy 被保留，不得把 validation anchor 解读成 runtime implementation、source move 或 SwiftPM target graph change。

`MTP-164-OLD-PATH-DRIFT-GUARD`

Old path drift guard 固定 `Core / Adapters / Persistence / Runtime / App / Dashboard / CSQLite` 只能作为 migration source / compatibility shell。后续 issue 不得把这些旧路径写成最终目标结构、长期新增能力落点或新的 architecture module name；任何新增 module boundary 必须映射到 MTP-163 的固定 `Sources/*` 目标目录。

`MTP-164-FUTURE-GATED-IMPLEMENTATION-DRIFT-GUARD`

Future-gated implementation drift guard 固定 `ExecutionClient`、`OMSFutureGate`、`FuturePrivateStreamGate`、`FutureLiveProConsole`、`Strategy runtime`、`Trader runtime`、`Portfolio runtime`、`Risk runtime` 和完整 `MessageBus` 只能作为 target boundary / future gate / validation label 出现。它们不得被写成 current runtime implementation、broker adapter、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle 或 command-capable UI。

`MTP-164-FORBIDDEN-CAPABILITY-DRIFT-GUARD`

Forbidden capability drift guard 固定 Strategy / Trader / Workbench / DataClient / ExecutionClient 的禁止路径：`Strategies -> ExecutionClient`、`Trader -> ExecutionClient`、`Workbench -> Runtime object / Adapter request / Database schema`、`DataClient -> signed/account/listenKey/private runtime`、`RiskEngine -> broker / ExecutionClient`、`Portfolio -> broker account state`、`ExecutionEngine -> current OMS / broker adapter` 和 `FutureLiveProConsole -> current Workbench command surface`。这些 guard 是 local docs/checks validation 输入，不授权 live runtime、broker path、Graphify 或 Figma。

`MTP-164-CROSS-MILESTONE-VALIDATION-INPUT`

MTP-164 的 anchors 是后续 MessageBus / Cache / Database、DataClient / DataEngine、Strategies / Trader / Portfolio、RiskEngine / ExecutionEngine / ExecutionClient、Workbench / Future Live PRO Console 和 stage closeout 的共同 validation input。每个后续 issue 都必须复用这些 anchors 证明 no old path drift、no future-gated implementation drift 和 no forbidden capability drift。

`MTP-164-ARCHITECTURE-BOUNDARY-VALIDATION`

MTP-164 的验证只证明 architecture boundary validation anchors 已落仓，并由 `checks/automation-readiness.sh` 机械检查；不证明 source move、business code migration、Package.swift target graph change、runtime actor、live broker path、OMS、ExecutionClient implementation 或 command-capable product surface 已实现。

`MTP-165-MESSAGEBUS-FACTS-COMMANDS-EVENTS-CONTRACT`

MTP-165 固定 `MessageBus` 为 facts / events / commands 的本地边界：facts 是 append-only `DomainEvent` evidence，events 是 facts 的领域分类和 stream envelope，commands 是本地 paper / replay / research 意图输入。MessageBus 只能承载这些可 replay 的本地语义，不表示 live command bus、external broker message broker、OMS bus 或真实 order command plane。

`MTP-165-REQUEST-RESPONSE-CONTRACT`

MessageBus request-response 只允许 engine-local deterministic request / response evidence，用于 DataEngine ingest、Strategies proposal input、Trader coordination input、RiskEngine pre-check input、ExecutionEngine paper lifecycle input 和 Portfolio projection input。它不暴露 HTTP API、Adapter request、Database schema、Runtime object、account payload、broker payload 或 UI command surface。

`MTP-165-PAPER-ROUTING-REPLAY-INVARIANT`

MTP-165 复用既有 `PaperRuntimeMessageBusRouting`、`MessageBus.publish`、`AppendOnlyEventLog` 和 `EventReplayCommand` 语义：routing 必须写入 append-only facts，并能从 Event Log / Replay 重建 route evidence、correlation、causation 和 stream。Replay invariant 不能升级成 production recovery、broker replay、account replay 或 live incident replay runtime。

`MTP-165-ENGINE-DEPENDENCY-BRIDGE`

MessageBus 是 DataEngine、Strategies、Trader、RiskEngine、ExecutionEngine 和 Portfolio 之间的 evidence bridge。DataEngine publish market / replay facts；Strategies publish proposal / signal facts；Trader 只协调 context；RiskEngine publish risk evidence；ExecutionEngine publish paper lifecycle / simulated fill facts；Portfolio 只消费 facts 形成 projection。任何模块都不得用 MessageBus 绕过 RiskEngine / ExecutionEngine boundary。

`MTP-165-RISK-EXECUTION-BYPASS-GUARD`

MessageBus 禁止承载 executable order command、broker command、ExecutionClient request、OMS order、signed request、account endpoint request、listenKey operation、private WebSocket runtime message、Live PRO Console command、trading button command 或 order form payload。Strategy / Trader / Workbench 不能通过 MessageBus 直连 ExecutionClient、broker、database schema 或 runtime object。

`MTP-165-MESSAGEBUS-BOUNDARY-VALIDATION`

MTP-165 的验证只证明 MessageBus facts / commands / events / request-response / paper routing / replay invariant 与 bypass guards 已落仓；不证明完整 runtime MessageBus、broker integration、OMS、ExecutionClient implementation、live command path、UI command surface 或 source migration 已实现。

`MTP-166-CACHE-RUNTIME-DERIVED-STATE-CONTRACT`

MTP-166 固定 `Cache` 为 runtime-derived state 边界：instruments、market data、paper orders、paper positions、account summary 和 portfolio summary 只能来自 MessageBus facts、local replay、paper / simulated lifecycle 或 read-model projection。Cache 是可重建的本地状态视图，不是 durable source of truth、Database schema、UI contract、broker account cache 或 external cache service。

`MTP-166-CACHE-DURABILITY-SCHEMA-SEPARATION`

Cache 不拥有 durability、schema ownership、DB adapter、SQLite / DuckDB projection、append-only Event Log 或 snapshot lifecycle。durable facts 归 MessageBus / Event Log，持久化和 projection 归 Database，Cache 只保存当前运行期可从 facts / replay / projection 重建的派生状态。

`MTP-166-CACHE-DATABASE-MESSAGEBUS-RELATIONSHIP`

Cache 只能消费 MessageBus facts、Database projection snapshot 和 local replay output 来形成 runtime read state；它不能向 Database 写 schema，不能替代 MessageBus publish / replay invariant，也不能绕过 DataEngine、Portfolio、RiskEngine 或 ExecutionEngine 的边界。Cache miss 必须表现为 stale / missing / unavailable read-model state，不得触发 broker call、signed request、account endpoint request 或 live command。

`MTP-166-REAL-ACCOUNT-CACHE-FORBIDDEN-GUARD`

Cache 禁止承载 real account cache、broker position cache、real balance、real position、margin、leverage、buying power、real PnL、account endpoint payload、broker payload、broker state、listenKey state、private WebSocket runtime message、ExecutionClient request、OMS order、Live PRO Console command、trading button command 或 order form payload。任何 account summary / portfolio summary 都必须保持 paper / simulated / read-model-only evidence 语义。

`MTP-166-CACHE-BOUNDARY-VALIDATION`

MTP-166 的验证只证明 Cache runtime-derived state、durability / schema separation、Database / MessageBus relationship 和 real account cache forbidden guard 已落仓；不证明 Redis、external cache service、real account / broker state cache、Database implementation、runtime object exposure、UI command surface 或 source migration 已实现。

`MTP-167-DATABASE-DURABLE-FACTS-SNAPSHOT-PROJECTION-CONTRACT`

MTP-167 固定 `Database` 为 local-first durable backing store boundary：Event Log 保存 append-only durable facts，Snapshot 保存可重建状态切片，Projection 保存面向查询的本地 read state。Database 只能持久化本地 facts / snapshots / projections，不表示 broker database、production datastore、Redis cache、UI state store 或 account payload archive。

`MTP-167-SQLITE-DUCKDB-SCHEMA-VERSION-CONTRACT`

SQLite / DuckDB 是 Database implementation detail；schema、version、migration 和 replay projection 只能服务本地 deterministic validation。schema/version 不能暴露为 Workbench UI contract，不能被 Cache 继承为 state ownership，也不能成为 Adapter request、Runtime object、broker payload 或 account endpoint payload 的镜像。

`MTP-167-DATABASE-MESSAGEBUS-CACHE-PORTFOLIO-RELATIONSHIP`

Database 从 MessageBus / Event Log 接收 durable facts，向 Cache 和 Portfolio projection 提供可重建 snapshot / projection input。Cache 只消费 Database projection snapshot，不写 schema；Portfolio projection 只消费 paper / simulated facts，不读取 broker account state。Database 不直接驱动 Workbench UI，Workbench 只能消费 ReadModel / ViewModel。

`MTP-167-WORKBENCH-SCHEMA-BYPASS-GUARD`

Workbench、Report、Dashboard 和 Events 禁止直接读取 SQLite / DuckDB schema、table、query row、DB adapter、file handle、runtime object 或 migration version。任何 database-backed evidence 都必须先经过 ReadModel / ViewModel / report input contract，不能把 schema name、table name、column name 或 raw SQL query 暴露为 product surface contract。

`MTP-167-ACCOUNT-BROKER-PERSISTENCE-FORBIDDEN-GUARD`

Database 禁止持久化 real account payload、broker payload、broker state、broker position、real balance、real position、margin、leverage、buying power、real PnL、signed request、account endpoint response、listenKey state、private WebSocket runtime message、ExecutionClient request、OMS order、execution report、broker fill 或 reconciliation record。真实账户和 broker persistence 仍是 future-gated。

`MTP-167-DATABASE-BOUNDARY-VALIDATION`

MTP-167 的验证只证明 Database durable facts / snapshots / projections、SQLite / DuckDB schema/version separation、Database / MessageBus / Cache / Portfolio relationship、Workbench schema bypass guard 和 account / broker persistence forbidden guard 已落仓；不证明 Database implementation migration、schema exposure、broker/account payload persistence、Redis clone、UI command surface 或 source migration 已实现。

`MTP-168-DATACLIENT-VENUE-ADAPTER-BOUNDARY-CONTRACT`

MTP-168 固定 `DataClient` 为 `Sources/DataClient/<venue>/` venue-scoped exchange adapter boundary。一个交易所一个目录；Binance 只能作为 `Sources/DataClient/Binance/` 示例边界出现。DataClient 只表达 source identity、provider client / exchange client capability taxonomy、public market data request contract 和 future private stream gate label，不直接依赖 DataEngine、Trader、ExecutionEngine、ExecutionClient、Workbench、Cache 或 Database。

`MTP-168-BINANCE-PUBLIC-MARKET-DATA-BOUNDARY`

Binance DataClient 当前只允许 public read-only market data source：symbols、klines、trades、depth、book ticker、public ticker 和 deterministic fixture / replay evidence。它不得包含 API key、secret、signature、signed request、account endpoint payload、order endpoint payload、listenKey、private stream message、execution report、broker fill、reconciliation、margin、leverage、buying power 或 real PnL。

`MTP-168-FUTURE-PRIVATE-STREAM-GATE-CONTRACT`

FuturePrivateStreamGate 是 future-gated label，不是 current runtime。该 label 只说明未来 private stream 需要 Human decision、独立 Project Definition、credential / endpoint / adapter / operations gates 和 forbidden capability audit；它不授权创建 listenKey、keepalive listenKey、连接 private WebSocket、运行 account snapshot runtime、读取 account endpoint payload 或保存 broker state。

`MTP-168-PROVIDER-EXCHANGE-CAPABILITY-TAXONOMY`

Provider client / exchange client capability taxonomy 只能分类为 `public-market-data`、`future-private-stream-gated`、`forbidden-signed-account` 和 `forbidden-execution`。该 taxonomy 不是 Runtime object、Adapter request、Database schema、broker payload、account payload、ExecutionClient request、OMS command、Workbench ViewModel 或 UI command contract。

`MTP-168-DATACLIENT-DEPENDENCY-ISOLATION-GUARD`

DataClient 不 publish MessageBus facts，不写 Database，不驱动 Workbench，不读取 Cache，不协调 Trader，也不提交 ExecutionEngine / ExecutionClient request。后续 DataEngine 可以通过 request / ingest boundary 消费 DataClient public market data capability；DataClient 不能反向依赖 DataEngine，也不能直接服务 Trader、Strategy、RiskEngine、ExecutionEngine 或 UI。

`MTP-168-SIGNED-ACCOUNT-LISTENKEY-FORBIDDEN-GUARD`

DataClient 禁止 signed endpoint、account endpoint、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、broker / exchange execution adapter、ExecutionClient、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account payload、broker payload、broker state、real balance、real position、margin、leverage、buying power 和 real PnL。

`MTP-168-DATACLIENT-BOUNDARY-VALIDATION`

MTP-168 的验证只证明 DataClient venue adapter boundary、Binance public market data boundary、FuturePrivateStreamGate、provider / exchange capability taxonomy、dependency isolation guard 和 signed/account/listenKey forbidden guard 已落仓；不证明 source move、SwiftPM target split、Binance runtime migration、private stream runtime、account snapshot runtime、ExecutionClient、OMS、broker adapter、UI command surface 或 source migration 已实现。

`MTP-169-DATAENGINE-INGEST-REPLAY-QUALITY-CONTRACT`

MTP-169 固定 `DataEngine` 为 `Sources/DataEngine/` ingest / replay / quality boundary：market data ingest、request / response、scenario replay、catalog、freshness 和 quality gates 都必须保留 source identity、dataset / fixture version、replay window、freshness 和 quality evidence。DataEngine 只解释 local deterministic、public read-only 和 scenario replay evidence，不直接服务 Workbench UI、Trader、Strategy、RiskEngine 或 ExecutionEngine。

`MTP-169-MARKET-DATA-INGEST-REQUEST-RESPONSE-CONTRACT`

DataEngine 只能通过 request / ingest boundary 消费 DataClient public market data capability。request / response 是 engine-local deterministic evidence，不是 Runtime object、Adapter request、HTTP API、Workbench ViewModel 或 UI command contract；它不能携带 API key、secret、signature、account endpoint payload、listenKey、private stream message、broker payload、order payload 或 real account state。

`MTP-169-SCENARIO-REPLAY-CATALOG-FRESHNESS-QUALITY-GATES`

Scenario replay、catalog、freshness 和 quality gates 只允许表达 deterministic replay window、dataset / fixture version、source watermark、observedAt、fresh / stale / missing / blocked evidence、completeness、ordering 和 checksum。stale 不触发 network refresh，missing 不回退到 signed/account endpoint，blocked 只表示 forbidden capability boundary 拒绝 private stream、broker adapter 或 account payload。

`MTP-169-DATAENGINE-MESSAGEBUS-PUBLISHING-CONTRACT`

DataEngine 向 MessageBus publish 的内容只能是 market ingest facts、scenario replay facts、catalog facts、freshness evidence 和 quality gate evidence。DataEngine 不 publish order command、risk decision、execution decision、broker command、OMS request、UI command、live command 或 Workbench event handler。

`MTP-169-DATACLIENT-MESSAGEBUS-CACHE-RELATIONSHIP`

DataClient 提供 public market data capability；DataEngine 负责 ingest / replay / quality interpretation；MessageBus 承载 facts / evidence；Cache 从 MessageBus facts 和 Database projection snapshot 形成 runtime-derived read state。DataEngine 不写 Cache，不写 Database schema，不绕过 MessageBus，不直接驱动 Workbench，也不直接服务 Trader。

`MTP-169-UI-TRADER-DIRECT-SERVICE-FORBIDDEN-GUARD`

Workbench、Report、Dashboard、Events、Trader、Strategy、RiskEngine 和 ExecutionEngine 禁止直接调用 DataEngine。所有 DataEngine evidence 必须先进入 MessageBus / Cache / ReadModel / ViewModel 或 report input contract，不能成为 UI command、Trader coordination、Strategy runtime input 或 executable order path。

`MTP-169-SIGNED-ACCOUNT-BROKER-PATH-FORBIDDEN-GUARD`

DataEngine 禁止 signed endpoint、account endpoint、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、broker / exchange execution adapter、ExecutionClient、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account payload、broker payload、broker state、real balance、real position、margin、leverage、buying power 和 real PnL。

`MTP-169-DATAENGINE-BOUNDARY-VALIDATION`

MTP-169 的验证只证明 DataEngine ingest / replay / quality boundary、request / response contract、scenario replay / catalog / freshness / quality gates、MessageBus publishing contract、DataClient / MessageBus / Cache relationship、UI / Trader direct service guard 和 signed/account/broker path forbidden guard 已落仓；不证明完整 streaming DataEngine runtime、source move、SwiftPM target split、private stream runtime、account snapshot runtime、ExecutionClient、OMS、broker adapter、UI command surface 或 source migration 已实现。

`MTP-170-ADAPTER-CAPABILITY-GUARD-CONTRACT`

MTP-170 固定 adapter capability guard 为 DataClient / DataEngine boundary 的 validation evidence。所有 adapter capability 必须先分类为 public market data、fixture replay、scenario replay、future-gated private source 或 forbidden capability；guard 只做边界判定，不实现 endpoint、credential、transport、private stream runtime、broker adapter 或 ExecutionClient。

`MTP-170-FORBIDDEN-ENDPOINT-RUNTIME-COVERAGE`

Forbidden endpoint / runtime coverage 必须包含 signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、broker adapter、exchange execution adapter、ExecutionClient、OMS、real order lifecycle、execution report、broker fill、reconciliation、account payload、broker payload 和 broker state。

`MTP-170-SOURCE-IDENTITY-LABELING-CONTRACT`

DataClient / DataEngine source identity 必须保留 source kind、venue、dataset / fixture version、replay window、freshness status、quality gate status 和 capability label。source identity 不能包含 endpoint URL、API key、secret、signature、listenKey lease、private stream cursor、broker account id、account payload、broker payload、broker state、Adapter request、Runtime object 或 SQLite / DuckDB schema。

`MTP-170-FIXTURE-PUBLIC-FUTURE-GATED-SOURCE-LABELS`

合法 source labels 只能是 `fixture-source`、`public-market-data-source`、`scenario-replay-source` 和 `future-gated-private-source-label`。future-gated private source 是 label-only evidence，不是 current private stream、account snapshot runtime、secret storage、signed request、account endpoint read、listenKey lifecycle、broker sync 或 private network test fixture。

`MTP-170-DATACLIENT-DATAENGINE-BOUNDARY-GUARD`

DataClient 只能提供 public market data capability 和 future-gated label；DataEngine 只能通过 ingest / replay / quality boundary 消费 public or fixture source，并 publish MessageBus facts / evidence。Capability matrix 不能让 DataClient / DataEngine 绕过 MessageBus、Cache、Database、ReadModel / ViewModel、RiskEngine、ExecutionEngine 或 Workbench boundary。

`MTP-170-NO-CREDENTIAL-SECRET-PRIVATE-NETWORK-TEST-GUARD`

自动验证不得依赖真实凭证、真实 Binance 私有接口、外部 account data、secret / credential / keychain storage、API key input、signed request fixture、listenKey fixture、private WebSocket fixture、account endpoint fixture、broker payload fixture 或 real account fixture。MTP-170 guard evidence 必须保持 local deterministic / docs / checks / existing public fixture evidence。

`MTP-170-ADAPTER-CAPABILITY-VALIDATION`

MTP-170 的验证只证明 adapter capability guard、forbidden endpoint/runtime coverage、source identity labeling、fixture / public / future-gated source labels、DataClient / DataEngine boundary guard 和 no credential / secret / private network test guard 已落仓；不证明 endpoint implementation、真实网络私有接口测试、secret / credential / keychain storage、private stream runtime、account snapshot runtime、ExecutionClient、OMS、broker adapter、UI command surface 或 source migration 已实现。

`MTP-171-STRATEGIES-LIFECYCLE-PROPOSAL-BOUNDARY-CONTRACT`

MTP-171 固定的 `Sources/Strategies/<strategy>/` 是当时的 strategy-scoped lifecycle、quoter / hedger、signals、paper/live-neutral proposals 和 read-model input boundary evidence。MTP-191 之后该路径只作为 historical / compatibility / superseded evidence；forward-looking concrete strategy canonical path 是 `Sources/Trader/Strategies/<strategy>/`。Trader-owned Strategies 可以消费 DomainModel、MessageBus、Cache、Portfolio 和 RiskEngine read-model inputs，也可以发布 signal / proposal / evidence facts；Strategies 不等于 Trader coordination runtime、ExecutionEngine command path、ExecutionClient request layer、broker gateway 或 OMS。

`MTP-171-EMA-STRATEGY-DIRECTORY-EXAMPLE`

`Sources/Strategies/EMA/` 是 MTP-171 / MTP-187 historical strategy directory 示例和 MTP-193 historical migration source。MTP-193 后，EMA 的 current canonical source path 是 `Sources/Trader/Strategies/EMA/`；`Lifecycle/`、`Quoter/`、`Hedger/`、`Signals/` 和 `Proposals/` 是 boundary labels，不表示 current strategy runtime、scheduler、live quoter、live hedger、broker adapter、ExecutionClient 或 OMS 已实现。

`MTP-171-LIFECYCLE-QUOTER-HEDGER-SIGNALS-PROPOSALS-SPLIT`

Lifecycle 只描述 strategy readiness state evidence；Quoter 只描述 quote intent / market-side evaluation evidence；Hedger 只描述 hedge intent / exposure balancing evidence；Signals 只描述 deterministic signal facts；Proposals 只描述 paper/live-neutral proposal evidence。任何一层都不能输出 executable order command、broker command、ExecutionClient request、OMS order、real submit / cancel / replace 或 UI command payload。

`MTP-171-STRATEGY-READ-MODEL-INPUT-CONTRACT`

Strategy read-model input 只能来自 DomainModel、MessageBus facts、Cache read state、Portfolio projection 和 RiskEngine blocked / allowed evidence。Strategy 不能直接调用 DataEngine、Trader、ExecutionEngine、ExecutionClient、Workbench、Database schema、Adapter request、Runtime object、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime 或 broker state。

`MTP-171-NO-DIRECT-EXECUTIONCLIENT-PATH-GUARD`

MTP-171 的 forbidden direct execution path 包括 `Strategies -> ExecutionClient`、`Strategies -> broker command`、`Strategies -> OMS`、`Strategies -> real order lifecycle`、`Strategies -> real submit / cancel / replace`、`Strategies -> execution report`、`Strategies -> broker fill`、`Strategies -> reconciliation`、`Strategies -> Live PRO Console command`、`Strategies -> trading button` 和 `Strategies -> order form`。Strategy proposal 必须保持 evidence-only / paper-live-neutral semantics，不能升级为 executable order command。

`MTP-171-NO-RUNTIME-SCHEDULER-LIVE-QUOTER-HEDGER-GUARD`

MTP-171 不实现 strategy runtime、scheduler、live quoter runtime、live hedger runtime、Trader runtime、ExecutionClient implementation、OMS implementation、broker adapter、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、secret / credential / keychain storage、Live PRO Console、trading button、live command 或 order form。

`MTP-171-STRATEGIES-BOUNDARY-VALIDATION`

MTP-171 的验证只证明 Strategies lifecycle and proposal boundary、EMA strategy directory example、lifecycle / quoter / hedger / signals / proposals split、Strategy read-model input contract、no direct ExecutionClient path guard 和 no runtime scheduler / live quoter / hedger guard 已落仓；不证明 source move、Package.swift target graph change、strategy runtime、scheduler、live quoter、live hedger、broker command、executable order command 或 source migration 已实现。

`MTP-172-TRADER-COORDINATION-BOUNDARY-CONTRACT`

MTP-172 固定 `Sources/Trader/` 为 strategy / account / risk / execution context 的 coordination boundary。Trader 可以协调 Strategies、Portfolio、RiskEngine 和 ExecutionEngine 的本地 evidence / read-model inputs；Trader 不等于 live coordinator、OMS、broker gateway、ExecutionClient client wrapper、real account service、portfolio ledger 或 executable order command surface。

`MTP-172-ACCOUNTS-COORDINATION-STRATEGYBINDINGS-SPLIT`

`Sources/Trader/Accounts/` 只保存 account context、account identity、source identity 和 future real account gate label；`Sources/Trader/Coordination/` 只表达 strategy / risk / execution context ordering evidence；`Sources/Trader/StrategyBindings/` 只表达 strategy instance 与 Trader context 的 binding evidence。这些 boundary 不拥有 cash、positions、PnL、margin、leverage、broker position、broker state、order form state 或 real account payload。

`MTP-172-STRATEGY-ACCOUNT-RISK-EXECUTION-CONTEXT-COORDINATION`

Trader coordination 只能把 strategy proposals、account context identity、Portfolio read model、RiskEngine evidence 和 ExecutionEngine paper / simulated lifecycle boundary 串成本地 decision context。该 context 不能绕过 MessageBus / Cache / ReadModel / ViewModel，不能直接调用 DataClient / DataEngine / Database schema，也不能产生 broker command、ExecutionClient request、OMS order、live command 或 UI command payload。

`MTP-172-TRADER-ACCOUNT-CONTEXT-IDENTITY-ONLY-GUARD`

Trader/Accounts 只表达 account identity、source identity、simulated / paper / future-gated source label 和 readiness evidence。真实 cash、positions、PnL、exposure、margin、open value 和 paper projection 属于 Portfolio；真实 account source、account endpoint payload、listenKey state、broker position、broker account id、broker payload 和 broker state 仍 forbidden。

`MTP-172-NO-LIVE-COORDINATOR-OMS-BROKER-GATEWAY-GUARD`

MTP-172 禁止把 Trader 写成 live coordinator、OMS、broker gateway、broker session manager、private stream coordinator、account snapshot runtime、real account synchronizer、Live PRO Console backend、trading button handler、order form handler、emergency stop runtime、shutdown runtime 或 restore runtime。

`MTP-172-NO-DIRECT-EXECUTIONCLIENT-BROKER-COMMAND-PATH`

MTP-172 的 forbidden direct command path 包括 `Trader -> ExecutionClient`、`Trader -> broker command`、`Trader -> OMS`、`Trader -> real order lifecycle`、`Trader -> real submit / cancel / replace`、`Trader -> execution report`、`Trader -> broker fill`、`Trader -> reconciliation`、`Trader -> signed endpoint`、`Trader -> account endpoint / listenKey`、`Trader -> private WebSocket runtime`、`Trader -> order form` 和 `Trader -> live command`。

`MTP-172-TRADER-BOUNDARY-VALIDATION`

MTP-172 的验证只证明 Trader coordination boundary、Accounts / Coordination / StrategyBindings split、strategy / account / risk / execution context coordination、account context identity-only guard、no live coordinator / OMS / broker gateway guard 和 no direct ExecutionClient / broker command path 已落仓；不证明 source move、Package.swift target graph change、Trader runtime、live coordinator、OMS、broker gateway、real account read 或 broker position sync 已实现。

`MTP-191-TRADER-OWNED-STRATEGY-CANONICAL-PATH`

`Trader-owned strategy canonical path` 指 MTP-191 之后具体策略的 forward-looking source landing path 是 `Sources/Trader/Strategies/<strategy>/`，不是 peer-level `Sources/Strategies/<strategy>/`。旧 `Sources/Strategies/<strategy>/`、`Sources/Strategies/EMA/` 和 `Sources/Strategies/OrderBookImbalance/` 只作为 MTP-171 / MTP-183 / MTP-187 historical evidence、compatibility envelope、superseded path 或 historical migration source。

`MTP-191-TRADER-CONTAINER-SPLIT`

`Trader container split` 指 `Sources/Trader/` 下固定包含 `Accounts/`、`Strategies/`、`Coordination/` 和 `StrategyBindings/`：`Strategies/<strategy>/` 保存具体策略定义和 readiness evidence；`Accounts/` 保存 account context identity；`Coordination/` 保存 strategy / account / risk / execution context ordering evidence；`StrategyBindings/` 保存 generic binding protocol / coordination adapter contract。

`MTP-191-STRATEGYBINDINGS-NON-LANDING-GUARD`

`StrategyBindings non-landing guard` 指 `Sources/Trader/StrategyBindings/` 不得作为 EMA、OrderBookImbalance 或未来具体策略实现目录。它只能表达 strategy instance 与 Trader context / RiskEngine / Portfolio evidence 的通用连接协议或 adapter contract，不能承载 lifecycle、signals、quoter、hedger、proposal implementation 或 strategy-specific business rules。

`MTP-191-INDEPENDENT-ENGINE-MODULES-GUARD`

`Independent engine modules guard` 指 Portfolio、RiskEngine、ExecutionEngine 和 ExecutionClient 不并入 Trader。Trader 可以消费它们的 read-model / evidence / future-gated context，但不能拥有 financial state、risk decision ownership、execution lifecycle ownership、broker capability、OMS、signed/account endpoint、private stream runtime 或 live command surface。

`MTP-191-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`

MTP-191 只定义 Trader-owned strategy path correction，不移动 production source，不修改 `Package.swift`，不创建 SwiftPM target，不实现 Strategy runtime、Trader runtime、live coordinator、broker gateway、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-191-BOUNDARY-CORRECTION-VALIDATION`

MTP-191 validation language 必须同时说明新的 canonical path、旧路径 compatibility / superseded role、StrategyBindings 非具体策略落点，以及 no source move / no Package.swift / no business code / no Graphify / no Figma。

`MTP-192-ROOT-DOCS-STRATEGY-PATH-ANCHOR-CORRECTION`

Root docs 的 forward-looking strategy path anchor 必须使用 `Sources/Trader/Strategies/<strategy>/`。旧 `Sources/Strategies/<strategy>/`、`Sources/Strategies/EMA/` 和 `Sources/Strategies/OrderBookImbalance/` 只能作为 historical evidence、compatibility envelope、superseded path、MTP-193 historical migration source 或 MTP-194 historical migration source。

`MTP-192-HISTORICAL-STRATEGIES-COMPATIBILITY-NOTE`

历史 evidence 不静默改写；凡保留 `Sources/Strategies/<strategy>/` 的 root docs 段落，必须说明它不是 MTP-191 之后的 canonical future layout。

`MTP-192-TRADER-CONTAINER-STRATEGYBINDINGS-ROOT-DOCS`

Trader shared language 使用 `Trader = Accounts + Strategies + StrategyBindings + Coordination`。`Trader/StrategyBindings` 是 generic binding protocol / coordination adapter，不是具体策略源码落点。

`MTP-192-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`

MTP-192 不移动 production source，不修改 `Package.swift`，不拆 SwiftPM target graph，不实现 Strategy runtime、Trader runtime、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-192-ROOT-DOCS-ANCHOR-VALIDATION`

MTP-192 validation 证明 root docs 不再把 `Sources/Strategies/<strategy>` 写成 forward-looking canonical strategy layout；允许保留的旧路径必须是 historical / compatibility / superseded / migration-source 语义。

`MTP-193-EMA-TRADER-STRATEGIES-PHYSICAL-MIGRATION`

`EMA Trader strategy physical migration` 指 EMA strategy lifecycle、shared strategy signal 和 paper/live-neutral proposal source 已从 MTP-187 的 superseded `Sources/Strategies/EMA/` 迁入 Trader-owned canonical path `Sources/Trader/Strategies/EMA/`。该术语只表达 physical source placement correction，不改变 EMA signal、proposal、fixture、authorization 或 `import Core` compatibility surface。

`MTP-193-EMA-OLD-PATH-REMOVAL-GUARD`

MTP-193 后 `Sources/Strategies/EMA/` 只能作为 historical evidence、superseded path 或 migration-source language 出现，不得再作为 current implementation path、canonical strategy path 或 future landing path。

`MTP-193-CORE-COMPATIBILITY-ENVELOPE-SOURCE-PATH`

MTP-193 的 compatibility envelope 指 `Core` target 名称保持不变，但 EMA source root 改为 `Sources/Trader/Strategies/EMA/`；MTP-194 后 OrderBookImbalance source root 也改为 `Sources/Trader/Strategies/OrderBookImbalance/`。这不表示 SwiftPM target graph split 已完成。

`MTP-193-BEHAVIOR-UNCHANGED-GUARD`

MTP-193 必须保持 EMA lifecycle、signal、paper proposal、paper-only authorization 和 deterministic fixtures 行为不变，不授权 Strategy runtime、scheduler、live quoter、live hedger、Trader runtime、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-193-NO-RUNTIME-TARGET-GRAPH-GUARD`

MTP-193 不创建 `Strategies` / `Trader` SwiftPM target，不迁移 OrderBookImbalance、StrategyBindings、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard，不把 proposal、signal 或 strategy evidence 升级为 executable order command。

`MTP-193-EMA-PATH-MIGRATION-VALIDATION`

MTP-193 validation language 必须证明 EMA source 位于 `Sources/Trader/Strategies/EMA/`，旧 `Sources/Strategies/EMA/` 目录不存在，`Package.swift` 使用 `"Trader/Strategies/EMA"` 且不再包含 `"Strategies/EMA"`，focused EMA / proposal tests 和完整 checks 仍通过。

`MTP-194-ORDERBOOKIMBALANCE-TRADER-STRATEGIES-PHYSICAL-MIGRATION`

`OrderBookImbalance Trader strategy physical migration` 指 order-book imbalance research strategy source 已从 MTP-187 的 superseded `Sources/Strategies/OrderBookImbalance/` 迁入 Trader-owned canonical path `Sources/Trader/Strategies/OrderBookImbalance/`。该术语只表达 physical source placement correction，不改变 imbalance calculation、bias semantics、input source evidence、fixtures 或 `import Core` compatibility surface。

`MTP-194-ORDERBOOKIMBALANCE-OLD-PATH-REMOVAL-GUARD`

MTP-194 后 `Sources/Strategies/OrderBookImbalance/` 只能作为 historical evidence、superseded path 或 migration-source language 出现，不得再作为 current implementation path、canonical strategy path 或 future landing path。

`MTP-194-CORE-COMPATIBILITY-ENVELOPE-SOURCE-PATH`

MTP-194 的 compatibility envelope 指 `Core` target 名称保持不变，但 OrderBookImbalance source root 改为 `Sources/Trader/Strategies/OrderBookImbalance/`。这不表示 SwiftPM target graph split 已完成。

`MTP-194-BEHAVIOR-UNCHANGED-GUARD`

MTP-194 必须保持 OrderBookImbalance strategy contract、configuration validation、signal sample、bid / ask notional、imbalance ratio、bias calculation、snapshot / delta input source 和 research-only boundary 行为不变。Ask dominance 仍只是 research bias，不授权 short、margin、futures、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-194-NO-RUNTIME-TARGET-GRAPH-GUARD`

MTP-194 不创建 `Strategies` / `Trader` SwiftPM target，不迁移 StrategyBindings、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard，不把 research signal、bias 或 fixture evidence 升级为 executable order command。

`MTP-194-ORDERBOOKIMBALANCE-PATH-MIGRATION-VALIDATION`

MTP-194 validation language 必须证明 OrderBookImbalance source 位于 `Sources/Trader/Strategies/OrderBookImbalance/`，旧 `Sources/Strategies/OrderBookImbalance/` 目录不存在，`Package.swift` 使用 `"Trader/Strategies/OrderBookImbalance"` 且不再包含 `"Strategies/OrderBookImbalance"`，focused OrderBookImbalance tests 和完整 checks 仍通过。

`MTP-195-STRATEGYBINDINGS-BINDING-PROTOCOL-ADAPTER-CONTRACT`

`StrategyBindings binding protocol / coordination adapter contract` 指 `Sources/Trader/StrategyBindings/` 只保存 strategy instance 与 Trader context / RiskEngine / Portfolio evidence 的通用 binding protocol、adapter contract 和 deterministic local coordination evidence。它不是 concrete strategy implementation root，也不是 Trader runtime、broker gateway、OMS gateway 或 live coordinator。

`MTP-195-CONCRETE-STRATEGY-NON-LANDING-GUARD`

MTP-195 后 `Sources/Trader/StrategyBindings/` 不得作为 EMA、OrderBookImbalance 或未来具体策略的源码落点。EMA 当前 root 是 `Sources/Trader/Strategies/EMA/`，OrderBookImbalance 当前 root 是 `Sources/Trader/Strategies/OrderBookImbalance/`；具体 strategy lifecycle、signals、proposal implementation、quoter、hedger 和 strategy-specific business rules 必须继续落在 `Sources/Trader/Strategies/<strategy>/`。

`MTP-195-STRATEGYBINDINGS-COMPATIBILITY-ENVELOPE`

MTP-195 的 compatibility envelope 指 `Core` target 名称保持不变，并继续编译 `Sources/Trader/StrategyBindings/PaperActionRiskLink.swift`。这只保持现有 import surface 和 tests buildability，不表示 SwiftPM target graph split、Trader runtime、strategy scheduler 或 live coordinator 已实现。

`MTP-195-NO-DIRECT-EXECUTION-BROKER-OMS-LIVE-GUARD`

StrategyBindings 不得引入 `StrategyBindings -> ExecutionClient`、`StrategyBindings -> broker command`、`StrategyBindings -> OMS command`、`StrategyBindings -> signed/account endpoint`、`StrategyBindings -> private stream runtime`、`StrategyBindings -> Live PRO Console`、`StrategyBindings -> trading button`、`StrategyBindings -> live command` 或 `StrategyBindings -> order form` 路径。`PaperActionRiskLink` 仍只表达 paper proposal -> risk query / blocker evidence 的本地只读链路。

`MTP-195-STRATEGYBINDINGS-BOUNDARY-VALIDATION`

MTP-195 validation language 必须证明 `TraderStrategyBindingsBoundaryEvidence`、focused XCTest、docs anchors 和 automation readiness checks 一致覆盖：StrategyBindings 只是 generic binding protocol / coordination adapter，concrete strategies remain Trader-owned，且无 direct execution / broker / OMS / live command path。

`MTP-173-ACCOUNT-PORTFOLIO-READMODEL-BOUNDARY-CONTRACT`

MTP-173 固定 Account / Portfolio context read-model boundary：`Sources/Trader/Accounts/` 只表达 Trader coordination 使用的 account context、account identity 和 source identity；`Sources/Portfolio/` 独立表达 positions、net positions、cash/equity、PnL、exposure、margin、open value 和 paper projection。

`MTP-173-TRADER-ACCOUNT-CONTEXT-IDENTITY-CONTRACT`

Trader/Accounts 只能记录 simulated / paper / future-gated source label、account context、account identity、source identity 和 readiness evidence。它不得拥有 cash、positions、PnL、exposure、margin、leverage、open value、paper projection、broker position、broker account state、account endpoint payload、broker payload 或 broker account id。

`MTP-173-PORTFOLIO-FINANCIAL-STATE-OWNERSHIP`

Portfolio 是独立 financial state read-model module。Portfolio 可以消费 DomainModel、MessageBus facts、Cache read state 和 Database projection input，用于表达 paper / simulated positions、net positions、cash/equity、PnL、exposure、margin、open value 和 paper projection；它不依赖 Trader runtime、ExecutionClient、broker adapter 或 account endpoint payload。

`MTP-173-CASH-POSITION-PNL-EXPOSURE-PROJECTION-SPLIT`

cash、positions、PnL、exposure、margin、open value 和 projection 归 Portfolio；Trader 只能引用 Portfolio read model 形成 coordination context；Workbench / Report / Events 只能通过 ReadModel / ViewModel 消费这些 evidence。任何后续 issue 不得把 Portfolio financial state 塞回 Trader/Accounts。

`MTP-173-REAL-ACCOUNT-BROKER-PORTFOLIO-FUTURE-GATE`

真实账户 source、broker portfolio、broker position、real balance、real position、margin / leverage、buying power、real PnL、account endpoint payload、broker payload 和 broker state 当前都是 future-gated forbidden label。它们不得被解释为可读 runtime source、fixture payload、Portfolio live reconciliation input 或 broker sync input。

`MTP-173-NO-BROKER-ACCOUNT-STATE-READ-GUARD`

MTP-173 的 forbidden read path 包括 `Portfolio -> broker account state`、`Portfolio -> account endpoint payload`、`Portfolio -> broker payload`、`Portfolio -> signed endpoint`、`Portfolio -> account endpoint / listenKey`、`Portfolio -> private WebSocket runtime`、`Portfolio -> broker position sync`、`Trader/Accounts -> broker portfolio` 和 `Workbench -> Portfolio broker state`。

`MTP-173-ACCOUNT-PORTFOLIO-BOUNDARY-VALIDATION`

MTP-173 的验证只证明 Account / Portfolio read-model boundary、Trader account context identity contract、Portfolio financial state ownership、cash / position / PnL / exposure / projection split、real account broker portfolio future gate 和 no broker account state read guard 已落仓；不证明 source move、Package.swift target graph change、Portfolio runtime、broker sync、real account read 或 live reconciliation 已实现。

`MTP-174-STRATEGIES-TRADER-NO-DIRECT-EXECUTION-GUARD`

MTP-174 固定 M4 no-direct-execution guard：Strategies 和 Trader 只能产生 paper / simulated / read-model-only evidence、proposal evidence、coordination context 和 blocked reason；它们不能直连 ExecutionClient、broker command、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。

`MTP-174-PROPOSAL-ORDER-COMMAND-SEMANTIC-ISOLATION`

Strategy proposal / Trader proposal 与 executable order command 必须语义隔离。Proposal 可以引用 read-model input、risk evidence、Portfolio projection 和 blocked reason；不得包含 order id、client order id、broker order id、broker account id、ExecutionClient request、OMS order、signed request、side / quantity / price / timeInForce / orderType executable tuple 或 order form payload。

`MTP-174-TRADER-NOT-LIVE-COORDINATOR-BROKER-GATEWAY`

Trader coordination 不是 live coordinator、broker gateway、OMS gateway、broker session manager、account session manager、private stream coordinator、account snapshot runtime、real account synchronizer 或 command router。它只能串联 Strategies、Trader/Accounts、Portfolio、RiskEngine 和 ExecutionEngine paper / simulated boundary。

`MTP-174-FORBIDDEN-UI-COMMAND-SURFACE-GUARD`

Workbench / Report / Events / Dashboard 只能展示 Strategies / Trader 的 ReadModel / ViewModel evidence。禁止把 strategy readiness、proposal、Trader coordination 或 account context 映射为 trading button、live command、order form、position command、order-level command UI、emergency stop、shutdown、restore 或 production operations command。

`MTP-174-EXECUTIONCLIENT-OMS-BROKER-PATH-BLOCKLIST`

MTP-174 的 forbidden direct execution blocklist 包括 `Strategies -> ExecutionClient`、`Strategies -> broker command`、`Strategies -> OMS`、`Trader -> ExecutionClient`、`Trader -> broker command`、`Trader -> OMS`、`Strategy proposal -> executable order command`、`Trader coordination -> real order lifecycle`、`Workbench -> Strategy / Trader live command` 和 `Live PRO Console -> current Workbench command surface`。

`MTP-174-NO-RUNTIME-ENDPOINT-CREDENTIAL-BYPASS`

No-direct-execution guard 不得通过 runtime / endpoint / credential bypass 实现。MTP-174 不创建 Strategy runtime、Trader runtime、ExecutionClient implementation、OMS implementation、broker adapter、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、API key input、secret storage、credential provider、keychain storage 或 private network test。

`MTP-174-NO-DIRECT-EXECUTION-GUARD-VALIDATION`

MTP-174 的验证只证明 Strategies / Trader no-direct-execution guard、proposal / order command semantic isolation、Trader not live coordinator / broker gateway guard、forbidden UI command surface guard、ExecutionClient / OMS / broker blocklist 和 no runtime / endpoint / credential bypass 已落仓；不证明 source move、Package.swift target graph change、Strategy runtime、Trader runtime、ExecutionClient、OMS 或 broker adapter 已实现。

`MTP-175-RISKENGINE-PRE-EXECUTION-BOUNDARY-CONTRACT`

MTP-175 固定 `Sources/RiskEngine/` 为 pre-execution risk boundary。RiskEngine 只消费 DomainModel、MessageBus facts、Cache read state、Portfolio read model、strategy proposal evidence 和 Trader coordination context，输出 paper pre-trade risk evidence、allowed / blocked evidence、blocked reason 和 future live risk gate label；它不表示 broker gateway、ExecutionClient wrapper、OMS、live risk runtime 或 real pre-trade allow / reject service。

`MTP-175-PAPER-RISK-BLOCKED-EVIDENCE-CONTRACT`

Paper risk / blocked evidence 是本地 deterministic evidence。它可以描述 pre-trade check、Portfolio exposure reference、paper proposal reference、risk input trace、allowed / blocked verdict、blocked reason、source anchor 和 validation trace；不得携带 executable order command、broker account id、broker position、real balance、margin、leverage、real PnL、ExecutionClient request、OMS order、signed request、order form payload 或 live command payload。

`MTP-175-RISKENGINE-BEFORE-EXECUTIONENGINE-DEPENDENCY`

RiskEngine 必须位于 ExecutionEngine 之前：Strategies / Trader / Portfolio evidence 先进入 RiskEngine boundary，再由 ExecutionEngine 消费 RiskEngine paper risk evidence 或 future-gated live risk gate label。RiskEngine 不反向调用 ExecutionClient、broker adapter、OMS、account endpoint、listenKey、private stream runtime、account snapshot runtime 或 broker session。

`MTP-175-FUTURE-LIVE-RISK-GATE-BOUNDARY`

Future live risk gate 是 future-gated boundary label，不是当前 live risk implementation。该 label 只为后续 Human decision、独立 Project Definition 和 signed / account / broker / ops gates 保留语义入口；当前不得解释为 live risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade runtime、risk command surface、position command、order form、trading button、stop trading command 或 emergency stop。

`MTP-175-NO-BROKER-EXECUTIONCLIENT-RISK-PATH-GUARD`

MTP-175 的 forbidden path 包括 `RiskEngine -> broker`、`RiskEngine -> ExecutionClient`、`RiskEngine -> OMS`、`RiskEngine -> signed endpoint`、`RiskEngine -> account endpoint / listenKey`、`RiskEngine -> private WebSocket runtime`、`RiskEngine -> broker position`、`RiskEngine -> real account state`、`RiskEngine -> live command` 和 `RiskEngine evidence -> executable order command`。

`MTP-175-NO-LIVE-RISK-RUNTIME-CIRCUIT-BREAKER-GUARD`

RiskEngine pre-execution boundary 不能升级为 current live safety runtime。MTP-175 不创建 live risk runtime、circuit breaker runtime、loss / drawdown enforcement runtime、frequency enforcement runtime、global trading lock、stop trading command、emergency stop command、broker session mutation、API key input、secret storage、credential provider、keychain storage 或 private network test。

`MTP-175-RISKENGINE-BOUNDARY-VALIDATION`

MTP-175 的验证只证明 RiskEngine pre-execution boundary、paper risk / blocked evidence contract、RiskEngine before ExecutionEngine dependency、future live risk gate boundary、no broker / ExecutionClient risk path guard 和 no live risk runtime / circuit breaker guard 已落仓；不证明 source move、Package.swift target graph change、RiskEngine runtime、live risk runtime、broker adapter、ExecutionClient 或 OMS 已实现。

`MTP-176-EXECUTIONENGINE-PAPER-SIMULATED-LIFECYCLE-BOUNDARY`

MTP-176 固定 `Sources/ExecutionEngine/` 为 paper / simulated execution lifecycle boundary。ExecutionEngine 只消费 RiskEngine paper risk evidence、Trader coordination context、paper proposal evidence 和 Portfolio read model，输出 paper lifecycle evidence、simulated fill evidence、fee / slippage evidence 和 Portfolio projection trigger；它不是 ExecutionClient、broker adapter、OMS、real order state machine、venue API client 或 live execution runtime。

`MTP-176-PAPER-LIFECYCLE-STATE-CONTRACT`

Paper lifecycle state 只表示本地 deterministic 状态流：proposed、accepted、rejected、filled、partially filled、expired 和 cancelled-local。每个 transition 可以记录 risk decision reference、paper order intent reference、correlation / causation evidence、replay trace 和 blocked reason；不得携带 broker order id、exchange order id、client order id、execution report id、broker fill id、real account id、account endpoint payload 或 signed request。

`MTP-176-SIMULATED-FILL-FEE-SLIPPAGE-CONTRACT`

Simulated fill、fee、slippage 和 cost impact 只表示 local simulated exchange / deterministic fixture evidence。它们可以作为 Portfolio projection、Report、Dashboard 和 Events read-model-only evidence input；不得升级为 execution report、broker fill、exchange acknowledgement、venue fee report、settlement record、reconciliation input、broker statement、real PnL source 或 live fill event。

`MTP-176-PORTFOLIO-PROJECTION-EVIDENCE-OUTPUT`

ExecutionEngine 输出必须通过 MessageBus facts、Portfolio projection input、ReadModel / ViewModel export、Report 和 Events evidence surface 传播。禁止直接写 Workbench UI state，禁止暴露 runtime object、Adapter request、SQLite / DuckDB schema、broker payload、account payload、broker state、order form payload 或 UI command surface。

`MTP-176-OMS-FUTURE-GATE-BOUNDARY`

OMSFutureGate 是 future-gated boundary label，用于说明未来 OMS 与 ExecutionEngine 的分界。当前 MTP-176 不实现 OMS、order router、execution venue routing、real order lifecycle、broker session、execution report ingestion、broker fill ingestion、reconciliation runtime、production execution audit trail 或 production recovery。

`MTP-176-NO-REAL-ORDER-LIFECYCLE-BROKER-PATH-GUARD`

MTP-176 的 forbidden path 包括 `ExecutionEngine -> broker submit`、`ExecutionEngine -> broker cancel`、`ExecutionEngine -> broker replace`、`ExecutionEngine -> ExecutionClient request`、`ExecutionEngine -> OMS order`、`ExecutionEngine -> signed endpoint`、`ExecutionEngine -> account endpoint / listenKey`、`ExecutionEngine -> execution report`、`ExecutionEngine -> broker fill`、`ExecutionEngine -> reconciliation` 和 `paper lifecycle -> real order lifecycle`。

`MTP-176-EXECUTIONENGINE-BOUNDARY-VALIDATION`

MTP-176 的验证只证明 ExecutionEngine paper / simulated lifecycle boundary、paper lifecycle state contract、simulated fill / fee / slippage contract、Portfolio projection evidence output、OMS future gate boundary 和 no real order lifecycle / broker path guard 已落仓；不证明 source move、Package.swift target graph change、ExecutionEngine runtime、ExecutionClient、OMS、broker adapter 或 real order lifecycle 已实现。

`MTP-177-EXECUTIONCLIENT-FUTURE-GATED-BOUNDARY-CONTRACT`

MTP-177 固定 `Sources/ExecutionClient/` 为 future-gated venue API client boundary。ExecutionClient 只表示未来把已通过 RiskEngine 和 ExecutionEngine 的 order intent 翻译成 broker / exchange API request 的外部电话线；当前不表示 broker client、exchange execution adapter、signed request runtime、account endpoint / listenKey runtime、private WebSocket runtime 或 order submit / cancel / replace capability。

`MTP-177-BROKER-CAPABILITY-MATRIX-FUTURE-GATE`

BrokerCapabilityMatrix 只是 future gate taxonomy。它可以列出 future venue capability、signed endpoint capability、account endpoint capability、execution report capability、broker fill capability、reconciliation capability 和 credential requirement label；不得升级为 capability discovery runtime、credential check、network probe、private endpoint test、API key input、secret storage、credential provider 或 keychain storage。

`MTP-177-OMS-FUTURE-GATE-EXECUTIONENGINE-SPLIT`

OMSFutureGate 只说明未来 OMS 与 ExecutionEngine 的分界：ExecutionEngine 负责 current paper / simulated lifecycle evidence、simulated fill、fee / slippage 和 Portfolio projection trigger；OMS 未来才可能负责 live order orchestration、order state machine、venue routing、order amendment 和 production execution audit trail。当前不得实现 OMS、order router、order state store、real submit / cancel / replace、execution report parser、broker fill parser 或 reconciliation runtime。

`MTP-177-EXECUTIONENGINE-VS-EXECUTIONCLIENT-PLAIN-LANGUAGE`

大白话：ExecutionEngine 是内部执行大脑，负责本地 paper / simulated lifecycle；ExecutionClient 是未来外部电话线，只在 future approved live gate 后才可能拨 broker / exchange API。当前 ExecutionEngine 不能直连这条电话线，ExecutionClient 不能作为当前 runtime、adapter、client wrapper 或 broker session 存在。

`MTP-177-NO-BROKER-CLIENT-SIGNED-REQUEST-GUARD`

MTP-177 的 forbidden path 包括 `ExecutionClient -> broker client`、`ExecutionClient -> signed request`、`ExecutionClient -> order submit`、`ExecutionClient -> order cancel`、`ExecutionClient -> order replace`、`ExecutionClient -> account endpoint / listenKey`、`ExecutionClient -> private WebSocket runtime`、`ExecutionEngine -> ExecutionClient request` 和 `OMSFutureGate -> current OMS implementation`。

`MTP-177-NO-EXECUTION-REPORT-FILL-RECONCILIATION-RUNTIME`

ExecutionClient / OMS future gate 不得产生 real execution evidence pipeline。MTP-177 不创建 execution report parser、broker fill parser、broker acknowledgement decoder、order status poller、fill reconciliation job、position reconciliation job、settlement importer、broker statement reader、production execution audit trail 或 production recovery hook。

`MTP-177-EXECUTIONCLIENT-OMS-FUTURE-GATE-VALIDATION`

MTP-177 的验证只证明 ExecutionClient future-gated boundary、BrokerCapabilityMatrix future gate、OMS future gate / ExecutionEngine split、ExecutionEngine vs ExecutionClient plain-language boundary、no broker client / signed request guard 和 no execution report / fill / reconciliation runtime guard 已落仓；不证明 source move、Package.swift target graph change、ExecutionClient、OMS、broker adapter 或 live execution runtime 已实现。

`MTP-178-BROKER-REAL-ORDER-FORBIDDEN-GUARD`

MTP-178 的 broker / real order forbidden guard 是 current implementation blocker。它覆盖 signed endpoint、account endpoint / listenKey、broker adapter、broker / exchange execution adapter、LiveExecutionAdapter、real order lifecycle、execution report、broker fill、reconciliation runtime、Live PRO Console、trading button、live command 和 order form；当前只允许这些词作为 forbidden capability、future gate 或 validation evidence。

`MTP-178-SIGNED-ACCOUNT-LISTENKEY-ENDPOINT-BLOCKLIST`

Signed / account / listenKey endpoint blocklist 表示当前不得出现 API key input、secret storage、credential provider、keychain storage、signed request builder、account endpoint client、listenKey lifecycle、private WebSocket runtime、account snapshot runtime、broker account payload、broker state payload 或 private endpoint network test。任何 DataClient / ExecutionClient / Trader / Portfolio / Workbench evidence 都必须保持 fixture / public / simulated / read-model-only。

`MTP-178-BROKER-EXCHANGE-EXECUTION-ADAPTER-BLOCKLIST`

Broker / exchange execution adapter blocklist 表示当前不得实现 BrokerExecutionAdapter、ExchangeExecutionAdapter、LiveExecutionAdapter、broker SDK wrapper、exchange venue client、broker gateway、OMS gateway、order router、execution venue routing、broker session manager 或 broker connect UI。ExecutionClient 和 OMSFutureGate 仍只是 future gate，不是 current runtime。

`MTP-178-REAL-SUBMIT-CANCEL-REPLACE-FORBIDDEN`

Real submit / cancel / replace forbidden 表示真实订单提交、撤单、改单、order amendment、order status poll、broker acknowledgement、exchange order id、client order id、broker order id、real order state machine 和 production execution audit trail 都不可执行。Paper lifecycle、simulated fill、RiskEngine blocked evidence 和 Strategy proposal 不能升级为 executable order command、order form payload、live command、trading button 或 Live PRO Console action。

`MTP-178-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-BLOCKLIST`

Execution report / broker fill / reconciliation blocklist 表示当前不得创建 execution report parser、broker fill parser、broker fill fact、fill reconciliation job、position reconciliation job、settlement importer、broker statement reader、real PnL source、broker portfolio sync、account position sync 或 broker evidence pipeline。Portfolio、Report、Events 和 Workbench 只能消费本地 paper / simulated / read-model-only evidence。

`MTP-178-LIVEEXECUTIONADAPTER-FUTURE-GATE`

LiveExecutionAdapter future gate 表示 `LiveExecutionAdapter` 只能作为 forbidden capability label、future gate term 或 validation evidence；不得成为 Sources / Tests 中的 production protocol、struct、class、actor、enum、runtime adapter 或 broker session implementation。未来 live execution 必须等待独立 Human decision、Project Definition、signed / account / broker / ops gates 和新的 validation matrix。

`MTP-178-BROKER-REAL-ORDER-GUARD-VALIDATION`

MTP-178 的验证只证明 broker / real order forbidden guard、signed / account / listenKey endpoint blocklist、broker / exchange execution adapter blocklist、real submit / cancel / replace forbidden、execution report / broker fill / reconciliation blocklist 和 LiveExecutionAdapter future gate 已落仓；不证明 source move、Package.swift target graph change、broker adapter、ExecutionClient、OMS、real order lifecycle 或 live execution runtime 已实现。

`MTP-179-WORKBENCH-READ-MODEL-ONLY-CONSUMPTION-BOUNDARY`

MTP-179 固定 Workbench / Report / Dashboard / Events 为 read-model-only consumption boundary。Workbench 只能消费 ReadModel / ViewModel / evidence surface，不能拥有 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload、broker state、ExecutionClient request、OMS order 或 live command payload。

`MTP-179-READMODEL-VIEWMODEL-ONLY-INPUT-CONTRACT`

ReadModel / ViewModel only input contract 表示 Workbench input 必须来自 MessageBus facts projection、Portfolio / Risk / Execution evidence read model、local fixture summary、deterministic validation summary 或 explicit ViewModel export。任何 engine runtime handle、adapter request object、database schema object、private endpoint payload、broker payload 或 account payload 都不能成为 Workbench / Report / Events input。

`MTP-179-WORKBENCH-REPORT-EVENTS-SURFACE-SPLIT`

Workbench 用于 read-only filtering / inspection，Report 用于 summary / audit / validation evidence，Events 用于 timeline / fact stream evidence。三者可以共享 read-model-only export，但不能互相升级为 runtime command surface、database browser、adapter console、broker console 或 live operations console。

`MTP-179-NO-RUNTIME-ADAPTER-SCHEMA-PAYLOAD-EXPOSURE`

MTP-179 的 forbidden exposure 包括 `Workbench -> Runtime object`、`Workbench -> Adapter request`、`Workbench -> SQLite schema`、`Workbench -> DuckDB schema`、`Workbench -> account payload`、`Workbench -> broker payload`、`Workbench -> broker state`、`Report -> Database schema`、`Events -> Runtime object` 和 `Dashboard -> broker state`。这些路径只能出现在 forbidden capability guard 或 validation evidence 中。

`MTP-179-NO-LIVE-COMMAND-SURFACE-GUARD`

Workbench 不能变成 Live PRO Console、trading button、live command、order form、position command、stop trading command、emergency stop、shutdown / restore command、broker connect UI、signed endpoint trigger、account endpoint trigger 或 ExecutionClient trigger。任何 current UI control 只能控制 local demo / filtering / read-only evidence inspection，不产生 trading side effect。

`MTP-179-UI-COPY-READ-MODEL-ONLY-LABELING`

UI copy / docs copy 必须使用 read-model-only、evidence、snapshot、summary、timeline、projection、ViewModel、blocked 或 unavailable 这些语义描述 Workbench。不得把 Workbench 文案写成 execute、submit、cancel、replace、trade、connect broker、sync account、start live、stop live、emergency stop 或 production operation。

`MTP-179-WORKBENCH-READMODEL-BOUNDARY-VALIDATION`

MTP-179 的验证只证明 Workbench read-model-only consumption boundary、ReadModel / ViewModel only input contract、Workbench / Report / Events surface split、no runtime / adapter / schema / payload exposure、no live command surface guard 和 UI copy read-model-only labeling 已落仓；不证明 source move、Package.swift target graph change、Workbench runtime、Live PRO Console 或 command-capable UI 已实现。

`MTP-180-FUTURE-LIVE-PRO-CONSOLE-PRODUCT-SURFACE-SPLIT`

Future Live PRO Console product-surface split 表示 Live PRO Console 是独立 future surface，不是 current Workbench 的自然扩展。Current Workbench 仍只做 read-model-only evidence / snapshot / summary / timeline inspection；Future Live PRO Console 只能作为未来 command-capable candidate 被记录。

`MTP-180-FUTURELIVEPROCONSOLE-BOUNDARY-LABEL`

`Sources/Workbench/FutureLiveProConsole/` 目前只是 future boundary label，不是当前目录、target、route、ViewModel 或 runtime implementation。该 label 只说明后续 L4 规划可能需要独立产品面，不授权当前创建 Live PRO Console source tree。

`MTP-180-CURRENT-WORKBENCH-VS-FUTURE-COMMAND-SURFACE`

Current Workbench 与 future command surface 的分离规则是：Workbench 只能消费 ReadModel / ViewModel / evidence surface；future command surface 即使被命名，也不能把 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload、broker state、ExecutionClient request、OMS order 或 live command payload 带入当前 Workbench。

`MTP-180-LIVE-COMMAND-CONTROLS-FUTURE-ONLY`

Live PRO Console、trading button、live command、order form、position command、emergency stop、shutdown、restore、broker connect、account connect 和 production operation control 都是 future-only controls。当前文档只能把它们描述为 future-gated / forbidden capability，不得写成当前可用 UI 或操作能力。

`MTP-180-NO-CURRENT-LIVE-PRO-CONSOLE-IMPLEMENTATION`

No current Live PRO Console implementation 表示本阶段不创建 FutureLiveProConsole 类型、不新增交易按钮、不新增 live command、不新增 order form、不新增 stop / shutdown / restore command、不新增 broker session control、不新增 ExecutionClient / OMS UI 入口。

`MTP-180-NEXT-STAGE-PRODUCT-SURFACE-READINESS-INPUT`

Next-stage product-surface readiness input 只记录后续 L4 planning 需要的事实：Workbench read-model-only boundary 已固定，Future Live PRO Console 仍需独立 Human decision、Project Definition、execution / broker / operations gates 和 validation matrix。它不创建 L4 Project / Issue，也不授权执行。

`MTP-180-FUTURE-LIVE-PRO-CONSOLE-VALIDATION`

MTP-180 的验证只证明 Future Live PRO Console product-surface split、boundary label、current Workbench vs future command surface separation、future-only live command controls、no current implementation 和 next-stage planning input 已落仓；不证明 Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore 已实现。

`MTP-181-L4-PLANNING-INPUT-MATERIAL`

L4 planning input material 指 MTP-181 为 Human + `@001 / PLN` 准备的下一阶段规划输入。它汇总 module map、dependency direction、forbidden audit、validation gaps 和 future gates，但不创建 L4 Linear Project / Issue，不推进 Todo，不授权 L4 execution。

`MTP-181-ENGINE-MODULE-BOUNDARY-MAP`

Engine module boundary map 是 DataClient / DataEngine / MessageBus / Cache / Database / Strategies / Trader / Account context / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench / Future Live PRO Console 的 target boundary 对照表。该 map 只描述边界和依赖，不表示目录、target 或 runtime 已迁移完成。

`MTP-181-DEPENDENCY-DIRECTION-SUMMARY`

Dependency direction summary 表示 L4 规划必须保留 upstream data / evidence flow 到 ReadModel / ViewModel / Workbench，以及 Strategies / Trader 经 RiskEngine / ExecutionEngine 后进入 Portfolio projection 的方向。任何 Workbench -> Runtime object、Strategy -> ExecutionClient、Trader -> broker gateway、DataClient -> Database account payload 或 DataEngine -> UI command path 都仍是 forbidden capability。

`MTP-181-FORBIDDEN-CAPABILITY-AUDIT`

Forbidden capability audit 是 L4 planning 的负面证据清单：credential、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、broker adapter、ExecutionClient implementation、OMS implementation、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console command controls、Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload 和 broker state 均未授权。

`MTP-181-VALIDATION-GAPS-FUTURE-GATES`

Validation gaps / future gates 表示 L4 需要新的 Project Definition、signed / account gate、broker / execution gate、product surface gate、operations gate 和 validation matrix gate。当前 architecture boundary evidence 不能替代这些 gate。

`MTP-181-NO-L4-PROJECT-ISSUE-AUTHORIZATION`

No L4 Project / Issue authorization 表示 MTP-181 不创建下一阶段 Linear Project / Issue、不启动 @002 新项目、不启动 Symphony、不更新 next-stage Todo、不运行 Graphify、不修改 Figma。后续必须由 Human + `@001 / PLN` 独立规划。

`MTP-181-L4-PLANNING-INPUT-VALIDATION`

MTP-181 的验证只证明 L4 planning input material、Engine module boundary map、dependency direction summary、forbidden capability audit、validation gaps / future gates 和 no L4 Project / Issue authorization 已落仓；不证明 L4 runtime、live production、broker path、Live PRO Console 或最终 Stage Code Audit Report 已实现。

## Paper Runtime Kernel Terms

`MTP-96-PAPER-RUNTIME-KERNEL-TERMS`

以下术语由 MTP-96 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的第一层 paper-only runtime foundation language。它们只用于 TradingClock、paper runtime kernel boundary、validation anchor 和后续 issue 的基础合同，不授权当前 scope 实现 CommandBus / EventBus / Paper RiskEngine / lifecycle coordinator / simulated fill / paper account projection。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `TradingClock` | paper runtime kernel 的 deterministic tick 来源，只允许 fixture / replay tick | 不等于 exchange clock、broker session clock、production scheduler 或 `Date()` wall clock |
| `TradingClockTick` | 本地 paper runtime 可消费的 tick fact，带 monotonic sequence 和 deterministic instant | 不等于 market sequence、broker sequence 或真实调度游标 |
| `paper runtime kernel boundary` | Core 层 value contract，固定 paper kernel 输入、输出、lifecycle、event stream 和 forbidden capability flags | 不等于 Runtime actor、生产调度服务、UI state 或 persistence schema |
| `paper command intake` | 允许进入 kernel boundary 的 paper / local / replay 输入类别，例如 paper session command、session local control、paper action proposal、paper execution decision 和 replay command | 不等于 live command、order form、real submit / cancel / replace 或 broker request |
| `paper event emission` | kernel boundary 允许输出的 `.paper` event envelope、replay result 或后续 projection trigger | 不等于 adapter payload、broker acknowledgement、database schema 或 Dashboard ViewModel |
| `kernel replay invariant` | replay 只能从 append-only event log facts 重建 deterministic evidence | 不等于 production recovery、broker replay、account replay 或 incident replay runtime |

`MTP-97-PAPER-RUNTIME-BUS-ROUTING-TERMS`

以下术语由 MTP-97 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper-only deterministic routing language。它们只用于 CommandBus / EventBus / MessageBus route evidence、correlation / causation tracing 和 Event Log / Replay 输入，不授权当前 scope 实现 Paper RiskEngine、paper lifecycle coordinator、真实 execution runtime、signed endpoint、broker action 或 live command。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `PaperRuntimeCommandBus` | Core 层 paper-only input classifier，把 paper session command、paper risk decision、paper lifecycle event 和 simulated fill event 展开为 deterministic routed messages | 不等于 live command bus、order submit bus、broker command plane 或 production scheduler |
| `PaperRuntimeEventBus` | Core 层本地 publish 边界，只把 routed message 发布到既有 `MessageBus` / append-only facts source | 不等于 external pub/sub、broker stream、exchange adapter 或 Runtime actor |
| `PaperRuntimeMessageBusRouting` | CommandBus -> EventBus -> MessageBus 的 MTP-97 便利编排入口，用 deterministic clock、envelope ID、correlation ID 和 causation ID 固定 route evidence | 不等于 live execution message bus、OMS bus 或真实订单状态机 |
| `PaperRuntimeRouteEvidence` | 从 `EventEnvelope` 或 replay result 重建的 route source / payload / stream / correlation / causation 摘要 | 不暴露 Runtime object、SQLite / DuckDB schema、adapter payload、broker acknowledgement 或 UI state |
| `paper runtime bus routing contract` | `PaperRuntimeBusRoutingContract` 中的 allowed buses、route sources、payload kinds、`.paper` / `.risk` streams 和 forbidden capability flags | 不授权 signed request routing、account endpoint、listenKey、execution report、broker fill 或 reconciliation |

`MTP-98-PAPER-PRETRADE-RISKENGINE-TERMS`

以下术语由 MTP-98 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper-only pre-trade risk language。它们只用于本地 sandbox proposal risk decision、blocker evidence、Event Log / Replay evidence 和 validation anchors，不授权当前 scope 实现 live risk engine、真实账户读取、broker position sync、margin、leverage、real pre-trade allow / reject runtime、circuit breaker、stop trading、emergency stop、Live PRO Console、live command 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Paper Pre-trade RiskEngine` | Core 层本地 paper-only runtime path，把 paper proposal、paper account snapshot、paper exposure 和 deterministic paper risk rules 转成 accepted / rejected paper risk decision | 不等于 live risk engine、真实账户风控、broker rejection 或 future live risk decision |
| `paper account snapshot` | 本地 sandbox available paper balance 证据，只用于 MTP-98 paper risk 输入 | 不读取 account endpoint、真实账户余额、broker position、margin 或 leverage |
| `paper risk rule` | deterministic paper risk rule，例如 max paper quantity、max paper notional、max paper gross exposure 和 available paper balance | 不等于交易所风控、broker-side throttling、真实 pre-trade policy 或 production risk config |
| `accepted paper risk decision` | 当前 paper proposal 在 deterministic rules 下通过，只允许作为 paper-only decision 写入 `.risk` event evidence | 不授权真实订单、real submit、future live risk allowed 或 broker action |
| `rejected paper risk decision` | 当前 paper proposal 被 deterministic rules 阻断，并携带 paper-only `RiskBlockerEvidence` | 不等于 broker rejection、future live risk blocked、circuit breaker、no-trade state 或 stop control |
| `PaperPreTradeRiskEnginePublication` | MTP-98 rejected decision 经 MTP-97 routing 写入 `MessageBus` 后的 route evidence 与 replay evidence 对照 | 不暴露 Runtime object、Persistence schema、adapter object、broker acknowledgement 或 UI command |
| `paper risk no live account / broker upgrade` | paper risk blocker、paper exposure 和 paper account snapshot 必须保持本地 sandbox 语义 | 不得升级为真实账户 exposure、broker position、margin / leverage、real pre-trade allow / reject、future live risk decision 或交易按钮 |

`MTP-99-PAPER-LOCAL-LIFECYCLE-TERMS`

以下术语由 MTP-99 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper-only local lifecycle language。它们只用于本地 lifecycle coordinator、local order transition fact、simulated fill 前置状态、Event Log / Replay evidence 和 validation anchors，不授权当前 scope 实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、单笔 order cancel button、order-level command UI、Live PRO Console、live command 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `paper-only lifecycle coordinator` | Core 层本地 paper lifecycle value orchestration，消费 MTP-98 accepted / rejected paper risk decision 并输出 local lifecycle transition fact | 不叫 OMS，不等于 broker router、execution engine、真实订单状态机或 Runtime actor |
| `PaperOrderLocalLifecycleState` | 本地 paper order lifecycle 状态集合：proposed、submitted local、accepted local、rejected by paper risk、cancelled local、expired local、failed local | 不等于 exchange accepted、broker submitted、broker filled、真实 cancel 或真实 rejected |
| `PaperOrderLocalLifecycleTransition` | 写入 `.paper` stream 的 append-only local lifecycle transition fact，带 order、proposal、risk decision、from / to state、trigger 和 source sequence | 不暴露 broker acknowledgement、execution report、Persistence schema 或 UI command |
| `cancelled local` | 只能来自 session close / reset、local expiry 或 deterministic local rule 的本地取消结果 | 不等于用户单笔撤单、broker cancel、exchange cancel 或 real cancel command |
| `accepted local` | 本地 deterministic rule 下满足 simulated fill 前置条件的状态 | 不等于 exchange accepted、broker accepted、真实订单可成交或执行授权 |
| `PaperOrderSimulatedFillPrecondition` | 证明 accepted local 已写入 event fact、后续 MTP-100 可以消费的 simulated fill 前置证据 | 不生成 simulated fill，不计算 fee / slippage，不表示 broker fill、execution report 或 reconciliation |

`MTP-99-NO-OMS-BROKER-REAL-CANCEL`

MTP-99 的 local lifecycle evidence 不得升级为 OMS、broker adapter、real order state machine、真实 submit / cancel / replace、execution report、broker fill、reconciliation、单笔 order cancel button、order-level command UI、live command、order form 或交易按钮。

`MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-TERMS`

以下术语由 MTP-100 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper-only simulated fill / fee / slippage language。它们只用于 deterministic market snapshot、fill assumption、partial / full simulated fill evidence、Event Log / Replay evidence 和 validation anchors，不授权当前 scope 实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation、broker / signed endpoint / account endpoint 或真实账户更新。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `PaperSimulatedFillMarketSnapshot` | simulated fill model 的本地 market-side 输入，只保存 fixture / replay bid、ask、last price 和 source anchor | 不等于 Adapter payload、live market stream、signed endpoint、account endpoint、broker stream 或 execution report |
| `PaperSimulatedFillCompletion` | simulated fill 的 deterministic completion 分类：`full` 或 `partial` | 不等于真实成交状态、broker partial fill 或交易所撮合结果 |
| `PaperSimulatedFillPriceSource` | fill price assumption 的本地来源：order reference、market last price、best bid 或 best ask | 不等于真实成交价格发现、动态滑点模型或执行成本优化 |
| `PaperSimulatedFillEvidence` | paper-only simulated fill、fee、slippage 和 cost impact 的可 replay 证据 | 不等于真实 fill、broker fill、execution report、account update 或 reconciliation |
| `PaperSimulatedFillEventLogBoundary` | 复用 MTP-97 routing 将 simulated fill evidence 写入 `.paper` Event Log 的 Core 边界 | 不等于 Runtime actor、broker event bus、OMS 或外部 pub/sub |
| `PaperSimulatedFillReplayPath` | 从 append-only replay result 重建 partial / full simulated fill facts | 不等于 broker replay、account replay、incident replay 或 production recovery |

`MTP-100-NO-BROKER-EXECUTION-REPORT-RECONCILIATION`

MTP-100 的 simulated fill evidence 不得升级为 broker fill、execution report、真实 fee statement、真实成交质量分析、live reconciliation、real account balance update、signed endpoint、account endpoint、broker action、Live PRO Console、live command、order form 或交易按钮。

`MTP-101-PAPER-ACCOUNT-PORTFOLIO-PROJECTION-TERMS`

以下术语由 MTP-101 定义为 `MTPRO Event-Driven Paper Trading Runtime v1` 的 paper account /
portfolio / position projection v2 language。它们只用于 replayed simulated fill -> projection ->
read model 的本地 sandbox 账本，不授权真实账户、broker position、margin、leverage、real PnL、
live risk runtime、Live PRO Console、live command 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `paper account projection v2` | 从 replayed simulated fill、fee / slippage cost impact 和 starting cash 推导的本地 sandbox account snapshot | 不等于 real account balance、account endpoint payload 或 broker statement |
| `paper position projection v2` | 从 replayed simulated fills 聚合 symbol / timeframe net quantity、average entry、last fill price、market value 和 cost basis | 不等于 broker position、margin position、leverage position 或真实持仓同步 |
| `paper portfolio projection v2` | 组合 account、positions、exposures 和 PnL summary 的 MTP-101 read model source | 不等于真实 portfolio、OMS state、broker sync 或 Live fallback |
| `paper PnL summary` | 基于本地 simulated fill cost impact、position market value 和 cost basis 的 realized / unrealized / net paper PnL | 不等于 real PnL、fee statement、margin PnL 或税务 / 对账结果 |
| `replayed simulated fill projection` | projection 只能从 Event Log replay result 中的 `.paper.simulatedFillRecorded` facts 派生 | 不直接读取 risk decision、Runtime object、SQLite schema、adapter payload、broker state 或真实账户 |
| `MTP-101 read model consumption` | Persistence / App / Dashboard / Report / Risk / Portfolio 只能消费 read model / ViewModel | 不暴露 database schema、Runtime object、adapter request、position command 或交易按钮 |

`MTP-101-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`

MTP-101 的 paper account / portfolio / position projection v2 不得升级为真实账户余额、broker
position sync、margin、leverage、real PnL、live risk runtime、account endpoint、signed endpoint、
broker action、Live PRO Console、live command、order form、position command 或交易按钮。

## Live Boundary Terms

以下术语只用于 Future / gated 实盘边界设计和当前 blocked evidence，不授权当前 scope 实现真实交易能力。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `live capability` | 未来实盘交易基础能力的候选名称，例如 secret policy、signed endpoint、account endpoint、broker / exchange adapter、real order lifecycle | 不等于当前已有可执行能力 |
| `blocked capability` | 当前已识别但被 gate 阻断的能力；可以进入 read-model-only blocked evidence | 不等于 fallback、mock broker 或 paper order 升级 |
| `future gate` | 某项 live capability 进入后续 Project Definition 前必须满足的条件和证据 | 不自动解锁 Linear issue，不推进 Todo |
| `forbidden capability` | 当前 Project 明确禁止的能力；任何代码、测试或文档都不得把它表达成当前可用能力 | 不写成 allowed capability，不写成 partially supported |
| `credential endpoint boundary` | MTP-62 Gate 1 中 API key、secret storage、request signature、signed endpoint、account endpoint 和 listenKey 只能作为 forbidden / future gate 出现的边界 | 不读取本地 secret，不新增 env/config/keychain，不实现签名请求或 account payload |
| `adapter capability isolation` | MTP-63 Gate 2 中 current public read-only adapter 与 future live adapter / broker / exchange execution adapter 的隔离合同 | 不实现 `LiveExecutionAdapter`，不连接 execution venue，不把 public market data adapter 升级为执行 adapter |
| `real order lifecycle boundary` | MTP-64 Gate 3 中 real order intent、state machine、submit / cancel / replace、execution report、broker fill、reconciliation、OMS 和 real account state 只能作为 terminology、future gate 和 forbidden tests 出现的边界 | 不实现真实订单状态机，不把 paper order intent、simulated fill 或 paper portfolio projection 升级为 real order、broker fill 或 account state |
| `Live readiness blocked read model` | MTP-65 Gate 4 中 `LiveReadiness` / `LiveBlockedEvidence` 只用 read-model-only 方式说明 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle 仍被阻断 | 不提供 live command，不暴露 adapter / runtime / persistence schema，不授权真实交易或交易按钮 |
| `Live blocked evidence surface` | MTP-66 Gate 5 中 Dashboard / Report / Event Timeline 只读展示 `LiveReadiness` blocked evidence 的产品面 | 不等于实盘监控台、实盘执行控制、实盘风险控制、实盘审计或任何交易入口 |

## Live Monitoring Terms

`MTP-68-LIVE-MONITORING-TERMS`

以下术语由 MTP-68 定义为 `MTPRO Live Monitoring Console v1` 的 read-model-only language。它们只用于信息架构、合同和后续验证 anchor，不授权当前 scope 实现 live runtime、真实连接或交易执行能力。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `live monitoring console` | 后续实盘监控台的信息架构和只读 evidence surface，覆盖 runtime health、connection、market stream、order stream evidence、latency、error、degraded state 和 operations evidence | 不等于当前 live runtime，不等于执行控制台，不提供交易按钮 |
| `live runtime health` | 后续 read model 可表达的 runtime health status，例如 blocked、unknown、nominal、stale、degraded、error、recovered | 不等于当前已启动 runtime actor 或生产进程 |
| `connection status` | 后续连接状态只读证据，可描述 public connection 或 future private connection gate | 不等于 account endpoint、listenKey、private WebSocket 或 broker session |
| `market stream status` | Binance public read-only market stream 的健康、freshness 和 latency evidence | 不等于 signed endpoint、account stream 或 execution venue |
| `order stream evidence` | 订单流相关的 blocked / simulated / future-only evidence，用于解释真实订单流仍未实现或后续 gate | 不等于 real order state machine、execution report、broker fill、OMS 或真实账户状态 |
| `latency evidence` | 从 read model 派生的延迟 bucket、last update、freshness 和 stale evidence | 不等于 runtime profiler、生产 telemetry agent 或自动扩缩容信号 |
| `error evidence` | 后续 Report / Dashboard / Event Timeline 可展示的错误事实摘要 | 不等于 incident command、自动恢复动作或 broker failure handler |
| `degraded state` | health / connection / stream / latency / error evidence 显示降级，但仍只作为可观察事实 | 不等于允许绕过 risk gate 或继续执行真实订单 |
| `operations evidence` | validation、handoff、Stage Audit input、known boundary 和 readiness evidence chain | 不等于 production operations command、部署或远程运维 |

## Live Monitoring Read-only Console v2 Terms

`MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-TERMINOLOGY`

以下术语由 MTP-147 定义为 `L3.3 Live Monitoring Read-only Console v2` 的 terminology / boundary language。它们只用于把 L3.0 / L3.1 / L3.2 已完成 evidence 组织成后续 read-model-only monitoring evidence，不授权 live readiness runtime、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、Live PRO Console、trading button、live command 或 order form。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Live Monitoring Read-only Console v2` | L3.3 只读 monitoring evidence console 的合同名称，组织 L3.0 readiness boundary、L3.1 APB read-model-only evidence 和 L3.2 simulation gate evidence | 不等于 Live Monitoring runtime、Live readiness runtime、Live PRO Console、broker console 或交易控制台 |
| `monitoring evidence` | 来自 read-model-only、fixture、paper、simulated 或 future-gated source label 的只读观察证据 | 不等于 runtime telemetry、account endpoint payload、private stream event、broker state 或 production monitoring agent |
| `monitoring source boundary` | monitoring evidence 只能来自 L3.0 / L3.1 / L3.2 已完成证据链的来源边界 | 不等于 source adapter、connection manager、private stream runtime 或 account snapshot runtime |
| `read-only monitoring state` | blocked、stale、missing、simulated、fixture、future-gated 等只读状态解释 | 不等于实时连接状态、自动恢复动作、交易授权或 live command enablement |
| `monitoring boundary entry` | Workbench / Report / Events 后续可引用的 boundary anchor、source anchor 和 validation anchor | 不等于 Dashboard surface、Swift ViewModel implementation 或 Event Timeline item implementation |
| `L3.3 monitoring handoff` | MTP-147 把 terminology / boundary 交给 MTP-148 至 MTP-153 的范围边界 | 不自动推进后续 issue，不授权 monitoring source identity、health evidence、connection explanation、forbidden tests、surface 或 stage closeout |

`MTP-147-MONITORING-EVIDENCE-SOURCE-BOUNDARY`

MTP-147 固定 monitoring evidence source boundary：L3.0 只提供 readiness / endpoint / adapter capability baseline，L3.1 只提供 account / position / balance read-model-only vocabulary input，L3.2 只提供 private stream / account snapshot simulation input。MTP-147 不新增 source implementation、fixture payload、Swift production code、focused XCTest 或 Dashboard smoke handle。

`MTP-147-READ-MODEL-VIEWMODEL-CONSUMPTION-BOUNDARY`

Workbench / Report / Events 后续只能消费 Read Model / ViewModel，不得直接读取 adapter request、Runtime object、SQLite / DuckDB schema、account payload、broker payload、secret config 或 broker state，也不得提供 API key input、account connect、broker connect、private stream connect、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore command。

`MTP-147-L33-HANDOFF-BOUNDARY`

MTP-147 只交付 terminology / boundary input。MTP-148 才能定义 monitoring source identity；MTP-149 才能定义 health / freshness evidence；MTP-150 才能定义 connection readiness explanation；MTP-151 才能定义 forbidden runtime / endpoint / UI command tests；MTP-152 才能接入 Workbench / Report / Events read-model-only surface；MTP-153 才能收口 validation matrix / automation readiness / stage audit input。

`MTP-147-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record、Linear Project issue order、next eligible candidate、Backlog issue、label、priority、assignee 或 estimate 都不构成执行授权。MTP-147 完成后不得自动推进 MTP-148；MTP-148 至 MTP-153 必须继续等待 Linear live-read 中唯一 eligible issue 授权。

`MTP-147-FORBIDDEN-CAPABILITY-BASELINE`

MTP-147 禁止 signed endpoint、account endpoint / listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、live readiness runtime、Live Monitoring runtime、account / position / balance runtime、real account read、broker position sync、margin / leverage、real PnL runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、emergency stop / shutdown / restore executable action、Graphify update 和 Figma change。

`MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-VALIDATION`

`MTP-148-MONITORING-SOURCE-IDENTITY`

MTP-148 把 monitoring source identity 固定为 Core deterministic source identity 合同：`LiveMonitoringSourceIdentityContract` 只引用 L3.0 readiness boundary、L3.1 account / position / balance read-model-only fixture、L3.2 private stream / account snapshot simulation gate 和 future real account unavailable label。它不等于 source adapter、connection manager、private stream runtime、account snapshot runtime、broker connector 或真实账户身份。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `monitoring source identity` | 用于解释 monitoring evidence 来源的只读身份，当前来自 boundary / fixture / simulated / read-model-only evidence | 不等于 API key、secret、listenKey、account endpoint、private WebSocket、broker account id 或 connection identity |
| `evidence origin boundary` | source identity 必须标明来源属于 boundary、fixture、simulated 或 read-model-only | 不等于 adapter capability、Runtime object、database schema 或 broker payload |
| `monitoring source status` | available、stale、blocked、unavailable 的只读 source 解释状态 | 不等于 live connection state、broker connectivity、automatic reconnect 或 recovery action |
| `source unavailable semantics` | future real account source 当前不可用且只作为 label 出现 | 不等于真实 account endpoint down、broker outage、listenKey expired 或 private stream disconnected |

`MTP-148-EVIDENCE-ORIGIN-BOUNDARY-FIXTURE-SIMULATED-READ-MODEL-ONLY`

MTP-148 只允许 boundary / fixture / simulated / read-model-only 四类 evidence origin。L3.1 fixture source identity 固定为 `fixture:mtp-137-account-position-balance-read-model-only`；L3.2 simulated source identity 固定为 `simulated:private-stream:mtp-141-scenario-replay-private-account-event`；future real account 只能是 `unavailable:future-real-account-source-label-only`。

`MTP-148-SOURCE-FRESHNESS-STATUS-UNAVAILABLE-SEMANTICS`

MTP-148 的 freshness / status 只解释本地 evidence 是否可展示：fresh / available 表示 deterministic evidence 可用，blocked 表示被 forbidden boundary 阻断，unavailable 表示 future real account source 当前不可用且不会触发 endpoint、listenKey、private stream、broker sync 或 reconnect。

`MTP-148-SIMULATED-FIXTURE-NOT-REAL-ACCOUNT-GUARD`

MTP-148 必须防止 simulated / fixture evidence 被解释为真实账户或真实 broker state。它禁止 API key、secret、listenKey、signed endpoint、account endpoint、private WebSocket runtime、private stream runtime、account snapshot runtime、real account read、account payload、broker payload、broker state、adapter request、Runtime object、database schema、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、Live PRO Console、trading button、live command 和 order form。

`MTP-148-LIVE-MONITORING-SOURCE-IDENTITY-VALIDATION`

MTP-147 required validation 是 `bash checks/run.sh`，并通过 contract、domain context、trading validation matrix、validation plan、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` 机械固定 terminology、boundary、forbidden capability baseline 和 no runtime authorization。MTP-147 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 MTP-153。

`MTP-149-SIMULATION-GATE-HEALTH-FRESHNESS-EVIDENCE`

MTP-149 把 MTP-148 monitoring source identity 与 MTP-144 simulated account snapshot freshness evidence 组合成 Core deterministic health evidence 合同：`LiveMonitoringSimulationGateHealthContract`、`LiveMonitoringSimulationGateHealthEvidenceItem`、`LiveMonitoringSimulationGateHealthStatus`、`LiveMonitoringSimulationGateFreshnessExplanation` 和 `LiveMonitoringSimulationGateHealthForbiddenCapability`。这些 evidence 只解释 L3.2 simulation gate 的 read-model-only 展示状态，不代表真实账户健康、真实 broker 连接、private stream 状态或 live connection status。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `simulation gate health evidence` | 从 MTP-144 fresh / stale / blocked / missing fixture 派生的只读 health evidence | 不等于 real account health、broker connectivity、private stream health 或 live monitoring runtime |
| `freshness explanation` | within threshold / threshold exceeded / boundary-held / input absent 的本地解释 | 不触发 endpoint call、listenKey、private WebSocket、refresh、reconnect 或 recovery action |
| `blocked display semantics` | blocked evidence 只能展示 boundary-held read-only evidence | 不等于连接失败、自动修复、broker outage、account endpoint down 或 incident action |
| `fixture simulated read-model-only source` | health evidence 只能来自 fixture + simulated + read-model-only source identity 和 MTP-144 checksum | 不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload 或 broker state |

`MTP-149-HEALTH-FRESHNESS-NOT-REAL-ACCOUNT-HEALTH`

MTP-149 的 health / freshness 只解释 simulated gate evidence：fresh 显示 nominal simulated gate health，stale 显示 stale simulated gate health，blocked 显示 boundary-held evidence，missing 显示 fixture input absent evidence。任何状态都不得升级为真实账户健康、真实 broker 连接健康、private stream runtime 状态、account snapshot runtime 状态或 live connection status。

`MTP-149-READ-MODEL-ONLY-NON-EXPOSURE`

MTP-149 必须保持 read-model-only non-exposure：不调用 signed endpoint / account endpoint，不创建 listenKey，不打开 private WebSocket，不运行 private stream runtime 或 account snapshot runtime，不读取真实 account / position / balance，不消费或暴露 account payload，不暴露 broker state、Adapter request、Runtime object 或 SQLite / DuckDB schema，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、live command、trading button、order form 或 real order write。

`MTP-149-LIVE-MONITORING-SIMULATION-GATE-HEALTH-VALIDATION`

`MTP-150-CONNECTION-READINESS-EXPLANATION`

MTP-150 把 MTP-148 monitoring source identity 与 MTP-149 simulation gate health evidence 派生成 Core deterministic connection readiness explanation 合同：`LiveMonitoringConnectionReadinessExplanationContract`、`LiveMonitoringConnectionReadinessExplanationItem`、`LiveMonitoringConnectionReadinessExplanationState`、`LiveMonitoringConnectionReadinessDisplaySemantics` 和 `LiveMonitoringConnectionReadinessForbiddenCapability`。这些 explanation 只表达 readiness / stale / blocked / missing 的只读展示含义，不是连接状态机，不表示真实连接已建立，不创建 connection manager、endpoint、private stream、broker adapter 或 live command。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `connection readiness explanation` | 从 MTP-149 health evidence 派生的只读 readiness 解释 | 不等于 live readiness implementation、connection manager、broker connectivity 或 private stream state |
| `readiness explanation` | simulated gate evidence 当前足以展示 readiness 解释 | 不等于真实连接成功、account endpoint 可用或 broker session 可用 |
| `stale readiness explanation` | simulated gate evidence stale，只能展示 stale 解释 | 不触发 refresh、reconnect、listenKey、endpoint call 或 recovery action |
| `blocked readiness explanation` | boundary-held evidence 只能展示 blocked 解释 | 不等于连接失败、broker outage、incident command 或自动修复 |
| `missing readiness explanation` | required simulated evidence absent，只能展示 missing 解释 | 不使用 fallback source，不读取真实 account payload 或 broker state |

`MTP-150-STALE-BLOCKED-MISSING-UI-REPORT-SEMANTICS`

MTP-150 的 UI / report 语义只给后续 MTP-152 read-model-only surface 提供稳定输入：readiness、stale、blocked、missing 四类 explanation 都必须以 Read Model / ViewModel 方式展示，不能暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、endpoint payload、connection object 或 private stream object。

`MTP-150-NO-RUNTIME-CONNECTION-BOUNDARY`

MTP-150 必须保持 no-runtime-connection boundary：不实现 connection manager，不打开 runtime connection，不实现 live readiness implementation 或 Live Monitoring runtime，不调用 signed endpoint / account endpoint，不创建 listenKey，不连接 private WebSocket，不运行 private stream runtime 或 account snapshot runtime，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、Live PRO Console、trading button、live command 或 order form。

`MTP-150-READINESS-EXPLANATION-NOT-LIVE-READINESS`

MTP-150 的 readiness wording 必须避免暗示真实连接已建立。`readiness` 只表示 deterministic simulated evidence 可被解释和展示，不表示 live readiness、broker connectivity、private stream health、account endpoint health、real account state 或 production monitoring runtime。

`MTP-150-LIVE-MONITORING-CONNECTION-READINESS-VALIDATION`

`MTP-151-FORBIDDEN-LIVE-MONITORING-CAPABILITY-TESTS`

MTP-151 把 Live Monitoring v2 的 forbidden capability tests 固定成 Core deterministic test matrix：`LiveMonitoringForbiddenCapabilityTestContract`、`LiveMonitoringForbiddenCapabilityTestCase`、`LiveMonitoringForbiddenCapabilityTestDomain` 和 `LiveMonitoringForbiddenCapabilityTestAssertion`。这些 tests 只描述本地检查覆盖，不实现 endpoint、runtime、broker adapter、Live PRO Console 或 UI command。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `forbidden capability test matrix` | MTP-151 对 endpoint、private stream runtime、broker / execution、Live Monitoring runtime 和 UI command 禁区的本地确定性检查矩阵 | 不等于 runtime implementation、adapter、UI command 或完整监控台页面 |
| `endpoint forbidden tests` | signed endpoint、account endpoint、listenKey 必须被拒绝的检查入口 | 不调用真实 endpoint，不读取 secret，不创建 listenKey |
| `private stream runtime forbidden tests` | private WebSocket runtime、private stream runtime、account snapshot runtime 必须被拒绝的检查入口 | 不打开 WebSocket，不运行私有流或账户快照 runtime |
| `broker execution forbidden tests` | broker adapter、exchange execution adapter、`LiveExecutionAdapter`、OMS 必须被拒绝的检查入口 | 不连接 broker / exchange，不实现 OMS 或 real order lifecycle |
| `UI command forbidden tests` | Live PRO Console、trading button、live command、order form、stop / shutdown / restore command 必须被拒绝的检查入口 | 不新增 UI command，不实现 stop / shutdown / restore |

`MTP-151-FORBIDDEN-ENDPOINT-RUNTIME-BROKER-UI-COVERAGE`

MTP-151 的 coverage 必须覆盖 endpoint、listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、connection manager、runtime connection、live readiness runtime、Live Monitoring runtime、broker adapter、exchange execution adapter、`LiveExecutionAdapter`、OMS、Live PRO Console、trading button、live command、order form 和 stop / shutdown / restore command。

`MTP-151-MONITORING-EVIDENCE-NOT-LIVE-RUNTIME-GUARD`

MTP-151 必须防止 MTP-147 至 MTP-150 的 monitoring evidence 被解释为 live readiness runtime 或 Live Monitoring runtime。检查本身必须 deterministic local-only、read-model-only、no-network，不依赖真实账户、真实 broker、真实 endpoint 或真实 WebSocket。

`MTP-151-LIVE-MONITORING-FORBIDDEN-CAPABILITY-VALIDATION`

`MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`

MTP-152 把 MTP-148 source identity、MTP-149 simulation gate health、MTP-150 readiness explanation 和 MTP-151 forbidden capability tests 接入 App 层 `LiveMonitoringReadOnlyConsoleV2SurfaceReadModel` / `LiveMonitoringReadOnlyConsoleV2SurfaceViewModel`，供 Workbench / Report / Events 只读展示。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Live Monitoring v2 surface` | MTP-152 的 Workbench / Report / Events read-model-only evidence surface | 不等于 Live PRO Console、Live Monitoring runtime、connection manager 或 broker console |
| `monitoring source freshness explanation surface` | 将 source freshness、health freshness、readiness / stale / blocked / missing explanation 汇总成只读 summary | 不等于真实连接状态、account endpoint health、private stream health 或 production monitoring runtime |
| `forbidden capability surface evidence` | 展示 MTP-151 forbidden test coverage 的 evidence rows | 不等于 endpoint test runner、runtime implementation、adapter 或 UI command |
| `liveMonitoringReadOnlyConsoleV2Surface` | Dashboard smoke / Workbench metrics 中的 read-model-only handle | 不是 trading button、live command、order form 或 connection control |

`MTP-152-MONITORING-SOURCE-FRESHNESS-EXPLANATION-SURFACE`

MTP-152 只能把 source identity、source freshness、health freshness、readiness / stale / blocked / missing explanation 和 forbidden capability test coverage 表达为 Read Model / ViewModel evidence。它不能暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、endpoint payload、connection object 或 private stream object。

`MTP-152-NO-RUNTIME-ADAPTER-SCHEMA-PAYLOAD-BROKER-STATE-SURFACE`

MTP-152 的 Workbench / Report / Events surface 必须保持 no runtime / adapter / schema / payload / broker state boundary：不创建 signed endpoint、account endpoint、listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、connection manager、runtime connection、live readiness runtime、Live Monitoring runtime、broker adapter、exchange execution adapter、`LiveExecutionAdapter`、OMS、Live PRO Console、trading button、live command、order form 或 real order command。

`MTP-152-LIVE-MONITORING-V2-SURFACE-VALIDATION`

`MTP-153-LIVE-MONITORING-V2-STAGE-CLOSEOUT`

MTP-153 stage closeout 只把 `MTPRO Live Monitoring Read-only Console v2` 的 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence、Workbench / Report / Events Live Monitoring v2 surface evidence 和 Stage Code Audit input material 收口为 Parent Codex 审计输入。该 closeout 不是最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进 L3.4 / L4，也不启动下一阶段 `symphony-issue`。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Live Monitoring v2 stage audit input` | MTP-153 为 Parent Codex Stage Code Audit 准备的 Project 级审计输入材料 | 不等于最终 Stage Code Audit Report、Project closure、Root Docs Refresh Gate 或下一阶段授权 |
| `Live Monitoring v2 closeout evidence chain` | MTP-147 至 MTP-152 的 terminology、source identity、health、readiness explanation、forbidden tests 和 read-model-only surface 汇总 | 不等于 runtime telemetry、account endpoint payload、broker state 或 production monitoring agent |
| `Live Monitoring v2 automation readiness closeout` | MTP-153 将 stage audit input、matrix、validation plan、latest summary 和 automation readiness doc 接入机械检查 | 不等于启动 Symphony、修改 active Project pointer、运行 Graphify 或创建下一 issue |

`MTP-153-STAGE-AUDIT-INPUT-MATERIAL`

MTP-153 stage audit input material 落仓于 `docs/audit/inputs/mtpro-live-monitoring-read-only-console-v2-stage-audit-input.md`，用于汇总 MTP-147 至 MTP-152 的 issue / PR / merge / required check evidence、`TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2` evidence chain、forbidden capability evidence chain、Dashboard smoke `liveMonitoringReadOnlyConsoleV2Surface=4` handle 和 Parent Codex final Stage Code Audit handoff checklist。

`MTP-153-NO-FINAL-STAGE-CODE-AUDIT`

MTP-153 不输出最终 Stage Code Audit Report。最终报告必须在 MTP-147 至 MTP-153 全部 Linear `Done`，且 Linear Project `Completed/type=completed/completedAt` evidence 齐备后，由 Parent Codex 单独输出。

`MTP-153-VALIDATION-EVIDENCE-CHAIN`

MTP-153 validation evidence chain 必须覆盖 MTP-147 terminology / boundary、MTP-148 monitoring source identity、MTP-149 simulation gate health / freshness、MTP-150 connection readiness explanation、MTP-151 forbidden capability tests、MTP-152 Workbench / Report / Events read-model-only surface，以及 MTP-153 自身的 stage audit input、automation readiness 和 matrix backfill。

`MTP-153-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-153 继续确认 signed endpoint、account endpoint / listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、live readiness runtime、Live Monitoring runtime、source adapter、connection manager、runtime connection、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command、order form、stop / shutdown / restore、Graphify update 和 Figma change 在当前 Project 中全部禁止。

`MTP-153-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`

MTP-153 必须确认 Live Monitoring v2 的 Workbench / Report / Events evidence 只来自 deterministic Core contract 和 App Read Model / ViewModel，不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload、broker state、signed endpoint、account endpoint、listenKey、private WebSocket 或 real account state。

`MTP-153-AUTOMATION-READINESS-STAGE-CLOSEOUT`

MTP-153 automation readiness stage closeout 只机械固定 MTP-153 input、contract、domain context、validation plan、Trading Validation Matrix、latest summary、automation readiness doc、MTP-147 至 MTP-152 evidence anchors、PR evidence 和 Dashboard smoke handle，不运行 Graphify、不修改 Figma、不创建下一 Project / Issue。

`MTP-153-STAGE-CLOSEOUT-VALIDATION`

## Strategy / Trader Instance Readiness Terms

`MTP-154-STRATEGY-TRADER-INSTANCE-READINESS-TERMINOLOGY`

以下术语由 MTP-154 定义为 `L3.4 Strategy / Trader Instance Readiness v1` 的 terminology / boundary language。它们只用于 Strategy / Trader structural readiness、readiness evidence、paper/live-neutral proposal boundary 和后续 issue handoff，不授权 Strategy runtime、Trader runtime、Execution Client direct path、broker command、OMS、Live PRO Console、trading button、live command、order form、signed endpoint、account endpoint / listenKey 或 broker / exchange execution adapter。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Strategy Instance` | 可被识别、审查和追溯的策略结构实例，只代表配置、角色、输入引用、proposal boundary 和 readiness evidence identity | 不等于 Strategy runtime、scheduler、order generation engine、Execution Client caller 或 broker command producer |
| `Trader Instance` | 可被识别、审查和追溯的交易者结构实例，只代表 future trader context 的只读 readiness shell | 不等于 Trader runtime、process manager、account session、broker session、OMS 或 live command actor |
| `strategy / trader readiness` | Strategy Instance / Trader Instance 是否具备后续合同深化所需的 terminology、identity、role、input、proposal isolation 和 forbidden capability evidence | 不等于运行中、可交易、可连接 broker、可提交订单或可进入 Live Production |
| `proposal` | Strategy / Trader 后续可能输出的 paper/live-neutral intent evidence，用来连接 read-model input、role responsibility 和 blocked / simulated / future-gated decision trace | 不等于 executable order command、broker command、Execution Client request、OMS order 或 UI order form payload |
| `readiness evidence` | 用于证明 Strategy / Trader Instance 仍停留在只读 readiness contract 内的 evidence anchor、source anchor、blocked reason 和 validation anchor | 不等于 runtime telemetry、broker acknowledgement、execution report、broker fill、reconciliation fact 或 production audit event |
| `paper/live-neutral proposal` | 不绑定真实账户、真实 broker、signed endpoint、account endpoint / listenKey 或 live venue 的 proposal 解释层 | 不等于 paper order execution path 的自动授权，也不等于 live order command 的预览或 beta |
| `non-execution baseline` | MTP-154 固定的基础约束：所有 Strategy / Trader 术语只能表达 readiness，不得创建执行路径 | 不等于 feature flag、local fallback、mock broker、behind flag execution 或 partial live support |

`MTP-154-READINESS-ONLY-BOUNDARY`

MTP-154 固定 Strategy / Trader Instance 只能进入 readiness contract。Strategy Instance / Trader Instance 是结构性 readiness vocabulary，不是运行时对象；readiness 只描述 identity、role、read-model input、proposal isolation、blocked evidence 和 validation anchors，不描述 strategy scheduler、trader process manager、live session 或 broker connection。MTP-154 不新增 Swift production code、focused XCTest、App read model、Dashboard surface 或 Dashboard smoke handle。

`MTP-154-PROPOSAL-READINESS-EVIDENCE-BASELINE`

MTP-154 的 proposal / readiness evidence 只停留在术语层。`strategy proposal`、`trader proposal` 和 `paper/live-neutral proposal` 不得包含 account id、broker account id、API key、secret、listenKey、private stream cursor、adapter request、Runtime object、OMS order id、order form payload 或 executable order command field；后续 MTP-158 才能定义 proposal contract。

`MTP-154-L34-HANDOFF-BOUNDARY`

MTP-154 只交付 terminology / boundary input。MTP-155 才能定义 lifecycle / instance identity；MTP-156 才能定义 quoter / hedger role taxonomy；MTP-157 才能定义 account / portfolio / risk read-model input；MTP-158 才能定义 paper/live-neutral proposal contract 和 execution command isolation；MTP-159 才能定义 forbidden Strategy -> Execution / broker / UI command tests；MTP-160 才能接入 Workbench / Report / Events read-model-only surface；MTP-161 才能收口 validation matrix / automation readiness / stage audit input。

`MTP-154-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record、Linear Project issue order、next eligible candidate、Backlog issue、label、priority、assignee 或 estimate 都不构成执行授权。MTP-154 完成后不得自动推进 MTP-155；MTP-155 至 MTP-161 必须继续等待 Linear live-read 中唯一 eligible issue 授权。

`MTP-154-FORBIDDEN-CAPABILITY-BASELINE`

MTP-154 禁止 Strategy runtime、Trader runtime、strategy scheduler、trader process manager、direct Strategy Instance -> Execution Client path、broker command、executable order command、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、real account read、broker position sync、margin / leverage、real PnL runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、emergency stop / shutdown / restore executable action、Graphify update 和 Figma change。

`MTP-154-STRATEGY-TRADER-INSTANCE-READINESS-VALIDATION`

MTP-154 required validation 是 `bash checks/run.sh`，并通过 contract、domain context、trading validation matrix、validation plan、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` 机械固定 terminology、boundary、forbidden capability baseline 和 no execution authorization。MTP-154 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

`MTP-155-STRATEGY-TRADER-LIFECYCLE-IDENTITY`

MTP-155 定义 Strategy Instance / Trader Instance 的 lifecycle、identity 和只读状态语义。`strategy instance identity` 与 `trader instance identity` 只由 local deterministic readiness fields 组成，用于 contract anchor、instance label、role reference、read-model reference、proposal boundary reference 和 evidence trace reference；不等于 runtime object id、broker account id、API key、secret、listenKey、adapter request id、OMS order id、trader process id、broker session id、account session id、private stream cursor、`LiveExecutionAdapter` handle 或 live command actor id。

`MTP-155-INSTANCE-IDENTITY-BOUNDARY`

Strategy / Trader identity 只能记录 `contractAnchor`、`instanceLabel`、`roleReference`、`readModelReference`、`proposalBoundaryReference` 和 `evidenceTraceReference`。这些字段只服务 read-model-only display、validation trace 和后续 issue handoff；不得承载 credential、secret、account id、broker account id、account payload、broker payload、Runtime object、Adapter request、SQLite / DuckDB schema、private stream cursor 或 executable order command field。

`MTP-155-LIFECYCLE-READINESS-STATE-SEMANTICS`

MTP-155 的 lifecycle state 只能表达 readiness evidence：`configured` 表示 identity contract 和 source anchors 已存在；`ready` 表示 terminology、identity、lifecycle 和 forbidden boundary anchors 已满足；`blocked` 表示 forbidden capability、future-gated dependency 或 missing read-model reference 仍阻断；`inactive` 表示 readiness shell 不参与当前 evidence surface；`simulation-only` 表示只能消费 deterministic local / simulated / fixture evidence。这些状态不等于 live runtime state、account connection state、broker session state、strategy scheduler state、trader process state、OMS state、order lifecycle state 或 UI command state。

`MTP-155-READ-MODEL-REFERENCE-BOUNDARY`

MTP-155 只定义 identity 与后续 account / portfolio / risk read-model input 的引用边界。Identity 可以记录 read-model reference placeholder、freshness / blocked / simulated / future-gated semantics 和 evidence trace reference，但不得读取真实 balance、position、margin、leverage、real PnL、broker position、account endpoint payload、broker state 或 adapter payload。

`MTP-155-NO-LIFECYCLE-RUNTIME-BOUNDARY`

MTP-155 不实现 lifecycle runtime、strategy scheduler、trader process manager、Strategy runtime、Trader runtime、broker connection、account session、private WebSocket runtime、private stream runtime、account snapshot runtime、OMS、Execution Client caller、broker command producer、Live PRO Console、trading button、live command 或 order form。

`MTP-155-IDENTITY-SENSITIVE-FIELD-GUARD`

Strategy / Trader identity 不得包含 credential、secret、API key、listenKey、account id、broker account id、private stream cursor、adapter request、Runtime object、broker payload、account endpoint payload、SQLite / DuckDB schema、OMS order id、order form payload、executable order command field、real account balance、real position、margin、leverage 或 real PnL。

`MTP-155-STRATEGY-TRADER-LIFECYCLE-VALIDATION`

MTP-155 required validation 是 `bash checks/run.sh`，并通过 contract、domain context、trading validation matrix、validation plan、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` 机械固定 lifecycle / identity、read-model reference boundary、no lifecycle runtime boundary 和 sensitive field guard。MTP-155 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

`MTP-156-QUOTER-HEDGER-ROLE-TAXONOMY`

MTP-156 定义 quoter / hedger role taxonomy 和 responsibility boundary。`quoter` 只表示后续 strategy / trader readiness 可能需要解释 quote intent、market reference、spread rationale、proposal candidate 和 blocked evidence 的结构性角色；不等于 market making runtime、quote engine、order generation engine、Execution Client caller、broker command producer、live quote stream 或 order form actor。`hedger` 只表示后续 readiness 可能需要解释 hedge intent、risk offset rationale、portfolio / risk read-model reference、proposal candidate 和 blocked evidence 的结构性角色；不等于 hedge runtime、position sync、broker hedge order、portfolio rebalancer、risk engine runtime、OMS actor 或 live command actor。

`MTP-156-ROLE-RESPONSIBILITY-BOUNDARY`

Role responsibility 只能记录 `roleName`、`responsibilitySummary`、`allowedReadModelReferences`、`allowedProposalReferences`、`blockedEvidenceReferences` 和 `forbiddenOutputs`。这些字段只描述 structural readiness，不表达 permission、authorization、capability flag、execution mode、broker entitlement 或 trading role assignment。

`MTP-156-ROLE-PROPOSAL-READ-MODEL-BLOCKED-EVIDENCE`

Quoter / hedger role 与 proposal、read-model input 和 blocked evidence 的关系只能是 handoff reference。Role 可以解释 `missingReadModelInput`、`proposalContractPending`、`executionForbidden`、`brokerForbidden`、`uiCommandForbidden` 等 blocked evidence，但不得提前定义 MTP-157 account / portfolio / risk input shape，不定义 MTP-158 proposal attributes，不输出 executable order command。

`MTP-156-NO-ROLE-EXECUTION-BEHAVIOR`

Role taxonomy 不实现 quoter runtime、hedger runtime、strategy marketplace、strategy manager、strategy scheduler、trader process manager、order generation engine、Execution Client direct path、broker connection、signed endpoint、account endpoint / listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、broker adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command 或 order form。

`MTP-156-FORBIDDEN-ROLE-COMMAND-SURFACE`

Quoter / hedger role 不得暴露 broker command、order-level live command、executable order command、Execution Client request、OMS order、quote order request、hedge order request、submit / cancel / replace command、trading button action、live command、order form payload、broker adapter request、account endpoint payload、signed request、listenKey create / keepalive、Runtime object、Adapter request、SQLite / DuckDB schema、credential、secret 或 API key。

`MTP-156-ROLE-TAXONOMY-VALIDATION`

MTP-156 required validation 是 `bash checks/run.sh`，并通过 contract、domain context、trading validation matrix、validation plan、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` 机械固定 quoter / hedger role taxonomy、role responsibility boundary、proposal / read-model / blocked evidence relationship、forbidden role command surface 和 no role execution behavior。MTP-156 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

`MTP-157-ACCOUNT-PORTFOLIO-RISK-READ-MODEL-INPUT`

MTP-157 定义 Strategy / Trader readiness 可以消费的 account / portfolio / risk read-model input contract。`account read-model input` 只能表示既有 Read Model / ViewModel 或 deterministic fixture evidence 中的账户证据摘要；`portfolio read-model input` 只能表示 paper / simulated / fixture portfolio evidence；`risk read-model input` 只能表示 blocked / simulated / future-gated readiness 的风险证据摘要。这些 input 不等于真实账户输入、broker state、live risk runtime input、order command precondition、account endpoint response、listenKey stream、broker statement、real margin / leverage 或 real PnL。

`MTP-157-INPUT-PROVENANCE-EVIDENCE-TRACE`

MTP-157 的每条 input 必须保留 source layer、source anchor、scenario / fixture reference、observedAt / watermark 和 evidence trace。source layer 只能指向 L3.1 account / position / balance read-model-only evidence、L3.2 private stream / account snapshot simulation gate evidence、L3.3 monitoring read-model-only evidence 或本 Project 合同锚点；source anchor 不得指向 signed endpoint route、account endpoint route、listenKey、private WebSocket cursor、adapter request、Runtime object 或 database schema；evidence trace 只服务 Report / audit / validation trace，不等于 execution id、broker fill id、reconciliation id 或 executable command id。

`MTP-157-FRESHNESS-BLOCKED-SIMULATED-FUTURE-GATED-SEMANTICS`

MTP-157 固定 `fresh`、`stale`、`missing`、`blocked`、`simulated` 和 `future-gated` input semantics。它们只解释 read-model-only evidence 的 freshness、缺失、阻断、模拟来源或 Future Gated 状态，不解释 real account health、broker position health、private stream status、live risk status、pre-trade allow / reject result、order lifecycle state 或 UI command state。

`MTP-157-READ-MODEL-VIEWMODEL-BOUNDARY`

Strategy / Trader readiness 只能通过 Read Model / ViewModel 消费 account / portfolio / risk input。允许引用既有 APB read-model-only evidence、paper portfolio projection evidence、private stream / account snapshot simulation gate evidence、Live Monitoring v2 read-model-only evidence 和 contract anchors；不允许读取 real account payload、broker state、account endpoint payload、private stream payload、Runtime object、Adapter request、SQLite / DuckDB schema、credential、secret、API key 或 listenKey；不允许绕过 Read Model / ViewModel 直接访问 Persistence schema、Runtime actor、Adapter boundary、Execution Client、broker connector、private WebSocket 或 signed endpoint。

`MTP-157-NO-REAL-ACCOUNT-RISK-RUNTIME`

MTP-157 不读取真实账户，不同步 broker position，不读取真实 balance、real position、margin、leverage、buying power 或 real PnL；不实现 live risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、stop trading command、account snapshot runtime、private stream runtime、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command 或 order form。

`MTP-157-BROKER-STATE-PAYLOAD-SCHEMA-EXPOSURE-GUARD`

MTP-157 input contract 不得暴露 real account payload、account endpoint payload、broker payload、broker state、broker position、Runtime object、Adapter request、SQLite / DuckDB schema、API key、secret、credential、listenKey、private WebSocket cursor、execution report、broker fill、reconciliation record、executable order command、broker command、OMS order 或 UI order form payload。

`MTP-157-READ-MODEL-INPUT-VALIDATION`

MTP-157 required validation 是 `bash checks/run.sh`，并通过 contract、domain context、trading validation matrix、validation plan、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` 机械固定 account / portfolio / risk read-model input contract、provenance / evidence trace、freshness / blocked / simulated / future-gated semantics、Read Model / ViewModel boundary、no real account / live risk runtime boundary 和 broker state / payload / schema exposure guard。MTP-157 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

`MTP-158-PAPER-LIVE-NEUTRAL-PROPOSAL-CONTRACT`

MTP-158 定义 Strategy / Trader readiness 中的 paper/live-neutral proposal contract。`strategy proposal`、`trader proposal` 和 `paper/live-neutral proposal` 只能作为 read-model-only / evidence-only intent evidence，解释 strategy / trader structure、role rationale、read-model input reference、blocked / simulated / future-gated decision trace 和 validation trace；不等于 executable order command、Execution Client request、broker command、OMS order、live command 或 UI order form payload。

`MTP-158-PROPOSAL-ATTRIBUTES-STATUS-SEMANTICS`

MTP-158 只允许 proposal 包含 local deterministic evidence id、proposal kind、source instance reference、role reference、read-model input reference、intent summary、proposal status、blocked reason 和 evidence trace。`proposalStatus` 只能是 `draft`、`blocked`、`simulated`、`future-gated` 或 `rejected-by-boundary`。`intentSummary` 不得包含 price、quantity、side、timeInForce、orderType、venue、account id、broker account id 或 execution destination；`blockedReason` 不等于 broker reject、risk reject、exchange reject 或 runtime failure。

`MTP-158-PROPOSAL-TO-COMMAND-ISOLATION`

Proposal 与 command 必须机械隔离。Proposal 不得包含 submit、cancel、replace、amend、route、execute、sendOrder、placeOrder、closePosition 或 rebalance 等 command verb；不得包含可直接执行订单所需的完整字段组合；不得被 Execution Client、broker adapter、OMS、Runtime actor、UI button、order form、live command handler 或 production operations command 直接消费。Proposal 只能由 MTP-160 read-model-only surface 展示，或由 MTP-159 forbidden tests 作为 non-executable evidence 检查。

`MTP-158-NO-EXECUTION-CLIENT-BROKER-OMS`

MTP-158 不实现 Execution Client、broker command、OMS、order generation engine、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation；不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`，不调用 signed endpoint、account endpoint / listenKey，不读取真实账户、broker position、margin、leverage、real PnL，不新增 Live PRO Console、trading button、live command 或 order form。

`MTP-158-PROPOSAL-FORBIDDEN-COMMAND-FIELD-GUARD`

MTP-158 proposal contract 不得暴露 executable order command、broker command、Execution Client request、OMS order、submit / cancel / replace command、order id、client order id、broker order id、account id、broker account id、account endpoint payload、signed request、listenKey、Runtime object、Adapter request、broker adapter request、SQLite / DuckDB schema、price / quantity / side / timeInForce / orderType / venue as executable order tuple、trading button action、live command、order form payload、execution report、broker fill 或 reconciliation record。

`MTP-158-PROPOSAL-CONTRACT-VALIDATION`

MTP-158 required validation 是 `bash checks/run.sh`，并通过 contract、domain context、trading validation matrix、validation plan、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` 机械固定 paper/live-neutral proposal contract、proposal attributes / status semantics、proposal-to-command isolation、no Execution Client / broker / OMS boundary 和 forbidden command field guard。MTP-158 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

`MTP-159-FORBIDDEN-STRATEGY-EXECUTION-CLIENT-TESTS`

MTP-159 定义 forbidden Strategy -> Execution Client tests 的 shared language。这里的 tests 是 deterministic / local-only / no-network 的 contract 与 automation readiness checks，只证明 Strategy Instance、Trader Instance、role、input 和 proposal 不能形成 Execution Client request、execution route、sendOrder / placeOrder / execute verb、broker command、OMS order 或 executable order command；不创建新的 runtime path、mock broker、command bus、Execution Client stub 或 Swift test target。

`MTP-159-FORBIDDEN-BROKER-COMMAND-OMS-TESTS`

MTP-159 forbidden broker command / OMS tests 必须覆盖 broker command、broker adapter request、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、broker position sync 和 real account / broker account routing。它们只能作为 forbidden evidence strings 与 blocked reason 出现，不得引入 adapter、runtime object、broker facade、OMS facade 或 hidden live fallback。

`MTP-159-FORBIDDEN-UI-COMMAND-SURFACE-TESTS`

MTP-159 forbidden UI command surface tests 必须覆盖 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 和 production operations command。MTP-159 不新增 UI surface、不新增 button、不新增 command handler、不新增 Dashboard smoke handle；Workbench / Report / Events 展示留给 MTP-160 的 read-model-only surface。

`MTP-159-PROPOSAL-TO-COMMAND-BYPASS-GUARD`

MTP-159 固定 proposal-to-command bypass guard：`proposalId` 不能被解释成 order id、client order id、broker order id 或 OMS id；`intentSummary` 不能与 price / quantity / side / timeInForce / orderType / venue 组合成 executable order tuple；`proposalStatus` 不能成为 order lifecycle state、execution state、broker acknowledgement 或 risk decision result；`blockedReason` 不能成为 broker reject、exchange reject、execution failure、incident action 或 stop command result。

`MTP-159-NO-SIGNED-ACCOUNT-ENDPOINT-LISTENKEY-GUARD`

MTP-159 forbidden tests 必须继续阻止 signed endpoint、account endpoint、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、real account payload、account endpoint payload、broker payload、broker state、Runtime object、Adapter request、SQLite / DuckDB schema、credential、secret 和 API key。验证不得读取真实网络、真实账户或真实 broker，也不得启动 private stream 或 account snapshot runtime。

`MTP-159-DETERMINISTIC-LOCAL-NO-NETWORK-TEST-BOUNDARY`

MTP-159 checks 只检查 repository text anchors、contract docs、domain context、validation matrix、validation plan、latest summary 和 automation readiness doc；不调用 external endpoint，不读取 secrets，不访问 broker / exchange adapter，不运行 Graphify，不修改 Figma，不新增 Core / App / Runtime behavior。

`MTP-159-FORBIDDEN-CAPABILITY-TESTS-VALIDATION`

MTP-159 required validation 是 `bash checks/run.sh`，并通过 contract、domain context、trading validation matrix、validation plan、latest verification summary、automation readiness doc 和 `checks/automation-readiness.sh` 机械固定 forbidden Strategy -> Execution Client tests、forbidden broker command / OMS tests、forbidden UI command surface tests、proposal-to-command bypass guard、no signed/account endpoint / listenKey guard 和 deterministic local no-network boundary。MTP-159 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 MTP-161。

## Live Execution Control Terms

`MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY`

以下术语由 MTP-75 定义为 `MTPRO Live Execution Control Contract v1` 的 Future / gated language。它们只用于 execution-control contract、real order command taxonomy、paper / real command isolation 和后续 forbidden capability tests，不授权当前 scope 实现真实订单命令或 UI 操作入口。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `execution control` | Future Live 中对真实订单 submit / cancel / replace、execution report、reconciliation 和 incident fallback 的控制边界 | 不等于当前 execution runtime、Dashboard 控制台或交易授权 |
| `real order command` | Future Live 可能需要的真实订单命令族 taxonomy | 不等于 Swift `Command`、paper command、UI button 或 broker request |
| `submit` | Future 真实订单提交 taxonomy term | 不等于当前可调用 order submit |
| `cancel` | Future 真实订单撤销 taxonomy term | 不等于当前 cancel command 或 broker cancel |
| `replace` | Future 真实订单替换 taxonomy term | 不等于当前 replace command 或 order amendment |
| `execution report` | Future broker / exchange 执行回报输入 | 不等于当前 Event Log fact、simulated fill 或 read model 授权 |
| `reconciliation` | Future 本地订单状态与 broker / exchange 状态核对 | 不等于当前 account sync、broker position sync 或 OMS |
| `incident fallback` | Future 执行异常时的受控降级 / 人工接管策略 | 不等于自动恢复、继续下单、incident command、stop control 或 live audit |
| `paper / real command isolation` | Paper order intent、paper execution decision 和 simulated fill 不能升级为 real order command 的隔离合同 | 不等于 paper evidence 可复用为真实订单输入 |

`MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES`

MTP-77 进一步固定 execution report、broker fill 和 reconciliation 的 future gate / blocked evidence 语义：execution report 不等于当前 parser 或 ingestion，broker fill 不等于 simulated fill 或 Event Log 真实成交 fact，reconciliation 不等于 account sync、broker position sync、real account balance read、OMS 修复或当前 runtime service。

`MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT`

MTP-78 进一步固定 paper order intent、paper execution decision、simulated fill 和 paper portfolio projection 与 future real order command 的隔离语义：paper evidence 可以进入 Report / Dashboard / Event Timeline 的 read model / ViewModel，但不等于 real order command、signed command request、execution report、broker fill、broker position、real account state、order form、order-level command UI 或交易按钮。

`MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`

MTP-79 进一步固定 execution-control blocked evidence 语义：`LiveExecutionControlBlockedEvidence` 只能用 read-model-only 方式说明 submit、cancel、replace、execution report、broker fill、reconciliation 和 incident fallback 为什么仍被阻断；它不等于 command model、adapter status、Runtime control、persistence schema、真实订单状态机、execution report parser、broker fill fact、reconciliation service、incident command 或交易按钮。

## Live Risk Gate Terms

`MTP-82-LIVE-RISK-TERMINOLOGY`

以下术语由 MTP-82 定义为 `MTPRO Live Risk Gate Contract v1` 的 Future / gated language。它们只用于 live risk gate contract、future risk decision taxonomy、paper / live risk isolation 和后续 forbidden capability tests，不授权当前 scope 实现真实风控引擎、账户读取、broker position sync、pre-trade allow / reject runtime、risk command surface 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `live pre-trade risk` | Future Live 中在真实订单提交前评估 exposure、order notional、frequency、loss、circuit breaker 和 no-trade state 的风险边界 | 不等于当前 risk engine、broker reject、paper blocker 或交易授权 |
| `future risk decision` | Future Live 可能输出的风险决策分类，例如 `allowed`、`blocked`、`degraded`、`no-trade` | 不等于当前 runtime decision、真实订单状态、broker response 或 Dashboard command |
| `risk gate` | Future Live 风控进入实现前必须满足的 contract / validation / operations / audit 门禁 | 不自动解锁 Linear issue，不推进 Todo |
| `risk blocked evidence` | 后续 read-model-only 方式说明 live risk gates 为什么仍被阻断的证据 | 不等于风控命令、真实拒单、熔断服务或 stop control |
| `exposure gate` | Future Live 对真实账户 / 仓位 exposure 的风险门禁 | 不读取真实账户余额、broker position、margin 或 leverage |
| `order notional gate` | Future Live 对真实订单 notional 的风险门禁 | 不实现真实订单金额 allow / reject runtime |
| `frequency gate` | Future Live 对下单频率的风险门禁 | 不实现生产限频器或 broker-side throttling |
| `loss gate` | Future Live 对亏损 / drawdown 的风险门禁 | 不读取真实 PnL、账户权益、margin 或 leverage |
| `circuit breaker` | Future Live 熔断门禁，可在后续设计中解释为什么交易必须被阻断 | 不等于当前 emergency stop、shutdown command、incident replay 或自动恢复 |
| `no-trade state` | Future Live 禁交易状态 taxonomy | 不等于当前 UI disable、真实全局交易锁或 broker session state |

`MTP-82-FUTURE-RISK-DECISION-TAXONOMY`

MTP-82 固定 `allowed`、`blocked`、`degraded` 和 `no-trade` 只是 Future risk decision taxonomy。`allowed` 不授权当前真实订单，`blocked` 不等于 broker rejection，`degraded` 不授权绕过 gate 继续交易，`no-trade` 不实现停机 / 恢复命令。

`MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`

Paper risk blocker 和 paper exposure 仍是 Current / paper-only evidence：`RiskBlockerEvidence` 不等于 future live risk decision，`PortfolioExposureSnapshot` 不等于真实账户 exposure、broker position、margin 或 leverage，paper evidence 不能升级为 real pre-trade allow / reject、circuit breaker、no-trade state 或 live risk runtime 输入。

`MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`

MTP-83 进一步固定 exposure gate 和 order notional gate 只是 Future Live Risk contract。它们可以描述后续需要的 account state source contract、broker position source contract、margin / leverage source contract、exposure limit policy、order notional limit policy 和 operations / audit handoff，但当前不得读取真实账户余额、broker position、margin 或 leverage，不得计算真实账户 exposure，不得执行真实 order notional allow / reject，不得实现 live risk engine、risk command surface、position management command、order form 或交易按钮。

`MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE`

当前 `PortfolioExposureSnapshot` 仍只能是 paper projection 派生的只读 evidence。它不能升级为 live exposure gate 输入、真实账户 exposure、broker position、margin、leverage 或 future live risk decision；`LiveExposureOrderNotionalGateBoundary` 的 account / position / margin / leverage / paper-upgrade flags 必须全部保持 `false`。

`MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES`

MTP-84 进一步固定 frequency gate、loss gate 和 drawdown gate 只是 Future Live Risk contract。它们可以描述后续需要的 frequency window policy、order event source contract、PnL / equity source contract、loss limit policy、drawdown limit policy、paper risk / exposure isolation 和 operations / audit handoff，但当前不得统计真实下单频率，不得执行生产限频或 broker-side throttling，不得读取真实 PnL、账户权益、账户余额、broker position、margin 或 leverage，不得执行真实 loss / drawdown allow / reject，不得运行 drawdown circuit breaker，不得实现 live risk engine、risk command surface、position management command、order form 或交易按钮。

`MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE`

当前 `RiskBlockerEvidence` 和 `PortfolioExposureSnapshot` 仍只能是 paper-only evidence。它们不能升级为 live frequency gate 输入、真实 loss / drawdown gate 输入、真实 PnL / equity、pre-trade risk runtime 或 future live risk decision；`LiveFrequencyLossDrawdownGateBoundary` 的 frequency runtime、loss / drawdown runtime、PnL / equity read、drawdown circuit breaker、stop / emergency command 和 paper-upgrade flags 必须全部保持 `false`。

`MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`

MTP-85 进一步固定 circuit breaker gate 和 no-trade state gate 只是 Future Live Risk contract。它们可以描述后续需要的 circuit breaker policy、trigger source contract、no-trade state policy、no-trade state transition policy 和 operations / audit handoff，但当前不得运行真实熔断服务，不得进入真实禁交易状态，不得实现全局交易锁，不得修改 broker session state，不得实现停机 / 恢复命令、production shutdown control、live risk engine、risk command surface、position management command、order form 或交易按钮。

`MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE`

当前 `RiskBlockerEvidence` 和 `PortfolioExposureSnapshot` 仍只能是 paper-only evidence。它们不能升级为 live circuit breaker trigger、no-trade state trigger、真实 PnL / equity、真实账户状态、pre-trade risk runtime 或 future live risk decision；`LiveCircuitBreakerNoTradeGateBoundary` 的 circuit breaker runtime、no-trade runtime、global trading lock、broker session mutation、stop / emergency / recovery command、production shutdown control 和 paper-upgrade flags 必须全部保持 `false`。

`MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT`

MTP-86 进一步固定 paper risk blocker、paper exposure、paper risk decision 和 read-model evidence 与 future live risk decision 的隔离合同。当前 `RiskBlockerEvidence`、`PortfolioExposureSnapshot`、paper risk decision、Report read model、Dashboard ViewModel 和 Event Timeline read model 只能作为 paper-only / read-model-only 证据，不得升级为 `allowed` / `blocked` / `degraded` / `no-trade` future live risk decision、真实账户 exposure、broker position、pre-trade allow / reject runtime、circuit breaker trigger、no-trade state trigger、risk command surface、position management command、order form 或交易按钮。

`MTP-86-PAPER-RISK-EVIDENCE-NO-FUTURE-LIVE-RISK-DECISION`

当前 paper risk evidence 不能升级为 future live risk decision；`LivePaperRiskLiveDecisionIsolationBoundary` 的 paper risk blocker / exposure / risk decision upgrade flags、live risk engine flags、pre-trade allow / reject flags、live trading authorization flags 和 required network validation flag 必须全部保持 `false`。

`MTP-86-PAPER-EXPOSURE-NO-REAL-ACCOUNT-RISK-INPUT`

当前 paper exposure 不能升级为真实账户风险输入；`LivePaperRiskLiveDecisionIsolationBoundary` 的 real account balance、broker position sync、margin、leverage、real PnL、real account equity 和 paper exposure to account / broker position mapping flags 必须全部保持 `false`。

`MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY`

MTP-86 只允许 Report / Dashboard / Event Timeline 展示既有 read model / ViewModel evidence，不新增 live risk command surface、position management command、order form、交易按钮或 `LiveRiskGateBlockedEvidence` 展示面；后者保留给 MTP-87。

`MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE`

MTP-87 进一步固定 `LiveRiskGateBlockedEvidence` 的 read-model-only 语义：exposure、order notional、frequency、loss / drawdown、circuit breaker 和 no-trade state 只能以 blocked gate、blocked reason、source anchor 和 deterministic snapshot 进入 Report / Dashboard / Event Timeline；它不等于 live risk engine、real pre-trade allow / reject runtime、真实账户 / broker state reader、circuit breaker / no-trade runtime、risk command、position command、order form 或交易按钮。

## Live Audit Incident Stop Terms

`MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`

以下术语由 MTP-89 定义为 `MTPRO Live Audit Incident Stop Boundary v1` 的 Future / gated language。它们只用于 live audit / incident / stop contract、future taxonomy、blocked evidence source anchors 和后续 forbidden capability tests，不授权当前 scope 实现 incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、live command、broker action 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `live audit` | Future Live 中对实盘边界、事件、命令、风险和恢复过程的审计概念 | 不等于当前 audit storage、production audit service 或 broker-side audit |
| `audit trail` | Future Live 可能串联 signal、order、risk decision 和 fill 证据的审计轨迹 | 不等于当前 append-only production audit log、OMS log 或 broker ledger |
| `incident` | Future Live 可能需要调查、回放或人工处理的事故语义 | 不等于当前 alerting / paging、production incident runtime 或自动恢复 |
| `incident replay` | Future Live 可能用于事故分析的回放能力名称 | 不等于当前 incident replay runtime、broker event replay 或生产回放服务 |
| `stop control` | Future Live 可能阻断交易或运维动作的控制类别 | 不等于当前 stop control runtime、risk command 或 live command |
| `emergency stop` | Future Live 可能存在的紧急停止语义 | 不等于当前 emergency stop command、交易按钮或 broker action |
| `shutdown` | Future Live 可能存在的生产停机语义 | 不等于当前 shutdown command、production operation 或 broker session mutation |
| `restore` | Future Live 可能存在的恢复语义 | 不等于当前 restore command、auto recovery 或 live runtime resume |

`MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`

MTP-89 固定 `signal audit trail`、`order audit trail`、`risk decision audit trail`、`fill audit trail`、`incident replay`、`stop control`、`emergency stop`、`shutdown`、`restore` 和 `production operations` 只是 Future audit / incident / stop taxonomy。它们不授权当前 audit runtime、incident replay runtime、emergency stop command、shutdown / restore command、production operations、Live PRO Console、live command、broker action 或交易按钮。

`MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES`

MTP-89 只能引用 `TVM-LIVE-TRADING-FOUNDATION`、`TVM-LIVE-EXECUTION-CONTROL`、`TVM-LIVE-RISK-GATE`、`MTP-65-LIVE-BLOCKED-EVIDENCE`、`MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE` 和 `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE` 作为 blocked evidence source anchors。引用这些 anchors 不会把 Workbench、Dashboard、Report 或 Event Timeline 升级为 Live PRO Console。

`MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND`

MTP-89 不实现 incident replay runtime、stop control runtime、emergency stop、shutdown、restore、production operations、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、live command、order-level command UI 或交易按钮；`LiveAuditIncidentStopTerminologyBoundary` 中对应 forbidden flags 必须全部保持 `false`。

`MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE`

Workbench 和 Dashboard 仍是当前 paper / research / validation / read-model-only evidence surface，不得被描述成当前 Live PRO Console。Live PRO Console 仍是 Future product surface，必须经过独立 Human decision、独立 Project Definition 和后续 signed / account / broker / risk / ops gates。

`MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`

MTP-90 固定 signal audit trail、order audit trail、risk decision audit trail 和 fill audit trail 只是 Future audit trail gates。signal gate 只要求未来 signal source / decision path / replay correlation contract；order gate 只要求未来 order intent source / state transition / command authorization contract；risk decision gate 只要求未来 risk decision source / gate outcome / blocked reason contract；fill gate 只要求未来 fill source / execution report source / broker fill source gate。它们不授权当前 audit trail runtime、production audit log、execution report ingestion、broker fill fact、real order state machine、OMS、broker action、live command 或交易按钮。

`MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS`

MTP-90 的 forbidden capability tests 必须继续阻断 execution report ingestion、broker fill fact / recorder、real order state machine、OMS、broker reconciliation、broker action、signed endpoint、account endpoint、listenKey 和 `LiveExecutionAdapter`。这些 forbidden capability 可以进入 Core deterministic fixture 和 PR evidence，但不能被实现为当前 parser、adapter、runtime、broker ledger、OMS log 或 UI command。

`MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION`

MTP-90 不实现 real order state machine、real order submit / cancel / replace、broker session mutation、broker reconciliation、broker action、execution report runtime 或 broker fill runtime。order audit trail 仍是 Future contract，不等于当前 real order lifecycle。

`MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE`

MTP-90 可以引用 paper-only / read-model-only source anchors，例如 `PaperOrderIntent`、`PaperExecutionDecision`、`RiskBlockerEvidence` 和 `PaperSimulatedFillEvidence`，但这些 evidence 不能升级为真实 audit fact、real order command、future live risk decision、execution report、broker fill、real account state 或 reconciliation input。

`MTP-90-LIVE-AUDIT-TRAIL-VALIDATION`

MTP-90 的 validation anchor 由 `LiveAuditTrailFutureGateBoundary` 和 focused Core tests 固定；required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户或人工验收。

`MTP-91-INCIDENT-REPLAY-FUTURE-GATES`

MTP-91 固定 incident replay 只是 Future / gated incident analysis contract。它只定义 input source、replay scope、replay evidence 和 replay output gates，不授权当前 incident replay runtime、production recovery、broker replay、account replay、auto restore、auto rollback、production operations、Live PRO Console、live command 或交易按钮。

`MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES`

MTP-91 的 input source gates 只能引用 `MTP-89` terminology、`MTP-90` audit trail gates、`Event Log` 和 `Replay` 作为 deterministic evidence path。当前 `Event Log` 不等于 production incident log、broker ledger、OMS log 或 real account replay source；当前 `Replay` 不等于 production recovery、auto restore、broker replay、account replay 或 live runtime resume。

`MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES`

MTP-91 的 replay scope / evidence / output gates 只说明后续 incident replay 进入实现前必须补齐范围合同、时间窗口、证据来源和 read-model-only output gate。它们不输出 production recovery、restore decision、broker replay、account replay、live command 或生产运维动作。

`MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS`

MTP-91 的 forbidden capability tests 必须继续阻断 incident replay runtime、production recovery runtime、auto restore / auto rollback runtime、broker replay runtime、account replay runtime、broker state reader、real account state reader、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、execution report ingestion、broker fill fact、audit trail runtime、production operations runtime、Live PRO Console、live command 和 trading button。

`MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY`

当前 replay 仍是 Research / Backtest / Paper / validation 的 deterministic evidence path，不得被写成生产事故回放系统、恢复系统、自动恢复、自动回滚、broker replay、account replay 或 live runtime resume。

`MTP-91-INCIDENT-REPLAY-VALIDATION`

MTP-91 的 validation anchor 由 `LiveIncidentReplayFutureGateBoundary` 和 focused Core tests 固定；required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、production operations 或人工验收。

`MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES`

MTP-92 固定 emergency stop、shutdown 和 restore 只是 Future / gated stop control contract。emergency stop gate 只要求未来 policy / trigger / authorization / read-model-only blocked evidence；shutdown gate 只要求未来 policy / scope / operations handoff；restore gate 只要求未来 policy / readiness evidence / authorization。它们不授权当前 emergency stop command、shutdown command、restore command、production shutdown control、broker session mutation、global trading lock、Live PRO Console、live command、stop button 或交易按钮。

`MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS`

MTP-92 的 forbidden capability tests 必须继续阻断 emergency stop command、shutdown command、restore command、stop control runtime、production shutdown control、production operations runtime、global trading lock、broker session mutation、broker action、signed endpoint、account endpoint、listenKey、`LiveExecutionAdapter`、OMS、real order state machine、live risk engine、restore decision runtime、live runtime resume、Live PRO Console、live command、stop button 和 trading button。

`MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE`

MTP-92 可以引用 `MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`、`LiveCircuitBreakerNoTradeGateBoundary` 和 `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE`，但这些 risk gate anchors 不能升级为当前 emergency stop、shutdown、restore、circuit breaker runtime、no-trade state runtime、risk command surface、global trading lock 或 broker session mutation。

`MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN`

MTP-92 不实现 broker session mutation、production shutdown control、production operations runtime、restore decision runtime 或 live runtime resume。shutdown / restore 仍是 Future contract，不等于当前生产停机、自动恢复或实盘运行时恢复。

`MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION`

MTP-92 的 validation anchor 由 `LiveStopShutdownRestoreFutureGateBoundary` 和 focused Core tests 固定；required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、production operations 或人工验收。

`MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION`

MTP-93 固定 `LiveExecutionControlBlockedEvidence`、`LiveRiskGateBlockedEvidence`、`RiskBlockerEvidence`、`PaperOrderIntent`、`PaperSimulatedFillEvidence` 和 `PortfolioExposureSnapshot` 只能作为 read-model-only / paper-only source anchors。它们可以解释 future audit / incident / stop boundary 为什么仍被阻断，但不能升级为 incident command、stop command、restore decision、execution runtime、live risk engine、production operations、Live PRO Console、live command 或交易按钮。

`MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE`

MTP-93 的 forbidden capability tests 必须继续阻断 execution-control blocked evidence -> incident command / stop command / restore decision、risk gate blocked evidence -> incident replay runtime / emergency stop / shutdown command，以及 incident replay runtime、stop command、shutdown command、restore command、execution runtime、live risk engine、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order state machine、Live PRO Console、live command 和 trading button。

`MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE`

MTP-93 可以引用 paper order、simulated fill、risk blocker 和 paper exposure 作为隔离证据，但这些 evidence 不能成为 production incident fact、stop decision、restore readiness、broker fill fact、real account state、future live risk decision、incident replay runtime 或 production operations handoff。

`MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS`

MTP-93 的 validation anchor 由 `LiveBlockedEvidenceIncidentStopIsolationBoundary` 和 focused Core tests 固定；Core tests 必须覆盖 deterministic fixture、forbidden command / runtime flags、Codable 解码拒绝绕过，以及 read-model-only / paper-only source anchors 的隔离。

`MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION`

MTP-93 的 required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、production operations 或人工验收。

`MTP-94-LIVE-INCIDENT-STOP-BLOCKED-EVIDENCE`

MTP-94 固定 `LiveIncidentStopBlockedEvidence` 的 read-model-only 语义：audit trail、incident replay、emergency stop、shutdown 和 restore 只能以 blocked gate、blocked reason、source anchor、validation anchor 和 deterministic snapshot 进入 Report / Dashboard / Event Timeline。它不等于 audit trail runtime、incident replay runtime、emergency stop command、shutdown command、restore command、production operations、Live PRO Console、stop button、trading button、live command、adapter / runtime / database schema exposure 或 broker action。

`MTP-94-AUDIT-INCIDENT-STOP-BLOCKED-REASONS`

MTP-94 的 blocked reasons 必须明确说明 Human live audit / incident / stop decision 尚未形成，audit trail runtime、incident replay runtime、emergency stop command、shutdown command、restore command、production operations runtime、broker session mutation、live runtime resume、Live PRO Console、live command surface、stop button、trading button 和 command surface 仍被阻断。

`MTP-94-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`

MTP-94 deterministic snapshot 是本地 fixture / read model evidence，不读取 secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、adapter object、runtime object 或 persistence schema。它只保留 source anchors、blocked gates、blocked reasons、validation anchors 和 forbidden flags。

`MTP-94-READ-MODEL-ONLY-NO-COMMAND-SURFACE`

MTP-94 允许 Dashboard / Report / Event Timeline 展示 live incident / stop blocked evidence，但所有展示面必须保持只读：Dashboard metrics、Report details、Workbench detail 和 Event Timeline item 都不能带 stop action、restore action、operator workflow、order form、trading button、Live PRO Console 或 broker action。

`MTP-94-LIVE-INCIDENT-STOP-VALIDATION`

MTP-94 的 validation anchor 由 `LiveIncidentStopBlockedEvidence`、`LiveIncidentStopBlockedEvidenceReadModel`、`LiveIncidentStopBlockedEvidenceViewModel`、Dashboard / Report / Event Timeline integration 和 focused Core / App tests 固定；required validation 仍是本地 `bash checks/run.sh`，不依赖真实 Binance 网络、secret、signed endpoint、account endpoint、listenKey、broker state、真实账户、production operations 或人工验收。

## Paper-only Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Paper Session` | 本地 paper-only session lifecycle | 不等于真实账户 session |
| `Paper Action Proposal` | 策略信号转出的本地 paper-only action intent | 不等于 order |
| `Risk Blocker` | 本地 paper readiness 的 blocker / evidence | 不等于完整实盘风控引擎 |
| `Paper Order Intent` | 本地 paper-only order intent value model | 不等于真实订单请求 |
| `Paper Order Lifecycle` | 本地 paper order 状态证据 | 不等于交易所订单生命周期 |
| `Simulated Fill Evidence` | deterministic simulated fill 研究证据 | 不等于 broker fill 或 execution report |
| `Portfolio Projection` | 从 paper-only evidence 派生的组合观察面 | 不等于真实账户余额或 broker position |
| `Paper Workflow Control Shell` | session-level `start` / `pause` / `close` / `reset` 本地控制壳 | 不允许 submit / cancel / replace |

## Market Replay Terms

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Market Data Batch` | 本地 public read-only fixture / batch replay 输入集合 | 不绑定真实历史下载规模 |
| `Replay Run` | 一次本地 deterministic replay 的 metadata 和 evidence | 不等于生产调度任务 |
| `Retention Policy` | 本地 batch 是否保留 / 过期 / stale 的最小证据规则 | 不等于云端 archive 或 storage tiering |
| `Freshness Evidence` | Report / Dashboard / Event Timeline 可消费的 freshness read model | 不暴露 adapter 或 schema |
| `Fixture Parity` | mock transport / fixture 与 decoder / replay contract 的一致性验证 | 不依赖真实 Binance 网络 |

## Data Catalog / Scenario Replay Terms

`MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY`

以下术语由 MTP-103 定义为 `MTPRO Data Catalog / Scenario Replay v1` 的 local-first、deterministic、versioned scenario replay 语言。它们只用于 Data Engine、State & Persistence Engine 和 Workbench Interface 的边界合同、source docs anchors、validation anchors 和后续 issue 的共同语言，不授权当前 scope 实现 manifest parser、fixture 数据、replay cursor、report input versioning、production data platform、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live command 或交易按钮。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `local data catalog` | 本地 scenario replay 输入身份、版本和证据锚点目录语言 | 不等于 production data platform、cloud data lake 或大型 ingestion pipeline |
| `scenario replay` | 从本地 versioned input 重建 deterministic evidence 的后续路径 | 不等于 production recovery、broker replay、account replay 或 live runtime resume |
| `scenario manifest` | 后续 issue 的输入身份合同名称 | 当前不解析 manifest，不定义最终字段 parser |
| `scenario id` | 后续 scenario replay 的稳定场景标识 | 不等于 database primary key、runtime job id、broker order id 或真实订单 id |
| `dataset version` | 后续 replay 输入数据版本 | 不等于 production dataset registry 或云端数据湖版本 |
| `fixture version` | 后续 deterministic fixture 的本地版本 | 当前不新增 fixture 数据 |
| `replay window` | 后续 replay 的本地时间 / 序列窗口 | 当前不实现 cursor 或 historical downloader |
| `replay cursor` | 后续回放位置证据 | 当前不实现 cursor runtime |
| `checksum evidence` | 后续完整性 / parity 证据 | 当前不计算新 checksum |
| `data quality gate` | 后续 scenario replay 数据质量判定分类 | 不等于 production data observability 或自动修复平台 |
| `report input versioning` | 后续 Report / Backtest / future Simulated Exchange 输入追溯合同 | 当前不实现 report input versioning runtime |
| `Workbench scenario replay evidence` | 后续 Workbench / Report / Events 只读展示面输入 | 不做 UI command、query language、schema exposure、adapter request 或 Runtime object exposure |

`MTP-103-FORBIDDEN-CAPABILITY-BASELINE`

MTP-103 的 forbidden baseline 必须覆盖 signed endpoint、account endpoint、listenKey、secret read、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、trading button、production data platform、large-scale ingestion pipeline、real network download、Graphify update 和 Figma change。

`MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS`

MTP-104 把 `scenario manifest` 从术语推进为 Core value contract，但仍只表达本地输入身份，不解析 manifest 文件，不新增 fixture data，也不实现 replay cursor。最小字段为 `scenario id`、`dataset version`、`symbol`、`timeframe`、`source anchor` 和 `single-symbol / single-timeframe` scope。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `ScenarioID` | 本地 scenario replay 的稳定场景标识 | 不等于 database primary key、runtime job id、broker order id 或真实订单 id |
| `DatasetVersion` | 本地 replay 输入数据版本 | 不等于 production dataset registry、cloud data lake version 或外部 catalog service version |
| `ScenarioManifest` | 绑定 scenario id、dataset version、symbol、timeframe、source anchor 和 scope 的 Core 输入身份合同 | 不等于 manifest parser、fixture data、production catalog service 或 report UI |
| `ScenarioManifestDeterministicSerialization` | 固定字段顺序的 deterministic serialization evidence | 不计算 checksum，不暴露 SQLite / DuckDB schema、adapter payload 或 Runtime object |
| `single-symbol / single-timeframe` | MTP-104 first scenario 的唯一允许 scope | 不授权 multi-symbol / multi-timeframe catalog |

`MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY`

MTP-104 manifest 必须保持 database schema exposure、adapter request exposure、secret read、signed endpoint、account endpoint、listenKey、broker integration、order command、live runtime、production dataset registry、real network download、multi-symbol catalog 和 multi-timeframe catalog flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

`MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE`

MTP-105 把 MTP-104 manifest 绑定到第一个本地 deterministic scenario fixture。该 fixture 只包含 BTCUSDT / 1m 的本地 public-read-only `MarketBar` records、`fixture-v1`、fixed window、fixed record order 和 deterministic summary pre-structure；不代表真实历史下载规模、production ingestion、data lake、adapter request、replay cursor、final checksum evidence、freshness evidence、data quality gate 或 report input versioning runtime。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `FixtureVersion` | 本地 fixture record set 的稳定版本身份 | 不等于 dataset version、production dataset registry 或 cloud data lake version |
| `DeterministicScenarioFixture` | first scenario 的 Core fixture，绑定 manifest、fixture version、source anchors、records 和 validation anchors | 不等于 manifest parser、historical downloader、production data platform 或 Runtime job |
| `ScenarioFixtureRecord` | fixture 内固定 sequence 的 public market data record | 不等于 exchange sequence、broker sequence、event log sequence 或 replay cursor |
| `ScenarioFixtureDeterministicSummary` | record count、fixed window、ordered starts、record order identity、canonical summary 和 checksum preimage 的前置结构 | 不等于 MTP-106 final checksum、freshness verdict、data quality gate 或 report input versioning |
| `Binance public read-only local fixture` | first scenario 与既有 public read-only / local replay evidence 的关系锚点 | 不等于真实 Binance 网络下载、signed endpoint、account endpoint / listenKey 或 broker feed |

`MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE`

MTP-105 fixture 必须保持 required validation 不依赖网络，且 real network download、production ingestion pipeline、cloud data lake、adapter request exposure、secret read、signed endpoint、account endpoint、listenKey、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、live command、trading button、multi-symbol catalog 和 multi-timeframe catalog flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

`MTP-106-DETERMINISTIC-REPLAY-WINDOW`

MTP-106 把 MTP-105 fixture 推进为本地 scenario replay evidence。`ScenarioReplayWindow` 继承 MTP-105 fixed window `1704067200...1704067380`、record sequence `1,2,3`、record order identity 和 MTP-104 source identity；它只表达 historical replay window，不等于 historical downloader、production retention window、Runtime job 或 broker/account replay window。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `ScenarioReplayWindow` | 本地 deterministic scenario replay 的时间窗口和 record order identity | 不等于 downloader policy、production scheduler window 或 broker/account replay |
| `ScenarioReplayCursor` | 本地 fixture record progress，默认 next sequence 为 `1`，completed 为 `4` | 不等于 event log sequence、exchange sequence、broker sequence、job offset 或 live resume token |
| `ScenarioReplayCursorSummary` | cursor identity、window identity、next sequence、consumed count、total count 和 state 的稳定摘要 | 不暴露 Runtime object、adapter request、SQLite / DuckDB schema 或 UI command |
| `ScenarioReplayChecksumEvidence` | MTP-105 checksum preimage 的 final FNV-1a checksum evidence | 不等于 production data quality platform、真实下载校验或 reconciliation |
| `ScenarioReplayFreshnessEvidence` | 固定 evaluatedAt、age 和 freshness status 的本地 fixture freshness evidence | 不执行 retention cleanup、cloud archive、storage tiering 或 downloader |
| `ScenarioReplayEvidence` | replay window、cursor、checksum、freshness 和 forbidden capability flags 的聚合证据 | 只供后续 quality gate / read model 消费，不实现 MTP-107 或 MTP-108 |

`MTP-106-CHECKSUM-PARITY-EVIDENCE`

MTP-106 final checksum 固定为 `fnv1a64:3c6cd4ff13cd4062`，算法为 `fnv1a64`，输入为 MTP-105 canonical checksum preimage。checksum evidence 必须保持 source identity、record order identity、canonical preimage 和 checksum 一致；初始化和 Codable 解码不能恢复 checksum drift、record order drift 或 parity flag drift。

`MTP-106-FIXTURE-FRESHNESS-EVIDENCE`

MTP-106 fixture freshness policy 只定义本地 freshness 阈值：stale after `300` seconds、expires after `900` seconds。默认 evaluatedAt 为 `1704067500`，相对 replay window end `1704067380` 的 age 为 `120` seconds，status 为 `fresh`。该 evidence 不执行 production retention engine，不授权 cloud archive，不暴露 storage tiering，不依赖真实网络。

`MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE`

MTP-106 replay evidence 必须保持 required validation network dependency、real network download、production retention engine、large-scale ingestion pipeline、production data platform、database schema exposure、adapter request exposure、secret read、signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、real order lifecycle、report input versioning runtime、data quality gate runtime、live runtime、live command 和 trading button flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

`MTP-107-DATA-QUALITY-GATE-TAXONOMY`

MTP-107 把 MTP-106 replay evidence 推进为本地 data quality gate 和 report input versioning contract。Data quality gates 只服务 local scenario replay 与 report reproducibility，不等于 production data observability、automatic download / repair、broker/account reconciliation 或 Simulated Exchange / Backtest Parity runtime。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `ScenarioDataQualityGateKind` | record order、window coverage、checksum match、freshness status、missing data、duplicate data 六个最小 gate | 不等于生产监控规则、自动修复规则或外部数据平台策略 |
| `ScenarioDataQualityGateEvaluation` | 基于 MTP-106 replay evidence 生成 deterministic quality verdict 的 Core 值对象 | 不启动 Runtime，不读取 schema，不自动下载 / 修复数据 |
| `ScenarioDataQualityVerdict` | `accepted`、`marked`、`rejected` 三类 report input 质量结论 | 不等于 production SLA、broker reject 或 live risk decision |
| `ScenarioReportInputVersion` | 把 scenario id、dataset version、fixture version、replay window、checksum、freshness 和 quality verdict 固定成 report input identity | 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、broker payload 或真实账户资料 |
| `ScenarioDataQualityReportInputEvidence` | 绑定 replay evidence、quality gates 和 report input version 的 MTP-107 聚合证据 | 只供后续 read-model evidence 消费，不实现 Workbench UI、不输出 stage audit input |

`MTP-107-REPORT-INPUT-VERSIONING`

MTP-107 report input versioning 必须可从 `ScenarioReplayEvidence` 追溯到同一 scenario id、dataset version、fixture version、replay window、checksum 和 freshness status；`versionIdentity` 必须包含 quality verdict。该 contract 是 stable Core value contract，不是 report runtime、database schema、adapter request 或 Runtime object。

`MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM`

MTP-107 quality / report input evidence 必须保持 required validation network dependency、production data platform、production data observability、automatic download、automatic repair、broker / account reconciliation、Simulated Exchange / Backtest Parity implementation、database schema exposure、adapter request exposure、Runtime object read、secret read、signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、real order lifecycle、live runtime、live command 和 trading button flags 全部为 false；初始化和 Codable 解码都不能恢复这些能力。

`MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE`

MTP-108 scenario replay read-model evidence 指 App 层只读聚合：它把 MTP-106 replay window / cursor / checksum / freshness 与 MTP-107 quality verdict / report input version identity 复制到 `ScenarioReplayEvidenceReadModel` 和 `ScenarioReplayEvidenceViewModel`。该术语只表示展示面 evidence，不表示 Runtime replay job、Adapter request、Persistence schema、database console、query language 或 command model。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Workbench scenario replay summary` | Workbench 中的 scenarios、quality gates、report inputs 和 quality verdict 只读指标 | 不等于 replay control、download console、query editor 或交易入口 |
| `Scenario replay drill-down entry` | 展示 scenario id、dataset version、fixture version、replay window、checksum、freshness、quality verdict 和 report input version identity 的只读 detail | 不等于 schema inspector、Runtime object inspector、Adapter request log 或 broker payload |
| `Quality gate timeline` | Events / Evidence Explorer 中的 record order、window coverage、checksum match、freshness status、missing data、duplicate data verdict rows | 不等于 production data observability、automatic repair、broker/account reconciliation 或 Simulated Exchange runtime |
| `Report input version surface` | Report / Dashboard ViewModel 中可编码展示的 report input version identity | 不等于 report runtime、database migration、SQL query 或 production data platform |

`MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE`

MTP-108 App surface 必须保持 read-model-only：Dashboard、Workbench、Report 和 Events 只能消费 `ScenarioReplayEvidenceReadModel` / `ScenarioReplayEvidenceViewModel`，不能提供 command surface、order-level command、query language、live command、trading button、broker action、live trading authorization 或 trading execution authorization。

## Simulated Exchange / Backtest Parity Terms

`MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY`

以下术语由 MTP-110 定义为 `MTPRO Simulated Exchange / Backtest Parity v1` 的 L2 deterministic simulation 语言。它们只用于 Simulation / Backtest Engine、paper-only / simulated Execution Engine、Portfolio Engine、Data Engine、State & Persistence Engine 和 Workbench Interface 的边界合同、source docs anchors、validation anchors 和后续 issue 的共同语言，不授权当前 scope 实现 matching runtime、order execution runtime、portfolio projection runtime、UI、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、Live PRO Console、live command、trading button、emergency stop、shutdown 或 restore。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `simulated exchange` | 本地 deterministic simulation 的术语入口，用于后续模拟撮合和回测 / Paper 共享语义 | 不等于真实交易所、broker、execution venue 或 live readiness |
| `backtest parity` | backtest 与 paper runtime 共享同一模拟交易语义和证据口径 | 不等于 live parity、broker reconciliation 或生产一致性声明 |
| `matching model` | 后续 deterministic matching contract 的名称 | 当前不实现撮合 runtime、不读取真实 order book 或 broker feed |
| `fill model` | 后续 simulated fill / full fill / partial fill 语义入口 | 不等于 broker fill、execution report 或真实成交质量 |
| `latency model` | 后续 deterministic latency assumption 语义入口 | 不等于 production telemetry、exchange latency 或 broker SLA |
| `fee / slippage parity` | backtest 与 paper runtime 共享交易摩擦假设 | 不等于真实费率表、broker fee statement 或 live execution cost optimization |
| `portfolio projection parity` | 后续 simulated exchange event 到 paper / backtest portfolio projection 的一致语义 | 不等于真实账户、broker position、margin、leverage 或 reconciliation |
| `scenario replay integration` | L1.5 scenario replay 作为 L2 deterministic input 的 handoff 语言 | 不等于 production data platform、network downloader 或 Runtime replay job |
| `deterministic simulation` | 所有 L2 parity evidence 必须可由本地 fixture / scenario replay 重放 | 不等于真实交易所模拟环境或 live runtime |
| `shared backtest-paper order semantics` | 后续 MTP-111 定义的 backtest / paper 共享订单语义入口 | 当前不实现 order semantics runtime、order form 或 command model |

`MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`

MTP-110 固定六类目标引擎职责：`Simulation / Backtest Engine`、`Execution Engine (paper-only / simulated)`、`Portfolio Engine`、`Data Engine`、`State & Persistence Engine` 和 `Workbench Interface`。这些职责只表达 L2 parity 共同语言，不实现 matching runtime、order execution runtime、portfolio projection runtime 或 UI。

`MTP-110-L1-L15-L2-HANDOFF-BOUNDARY`

MTP-110 handoff boundary 只把 L1 Paper Runtime 的 paper-only execution evidence 和 L1.5 Data Catalog / Scenario Replay 的 deterministic scenario input identity 连接到 L2 terminology。它不表示真实交易所、live readiness、production trading engine、broker / OMS、signed endpoint、account endpoint / listenKey 或 Live PRO Console 已进入当前 scope。

`MTP-110-FORBIDDEN-CAPABILITY-BASELINE`

MTP-110 的 forbidden baseline 必须覆盖 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、secret read、signed endpoint、account endpoint、listenKey、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、trading button、emergency stop / shutdown / restore、Graphify update 和 Figma change。

`MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`

MTP-111 把 `shared backtest-paper order semantics` 从 MTP-110 的术语入口推进为 Core value contract。它只定义 paper order intent 与 backtest replay order input 的共享字段：input id、order id、source paper order intent id、proposal id、session id、scenario id、dataset version、fixture version、symbol、timeframe、side、quantity、reference price、notional amount、source risk decision sequence、source replay sequence 和 recorded at。这些字段只服务 deterministic simulation / backtest replay，不等于 broker order id、exchange order id、real order command、order form、OMS state 或真实订单生命周期。

`MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`

MTP-111 固定 shared simulated order state taxonomy：`intent recorded`、`submitted simulated`、`accepted simulated`、`rejected simulated`、`expired simulated`、`cancelled local only`、`failed local only`、`filled simulated` 和 `partially filled simulated`。这些状态只能表达 paper-only / simulated evidence；`accepted simulated` 不等于 exchange accepted，`rejected simulated` 不等于 broker rejection，`filled simulated` / `partially filled simulated` 不等于 broker fill、execution report 或真实成交质量，`cancelled local only` 不等于 real cancel command。

`MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT`

MTP-111 固定 paper lifecycle 与 backtest replay 的对齐：`PaperOrderLifecycleState.intentCreated` 映射为 `intent recorded`，`PaperOrderLifecycleState.rejectedByRisk` 映射为 `rejected simulated`，`PaperOrderLocalLifecycleState.submittedLocal` / `acceptedLocal` / `rejectedByPaperRisk` / `expiredLocal` / `cancelledLocal` / `failedLocal` 分别映射为 submitted / accepted / rejected / expired / local-cancelled / local-failed simulated evidence，`PaperSimulatedFillCompletion.full` 映射为 `filled simulated`，`partial` 映射为 `partially filled simulated`。scenario id、dataset version、fixture version、symbol 和 timeframe 必须与 L1.5 scenario replay input identity 对齐。

`MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE`

MTP-111 shared order semantics 不得升级为 matching runtime、order execution runtime、portfolio projection runtime、real order command、real order lifecycle、real submit / cancel / replace、signed endpoint、account endpoint、listenKey、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI、trading button 或 emergency stop / shutdown / restore。

`MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`

MTP-112 把 scenario replay window / cursor、dataset version、fixture version、local market state、checksum / freshness evidence 和 MTP-111 shared order input 串成 deterministic matching input。默认 fixture 固定 scenario id `mtp-104-btcusdt-1m-first-scenario`、dataset version `dataset-v1`、fixture version `fixture-v1`、window `1704067200...1704067380`、cursor / record sequence `2`、freshness `fresh` 和 checksum `fnv1a64:3c6cd4ff13cd4062`。这些输入只来自本地 deterministic fixture / scenario replay，不等于真实 order book、broker feed、live stream 或 production replay job。

`MTP-112-DETERMINISTIC-MATCHING-ORDERING`

MTP-112 matching ordering 只使用 scenario identity、dataset / fixture version、replay window、cursor sequence、fixture record order、shared order input tie-break 和 append-only simulated event output；不得使用 wall clock、randomness、真实网络、exchange priority、broker routing 或 production scheduler。

`MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`

MTP-112 输出 `simulated exchange order matched` event，默认 matched record sequence 为 `2`、matched price 为 `42120.70`、matched quantity 为 `0.5`，shared order state 为 `filled simulated`，shared event kind 为 `simulated order filled`。该 event 只表达 simulated exchange matching output，不等于 broker fill、execution report、真实成交、account update、portfolio projection 或 reconciliation 输入。

`MTP-112-REPEATABLE-MATCHING-OUTPUT`

MTP-112 必须保证相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input 可重复输出同一个 deterministic result identity：`mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|price=42120700000|quantity=500000`。

`MTP-112-NO-NETWORK-BROKER-LIVE`

MTP-112 deterministic matching model 不得升级为真实 matching runtime、market / limit execution runtime、partial fill / latency / fee / slippage runtime、portfolio projection runtime、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、live command、order-level command UI 或交易按钮。

`MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`

MTP-113 market order simulated execution 只表示 accepted simulated shared order input 使用 MTP-112 deterministic matching output 的 matched price 立即 full fill。默认 fixture 使用 matched price `42120.70`、quantity `0.5`、shared state `filled simulated` 和 event kind `simulated order filled`。它不等于真实 market order、exchange order book execution、broker route、execution report、broker fill、account update 或 live order。

`MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`

MTP-113 limit order simulated execution 只定义当前 shared order side 中 buy-side 的最小 limit rule：explicit limit price 大于等于 deterministic matched price 时 full fill，低于 matched price 时输出 `expired simulated` evidence。默认 fill fixture 的 limit price 为 `42150.00`；expire fixture 的 limit price 为 `42100.00`。它不实现 sell / short、stop、OCO、post-only、maker/taker routing、price-time priority 或真实交易所订单过期。

`MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`

MTP-113 固定三种最小 simulated execution outcome：`full fill simulated` 映射到 `filled simulated` / `simulated order filled`；`rejected simulated` 映射到 `rejected simulated` / `simulated order rejected`，用于 rejected initial state 或 non-executable hold side 在 fill 前停止；`expired simulated` 映射到 `expired simulated` / `simulated order expired`，用于 buy limit 未穿越 deterministic matched price。MTP-113 不输出 partial fill，partial fill、latency、fee / slippage parity 仍归属 MTP-114。

`MTP-113-DETERMINISTIC-EXECUTION-REPLAY`

MTP-113 必须保证相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input / order type / limit price / initial state 输出同一个 deterministic execution result identity。limit expire fixture 的 identity 固定为 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|orderType=limit order simulated execution|limit=42100000000|initialState=accepted simulated|outcome=expired simulated|matchedPrice=42120700000|filled=0|remaining=500000`。

`MTP-113-NO-REAL-ORDER-LIVE-COMMAND`

MTP-113 market / limit simulated execution semantics 不得升级为真实 order execution runtime、matching runtime、portfolio projection runtime、advanced order types、真实 submit / cancel / replace、OMS、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。

`MTP-114-PARTIAL-FULL-FILL-PARITY`

MTP-114 partial / full fill parity 只表示 deterministic simulated exchange evidence：当 `availableSimulatedLiquidity` 小于 order quantity 时输出 `partial` / `partially filled simulated` / `simulated order partially filled`，并显式保留 remaining quantity；当 available liquidity 等于 order quantity 时输出 `full` / `filled simulated` / `simulated order filled`。`availableSimulatedLiquidity` 是 fixture cap，不是真实盘口深度、真实流动性消耗、broker quote、account position、margin 或 leverage。

`MTP-114-DETERMINISTIC-LATENCY-MODEL`

MTP-114 latency model 只使用 replay record sequence 和固定 tick offset。默认 fixture 从 matched record sequence `2` 延迟 `1` 个 deterministic tick 到 output sequence `3`，并记录 `250ms` 的本地 evidence。它不等于 wall clock、真实网络延迟、exchange latency、broker SLA、production telemetry 或自动优化信号。

`MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`

MTP-114 fee / slippage parity 复用 MTP-27 fixed cost assumptions：maker fee `2 bps`、taker fee `5 bps`、slippage `1.5 bps`、rounding scale `8`。Backtest 与 Paper 用同一 matched price、filled quantity、liquidity role 和 fixed assumptions 生成一致 `ExecutionCostEstimate`，再用 `ExecutionCostParity.verify` 验证一致。它不是真实费率表、VIP tier、symbol-specific fee、broker fee statement、动态滑点模型、真实成交质量或执行成本优化。

`MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE`

MTP-114 必须保证相同 MTP-113 execution input、available simulated liquidity、latency assumption、liquidity role 和 MTP-27 cost assumption 输出同一个 deterministic report identity。默认 partial fixture identity 固定为 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|cursor=2|record=2|order=paper-order-intent-allowed|orderType=market order simulated execution|limit=none|initialState=accepted simulated|availableLiquidity=250000|latencyAssumption=mtp-114-deterministic-latency-assumption|latencySource=2|latencyOutput=3|liquidityRole=taker|costAssumption=mtp-27-fixed-cost-assumptions|fill=partial|latencyMs=25000000000|latencyRecord=3|filled=250000|remaining=250000|fee=526508750|slippage=157952625|totalCost=684461375`。

`MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION`

MTP-114 partial fill / latency / fee / slippage parity 不得升级为 real fee schedule、dynamic slippage model、real liquidity consumption、execution cost optimization、signed endpoint、account endpoint、listenKey、broker integration、broker fill、execution report、reconciliation、`LiveExecutionAdapter`、OMS、real submit / cancel / replace、portfolio projection runtime、Live PRO Console、live command、order-level command UI 或交易按钮。

`MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`

MTP-115 simulated event to portfolio projection 只表示 deterministic simulated exchange parity event 到 value-object portfolio projection 的映射：输入来自 MTP-114 report evidence、MTP-107 report input version 和 replay latency output sequence `3`，输出 backtest / paper 两侧的 position、cash、PnL 和 exposure summary。它不等于 portfolio projection runtime、real account sync、broker position sync、account endpoint read 或 persistence schema read。

`MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`

MTP-115 backtest / paper portfolio parity 要求两侧 projection 共享同一个 source event、report input identity、source replay sequence、filled quantity、matched price、fee、slippage 和 starting cash，并输出完全相同的 `parityComparableIdentity`。默认 partial fixture 固定 filled quantity `0.25`、matched price `42120.70`、gross exposure `10530.175`、cash `39462.98038625`、equity `49993.15538625`、net simulated PnL `-6.84461375`。

`MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`

MTP-115 position / cash / PnL / exposure summary 只包含 net quantity、average entry price、last fill price、position market value、cost basis、fee、slippage、cost impact、cash、available simulated cash、equity、gross exposure、realized / unrealized / net simulated PnL 和 `PortfolioExposureSnapshot`。这些字段是 report / validation evidence，不是真实账户资产、broker statement、margin、leverage、risk limit 或 trading command state。

`MTP-115-REPORT-INPUT-REPLAY-EVIDENCE`

MTP-115 report input / replay evidence 必须绑定 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted`，并在 deterministic identity 中保留 MTP-114 report identity、`startingCash=5000000000000` 和 `sourceReplaySequence=3`。该 evidence 证明 projection 从 replayed simulated fill fact 派生，而不是从 live state、database console 或 Runtime object 派生。

`MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`

MTP-115 simulated exchange portfolio projection parity 不得升级为 real account balance read / sync、broker position read、margin read、leverage read、broker reconciliation、signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、live runtime、live command、order-level command UI、交易按钮、database schema exposure、runtime object read 或 network-dependent validation。

`MTP-116-PARITY-EVIDENCE-READ-MODEL`

MTP-116 parity evidence read model 指 App 层对 MTP-112 至 MTP-115 deterministic parity facts 的只读复制：scenario id、dataset version、fixture version、replay window、matching result、fill summary、reject / expire outcome、latency、fee / slippage、portfolio projection parity、report input version identity 和 replay sequence。它不等于 matching runtime、order execution runtime、portfolio projection runtime、database console 或 command model。

`MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE`

MTP-116 Report / Dashboard / Events parity surface 指 Report、Dashboard Shell、Workbench 和 Evidence Explorer 对 `SimulatedExchangeParityEvidenceReadModel` 的只读展示：Report 显示 evidence count 和 deterministic fields，Dashboard / Workbench 显示 parity evidence / outcomes / timeline / portfolio parity / cost parity metrics，Events 新增 `simulated exchange parity evidence` timeline section。该 surface 不提供 order form、query language、order-level command UI、live command、trading button 或 trading execution authorization。

`MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT`

MTP-116 默认 snapshot 必须把同一个 scenario `mtp-104-btcusdt-1m-first-scenario`、dataset `dataset-v1`、fixture `fixture-v1`、replay window `1704067200...1704067380`、matching event `mtp-112-simulated-exchange-order-matched`、partial / full / rejected / expired simulated outcomes、latency `250ms`、fee `5.2650875`、slippage `1.57952625`、gross exposure `10530.175` 和 net simulated PnL `-6.84461375` 作为 read-model evidence 呈现，证明 projection 从 replayed simulated fill fact 派生。

`MTP-116-READ-MODEL-ONLY-NO-COMMAND-SURFACE`

MTP-116 read-model-only boundary 要求所有 Report / Dashboard / Events parity evidence 只消费 App ViewModel，不读取 Runtime object、Persistence schema、Adapter request、secret、signed endpoint、account endpoint、listenKey、broker payload 或 live state；Codable decode 也不能恢复 command surface、order-level command、Live PRO Console、交易按钮或真实交易授权。

`MTP-116-NO-LIVE-BROKER-SIGNED-ENDPOINT`

MTP-116 parity evidence surface 必须保持 signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、database schema exposure、Runtime object exposure、adapter request exposure、live runtime 和 network-dependent validation 全部为 false。

## Workbench Beta Readiness Terms

`MTP-118-WORKBENCH-BETA-READINESS-TERMINOLOGY`

以下术语由 MTP-118 定义为 `MTPRO Workbench Beta Readiness v1` 的 L2+ local Workbench beta language。它们只用于 Workbench beta readiness contract、acceptance boundary、local-only beta demo path、L1 / L1.5 / L2 / L2+ handoff boundary、forbidden capability baseline 和 validation anchors，不授权当前 scope 实现 install / run 逻辑、engine core capability、release package、production release、notarization、App Store distribution、auto-update、production operations、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button 或 live command。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Workbench beta readiness` | L2+ maturity slice 的本地 macOS Workbench demo / acceptance 准备度 | 不等于 production release、live readiness、notarization、App Store release 或 production operations |
| `beta acceptance path` | operator 后续按固定本地路径验收 Workbench demo 的证据链 | 当前不实现 launch / install / run 逻辑，不替代 `bash checks/run.sh` |
| `local macOS Workbench demo` | 只在本机 macOS Workbench 展示 L1 / L1.5 / L2 已完成 evidence 的 demo 目标 | 不等于 cloud service、Live PRO Console、production deployment 或真实交易工作台 |
| `demo workflow` | 后续 issue 逐步固定 demo scenario、first-run state、Report / Dashboard / Events evidence 和 checklist 的流程语言 | 当前不选择 fixture、不写启动脚本、不新增 UI 或 runtime behavior |
| `acceptance boundary` | beta readiness 验收必须保持 local-only、read-model-only、no live / broker / signed / account / OMS / trading button | 不授权下一 issue 自动执行，不授权 live / broker / production release |
| `local-only beta definition` | beta readiness 只代表本地可演示 / 可验收，不代表生产发布或 live 准入 | 不等于 production installer、auto-update、notarized build 或 real account readiness |

`MTP-118-BETA-ACCEPTANCE-BOUNDARY`

MTP-118 beta acceptance boundary 要求 Workbench beta readiness 只表示 local macOS Workbench demo / acceptance path。它必须保持 evidence-first、read-model-only 和 local-only，不得变成 production release、live readiness、cloud deployment、Runtime command surface、order form、trading button、Live PRO Console、signed endpoint、account endpoint、listenKey、broker payload、OMS 或真实交易授权。

`MTP-118-LOCAL-ONLY-BETA-DEMO-PATH`

MTP-118 只定义 local-only beta demo path 的验收语言。MTP-119 至 MTP-125 后续 issue 才能分别处理 local launch / install / environment verification、demo scenario / fixture wiring、first-run default demo state、Report / Dashboard / Events acceptance path、reproducible beta checklist / script、docs index / operator guide 和 stage audit input material；MTP-118 不提前实现这些后续 issue。

`MTP-118-L1-L15-L2-L2PLUS-HANDOFF`

MTP-118 把 L1 Paper Runtime、L1.5 Data Catalog / Scenario Replay 和 L2 Simulated Exchange / Backtest Parity 的已完成 deterministic evidence 连接到 L2+ Workbench Beta Readiness 的 local demo / acceptance boundary。该 handoff 不表示 production trading engine、production data platform、production matching runtime、真实 exchange runtime、broker / OMS、signed endpoint、account endpoint / listenKey、execution report、broker fill、reconciliation、Live PRO Console、trading button 或 live command 已进入当前 scope。

`MTP-118-FORBIDDEN-CAPABILITY-BASELINE`

MTP-118 的 forbidden baseline 必须覆盖 engine core capability expansion、install / run implementation、release package creation、production release、notarization、App Store distribution、auto-update、production operations、API key / secret read、signed endpoint、account endpoint、listenKey、broker integration、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop / shutdown / restore、Graphify update 和 Figma change。

`MTP-118-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record 中的 first executable issue candidate 只是候选。只有 Linear live-read 中经 Parent Codex queue preflight 确认为唯一 Todo / configured executable issue 的 MTP-118 才能执行；MTP-119 至 MTP-125 仍必须保持 Backlog / blocked，直到 MTP-118 独立完成 PR、required check、merge 和 Linear Done evidence 后再由 Parent Codex queue preflight 单独判断。

`MTP-119-LOCAL-LAUNCH-INSTALL-ENVIRONMENT-PATH`

MTP-119 在 MTP-118 的 local-only beta demo path 边界内定义本地 launch / install / environment verification path。这里的 install 只表示 SwiftPM 本地依赖解析和 `.build` 构建产物，不等于 production installer、notarized artifact、App Store distribution、auto-update、production deployment 或 cloud operations。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `local environment verification` | operator 在仓库根目录用 `uname -s`、`swift --version` 和 `swift package resolve` 确认 Darwin / Swift 6+ / SwiftPM dependency resolution | 不读取 API key、secret、account endpoint、listenKey、broker credential 或生产配置 |
| `local install path` | `swift build --product Dashboard` 生成本地 SwiftPM build artifact | 不等于 `.app` installer、`.pkg`、`.dmg`、notarization、App Store build、auto-update channel 或 production release |
| `local launch command` | `swift run Dashboard` 或自动 smoke 的 `DASHBOARD_SMOKE=1 swift run Dashboard` | 不等于 production deployment、cloud operations、Live PRO Console 或 live runtime |
| `Dashboard smoke expectation` | Dashboard smoke summary 必须输出 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 blocked live evidence | 不等于 UI acceptance checklist 完成，不等于 demo scenario 已选择，不等于 live readiness |
| `reproducible launch evidence` | `swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `bash checks/run.sh` 的本地输出证据 | 不替代 GitHub required check，不替代后续 MTP-123 beta acceptance checklist / script |
| `launch troubleshooting boundary` | 失败排查只沿 SwiftPM dependency、Dashboard build、Dashboard smoke、`checks/run.sh` 最小失败点定位 | 不引入 signed endpoint、account endpoint、broker、OMS、real order lifecycle、Live PRO Console、live command 或 trading button |

`MTP-119-LOCAL-LAUNCH-VALIDATION`

MTP-119 required validation 是 `DASHBOARD_SMOKE=1 swift run Dashboard` 和 `bash checks/run.sh`。该 validation 只证明 local macOS Workbench beta launch path 可复现；它不表示 production release、notarization、App Store distribution、auto-update、production operations、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button 或 live command 已实现或获授权。

MTP-119 的英文锚点表述中，local install 只表示 SwiftPM dependency resolution 和本地 `.build` artifact，不表示发布安装或生产分发。

`MTP-120-DEMO-SCENARIO-SELECTION`

MTP-120 在 local-only beta demo path 内固定唯一 demo scenario：`mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`。该选择只表示 Workbench beta demo 输入，不等于 production data catalog、production dataset registry、automatic downloader、Runtime replay job 或真实市场数据平台。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `beta demo scenario` | MTP-120 固定的本地 deterministic scenario id / dataset version / fixture version | 不等于 production dataset、remote catalog、真实历史数据下载任务或 live readiness |
| `demo fixture wiring` | 把 L1.5 Scenario Replay report input evidence 与 L2 Simulated Exchange / Backtest Parity evidence 绑定到同一 demo scenario | 不等于 Runtime replay job、production matching runtime、App first-run state 或 Dashboard acceptance surface |
| `demo checksum / freshness evidence` | `fnv1a64:3c6cd4ff13cd4062`、`fresh` 和 `accepted` 作为 beta demo 输入追踪证据 | 不等于 production data quality monitor、retention engine、自动修复或真实网络校验 |

`MTP-120-DATASET-FIXTURE-VERSION-LOCK`

MTP-120 固定 `dataset-v1` 和 `fixture-v1`，使后续 MTP-121 / MTP-122 / MTP-123 只能消费同一 deterministic beta fixture。该 version lock 不表示 remote sync、dataset registry、production release version 或 production operations readiness。

`MTP-120-SCENARIO-REPLAY-FIXTURE-WIRING`

MTP-120 的 wiring 由 Core 值对象 `WorkbenchBetaDemoScenarioSelection` 和 `WorkbenchBetaDemoFixtureEvidence` 表达：前者固定 selection，后者复用 `ScenarioDataQualityReportInputEvidence.deterministicFixture` 和 `SimulatedExchangePortfolioProjectionParityFixture.deterministicEvidence()`。该 wiring 不新增 fixture records、不触发 replay scheduler、不读取 Persistence schema、不调用 Adapter、不新增 App read model 或 Dashboard first-run state。

`MTP-120-CHECKSUM-FRESHNESS-EVIDENCE`

MTP-120 demo fixture 的 checksum / freshness / quality evidence 固定为 `fnv1a64:3c6cd4ff13cd4062`、`fresh`、`accepted`，report input version 固定为 `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted`。

`MTP-120-L15-L2-EVIDENCE-RELATIONSHIP`

MTP-120 只记录 L1.5 Scenario Replay evidence 与 L2 Simulated Exchange / Backtest Parity evidence 的 relationship：二者共享同一 scenario / dataset / fixture / report input version，后续 L2+ Workbench Beta Readiness issue 可在 read-model-only 路径中消费。它不授权 production matching runtime、真实 exchange runtime、broker adapter、execution report、broker fill、reconciliation、Live PRO Console、trading button 或 live command。

`MTP-120-NO-NETWORK-DOWNLOAD-LIVE-BROKER`

MTP-120 validation 必须证明 demo path 不依赖真实网络或自动下载，不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、live command、trading button、Graphify 或 Figma。

`MTP-121-DEFAULT-SELECTED-SCENARIO`

MTP-121 把 Workbench first-run 默认选择固定为 MTP-120 的 local deterministic beta demo scenario：`mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`。该默认选择只表示本地 Workbench beta demo 启动状态，不等于 production dataset、remote catalog、Runtime replay job、live readiness 或真实交易授权。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `first-run default demo state` | Dashboard 启动后默认展示的 local beta evidence state | 不等于 UI redesign、Live PRO Console、production release 或 live readiness |
| `default selected scenario` | MTP-121 启动 snapshot 中选择的 MTP-120 deterministic scenario | 不等于用户可切换 scenario selector、remote catalog 或下载任务 |
| `first-run evidence summary` | App ViewModel 复制 scenario、dataset / fixture version、checksum、freshness、quality、report input version 和 L1.5 / L2 relationship 的只读摘要 | 不等于 Runtime replay result、Persistence schema、Core object inspector 或执行入口 |
| `first-run fallback state` | `empty` / `loading` / `error` 三个只读 fallback | 不等于 retry command、download command、repair command 或 Runtime mutation |

`MTP-121-READ-MODEL-ONLY-DASHBOARD-STATE`

MTP-121 的 first-run state 只能通过 `WorkbenchBetaFirstRunReadModel`、`WorkbenchBetaFirstRunViewModel`、`DashboardReadModel.defaultWorkbenchBetaDemo` 和 `DashboardViewModel.defaultWorkbenchBetaDemo` 进入 Dashboard。Dashboard 不直接读取 Core fixture、Persistence schema、Runtime object 或 Adapter request。

`MTP-121-FIRST-RUN-FALLBACK-STATES`

MTP-121 固定 fallback states 为 `empty`、`loading`、`error`。这些 fallback 只解释展示状态，不提供 retry / download / repair command，不读取 secret，不接 signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、Live PRO Console、live command 或 trading button。

`MTP-121-FIRST-RUN-EVIDENCE-SUMMARY`

MTP-121 first-run summary 必须保留 `checksum=fnv1a64:3c6cd4ff13cd4062`、`freshness=fresh`、`quality=accepted`、`scenarioReplayEvidence=1`、`simulatedParityEvidence=1` 和 `defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`。它只消费 MTP-120 fixture wiring，不新建 fixture records，不实现 MTP-122 Report / Dashboard / Events acceptance path。

`MTP-121-DEMO-FIXTURE-ALIGNMENT`

MTP-121 必须证明 first-run state 与 MTP-120 demo fixture wiring 使用同一 scenario、dataset version、fixture version、report input version 和 parity evidence identity；不得换数据源或把 demo state 写成 production data readiness。

`MTP-121-NO-LIVE-PRO-CONSOLE-TRADING-COMMAND`

MTP-121 validation 必须证明 first-run state 不新增 Live PRO Console、live command、trading button、order-level command、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、Graphify 或 Figma。

`MTP-122-REPORT-BETA-ACCEPTANCE-SUMMARY`

MTP-122 把 Report beta acceptance summary 定义为 read-model-only acceptance path summary：它从 MTP-121 first-run default demo state、MTP-108 Scenario Replay App evidence 和 MTP-116 Simulated Exchange / Backtest Parity App evidence 复制同一 demo fixture identity。执行记录：2026-05-27，Codex。该 summary 不等于 Runtime replay job、production report engine、database query surface 或 live readiness。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `beta acceptance path` | Report / Dashboard / Events 对同一 local deterministic demo scenario 的只读验收链路 | 不等于 production release acceptance、Live readiness 或真实交易验收 |
| `Report beta acceptance summary` | Report 层展示 scenario、dataset / fixture version、report input version、quality、scenario replay 和 simulated parity evidence 的摘要 | 不等于 Runtime replay result、database schema、adapter request 或 Core object inspector |
| `Dashboard beta evidence panels` | Dashboard shell 中的 acceptance path metrics / details / smoke handles | 不等于完整 UI redesign、Live PRO Console、trading button 或 command surface |
| `Events beta acceptance trace` | Evidence Explorer 中 `workbench beta acceptance path` section 的 timeline rows | 不等于 broker event stream、execution report、account event 或 incident replay runtime |

`MTP-122-DASHBOARD-BETA-EVIDENCE-PANELS`

MTP-122 Dashboard panels 必须通过 `WorkbenchBetaAcceptancePathViewModel` 和 `DashboardShellSnapshot` 输出 `betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。这些 handles 只表示 local beta evidence 可验收，不提供 scenario selector、download action、repair command、order command、live command 或交易按钮。

`MTP-122-EVENTS-BETA-ACCEPTANCE-TRACE`

MTP-122 Events trace 必须包含 Report summary、Scenario Replay evidence、Simulated Exchange / Backtest Parity evidence、Portfolio evidence 和 boundary summary 五个 read-model-only trace rows。Trace rows 只链接已存在 evidence id，不运行 matching runtime、execution runtime、portfolio runtime、broker runtime 或 live runtime。

`MTP-122-SAME-DEMO-SCENARIO-EVIDENCE`

MTP-122 同一 demo scenario evidence 必须固定 `mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`、checksum `fnv1a64:3c6cd4ff13cd4062`、freshness `fresh`、quality `accepted` 和 report input version `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted`。任一 evidence source 不匹配时，acceptance path 必须为空。

`MTP-122-SCENARIO-PARITY-PORTFOLIO-TRACE`

MTP-122 scenario / parity / portfolio trace 必须同时展示 Scenario Replay evidence、Simulated Exchange / Backtest Parity evidence 和 portfolio projection parity evidence，默认 portfolio evidence id 为 `mtp-115-simulated-exchange-portfolio-projection-parity-portfolio-parity`。它只表示 simulated evidence chain 完整，不表示真实 account balance、broker position、margin、leverage、broker fill、reconciliation 或 real account endpoint。

`MTP-122-READ-MODEL-ONLY-NO-RUNTIME-COMMAND`

MTP-122 validation 必须证明 acceptance path 不新增 engine core capability、Runtime replay job、matching runtime、order execution runtime、portfolio projection runtime、Persistence schema exposure、database console、Runtime object inspector、Adapter request exposure、signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、live command、trading button、order-level command UI、Graphify 或 Figma。

`MTP-123-REPRODUCIBLE-BETA-ACCEPTANCE-WORKFLOW`

MTP-123 把 local macOS Workbench beta acceptance 固定为 operator 可复现 workflow：`checks/workbench-beta-acceptance.sh` 只运行本地环境验证、SwiftPM dependency resolution、Dashboard smoke 和 `bash checks/run.sh`。该 workflow 不等于 CI replacement、production release、notarization、App Store distribution、auto-update、production operations 或 live readiness。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `beta acceptance checklist` | operator 按固定步骤检查 local Workbench demo、demo scenario、Report / Dashboard / Events evidence 和 boundary handles | 不等于 release checklist、production ops runbook、CI replacement 或 live readiness checklist |
| `beta acceptance script` | `checks/workbench-beta-acceptance.sh` 对既有 local commands 的薄编排和 smoke handle 校验 | 不等于 installer、deployment script、Graphify job、Figma automation 或 production operations script |
| `operator reproducibility evidence` | `.codex/beta-acceptance/<run-id>/` 下的本地 transcript | 不进入 PR，不作为 secret / account / broker evidence |
| `failure triage hints` | 只沿 SwiftPM、Dashboard smoke、automation readiness 和 `swift test` 收窄失败 | 不通过 signed endpoint、broker、LiveExecutionAdapter、OMS、Live PRO Console、trading button 或 live command 绕过失败 |

`MTP-123-BETA-ACCEPTANCE-CHECKLIST`

MTP-123 checklist 必须同时覆盖 MTP-119 launch path、MTP-120 deterministic fixture、MTP-121 first-run default demo state 和 MTP-122 Report / Dashboard / Events acceptance path。关键 handles 是 `defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptanceTrace=5`、`readModelOnly=true` 和 `workbenchReadModelOnly=true`。

`MTP-123-LOCAL-COMMANDS-EXPECTED-OUTPUTS`

MTP-123 expected outputs 只锁定 operator acceptance 所需的稳定 smoke handles 和 `MTPRO checks passed.`；它不把 SwiftPM build noise、timing 或完整 stdout 当成领域 contract。

`MTP-123-OPERATOR-REPRODUCIBILITY-EVIDENCE`

MTP-123 operator reproducibility evidence 只保存在 `.codex/beta-acceptance/<run-id>/`，用于本地 handoff 和 debug。它不得进入 PR，不得包含 secret、API key、account endpoint、listenKey、broker credential、signed request 或 production operations state。

`MTP-123-FAILURE-TRIAGE-HINTS`

MTP-123 failure triage 只能沿 `uname -s`、`swift --version`、`swift package resolve`、Dashboard smoke、`checks/automation-readiness.sh` 和 `swift test` 收窄；不得把失败升级成 Graphify refresh、Figma update、release automation、broker action、live command 或 trading button。

`MTP-123-NO-GRAPHIFY-FIGMA-PRODUCTION-OPS`

MTP-123 validation 必须证明 checklist / script 不运行 Graphify、不修改 Figma、不新增 production ops、不新增 release automation、不接 signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button 或 live command。

`MTP-124-DOCS-INDEX`

MTP-124 把 docs index 固定为 operator 的文档入口：`docs/index.md` 只帮助 Human / operator 找到 root docs、Workbench Beta Readiness docs、acceptance checklist、operator guide、demo workflow guide 和 required validation。docs index 不替代 Linear issue execution contract，不授权下一阶段 execution，不创建 production release，不表示 live readiness。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `docs index` | 仓库内正式中文文档导航，指向 root docs、operator guide、demo workflow guide、acceptance checklist 和 boundary docs | 不等于 marketing landing page、release portal、production runbook 或 Linear execution contract |
| `operator guide` | local macOS Workbench beta 的本机操作手册，说明环境确认、Dashboard smoke、acceptance script、expected handles 和 failure triage | 不等于 production deployment guide、Live PRO Console docs、notarization guide 或 App Store guide |
| `demo workflow guide` | 解释 MTP-119 至 MTP-123 如何串成同一 deterministic acceptance evidence chain | 不等于 Runtime replay job、scenario selector、remote catalog、download action 或 repair command |
| `known limitations` | 明确 local Workbench beta 的限制，例如 single deterministic fixture、SwiftPM local artifact、command-line smoke summary 和 `.codex` local transcript | 不等于 roadmap promise、release blocker bypass 或 production readiness claim |
| `troubleshooting pointers` | 只沿 SwiftPM、Dashboard smoke、acceptance script、automation readiness 和 Swift tests 收窄失败 | 不通过 signed endpoint、broker、Graphify、Figma、Live PRO Console、trading button 或 live command 绕过失败 |

`MTP-124-OPERATOR-GUIDE`

MTP-124 operator guide 只服务 local Workbench beta operator。它允许 operator 运行 `bash checks/workbench-beta-acceptance.sh`、查看 stable smoke handles、阅读 `.codex/beta-acceptance/<run-id>/` 本地 transcript 和按 `bash checks/run.sh` 失败顺序排查。它不创建 release artifact，不读取 secret，不接 broker，不提供交易操作入口。

`MTP-124-DEMO-WORKFLOW-GUIDE`

MTP-124 demo workflow guide 只解释以下 evidence chain：MTP-119 local launch / install、MTP-120 deterministic fixture、MTP-121 first-run state、MTP-122 Report / Dashboard / Events acceptance path、MTP-123 reproducible checklist / script。该 workflow 不新增 Runtime job、App read model、Dashboard behavior、production data platform、Graphify update 或 Figma change。

`MTP-124-KNOWN-LIMITATIONS`

MTP-124 known limitations 必须说明 local install 只是 SwiftPM dependency resolution / `.build` artifact，Dashboard smoke 是 command-line summary，demo scenario 固定为 `mtp-104-btcusdt-1m-first-scenario`，operator transcript 只在 `.codex/beta-acceptance/<run-id>/`，stage closeout 仍归属 MTP-125。

`MTP-124-FORBIDDEN-CAPABILITY-BOUNDARY`

MTP-124 docs 必须保持 production release、notarization、App Store distribution、auto-update、production deployment、cloud operations、signed endpoint、account endpoint / listenKey、API key / secret read、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、live readiness、Live PRO Console、trading button、live command、emergency stop / shutdown / restore、Graphify update 和 Figma change 仍为 forbidden / Future Gated。

`MTP-124-TROUBLESHOOTING-POINTERS`

MTP-124 troubleshooting 只允许沿 `uname -s`、`swift --version`、`swift package resolve`、`swift build --product Dashboard`、`DASHBOARD_SMOKE=1 swift run Dashboard`、`bash checks/workbench-beta-acceptance.sh` 和 `bash checks/run.sh` 收窄失败。

`MTP-124-BETA-NOT-LIVE-READINESS`

MTP-124 必须明确 Workbench beta readiness 不等于 live readiness。它只表示 local macOS Workbench demo / acceptance path 可复现，不表示真实账户、broker readiness、Live PRO Console readiness、live runtime readiness、真实交易授权、production release 或下一阶段 execution 授权。

`MTP-124-DOCS-OPERATOR-GUIDE-VALIDATION`

MTP-124 validation 必须证明 docs index、operator guide、demo workflow guide、known limitations、forbidden capabilities、troubleshooting pointers 和 acceptance workflow references 均存在，并且 `bash checks/run.sh` 通过。

## Live Read-only Readiness Terms

`MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY`

以下术语由 MTP-126 定义为 `MTPRO Live Read-only Readiness Boundary v1` 的 L3.0 boundary language。它们只用于术语、target engines / layers、future gates、forbidden capability baseline 和 validation anchors，不授权当前 scope 实现 endpoint、secret、adapter、account read model、UI 或 live runtime。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `Live read-only readiness` | 靠近真实账户只读能力前的 L3.0 准备边界，固定术语、future gates、validation anchors 和 forbidden baseline | 不等于真实账户读取、private stream、broker connection、Live Monitoring v2 或 Live Production |
| `read-only readiness boundary` | 当前 Project 只能定义 boundary / contract / forbidden baseline，不实现运行时能力 | 不等于 account endpoint runtime、adapter capability implementation、App read model 或 Dashboard surface |
| `target engine / layer boundary` | Connectivity / Adapter Engine、Data Engine / future private stream boundary、Evidence Read Model Layer、Workbench Interface / Live Readiness surface 和 Docs / Validation / Automation readiness layer 的职责地图 | 不等于新增 SwiftPM target、Runtime actor、ViewModel 或 UI 行为 |
| `read-only future gate` | 后续 account / position / balance、private stream / account snapshot simulation gate 和 Live Monitoring read-only Console v2 进入 planning 前必须满足的 gate | 不等于当前可读取真实账户、创建 listenKey 或连接 private WebSocket |

`MTP-126-TARGET-ENGINE-LAYER-BOUNDARY`

MTP-126 target engines / layers 只作为边界语言出现：Connectivity / Adapter Engine 只能定义 public market data allowed、future private read-only gate 和 forbidden write capability baseline；Data Engine 只能定义 future private stream boundary；Evidence Read Model Layer 只能定义后续 read-model-only evidence source boundary；Workbench Interface 只能定义 Live Readiness surface 的 read-model-only boundary；Docs / Validation / Automation readiness layer 只落 contract、matrix、latest summary 和 mechanical anchors。

`MTP-126-L30-L31-L32-L33-HANDOFF`

MTP-126 的 L3.0 handoff 只把 terminology、target engines、future gates、forbidden baseline 和 validation anchors 交给后续 issue。MTP-127 才能定义 credential / endpoint taxonomy，MTP-128 才能定义 adapter capability matrix，MTP-129 才能定义 account / position / balance read-model-only future gates，MTP-130 才能定义 private stream / account snapshot simulation gate input material，MTP-131 才能定义 Workbench Live readiness read-model-only boundary，MTP-132 才能做 validation / automation / stage audit input closeout。

`MTP-126-FORBIDDEN-CAPABILITY-BASELINE`

MTP-126 的 forbidden baseline 必须覆盖 API key / secret storage、local secret read、signed endpoint、account endpoint、listenKey、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage runtime、account / position / balance read model implementation、Live Monitoring Console v2 implementation、Live PRO Console、trading button、live command、order form、emergency stop / shutdown / restore executable action、Graphify update 和 Figma change。

`MTP-126-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record 中的 first executable issue candidate 只是候选，不构成执行授权。只有 Linear live-read 中经 Parent Codex queue preflight 和 symphony-issue 调度后，作为唯一 active configured executable issue 的 MTP-126 才可执行；MTP-126 完成后不得自动推进 MTP-127。

`MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION`

MTP-126 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 L3.0 terminology / boundary，并且 `bash checks/run.sh` 通过。

`MTP-127-CREDENTIAL-SECRET-POLICY-FUTURE-GATE`

MTP-127 credential / secret policy 只能作为 L3.0 future gate 和 forbidden baseline 出现。`LiveReadOnlyCredentialPolicyTerm` 只允许命名 credential / secret policy future gate、no local secret read、no API key / secret storage implementation、no env / keychain / config secret path 和 no credential provider runtime；它不授权当前读取 secret、创建配置路径或实现 credential provider。

`MTP-127-ENDPOINT-CAPABILITY-TAXONOMY`

MTP-127 endpoint capability taxonomy 固定 `public read-only market data` 是唯一 current allowed capability；`signed endpoint forbidden`、`account endpoint forbidden`、`listenKey forbidden`、`private WebSocket forbidden` 和 `broker action forbidden` 只能作为 forbidden / future gate evidence。禁止把这些词写成 partially supported、preview enabled、behind flag available 或 local fallback。

`MTP-127-PUBLIC-READ-ONLY-PRIVATE-ENDPOINT-ISOLATION`

MTP-127 public read-only / private endpoint isolation 表示 public market data 不能升级为 signed request、account endpoint、listenKey、private WebSocket、broker action、`LiveExecutionAdapter` 或 private read runtime。MTP-127 不实现 MTP-128 adapter capability matrix，不实现 MTP-129 account / position / balance read model，不实现 MTP-130 private stream / account snapshot simulation gate，不实现 MTP-131 Workbench Live readiness surface。

`MTP-127-FORBIDDEN-CAPABILITY-TESTS`

MTP-127 forbidden capability tests 必须证明 `LiveReadOnlyCredentialEndpointTaxonomyBoundary` 的 secret read、API key storage、secret configuration path、signed endpoint、account endpoint、listenKey、private WebSocket、broker action、`LiveExecutionAdapter`、private read runtime、public adapter upgrade 和 network dependency flags 全部为 `false`，并且 Codable 解码不能恢复这些 forbidden capability。

`MTP-127-LIVE-READ-ONLY-CREDENTIAL-ENDPOINT-VALIDATION`

MTP-127 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture 和 focused tests 均固定 credential / endpoint taxonomy boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不连接 broker、不触发真实交易行为。

`MTP-128-ADAPTER-CAPABILITY-MATRIX`

MTP-128 adapter capability matrix 固定 `public market data allowed` 是唯一 current allowed adapter capability；`future private account read-only gated` 只能作为 future gated capability；`signed endpoint forbidden`、`order write forbidden`、`broker action forbidden`、`broker execution adapter forbidden`、`exchange execution adapter forbidden`、`LiveExecutionAdapter forbidden`、`account endpoint / listenKey forbidden`、`execution report / broker fill / reconciliation forbidden` 和 `real account / broker position / margin / leverage forbidden` 只能作为 forbidden evidence。

`MTP-128-PUBLIC-READ-ONLY-ADAPTER-PRIVATE-GATE-ISOLATION`

MTP-128 public read-only adapter / future private gate isolation 表示当前 public market data adapter 不能升级为 private account read runtime、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、order write、execution report、broker fill、reconciliation 或真实账户 / 仓位 / 保证金 / 杠杆读取。MTP-128 不实现 adapter runtime，不新增 Adapters target 类型，不实现 MTP-129 account / position / balance read model，不实现 MTP-130 private stream / account snapshot simulation gate。

`MTP-128-FORBIDDEN-ADAPTER-CAPABILITY-TESTS`

MTP-128 forbidden adapter capability tests 必须证明 `LiveReadOnlyAdapterCapabilityMatrixBoundary` 的 broker adapter、exchange execution adapter、`LiveExecutionAdapter`、public adapter execution upgrade、signed endpoint、account endpoint、listenKey、order write、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage 和 network dependency flags 全部为 `false`，并且 Codable 解码不能恢复这些 forbidden capability。

`MTP-128-LIVE-READ-ONLY-ADAPTER-CAPABILITY-VALIDATION`

MTP-128 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture 和 focused tests 均固定 adapter capability matrix boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不连接 broker、不触发真实交易行为。

`MTP-129-ACCOUNT-POSITION-BALANCE-FUTURE-GATES`

MTP-129 account / position / balance future gates 只能作为 L3.1 read-model-only handoff material 出现。`LiveReadOnlyAccountPositionBalanceFutureGate` 只允许命名 account read-model-only contract、position read-model-only contract、balance read-model-only contract、source identity required、snapshot freshness required、evidence identity required、Workbench / Dashboard ViewModel boundary 和 paper / simulated / fixture evidence isolation；它不授权当前读取 real account、broker position、margin、leverage 或 real PnL。

`MTP-129-SOURCE-FRESHNESS-EVIDENCE-IDENTITY-BOUNDARY`

MTP-129 source identity / freshness / evidence identity boundary 表示后续 L3.1 必须区分 future account source identity、future position source identity、future balance source identity 和 fixture source identity isolation，并在 snapshot 上记录 observedAt、source watermark 和 stale boundary。MTP-129 不实现 account snapshot runtime、不连接 private stream、不调用 signed endpoint、account endpoint 或 listenKey。

`MTP-129-FORBIDDEN-ACCOUNT-DATA-INTERPRETATION-TESTS`

MTP-129 forbidden interpretation tests 必须证明 `LiveReadOnlyAccountPositionBalanceFutureGateBoundary` 的 account / position / balance runtime、real account read、broker position sync、real account balance、margin、leverage、real PnL、signed/account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、OMS、paper evidence -> real account data、simulated fill -> broker position、fixture evidence -> real account snapshot、trading button、live command 和 network dependency flags 全部为 `false`，并且 Codable 解码不能恢复这些 forbidden capability。

`MTP-129-LIVE-READ-ONLY-ACCOUNT-POSITION-BALANCE-VALIDATION`

MTP-129 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture 和 focused tests 均固定 account / position / balance read-model-only future gate boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不读取真实账户、不连接 broker、不触发真实交易行为。

`MTP-130-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE`

MTP-130 private stream / account snapshot simulation gate input material 只能作为 L3.2 handoff material 出现。`LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial` 只允许命名 private stream source identity、account snapshot fixture identity、snapshot observedAt、source watermark、freshness boundary、account / position / balance event shape、fixture replay cursor 和 simulation gate boundary；它不授权当前创建 listenKey、连接 private WebSocket、运行 account snapshot runtime 或读取真实账户。

`MTP-130-FUTURE-FIXTURE-REQUIREMENTS`

MTP-130 future fixture requirements 表示后续 L3.2 必须使用 deterministic account snapshot fixture、private stream event fixture、fixture source identity、fixture freshness、replay cursor、live stream implementation separation、listenKey forbidden validation 和 network independent validation。MTP-130 不实现 fixture runtime、不调用 account endpoint、不创建 private stream runtime，也不依赖真实 Binance 网络。

`MTP-130-SIMULATION-GATE-LIVE-STREAM-ISOLATION`

MTP-130 simulation gate / live stream isolation 表示 simulation gate input material 不能被解释为 live private stream implementation，fixture account snapshot 不能被解释为真实 account snapshot。MTP-130 不新增 Adapters、Runtime、App、Dashboard behavior，不实现 L3.2，不把 public read-only adapter 或 MTP-129 account / position / balance future gate 升级为 private stream runtime。

`MTP-130-LISTENKEY-FORBIDDEN-TESTS`

MTP-130 listenKey forbidden tests 必须证明 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary` 的 listenKey create / keepalive、private WebSocket、private stream runtime、account snapshot runtime、signed/account endpoint、real account read、real account payload consumption、broker position sync、margin / leverage、broker adapter、`LiveExecutionAdapter`、OMS、real order write、simulation gate -> live stream implementation、fixture snapshot -> real account snapshot、trading button、live command 和 network dependency flags 全部为 `false`，并且 Codable 解码不能恢复这些 forbidden capability。

`MTP-130-LIVE-READ-ONLY-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-VALIDATION`

MTP-130 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture 和 focused tests 均固定 private stream / account snapshot simulation gate input boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不创建 listenKey、不连接 private WebSocket、不读取真实账户、不连接 broker、不触发真实交易行为。

`MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY`

MTP-131 Workbench Live readiness read-model-only boundary 表示 Workbench、Dashboard、Report 和 Event Timeline 只能展示 Live readiness boundary evidence。`LiveReadOnlyWorkbenchReadModelBoundary`、`LiveReadOnlyWorkbenchBoundaryReadModel` 和 `LiveReadOnlyWorkbenchBoundaryViewModel` 只允许携带 surface labels、ReadModel / ViewModel input boundary、forbidden UI labels、detail / audit route、L3.1 / L3.2 / L3.3 handoff target、source anchors 和 validation anchors；它们不等于 API key 表单、broker connect、account connect、Live PRO Console、trading button、live command、order form、real account balance 或 broker position。

`MTP-131-READ-MODEL-VIEWMODEL-INPUT-BOUNDARY`

MTP-131 ReadModel / ViewModel input boundary 表示 UI 输入只能来自 Core deterministic fixture、App read model projection、App ViewModel snapshot、Dashboard shell snapshot 和 Evidence Explorer timeline route。Workbench / Dashboard 不允许直接读取 secret、Persistence schema、Runtime object、adapter request、signed endpoint、account endpoint、listenKey、private WebSocket、broker state、account payload 或真实账户数据。

`MTP-131-FORBIDDEN-UI-SURFACE`

MTP-131 forbidden UI surface 必须覆盖 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command、order form、real account balance、broker position、Runtime object、database schema、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle 和 real submit / cancel / replace。这些词只能作为 forbidden evidence、validation matrix 和 PR boundary evidence 出现，不能作为可见交互、连接向导、命令入口或真实账户展示。

`MTP-131-DETAIL-AUDIT-ROUTING`

MTP-131 detail / audit routing 只允许 Dashboard summary -> Report evidence、Report evidence -> Event Timeline、Event Timeline -> contract anchor 和 detail inspector -> validation anchor。它不授权查询语言、Runtime replay command、incident replay、stop control、broker operation、live audit runtime 或任何 production operation。

`MTP-131-L31-L32-L33-HANDOFF`

MTP-131 L3.1 / L3.2 / L3.3 handoff 只说明 Workbench UI 已保留后续只读 evidence 位置：account / position / balance read-model-only、private stream / account snapshot simulation gate 和 Live Monitoring read-only console v2。该 handoff 不授权后续 issue 自动执行，也不授权 signed/account/broker capability。

`MTP-131-LIVE-READ-ONLY-WORKBENCH-VALIDATION`

MTP-131 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc、Core fixture、App ReadModel / ViewModel、Dashboard shell、Event Timeline 和 focused tests 均固定 Workbench read-model-only boundary，并且 required validation 不读取 secret、不依赖真实 Binance 网络、不连接 broker、不触发真实交易行为、不创建 live command 或 trading button。

## Account / Position / Balance Read-model-only Terms

`MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-TERMINOLOGY`

以下术语由 MTP-133 定义为 `MTPRO Account / Position / Balance Read-model-only v1` 的 L3.1 boundary language。它们只用于 terminology、contract、validation anchors 和后续 issue handoff，不授权当前 scope 实现 account runtime、position runtime、balance runtime、signed endpoint、account endpoint / listenKey、private WebSocket、broker adapter、Live PRO Console、trading button、live command 或 order form。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `account read-model-only evidence` | 本地 / fixture / paper / simulated 来源的账户证据解释层 | 不等于真实 account endpoint payload、account snapshot runtime、broker account sync 或可交易账户状态 |
| `position read-model-only evidence` | 本地 / fixture / paper / simulated 来源的仓位证据解释层 | 不等于 broker position、margin position、leverage position、real portfolio sync 或 broker risk input |
| `balance read-model-only evidence` | 本地 / fixture / paper / simulated 来源的余额证据解释层 | 不等于真实账户余额、buying power、margin、leverage、real PnL 或可下单资金 |
| `read-model-only source` | 当前只允许 fixture / paper / simulated / future-gated real label 的证据来源标签 | 不等于 account endpoint、listenKey、private stream、broker adapter 或真实账户连接 |
| `future real source` | 未来可能接入真实账户只读能力前的门禁标签 | 不等于当前已实现真实账户读取、secret storage、signed request 或 private WebSocket |

`MTP-133-SOURCE-SEMANTICS-BOUNDARY`

MTP-133 source semantics 只允许表达 fixture source、paper source、simulated source 和 future-gated real source。fixture source 是 deterministic local fixture，不是真实 account payload；paper source 是 paper runtime / paper portfolio 本地证据，不是真实账户；simulated source 是 scenario replay / simulated exchange / backtest parity 本地证据，不是 broker fill、execution report 或 reconciliation；future-gated real source 只是门禁标签，不授权当前读取 real account、调用 signed endpoint、创建 listenKey 或运行 account snapshot runtime。

`MTP-133-EVIDENCE-INTERPRETATION-BOUNDARY`

MTP-133 evidence interpretation boundary 固定 account evidence 只能说明 evidence identity、source identity、freshness / stale 状态和 blocked reason；position evidence 只能说明 symbol / side / quantity / exposure 的 read-model-only interpretation；balance evidence 只能说明 paper / simulated / fixture balance interpretation。任何 evidence 都不得被解释为真实账户资产、broker position sync、buying power、margin、leverage 或 real PnL。

`MTP-133-L31-L32-HANDOFF-BOUNDARY`

MTP-133 只交付 L3.1 terminology / contract input。MTP-134 才能定义 account snapshot identity，MTP-135 才能定义 position snapshot identity，MTP-136 才能定义 balance snapshot identity，MTP-137 才能定义 deterministic fixture contract，MTP-138 才能定义 Workbench / Report / Events read-model-only evidence surface，MTP-139 才能做 validation / automation / stage audit input closeout。L3.2 Private Stream / Account Snapshot Simulation Gate 仍是 future gate；MTP-133 不创建 listenKey、不连接 private WebSocket、不运行 account snapshot runtime。

`MTP-133-FORBIDDEN-CAPABILITY-BASELINE`

MTP-133 的 forbidden baseline 必须覆盖 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL runtime、Live PRO Console、trading button、live command、order form、emergency stop / shutdown / restore executable action、Graphify update 和 Figma change。

`MTP-133-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record 中的 first executable candidate 只是候选，不构成执行授权。MTP-133 只有在 Linear live-read 中经 Parent Codex queue preflight 推进为唯一 active issue 后才可执行；MTP-133 完成后不得自动推进 MTP-134。

`MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-VALIDATION`

MTP-133 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 L3.1 read-model-only terminology / boundary，并且 `bash checks/run.sh` 通过。

`MTP-134-ACCOUNT-SNAPSHOT-IDENTITY`

MTP-134 account snapshot identity 只表示 account evidence 的稳定身份。`accountSnapshotId`、`accountEvidenceId`、`accountSourceIdentity`、`observedAt` 和 `sourceWatermark` 都是 Read Model / ViewModel 可引用的 evidence 字段，不是 account snapshot runtime、真实 account id、broker account object、account endpoint payload id 或可交易账户状态。Canonical identity example 为 `account-snapshot|fixture|mtp-134-local-account-evidence|1704067500|fresh`，只表达 deterministic string shape，不包含真实账户余额、margin、leverage、buying power、real PnL 或 broker account identifier。

`MTP-134-SOURCE-IDENTITY-FRESHNESS-EVIDENCE`

MTP-134 account source identity 只允许 `fixture`、`paper`、`simulated` 和 `future-gated-real`。fixture source 必须是 deterministic local fixture identity，不是真实 account payload；paper source 只能引用 paper runtime / paper portfolio 本地 evidence，不是真实账户；simulated source 只能引用 scenario replay / simulated exchange / backtest parity evidence，不是 broker fill、execution report 或 reconciliation；future-gated-real source 只是未来门禁标签，不包含 endpoint URL、API key、secret、listenKey、private stream cursor、broker account id 或 account payload。Freshness evidence 只表达 `observedAt`、`sourceWatermark`、`freshnessStatus`、`freshnessReason` 和 `sourceBoundary`。

`MTP-134-STALE-MISSING-BLOCKED-ACCOUNT-EVIDENCE`

MTP-134 stale / missing / blocked account evidence 只描述 evidence 可用性：`stale` 不触发网络刷新，`missing` 不触发 account endpoint / listenKey / broker fallback，`blocked` 表示 forbidden capability boundary 拒绝 real account endpoint、private WebSocket、broker adapter、secret storage 或 signed request。任何状态都不得升级为 recovery action、refresh command、private stream reconnect、broker sync、Live PRO Console action、trading button 或 live command。

`MTP-134-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`

MTP-134 account source identity 不能绕过 adapter capability matrix。`future-gated-real` source 不得写成 account endpoint path、signed request descriptor、listenKey lease 或 private WebSocket channel；fixture / paper / simulated source 不得写成 broker account payload、Runtime object、Adapter request 或 exchange private payload；App / UI 不得直接消费 adapter request、exchange payload、broker payload、secret config 或 Runtime object。

`MTP-134-ACCOUNT-SNAPSHOT-NOT-RUNTIME`

MTP-134 account snapshot identity 是 evidence identity，不是 runtime snapshot；它不授权 account snapshot runtime、account endpoint / listenKey、signed endpoint、signed request、private WebSocket runtime、secret storage、credential provider、broker / exchange execution adapter、real account balance、margin、leverage、buying power、real PnL、OMS、real order lifecycle、real submit / cancel / replace、Live PRO Console、trading button、live command 或 order form。

`MTP-134-ACCOUNT-SNAPSHOT-IDENTITY-VALIDATION`

MTP-134 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 account snapshot identity / source freshness evidence boundary，并且 `bash checks/run.sh` 通过。MTP-134 不新增 account fixture payload、不新增 Swift production code、不新增 App surface、不新增 Dashboard smoke handle。

`MTP-135-POSITION-SNAPSHOT-IDENTITY`

MTP-135 position snapshot identity 只表示 position evidence 的稳定身份。`positionSnapshotId`、`positionEvidenceId`、`positionSourceIdentity`、`symbol`、`side`、`quantity` 和 `scenarioVersion` 都是 read-model-only evidence 字段，不是 broker position id、exchange position id、margin account position、leverage position、live portfolio handle 或 live risk input。Canonical identity example 为 `position-snapshot|simulated|mtp-135-local-position-evidence|BTCUSDT|long|1704067500|simulated`，只表达 deterministic string shape，不包含 broker position id、real account id、margin、leverage、real PnL、execution report、broker fill 或 reconciliation data。

`MTP-135-POSITION-EXPOSURE-EVIDENCE`

MTP-135 exposure evidence 只表示 fixture / paper / simulated position 的 read-model-only interpretation。`symbol`、`side`、`quantity`、`exposureNotional` / `exposureQuoteValue` 和 `scenarioVersion` 只能说明本地证据，不等于 broker quantity、margin exposure、leverage exposure、broker risk input、order sizing input 或 real PnL source。Exposure evidence 不能驱动 live risk engine、OMS decision、trading command、emergency stop 或 broker sync。

`MTP-135-PAPER-SIMULATED-FUTURE-REAL-POSITION-ISOLATION`

MTP-135 paper exposure、simulated exposure 和 future-gated real position 必须隔离：paper exposure 可以引用 paper portfolio projection 但不得升级为 real position；simulated exposure 可以引用 simulated fill / simulated exchange / scenario replay evidence 但不得升级为 broker fill、execution report 或 broker position；future-gated real position 只是未来门禁标签，不包含 broker account id、position id、margin mode、leverage、private stream cursor 或 account endpoint payload。

`MTP-135-STALE-BLOCKED-SIMULATED-POSITION-EVIDENCE`

MTP-135 position evidence status 只描述 evidence 可用性：`simulated` 表示本地 simulated exchange / scenario replay / deterministic fixture evidence，`stale` 不触发 broker refresh，`blocked` 表示 forbidden broker position interpretation 拒绝 broker adapter、account endpoint、listenKey、private stream、real account position、margin、leverage 或 real PnL。任何状态都不得升级为 broker position sync、private stream reconnect、margin refresh、live risk engine input、trading button、live command 或 order form。

`MTP-135-FORBIDDEN-BROKER-POSITION-INTERPRETATION`

MTP-135 forbidden broker position interpretation 固定：position evidence 不是 broker position；paper portfolio projection 不是 real position；simulated fill / simulated exchange exposure 不是 broker fill、execution report 或 reconciliation；fixture position evidence 不是真实 account snapshot、broker portfolio、margin position 或 leverage position；App / UI 只能消费 Read Model / ViewModel evidence，不得展示 broker connect、account connect、Live PRO Console、trading button、live command 或 order form。

`MTP-135-POSITION-SNAPSHOT-IDENTITY-VALIDATION`

MTP-135 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 position snapshot identity / exposure evidence boundary，并且 `bash checks/run.sh` 通过。MTP-135 不新增 position fixture payload、不新增 Swift production code、不新增 App surface、不新增 Dashboard smoke handle。

`MTP-136-BALANCE-SNAPSHOT-IDENTITY`

MTP-136 balance snapshot identity 只表示 balance evidence 的稳定身份。`balanceSnapshotId`、`balanceEvidenceId`、`balanceSourceIdentity`、`balanceKind`、`observedAt` 和 `sourceWatermark` 都是 read-model-only evidence 字段，不是 real account balance id、broker cash statement id、buying power id、account endpoint payload id、ledger statement 或真实资金流水。Canonical identity example 为 `balance-snapshot|paper-cash|mtp-136-local-balance-evidence|1704067500|fresh`，只表达 deterministic string shape，不包含真实账户余额、broker cash statement、margin、leverage、buying power、real PnL、account endpoint payload 或 private stream update。

`MTP-136-PAPER-SIMULATED-FUTURE-REAL-BALANCE-TERMINOLOGY`

MTP-136 balance terminology 必须保留 source label：`paper cash` 是 paper runtime / paper portfolio 的本地 sandbox cash interpretation，不是真实账户 cash；`paper equity` 不是 broker equity、margin equity 或 buying power；`simulated balance` 不是 broker cash statement；`fixture balance` 不是真实 account payload；`future-gated real balance` 只是未来门禁标签，不包含 account endpoint、listenKey、private stream、broker cash statement 或真实资金字段。

`MTP-136-PAPER-VS-REAL-INTERPRETATION-BOUNDARY`

MTP-136 paper-vs-real boundary 固定：Paper account model 输出只能解释为 paper balance evidence，不是 live account balance；simulated exchange balance 只能解释为 simulated balance evidence，不是 broker cash、broker margin 或 real PnL；fixture balance 只能解释为 deterministic local evidence，不是真实账户资金；future-gated real balance 只能作为未来门禁标签，不表示当前已读取真实账户资金。Balance evidence 不得驱动 order sizing、buying power check、live risk engine、OMS decision、trading button、live command、emergency stop 或 broker sync。

`MTP-136-REAL-PNL-MARGIN-LEVERAGE-BUYING-POWER-FORBIDDEN`

MTP-136 forbidden baseline 必须覆盖 real PnL runtime、margin read、leverage read、buying power read、real account balance read、broker cash statement、signed endpoint、account endpoint、listenKey、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command 和 order form。这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成 current preview、fallback、behind flag、local beta 或 partial implementation。

`MTP-136-BALANCE-STALE-BLOCKED-EVIDENCE`

MTP-136 balance evidence status 只描述 evidence 可用性：`stale` 表示本地 paper / simulated / fixture balance evidence 超出 freshness expectation，但不触发 account endpoint refresh；`blocked` 表示 evidence 因 forbidden real balance interpretation 被拒绝，例如 real account balance、margin、leverage、buying power、real PnL、signed endpoint、account endpoint、listenKey、private stream 或 broker cash statement。Stale / blocked state 不得升级为 balance refresh command、private stream reconnect、broker sync、buying power check、Live PRO Console action、trading button、live command 或 order form。

`MTP-136-BALANCE-SNAPSHOT-IDENTITY-VALIDATION`

MTP-136 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 balance snapshot identity / paper-vs-real interpretation boundary，并且 `bash checks/run.sh` 通过。MTP-136 不新增 balance fixture payload、不新增 Swift production code、不新增 App surface、不新增 Dashboard smoke handle。

`MTP-137-DETERMINISTIC-FIXTURE-SHAPE`

MTP-137 deterministic fixture shape 固定三类本地证据：`account snapshot`、`position snapshot` 和 `balance snapshot`。每类记录只包含 snapshot identity、evidence identity、source identity、observedAt、sourceWatermark、freshnessStatus 和 read model field names；它不是真实 account endpoint payload、broker payload、private stream event、schema object、adapter request、Runtime object 或 account snapshot runtime handle。

`MTP-137-FIXTURE-CHECKSUM-FRESHNESS-SOURCE`

MTP-137 fixture identity 固定为 `fixture-v1`、`fixture:mtp-137-account-position-balance-read-model-only`、`1704067500`、`fixture-watermark:mtp-137:2024-01-01T00:05:00Z` 和 `fresh`。Checksum 只能证明本地 deterministic fixture parity，不代表真实账户 freshness、broker server timestamp、private stream cursor、listenKey keepalive 或 reconciliation watermark。

`MTP-137-FORBIDDEN-REAL-ACCOUNT-TESTS`

MTP-137 forbidden real account tests 必须覆盖 signed endpoint、account endpoint、listenKey、private WebSocket、secret read、broker adapter、real account read、real account payload、broker payload import、broker position sync、real PnL runtime、margin read、leverage read、account snapshot runtime 和 payload / schema / runtime object exposure。测试必须由本地 deterministic fixture 完成，不依赖真实网络、真实 Binance private API 或真实 credential。

`MTP-137-FIXTURE-TO-READ-MODEL-MAPPING-ISOLATION`

MTP-137 fixture-to-read-model mapping 只能输出稳定 Read Model 字段，不能包含 `payload`、`schema`、`runtime`、`endpoint`、`listenKey`、`secret`、`broker`、`margin`、`leverage` 或 `realPnL`。任何尝试把 account endpoint payload、broker payload、schema、Runtime object 或 private stream object 放入 mapping 的行为都必须被拒绝。

`MTP-137-REAL-ACCOUNT-PAYLOAD-ISOLATION`

MTP-137 real account payload isolation 规则要求 fixture 不提供 importer、parser、refresh、connect、sync、reconcile、submit、cancel、replace 或 live command。`future-gated` 只能表示后续门禁，不表示当前已连接真实账户。

`MTP-137-FIXTURE-FORBIDDEN-REAL-ACCOUNT-VALIDATION`

MTP-137 validation 必须证明 `AccountPositionBalanceReadModelOnlyFixtureContract`、`AccountPositionBalanceReadModelOnlyFixtureRecord`、`AccountPositionBalanceReadModelOnlyForbiddenCapability` 和 focused Core tests 均固定 fixture / forbidden real account boundary，并且 `bash checks/run.sh` 通过。MTP-137 不新增 App surface、不新增 Dashboard smoke handle；Workbench / Report / Events surface 仍归属 MTP-138。

`MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`

MTP-138 Workbench / Report / Events read-model-only surface 只把 MTP-137 deterministic fixture evidence 映射为 App 层 `AccountPositionBalanceReadModelOnlySurfaceReadModel` / `AccountPositionBalanceReadModelOnlySurfaceViewModel`。该 surface 的 `sourceIdentity`、`sourceWatermark`、snapshot id、evidence id、freshness、blocked / stale / simulated labels 都是 read-model-only evidence，不是真实账户状态、broker position、broker balance、private stream cursor 或 account endpoint payload。

`MTP-138-DASHBOARD-REPORT-EVENTS-EVIDENCE`

MTP-138 的 Workbench、Report 和 Event Timeline 只能展示同一组 APB read-model-only evidence：Workbench 展示 APB records / fixture / freshness / boundary；Report 展示 APB summary / components / evidence / forbidden flags；Events 展示 account snapshot、position snapshot 和 balance snapshot 三条 timeline item。Dashboard smoke 的 `accountPositionBalanceEvidence=<count>` 只是本地 acceptance handle，不代表真实账户连接或 live readiness。

`MTP-138-FORBIDDEN-UI-RUNTIME-SURFACE`

MTP-138 明确禁止 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command、order form、signed endpoint、account endpoint、listenKey、database schema、Runtime object、adapter request、account payload、broker state、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real account read、broker position sync、real PnL runtime、margin / leverage read、order-level command 和 live trading authorization。

`MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-VALIDATION`

MTP-138 validation 必须证明 App surface 只消费 ReadModel / ViewModel，Event Timeline 只链接 evidence id 与 validation anchor，Workbench / Report / Dashboard smoke 都不暴露 connect、credential、broker、runtime、schema、order 或 command surface。Focused tests 必须覆盖 `AccountPositionBalanceReadModelOnlySurfaceViewModel`、`PaperWorkflowEvidenceExplorerSection.accountPositionBalanceReadModelOnlySurface` 和 DashboardShell Workbench / Report APB details。

`MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT`

MTP-139 stage closeout 只把 `MTPRO Account / Position / Balance Read-model-only v1` 的 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence、Workbench / Report / Events APB surface evidence 和 Stage Code Audit input material 收口为 Parent Codex 审计输入。该 closeout 不是最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进 L3.2 / L3.3 / L3.4 / L4，也不启动下一阶段 `symphony-issue`。

`MTP-139-STAGE-AUDIT-INPUT-MATERIAL`

MTP-139 stage audit input material 落仓于 `docs/audit/inputs/mtpro-account-position-balance-read-model-only-v1-stage-audit-input.md`，用于汇总 MTP-133 至 MTP-138 的 issue / PR / merge / required check evidence、`TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY` evidence chain、forbidden capability evidence chain、Dashboard smoke `accountPositionBalanceEvidence=3` handle 和 Parent Codex final Stage Code Audit handoff checklist。

`MTP-139-NO-FINAL-STAGE-CODE-AUDIT`

MTP-139 不输出最终 Stage Code Audit Report，不创建 `docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md`，不写 Root Docs Refresh Gate，不把 L3.1 complete 写成 root docs 已发生事实。最终报告必须在 MTP-139 独立 PR、checks、merge 和 Linear `Done` 后，由 Parent Codex closure flow 单独执行。

`MTP-139-VALIDATION-EVIDENCE-CHAIN`

MTP-139 validation evidence chain 必须覆盖 MTP-133 terminology / boundary、MTP-134 account snapshot identity / freshness、MTP-135 position snapshot identity / exposure、MTP-136 balance snapshot identity / paper-vs-real boundary、MTP-137 deterministic fixture / forbidden real account tests、MTP-138 Workbench / Report / Events read-model-only surface，以及 MTP-139 自身的 stage audit input、automation readiness 和 matrix backfill。

`MTP-139-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-139 forbidden capability evidence chain 必须继续证明 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、account / position / balance runtime、real account read、broker position sync、real account balance、margin、leverage、real PnL runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、emergency stop / shutdown / restore executable action、Graphify update 和 Figma change 全部保持 forbidden / future gated。

`MTP-139-AUTOMATION-READINESS-STAGE-CLOSEOUT`

MTP-139 automation readiness stage closeout 要求 `checks/automation-readiness.sh` 机械检查 stage audit input、contract anchors、domain context anchors、validation plan anchors、Trading Validation Matrix backfill、latest verification summary、automation readiness doc anchor、MTP-133 至 MTP-138 source / test / surface anchors、PR #245 至 PR #250 evidence 和 Dashboard smoke `accountPositionBalanceEvidence=3` handle。

`MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT-VALIDATION`

MTP-139 validation 必须通过 `bash checks/automation-readiness.sh`、`git diff --check` 和 `bash checks/run.sh`。该 validation 只证明 L3.1 read-model-only evidence boundary 和 closeout input 完整，不授权真实账户读取、account snapshot runtime、private stream runtime、broker runtime、Live PRO Console、trading button、live command 或 order form。

## Private Stream / Account Snapshot Simulation Gate Terms

`MTP-140-PRIVATE-STREAM-SIMULATION-GATE-TERMINOLOGY`

以下术语由 MTP-140 定义为 `MTPRO Private Stream / Account Snapshot Simulation Gate v1` 的 L3.2 boundary language。它们只用于 terminology、contract、validation anchors 和后续 issue handoff，不授权当前 scope 实现 private stream runtime、account snapshot runtime、signed endpoint、account endpoint / listenKey、private WebSocket、broker adapter、Live PRO Console、trading button、live command 或 order form。

| 术语 | MTPRO 含义 | 避免混用 |
| --- | --- | --- |
| `private stream simulation gate` | 本地 deterministic fixture / simulated event 进入 L3.2 evidence chain 前的语义门禁 | 不等于 listenKey、private WebSocket、user data stream runtime 或 broker stream |
| `simulated private account event` | 本地 fixture 描述的账户相关事件语义 | 不等于真实 Binance user data event、account endpoint payload、execution report 或 broker account event |
| `private stream fixture source` | 只读 fixture source label，说明 event 来自本地模拟输入 | 不等于 exchange connection、broker connection、secret-backed session 或 private account stream |
| `fixture replay cursor` | 本地 fixture / scenario replay 可复现 cursor，用于说明 deterministic ordering | 不等于 live stream offset、listenKey lifecycle、production stream watermark 或 network checkpoint |
| `future real private stream label` | 未来真实 private stream 进入独立 Project 前的门禁标签 | 不等于当前已实现真实 private stream、secret storage、signed request 或 account stream |

`MTP-140-ACCOUNT-SNAPSHOT-SIMULATION-GATE-TERMINOLOGY`

MTP-140 account snapshot simulation gate 只定义本地模拟快照输入的术语边界：`account snapshot simulation gate` 是 simulation input 进入 evidence chain 前的语义门禁；`simulated account snapshot input` 是后续 MTP-142 才能深化的本地模拟快照输入 shape；`account snapshot fixture` 是 deterministic local fixture 中的 account snapshot evidence；`snapshot observedAt`、`source watermark`、`freshness / stale / blocked / missing evidence` 都是 fixture / replay 语义，不是真实 account endpoint response、broker account payload、Runtime object、schema、真实账户余额、margin、leverage、buying power 或 real PnL。

`MTP-140-FIXTURE-SIMULATED-FUTURE-REAL-PRIVATE-STREAM-BOUNDARY`

MTP-140 source semantics 只允许表达 fixture private stream source、simulated private stream source 和 future real private stream label。fixture source 是 deterministic local fixture，不是真实 private stream payload；simulated source 是 scenario replay / simulated input 的本地事件语义，不是 listenKey user data stream、execution report、broker fill 或 reconciliation；future real private stream label 只是门禁标签，不授权读取 secret、创建 listenKey、调用 signed endpoint、打开 private WebSocket 或运行 account snapshot runtime。

`MTP-140-L31-APB-L32-SIMULATION-GATE-RELATIONSHIP`

MTP-140 固定 L3.1 APB read-model-only evidence 与 L3.2 simulation gate 的关系：L3.2 可以复用 L3.1 APB 的 read-model-only vocabulary，例如 evidence id、source identity、freshness / stale / blocked / missing 状态和 fixture-to-read-model mapping boundary；L3.2 不得把 L3.1 APB evidence 反向升级为 account snapshot runtime、private stream runtime、real account read、broker position sync、real balance、margin、leverage 或 real PnL，也不得把 Workbench / Report / Events APB surface 写成 account connect、broker connect、Live PRO Console、trading button、live command 或 order form。

`MTP-140-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record、Linear Project issue order、next eligible candidate、Backlog issue、label、priority、assignee 或 estimate 都不构成执行授权。MTP-140 只有在 Linear live-read 中经 Parent Codex queue preflight 推进为唯一 active issue 后才可执行；MTP-140 完成后不得自动推进 MTP-141。

`MTP-140-FORBIDDEN-CAPABILITY-BASELINE`

MTP-140 的 forbidden baseline 必须覆盖 signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、account / position / balance runtime、real account read、broker position sync、real account balance、margin / leverage、real PnL runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、emergency stop / shutdown / restore executable action、Graphify update 和 Figma change。

`MTP-140-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE-VALIDATION`

MTP-140 validation 必须证明 contract、domain context、validation plan、trading validation matrix、latest summary、automation readiness doc 和 mechanical anchors 均固定 L3.2 terminology / boundary，并且 `bash checks/run.sh` 通过。MTP-140 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 MTP-146。

`MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`

MTP-141 定义 simulated private account event 的 source identity，只允许以下三类 source kind：`fixture private stream source`、`simulated private stream source` 和 `future real private stream label`。固定 source identity 分别为 `fixture:private-stream:mtp-141-local-private-account-event`、`simulated:private-stream:mtp-141-scenario-replay-private-account-event` 和 `future-gated:private-stream:label-only`。这些 source identity 只说明本地 fixture / simulated / future-gated label，不等于真实 Binance private stream、listenKey user data stream、signed request、account endpoint payload、broker stream 或 execution report。

`MTP-141-FIXTURE-SCENARIO-VERSION-CHECKSUM-FRESHNESS-LINKAGE`

MTP-141 source identity 必须绑定 `scenarioID=mtp-141-private-account-event-source-scenario`、`datasetVersion=dataset-v1`、`fixtureVersion=fixture-v1`、`fixtureReplayCursor=fixture-replay-cursor:mtp-141:private-account-event:001`、`sourceWatermark=fixture-watermark:mtp-141:2024-01-01T00:06:00Z`、`freshnessStatus=fresh` 和 deterministic checksum。该 checksum 只用于本地 source identity 可重复验证，不是 exchange checksum、listenKey checkpoint、broker watermark 或 production stream offset。

`MTP-141-FUTURE-REAL-PRIVATE-STREAM-LABEL-GATE`

MTP-141 允许 future real private stream 只作为 `future-gated:private-stream:label-only` 出现。该 label 说明未来真实 private stream 需要独立 Human decision、Project Definition、credential / endpoint / adapter / operations gates 和 forbidden capability audit；它不授权当前 issue 创建 listenKey、打开 private WebSocket、调用 signed/account endpoint、运行 private stream runtime 或 account snapshot runtime。

`MTP-141-FORBIDDEN-LIVE-STREAM-SOURCE-TESTS`

MTP-141 的 forbidden live stream source tests 必须拒绝 signed endpoint call、account endpoint call、listenKey creation、private WebSocket runtime、private stream runtime、account snapshot runtime、secret read、real account payload consumption、broker payload import、adapter request exposure、adapter capability matrix bypass、broker / exchange execution adapter connection、`LiveExecutionAdapter` implementation、OMS implementation 和 real order write。

`MTP-141-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`

MTP-141 source identity 不能绕过 adapter capability matrix。任何 source identity 都不能被写成 adapter request、private endpoint capability、broker connection、exchange execution adapter、`LiveExecutionAdapter`、OMS、account payload importer、Live PRO Console、trading button、live command 或 order form。

`MTP-141-SOURCE-IDENTITY-VALIDATION`

MTP-141 validation 必须证明 `SimulatedPrivateAccountEventSourceIdentityContract`、`SimulatedPrivateAccountEventSourceIdentityRecord`、focused XCTest、contract docs、domain context、validation matrix、validation plan、latest summary、automation readiness doc 和 mechanical anchors 均固定 source identity / forbidden source boundary，并且 `bash checks/run.sh` 通过。MTP-141 不实现 simulated account snapshot input contract，不新增 Dashboard smoke handle；MTP-142 才能深化 snapshot input shape。

`MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-SHAPE`

MTP-142 定义 `simulated account snapshot input` 的 Core deterministic value contract。`SimulatedAccountSnapshotInputContract` 和 `SimulatedAccountSnapshotInputRecord` 只保存 `snapshotID`、MTP-141 `sourceIdentity`、`observedAt`、`sourceWatermark`、`freshnessStatus`、`inputState`、`fixtureReplayCursor`、`deterministicReplayLinkage`、`readModelFields` 和 checksum；不保存 account endpoint payload、broker payload、Adapter request、Runtime object 或 SQLite / DuckDB schema。

`MTP-142-SNAPSHOT-ID-SOURCE-OBSERVEDAT-FRESHNESS-STATE`

MTP-142 snapshot input 固定 `snapshotID=simulated-account-snapshot|fixture|mtp-142-local-account-snapshot|1704067620|fresh`、`sourceIdentity=fixture:private-stream:mtp-141-local-private-account-event`、`observedAt=1704067620`、`sourceWatermark=fixture-watermark:mtp-142:2024-01-01T00:07:00Z`、`freshnessStatus=fresh` 和 `inputState=available fixture input`。`missing fixture input` 与 `blocked fixture input` 只是状态分类，不是真实账户健康状态、broker connectivity 或 live monitoring runtime。

`MTP-142-FIXTURE-VERSION-CHECKSUM-DETERMINISTIC-REPLAY-LINKAGE`

MTP-142 snapshot input 复用 `fixture-v1`，并通过 `sourceIdentityLinkage=MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`、`fixtureReplayCursor=fixture-replay-cursor:mtp-142:simulated-account-snapshot:001` 和 deterministic replay linkage 串回 MTP-141 source identity。Checksum 只用于本地 fixture input 的可重复验证，不是 exchange checksum、listenKey checkpoint、broker watermark 或 production stream offset。

`MTP-142-FIXTURE-TO-READ-MODEL-MAPPING-BOUNDARY`

MTP-142 fixture-to-read-model mapping 只允许输出 `accountSnapshotId`、`sourceIdentity`、`observedAt`、`sourceWatermark`、`freshnessStatus`、`inputState`、`fixtureReplayCursor`、`deterministicReplayLinkage` 和 `checksum`。Mapping 不得包含 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema、secret、listenKey、margin、leverage、real PnL、Live PRO Console、trading button、live command 或 order form。

`MTP-142-ACCOUNT-PAYLOAD-ISOLATION-TESTS`

MTP-142 account payload isolation tests 必须拒绝 signed endpoint call、account endpoint call、listenKey creation、private WebSocket runtime、private stream runtime、account snapshot runtime、real account / balance / margin / leverage / PnL reads、real account payload exposure、broker payload import、Adapter request exposure、Runtime object exposure、SQLite / DuckDB schema exposure、account endpoint payload exposure、fixture-to-read-model mapping bypass、broker / exchange execution adapter connection、`LiveExecutionAdapter`、OMS、real order write、Live PRO Console、trading button、live command 和 order form。

`MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-VALIDATION`

MTP-142 validation 必须证明 `SimulatedAccountSnapshotInputContract`、`SimulatedAccountSnapshotInputRecord`、focused XCTest、contract docs、domain context、validation matrix、validation plan、latest summary、automation readiness doc 和 mechanical anchors 均固定 snapshot input / payload isolation boundary，并且 `bash checks/run.sh` 通过。MTP-142 不实现 account snapshot runtime、private stream runtime、balance / position update fixture semantics、freshness runtime 或 Workbench / Report / Events surface。

`MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-SEMANTICS`

MTP-143 定义 `simulated account snapshot update fixture` 的 Core deterministic value contract。`SimulatedAccountSnapshotUpdateFixture` 和 `SimulatedAccountSnapshotUpdateFixtureRecord` 只保存 account snapshot event fixture、balance update fixture 和 position update fixture 的本地 update identity、fixture-only source semantics、MTP-141 source identity、MTP-142 snapshot input id、fixture version、deterministic summary linkage、read-model field names 和 checksum；不保存真实 account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema、execution report、broker fill、reconciliation 或真实账户状态。

`MTP-143-MTP141-MTP142-LINKAGE-CHECKSUM-BOUNDARY`

MTP-143 update fixture 必须串回 `MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY` 和 `MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-SHAPE`。固定 `snapshotInputID=simulated-account-snapshot|fixture|mtp-142-local-account-snapshot|1704067620|fresh`、`sourceIdentity=fixture:private-stream:mtp-141-local-private-account-event` 和 `fixtureVersion=fixture-v1`。Checksum 只证明三条 update fixture record 的 canonical preimage 可重复，不是 exchange checksum、listenKey checkpoint、private stream watermark 或 broker reconciliation marker。

`MTP-143-BALANCE-POSITION-UPDATE-READ-MODEL-ONLY-BOUNDARY`

MTP-143 的 balance update fixture 和 position update fixture 只能作为 read-model-only 字段命名与 deterministic summary evidence。允许字段只包括 `accountSnapshotUpdateFixtureId`、`balanceUpdateFixtureId`、`positionUpdateFixtureId`、`sourceIdentity`、`snapshotInputId`、`fixtureVersion`、`fixtureOnlySourceSemantics`、`deterministicSummaryLinkage` 和 `checksum`；不得升级为真实余额、真实持仓、broker position sync、margin、leverage、buying power、real PnL、account endpoint payload 或 broker portfolio。

`MTP-143-UPDATE-FIXTURE-INTERPRETATION-ISOLATION-TESTS`

MTP-143 update fixture interpretation isolation tests 必须拒绝 signed endpoint call、account endpoint call、listenKey creation、private WebSocket runtime、private stream runtime、account snapshot runtime、real account read / update、broker position sync、real balance / margin / leverage / real PnL read、broker / exchange execution adapter connection、`LiveExecutionAdapter`、execution report、broker fill、reconciliation、OMS、real order lifecycle、Live PRO Console、trading button、live command 和 order form。

`MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-VALIDATION`

MTP-143 validation 必须证明 `SimulatedAccountSnapshotUpdateFixture`、`SimulatedAccountSnapshotUpdateFixtureRecord`、focused XCTest、contract docs、domain context、validation matrix、validation plan、latest summary、automation readiness doc 和 mechanical anchors 均固定 fixture-only update semantics / read-model-only boundary，并且 `bash checks/run.sh` 通过。MTP-143 不实现 private stream runtime、account snapshot runtime、freshness runtime 或 Workbench / Report / Events surface。

`MTP-144-FRESHNESS-STALE-BLOCKED-MISSING-EVIDENCE`

MTP-144 定义 `simulated account snapshot freshness evidence` 的 Core deterministic value contract。`SimulatedAccountSnapshotFreshnessEvidenceContract` 和 `SimulatedAccountSnapshotFreshnessEvidenceItem` 只保存 fresh / stale / blocked / missing 四种本地 fixture evidence、ageSeconds、staleAfterSeconds、inputState、boundary reason、MTP-141 source identity、MTP-142 snapshot input id、MTP-143 update fixture checksum 和 read-model-only fields；不保存真实 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。

`MTP-144-MTP141-MTP142-MTP143-FRESHNESS-CHECKSUM-BOUNDARY`

MTP-144 freshness evidence 必须串回 `MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`、`MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-SHAPE` 和 `SimulatedAccountSnapshotUpdateFixture.requiredChecksum`。Checksum 只证明四条 freshness evidence item 的 canonical preimage 可重复，不是 exchange checksum、listenKey checkpoint、private stream watermark、broker reconciliation marker 或 production health status。

`MTP-144-FORBIDDEN-ENDPOINT-RUNTIME-TESTS`

MTP-144 forbidden endpoint/runtime tests 必须拒绝 signed endpoint call、account endpoint call、listenKey creation / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、broker / exchange execution adapter connection、`LiveExecutionAdapter`、OMS implementation 和 real order write。

`MTP-144-PAYLOAD-SCHEMA-RUNTIME-NON-EXPOSURE-TESTS`

MTP-144 payload/schema/runtime non-exposure tests 必须拒绝 account endpoint payload、real account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 和 broker state 出现在 read-model-only freshness evidence 中。

`MTP-144-SIMULATED-ACCOUNT-SNAPSHOT-FRESHNESS-EVIDENCE-VALIDATION`

MTP-144 validation 必须证明 `SimulatedAccountSnapshotFreshnessEvidenceContract`、`SimulatedAccountSnapshotFreshnessEvidenceItem`、focused XCTest、contract docs、domain context、validation matrix、validation plan、latest summary、automation readiness doc 和 mechanical anchors 均固定 freshness evidence / forbidden endpoint boundary，并且 `bash checks/run.sh` 通过。MTP-144 不实现 private stream runtime、account snapshot runtime、freshness runtime 或 Workbench / Report / Events surface。

## Strategy / Trader Readiness Surface Terms

`MTP-160-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`

`strategy readiness evidence surface` 指 MTP-160 在 Workbench、Report 和 Events 中展示 MTP-154 至 MTP-159 evidence chain 的 read-model-only surface。它只说明 Strategy / Trader Instance readiness terminology、lifecycle / identity、quoter / hedger role taxonomy、account / portfolio / risk input、paper/live-neutral proposal isolation 和 forbidden capability tests 已有可追溯证据；不表示 Strategy Console、Live PRO Console、trading button、live command、order form、Strategy runtime、Trader runtime、Execution Client、broker adapter、`LiveExecutionAdapter`、OMS、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime 或真实交易能力。

`MTP-160-STRATEGY-READINESS-SOURCE-CHAIN`

`strategy readiness surface source chain` 指 `StrategyTraderReadinessEvidenceSurfaceReadModel`、`StrategyTraderReadinessEvidenceSurfaceViewModel`、`ReportReadModel.strategyTraderReadinessEvidenceSurface`、`PaperWorkflowEvidenceExplorerReadModel.strategyTraderReadinessEvidenceSurface` 和 `DashboardShellWorkbenchSnapshot.strategyTraderReadinessEvidenceSurfaceMetrics` 组成的 App 层只读链路。该链路只能消费 deterministic evidence anchors 和 source anchors，不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account endpoint payload、broker payload、broker state、credential、secret、API key、listenKey、real account、real position、real balance、margin、leverage 或 real PnL。

`MTP-160-NO-COMMAND-RUNTIME-SCHEMA-ACCOUNT-BOUNDARY`

`strategy readiness boundary evidence` 指 MTP-160 surface 必须持续输出的 negative capability evidence：no command surface、no order-level command、no Strategy runtime、no Trader runtime、no Execution runtime、no broker connection、no broker adapter、no `LiveExecutionAdapter`、no OMS、no signed endpoint call、no account endpoint call、no listenKey create / keepalive、no private WebSocket runtime、no private stream runtime、no account snapshot runtime、no Runtime object exposure、no Adapter request exposure、no schema exposure、no account / broker payload exposure、no real account read、no live trading authorization 和 no trading execution authorization。

`MTP-160-STRATEGY-TRADER-READINESS-SURFACE-VALIDATION`

MTP-160 validation 必须证明 Workbench / Report / Events 只展示 MTP-154 至 MTP-159 的 readiness / forbidden capability evidence，Event Timeline 只新增六条 strategy readiness read-model-only items，Dashboard smoke 只新增 `strategyTraderReadinessSurface=6`，并且 `swift test`、`bash checks/automation-readiness.sh`、`git diff --check` 和 `bash checks/run.sh` 均通过。MTP-160 不新增或修改 Core semantics，不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

`MTP-161-STRATEGY-TRADER-READINESS-STAGE-CLOSEOUT`

MTP-161 stage closeout 只表示 `MTPRO Strategy / Trader Instance Readiness v1` 的 validation matrix、automation readiness、forbidden capability evidence chain、read-model-only boundary evidence 和 stage audit input material 已被收口。它不表示最终 Stage Code Audit Report 已输出，不表示 Linear Project `Completed` 已设置，不授权下一 Project planning / execution，也不授权 Strategy runtime、Trader runtime、Execution Client、broker command、OMS、Strategy Console、Live PRO Console、trading button、live command 或 order form。

`MTP-161-STAGE-AUDIT-INPUT-MATERIAL`

MTP-161 stage audit input material 指 `docs/audit/inputs/mtpro-strategy-trader-instance-readiness-v1-stage-audit-input.md`。该材料只为 Parent Codex 后续 Stage Code Audit Report 提供输入，必须包含 MTP-154 至 MTP-160 issue / PR / merge / checks evidence、`TVM-STRATEGY-TRADER-INSTANCE-READINESS` evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness evidence、Root Docs Delta input 和 handoff checklist。

`MTP-161-NO-FINAL-STAGE-CODE-AUDIT`

MTP-161 不输出最终 Stage Code Audit Report。最终 Stage Code Audit Report 必须等 MTP-154 至 MTP-161 全部 Linear `Done`，且 Linear Project status 为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出。

`MTP-161-VALIDATION-EVIDENCE-CHAIN`

MTP-161 validation evidence chain 必须串联 terminology / boundary、lifecycle / identity、role taxonomy、read-model input、proposal isolation、forbidden capability tests、Workbench / Report / Events surface 和 stage closeout，不得把任何 evidence 解读为 runtime readiness、broker readiness、live trading readiness 或 trading authorization。

`MTP-161-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-161 forbidden capability evidence chain 继续固定 no Strategy runtime、no Trader runtime、no lifecycle runtime、no quoter / hedger runtime、no Execution Client、no broker command、no broker adapter、no `LiveExecutionAdapter`、no OMS、no real order lifecycle、no signed endpoint、no account endpoint / listenKey、no private stream runtime、no account snapshot runtime、no real account read、no Strategy Console、no Live PRO Console、no trading button、no live command 和 no order form。

`MTP-161-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`

MTP-161 read-model-only boundary evidence 指 Strategy / Trader readiness evidence 仍只来自 contract anchors、deterministic evidence 和 App read-model-only surface，不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account endpoint payload、broker payload、broker state、credential、secret、API key、listenKey、real account、real position、real balance、margin、leverage 或 real PnL。

`MTP-161-AUTOMATION-READINESS-STAGE-CLOSEOUT`

MTP-161 automation readiness closeout 必须由 `checks/automation-readiness.sh` 机械检查 stage audit input、contract、domain context、validation matrix、validation plan、latest verification summary、automation readiness doc、PR evidence、Dashboard smoke handle `strategyTraderReadinessSurface=6` 和 forbidden capability strings。

`MTP-161-STAGE-CLOSEOUT-VALIDATION`

MTP-161 validation 必须通过 `bash checks/automation-readiness.sh`、`git diff --check` 和 `bash checks/run.sh`，并确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

`MTP-161-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

MTP-161 不运行 Graphify，不修改 Figma，不创建 Linear Project / Issue，不修改 issue body，不输出最终 Stage Code Audit Report，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## Engine Module Boundary Consolidation Closeout Terms

`MTP-182-ENGINE-MODULE-BOUNDARY-STAGE-CLOSEOUT`

MTP-182 stage closeout 只表示 `MTPRO Engine Module Boundary Consolidation v1` 的 validation matrix、automation readiness 和 stage audit input material 已被收口。它不表示最终 Stage Code Audit Report 已输出，不表示 Linear Project `Completed` 已设置，不授权 L4 Project planning / execution，也不授权 live runtime、broker path、ExecutionClient implementation、OMS、Live PRO Console、trading button、live command 或 order form。

`MTP-182-STAGE-AUDIT-INPUT-MATERIAL`

MTP-182 stage audit input material 指 `docs/audit/inputs/mtpro-engine-module-boundary-consolidation-v1-stage-audit-input.md`。该材料只为 Parent Codex 后续 Stage Code Audit Report 提供输入，必须包含 MTP-162 至 MTP-181 issue / PR / merge / checks evidence、`TVM-ARCHITECTURE-MODULE-BOUNDARY` closeout、automation readiness evidence、forbidden implementation audit、unresolved future gates、Root Docs Delta input 和 handoff checklist。

`MTP-182-NO-FINAL-STAGE-CODE-AUDIT`

MTP-182 不输出最终 Stage Code Audit Report。最终 Stage Code Audit Report 必须等 MTP-162 至 MTP-182 全部 Linear `Done`，且 Linear Project status 为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出。

`MTP-182-VALIDATION-MATRIX-CLOSEOUT`

MTP-182 validation matrix closeout 必须证明 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 已覆盖 terminology、fixed layout、dependency direction、MessageBus、Cache、Database、DataClient、DataEngine、adapter capability guard、Strategies、Trader、Account / Portfolio、RiskEngine、ExecutionEngine、ExecutionClient / OMS、broker / real order guard、Workbench read-model-only boundary、Future Live PRO Console split 和 L4 planning input material；该 matrix 不授权 L4 execution。

`MTP-182-AUTOMATION-READINESS-CLOSEOUT`

MTP-182 automation readiness closeout 必须由 `checks/automation-readiness.sh` 机械检查 stage audit input、module-boundary docs、domain context、validation matrix、validation plan、latest verification summary、automation readiness doc、PR evidence 和 no final Stage Code Audit boundary。

`MTP-182-FORBIDDEN-IMPLEMENTATION-AUDIT`

MTP-182 forbidden implementation audit 继续固定 no Strategy runtime、no Trader runtime、no Live runtime、no ExecutionClient implementation、no OMS implementation、no broker adapter、no `LiveExecutionAdapter`、no real order lifecycle、no signed endpoint、no account endpoint / listenKey、no private stream runtime、no account snapshot runtime、no Live PRO Console、no trading button、no live command 和 no order form。

`MTP-182-UNRESOLVED-FUTURE-GATES`

MTP-182 unresolved future gates 指 L4 Project Definition gate、signed / account gate、broker / execution gate、product surface gate、operations gate 和 validation gate 仍未打开。后续必须由 Human + `@001 / PLN` 独立规划，不得把 Engine Module Boundary Consolidation evidence 解读为 execution authorization。

`MTP-182-STAGE-CLOSEOUT-VALIDATION`

MTP-182 validation 必须通过 `bash checks/automation-readiness.sh`、`git diff --check` 和 `bash checks/run.sh`，并确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

`MTP-182-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`

MTP-182 不运行 Graphify，不修改 Figma，不创建 L4 Linear Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR` 或 Symphony，不设置 Linear Project `Completed`，不输出最终 Stage Code Audit Report，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## Target Module Physical Layout / Source Migration Terms

`MTP-183-TARGET-PHYSICAL-LAYOUT-CONTRACT`

`target physical layout` 指 `MTPRO Target Module Physical Layout / Source Migration v1` 后续 source migration 允许落入的固定目录结构。它复用 MTP-163 的 target source layout，不表示 MTP-183 已移动任何 source file。

MTP-191 后续将 concrete strategy landing path 修正为 `Sources/Trader/Strategies/<strategy>/`。MTP-183 中的 `Sources/Strategies/<strategy>/` 保留为 historical migration contract evidence，不再作为 MTP-191 之后的 canonical path。

`MTP-183-CURRENT-SWIFTPM-SNAPSHOT`

`current SwiftPM snapshot` 指当前 `Package.swift` 仍保留 `Core / Adapters / Persistence / Runtime / App / Dashboard` coarse targets。该 snapshot 是迁移输入，不是最终架构名。

`MTP-183-SWIFTPM-MIGRATION-CONTRACT`

`SwiftPM migration contract` 指后续逐步从 directory / namespace move、compatibility shell、low-level target split 到 engine / surface target split 的规则。任何 `Package.swift` target graph change 都必须由后续 Linear issue 明确授权，不能由 planning record 或 MTP-183 自动授权。

`MTP-183-OLD-TO-NEW-SOURCE-MAP`

`old-to-new source map` 指 `Core / Adapters / Persistence / Runtime / App / Dashboard / CSQLite` 到 `DomainModel / DataClient / DataEngine / MessageBus / Cache / Database / Strategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench / Dashboard` 的迁移映射。旧路径只能是 migration source / compatibility shell，不是新增能力落点。

`MTP-183-COMPATIBILITY-SHELL-POLICY`

`compatibility shell` 是迁移期间保留 buildability 的旧路径薄壳，只能 forwarding import、typealias、deprecated wrapper 或 minimal adapter glue。它不能新增业务语义，不能绕过 import direction，不能长期保留为最终架构。

`MTP-183-IMPORT-DIRECTION-GUARD`

`import direction guard` 指后续 source migration 必须阻断 `Strategies -> ExecutionClient`、`Trader -> ExecutionClient`、`Workbench -> Runtime object / Adapter request / Database schema`、`DataClient -> signed/account/listenKey/private runtime`、`RiskEngine -> broker / ExecutionClient`、`Portfolio -> broker account state`、`ExecutionEngine -> current OMS / broker adapter` 和 `Dashboard -> broker command / live command / order form`。

`MTP-183-VALIDATION-ANCHORS`

MTP-183 validation anchors 只证明 migration contract、target layout、old-to-new map、compatibility shell policy、import guard 和 required validation 已落仓。它们不授权 MTP-184 之后的 source movement 自动发生。

`MTP-183-NO-SOURCE-MOVE-PACKAGE-BUSINESS-CODE`

MTP-183 不移动 `Sources` 文件，不修改 `Package.swift` target graph，不写业务代码，不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、real order lifecycle、Live PRO Console、trading button、live command 或 order form。

`MTP-184-DOMAINMODEL-MESSAGEBUS-PHYSICAL-MIGRATION`

`DomainModel / MessageBus physical migration` 指把 MTP-183 已映射的 pure domain value objects、market data models、Core baseline、domain events、commands / queries、append-only event log 和 paper runtime bus routing 文件从 `Sources/Core/` 迁入 `Sources/DomainModel/` 与 `Sources/MessageBus/`。MTP-184 只移动这些低层 spine 文件，不迁移后续 engine、adapter、UI 或 live boundary 文件。

`MTP-184-CORE-TARGET-COMPATIBILITY-ENVELOPE`

`Core target compatibility envelope` 指迁移期间仍由 `Core` target 编译 `Sources/Core`、`Sources/DomainModel` 和 `Sources/MessageBus`，让下游 target 继续使用既有 `import Core`。它不是新的 target graph，不代表 `DomainModel` 或 `MessageBus` 已成为独立 SwiftPM target。

`MTP-184-NO-BEHAVIOR-CHANGE-IMPORT-BOUNDARY`

`no behavior change import boundary` 指 MTP-184 不改 public type、event envelope、MessageBus replay、paper runtime bus routing 或调用语义；验证重点是 buildability、CoreTests、full checks 和 no unauthorized runtime capability。

`MTP-184-FORBIDDEN-HIGHER-MODULE-MIGRATION`

MTP-184 不迁移 DataClient、DataEngine、Cache、Database、Strategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard，不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker / live / order capability、signed endpoint、account endpoint / listenKey、private WebSocket runtime、Live PRO Console、trading button、live command 或 order form。

`MTP-185-DATACLIENT-DATAENGINE-PHYSICAL-MIGRATION`

`DataClient / DataEngine physical migration` 指把 Binance public read-only client 和本地 replay operations evidence 从旧 `Sources/Adapters/` 迁入 `Sources/DataClient/Binance/PublicMarketData/`，把 local data catalog、scenario replay、scenario fixture、replay evidence、deterministic matching 和 data quality / report input 从旧 `Sources/Core/` 迁入 `Sources/DataEngine/ScenarioReplay/` 与 `Sources/DataEngine/DataQuality/`，并把 public market data ingest workflow 迁入 `Sources/DataEngine/Ingest/`。MTP-185 只做 physical source migration 和兼容 target 配置，不新增真实 DataClient / DataEngine SwiftPM target。

`MTP-185-DATACLIENT-COMPATIBILITY-ENVELOPE`

MTP-185 的 `DataClient compatibility envelope` 指现有 `Adapters` target 继续编译 `Sources/DataClient/Binance/PublicMarketData/`，让既有 tests 和 downstream target 仍使用 `import Adapters`。该名称是迁移期兼容壳，不是最终架构名；后续 target split 必须由独立 Linear issue 授权。

`MTP-185-DATAENGINE-COMPATIBILITY-ENVELOPE`

MTP-185 的 `DataEngine compatibility envelope` 指 `Core` target 继续编译 `Sources/DataEngine/ScenarioReplay/` 和 `Sources/DataEngine/DataQuality/`，`Runtime` target 继续编译 `Sources/DataEngine/Ingest/`。这只保持 buildability，不授权 DataEngine 直连 UI、Trader、Strategy、RiskEngine、ExecutionEngine、signed/account endpoint、private stream 或 broker path。

`MTP-185-PUBLIC-READ-ONLY-GUARD`

MTP-185 public read-only guard 固定 Binance DataClient 只能读取 public market data、mock transport fixture、local batch replay metadata、freshness 和 deterministic parity evidence。它不保存 API key，不签名，不调用 account endpoint，不创建 listenKey，不实现 private WebSocket runtime，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、真实订单生命周期或交易命令。

`MTP-185-DATAENGINE-BOUNDARY-GUARD`

MTP-185 DataEngine boundary guard 固定 scenario replay / data quality / ingest 只能在 deterministic local validation 内消费 public read-only output、fixture identity、MessageBus / event log / projection compatibility evidence 和 read-model input。它不实现完整 streaming DataEngine runtime，不绕过 MessageBus / Cache / Database / ReadModel / ViewModel，不触发 network refresh、listenKey keepalive、broker sync、private stream reconnect、live command 或 executable order path。

`MTP-186-CACHE-DATABASE-PHYSICAL-MIGRATION`

`Cache / Database physical migration` 指把 runtime-derived market data cache 和 order book read model 从旧 `Sources/Core/` 迁入 `Sources/Cache/MarketData/`，把 SQLite / DuckDB projection adapters 和 CSQLite shim 从旧 `Sources/Persistence/`、`Sources/CSQLite/` 迁入 `Sources/Database/Projections/SQLite/`、`Sources/Database/Projections/DuckDB/` 与 `Sources/Database/Projections/SQLite/CSQLite/`，并把 replay projection consistency evidence 迁入 `Sources/Database/ReplayProjection/`。MTP-186 只做 physical source migration 和兼容 target 配置，不新增真实 Cache / Database SwiftPM target。

`MTP-186-CACHE-COMPATIBILITY-ENVELOPE`

MTP-186 的 `Cache compatibility envelope` 指现有 `Core` target 继续编译 `Sources/Cache/MarketData/`，让既有 tests 和 downstream target 仍使用 `import Core`。该名称是迁移期兼容壳，不是最终架构名；后续 target split 必须由独立 Linear issue 授权。

`MTP-186-DATABASE-COMPATIBILITY-ENVELOPE`

MTP-186 的 `Database compatibility envelope` 指现有 `Persistence` target 继续编译 `Sources/Database/Projections/SQLite/` 和 `Sources/Database/Projections/DuckDB/`，`Runtime` target 继续编译 `Sources/Database/ReplayProjection/`。这只保持 buildability，不授权 Database 直连 UI、Trader、Strategy、RiskEngine、ExecutionEngine、signed/account endpoint、private stream、broker path 或 live command path。

`MTP-186-CSQLITE-SYSTEM-LIBRARY-BOUNDARY`

MTP-186 的 `CSQLite system library boundary` 指 CSQLite shim 归属 `Sources/Database/Projections/SQLite/CSQLite/`，仍只服务 SQLite projection adapter 编译。该边界不新增 schema migration runtime，不改变 SQLite projection behavior，不向 UI 或 higher modules 暴露 C shim。

`MTP-186-SCHEMA-NON-EXPOSURE-GUARD`

MTP-186 schema non-exposure guard 固定 Database projection code 只能提供 local deterministic facts / snapshots / projection evidence。它不暴露 SQLite / DuckDB schema、Runtime object、Adapter request、broker state、account endpoint payload、credential、secret、API key 或 listenKey，不读取真实账户，不同步 broker position，不触发 signed/account/listenKey/private stream、broker sync、live command 或 executable order path。

`MTP-187-STRATEGIES-TRADER-PORTFOLIO-PHYSICAL-MIGRATION`

`Strategies / Trader / Portfolio physical migration` 指 MTP-187 把 EMA strategy lifecycle、strategy signal、paper proposal 和 order-book research strategy 从旧 `Sources/Core/` 迁入当时的 `Sources/Strategies/EMA/` 与 `Sources/Strategies/OrderBookImbalance/`，把 proposal-to-risk binding 迁入 `Sources/Trader/StrategyBindings/`，并把 paper account / portfolio projection、portfolio projection update 和 simulated exchange portfolio projection parity 迁入 `Sources/Portfolio/`。MTP-193 后 EMA current source path 是 `Sources/Trader/Strategies/EMA/`；MTP-194 后 OrderBookImbalance current source path 是 `Sources/Trader/Strategies/OrderBookImbalance/`；MTP-187 只做 physical source migration 和兼容 target 配置，不新增真实 Strategies / Trader / Portfolio SwiftPM target。

MTP-191 后续把 MTP-187 的 strategy physical locations 标记为 compatibility / superseded path；MTP-193 已把 EMA concrete strategy files 移到 `Sources/Trader/Strategies/EMA/`，MTP-194 已把 OrderBookImbalance concrete strategy files 移到 `Sources/Trader/Strategies/OrderBookImbalance/`。

`MTP-187-STRATEGIES-COMPATIBILITY-ENVELOPE`

MTP-187 的 `Strategies compatibility envelope` 指现有 `Core` target 继续编译 strategy source roots。MTP-194 后该 envelope 的 strategy roots 是 `Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Strategies/OrderBookImbalance/`。这只保持 buildability，不授权 Strategy runtime、scheduler、live quoter / hedger、direct Strategy -> ExecutionClient path、broker command 或 executable order command。

`MTP-187-TRADER-COMPATIBILITY-ENVELOPE`

MTP-187 的 `Trader compatibility envelope` 指现有 `Core` target 继续编译 `Sources/Trader/StrategyBindings/`。Trader 在该 issue 中只表示 deterministic local strategy / risk / portfolio coordination evidence，不表示 live coordinator、broker gateway、OMS gateway、ExecutionClient gateway、account session runtime 或 private stream coordinator。

`MTP-187-PORTFOLIO-COMPATIBILITY-ENVELOPE`

MTP-187 的 `Portfolio compatibility envelope` 指现有 `Core` target 继续编译 `Sources/Portfolio/`。Portfolio 当前只持有 paper / simulated / read-model financial state，不读取 broker account state、account endpoint payload、real balance、real position、margin、leverage 或 real PnL。

`MTP-187-NO-DIRECT-EXECUTION-GUARD`

MTP-187 no-direct-execution guard 固定 strategy proposal、Trader binding 和 Portfolio projection 不能升级为 executable order command、ExecutionClient request、OMS order、broker order、order form payload、live command、position command 或 trading button。任何真实交易、broker、signed/account endpoint、listenKey、private stream、execution report、broker fill 和 reconciliation 都保持 future-gated / forbidden。

`MTP-188-RISK-EXECUTION-PHYSICAL-MIGRATION`

`RiskEngine / ExecutionEngine / ExecutionClient physical migration` 指把 paper pre-trade risk 迁入 `Sources/RiskEngine/PreTrade/`，把 live risk gate 与 incident / stop blocked evidence 迁入 `Sources/RiskEngine/LiveGate/`，把 paper lifecycle / paper order / paper event log 迁入 `Sources/ExecutionEngine/PaperLifecycle/`，把 simulated fill / shared order semantics / market-limit execution / fee-slippage parity / execution costs 迁入 `Sources/ExecutionEngine/SimulatedExchange/`，并把 OMSFutureGate、ExecutionClient FutureGate 和 BrokerCapabilityMatrix 放入对应 target source directories。MTP-188 只做 physical source migration 和兼容 target 配置，不新增真实 RiskEngine / ExecutionEngine / ExecutionClient SwiftPM target。

`MTP-188-RISKENGINE-COMPATIBILITY-ENVELOPE`

MTP-188 的 `RiskEngine compatibility envelope` 指现有 `Core` target 继续编译 `Sources/RiskEngine/PreTrade/` 和 `Sources/RiskEngine/LiveGate/`。这只保持 buildability，不授权 live risk runtime、real pre-trade allow / reject runtime、circuit breaker runtime、stop trading command、emergency stop、broker state read 或 ExecutionClient call。

`MTP-188-EXECUTIONENGINE-COMPATIBILITY-ENVELOPE`

MTP-188 的 `ExecutionEngine compatibility envelope` 指现有 `Core` target 继续编译 `Sources/ExecutionEngine/PaperLifecycle/`、`Sources/ExecutionEngine/SimulatedExchange/` 和 `Sources/ExecutionEngine/OMSFutureGate/`。ExecutionEngine 当前只表示 paper / simulated lifecycle evidence，不表示 current OMS、order router、broker adapter、real order state machine、execution report ingestion、broker fill ingestion 或 reconciliation runtime。

`MTP-188-EXECUTIONCLIENT-FUTURE-GATE-ENVELOPE`

MTP-188 的 `ExecutionClient future gate envelope` 指 `Sources/ExecutionClient/FutureGate/` 和 `Sources/ExecutionClient/BrokerCapabilityMatrix/` 只保存 future-gated taxonomy / boundary evidence。BrokerCapabilityMatrix 可以列出 future venue capability、signed endpoint future gate、account endpoint future gate、execution report capability、broker fill capability 和 reconciliation capability，但不得升级为 capability discovery runtime、credential check、network probe、private endpoint test、API key input、secret storage、credential provider 或 keychain storage。

`MTP-188-BROKER-REAL-ORDER-FORBIDDEN-GUARD`

MTP-188 broker / real order forbidden guard 固定 RiskEngine、ExecutionEngine 和 ExecutionClient 不能形成真实执行路径：RiskEngine 不调用 broker / ExecutionClient，ExecutionEngine 不调用 current OMS / broker adapter / ExecutionClient request，ExecutionClient 不实现 signed request、account endpoint、order submit / cancel / replace、execution report parser、broker fill parser 或 reconciliation runtime。

`MTP-189-WORKBENCH-DASHBOARD-PHYSICAL-MIGRATION`

`Workbench / Dashboard physical migration` 指把 Workbench read model / report / dashboard / events / future Live PRO Console boundary source 从旧 `Sources/App/` 迁入 `Sources/Workbench/`，并把 macOS dashboard shell source 放在 `Sources/Dashboard/`。MTP-189 只做 physical source migration 和兼容 target 配置，不新增真实 Workbench SwiftPM target，不实现 Live PRO Console 或 command-capable UI。

`MTP-189-APP-COMPATIBILITY-ENVELOPE`

MTP-189 的 `App compatibility envelope` 指现有 `App` target 继续编译 `Sources/Workbench/ReadModels/`、`Sources/Workbench/Report/`、`Sources/Workbench/Dashboard/`、`Sources/Workbench/Events/`、`Sources/Workbench/FutureLiveProConsole/` 和 `Sources/Dashboard/DashboardShell.swift`。这只保持 buildability，不授权 Workbench runtime、Dashboard runtime inspector、broker connect UI、account connect UI 或 final target graph split。

`MTP-189-DASHBOARD-SHELL-BOUNDARY`

Dashboard shell 只能消费 `DashboardViewModel` / `DashboardShellSnapshot`。它不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload 或 broker state，不提供 Live PRO Console、trading button、live command、order form、broker connect UI、account connect UI 或 executable order path。

`MTP-189-WORKBENCH-READMODEL-ONLY-GUARD`

MTP-189 后 `Sources/Workbench/FutureLiveProConsole/` 只是 future-gated boundary label 的 physical location。它不是 current Live PRO Console implementation，不包含 command controls、emergency stop、shutdown、restore、ExecutionClient request UI、OMS command UI 或 production operations command。

`MTP-190-TARGET-MODULE-SOURCE-MIGRATION-STAGE-CLOSEOUT`

`Target Module Source Migration Stage Closeout` 指 MTP-190 对 MTP-183 至 MTP-189 的 physical source migration evidence 做 validation / readiness / audit-input 收口。它不是最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不授权 L4 Project / Issue、SwiftPM target graph split 或下一阶段 execution。

`MTP-190-STAGE-AUDIT-INPUT-MATERIAL`

MTP-190 stage audit input material 固定在 `docs/audit/inputs/mtpro-target-module-physical-layout-source-migration-v1-stage-audit-input.md`。该材料为 Parent Codex 后续 Stage Code Audit Report 提供 PR evidence、source migration closeout、validation matrix closeout、automation readiness closeout、remaining compatibility shell audit、forbidden implementation audit、unresolved future gates 和 Root Docs Delta input。

`MTP-190-VALIDATION-MATRIX-CLOSEOUT`

MTP-190 validation matrix closeout 只证明 `TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION` 已覆盖 contract-first migration、DomainModel / MessageBus、DataClient / DataEngine、Cache / Database、Strategies / Trader / Portfolio、RiskEngine / ExecutionEngine / ExecutionClient future gate、Workbench / Dashboard physical migration 和 stage audit input。该 matrix 不能写成 L4 execution authorization。

`MTP-190-REMAINING-COMPATIBILITY-SHELL-AUDIT`

MTP-190 remaining compatibility shell audit 表示当前迁移完成的是 source directory ownership，不是 final target split。`Core`、`Adapters`、`Runtime`、`App` 和 `Dashboard` 等 target / product name 仍可作为 compatibility envelope 保持 buildability；后续拆分必须单独规划。

`MTP-190-FORBIDDEN-IMPLEMENTATION-AUDIT`

MTP-190 forbidden implementation audit 固定 no Strategy runtime、Trader runtime、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、emergency stop、shutdown、restore 或 production operations command。

## Forbidden Terms / 当前禁用或必须带门禁语义的词

以下词在当前 construction scope 中必须带上 `Future`、`gated` 或 `forbidden` 语义。中文写法也必须表达“未来建设区 / 受门禁保护 / 当前禁止”，不能写成当前已具备能力：

- Live trading
- API key
- secret storage
- signed endpoint
- account endpoint
- listenKey
- broker integration
- broker execution adapter
- exchange execution adapter
- execution venue connection
- real order submit / cancel / replace
- real order lifecycle
- execution report
- broker fill
- order reconciliation
- OMS
- real account balance
- broker position sync
- production deployment / runtime operations

## 维护规则

- 新 Linear Project 规划前，`@001 / PLN` 必须读取本文档，避免 issue title / body 使用漂移术语。
- `@002 / PAR` 做 Stage Code Audit 和 Root Docs Refresh Gate 时，如发现 root docs、PR 或 validation evidence 中出现术语漂移，应记录为 Root Docs Delta。
- Codex Execution Agent 新增 public type / protocol / actor / service 时，应优先复用本文档中的领域词命名，并在中文注释中保持同一语义。
- 临时 planning note、implementation detail 和代码文件清单不得写入本文档。
