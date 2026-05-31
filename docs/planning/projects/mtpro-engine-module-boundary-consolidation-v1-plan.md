# MTPRO Engine Module Boundary Consolidation v1

日期：2026-05-31

执行者：Codex

## 文档定位

本文是 `MTPRO Engine Module Boundary Consolidation v1` 的 docs-only planning record。

本文承接 `L3.4 Strategy / Trader Instance Readiness v1 complete` 和 `docs/architecture/mtpro-nautilus-style-architecture-gap-review-v1.md` 的差距核对结论，用于把 MTPRO 当前 early boundary 文档调整为架构图对齐的 Engine / Runtime module boundary 方案。

本文不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma，不写业务代码。

本文不授权 live runtime、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS implementation、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation runtime、real account / broker position / margin / leverage、real PnL、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。

## Project name

`MTPRO Engine Module Boundary Consolidation v1`

## Target maturity

`Architecture Boundary Consolidation before L4`

该阶段不改变旧 `Engine Maturity Roadmap Progress 4 / 4 (100%)`，也不把 L4 写成当前 execution scope。

## Target Engines / Layers

- Domain Model Foundation
- DataClient
- DataEngine
- MessageBus / Eventing
- Cache
- Database
- Trader
- Account context
- Strategies
- Portfolio
- RiskEngine
- ExecutionEngine
- ExecutionClient future gate
- Workbench Interface
- Future Live PRO Console boundary

## Project goal

按照交易系统架构图方向，把 MTPRO 当前已完成的 paper / simulated / read-model / strategy-trader readiness evidence 推进到下一版目标架构：以 `DataClient / DataEngine / MessageBus / Cache / Database / Strategies / Trader / Account / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench` 为主轴，形成清楚的 Engine / Runtime module boundary，并为后续 L4 planning 提供可执行的模块地基。

本 Project 的重点不是继续写“不能有 Execution Client / OMS / Trader runtime”，而是把这些目标模块正式放进架构边界图，并标明：

- 当前允许的 paper / simulated / read-model-only 能力。
- future-gated module boundary。
- forbidden implementation path。
- 未来进入 L4 planning 前必须满足的 validation anchors。

本 Project 必须一次性确定架构图对齐的最终目标代码结构和模块边界。目标结构不再以早期 `Core / Adapters / Persistence / Runtime / App` 分层为准，而是以架构图里的 `DataClient / DataEngine / Strategies / Trader / Portfolio / ExecutionEngine / ExecutionClient / RiskEngine / MessageBus / Cache / Database` 为主轴。Linear issue 授权后，可以按固定目录逐步迁移文件、收口 namespace / type boundary、增加测试锚点、文档锚点和 dependency guard；但不能把 future-gated module 实现成真实 live runtime。

## Scope

- 定义 architecture-graph-aligned module boundary 术语。
- 校准早期 forbidden boundary：从“模块名不能出现”改成“模块可进入目标图，但 implementation gated”。
- 收口 MessageBus / Eventing boundary。
- 收口 Cache / Database boundary。
- 收口 DataClient / DataEngine boundary；DataClient 下按 `<venue>/` 组织交易所适配，一个交易所对应一个目录。
- 收口 Strategies / Trader / Account / Portfolio boundary；Strategies 下按 `<strategy>/` 组织策略，一个策略一个目录。
- 收口 RiskEngine / ExecutionEngine / ExecutionClient boundary。
- 收口 Workbench read-model-only boundary 和 Future Live PRO Console 分离边界。
- 一次性确定 `Sources/*` 下按架构图命名的最终目标模块目录关系，后续 issue 不再临时发明 Engine 目录，也不继续把早期文件夹作为目标落点。
- 准备后续 L4 planning input material。
- 按 milestone 顺序建立可进入 Linear 的 task candidates。

## Non-goals

- 不把一次性模块定位等同于一次性完成所有代码迁移；文件迁移必须按 Linear task 分批完成。
- 不继续把早期 `Core / Adapters / Persistence / Runtime / App` 文件夹当作最终目标结构；它们只能作为迁移来源或过渡 compatibility shell。
- 不在 planning record 里直接执行大规模文件移动；真实迁移必须由 Linear issue 明确授权。
- 不做无关重构。
- 不实现 Strategy runtime。
- 不实现 Trader runtime。
- 不实现 Live Monitoring runtime。
- 不实现 Live readiness runtime。
- 不实现 signed endpoint、account endpoint / listenKey。
- 不实现 private WebSocket runtime、account snapshot runtime。
- 不实现 broker / exchange execution adapter。
- 不实现 ExecutionClient implementation。
- 不实现 `LiveExecutionAdapter`。
- 不实现 OMS / real order lifecycle。
- 不实现 real submit / cancel / replace。
- 不实现 execution report / broker fill / reconciliation runtime。
- 不读取 real account / broker position / margin / leverage。
- 不实现 real PnL。
- 不实现 Live PRO Console、trading button、live command 或 order form。
- 不实现 emergency stop、shutdown 或 restore。
- 不运行 Graphify。
- 不修改 Figma。
- 不创建下一 L4 Project / Issue。

## Project-level acceptance criteria

本 Project 完成时必须满足以下验收标准：

- [ ] 架构图中的核心模块均已进入 MTPRO target boundary：`DataClient`、`DataEngine`、`MessageBus`、`Cache`、`Database`、`Strategies`、`Trader`、`Account context`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient`、`Workbench` 和 Future `Live PRO Console`。
- [ ] 目标代码目录关系已固定，且后续 issue 只能向固定目录迁移：`Sources/DataClient/<venue>/`、`Sources/DataEngine/`、`Sources/MessageBus/`、`Sources/Cache/`、`Sources/Database/`、`Sources/Strategies/<strategy>/`、`Sources/Trader/`、`Sources/Portfolio/`、`Sources/RiskEngine/`、`Sources/ExecutionEngine/`、`Sources/ExecutionClient/`、`Sources/Workbench/`、`Sources/Dashboard/`。
- [ ] `DataClient` 已明确为 exchange / venue scoped adapter boundary，一个交易所一个目录；当前只允许 public / fixture / simulated / read-model evidence，private / signed / account path 必须 future-gated。
- [ ] `Strategies` 已明确为独立模块，一个策略一个目录；当前示例为 `Strategies/EMA/`，后续策略必须按同一结构进入。
- [ ] `Trader`、`Account context` 和 `Portfolio` 分层已明确：`Trader` 只做协调，`Trader/Accounts` 只保存 account context / identity，cash、position、PnL、exposure 和 projection 归独立 `Portfolio`。
- [ ] `ExecutionEngine` 与 `ExecutionClient` 分层已明确：`ExecutionEngine` 是内部 paper / simulated execution lifecycle 边界，`ExecutionClient` 是未来 broker / exchange API client 边界；当前不得实现真实 client、OMS 或 real order lifecycle。
- [ ] `MessageBus / Cache / Database` 作为系统脊柱已收口：MessageBus 管 facts / commands / events，Cache 管 runtime-derived state，Database 管 durable facts / snapshots / projections。
- [ ] Workbench 只消费 ReadModel / ViewModel，Future Live PRO Console 作为独立 future product surface，不从 Workbench 自然扩展出 trading command。
- [ ] Validation anchors 能机械阻断 old path drift、future-gated implementation drift 和 forbidden capability drift。
- [ ] 每个 milestone 均有可追溯 PR、validation output、boundary evidence 和 stage closeout input。
- [ ] Project 完成后只产生 L4 planning input material；不得自动创建 L4 Linear Project / Issue 或推进 Todo。

## Milestone plan

| Milestone | Goal | Must complete | Exit evidence |
| --- | --- | --- | --- |
| M1 Architecture Boundary Contract | 统一架构图模块语言，把 early forbidden boundary 校准成 target module boundary。 | 固定最终 `Sources/*` 目标模块目录、目标模块图、依赖方向、forbidden path taxonomy、Linear issue contract 模板。 | 架构边界文档、最终目录 map、validation anchors、no-authorization audit。 |
| M2 MessageBus / Cache / Database Spine | 把 MessageBus、Cache、Database 作为系统脊柱收清楚。 | 定义 facts / events / commands / replay / snapshot / runtime cache / durable database / projection 的职责和依赖方向。 | `Sources/MessageBus`、`Sources/Cache`、`Sources/Database` boundary map 和 focused validation。 |
| M3 DataClient / DataEngine Boundary | 对齐图中的 DataClient -> DataEngine -> MessageBus 路径。 | 区分 exchange-scoped public data client、future private stream source、DataEngine ingest、scenario replay、data quality。 | `Sources/DataClient/<venue>`、`Sources/DataEngine`、adapter capability matrix、no signed/account/listenKey validation。 |
| M4 Strategies / Trader / Account / Portfolio Context | 对齐图中的 Strategies、Trader、Account、Portfolio 上下文。 | 定义独立 Strategies lifecycle、quoter / hedger proposal path、Trader coordinator boundary、Account context、Portfolio context read-model input。 | `Sources/Strategies/<strategy>`、`Sources/Trader`、`Sources/Portfolio` boundary map、proposal isolation tests、no direct ExecutionClient path。 |
| M5 RiskEngine / ExecutionEngine / ExecutionClient Future Gate | 对齐 RiskEngine -> ExecutionEngine -> ExecutionClient 路径。 | 定义 paper / simulated execution boundary、future OMS boundary、ExecutionClient future gate、risk-before-execution dependency。 | `Sources/RiskEngine`、`Sources/ExecutionEngine`、`Sources/ExecutionClient` boundary map、forbidden broker / real order tests。 |
| M6 Workbench Surface / L4 Handoff | 对齐 Workbench 只读面和 Future Live PRO Console 分离。 | 确认 Workbench 只读消费边界、Live PRO Console future surface、L4 planning input material。 | Workbench read-model boundary、L4 input checklist、stage audit input material。 |

## Milestone acceptance criteria

### M1 Architecture Boundary Contract

- [ ] 所有架构图模块都有 MTPRO 对应术语、目标目录、当前能力状态和 future-gated 边界。
- [ ] 早期 `Core / Adapters / Persistence / Runtime / App` 文件夹被定义为迁移来源或 compatibility shell，不再作为最终目标结构。
- [ ] 目标依赖方向已写入文档和 validation anchor，能阻止 Strategies / Trader / Workbench 直连 ExecutionClient、broker、database schema 或 runtime object。
- [ ] 本 milestone 不移动业务代码，不实现 runtime，只固定 architecture contract。

### M2 MessageBus / Cache / Database Spine

- [ ] MessageBus 的 facts / events / commands / request-response / replay invariant 边界已独立成可验证合同。
- [ ] Cache 明确只保存 runtime-derived state，不承载 durability、schema ownership、DB adapter 或 UI contract。
- [ ] Database 明确承载 durable facts、snapshots、projections、SQLite / DuckDB 版本边界，不直接驱动 Workbench。
- [ ] 后续 DataEngine、Trader、Portfolio、ExecutionEngine 都必须经 MessageBus / Cache / Database spine 解释状态，不允许旁路。

### M3 DataClient / DataEngine Boundary

- [ ] `DataClient/<venue>/` 目标结构被固定；Binance 只是一个 venue 示例，不把 venue-specific 逻辑散落到 DataEngine 或 Workbench。
- [ ] DataClient 只负责外部或 fixture source boundary，DataEngine 负责 ingest、scenario replay、quality gates、freshness 和 MessageBus publication。
- [ ] Signed endpoint、account endpoint、listenKey、private WebSocket runtime、account snapshot runtime 和 broker adapter 均被 validation anchor 阻断。
- [ ] 同一数据源可追溯到 source identity、dataset / fixture version、replay window、freshness 和 quality evidence。

### M4 Strategies / Trader / Account / Portfolio Context

- [ ] `Strategies/<strategy>/` 目标结构被固定，EMA 只是首个策略目录示例，后续策略不得直接混入 Trader 或 ExecutionEngine。
- [ ] Strategy lifecycle、quoter / hedger roles、signals、proposals 和 paper/live-neutral proposal isolation 已形成独立 boundary。
- [ ] Trader 只协调 account context、strategy binding、risk / execution context，不拥有 cash、positions、PnL 或 real account state。
- [ ] Portfolio 作为独立模块拥有 cash、positions、PnL、exposure、paper projection 和 future real account gate。
- [ ] Strategies / Trader 不得直连 ExecutionClient、broker command、OMS、trading button、live command 或 order form。

### M5 RiskEngine / ExecutionEngine / ExecutionClient Future Gate

- [ ] RiskEngine 的 pre-execution boundary、paper risk、blocked evidence 和 future live risk gate 已明确。
- [ ] ExecutionEngine 的 paper / simulated lifecycle、simulated fill、fee / slippage、portfolio projection 和 future OMS split 已明确。
- [ ] ExecutionClient 被纳入目标架构模块，但只表示 future venue API client boundary，不实现真实 broker / exchange client。
- [ ] Signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 和 reconciliation runtime 均有 forbidden guard evidence。

### M6 Workbench Surface / L4 Handoff

- [ ] Workbench / Report / Events 只消费 ReadModel / ViewModel，不读取 runtime object、Adapter request、SQLite / DuckDB schema、account payload 或 broker state。
- [ ] Future Live PRO Console 被定义为独立 future product surface，不与 current Workbench 混用。
- [ ] L4 planning input material 包含 module boundary map、dependency direction、forbidden capability audit、validation matrix 和 unresolved future gates。
- [ ] M6-T4 只准备 stage audit input；最终 Stage Code Audit Report 必须由 Parent Codex 在 Project 全部 Done 后单独输出。

## Milestone task breakdown

### M1 Architecture Boundary Contract

| Task | Candidate Linear title | Deliverable |
| --- | --- | --- |
| M1-T1 | Define architecture-graph-aligned module boundary terminology | 统一 DataClient / DataEngine / MessageBus / Cache / Database / Strategies / Trader / Account / Risk / Execution / Portfolio / Workbench 术语。 |
| M1-T2 | Define fixed target source module layout, dependency direction, and forbidden path taxonomy | 一次性固定 `Sources/DataClient/<venue>/`、`Sources/DataEngine/`、`Sources/MessageBus/`、`Sources/Cache/`、`Sources/Database/`、`Sources/Strategies/<strategy>/`、`Sources/Trader/`、`Sources/Portfolio/`、`Sources/RiskEngine/`、`Sources/ExecutionEngine/`、`Sources/ExecutionClient/`、`Sources/Workbench/`、`Sources/Dashboard/` 的目标模块目录和依赖方向。 |
| M1-T3 | Add architecture boundary validation anchors | 在 automation readiness / validation docs 中建立“不把 target module 写成 current live runtime”的机械锚点。 |

### M2 MessageBus / Cache / Database Spine

| Task | Candidate Linear title | Deliverable |
| --- | --- | --- |
| M2-T1 | Consolidate MessageBus / Command / Event boundary | 明确 facts、events、commands、request / response、paper routing、replay invariant 的职责。 |
| M2-T2 | Consolidate Cache boundary | 明确 instruments、market data、orders、positions、account summary 的 runtime cache boundary。 |
| M2-T3 | Consolidate Database boundary | 明确 Event Log、Snapshot、Projection、SQLite、DuckDB、Database、schema/version 的职责分层。 |

### M3 DataClient / DataEngine Boundary

| Task | Candidate Linear title | Deliverable |
| --- | --- | --- |
| M3-T1 | Consolidate DataClient exchange adapter boundary | 区分 `Binance/PublicMarketData`、future provider client、future private stream client 和 forbidden signed/account path；确认一个交易所一个目录。 |
| M3-T2 | Consolidate DataEngine ingest / replay / quality boundary | 明确 market data ingest、scenario replay、catalog、freshness、quality gates 到 MessageBus 的路径。 |
| M3-T3 | Add adapter capability and data-source guard evidence | 增加 validation anchors，防止 DataClient 绕过 capability matrix 进入 account/listenKey/private runtime。 |

### M4 Strategies / Trader / Account / Portfolio Context

| Task | Candidate Linear title | Deliverable |
| --- | --- | --- |
| M4-T1 | Consolidate Strategies lifecycle and proposal boundary | 明确 Strategies 独立模块，并按 `Strategies/<strategy>/` 放置 EMA 等不同交易策略；每个策略拥有自己的 quoter / hedger、signals、paper/live-neutral proposal 边界。 |
| M4-T2 | Consolidate Trader coordination boundary | 明确 Trader 只协调 account / strategies / risk / execution context，不成为 live coordinator。 |
| M4-T3 | Consolidate Account / Portfolio context read-model boundary | 明确 Account 只是 Trader 内的 account context / identity；Portfolio 保持独立模块，拥有 cash、position、PnL、exposure、paper projection 和 future real account gate。 |
| M4-T4 | Add Strategies / Trader no-direct-execution guard evidence | 防止 Strategies / Trader 直连 ExecutionClient、broker command、OMS 或 executable order command。 |

### M5 RiskEngine / ExecutionEngine / ExecutionClient Future Gate

| Task | Candidate Linear title | Deliverable |
| --- | --- | --- |
| M5-T1 | Consolidate RiskEngine pre-execution boundary | 明确 paper risk、blocked evidence、future live risk gate 与 execution dependency。 |
| M5-T2 | Consolidate ExecutionEngine paper / simulated lifecycle boundary | 明确 paper lifecycle、simulated fill、fee/slippage、portfolio projection 与 future OMS 分界。 |
| M5-T3 | Define Execution Client and OMS future gate boundary | 把 ExecutionClient / OMS 纳入目标架构模块，但保持 implementation forbidden。 |
| M5-T4 | Add broker / real order forbidden guard evidence | 建立 signed endpoint、broker adapter、real order lifecycle、execution report、broker fill、reconciliation 的阻断证据。 |

### M6 Workbench Surface / L4 Handoff

| Task | Candidate Linear title | Deliverable |
| --- | --- | --- |
| M6-T1 | Consolidate Workbench read-model-only consumption boundary | 确认 Workbench / Report / Events 只能消费 ReadModel / ViewModel，不读取 runtime / adapter / schema / payload。 |
| M6-T2 | Define Future Live PRO Console product-surface split | 明确 Live PRO Console 是独立 future surface，不是 Workbench 自然扩展。 |
| M6-T3 | Close L4 planning input material | 汇总 Engine boundary map、forbidden audit、dependency direction 和 L4 issue planning inputs。 |
| M6-T4 | Close validation matrix / automation readiness / stage audit input | 准备 Stage Code Audit input；Project 全部 Done 后由 Parent Codex 单独输出 Stage Code Audit Report。 |

## Issue acceptance criteria

写入 Linear 时，每个 issue body 必须把下列 acceptance criteria 展开到 `Validation / Boundary / PR Requirements` 中。仓库 planning record 只保存摘要，不长期复制完整 Linear issue body。

| Task | Acceptance criteria |
| --- | --- |
| M1-T1 | 架构图模块术语全部有 MTPRO 对应定义；旧术语和新术语映射清楚；future-gated 模块名可出现但不得表示当前 runtime implementation。 |
| M1-T2 | 固定目标目录包含 `DataClient/<venue>`、`Strategies/<strategy>`、`Database`、`Trader/Accounts`、独立 `Portfolio`、`ExecutionEngine` 和 future-gated `ExecutionClient`；依赖方向和 forbidden path taxonomy 已写清。 |
| M1-T3 | automation readiness / validation docs 能检查目标模块不被写成当前 live runtime；`bash checks/run.sh` 通过。 |
| M2-T1 | MessageBus facts / commands / events / request-response / replay invariant 被独立定义；没有 broker、UI、database schema 或 runtime object 旁路。 |
| M2-T2 | Cache boundary 只覆盖 instruments、market data、orders、positions、account summary 等 runtime-derived state；明确不负责 durability / schema / DB adapter。 |
| M2-T3 | Database boundary 覆盖 Event Log、Snapshot、Projection、SQLite、DuckDB、schema / version；明确不直接被 Workbench 消费。 |
| M3-T1 | DataClient 按 `DataClient/<venue>/` 组织；Binance public market data 与 future private / signed / account source 分离；一个交易所一个目录。 |
| M3-T2 | DataEngine ingest、scenario replay、catalog、freshness、quality gates 到 MessageBus 的路径明确；不直接服务 UI 或 Trader。 |
| M3-T3 | capability guard 覆盖 signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime 和 broker adapter。 |
| M4-T1 | Strategies 独立为 `Strategies/<strategy>/`；EMA 示例下的 lifecycle、quoter、hedger、signals、proposals 边界明确；无直接 execution path。 |
| M4-T2 | Trader 只协调 strategy / account / risk / execution context，不成为 live coordinator、OMS 或 broker gateway。 |
| M4-T3 | Account context 与 Portfolio financial state 分层明确；cash、positions、PnL、exposure 和 projection 归 Portfolio；真实账户仍 future-gated。 |
| M4-T4 | validation guard 能阻断 Strategies / Trader 直连 ExecutionClient、broker command、OMS、trading button、live command 或 order form。 |
| M5-T1 | RiskEngine pre-execution boundary 和 future live risk gate 明确；不读取 real account、broker position、margin、leverage 或 real PnL。 |
| M5-T2 | ExecutionEngine 只覆盖 paper / simulated lifecycle、simulated fill、fee / slippage 和 portfolio projection；real order lifecycle 仍 forbidden。 |
| M5-T3 | ExecutionClient / OMS 只作为 future-gated target module boundary；不新增 broker client、signed request、execution report parser 或 reconciliation runtime。 |
| M5-T4 | forbidden guard 覆盖 signed endpoint、broker adapter、real order lifecycle、real submit / cancel / replace、execution report、broker fill 和 reconciliation。 |
| M6-T1 | Workbench / Report / Events 只消费 ReadModel / ViewModel；没有 runtime object、Adapter request、SQLite / DuckDB schema、account payload 或 broker state exposure。 |
| M6-T2 | Future Live PRO Console 与 current Workbench surface 分离；不新增交易按钮、order form、live command、emergency stop、shutdown 或 restore。 |
| M6-T3 | L4 input material 汇总 module map、dependency direction、forbidden audit、validation gaps 和 future gates；不创建 L4 Project / Issue。 |
| M6-T4 | validation matrix、automation readiness、stage audit input material 完整；issue 不输出最终 Stage Code Audit Report，不推进下一阶段。 |

## Suggested issue order

1. M1-T1 Define architecture-graph-aligned module boundary terminology
2. M1-T2 Define fixed target source module layout, dependency direction, and forbidden path taxonomy
3. M1-T3 Add architecture boundary validation anchors
4. M2-T1 Consolidate MessageBus / Command / Event boundary
5. M2-T2 Consolidate Cache boundary
6. M2-T3 Consolidate Database boundary
7. M3-T1 Consolidate DataClient exchange adapter boundary
8. M3-T2 Consolidate DataEngine ingest / replay / quality boundary
9. M3-T3 Add adapter capability and data-source guard evidence
10. M4-T1 Consolidate Strategies lifecycle and proposal boundary
11. M4-T2 Consolidate Trader coordination boundary
12. M4-T3 Consolidate Account / Portfolio context read-model boundary
13. M4-T4 Add Strategies / Trader no-direct-execution guard evidence
14. M5-T1 Consolidate RiskEngine pre-execution boundary
15. M5-T2 Consolidate ExecutionEngine paper / simulated lifecycle boundary
16. M5-T3 Define Execution Client and OMS future gate boundary
17. M5-T4 Add broker / real order forbidden guard evidence
18. M6-T1 Consolidate Workbench read-model-only consumption boundary
19. M6-T2 Define Future Live PRO Console product-surface split
20. M6-T3 Close L4 planning input material
21. M6-T4 Close validation matrix / automation readiness / stage audit input

## Dependencies

- M1-T2 depends on M1-T1.
- M1-T3 depends on M1-T1, M1-T2.
- M2-T1 depends on M1-T3.
- M2-T2 depends on M2-T1.
- M2-T3 depends on M2-T1, M2-T2.
- M3-T1 depends on M1-T3.
- M3-T2 depends on M2-T1, M2-T2, M3-T1.
- M3-T3 depends on M3-T1, M3-T2.
- M4-T1 depends on M1-T3, M2-T1.
- M4-T2 depends on M4-T1.
- M4-T3 depends on M2-T2, M2-T3, M4-T2.
- M4-T4 depends on M4-T1, M4-T2, M4-T3.
- M5-T1 depends on M2-T1, M4-T3.
- M5-T2 depends on M5-T1.
- M5-T3 depends on M5-T2.
- M5-T4 depends on M5-T1, M5-T2, M5-T3.
- M6-T1 depends on M2-T3, M3-T3, M4-T4, M5-T4.
- M6-T2 depends on M6-T1.
- M6-T3 depends on M6-T1, M6-T2.
- M6-T4 depends on M6-T3.

## Validation requirements

- 每个 issue 必须运行 `bash checks/run.sh`。
- 必须验证 module boundary 文档不会把 future-gated module 写成当前 runtime implementation。
- 必须验证目标模块目录按架构图一次性固定，后续 task 只能迁移到固定目录，不能继续把早期 `Core / Adapters / Persistence / Runtime / App` 当成目标落点。
- 必须验证 `Strategies / Trader` 不直连 `ExecutionClient` 或 broker command。
- 必须验证 `DataClient` 下按 `<venue>/` 组织交易所适配，一个交易所一个目录。
- 必须验证 `Strategies` 下按 `<strategy>/` 组织交易策略，一个策略一个目录。
- 必须验证 `Account` 只作为 `Trader/Accounts` context / identity，不承载 cash、positions、PnL；这些 financial state 归独立 `Portfolio`，不得合并进 `Trader`。
- 必须验证 `Cache` 不承载 durability / schema / DB adapter，`Database` 不直接驱动 UI。
- 必须验证 `Execution Client` / `OMS` / `Live PRO Console` 只能作为 future-gated target module boundary 出现。
- 必须验证 no signed endpoint / account endpoint / listenKey。
- 必须验证 no private WebSocket runtime / account snapshot runtime。
- 必须验证 no broker / exchange execution adapter。
- 必须验证 no `LiveExecutionAdapter`。
- 必须验证 no real order lifecycle / real submit / cancel / replace。
- 必须验证 no execution report / broker fill / reconciliation runtime。
- 必须验证 no real account / broker position / margin / leverage / real PnL。
- 必须验证 Workbench 只消费 ReadModel / ViewModel，不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload 或 broker state。

## Evidence requirements

- 每个 PR 必须包含 Linked Linear Issue、Scope / Non-goals、validation output、boundary evidence。
- 每个 PR 前必须执行 Pre-PR Codex Code Review。
- 每个 PR 必须使用 GitHub PR Automation。
- 每个 PR 必须包含 MTPRO-native PR evidence fields：
  - Feedback Loop Evidence
  - Tracer Bullet / Fixture Evidence
  - Diagnose Evidence
  - Architecture Deepening Candidate
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- 如由 `symphony-issue` 执行，必须提供 handoff marker evidence。
- 涉及 production code 的 PR 必须补充详细中文注释；只有对应 Linear task 明确授权时才可触碰 production code。
- M6-T4 只准备 validation matrix / automation readiness / stage audit input，不输出最终 Stage Code Audit Report。
- Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## Candidate issue summary rule

仓库 planning record 只保留 milestone / task 摘要，不复制完整 Linear issue body。写入 Linear 时，每个 task 必须展开为完整 execution contract：

```text
Goal / Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements / Dependencies / Initial Linear State
```

## First executable issue candidate

M1-T1：`Define architecture-graph-aligned module boundary terminology`

该 task 只是 first executable candidate，不构成执行授权。

## WIP=1 / queue preflight rule

- Project 执行必须保持 WIP=1。
- 所有 issue 初始状态必须是 `Backlog / non-executable`。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 写入 Linear 后，由 Parent Codex queue preflight 判断唯一 eligible issue。
- Parent Codex queue preflight 必须确认 WIP=1、依赖满足、无 active conflict、execution contract 格式完整，才可推进唯一 eligible issue 到 Todo。

## Linear write boundary

- 本 planning record 不创建 Linear Project。
- 本 planning record 不创建 Linear Issues。
- 本 planning record 不修改 Linear status。
- 本 planning record 不推进 Todo。
- 后续完整 execution contract 以 Linear issue body 为准。
- Linear 写入后，所有 issue 初始必须保持 `Backlog / non-executable`。

## Repository record boundary

- 仓库 planning record 只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 Linear issue body。
- Planning record 不授权执行。
- 后续 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 以 Linear issue body 为准。

## L4 handoff

Project 全部 Done 后，才能把以下内容作为 L4 planning input：

- Engine module boundary map。
- MessageBus / Cache / Database boundary。
- DataClient / DataEngine capability boundary。
- Strategies / Trader future runtime boundary。
- Portfolio / RiskEngine / ExecutionEngine / ExecutionClient future live boundary。
- Workbench / Live PRO Console surface split。
- Forbidden implementation audit。

L4 仍必须由 Human + `@001 / PLN` 独立规划，不得由本 Project 自动推进。
