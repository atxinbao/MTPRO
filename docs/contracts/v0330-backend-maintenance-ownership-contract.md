# MTPRO v0.33.0 Backend Maintenance Ownership Contract

Date: 2026-07-19

Executor: Codex

This contract serves GitHub issue `#1574 M1 Define v0.33 backend maintenance ownership and cleanup contract`.
It establishes the post-v0.33.0 maintenance baseline at
`9d6e252ce9d2f63dd8f13c0d55141d75d11e4925`. It does not authorize a source
migration, a SwiftPM target graph change, a new venue or product, or any
production-trading capability.

## GH-1574-V0330-BACKEND-MAINTENANCE-CONTRACT

The maintenance line may improve only:

- cross-platform build and validation stability;
- internal file organization without public behavior changes;
- Demo evidence integrity, provenance, redaction and fail-closed evaluation;
- explicit ownership of retained compatibility sources;
- stale compatibility shim retirement after active-reference proof;
- maintenance audit and release-fact accuracy.

The immutable release snapshot remains `v0.33.0` at
`19d5d6bcc24ae6cc243396cea57d1c01499b23fe`. The maintenance baseline includes
PR #1573 at `9d6e252ce9d2f63dd8f13c0d55141d75d11e4925`. Maintenance work must never
move or rewrite the existing tag.

## GH-1574-CURRENT-REAL-MODULE-OWNERSHIP

| Real module owner | Current active responsibility |
| --- | --- |
| `DomainModel` | Shared identifiers, product/instrument values, order intent/lifecycle values and strategy-neutral contracts. |
| `MessageBus` | Neutral event, command, request/response, append-only journal and replay contracts. |
| `Database` | Durable local journals, checkpoints, run/session stores and SQLite/DuckDB projection ownership. |
| `DataClient` | Binance-scoped public data, signed-account/private-stream boundaries and Demo/testnet read-only transport evidence. |
| `DataEngine` | Binance market-data ingest, replay, scenario/data-quality and product-aware runtime evidence. |
| `Cache` | Runtime-derived market/instrument/order/position read state. |
| `TraderStrategies` | Trader-owned active strategy implementation under `Sources/Trader/Strategies`; active strategies remain EMA and RSI. |
| `Trader` | Account context, strategy coordination, risk binding and local runtime orchestration boundaries. |
| `Portfolio` | Spot/USD-M projection, exposure, reconciliation and read-model evidence. |
| `RiskEngine` | Pre-trade and live-gate policy, kill-switch/no-trade and incident-stop evidence. |
| `ExecutionEngine` | Paper/simulated lifecycle, OMS evidence, fills, reconciliation and internal execution semantics. |
| `ExecutionClient` | Binance external execution capability, Demo/testnet/prod-gated transport contracts and evidence validation. |
| `Dashboard` | Read-model-only status, report and evidence surfaces; no default command authority. |
| `MTPROCLI` | Operator commands that remain approval-bound, environment-bound and fail-closed. |

## GH-1574-RETAINED-COMPATIBILITY-ENVELOPE

The following targets are retained compatibility envelopes, not new architecture
owners:

| Envelope | Allowed retained responsibility | Exit condition |
| --- | --- | --- |
| `Core` | Historical rich paper/runtime payloads and legacy import bridges still required by tests or Dashboard compatibility. | Real owner imports and focused tests exist; no active reference requires the Core export. |
| `Adapters` | `DataClient` compatibility re-export only. | All consumers import `DataClient` directly. |
| `Persistence` | SQLite/DuckDB projection compatibility surface. | Consumers import `Database` directly and projection behavior remains covered. |
| `Runtime` | Ingest/replay composition compatibility surface. | DataEngine/Database own the complete workflow and Runtime imports are absent. |

No new business implementation may land in these envelopes. Every retained file
must have one named real owner, one reason for retention and one evidence-backed
exit path.

## GH-1574-CURRENT-MAINTENANCE-INVENTORY

| Priority | Inventory finding | Maintenance action |
| --- | --- | --- |
| P1 | Linux/macOS validation depends on shared Crypto, sqlite and release-specific fail-closed guards. | Keep both hosted platforms buildable and make every validation failure non-zero. |
| P1 | Demo evidence, provenance, CLI and Dashboard status span `ExecutionClient`, `MTPROCLI` and `Dashboard`. | Keep one authoritative bundle/decision path and read-only consumers. |
| P2 | Several backend files exceed 2,000 lines, including Core live-boundary, Database stores, Risk live-gate and CLI routing files. | Split by cohesive type families after focused behavior tests exist. |
| P2 | `Core`, `Adapters`, `Persistence` and `Runtime` remain exported SwiftPM products. | Retire only proven stale shims; do not perform an unscoped target rewrite. |
| P2 | Release-specific evidence types accumulate across versioned files. | Consolidate shared mechanics only when three or more active versions use the same behavior and compatibility is proven. |

## GH-1574-DEPENDENCY-DIRECTION

Maintenance changes must preserve the active direction:

```text
DomainModel
MessageBus -> DomainModel
Database -> DomainModel / MessageBus
DataClient -> DomainModel
DataEngine -> DomainModel / DataClient / MessageBus / Cache / Database
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine
ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient
Dashboard -> read models and compatibility exports only
```

Maintenance must not introduce a strategy-to-broker shortcut, a Dashboard command
shortcut or a compatibility-envelope ownership reversal.

## GH-1574-DEMO-AND-PRODUCTION-BOUNDARY

The active maintenance evidence scope is Binance Demo Network, Binance Spot and
Binance USD-M Futures. The accepted Demo parity result does not authorize
production cutover.

Required invariant values:

```text
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

Raw API keys, secret values and raw exchange responses must not be persisted in
evidence. Production endpoints and production orders are outside this maintenance
line.

## GH-1574-CLEANUP-SEQUENCE

1. `#1575` stabilizes the cross-platform build and validation matrix.
2. `#1576` splits selected oversized files without changing behavior.
3. `#1577` consolidates Demo evidence, CLI and artifact ownership.
4. `#1578` narrows compatibility ownership and retires proven stale shims.
5. `#1579` closes the validation matrix and decides whether a patch release is warranted.

The queue must remain WIP=1. A downstream issue may start only after all of its
declared blockers are closed.

## GH-1574-ROLLBACK-AND-ACCEPTANCE

Every maintenance PR must be independently revertible. A PR is unacceptable if it
changes a public execution contract without explicit issue scope, weakens
fail-closed behavior, moves the v0.33.0 tag, expands venue/product scope or enables
production behavior by default.

Required validation:

- `git diff --check`
- `bash checks/automation-readiness.sh`
- focused tests for the changed ownership boundary
- `bash checks/run.sh`

