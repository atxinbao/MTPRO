# MTPRO Trader EMA Strategy Layout Consolidation v1 MTP-200 non-EMA anchor audit

日期：2026-06-02

执行者：Codex

## 定位

`MTP-200-NON-EMA-STRATEGY-ANCHOR-AUDIT`

本文档是 `MTP-200` 的 audit / evidence output，服务 `MTPRO Trader EMA Strategy Layout Consolidation v1` 后续 `MTP-201` 和 `MTP-202` 的输入材料。本文档只枚举并分类 current source、`Package.swift`、tests 和 validation anchors 中的 non-EMA strategy / StrategyBindings references，不移动 source，不修改 `Package.swift`，不改变 runtime behavior。

`MTP-200-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`

本文档不授权删除 `Sources/Trader/Strategies/OrderBookImbalance/`，不移动 `Sources/Trader/StrategyBindings/`，不修改 SwiftPM target graph，不实现 Strategy runtime、Trader runtime、ExecutionClient、OMS、broker command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command 或 order form。

## Audit commands

| Command | Result | Interpretation |
| --- | --- | --- |
| `rg -n "OrderBookImbalance" Sources Tests Package.swift` | 103 matches | `OrderBookImbalance` still has production source, package root, research flow, persistence, command / event, and test dependencies. |
| `rg -n "StrategyBindings" Sources Tests Package.swift` | 27 matches | `StrategyBindings` still has a Trader-owned binding / coordination source root, package root, and path validation tests. |
| `rg -n "\b(RSI|Momentum|MeanReversion)\b" Sources Tests Package.swift` | 0 matches | `RSI`、`Momentum`、`MeanReversion` have no active source, package, or test anchors. Their retained references are docs-only future candidate labels. |
| `rg -n "\"Trader/Strategies|\"Strategies/|StrategyBindings" Package.swift Tests/CoreTests/CoreTests.swift` | package / path guard matches | Current package roots include EMA, OrderBookImbalance, and StrategyBindings compatibility roots; tests assert old peer-level roots stay absent. |
| `find Sources/Trader -maxdepth 3 -type f ! -name .DS_Store \| sort` | Trader strategy / binding files only | `Sources/Trader/Strategies/EMA/` contains active EMA files; `Sources/Trader/Strategies/OrderBookImbalance/` contains non-EMA source placement debt; `Sources/Trader/StrategyBindings/` contains binding evidence. |

## Source and package classification

`MTP-200-SOURCE-PACKAGE-CLASSIFICATION`

| Finding | Evidence path | Classification | Next issue input |
| --- | --- | --- | --- |
| EMA active source | `Sources/Trader/Strategies/EMA/EMACross.swift`、`PaperActionProposal.swift`、`StrategySignals.swift` | Current active concrete strategy source. | Keep as canonical active path. |
| OrderBookImbalance strategy source | `Sources/Trader/Strategies/OrderBookImbalance/OrderBookImbalance.swift` | Active compiled non-EMA source placement debt. It is not current active strategy after MTP-198 / MTP-199. | `MTP-201` must decide retirement / quarantine / compatibility treatment under explicit authorization. |
| OrderBookImbalance package root | `Package.swift:37` contains `"Trader/Strategies/OrderBookImbalance"` | SwiftPM compatibility envelope root for non-EMA source debt. | `MTP-201` must update package roots only if source retirement / quarantine requires it. |
| StrategyBindings source | `Sources/Trader/StrategyBindings/PaperActionRiskLink.swift` | Generic binding protocol / coordination adapter evidence, not concrete strategy source. | `MTP-202` must move or reclassify this under Trader Coordination boundary. |
| StrategyBindings package root | `Package.swift:38` contains `"Trader/StrategyBindings"` | SwiftPM compatibility envelope root for binding evidence. | `MTP-202` must update package roots only if boundary move / reclassification requires it. |
| RSI / Momentum / MeanReversion | No exact `Sources` / `Tests` / `Package.swift` matches | No active source, package, or tests. | No source retirement input; keep docs-only future candidate labels. |

## Runtime and test dependency classification

`MTP-200-RUNTIME-TEST-DEPENDENCY-CLASSIFICATION`

| Domain | Evidence paths | Classification | Next issue input |
| --- | --- | --- | --- |
| OrderBookImbalance command / event | `Sources/MessageBus/CommandsAndQueries.swift`、`Sources/MessageBus/DomainEvents.swift` | Research command / event evidence, not executable order command. | `MTP-201` must decide whether this remains as historical research evidence or is quarantined with the source. |
| OrderBookImbalance research flow | `Sources/Core/ResearchEventFlows.swift`、`Sources/Core/ResearchResults.swift` | Local research / parity evidence that still depends on OBI types. | `MTP-201` must account for these dependencies before retiring source. |
| OrderBookImbalance persistence projection | `Sources/Database/Projections/SQLite/Persistence.swift` | Persistence projection support for research events / samples. | `MTP-201` must preserve or retire projection coverage consistently with research evidence. |
| OrderBookImbalance tests | `Tests/CoreTests/CoreTests.swift`、`Tests/PersistenceTests/PersistenceTests.swift` | Focused research / parity / persistence tests; not active live strategy tests. | `MTP-201` must update or quarantine tests with the source decision. |
| StrategyBindings tests | `Tests/CoreTests/CoreTests.swift:8278` and path validation assertions around `Package.swift` roots | Boundary and path validation evidence. | `MTP-202` must update tests if `StrategyBindings` moves under `Trader/Coordination`. |

## Validation anchor classification

`MTP-200-VALIDATION-ANCHOR-CLASSIFICATION`

| Anchor area | Evidence paths | Classification |
| --- | --- | --- |
| EMA-only contract | `docs/contracts/trader-ema-strategy-layout-contract.md` | Correctly states EMA-only active strategy and non-EMA future candidate / debt boundary. |
| Architecture / domain anchors | `docs/architecture/module-boundary.md`、`docs/domain/context.md` | Correctly classify OrderBookImbalance as historical / compatibility debt and StrategyBindings as non-landing binding evidence. |
| Validation plan / matrix | `docs/validation/validation-plan.md`、`docs/validation/trading-validation-matrix.md` | Correctly preserve historical MTP-193..199 context and future MTP-201 / MTP-202 input. |
| Latest verification summary | `docs/validation/latest-verification-summary.md` | Correctly records MTP-198 / MTP-199 EMA-only boundary and now records MTP-200 audit evidence. |

## Issue 4 and Issue 5 input

`MTP-200-MTP-201-INPUT`

`MTP-201` should focus on `OrderBookImbalance` retirement / quarantine. The concrete inputs are:

- `Sources/Trader/Strategies/OrderBookImbalance/OrderBookImbalance.swift`
- `Package.swift` root `"Trader/Strategies/OrderBookImbalance"`
- `Sources/Core/ResearchEventFlows.swift`
- `Sources/Core/ResearchResults.swift`
- `Sources/MessageBus/CommandsAndQueries.swift`
- `Sources/MessageBus/DomainEvents.swift`
- `Sources/Database/Projections/SQLite/Persistence.swift`
- `Tests/CoreTests/CoreTests.swift`
- `Tests/PersistenceTests/PersistenceTests.swift`

`MTP-200-MTP-202-INPUT`

`MTP-202` should focus on StrategyBindings boundary move / reclassification. The concrete inputs are:

- `Sources/Trader/StrategyBindings/PaperActionRiskLink.swift`
- `Package.swift` root `"Trader/StrategyBindings"`
- `Tests/CoreTests/CoreTests.swift` StrategyBindings boundary / path validation assertions
- Existing docs anchors that say StrategyBindings belongs to binding / coordination adapter semantics

## Validation evidence

`MTP-200-AUDIT-VALIDATION`

| Command | Result | Notes |
| --- | --- | --- |
| `git diff --check` | pass | No whitespace errors. |
| `bash checks/run.sh` | pass | Automation readiness, Dashboard build / smoke, and full XCTest validation passed; this issue only changes audit / validation docs and must not alter runtime behavior or active source paths. |

## Boundary evidence

`MTP-200-FORBIDDEN-IMPLEMENTATION-AUDIT`

- No source files moved.
- No production source deleted.
- No `Package.swift` change.
- No Swift business code changed.
- No SwiftPM target graph split.
- No Strategy runtime, Trader runtime, ExecutionClient, OMS, broker command, signed/account endpoint, private stream runtime, Live PRO Console, trading button, live command or order form.
- No Symphony, Graphify or Figma.
- No `.codex/*` or `graphify-out/*` submitted.
