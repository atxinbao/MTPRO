# MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1 — GH-376 Baseline

日期：2026-06-05

执行者：Codex

GitHub Issue：[#376](https://github.com/atxinbao/MTPRO/issues/376)

类型：architecture completion review baseline / evidence inventory

## 定位

本文档是 `MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1` 的第一个执行输入材料，用于建立后续 architecture graph completion review 的事实基线。它只记录当前证据，不修改 `Package.swift`，不移动 `Sources`，不拆 SwiftPM target graph，不实现 runtime，也不推进 L4。

当前使用 GitHub Issues 作为临时 queue，因为 Linear connector 当前不可用。GitHub queue 只用于记录 Backlog / non-executable / in-progress 状态，不改变 MTPRO 的执行边界。

## 当前 HEAD

| Item | Evidence |
| --- | --- |
| Repository | `atxinbao/MTPRO` |
| Branch | `main` |
| Issue execution branch | `codex/gh-376-architecture-review-baseline` |
| HEAD before GH-376 edits | `fef5be7` |
| Planning record | `docs/planning/projects/mtpro-architecture-graph-completion-review-l4-readiness-planning-v1-plan.md` |

说明：planning record 中的 `3226441 Retire Workbench and AppCompatibility active modules (#374)` 是 Human 确认 planning draft 时的基线；GH-376 执行时 `main` 已包含 docs-only planning record merge，因此当前 review execution baseline 是 `fef5be7`。

## Authority anchors

| Authority | Role |
| --- | --- |
| `architecture.md` | 根级 architecture graph / module boundary 权威入口 |
| `environment.md` | 环境、外部系统、tooling 和禁区边界入口 |
| `Package.swift` | SwiftPM target graph 当前事实源 |
| `docs/architecture/module-boundary.md` | 模块边界、dependency direction、forbidden dependency 和 future gate |
| `docs/domain/context.md` | domain / bounded context 口径 |
| `docs/contracts/swiftpm-target-graph-split-contract.md` | SwiftPM target graph split contract |
| `docs/contracts/targetgraph-anchor-retirement-real-module-source-root-migration-contract.md` | top-level `Sources/TargetGraph` retirement 和 real module root 迁移证据 |
| `docs/validation/latest-verification-summary.md` | latest verification and closure summary |
| `verification.md` | chronological validation ledger |

## Active source root inventory

| Architecture module | Current source root | Current state |
| --- | --- | --- |
| `DomainModel` | `Sources/DomainModel` | real module root exists；compiled target source is boundary anchor |
| `MessageBus` | `Sources/MessageBus` | real module root exists；compiled target source is boundary anchor |
| `Database` | `Sources/Database` | real module root exists；projection implementation remains under compatibility envelope |
| `DataClient` | `Sources/DataClient` | real module root exists；Binance public market data implementation remains under `Adapters` compatibility target |
| `DataEngine` | `Sources/DataEngine` | real module root exists；scenario / quality / ingest ownership still split across `Core` and `Runtime` envelopes |
| `Cache` | `Sources/Cache` | real module root exists；market data cache implementation remains under `Core` compatibility target |
| `Portfolio` | `Sources/Portfolio` | real module root exists；projection implementation remains under `Core` compatibility target |
| `RiskEngine` | `Sources/RiskEngine` | real module root exists；pre-trade and live-gate evidence remain under `Core` compatibility target |
| `ExecutionClient` | `Sources/ExecutionClient` | real module root exists；future gate / protocol boundary only, no broker implementation |
| `ExecutionEngine` | `Sources/ExecutionEngine` | real module root exists；paper / simulated / OMS future-gate evidence remains under `Core` compatibility target |
| `TraderStrategies` | `Sources/Trader/Strategies/EMA` | EMA-only active concrete strategy path exists；compiled target source is boundary anchor |
| `Trader` | `Sources/Trader` | `Accounts + Strategies/EMA + Coordination` exists；compiled target source is boundary anchor |
| `Dashboard` | `Sources/Dashboard` | active UI surface；read-model-only boundary |

## Retired active paths

| Path / concept | Current status |
| --- | --- |
| `Sources/TargetGraph` | retired as top-level active directory |
| `Sources/Workbench` | retired as active source path |
| `Sources/AppCompatibility` | retired as active source path |
| `Sources/Strategies` | retired as active source path |
| `Sources/Trader/StrategyBindings` | retired as active source path |

## Compatibility envelope inventory

| Envelope | Current role | Review implication |
| --- | --- | --- |
| `Core` | Retains broad domain, message bus, cache, trader, portfolio, risk, execution and strategy implementation ownership. | Main architecture completion blocker; downstream review must decide what can stay before L4 and what must migrate. |
| `Adapters` | Retains public read-only Binance market data adapter implementation. | DataClient is not yet fully independent implementation owner. |
| `Persistence` | Retains SQLite / DuckDB projection implementation. | Database target does not yet own all persistence implementation. |
| `Runtime` | Retains ingest / replay projection implementation. | Must remain non-live; downstream review must decide if this envelope blocks L4 planning. |

## SwiftPM target graph baseline

Current products / targets include:

- Architecture graph targets：`DomainModel`, `MessageBus`, `Database`, `DataClient`, `DataEngine`, `Cache`, `Portfolio`, `RiskEngine`, `ExecutionClient`, `ExecutionEngine`, `TraderStrategies`, `Trader`, `Dashboard`
- Retained compatibility targets：`Core`, `Adapters`, `Persistence`, `Runtime`

Current pattern:

- Architecture graph target paths point to real module roots.
- Most architecture graph targets still compile only module-local `TargetGraph/*TargetBoundary.swift` files.
- Real implementation ownership is still partly retained by compatibility targets.
- `Dashboard` is the active UI executable and directly consumes read-model / ViewModel surfaces.

This baseline does not authorize target graph changes.

## Validation evidence inventory

Required validation commands for GH-376:

- `git diff --check`
- `bash checks/run.sh`

Expected evidence surface:

- Dashboard smoke remains read-model-only.
- XCTest count remains green.
- No `Sources/TargetGraph` top-level path returns.
- No `Sources/Workbench` / `Sources/AppCompatibility` active path returns.
- No `Package.swift` modification.
- No source move.
- No SwiftPM target graph split.

## Boundary evidence

- No Linear write.
- No Todo promotion outside GitHub fallback queue.
- No Symphony / symphony-issue.
- No Graphify / code-index.
- No Figma changes.
- No business code changes.
- No `Package.swift` changes.
- No `Sources` move.
- No SwiftPM target graph split.
- No Trader runtime.
- No Strategy runtime.
- No Live runtime.
- No `ExecutionClient` implementation.
- No OMS.
- No broker gateway.
- No signed endpoint.
- No account endpoint / listenKey.
- No private WebSocket runtime.
- No real order lifecycle.
- No submit / cancel / replace.
- No execution report / broker fill / reconciliation.
- No Live PRO Console, trading button, live command or order form.
- No L4 implementation.

## Downstream handoff

GH-376 enables downstream GitHub issues to use a stable baseline:

- GH-377 can audit real module source roots versus compatibility envelopes.
- GH-378 can review DataClient / DataEngine / MessageBus / Cache / Database alignment.
- GH-379 can review Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient future gates.
- GH-380 can review Dashboard read-model-only boundary and retired Workbench / AppCompatibility paths.
- GH-381 can define L4 readiness gate and blockers.
- GH-382 can close validation matrix and handoff material.
