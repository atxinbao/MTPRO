# MTPRO SwiftPM Target Graph Module Split v1 Planning Record

日期：2026-06-04

执行者：Codex

类型：docs-only planning record / non-executable

## 文档定位

本文档只保存 `MTPRO SwiftPM Target Graph Module Split v1` 的 Project 级计划摘要、milestones、issue order、dependencies、validation、evidence、first executable candidate、WIP=1 和边界。它不是 Linear issue body 的长期副本，也不授权执行。

完整 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 和 Acceptance Criteria 以后续 Linear issue body 为准。

本 planning record 不修改 `Package.swift` target graph，不拆 SwiftPM targets，不移动 `Sources`，不写业务代码。MTPRO 不再使用 Symphony / Graphify；本 Project 后续执行也不得引入 Symphony handoff marker、Graphify output 或相关调度要求。

## Project name

`MTPRO SwiftPM Target Graph Module Split v1`

## Project goal

将已完成的 architecture-graph-aligned source layout 进一步落实为 SwiftPM target graph，使 `Package.swift` 的 target / dependency boundary 与当前架构图模块一致。

本阶段只规划和后续执行编译边界、依赖方向、import boundary 和兼容壳收口；不实现 L4、live、broker、OMS 或任何真实交易能力。

## Target maturity

`Architecture graph aligned SwiftPM target graph baseline`

## Target Engines / Modules

- `DomainModel`
- `MessageBus`
- `DataClient/<venue>`
- `DataEngine`
- `Cache`
- `Database`
- `Trader`
  - `Accounts`
  - `Strategies/EMA`
  - `Coordination`
- `Portfolio`
- `RiskEngine`
- `ExecutionEngine`
- `ExecutionClient`
- `Workbench`
- `Dashboard`
- Validation / Automation readiness layer

## Scope

- 按 architecture module boundary 规划 SwiftPM module targets。
- 固定 target graph dependency direction。
- 收口旧 `Core / Adapters / Persistence / Runtime / App / Dashboard` compatibility envelope。
- 移除不再需要的聚合边界或 stale excludes。
- 保持 `Trader = Accounts + Strategies/EMA + Coordination`。
- 保持 EMA-only active strategy。
- 保持 Dashboard / Workbench 只消费 Read Model / ViewModel。
- 保持 `ExecutionClient` 只作为 future gate / protocol boundary，不实现 broker gateway。
- 保持 Persistence repair validation baseline 不回退。
- 输出 target graph split evidence、import boundary evidence 和 validation baseline。

## Non-goals

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不写业务代码。
- 不移动 `Sources` 文件。
- 不修改 `Package.swift` target graph。
- 不拆 SwiftPM target graph。
- 不修改 architecture module layout。
- 不实现 Trader runtime。
- 不实现 Strategy runtime。
- 不实现 Live runtime。
- 不实现 `ExecutionClient` implementation。
- 不实现 OMS。
- 不实现 broker gateway。
- 不接 signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- 不实现 real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation。
- 不实现 Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- 不把 target split 写成 runtime capability implementation。

## Current authority anchors

- `architecture.md` 和 `docs/architecture/module-boundary.md` 是当前 architecture module boundary 的权威入口。
- `environment.md` 是当前环境、外部系统和禁区边界入口。
- `docs/audit/mtpro-persistence-validation-repair-v1-stage-code-audit.md` 记录 Persistence validation baseline 已恢复。
- `Package.swift` 当前仍是 compatibility envelope；本 planning record 不授权立即修改。
- `ExecutionClient` 只作为 future gate / protocol boundary，不代表 broker gateway implementation。
- 当前 Trader 权威口径为：

```text
Trader = Accounts + Strategies/EMA + Coordination
```

- 当前唯一 active concrete strategy 是 `EMA`。
- `L4 Live Production / Trading Commands` 仍为 Future Gated。

## Milestones

| Milestone | 目标 |
| --- | --- |
| M1 Target Graph Contract | 固定 SwiftPM target graph 方案、模块命名、依赖方向、兼容期边界和禁止路径。 |
| M2 Foundation Spine | 建立 `DomainModel / MessageBus / Database` 等底层 target，确保上层模块依赖 foundation spine，而 foundation 不反向依赖 runtime / UI。 |
| M3 Data / Cache Boundary | 建立 `DataClient / DataEngine / Cache` 编译边界，保持 public market data 与 replay / catalog / cache 语义分离。 |
| M4 Trader / Portfolio / Risk / Execution Boundary | 建立 `Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient` target 边界，保持 Trader-owned EMA、future-gated `ExecutionClient` 和 no broker implementation。 |
| M5 Workbench / Dashboard Consumption Boundary | 建立 Workbench / Dashboard target consumption boundary，确保 UI 只消费 Read Model / ViewModel，不读取 database schema、runtime object 或 adapter request。 |
| M6 Compatibility Envelope Retirement | 移除旧聚合 target、stale excludes、旧 import anchor 和不再需要的 compatibility shell。 |
| M7 Validation Closeout | 收口 target graph evidence、automation readiness、forbidden path audit 和 stage audit input material。 |

## Suggested issue order

1. Define SwiftPM target graph split contract and dependency direction
2. Split DomainModel / MessageBus / Database foundation targets
3. Split DataClient / DataEngine / Cache targets
4. Split Trader / Portfolio / RiskEngine targets with EMA-only strategy boundary
5. Split ExecutionEngine / ExecutionClient future gate targets
6. Split Workbench / Dashboard read-model-only consumption targets
7. Retire obsolete compatibility envelopes and stale target anchors
8. Close target graph validation matrix / automation readiness / stage audit input

## Dependencies

- Issue 2 blocked by Issue 1
- Issue 3 blocked by Issue 1, Issue 2
- Issue 4 blocked by Issue 1, Issue 2
- Issue 5 blocked by Issue 2, Issue 4
- Issue 6 blocked by Issue 3, Issue 4, Issue 5
- Issue 7 blocked by Issue 3, Issue 4, Issue 5, Issue 6
- Issue 8 blocked by Issue 7

## Candidate issue summaries

| Issue | Summary | Boundary |
| --- | --- | --- |
| Issue 1 | 定义 SwiftPM target graph split contract、target naming、dependency direction、compatibility envelope 和 forbidden import path。 | Contract / docs / validation anchors only；不修改 `Package.swift`，不移动 `Sources`。 |
| Issue 2 | 拆分 `DomainModel / MessageBus / Database` foundation targets。 | 只建立 foundation compile boundary；不改变 persistence behavior，不新增 runtime。 |
| Issue 3 | 拆分 `DataClient / DataEngine / Cache` targets。 | 保持 `DataClient/<venue>` 为 public market data adapter boundary；不接 signed endpoint 或 account endpoint。 |
| Issue 4 | 拆分 `Trader / Portfolio / RiskEngine` targets，并保持 EMA-only strategy boundary。 | `Trader = Accounts + Strategies/EMA + Coordination`；不实现 Trader runtime、Strategy runtime 或真实账户读取。 |
| Issue 5 | 拆分 `ExecutionEngine / ExecutionClient` future gate targets。 | `ExecutionClient` 只作为 future gate / protocol boundary；不实现 broker gateway、OMS 或真实订单。 |
| Issue 6 | 拆分 `Workbench / Dashboard` read-model-only consumption targets。 | UI 只消费 Read Model / ViewModel；不暴露 runtime object、database schema、adapter request、account payload 或 broker state。 |
| Issue 7 | 退休 obsolete compatibility envelopes、stale excludes 和旧 target anchors。 | 不引入新 runtime capability；不恢复 `Sources/Strategies` 或 `StrategyBindings` active path。 |
| Issue 8 | 收口 target graph validation matrix、automation readiness 和 stage audit input material。 | 只准备 stage audit input；最终 Stage Code Audit Report 由 Parent Codex 单独输出。 |

## Validation requirements

每个 issue 必须运行：

- `git diff --check`
- `bash checks/run.sh`

按 issue scope 额外验证：

- `Package.swift` target graph 与 architecture module boundary 一致。
- SwiftPM targets 可 build / test。
- 模块 import direction 不出现反向依赖。
- Dashboard / Workbench 只消费 Read Model / ViewModel。
- `ExecutionClient` 只保留 future gate / protocol boundary。
- `Trader = Accounts + Strategies/EMA + Coordination`。
- EMA 是唯一 active concrete strategy。
- 无 active `Sources/Strategies` canonical path。
- 无 active `Sources/Trader/StrategyBindings` canonical path。
- 不存在 signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- 不存在 broker gateway、OMS、`ExecutionClient` implementation。
- 不存在 real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation。
- 不新增 Live PRO Console、trading button、live command 或 order form。
- Persistence repair baseline 不回退。

## Evidence requirements

每个 PR 必须包含：

- Linked Linear Issue。
- Scope / Non-goals。
- changed paths summary。
- target graph / dependency direction evidence。
- import boundary evidence。
- validation output。
- forbidden capability evidence。
- no L4 / live / broker / OMS evidence。
- no Symphony / no Graphify / no Figma evidence。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。

涉及 production code 的 PR 必须补充详细中文注释，说明模块边界、依赖方向和禁止 live / broker capability 的原因。

Issue 8 只准备 stage audit input material，不输出最终 Stage Code Audit Report。Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

Issue 1：`Define SwiftPM target graph split contract and dependency direction`

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
- 不移动 `Sources` 文件。
- 不修改 `Package.swift` target graph。
- 不拆 SwiftPM target graph。
- 不修改 architecture module layout。
- 不实现 Trader runtime、Strategy runtime、Live runtime、`ExecutionClient` implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。
