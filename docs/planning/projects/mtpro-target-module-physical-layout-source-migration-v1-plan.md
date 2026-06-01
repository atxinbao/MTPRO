# MTPRO Target Module Physical Layout / Source Migration v1

日期：2026-06-01

执行者：Codex

## 文档定位

本文是 `MTPRO Target Module Physical Layout / Source Migration v1` 的 docs-only planning record。

本文承接 `MTPRO Engine Module Boundary Consolidation v1` 已完成的 architecture-graph-aligned module boundary、fixed target source layout、dependency direction 和 forbidden path taxonomy，用于把下一步 source physical layout migration 收敛成可写入 Linear 的 Project 级计划摘要。

本文不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不启动 `@002 / PAR`，不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma，不移动 `Sources` 文件，不修改 `Package.swift` target graph，不写业务代码。

本文不授权 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。

## Project name

`MTPRO Target Module Physical Layout / Source Migration v1`

## Target maturity

`Target Module Physical Layout / Source Migration before L4`

该阶段不改变旧 `Final Product Goal Progress 9 / 9 (100%)`，不更新旧 `Engine Maturity Roadmap Progress 4 / 4 (100%)`，也不把 L4 live production capability 写成当前 execution scope。

## Target Engines / Modules

- DomainModel
- DataClient / Binance public read-only venue boundary
- DataEngine
- MessageBus
- Cache
- Database
- Strategies / EMA strategy-scoped boundary
- Trader
- Portfolio
- RiskEngine
- ExecutionEngine
- ExecutionClient future gate
- Workbench
- Dashboard
- CSQLite / system library boundary

## Project goal

把当前早期 SwiftPM source layout：

```text
Sources/Core
Sources/Adapters
Sources/Persistence
Sources/Runtime
Sources/App
Sources/Dashboard
Sources/CSQLite
```

按 `docs/architecture/module-boundary.md` 已固定的架构图目标模块，迁移为下一版物理源码结构：

```text
Sources/DomainModel/
Sources/DataClient/<venue>/
Sources/DataEngine/
Sources/MessageBus/
Sources/Cache/
Sources/Database/
Sources/Strategies/<strategy>/
Sources/Trader/
Sources/Portfolio/
Sources/RiskEngine/
Sources/ExecutionEngine/
Sources/ExecutionClient/
Sources/Workbench/
Sources/Dashboard/
```

本 Project 的目标是完成物理目录、SwiftPM target / namespace strategy、import boundary、tests placement、compatibility shell 和 migration evidence 的分批计划，使 MTPRO 后续开发不再继续把旧 `Core / Adapters / Persistence / Runtime / App` 当成新增能力落点。

本 Project 只规划 source physical layout migration 和 boundary-preserving source movement。它不实现新的交易能力，不启动 live runtime，不把 future-gated module 变成真实 broker / signed endpoint / OMS / trading command。

## Scope

- 定义 target physical layout 与 SwiftPM target migration contract。
- 固定旧目录到新目标模块的 source migration map。
- 定义 module-by-module import boundary 与 dependency direction。
- 分批迁移 DomainModel / MessageBus spine。
- 分批迁移 DataClient / DataEngine boundary。
- 分批迁移 Cache / Database boundary。
- 分批迁移 Strategies / Trader / Portfolio boundary。
- 分批迁移 RiskEngine / ExecutionEngine / ExecutionClient future gate boundary。
- 分批迁移 Workbench / Dashboard consumption boundary。
- 保留必要 compatibility shell，避免一次性破坏编译与验证。
- 更新 tests placement、focused validation、automation readiness anchors 和 stage audit input。
- 确保每一步迁移都能运行 `bash checks/run.sh` 并留下 PR evidence。

## Non-goals

- 不在 planning record 中执行任何 source move。
- 不把所有业务文件一次性迁移完。
- 不做无关重构。
- 不改变产品口径、进度条或 L4 authorization。
- 不实现 Strategy runtime。
- 不实现 Trader runtime。
- 不实现 Live runtime。
- 不实现 ExecutionClient implementation。
- 不实现 OMS implementation。
- 不实现 signed endpoint、account endpoint / listenKey。
- 不实现 private WebSocket runtime。
- 不实现 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order lifecycle。
- 不实现 real submit / cancel / replace。
- 不实现 execution report / broker fill / reconciliation。
- 不读取 real account / broker position / margin / leverage。
- 不实现 real PnL。
- 不实现 Live PRO Console、trading button、live command 或 order form。
- 不实现 emergency stop、shutdown 或 restore。
- 不运行 Graphify。
- 不修改 Figma。
- 不提交 `.codex/*` 或 `graphify-out/*`。

## Target layout contract

后续 source migration 只能迁入下列目标目录；不得临时发明平行 Engine 目录，也不得继续把旧路径写成最终架构名。

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

## Milestones

| Milestone | Goal | Must complete | Exit evidence |
| --- | --- | --- | --- |
| M1 Migration Contract / Package Target Strategy | 定义物理迁移合同、SwiftPM target strategy、compatibility shell 和 old-to-new source map。 | 固定 migration order、target graph strategy、import boundary guard、old path compatibility policy。 | migration contract、Package.swift change plan、no source move audit、validation anchors。 |
| M2 DomainModel / MessageBus Spine | 先迁移最底层 pure domain 和 facts / command / event spine，降低后续模块耦合风险。 | DomainModel、MessageBus 目标目录和测试归位策略；旧 Core compatibility shell 规则。 | focused validation、import boundary evidence、no behavior change evidence。 |
| M3 DataClient / DataEngine Migration | 把 public market data venue client 和 ingest / replay / quality 边界迁入目标模块。 | `DataClient/Binance`、DataEngine ingest / replay / quality placement；public read-only guard。 | adapter capability evidence、no signed/account/listenKey evidence。 |
| M4 Cache / Database Migration | 把 runtime-derived state 和 durable facts / snapshots / projections 从旧 Persistence / Runtime 结构中拆清。 | Cache、Database、CSQLite boundary、SQLite / DuckDB projection placement。 | persistence projection tests、schema non-exposure evidence、database boundary audit。 |
| M5 Strategies / Trader / Portfolio Migration | 把策略、协调器和组合状态拆成独立目标模块。 | `Strategies/EMA`、Trader coordination、Trader/Accounts、Portfolio financial state placement。 | no direct execution path evidence、proposal isolation tests、Portfolio read-model evidence。 |
| M6 RiskEngine / ExecutionEngine / ExecutionClient Future Gate | 把 paper / simulated execution、risk pre-check 和 future execution client gate 拆清。 | RiskEngine、ExecutionEngine、ExecutionClient FutureGate / BrokerCapabilityMatrix placement。 | broker / real order forbidden guard evidence、no OMS implementation evidence。 |
| M7 Workbench / Dashboard Consumption Boundary | 把 App / Dashboard 的 read-model consumption 迁到 Workbench / Dashboard 目标边界。 | Workbench ReadModels / Report / Dashboard / Events placement；Dashboard shell dependency cleanup。 | UI read-model-only evidence、no runtime / schema / adapter exposure evidence。 |
| M8 Validation Matrix / Stage Audit Input | 收口全 Project validation matrix、automation readiness、source migration evidence 和 Stage Audit input。 | migration evidence chain、deferred work、remaining compatibility shells、L4 source-readiness input。 | validation matrix、automation readiness anchors、stage audit input material。 |

## Suggested issue order

1. Define target module physical layout and SwiftPM migration contract.
2. Migrate DomainModel and MessageBus spine without behavior change.
3. Migrate DataClient / DataEngine boundaries for public read-only data.
4. Migrate Cache / Database boundaries for state, event log, projection, SQLite and DuckDB.
5. Migrate Strategies / Trader / Portfolio boundaries.
6. Migrate RiskEngine / ExecutionEngine and future-gated ExecutionClient boundary.
7. Migrate Workbench / Dashboard consumption boundary.
8. Close validation matrix, automation readiness and stage audit input.

仓库 planning record 只保存 Project 级计划摘要和 issue order。完整 Linear issue body 后续以 Linear 写入内容为准，不在仓库长期复制维护。

## Dependencies

- Issue 2 depends on Issue 1.
- Issue 3 depends on Issue 1, Issue 2.
- Issue 4 depends on Issue 1, Issue 2.
- Issue 5 depends on Issue 2, Issue 4.
- Issue 6 depends on Issue 2, Issue 5.
- Issue 7 depends on Issue 3, Issue 4, Issue 5, Issue 6.
- Issue 8 depends on Issue 7.

## Validation requirements

- 每个 issue 必须运行 `bash checks/run.sh`。
- 每个 issue 必须运行 `git diff --check`。
- 每个 source migration issue 必须说明 moved files、compatibility shell、import boundary 和 no behavior change evidence。
- 必须验证目标目录只使用已固定的 `Sources/*` target layout。
- 必须验证 old path 只作为 migration source / compatibility shell，不作为新增能力落点。
- 必须验证 `Package.swift` target graph change 只在对应 Linear issue 授权后发生。
- 必须验证 Workbench / Dashboard 只消费 ReadModel / ViewModel，不读取 runtime object、adapter request、SQLite / DuckDB schema、account payload 或 broker state。
- 必须验证 no signed endpoint、no account endpoint / listenKey、no private WebSocket runtime。
- 必须验证 no broker / exchange execution adapter、no `LiveExecutionAdapter`。
- 必须验证 no Strategy runtime、no Trader runtime、no Live runtime。
- 必须验证 no ExecutionClient implementation、no OMS implementation。
- 必须验证 no real order lifecycle、no real submit / cancel / replace。
- 必须验证 no execution report / broker fill / reconciliation。
- 必须验证 no real account / broker position / margin / leverage、no real PnL。
- 必须验证 no Live PRO Console / trading button / live command / order form。
- 必须验证 no emergency stop、shutdown 或 restore。
- `.codex/*` 和 `graphify-out/*` 不进入 PR。

## Evidence requirements

- 每个 PR 必须包含 Linked Linear Issue、Scope / Non-goals、changed files / moved files summary、validation output 和 boundary evidence。
- 每个 PR 必须包含 MTPRO-native PR evidence fields：Feedback Loop Evidence、Tracer Bullet / Fixture Evidence、Diagnose Evidence、Architecture Deepening Candidate。
- 每个 PR 前必须执行 Pre-PR Codex Code Review。
- 每个 PR 必须使用 GitHub PR Automation。
- 每个 PR 必须明确是否修改 `Package.swift`，如修改必须说明 target graph delta；如未修改必须说明 no Package.swift target graph change。
- 每个 PR 必须说明是否移动 `Sources` 文件，以及 old path compatibility shell 如何保留或删除。
- 每个 PR 必须说明 no unauthorized live / broker / signed / execution capability。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- 如由 symphony-issue 执行，必须提供 handoff marker evidence。
- Issue 8 只准备 stage audit input material；Project 全部 Done 后 Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

Issue 1：`Define target module physical layout and SwiftPM migration contract`

该 issue 只是 first executable candidate，不构成执行授权。

## WIP=1 / Queue Preflight Rule

- Project 执行必须保持 WIP=1。
- 所有 issue 初始状态必须是 `Backlog / non-executable`。
- `@001 / PLN` 不操作 `Backlog -> Todo`。
- Project 写入 Linear 后，由 Parent Codex queue preflight 判断唯一 eligible issue。
- Parent Codex queue preflight 必须确认 WIP=1、依赖满足、无 active conflict、execution contract 格式完整、source migration scope 清楚、validation requirements 完整后，才可推进唯一 eligible issue 到 Todo。

## Linear write boundary

- 本 planning record 不创建 Linear Project。
- 本 planning record 不创建 Linear Issues。
- 本 planning record 不修改 Linear status。
- 本 planning record 不推进 Todo。
- 本 planning record 不启动 `@002 / PAR`。
- 本 planning record 不启动 Symphony / symphony-issue。
- 后续完整 execution contract 以 Linear issue body 为准。
- Linear 写入后，所有 issue 初始必须保持 `Backlog / non-executable`。

## Repository record boundary

- 仓库 planning record 只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 Linear issue body。
- 仓库 planning record 不授权执行。
- 后续 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 和 Acceptance Criteria 以 Linear issue body 为准。
- 本文不授权移动 `Sources` 文件，不授权修改 `Package.swift` target graph，不授权写业务代码。

## Final boundary confirmation

本文只记录 docs-only Project planning record。它不是 Project closure，不是 Linear write，不是 queue preflight，不是 source migration execution，不是 L4 authorization。

后续必须先由 Human 决定是否写入 Linear；Linear 写入后仍必须由 Parent Codex queue preflight 推进唯一 eligible issue，才允许执行任何 source migration。
