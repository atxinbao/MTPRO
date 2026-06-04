# MTPRO Project Planning Records

日期：2026-05-18

执行者：Codex

本文档是 MTPRO Project Planning Record 的入口索引和统一规则文档。

本文档不授权 Codex 执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不启动 `@002 / PAR`、Symphony / symphony-issue、Graphify / code-index，不授权 Binance、策略、UI、数据库适配器、SwiftPM target graph split 或任何 runtime 实现。

## 职责

本文档只承担以下职责：

1. Project Planning Record 入口索引。
2. Project Planning Record 命名规则。
3. Project Planning Record 内容规则。
4. Linear write boundary。
5. Repository record boundary。
6. 当前 Project planning record 指向。

历史 Project planning 内容已迁移到 `docs/planning/projects/`。

## Project Planning Record 索引

| Project | Planning Record | 状态 |
| --- | --- | --- |
| `MTPRO 引导` | `docs/planning/projects/mtpro-guidance-plan.md` | 已写入 Linear；Project 已完成；Stage Code Audit Report 已落仓。 |
| `MTPRO Runtime Research Workbench v1` | `docs/planning/projects/mtpro-runtime-research-workbench-v1-plan.md` | 已写入 Linear；`MTP-16` 至 `MTP-23` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Trading Validation and Parity Hardening` | `docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md` | 已写入 Linear；`MTP-24` 至 `MTP-30` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Paper Session Runtime v1` | `docs/planning/projects/mtpro-paper-session-runtime-v1-plan.md` | 已写入 Linear；`MTP-31` 至 `MTP-37` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Paper Execution Workflow v1` | `docs/planning/projects/mtpro-paper-execution-workflow-v1-plan.md` | 已写入 Linear；canonical issues 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Paper Workflow Control Shell v1` | `docs/planning/projects/mtpro-paper-workflow-control-shell-v1-plan.md` | 已写入 Linear；`MTP-47` 至 `MTP-53` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Market Data Replay Operations v1` | `docs/planning/projects/mtpro-market-data-replay-operations-v1-plan.md` | 已写入 Linear；`MTP-54` 至 `MTP-60` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Live Trading Boundary Definition v1` | `docs/planning/projects/mtpro-live-trading-boundary-definition-v1-plan.md` | 已写入 Linear；`MTP-61` 至 `MTP-67` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Live Monitoring Console v1` | `docs/planning/projects/mtpro-live-monitoring-console-v1-plan.md` | 已写入 Linear；`MTP-68` 至 `MTP-74` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Live Execution Control Contract v1` | `docs/planning/projects/mtpro-live-execution-control-contract-v1-plan.md` | 已写入 Linear；`MTP-75` 至 `MTP-81` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Live Risk Gate Contract v1` | `docs/planning/projects/mtpro-live-risk-gate-contract-v1-plan.md` | 已写入 Linear；`MTP-82` 至 `MTP-88` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Live Audit Incident Stop Boundary v1` | `docs/planning/projects/mtpro-live-audit-incident-stop-boundary-v1-plan.md` | 已写入 Linear；`MTP-89` 至 `MTP-95` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Event-Driven Paper Trading Runtime v1` | `docs/planning/projects/mtpro-event-driven-paper-trading-runtime-v1-plan.md` | 已写入 Linear；`MTP-96` 至 `MTP-102` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Data Catalog / Scenario Replay v1` | `docs/planning/projects/mtpro-data-catalog-scenario-replay-v1-plan.md` | 已写入 Linear；`MTP-103` 至 `MTP-109` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Simulated Exchange / Backtest Parity v1` | `docs/planning/projects/mtpro-simulated-exchange-backtest-parity-v1-plan.md` | 已写入 Linear；`MTP-110` 至 `MTP-117` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Workbench Beta Readiness v1` | `docs/planning/projects/mtpro-workbench-beta-readiness-v1-plan.md` | 已写入 Linear；`MTP-118` 至 `MTP-125` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Live Read-only Readiness Boundary v1` | `docs/planning/projects/mtpro-live-read-only-readiness-boundary-v1-plan.md` | 已写入 Linear；`MTP-126` 至 `MTP-132` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Account / Position / Balance Read-model-only v1` | `docs/planning/projects/mtpro-account-position-balance-read-model-only-v1-plan.md` | 已写入 Linear；`MTP-133` 至 `MTP-139` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Private Stream / Account Snapshot Simulation Gate v1` | `docs/planning/projects/mtpro-private-stream-account-snapshot-simulation-gate-v1-plan.md` | 已写入 Linear；`MTP-140` 至 `MTP-146` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Live Monitoring Read-only Console v2` | `docs/planning/projects/mtpro-live-monitoring-read-only-console-v2-plan.md` | 已写入 Linear；`MTP-147` 至 `MTP-153` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Strategy / Trader Instance Readiness v1` | `docs/planning/projects/mtpro-strategy-trader-instance-readiness-v1-plan.md` | 已写入 Linear；`MTP-154` 至 `MTP-161` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Engine Module Boundary Consolidation v1` | `docs/planning/projects/mtpro-engine-module-boundary-consolidation-v1-plan.md` | 已写入 Linear；`MTP-162` 至 `MTP-182` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Target Module Physical Layout / Source Migration v1` | `docs/planning/projects/mtpro-target-module-physical-layout-source-migration-v1-plan.md` | 已写入 Linear；`MTP-183` 至 `MTP-190` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。Historical first executable issue candidate：`Define target module physical layout and SwiftPM migration contract`。 |
| `MTPRO Trader-Owned Strategies Layout Correction v1` | `docs/planning/projects/mtpro-trader-owned-strategies-layout-correction-v1-plan.md` | 已写入 Linear；`MTP-191` 至 `MTP-197` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Trader EMA Strategy Layout Consolidation v1` | `docs/planning/projects/mtpro-trader-ema-strategy-layout-consolidation-v1-plan.md` | 已写入 Linear；`MTP-198` 至 `MTP-204` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Trader Accounts / Coordination Compatibility Consolidation v1` | `docs/planning/projects/mtpro-trader-accounts-coordination-compatibility-consolidation-v1-plan.md` | 已写入 Linear；`MTP-205` 至 `MTP-211` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO Persistence Validation Repair v1` | `docs/planning/projects/mtpro-persistence-validation-repair-v1-plan.md` | 已写入 Linear；`MTP-213` 至 `MTP-215` 已完成；`MTP-212` 为 Duplicate / non-canonical；Linear Project closure flow 已完成；Stage Code Audit Report 已落仓。 |
| `MTPRO SwiftPM Target Graph Module Split v1` | `docs/planning/projects/mtpro-swiftpm-target-graph-module-split-v1-plan.md` | 已写入 Linear；`MTP-216` 至 `MTP-223` 已完成；Linear Project status `Completed`；Stage Code Audit Report 已落仓。 |
| `MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` | `docs/planning/projects/mtpro-targetgraph-anchor-retirement-real-module-source-root-migration-v1-plan.md` | 当前 docs-only planning record / non-executable；未写入 Linear；不创建 Linear，不推进 Todo；只规划 `Sources/TargetGraph` 过渡锚点退休和真实模块 source root 迁移，不授权修改 `Package.swift`、移动 `Sources`、拆 target 或实现 runtime。 |

## 当前 Project planning record

- 当前仓库只保存 `MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` 的 docs-only / non-executable planning record 作为当前 planning entry。
- 当前 Project / active issue / Todo / In Progress / In Review 状态必须从 Linear live-read 和 Parent Codex queue preview 获取。
- `MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration v1` 仍未写入 Linear，不创建 Linear Project / Issue，不推进 Todo，不授权 `Package.swift` target graph change、SwiftPM target split、source move 或 runtime implementation。
- 下一步必须由 Human 明确授权 Linear 写入；Linear 写入后所有 issues 仍必须保持 `Backlog / non-executable`，再由 Parent Codex queue preflight 才能推进唯一 eligible issue。
- `MTPRO SwiftPM Target Graph Module Split v1` 已完成 closure；其 planning record 只作为 historical planning evidence 保留，不再表示当前 queue。
- `MTPRO Persistence Validation Repair v1` 已完成 closure；其 planning record 只作为 historical planning evidence 保留，不再表示当前 queue。
- 历史 planning record 保留 `当前 docs-only planning record / non-executable` 语义：只代表已落仓计划证据，不代表 execution authorization。

## Project Planning Record 命名规则

- 所有 Project planning record 必须放在 `docs/planning/projects/`。
- 文件名格式：`<linear-project-slug>-plan.md`。
- slug 使用 Project name 的小写 kebab-case。
- 文件名不放日期。
- 一个 Linear Project 对应一份 canonical planning record。

## Project Planning Record 内容规则

每份 Project planning record 必须包含：

1. `Project name`
2. `Project goal`
3. `Scope`
4. `Non-goals`
5. `Issue order`
6. `Dependencies`
7. `Validation requirements`
8. `Evidence requirements`
9. `First executable issue candidate`
10. `WIP=1`
11. `Linear write boundary`
12. `Repository record boundary`

每份 Project planning record 只保留 Project 级计划摘要、issue order、dependencies、validation、evidence、first executable candidate、WIP=1 和边界。

仓库只保存 Project 级计划摘要和格式门槛，不复制维护完整 issue 正文。

不得复制维护完整 issue 正文。历史内容里如果存在完整 issue body，迁移时必须压缩成 issue list 摘要。

## Linear write boundary

- planning record 不创建 Linear Project。
- planning record 不创建 Linear Issues。
- planning record 不修改 Linear status。
- Human review / merge 后，才允许进入 Linear 写入。
- Linear 写入后，所有 issue 初始必须保持 Backlog / non-executable。
- 完整 issue execution contract 以 Linear issue body 为准。

## Repository record boundary

- 仓库只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 issue 正文。
- 后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## 执行边界

- `docs/roadmap.md` 不授权执行。
- Project Planning Record 不授权执行。
- Project Planning Facilitator 不操作 `Backlog` -> `Todo`。
- 只有父 Codex 可以操作 `Backlog` -> `Todo`。
- 只有父 Codex 可以在 Human-approved Project 内，通过 queue preflight、WIP=1、依赖、previous issue Done 和 execution contract gate 后，操作唯一 eligible issue 的 `Backlog` -> `Todo`。
- MTPRO 不再使用 Symphony / symphony-issue 或 Graphify；任何执行调度都不能绕过 Parent Codex queue preflight。
- Codex Execution Agent 只执行当前唯一 Linear issue scope。

## Next Human Project Planning 前置 Gate

当前 Project 全部有效 issues `Done` 后，必须先完成 Linear Project closure：

- Linear Project status 必须设置或确认为 `Completed`。
- Linear Project status type 必须是 `completed`。
- Linear Project `completedAt` 必须非空。
- 仅有全部 issues `Done`、PR 全部合并、Post-Issue Ledger passed 或会话输出，都不能替代 Linear Project status `Completed`。

Project closure evidence 完成后，必须按以下顺序进入下一轮规划：

```text
Linear Project status Completed
-> Stage Code Audit Report
-> Root Docs Refresh Gate
-> Next Human Project Planning
```

Root Docs Refresh Gate 只同步已发生事实：

- `GOAL.md`：目标、用户、成功标准或安全边界事实变化。
- `environment.md`：工具、运行方式、Graphify、Symphony、GitHub、Linear、本地依赖或 CI 环境事实变化。
- `architecture.md`：已稳定落地的功能模块、边界、依赖方向和数据流。
- `docs/roadmap.md`：阶段状态、已完成 Project 和下一阶段 planning input；不授权执行。

`@002 / PAR` 可以开 factual refresh PR。下一阶段方向、目标、架构路线和优先级必须由 Human + `@001 / PLN` 决定。
