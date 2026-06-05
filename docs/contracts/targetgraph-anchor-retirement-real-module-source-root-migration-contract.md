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
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine
Dashboard -> Core / Persistence read-model and ViewModel exports only
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
- Dashboard root：`Sources/Dashboard/`。

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

## MTP-226-FOUNDATION-REAL-ROOT-TARGET-MIGRATION

MTP-226 是第一个 real module source root migration issue。它只迁移 foundation target boundary anchors：

| Target | Previous active target path | Current active target path | Current explicit sources | Retained compatibility owner |
| --- | --- | --- | --- | --- |
| `DomainModel` | `Sources/TargetGraph/DomainModel` | `Sources/DomainModel` | `TargetGraph/DomainModelTargetBoundary.swift` | `Core` continues compiling `Sources/DomainModel/*.swift` implementation files. |
| `MessageBus` | `Sources/TargetGraph/MessageBus` | `Sources/MessageBus` | `TargetGraph/MessageBusTargetBoundary.swift` | `Core` continues compiling `Sources/MessageBus/*.swift` implementation files. |
| `Database` | `Sources/TargetGraph/Database` | `Sources/Database` | `TargetGraph/DatabaseTargetBoundary.swift` | `Persistence` continues compiling projection implementation; `Runtime` continues compiling replay projection. |

MTP-226 intentionally keeps `sources` explicit so the newly migrated foundation targets do not overlap with retained compatibility envelopes. `Core` excludes `DomainModel/TargetGraph` and `MessageBus/TargetGraph`; `Persistence` excludes `TargetGraph`; `Runtime` excludes `Database/TargetGraph`.

## MTP-226-FOUNDATION-DEPENDENCY-DIRECTION-PRESERVED

MTP-226 preserves the foundation dependency direction:

```text
DomainModel
MessageBus -> DomainModel
Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)
```

MTP-226 does not migrate DataClient、DataEngine、Cache、TraderStrategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench or Dashboard. It does not change persistence behavior, runtime behavior, broker boundary, live boundary or L4 boundary.

## MTP-226-TARGETGRAPH-FOUNDATION-ACTIVE-PATH-RETIREMENT

After MTP-226, these active foundation files must not exist:

- `Sources/TargetGraph/DomainModel/DomainModelTargetBoundary.swift`
- `Sources/TargetGraph/MessageBus/MessageBusTargetBoundary.swift`
- `Sources/TargetGraph/Database/DatabaseTargetBoundary.swift`

The remaining `Sources/TargetGraph/*` active paths are for later MTP-227 through MTP-231 issues only. MTP-226 does not delete `Sources/TargetGraph` and does not retire data / trader / execution TargetGraph paths.

## MTP-226-FOUNDATION-REAL-ROOT-VALIDATION

MTP-226 required validation：

- `swift package describe` must not emit unhandled-file warnings for the migrated foundation target roots.
- `swift test --filter TargetGraphTests/testMTP226FoundationTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- PR evidence 必须确认 foundation target paths no longer depend on `Sources/TargetGraph/DomainModel`、`Sources/TargetGraph/MessageBus` or `Sources/TargetGraph/Database`.
- PR evidence 必须确认 no Symphony / no Graphify / no code-index / no Figma / no `.codex/*` / no `graphify-out/*`。

## MTP-227-DATA-REAL-ROOT-TARGET-MIGRATION

MTP-227 只迁移 data-layer target boundary anchors：

| Target | Previous active target path | Current active target path | Current explicit sources | Retained compatibility owner |
| --- | --- | --- | --- | --- |
| `DataClient` | `Sources/TargetGraph/DataClient` | `Sources/DataClient` | `TargetGraph/DataClientTargetBoundary.swift` | `Adapters` continues compiling Binance public market data implementation. |
| `Cache` | `Sources/TargetGraph/Cache` | `Sources/Cache` | `TargetGraph/CacheTargetBoundary.swift` | `Core` continues compiling `Sources/Cache/MarketData` implementation files. |
| `DataEngine` | `Sources/TargetGraph/DataEngine` | `Sources/DataEngine` | `TargetGraph/DataEngineTargetBoundary.swift` | `Core` continues compiling replay / quality implementation; `Runtime` continues compiling ingest implementation. |

MTP-227 intentionally keeps `sources` explicit so the newly migrated data targets do not overlap with retained compatibility envelopes. `Adapters` excludes `TargetGraph`; `Core` excludes `Cache/TargetGraph` and `DataEngine/TargetGraph`; `Runtime` excludes `DataEngine/TargetGraph`.

## MTP-227-DATA-DEPENDENCY-DIRECTION-PRESERVED

MTP-227 preserves the data-layer dependency direction:

```text
DataClient -> DomainModel
Cache -> DomainModel / MessageBus
DataEngine -> DomainModel / DataClient / MessageBus / Cache
```

MTP-227 does not migrate TraderStrategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench or Dashboard. It does not add signed endpoint, account endpoint, listenKey, private stream runtime, broker path, runtime behavior, live behavior or L4 capability.

## MTP-227-TARGETGRAPH-DATA-ACTIVE-PATH-RETIREMENT

After MTP-227, these active data files must not exist:

- `Sources/TargetGraph/DataClient/DataClientTargetBoundary.swift`
- `Sources/TargetGraph/Cache/CacheTargetBoundary.swift`
- `Sources/TargetGraph/DataEngine/DataEngineTargetBoundary.swift`

The remaining `Sources/TargetGraph/*` active paths are for later MTP-228 through MTP-231 issues only. MTP-227 does not delete `Sources/TargetGraph` and does not retire trader / portfolio / risk / execution / UI TargetGraph paths.

## MTP-227-DATA-REAL-ROOT-VALIDATION

MTP-227 required validation：

- `swift package describe` must not emit unhandled-file warnings for the migrated data target roots.
- `swift test --filter TargetGraphTests/testMTP227DataTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- PR evidence 必须确认 data target paths no longer depend on `Sources/TargetGraph/DataClient`、`Sources/TargetGraph/Cache` or `Sources/TargetGraph/DataEngine`.
- PR evidence 必须确认 no signed/account endpoint、no listenKey、no private stream runtime、no broker gateway、no Symphony、no Graphify、no code-index、no Figma、no `.codex/*`、no `graphify-out/*`。

## MTP-228-TRADER-PORTFOLIO-RISK-REAL-ROOT-TARGET-MIGRATION

MTP-228 只迁移 Trader / Portfolio / Risk target boundary anchors：

| Target | Previous active target path | Current active target path | Current explicit sources | Retained compatibility owner |
| --- | --- | --- | --- | --- |
| `TraderStrategies` | `Sources/TargetGraph/TraderStrategies` | `Sources/Trader/Strategies/EMA` | `TargetGraph/TraderStrategiesTargetBoundary.swift` | `Core` continues compiling EMA strategy implementation. |
| `Trader` | `Sources/TargetGraph/Trader` | `Sources/Trader` | `TargetGraph/TraderTargetBoundary.swift` | `Core` continues compiling Accounts / Strategies / Coordination implementation. |
| `Portfolio` | `Sources/TargetGraph/Portfolio` | `Sources/Portfolio` | `TargetGraph/PortfolioTargetBoundary.swift` | `Core` continues compiling paper portfolio projection implementation. |
| `RiskEngine` | `Sources/TargetGraph/RiskEngine` | `Sources/RiskEngine` | `TargetGraph/RiskEngineTargetBoundary.swift` | `Core` continues compiling pre-trade / live gate evidence implementation. |

MTP-228 intentionally keeps `sources` explicit so the newly migrated targets do not overlap with retained compatibility envelopes. `Core` excludes `Trader/Strategies/EMA/TargetGraph`、`Trader/TargetGraph`、`Portfolio/TargetGraph` 和 `RiskEngine/TargetGraph`.

## MTP-228-TRADER-CONTAINER-DEPENDENCY-DIRECTION-PRESERVED

MTP-228 preserves the Trader / Portfolio / Risk dependency direction:

```text
Portfolio -> DomainModel / MessageBus / Cache / Database
RiskEngine -> DomainModel / MessageBus / Cache / Portfolio
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine
```

`Trader = Accounts + Strategies/EMA + Coordination` remains the authority, and EMA remains the only active concrete strategy. GH-392 later removed direct `Trader -> ExecutionEngine` target dependency, so this direction is current. MTP-228 does not migrate ExecutionEngine、ExecutionClient、Workbench or Dashboard. It does not add Trader runtime, Strategy runtime, Live runtime, direct strategy-to-execution path, broker / OMS path, signed endpoint, account endpoint, listenKey, private stream runtime or L4 capability.

## MTP-228-TARGETGRAPH-TRADER-PORTFOLIO-RISK-ACTIVE-PATH-RETIREMENT

After MTP-228, these active Trader / Portfolio / Risk files must not exist:

- `Sources/TargetGraph/TraderStrategies/TraderStrategiesTargetBoundary.swift`
- `Sources/TargetGraph/Trader/TraderTargetBoundary.swift`
- `Sources/TargetGraph/Portfolio/PortfolioTargetBoundary.swift`
- `Sources/TargetGraph/RiskEngine/RiskEngineTargetBoundary.swift`

The remaining `Sources/TargetGraph/*` active paths are for later MTP-229 through MTP-231 issues only. MTP-228 does not delete `Sources/TargetGraph` and does not retire execution / UI TargetGraph paths.

## MTP-228-TRADER-PORTFOLIO-RISK-REAL-ROOT-VALIDATION

MTP-228 required validation：

- `swift package describe` must not emit unhandled-file warnings for the migrated Trader / Portfolio / Risk target roots.
- `swift test --filter TargetGraphTests/testMTP228TraderPortfolioRiskTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- PR evidence 必须确认 Trader / TraderStrategies / Portfolio / RiskEngine target paths no longer depend on `Sources/TargetGraph/<Module>`.
- PR evidence 必须确认 EMA-only active strategy、no direct strategy-to-execution / broker path、no Trader runtime、no Strategy runtime、no Symphony、no Graphify、no code-index、no Figma、no `.codex/*`、no `graphify-out/*`。

## MTP-229-EXECUTION-REAL-ROOT-TARGET-MIGRATION

MTP-229 只迁移 execution target boundary anchors：

| Target | Previous active target path | Current active target path | Current explicit sources | Retained compatibility owner |
| --- | --- | --- | --- | --- |
| `ExecutionClient` | `Sources/TargetGraph/ExecutionClient` | `Sources/ExecutionClient` | `TargetGraph/ExecutionClientTargetBoundary.swift` | `Core` continues compiling FutureGate and BrokerCapabilityMatrix evidence. |
| `ExecutionEngine` | `Sources/TargetGraph/ExecutionEngine` | `Sources/ExecutionEngine` | `TargetGraph/ExecutionEngineTargetBoundary.swift` | `Core` continues compiling paper lifecycle, simulated exchange and OMS future gate evidence. |

MTP-229 intentionally keeps `sources` explicit so the newly migrated execution targets do not overlap with retained compatibility envelopes. `Core` excludes `ExecutionClient/TargetGraph` and `ExecutionEngine/TargetGraph`.

## MTP-229-EXECUTION-FUTURE-GATE-DEPENDENCY-DIRECTION-PRESERVED

MTP-229 preserves the execution dependency direction:

```text
ExecutionClient -> DomainModel / MessageBus
ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient
```

`ExecutionClient` remains future-gated and `ExecutionEngine` remains paper / simulated lifecycle evidence only. MTP-229 does not migrate Workbench or Dashboard. It does not add ExecutionClient implementation, OMS implementation, broker gateway, signed endpoint, account endpoint, listenKey, private stream runtime, real order lifecycle, submit / cancel / replace, execution report, broker fill, reconciliation, live command or L4 capability.

## MTP-229-TARGETGRAPH-EXECUTION-ACTIVE-PATH-RETIREMENT

After MTP-229, these active execution files must not exist:

- `Sources/TargetGraph/ExecutionClient/ExecutionClientTargetBoundary.swift`
- `Sources/TargetGraph/ExecutionEngine/ExecutionEngineTargetBoundary.swift`

The remaining `Sources/TargetGraph/*` active paths are for later MTP-230 through MTP-231 issues only. MTP-229 does not delete `Sources/TargetGraph` and does not retire UI TargetGraph paths.

## MTP-229-EXECUTION-REAL-ROOT-VALIDATION

MTP-229 required validation：

- `swift package describe` must not emit unhandled-file warnings for the migrated execution target roots.
- `swift test --filter TargetGraphTests/testMTP229ExecutionTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- PR evidence 必须确认 ExecutionClient / ExecutionEngine target paths no longer depend on `Sources/TargetGraph/<Module>`.
- PR evidence 必须确认 no ExecutionClient implementation、no OMS implementation、no broker gateway、no real order lifecycle、no live command、no Symphony、no Graphify、no code-index、no Figma、no `.codex/*`、no `graphify-out/*`。

## MTP-230-DASHBOARD-REAL-ROOT-TARGET-MIGRATION

MTP-230 曾迁移 Workbench / Dashboard UI target boundaries。后续 cleanup 已退休 `Workbench` target / product 和 `Sources/Workbench/` active source root；当前 UI target boundary 只保留 `Dashboard`：

| Target | Previous active compiler shape | Real module root | Active source anchor after MTP-230 | Retained compatibility |
| --- | --- | --- | --- | --- |
| `Workbench` | Historical read-model-only UI library target | retired | historical / forbidden active path evidence only | none |
| `Dashboard` | `Sources/Dashboard` executable | `Sources/Dashboard` | `DashboardApplication.swift`、`DashboardTargetBoundary.swift`、`DashboardShell.swift`、`ReadModels`、`Report`、`Events`、`FutureLiveProConsole` | `Dashboard` depends only on `Core` / `Persistence`. |

`DashboardShell.swift`、ReadModels、Report、Events 和 FutureLiveProConsole future label 当前均由 `Sources/Dashboard/` 直接拥有。`Sources/Dashboard` 仍只表示 read-model-only display surface，不拥有 runtime object、adapter request、schema、account payload、broker payload、command-capable UI surface 或 L4 capability。

## MTP-230-UI-READ-MODEL-ONLY-DEPENDENCY-DIRECTION-PRESERVED

MTP-230 后续 cleanup 后的 UI dependency direction：

```text
Dashboard -> Core / Persistence read-model and ViewModel exports only
```

Dashboard 继续只消费 read model / ViewModel / projection snapshot。`App` product / target、`Sources/AppCompatibility`、`Workbench` product / target 和 `Sources/Workbench/` 已退休。MTP-230 不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload 或 broker state，不新增 Live PRO Console、trading button、live command、order form、Dashboard runtime inspector、broker connect UI、account connect UI 或 L4 capability。

## MTP-230-TARGETGRAPH-UI-MIXED-PATH-RETIREMENT

After MTP-230 follow-up cleanup, these UI paths must not remain active:

- `Sources/Workbench`
- `Sources/Workbench/TargetGraph/WorkbenchTargetBoundary.swift`

The active Dashboard boundary files remain under the real Dashboard root:

- `Sources/Dashboard/DashboardTargetBoundary.swift`
- `Sources/Dashboard/DashboardShell.swift`

MTP-230 does not delete `Sources/TargetGraph` as a historical term from older evidence and does not perform final TargetGraph active path retirement. MTP-231 remains responsible for final active path reference retirement and validation anchor cleanup.

## MTP-230-DASHBOARD-REAL-ROOT-VALIDATION

MTP-230 required validation：

- `swift package describe` must not emit unhandled-file warnings for Dashboard root.
- `swift test --filter TargetGraphTests/testMTP230DashboardTargetUsesRealModuleRootAndRetiresWorkbenchTarget`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- PR evidence 必须确认 Workbench target / source root 已退休，Dashboard executable target path 使用 `Sources/Dashboard`，`DashboardShell.swift` active owner 是 `Sources/Dashboard`。
- PR evidence 必须确认 no runtime object、no adapter request、no schema / payload / broker state exposure、no Live PRO Console、no trading button、no live command、no order form、no Symphony、no Graphify、no code-index、no Figma、no `.codex/*`、no `graphify-out/*`。

## MTP-231-TARGETGRAPH-ACTIVE-PATH-REFERENCE-RETIREMENT

MTP-231 retires the final active `Sources/TargetGraph` source root references from validation anchors and current architecture wording. After MTP-231, the repository must not contain an active `Sources/TargetGraph/` directory, and `Package.swift` must not contain any active `path: "Sources/TargetGraph..."` target path.

Remaining text references to `Sources/TargetGraph/<Module>` are allowed only when they are explicitly historical / before-state / retired evidence for MTP-224 through MTP-230. They must not describe a current compiler owner, final module root, new implementation root, feature landing path, engine layer, runtime object owner, or L4 capability source.

## MTP-231-REAL-MODULE-ROOT-ACTIVE-SNAPSHOT

MTP-231 confirms the active target path snapshot is real module roots only:

| Target | Active target path after MTP-231 | Active boundary anchor |
| --- | --- | --- |
| `DomainModel` | `Sources/DomainModel` | `TargetGraph/DomainModelTargetBoundary.swift` |
| `MessageBus` | `Sources/MessageBus` | `TargetGraph/MessageBusTargetBoundary.swift` |
| `Database` | `Sources/Database` | `TargetGraph/DatabaseTargetBoundary.swift` |
| `DataClient` | `Sources/DataClient` | `TargetGraph/DataClientTargetBoundary.swift` |
| `Cache` | `Sources/Cache` | `TargetGraph/CacheTargetBoundary.swift` |
| `DataEngine` | `Sources/DataEngine` | `TargetGraph/DataEngineTargetBoundary.swift` |
| `TraderStrategies` | `Sources/Trader/Strategies/EMA` | `TargetGraph/TraderStrategiesTargetBoundary.swift` |
| `Trader` | `Sources/Trader` | `TargetGraph/TraderTargetBoundary.swift` |
| `Portfolio` | `Sources/Portfolio` | `TargetGraph/PortfolioTargetBoundary.swift` |
| `RiskEngine` | `Sources/RiskEngine` | `TargetGraph/RiskEngineTargetBoundary.swift` |
| `ExecutionClient` | `Sources/ExecutionClient` | `TargetGraph/ExecutionClientTargetBoundary.swift` |
| `ExecutionEngine` | `Sources/ExecutionEngine` | `TargetGraph/ExecutionEngineTargetBoundary.swift` |
| `Dashboard` | `Sources/Dashboard` | `DashboardApplication.swift`、`DashboardTargetBoundary.swift`、`DashboardShell.swift`、`ReadModels`、`Report`、`Events`、`FutureLiveProConsole` |

This snapshot preserves the dependency direction from MTP-222 and the real-root migrations from MTP-226 through MTP-230. It does not delete retained compatibility implementation and does not introduce new module layout.

## MTP-231-NO-RUNTIME-LIVE-BROKER-L4-GUARD

MTP-231 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。

MTP-231 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-231-TARGETGRAPH-RETIREMENT-VALIDATION

MTP-231 required validation：

- `swift package describe` must complete with empty stderr.
- `swift test --filter TargetGraphTests/testMTP231TargetGraphActivePathReferencesAreRetiredAndRealRootsRemainCurrent`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- PR evidence 必须确认 `Sources/TargetGraph/` directory 不存在。
- PR evidence 必须确认 `Package.swift` 不包含 active `path: "Sources/TargetGraph..."` target path。
- PR evidence 必须确认 tests / docs / automation readiness anchors 不再把 `Sources/TargetGraph` 描述为 current active source root。
- PR evidence 必须确认 no Symphony、no Graphify、no code-index、no Figma、no `.codex/*`、no `graphify-out/*`。
