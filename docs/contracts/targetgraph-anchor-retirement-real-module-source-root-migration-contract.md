# MTPRO TargetGraph Anchor Retirement / Real Module Source Root Migration Contract

日期：2026-06-04

执行者：Codex

本文档服务 `MTP-224 Define TargetGraph retirement and real module source root migration contract`，并承接 `MTP-225 Audit current TargetGraph anchors, real module roots, Package.swift and tests` 的 audit input。它只固定 `Sources/TargetGraph` 退休合同、真实模块 source root 迁移规则、target dependency direction、forbidden path taxonomy、current audit snapshot 和 validation anchors；不修改 `Package.swift`，不移动 `Sources` 文件，不写业务代码。

## MTP-224-TARGETGRAPH-RETIREMENT-CONTRACT

`Sources/TargetGraph` 是 transitional compile anchor / historical evidence。它用于在 MTP-217 至 MTP-221 已建立的 SwiftPM target split 中承载 target boundary anchor，使 `DomainModel`、`MessageBus`、`Database`、`DataClient`、`Cache`、`DataEngine`、`Portfolio`、`RiskEngine`、`ExecutionClient`、`ExecutionEngine`、`TraderStrategies`、`Trader`、`Workbench` 和 `Dashboard` 可以被 SwiftPM 编译和测试。

`Sources/TargetGraph` 不是最终架构模块、不是长期 source ownership、不是新的 engine layer，也不是未来 feature landing path。任何把 `Sources/TargetGraph/<Module>` 写成 final module root、architecture module root、new implementation root、runtime object owner 或 L4 capability source 的表述都必须视为过期或越界。

## MTP-224-REAL-MODULE-SOURCE-ROOT-TARGET

真实模块 source root 是后续 active target path 的目标落点。当前 canonical roots 固定为：

| Target | 后续目标 source root |
| --- | --- |
| `DomainModel` | `Sources/DomainModel/` |
| `MessageBus` | `Sources/MessageBus/` |
| `Database` | `Sources/Database/` |
| `DataClient` | `Sources/DataClient/` |
| `DataEngine` | `Sources/DataEngine/` |
| `Cache` | `Sources/Cache/` |
| `Portfolio` | `Sources/Portfolio/` |
| `RiskEngine` | `Sources/RiskEngine/` |
| `ExecutionClient` | `Sources/ExecutionClient/` |
| `ExecutionEngine` | `Sources/ExecutionEngine/` |
| `TraderStrategies` | `Sources/Trader/Strategies/EMA/` 和后续 `Sources/Trader/Strategies/<strategy>/` |
| `Trader` | `Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/`、`Sources/Trader/Coordination/` |
| `Workbench` | `Sources/Workbench/` |
| `Dashboard` | `Sources/Dashboard/` |

当前 active concrete strategy only `EMA`。后续多个策略只能进入 `Sources/Trader/Strategies/<strategy>/`，并必须继续由 `TraderStrategies` / `Trader` 边界管理。旧 peer-level `Sources/Strategies/` 和旧 `Sources/Trader/StrategyBindings/` 只能作为 historical / compatibility / superseded evidence 保留。

## MTP-224-MIGRATION-SEQUENCE-COMPATIBILITY-RULE

后续迁移必须按 WIP=1 和 Linear live issue 合同逐步执行：

1. `MTP-225` 只审计当前 `Sources/TargetGraph/*`、真实模块 roots、`Package.swift` 和 `Tests/TargetGraphTests`。
2. `MTP-226` 才能迁移 `DomainModel` / `MessageBus` / `Database` foundation targets。
3. `MTP-227` 才能迁移 `DataClient` / `DataEngine` / `Cache` data targets。
4. `MTP-228` 才能迁移 `Trader` / `TraderStrategies` / `Portfolio` / `RiskEngine` targets。
5. `MTP-229` 才能迁移 `ExecutionEngine` / `ExecutionClient` future gate targets。
6. `MTP-230` 才能迁移 `Workbench` / `Dashboard` target boundaries。
7. `MTP-231` 才能退休 active `Sources/TargetGraph` path references 并更新 validation anchors。
8. `MTP-232` 只收口 validation matrix、compatibility envelope 和 stage audit input material。

每一步迁移必须保留已授权的 compatibility envelope，直到对应 Linear issue 明确允许退休。迁移 `Package.swift` active target path 只能从 `Sources/TargetGraph/<Module>` 指向对应真实模块 source root，不能新增 runtime capability、不能删除 retained implementation、不能把 compatibility shell 当成 architecture redesign。

## MTP-224-DEPENDENCY-DIRECTION-AND-FORBIDDEN-PATH-TAXONOMY

后续真实 module source root 迁移必须保持 MTP-222 current target graph direction：

```text
DomainModel
MessageBus -> DomainModel
Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)
DataClient -> DomainModel
Cache -> DomainModel / MessageBus
DataEngine -> DomainModel / DataClient / MessageBus / Cache
Portfolio -> DomainModel / MessageBus / Cache / Database
RiskEngine -> DomainModel / MessageBus / Cache / Portfolio
ExecutionClient -> DomainModel / MessageBus
ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine / ExecutionEngine
Workbench -> Core / Persistence read-model and ViewModel exports only
App -> Workbench compatibility re-export
Dashboard -> Workbench
```

Forbidden path taxonomy 继续保持：

- `DataClient -> signed endpoint / account endpoint / listenKey / private stream runtime` 禁止。
- `TraderStrategies -> ExecutionClient / broker / OMS / Workbench / Dashboard / UI command surface` 禁止。
- `Trader -> ExecutionClient` 当前禁止；未来只能经 L4 独立 Project 重新授权。
- `Portfolio -> broker account state / account endpoint payload / signed endpoint / listenKey` 禁止。
- `RiskEngine -> broker / ExecutionClient / signed endpoint / account endpoint / listenKey` 禁止。
- `ExecutionEngine -> current OMS / broker adapter / signed endpoint / account endpoint / listenKey` 禁止。
- `ExecutionClient -> signed request / order submit / cancel / replace / execution report / broker fill / reconciliation runtime` 当前禁止。
- `Workbench -> Runtime object / Adapter request / Database schema / broker payload / account payload / trading command` 禁止。
- `Dashboard -> anything except Workbench` 禁止。

## MTP-224-NO-PACKAGE-SOURCE-MOVE-RUNTIME-GUARD

MTP-224 不授权以下动作：

- 修改 `Package.swift` target graph、products、dependencies、source roots 或 exclude list。
- 新增、删除、重命名 SwiftPM target / product / dependency。
- 移动 production source 或 tests。
- 删除 `Sources/TargetGraph`。
- 退休 active `Sources/TargetGraph/*` path references。
- 实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 启动 Symphony / symphony-issue。
- 运行 Graphify / code-index。
- 修改 Figma。
- 提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-224-VALIDATION-ANCHORS

MTP-224 required validation：

- `git diff --check`
- `bash checks/run.sh`
- PR evidence 必须确认 `Package.swift` 无 diff。
- PR evidence 必须确认未移动 `Sources` 文件。
- PR evidence 必须确认 docs 明确 `Sources/TargetGraph` 是 transitional compile anchor / historical evidence，不是最终架构模块。
- PR evidence 必须确认 docs 不授权 `Package.swift` change、source move、target split、runtime、live、broker、L4 capability。
- PR evidence 必须确认 no Symphony / no Graphify / no code-index / no Figma / no `.codex/*` / no `graphify-out/*`。

## MTP-225-TARGETGRAPH-ACTIVE-ANCHOR-AUDIT

`MTP-225` 的 audit input 固定在 `docs/audit/inputs/mtpro-targetgraph-anchor-retirement-real-module-source-root-migration-v1-mtp-225-audit.md`。该文件列出当前 active `Sources/TargetGraph/*` anchors：

- `Sources/TargetGraph/DomainModel/DomainModelTargetBoundary.swift`
- `Sources/TargetGraph/MessageBus/MessageBusTargetBoundary.swift`
- `Sources/TargetGraph/Database/DatabaseTargetBoundary.swift`
- `Sources/TargetGraph/DataClient/DataClientTargetBoundary.swift`
- `Sources/TargetGraph/DataEngine/DataEngineTargetBoundary.swift`
- `Sources/TargetGraph/Cache/CacheTargetBoundary.swift`
- `Sources/TargetGraph/Portfolio/PortfolioTargetBoundary.swift`
- `Sources/TargetGraph/RiskEngine/RiskEngineTargetBoundary.swift`
- `Sources/TargetGraph/TraderStrategies/TraderStrategiesTargetBoundary.swift`
- `Sources/TargetGraph/Trader/TraderTargetBoundary.swift`
- `Sources/TargetGraph/ExecutionClient/ExecutionClientTargetBoundary.swift`
- `Sources/TargetGraph/ExecutionEngine/ExecutionEngineTargetBoundary.swift`

这些 files 只能作为 transitional compile anchor / historical evidence。它们证明 MTP-217 至 MTP-221 target split 当前可编译，不代表 final architecture module root、长期 source ownership 或 future feature landing path。

## MTP-225-REAL-MODULE-ROOT-AUDIT

MTP-225 确认真实 source root 已存在，但当前 target path ownership 尚未迁移：

- Foundation roots：`Sources/DomainModel/`、`Sources/MessageBus/`、`Sources/Database/`。
- Data roots：`Sources/DataClient/`、`Sources/DataEngine/`、`Sources/Cache/`。
- Trader / Portfolio / Risk roots：`Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/`、`Sources/Trader/Coordination/`、`Sources/Portfolio/`、`Sources/RiskEngine/`。
- Execution roots：`Sources/ExecutionClient/`、`Sources/ExecutionEngine/`。
- Workbench / Dashboard roots：`Sources/Workbench/`、`Sources/Dashboard/`。

MTP-225 不改变上述 roots 的 compiler owner。后续只有 `MTP-226` 至 `MTP-230` 可以在各自 Linear issue scope 内迁移对应 target family。

## MTP-225-PACKAGE-TARGET-PATH-AUDIT

MTP-225 audit confirms `Package.swift` active target path snapshot remains:

```text
DomainModel / MessageBus / Database / DataClient / Cache / DataEngine /
Portfolio / RiskEngine / TraderStrategies / Trader / ExecutionClient /
ExecutionEngine -> Sources/TargetGraph/<Module>
Workbench -> path Sources with explicit Workbench and DashboardShell sources
Core / Adapters / Persistence / Runtime / App -> retained compatibility envelopes
Dashboard -> Sources/Dashboard, dependencies: Workbench
```

MTP-225 does not change `Package.swift`. Any future path change must be issue-scoped and must only move an active target path from `Sources/TargetGraph/<Module>` to the matching real source root.

## MTP-225-TARGETGRAPH-TEST-COVERAGE-AUDIT

MTP-225 audit confirms `Tests/TargetGraphTests/TargetGraphTests.swift` directly imports `DomainModel`、`MessageBus`、`Database`、`DataClient`、`DataEngine`、`Cache`、`Portfolio`、`RiskEngine`、`ExecutionClient`、`ExecutionEngine`、`TraderStrategies`、`Trader`、`Workbench` 和 `Dashboard`，并 covers:

- MTP-217 foundation target split dependency direction and no higher-layer runtime / broker / UI drift.
- MTP-218 data target split dependency direction and no signed / account / listenKey / broker / runtime drift.
- MTP-219 Trader / Portfolio / Risk dependency direction, EMA-only active strategy and no direct execution / broker / runtime drift.
- MTP-220 execution future gate dependency direction and no broker / OMS / real order / endpoint drift.
- MTP-221 Workbench / Dashboard read-model-only dependency direction and no runtime / adapter / schema / UI command drift.

Current gap: TargetGraphTests prove target boundary contracts, not real source root ownership. Future migration issues must adjust tests only after their target family actually migrates.

## MTP-225-AUDIT-VALIDATION

MTP-225 required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- PR evidence 必须确认 audit 覆盖 `Sources/TargetGraph` anchors、real module roots、`Package.swift` target path / dependencies 和 `Tests/TargetGraphTests` coverage。
- PR evidence 必须确认 `Package.swift` 无 diff、未移动 production source 或 tests、未退休 active TargetGraph path references。
- PR evidence 必须确认 no Symphony / no Graphify / no code-index / no Figma / no `.codex/*` / no `graphify-out/*`。
