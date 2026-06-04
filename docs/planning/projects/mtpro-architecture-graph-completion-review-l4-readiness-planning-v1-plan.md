# MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1 Planning Record

日期：2026-06-05

执行者：Codex

类型：docs-only planning record / non-executable

## 文档定位

本文档只保存 `MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1` 的 Project 级计划摘要、architecture graph completion matrix、L4 readiness gate、milestones、issue order、dependencies、validation、evidence、first executable candidate、WIP=1 和边界。它不是 Linear issue body 的长期副本，也不授权执行。

完整 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 和 Acceptance Criteria 以后续 Linear issue body 为准。

本 planning record 不修改 `Package.swift`，不移动 `Sources`，不拆 SwiftPM target graph，不写业务代码，不创建 Linear Project / Issue，不推进 Todo。当前只做 architecture graph completion review / L4 readiness planning：区分 real module source root、boundary anchor、future gate、retained compatibility envelope 和 L4 前置 blocker。

MTPRO 不再使用 Symphony / Graphify；本 Project 后续执行也不得引入 Symphony handoff marker、Graphify output、code-index evidence 或相关调度要求。

## Project name

`MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1`

## Target maturity

`Pre-L4 Architecture Graph Completion Review / L4 Readiness Planning Gate`

## Target Engines / Modules

- `DataClient`
- `DataEngine`
- `MessageBus`
- `Cache`
- `Database`
- `Trader`
- `TraderStrategies / EMA`
- `Portfolio`
- `RiskEngine`
- `ExecutionEngine`
- `ExecutionClient`
- `Dashboard read-model-only boundary`
- Compatibility envelope：`Core / Adapters / Persistence / Runtime`

## Project goal

复核当前 `main` 是否已经完成 architecture graph 对齐，并形成进入 L4 planning 前的 readiness gate。

当前只做 review / planning：判断哪些模块已完成 real module source root + SwiftPM target boundary 对齐，哪些仍只是 boundary anchor / future gate，哪些实现仍依赖 compatibility envelope，哪些 blocker 必须先收口，哪些条件满足后才可以进入 `L4 Live Production / Trading Commands` planning。

当前核查基线：

- Current main：`3226441 Retire Workbench and AppCompatibility active modules (#374)`
- `Sources/TargetGraph` 顶层 active directory 已退休。
- `Sources/Workbench` 已退休。
- `Sources/AppCompatibility` 已退休。
- `Package.swift` 不再使用 `path: "Sources/TargetGraph..."`。
- 当前 active UI surface 是 `Dashboard -> Core / Persistence read-model and ViewModel exports only`。
- `Core / Adapters / Persistence / Runtime` 仍保留为 compatibility envelope。
- 多数新 SwiftPM module target 仍只编译模块内 `TargetGraph/*TargetBoundary.swift`，真实 implementation 仍由 compatibility envelope 编译。

## Scope

- 复核 architecture graph completion baseline。
- 审计 real module source root、SwiftPM target path、compiled boundary anchor 和 retained implementation owner。
- 审计 `Core / Adapters / Persistence / Runtime` compatibility envelope 仍承载哪些实现。
- 复核 `DataClient / DataEngine / MessageBus / Cache / Database` 对齐状态。
- 复核 `Trader = Accounts + Strategies/EMA + Coordination` 对齐状态。
- 复核 `Portfolio / RiskEngine / ExecutionEngine / ExecutionClient` future gate 对齐状态。
- 复核 `Dashboard read-model-only boundary` 是否替代旧 Workbench / AppCompatibility active module。
- 输出 L4 readiness gate：已满足项、未满足项、blocker、可进入 L4 planning 条件。
- 输出下一阶段候选 cleanup / planning issue order。
- `TargetGraph` 命名清理只作为 review 输出中的候选 cleanup，不作为本 Project 默认执行范围。

## Non-goals

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不修改仓库文件。
- 不修改 `Package.swift`。
- 不移动 `Sources`。
- 不拆 SwiftPM target graph。
- 不实现 Trader runtime。
- 不实现 Strategy runtime。
- 不实现 Live runtime。
- 不实现 `ExecutionClient` implementation。
- 不实现 OMS。
- 不实现 broker gateway。
- 不接 signed endpoint。
- 不接 account endpoint / listenKey。
- 不实现 private WebSocket runtime。
- 不实现 real order lifecycle。
- 不实现 submit / cancel / replace。
- 不实现 execution report / broker fill / reconciliation。
- 不实现 Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。

## Current authority anchors

- `architecture.md` 是当前 architecture graph / module boundary 的根级权威入口。
- `environment.md` 是当前环境、外部系统、tooling 和禁区边界入口。
- `Package.swift` 是 SwiftPM target graph 的当前事实源。
- `docs/architecture/module-boundary.md` 记录模块边界、forbidden dependency 和 future gate。
- `docs/domain/context.md` 记录 domain / bounded context 口径。
- `docs/contracts/swiftpm-target-graph-split-contract.md` 记录 SwiftPM target graph split contract。
- `docs/contracts/targetgraph-anchor-retirement-real-module-source-root-migration-contract.md` 记录 top-level `Sources/TargetGraph` retirement 和 real module source root 迁移证据。
- `docs/validation/latest-verification-summary.md` 和 `verification.md` 记录最新验证与 planning evidence。

## Architecture graph completion matrix

| Module | Current source root | SwiftPM target status | Real implementation status | Compatibility envelope dependency | Future gate status | Completion status | Gap / next action |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `DomainModel` | `Sources/DomainModel` | target path 已是真实 root；compiled source 仍是 `TargetGraph/DomainModelTargetBoundary.swift` | `CoreBaseline / MarketDataModels / MarketPrimitives` 仍由 `Core` 编译 | `Core` | 无 live gate | 部分完成 | target boundary 已对齐；需决定 implementation 是否迁入 target |
| `MessageBus` | `Sources/MessageBus` | target path 已是真实 root；compiled source 仍是 `TargetGraph/MessageBusTargetBoundary.swift` | commands / events / event log 仍由 `Core` 编译 | `Core` | 无 live gate | 部分完成 | 需审计是否可退休 MessageBus implementation compatibility |
| `Database` | `Sources/Database` | target path 已是真实 root；compiled source 仍是 `TargetGraph/DatabaseTargetBoundary.swift` | projections 由 `Persistence / Runtime` 编译 | `Persistence / Runtime` | 无 live gate | 部分完成 | 需确认 projection / replay projection owner |
| `DataClient` | `Sources/DataClient` | target path 已是真实 root；compiled source 仍是 `TargetGraph/DataClientTargetBoundary.swift` | Binance public read-only implementation 由 `Adapters` 编译 | `Adapters` | signed / account endpoint forbidden | 部分完成 | 需确认 public market data client 是否迁入 DataClient target |
| `Cache` | `Sources/Cache` | target path 已是真实 root；compiled source 仍是 `TargetGraph/CacheTargetBoundary.swift` | market data cache 由 `Core` 编译 | `Core` | no broker/account state | 部分完成 | 需确认 cache implementation owner |
| `DataEngine` | `Sources/DataEngine` | target path 已是真实 root；compiled source 仍是 `TargetGraph/DataEngineTargetBoundary.swift` | scenario replay / quality 由 `Core` 编译；ingest 由 `Runtime` 编译 | `Core / Runtime` | no private stream / broker route | 部分完成 | 需审计 DataEngine 实现迁移与 Runtime envelope 退休条件 |
| `TraderStrategies / EMA` | `Sources/Trader/Strategies/EMA` | target path 已是真实 root；compiled source 仍是 `TargetGraph/TraderStrategiesTargetBoundary.swift` | EMA source 由 `Core` 编译 | `Core` | strategy 不直连 execution | 部分完成 | 需确认 EMA 是否可作为 target implementation 编译；保持 EMA-only |
| `Trader` | `Sources/Trader` | target path 已是真实 root；compiled source 仍是 `TargetGraph/TraderTargetBoundary.swift` | Accounts / Coordination 由 `Core` 编译 | `Core` | no Trader runtime / no real account read | 部分完成 | 需确认 Trader container implementation owner；不能进入 runtime |
| `Portfolio` | `Sources/Portfolio` | target path 已是真实 root；compiled source 仍是 `TargetGraph/PortfolioTargetBoundary.swift` | portfolio projection 由 `Core` 编译 | `Core` | no broker account state | 部分完成 | 需确认 projection owner 与 Database / Cache 输入边界 |
| `RiskEngine` | `Sources/RiskEngine` | target path 已是真实 root；compiled source 仍是 `TargetGraph/RiskEngineTargetBoundary.swift` | pre-trade / live gate evidence 由 `Core` 编译 | `Core` | no live risk runtime | 部分完成 | 需确认 risk implementation owner；禁止升级为 real allow/reject runtime |
| `ExecutionClient` | `Sources/ExecutionClient` | target path 已是真实 root；compiled source 仍是 `TargetGraph/ExecutionClientTargetBoundary.swift` | future gate / broker matrix evidence 由 `Core` 编译 | `Core` | future gate only | L4 前合格但未实现 | 可进入 L4 planning 的前提是先定义 signed/account/broker gates；当前不能实现 |
| `ExecutionEngine` | `Sources/ExecutionEngine` | target path 已是真实 root；compiled source 仍是 `TargetGraph/ExecutionEngineTargetBoundary.swift` | paper lifecycle / simulated exchange / OMS future gate evidence 由 `Core` 编译 | `Core` | no live execution runtime | 部分完成 | 需确认 paper/simulated implementation owner；L4 前不能变成 OMS |
| `Dashboard` | `Sources/Dashboard` | executable target path 已是真实 root；显式编译 Dashboard surface | active UI / report / events surface；直接依赖 `Core / Persistence` | `Core / Persistence` | no Live PRO Console / no command UI | 当前 active UI 完成 | 需持续验证 Dashboard read-model-only boundary |
| `Workbench` | retired | 无 active product / target | retired | 无 | historical only | 已退休 | 只允许历史证据引用；不得作为 active 口径 |
| `AppCompatibility` | retired | 无 active product / target | retired | 无 | historical only | 已退休 | 保持 `import App` 不回流 |
| `TargetGraph` 顶层 | retired | 无 active `Sources/TargetGraph` path | retired historical evidence | 无 | historical only | 已退休 | 命名 cleanup 可作为候选 cleanup，不是默认执行范围 |
| `Core` | `Sources/Core` | retained compatibility target | 承载大量真实 implementation | active envelope | no live/broker | 未退休 | L4 前主要 blocker：实现仍集中在 Core |
| `Adapters` | `Sources/DataClient/Binance/PublicMarketData` | retained compatibility target | 承载 public market data adapter | active envelope | public read-only only | 未退休 | 是否迁入 DataClient target 需单独规划 |
| `Persistence` | `Sources/Database/Projections` | retained compatibility target | 承载 SQLite / DuckDB projection implementation | active envelope | no schema exposed to UI | 未退休 | 是否迁入 Database target 需单独规划 |
| `Runtime` | `Sources/Database/ReplayProjection` + `Sources/DataEngine/Ingest` | retained compatibility target | 承载 ingest / replay projection implementation | active envelope | no live runtime | 未退休 | 需判断能否退休 Runtime envelope；不能变成 live runtime |

## L4 readiness gate

### 已满足项

- `Sources/TargetGraph` 顶层 active path 已退休。
- `Sources/Workbench` 已退休。
- `Sources/AppCompatibility` 已退休。
- `Package.swift` active target roots 已指向真实模块目录。
- `Trader = Accounts + Strategies/EMA + Coordination` 已固定。
- EMA 是唯一 active concrete strategy。
- `ExecutionClient` 当前只是 future gate / protocol boundary。
- Dashboard 已作为 active read-model-only UI / report / events surface。
- `Dashboard -> Core / Persistence` read-model / ViewModel consumption boundary 已有测试证据。
- `bash checks/run.sh` 在最近 closure 证据中恢复并保持通过。

### 未满足项

- 多数 real module target 仍只编译 `TargetGraph/*TargetBoundary.swift`，不是完整 module implementation。
- `Core` 仍承载 DomainModel、MessageBus、Cache、DataEngine、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient 等大量 implementation。
- `Adapters` 仍承载 DataClient/Binance public market data implementation。
- `Persistence` 仍承载 Database projection implementation。
- `Runtime` 仍承载 DataEngine ingest 和 Database replay projection implementation。
- root docs 仍存在历史 Workbench wording，需要 review 判断是否只是 historical context。
- `TargetGraph` 命名仍存在于模块内 boundary anchor，是否 cleanup 需要单独候选 Project，不是默认 L4 scope。
- 当前没有 signed/account/broker credential policy 的 implementation gate。
- 当前没有 `LiveExecutionAdapter` / OMS / real order lifecycle implementation authorization。

### 必须先完成的 blocker

1. 明确 retained compatibility envelopes 是否阻止 L4 planning：
   - `Core`
   - `Adapters`
   - `Persistence`
   - `Runtime`
2. 明确哪些 implementation 必须先迁入真实 module target，哪些可以在 L4 planning 前继续保留 compatibility envelope。
3. 明确 Dashboard read-model-only boundary 不能被 L4 planning 扩展成 Live PRO Console。
4. 明确 ExecutionClient future gate 进入 L4 planning 前需要独立 signed/account/broker/OMS gate，而不是直接实现。

### 可进入 L4 planning 的条件

- Architecture completion review 明确列出 remaining envelope debt。
- Human 确认 L4 planning 只规划 gates / contracts / forbidden tests，不直接实现 broker runtime。
- Parent Codex queue preflight 能确认当前无 active Todo / In Progress / In Review conflict。
- Linear issue body 能完整约束：
  - no real API key / secret storage until dedicated gate。
  - no signed endpoint / account endpoint / listenKey until dedicated gate。
  - no broker adapter / `LiveExecutionAdapter` until dedicated gate。
  - no trading button / live command / order form。
  - no OMS / real order lifecycle until dedicated gate。

## Suggested milestones

| Milestone | 目标 |
| --- | --- |
| M1 Architecture Completion Review Baseline | 建立当前 HEAD、Package target graph、source roots、tests、contracts 和 validation summary 的 review baseline。 |
| M2 Real Module Source Root vs Compatibility Envelope Audit | 逐模块审计真实 module root 与 retained compatibility envelope 的实现归属差距。 |
| M3 Dashboard Read-model-only Boundary Review | 确认 Dashboard 已替代旧 Workbench / AppCompatibility active module，并只消费 read model / ViewModel / projection snapshot。 |
| M4 Execution / Risk / Portfolio Future Gate Review | 复核 Portfolio / RiskEngine / ExecutionEngine / ExecutionClient 的 future gate 状态，阻止 L4 前越界。 |
| M5 L4 Readiness Gate Definition | 定义 L4 planning 的进入条件、blocker、禁止能力和可规划范围。 |
| M6 Validation Matrix / Planning Closeout | 收口 review matrix、validation anchors、evidence requirements 和后续候选 Project 建议。 |

## Suggested issue order

1. Define architecture completion review baseline and evidence inventory
2. Audit real module source roots versus compatibility envelopes
3. Review DataClient / DataEngine / MessageBus / Cache / Database graph alignment
4. Review Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient future gates
5. Review Dashboard read-model-only boundary and retired Workbench / AppCompatibility paths
6. Define L4 readiness gate, blockers and allowed planning scope
7. Close validation matrix / planning evidence / L4 readiness handoff

## Dependencies

- Issue 2 blocked by Issue 1
- Issue 3 blocked by Issue 1, Issue 2
- Issue 4 blocked by Issue 1, Issue 2
- Issue 5 blocked by Issue 1, Issue 2
- Issue 6 blocked by Issue 3, Issue 4, Issue 5
- Issue 7 blocked by Issue 6

## Candidate issue summaries

| Issue | Summary | Boundary |
| --- | --- | --- |
| Issue 1 | 建立当前 HEAD、Package.swift、source roots、tests、contracts 和 validation evidence inventory。 | Review / audit only；不写业务代码，不改 Package.swift，不移动 Sources。 |
| Issue 2 | 审计 real module source roots 与 `Core / Adapters / Persistence / Runtime` compatibility envelope 的 implementation ownership 差距。 | 只输出 compatibility envelope debt，不迁移 implementation。 |
| Issue 3 | 复核 DataClient / DataEngine / MessageBus / Cache / Database architecture graph alignment。 | 保持 no signed / account endpoint / private stream / live runtime。 |
| Issue 4 | 复核 Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient future gates。 | 保持 Trader no runtime、ExecutionClient future gate、no OMS / broker gateway。 |
| Issue 5 | 复核 Dashboard read-model-only boundary 和 retired Workbench / AppCompatibility paths。 | Dashboard 只消费 read model / ViewModel / projection snapshot，不变成 Live PRO Console。 |
| Issue 6 | 定义 L4 readiness gate、blockers 和 allowed planning scope。 | 只定义 L4 planning gate，不推进 L4，不实现 live capability。 |
| Issue 7 | 收口 validation matrix、planning evidence 和 L4 readiness handoff material。 | 只准备 planning closeout；最终 Stage Code Audit Report 由 Parent Codex 单独输出。 |

## Validation requirements

每个 issue 必须运行：

- `git diff --check`
- `bash checks/run.sh`

按 issue scope 额外验证：

- `Package.swift` active target roots 与真实 module source roots 一致。
- `Sources/TargetGraph` 顶层目录不存在。
- `Sources/Workbench` 不作为 active path。
- `Sources/AppCompatibility` 不作为 active path。
- `Sources/Strategies` 不作为 active path。
- `Sources/Trader/StrategyBindings` 不作为 active path。
- `Trader = Accounts + Strategies/EMA + Coordination`。
- EMA 是唯一 active concrete strategy。
- `ExecutionClient` 只作为 future gate / protocol boundary。
- Dashboard 只消费 read model / ViewModel / projection snapshot。
- Dashboard 不暴露 runtime object、adapter request、database schema、account payload、broker state。
- no signed endpoint。
- no account endpoint / listenKey。
- no private WebSocket runtime。
- no `ExecutionClient` implementation。
- no OMS / broker gateway。
- no real order lifecycle / submit / cancel / replace。
- no execution report / broker fill / reconciliation。
- no Live PRO Console / trading button / live command / order form。
- no Graphify / code-index evidence in execution logs。

## Evidence requirements

每个 PR 必须包含：

- Linked Linear Issue。
- Scope / Non-goals。
- changed paths summary。
- architecture graph completion evidence。
- compatibility envelope audit evidence。
- Dashboard read-model-only evidence。
- L4 readiness blocker evidence。
- validation output。
- forbidden capability evidence。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。
- Issue 7 只准备 planning closeout / L4 readiness handoff material，不输出最终 Stage Code Audit Report。
- Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

Issue 1：`Define architecture completion review baseline and evidence inventory`

该 issue 只是 first executable candidate，不构成执行授权。

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

## Final boundary confirmation

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不修改 `Package.swift`。
- 不移动 `Sources`。
- 不拆 SwiftPM target graph。
- 不实现 Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
