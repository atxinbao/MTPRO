# MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1 - GH-381 L4 Readiness Gate

Date: 2026-06-05
Executor: Codex

## Scope

GH-381 defines the L4 readiness gate, blockers, and allowed planning scope based on GH-376 through GH-380 review evidence.

This is planning evidence only. It does not authorize L4 implementation, live runtime, broker connectivity, order commands, or endpoint access.

## Readiness Inputs

| Input | Review focus |
|---|---|
| GH-376 | Baseline and evidence inventory |
| GH-377 | Real module source roots versus retained compatibility envelopes |
| GH-378 | DataClient / DataEngine / MessageBus / Cache / Database alignment |
| GH-379 | Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient future gates |
| GH-380 | Dashboard read-model-only boundary and retired Workbench / AppCompatibility paths |

## Satisfied L4 Planning Preconditions

The following items are satisfied for L4 planning discussion:

- Architecture graph target names exist in SwiftPM: `DomainModel`, `MessageBus`, `Database`, `DataClient`, `DataEngine`, `Cache`, `Portfolio`, `RiskEngine`, `ExecutionClient`, `ExecutionEngine`, `TraderStrategies`, `Trader`, and `Dashboard`.
- Current active source roots are aligned to architecture module directories.
- Top-level `Sources/TargetGraph/` is retired.
- `Sources/Workbench/` is retired.
- `Sources/AppCompatibility/` is retired.
- `Sources/Strategies/` is retired.
- `Sources/Trader/StrategyBindings/` is retired.
- `Trader = Accounts + Strategies/EMA + Coordination`.
- `EMA` is the only active concrete strategy.
- `ExecutionClient` is present only as future gate / protocol boundary.
- `Dashboard` is the active UI surface and remains read-model-only.
- Validation baseline is green with `bash checks/run.sh`.

## Unsatisfied Items / Blockers

The following items block direct L4 implementation:

1. `Core` still retains broad implementation ownership for domain, message bus, cache, data quality, trader, portfolio, risk, execution and strategy evidence.
2. `Adapters` still retains public read-only Binance DataClient implementation.
3. `Persistence` still retains SQLite / DuckDB implementation.
4. `Runtime` still retains data ingest and replay projection implementation.
5. Many architecture targets still compile module-local boundary anchors rather than full implementation ownership.
6. Module-local `TargetGraph/` naming remains as boundary-anchor wording; this is not a top-level active source path, but may need future cleanup.
7. Dashboard still depends on `Core` / `Persistence` compatibility exports.
8. Historical Workbench wording remains in some Dashboard source filenames, comments and smoke keys; this is wording debt, not an active Workbench module.
9. `ExecutionClient` has no broker gateway implementation by design.
10. OMS, credentials, signed endpoint, account endpoint, listenKey, private stream, live risk runtime and production trading command contracts are not yet planned as implementation work.

## Allowed L4 Planning Scope

L4 planning may discuss only contracts and gates until a separate Human-confirmed project authorizes implementation.

Allowed planning topics:

- Live runtime readiness terminology and stage gates.
- Broker / exchange execution adapter contract shape, without implementation.
- OMS contract decomposition, without implementation.
- Credential / endpoint access preconditions, without reading secrets.
- `ExecutionClient` future-gate contract and dependency direction.
- Trader runtime readiness contract, without runtime implementation.
- Strategy runtime readiness contract for EMA-only current strategy, without enabling live execution.
- Dashboard read-model-only evidence needed before any command UI planning.
- Compatibility envelope retirement strategy for `Core`, `Adapters`, `Persistence`, and `Runtime`.

## Forbidden L4 Implementation Capabilities

The following remain forbidden until a separate executable project explicitly authorizes them:

- Trader runtime.
- Strategy runtime.
- Live runtime.
- `ExecutionClient` implementation.
- OMS implementation.
- broker gateway.
- signed endpoint.
- account endpoint / listenKey.
- private WebSocket runtime.
- real account read.
- broker payload read.
- real order lifecycle.
- submit / cancel / replace.
- execution report.
- broker fill.
- reconciliation.
- real PnL.
- Live PRO Console.
- trading button.
- live command.
- order form.
- emergency stop / shutdown / restore implementation.

## L4 Entry Gate

L4 planning can start only if all of these are true:

- A Human-confirmed L4 planning draft exists.
- The planning draft preserves `ExecutionClient` as future-gated until explicitly authorized.
- The planning draft does not bypass `Core` / `Adapters` / `Persistence` / `Runtime` compatibility envelope decisions.
- The planning draft keeps Dashboard read-model-only until a separate command-surface project is approved.
- The planning draft separates contracts from implementation.
- Queue preflight confirms WIP=1, no active conflict, complete execution contract, and a unique eligible issue.

L4 implementation cannot start under this review project.

## Completion Decision

Current architecture graph completion status:

- Source roots and SwiftPM target graph are substantially aligned.
- Active retired paths are correctly removed.
- Dashboard active UI boundary is read-model-only.
- Full implementation ownership is not yet complete because compatibility envelopes remain.

Therefore the correct next move after this review is not direct L4 implementation. It is either:

1. an L4 planning-only project with strict future gates; or
2. one or more compatibility envelope retirement projects before L4 implementation planning.

## GH-381 Acceptance Criteria

- AC1: L4 readiness gate is documented with satisfied items, blockers, and allowed planning scope.
- AC2: Forbidden L4 implementation capabilities are explicitly preserved.
- AC3: Validation output is recorded in `verification.md`.

