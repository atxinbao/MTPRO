# MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1 Planning Record

日期：2026-06-04

执行者：Codex

类型：docs-only planning record / non-executable

## 文档定位

本文档只保存 `MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` 的 Project 级计划摘要、milestones、issue order、dependencies、validation、evidence、first executable candidate、WIP=1 和边界。它不是 Linear issue body 的长期副本，也不授权执行。

完整 issue scope、Codex Instructions、Validation、Boundary、PR Requirements 和 Acceptance Criteria 以后续 Linear issue body 为准。

本 planning record 不修改 `Package.swift` target graph，不拆 SwiftPM targets，不移动 `Sources`，不写业务代码。`Sources/TargetGraph` 是过渡编译锚点，不是最终架构模块；本 Project 的目标是后续把 target boundary anchors 迁回真实模块目录。MTPRO 不再使用 Symphony / Graphify；本 Project 后续执行也不得引入 Symphony handoff marker、Graphify output 或相关调度要求。

## Project name

`MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1`

## Project goal

将 `Sources/TargetGraph` 从 active SwiftPM target source root 收口为历史过渡 evidence，并把 target graph 的编译边界、依赖方向、forbidden dependency guard 迁入真实模块目录。

完成后，`Package.swift` 不再依赖 `Sources/TargetGraph/*` 作为 active target path，SwiftPM target path 逐步对齐真实架构模块目录。

## Target maturity

`Real module source root aligned SwiftPM target graph baseline`

## Target Engines / Modules

- `DomainModel` -> `Sources/DomainModel`
- `MessageBus` -> `Sources/MessageBus`
- `Database` -> `Sources/Database`
- `DataClient` -> `Sources/DataClient`
- `DataEngine` -> `Sources/DataEngine`
- `Cache` -> `Sources/Cache`
- `Portfolio` -> `Sources/Portfolio`
- `RiskEngine` -> `Sources/RiskEngine`
- `ExecutionClient` -> `Sources/ExecutionClient`
- `ExecutionEngine` -> `Sources/ExecutionEngine`
- `TraderStrategies` / strategy boundary -> `Sources/Trader/Strategies/EMA`
- `Trader` -> `Sources/Trader`
- `Workbench` -> `Sources/Workbench`
- `Dashboard` -> `Sources/Dashboard`

## Scope

- 审计当前 `Sources/TargetGraph/*`、真实 `Sources/<Module>/`、`Package.swift` 和 `Tests/TargetGraphTests`。
- 定义 TargetGraph retirement contract。
- 迁移 foundation targets：`DomainModel / MessageBus / Database`。
- 迁移 data targets：`DataClient / DataEngine / Cache`。
- 迁移 trader / portfolio / risk targets：`Trader / TraderStrategies / Portfolio / RiskEngine`。
- 迁移 execution targets：`ExecutionEngine / ExecutionClient` future gate。
- 迁移 Workbench / Dashboard target boundary。
- 更新 tests：`TargetGraphTests` 转为 module boundary / target split tests。
- 清理 root docs 中把 `Sources/TargetGraph` 当 active path 的表述。
- 收口 validation matrix、automation readiness 和 stage audit input。

## Non-goals

- 不创建 Linear Project / Issue。
- 不修改 Linear status。
- 不推进 Todo。
- 不启动 `@002 / PAR`。
- 不启动 Symphony / symphony-issue。
- 不运行 Graphify / code-index。
- 不修改 Figma。
- 不修改 `Package.swift`。
- 不拆 SwiftPM target graph。
- 不移动 `Sources` 文件。
- 不写业务代码。
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
- 不把 `Sources/TargetGraph` retirement 写成 architecture redesign。
- 不把 target source root migration 写成 runtime implementation。

## Current authority anchors

- `architecture.md` 和 `docs/architecture/module-boundary.md` 是当前 architecture module boundary 的权威入口。
- `environment.md` 是当前环境、外部系统和禁区边界入口。
- `docs/contracts/swiftpm-target-graph-split-contract.md` 记录当前 SwiftPM target graph split contract 和 TargetGraph compiled boundary roots。
- `Package.swift` 当前仍通过 `Sources/TargetGraph/*` 提供部分 active target path；本 planning record 不授权立即修改。
- `Sources/TargetGraph` 是过渡编译锚点；真实模块 source roots 才是后续目标落点。
- 当前 Trader 权威口径为：

```text
Trader = Accounts + Strategies/EMA + Coordination
```

- 当前唯一 active concrete strategy 是 `EMA`。
- `ExecutionClient` 仍只是 future gate / protocol boundary，不是 broker gateway implementation。
- `L4 Live Production / Trading Commands` 仍为 Future Gated。

## Milestones

| Milestone | 目标 |
| --- | --- |
| M1 Retirement Contract | 定义 `Sources/TargetGraph` 的历史过渡定位、active path 退休规则、真实模块 root 迁移顺序和兼容期判断标准。 |
| M2 Foundation Migration | 将 `DomainModel / MessageBus / Database` target path 迁入真实模块目录，并验证 foundation dependency direction 不变。 |
| M3 Data Migration | 将 `DataClient / DataEngine / Cache` target path 迁入真实模块目录，保持 public data / replay / cache 边界清晰。 |
| M4 Trader / Portfolio / Risk Migration | 将 `Trader / TraderStrategies / Portfolio / RiskEngine` target path 迁入真实模块目录，保持 `Trader = Accounts + Strategies/EMA + Coordination`，并保持 EMA-only active strategy。 |
| M5 Execution Future Gate Migration | 将 `ExecutionEngine / ExecutionClient` target path 迁入真实模块目录，保持 `ExecutionClient` 仅为 future gate / protocol boundary。 |
| M6 Workbench / Dashboard Migration | 将 Workbench / Dashboard target boundary 迁入真实模块目录，继续只消费 Read Model / ViewModel。 |
| M7 Anchor Retirement Closeout | 退休 active `Sources/TargetGraph/*` path references，更新 tests、validation anchors、root docs 和 stage audit input material。 |

## Suggested issue order

1. Define TargetGraph retirement and real module source root migration contract
2. Audit current TargetGraph anchors, real module roots, Package.swift and tests
3. Migrate foundation targets to real module roots
4. Migrate data targets to real module roots
5. Migrate Trader / TraderStrategies / Portfolio / RiskEngine targets to real module roots
6. Migrate ExecutionEngine / ExecutionClient future gate targets to real module roots
7. Migrate Workbench / Dashboard target boundaries to real module roots
8. Retire `Sources/TargetGraph` active path references and update validation anchors
9. Close validation matrix / compatibility envelope / stage audit input

## Dependencies

- Issue 2 blocked by Issue 1
- Issue 3 blocked by Issue 2
- Issue 4 blocked by Issue 3
- Issue 5 blocked by Issue 3
- Issue 6 blocked by Issue 5
- Issue 7 blocked by Issue 4, Issue 5, Issue 6
- Issue 8 blocked by Issue 3, Issue 4, Issue 5, Issue 6, Issue 7
- Issue 9 blocked by Issue 8

## Candidate issue summaries

| Issue | Summary | Boundary |
| --- | --- | --- |
| Issue 1 | 定义 TargetGraph retirement contract、real module source root target path、dependency direction 和 forbidden path taxonomy。 | Contract / docs / validation anchors only；不修改 `Package.swift`，不移动 `Sources`。 |
| Issue 2 | 审计当前 `Sources/TargetGraph/*` anchors、真实模块 roots、`Package.swift` 和 `TargetGraphTests`。 | 只做 audit / evidence；不执行迁移。 |
| Issue 3 | 迁移 `DomainModel / MessageBus / Database` foundation targets 到真实模块目录。 | 保持 foundation dependency direction，不改变 persistence behavior。 |
| Issue 4 | 迁移 `DataClient / DataEngine / Cache` data targets 到真实模块目录。 | 保持 public read-only data / replay / cache 边界，不接 signed / account endpoint。 |
| Issue 5 | 迁移 `Trader / TraderStrategies / Portfolio / RiskEngine` targets 到真实模块目录。 | 保持 `Trader = Accounts + Strategies/EMA + Coordination`，EMA-only active strategy，不实现 runtime。 |
| Issue 6 | 迁移 `ExecutionEngine / ExecutionClient` future gate targets 到真实模块目录。 | `ExecutionClient` 仍只是 future gate / protocol boundary，不实现 broker gateway、OMS 或真实订单。 |
| Issue 7 | 迁移 Workbench / Dashboard target boundaries 到真实模块目录。 | UI 只消费 Read Model / ViewModel，不读取 runtime object、database schema、adapter request、account payload 或 broker state。 |
| Issue 8 | 退休 active `Sources/TargetGraph` path references，更新 validation anchors 和 root docs wording。 | 不引入新 runtime capability，不误删 retained compatibility implementation。 |
| Issue 9 | 收口 validation matrix、compatibility envelope 和 stage audit input material。 | 只准备 stage audit input；最终 Stage Code Audit Report 由 Parent Codex 单独输出。 |

## Validation requirements

每个 issue 必须运行：

- `git diff --check`
- `bash checks/run.sh`

按 issue scope 额外验证：

- `Package.swift` active target path 不再依赖对应 `Sources/TargetGraph/<Module>`。
- target dependency direction 不变。
- no runtime / broker / live capability。
- `Trader = Accounts + Strategies/EMA + Coordination`。
- EMA 仍是唯一 active concrete strategy。
- `ExecutionClient` 仍只是 future gate / protocol boundary。
- retained compatibility envelopes 没有误删 implementation。
- `Sources/TargetGraph` 退休后不影响 Dashboard smoke。
- `Sources/TargetGraph` 退休后不影响 XCTest baseline。
- Workbench / Dashboard 仍只消费 Read Model / ViewModel。
- 不存在 signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- 不存在 OMS / broker gateway / `ExecutionClient` implementation。
- 不新增 Live PRO Console、trading button、live command 或 order form。
- 不推进 L4。

## Evidence requirements

每个 PR 必须包含：

- Linked Linear Issue。
- Scope / Non-goals。
- changed paths summary。
- target path migration evidence。
- `Package.swift` target path evidence。
- dependency direction evidence。
- validation output。
- compatibility envelope evidence。
- forbidden capability evidence。
- no runtime / live / broker capability evidence。
- no signed endpoint / account endpoint / listenKey evidence。
- no OMS / broker gateway / `ExecutionClient` implementation evidence。
- no Live PRO Console / trading button / live command evidence。
- no Symphony / no Graphify / no Figma evidence。
- `.codex/*` 不进入 PR。
- `graphify-out/*` 不进入 PR。

涉及 production code 的 PR 必须补充详细中文注释，说明真实模块 source root、target boundary 和禁止 live / broker capability 的原因。

Issue 9 只准备 stage audit input material，不输出最终 Stage Code Audit Report。Project 全部 Done 后，Stage Code Audit Report 必须由 Parent Codex 单独输出。

## First executable issue candidate

Issue 1：`Define TargetGraph retirement and real module source root migration contract`

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
