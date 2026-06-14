# MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1 Planning Record

日期：2026-06-05

执行者：Codex

类型：docs-only planning record / non-executable

## 文档定位

本文档只保存 `MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1` 的 Project 级计划摘要、architecture graph completion matrix、L4 readiness gate、issue order、dependencies、validation、evidence、first executable candidate、WIP=1 和边界。它不是 Linear issue body 的长期副本，也不授权执行。

本 planning record 不修改 `Package.swift`，不移动 `Sources`，不拆 SwiftPM target graph，不写业务代码，不创建 Linear Project / Issue，不推进 Todo，不启动 Symphony / Graphify / code-index。

## Project Summary

| 字段 | 内容 |
| --- | --- |
| Project name | `MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1` |
| Target maturity | `Pre-L4 Architecture Graph Completion Review / L4 Readiness Planning Gate` |
| Target modules | `DataClient`、`DataEngine`、`MessageBus`、`Cache`、`Database`、`Trader`、`TraderStrategies / EMA`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient`、`Dashboard read-model-only boundary`、compatibility envelope `Core / Adapters / Persistence / Runtime` |
| Goal | 复核 `main` 是否完成 architecture graph 对齐，并形成进入 L4 planning 前的 readiness gate |
| Current baseline | `Sources/TargetGraph`、`Sources/Workbench`、`Sources/AppCompatibility` 已退休；`Package.swift` 不再使用 `path: "Sources/TargetGraph..."`；`Core / Adapters / Persistence / Runtime` 仍保留 compatibility envelope |

## Scope / Non-goals

| Scope | Non-goals |
| --- | --- |
| 复核 real module source root、SwiftPM target path、compiled boundary anchor、retained implementation owner | 不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo |
| 复核 `DataClient / DataEngine / MessageBus / Cache / Database` 对齐状态 | 不启动 `@002 / PAR`、Symphony、Graphify、code-index 或 Figma |
| 复核 `Trader = Accounts + Strategies/EMA + Coordination` 对齐状态 | 不修改 `Package.swift`，不移动 `Sources`，不拆 SwiftPM target graph |
| 复核 `Portfolio / RiskEngine / ExecutionEngine / ExecutionClient` future gate | 不实现 Trader / Strategy / Live runtime、ExecutionClient、OMS、broker gateway |
| 输出 L4 readiness gate、blocker、cleanup / planning order | 不接 signed endpoint、account endpoint / listenKey、private WebSocket、real order lifecycle、Live PRO Console、trading button、live command、order form |

## Authority Anchors

- `architecture.md`
- `environment.md`
- `Package.swift`
- `docs/architecture/module-boundary.md`
- `docs/domain/context.md`
- `docs/contracts/swiftpm-target-graph-split-contract.md`
- `docs/contracts/targetgraph-anchor-retirement-real-module-source-root-migration-contract.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

## Architecture Graph Completion Matrix

| Module group | Completion status | Gap / next action |
| --- | --- | --- |
| `DomainModel` / `MessageBus` / `Database` | target path 已是真实 root，部分 implementation 仍由 compatibility envelope 编译 | 审计 implementation ownership，决定是否继续迁入真实 target |
| `DataClient` / `DataEngine` / `Cache` | public read-only / ingest / replay / cache boundary 已有 | 审计 Adapters / Runtime retained implementation，确保 signed/private/prod 仍 gated |
| `Trader` / `TraderStrategies / EMA` | Trader-owned layout 和 EMA active path 已固定 | 清理 historical wording，禁止 strategy -> ExecutionClient / broker shortcut |
| `Portfolio` / `RiskEngine` / `ExecutionEngine` | paper / simulated / blocked evidence 已有 | L4 前必须确认 real target ownership 和 compatibility envelope debt |
| `ExecutionClient` | capability boundary 存在，implementation 仍 gated | L4 planning 前只允许 testnet / sandbox / dry-run scope |
| `Dashboard` | active UI surface 是 read-model-only Dashboard | 不能把 Dashboard 变成 Live PRO Console 或 production command surface |

## L4 Readiness Gate

已满足项：

- top-level `Sources/TargetGraph`、`Workbench`、`AppCompatibility` 已退休。
- root docs 记录 module boundary、read-model-only Dashboard、Future Construction Zones。
- production trading disabled by default。

必须先完成或保持的 blocker：

- retained compatibility envelope matrix 可解释。
- ExecutionClient / OMS / broker gateway / signed endpoint / account endpoint 仍无默认授权。
- active issue / PR / queue conflict = 0。
- no-default-production-trading guard 继续通过。

可进入 L4 planning 的条件：

1. Human 明确选择 L4 planning。
2. Project Planning Record 明确 issue order、dependencies、validation、forbidden capabilities。
3. Linear 或 approved fallback queue 写入后，Parent Codex 按 WIP=1 做 queue preflight。
4. 唯一 eligible issue 才能进入 execution。

## Suggested Issue Order

1. architecture graph completion terminology。
2. retained compatibility envelope audit。
3. real module source root smoke evidence。
4. Dashboard read-model-only boundary review。
5. L4 planning input matrix closeout。

## Validation Requirements

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- targeted architecture / target graph tests if issue body requires them

## Final Boundary

本文档是 planning evidence，不授权 execution、runtime、broker、OMS、Live PRO Console、production trading 或任何真实订单能力。
