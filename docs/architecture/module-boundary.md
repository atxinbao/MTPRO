# MTPRO Module Boundary

Date: 2026-07-20

Executor: Codex

Status: Canonical

## Authority

This document defines the current module ownership and dependency boundaries for
MTPRO. The root [architecture](../../architecture.md) document remains the
high-level architecture authority; `Package.swift` remains the compile-time
target authority.

Historical MTP/GH validation anchors and retired module wording are preserved in:

`docs/history/architecture-pre-canonicalization-2026-07-20/module-boundary.md`

They are evidence, not active architecture.

## Product Scope

```text
activeVenue=Binance
activeProducts=spot,usdsPerpetual
activeStrategies=ema,rsi
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

OKX, Bybit, and other venues are outside the current product scope.

## Active Modules

| Module | Source root | Owns | Must not own |
| --- | --- | --- | --- |
| `DomainModel` | `Sources/DomainModel/` | Shared venue, product, market, account, order, risk, and execution types | Network, storage, UI |
| `MessageBus` | `Sources/MessageBus/` | Event, command, query, correlation, causation, replay contracts | Adapter payloads, UI state |
| `DataClient` | `Sources/DataClient/Binance/` | Binance public, signed account, and private-stream input adaptation | Order execution |
| `DataEngine` | `Sources/DataEngine/` | Ingest, quality, replay, scenarios, runtime data steps | Direct execution |
| `Cache` | `Sources/Cache/` | Rebuildable memory state and read models | Durable truth |
| `Database` | `Sources/Database/` | Append-only facts, journals, projections, SQLite/DuckDB integration | UI schema coupling |
| `TraderStrategies` | `Sources/Trader/Strategies/` | EMA and RSI strategy definitions and intent generation | Broker transport, OMS |
| `Trader` | `Sources/Trader/` | Accounts, Strategies, Coordination, runtime lifecycle | Direct ExecutionClient calls |
| `Portfolio` | `Sources/Portfolio/` | Position, balance, PnL, margin, and exposure projections | Raw broker ownership |
| `RiskEngine` | `Sources/RiskEngine/` | Pre-trade gates, limits, kill switch, no-trade decisions | Order submission |
| `ExecutionEngine` | `Sources/ExecutionEngine/` | Order lifecycle, OMS, reconciliation, rollback coordination | Strategy logic |
| `ExecutionClient` | `Sources/ExecutionClient/` | Binance Demo/guarded transport, endpoint policy, external evidence | Strategy, portfolio, UI |
| `MTPROCLI` | `Sources/MTPROCLI/` | Operator commands, status, verification | Secret persistence, gate bypass |
| `Dashboard` | `Sources/Dashboard/` | Read-only validated operational views | Production authorization |

## Trader Boundary

```text
Trader
├── Accounts
├── Strategies
│   ├── EMA
│   └── RSI
├── Coordination
└── Runtime
```

- EMA and RSI are the current active strategy implementations.
- Strategies produce signals and target exposure intents.
- Strategy output must pass through MessageBus, RiskEngine, ExecutionEngine, and
  OMS before any external execution.
- `Coordination/RiskBinding` is the active proposal-to-risk binding location.
- `StrategyBindings` is a retired first-level module name.

## Dependency Direction

```text
DataClient -> DataEngine -> MessageBus
MessageBus -> Trader -> Portfolio -> RiskEngine
RiskEngine -> ExecutionEngine -> ExecutionClient
Execution events -> MessageBus -> Database / Cache / Portfolio
Validated projections -> MTPROCLI / Dashboard
```

Compile-time details are enforced by `Package.swift`. In particular:

- `Trader` depends on `TraderStrategies`, `Portfolio`, and `RiskEngine`, not
  `ExecutionEngine` or `ExecutionClient`.
- `RiskEngine` does not depend on external transport.
- `ExecutionClient` does not depend on Trader, Portfolio, or Dashboard.
- Dashboard consumes validated state and does not depend on adapter requests,
  runtime objects, or database schema.
- Foundation modules do not depend upward on execution or UI modules.

## External Boundary

`DataClient` is the inbound exchange boundary:

```text
Binance response
-> DataClient normalization
-> DomainModel event
-> DataEngine / MessageBus
```

`ExecutionClient` is the outbound exchange boundary:

```text
Risk-approved execution command
-> ExecutionEngine / OMS
-> ExecutionClient transport
-> Binance Demo or explicitly authorized environment
-> execution evidence
```

The two boundaries share venue/product identity and endpoint policy, but they do
not share responsibility. DataClient cannot submit orders. ExecutionClient
cannot generate strategy signals.

## Runtime Consistency

Research, Backtest, Paper, Demo, and future Production reuse:

- DomainModel types.
- MessageBus semantics.
- Trader strategy intent.
- RiskEngine decisions.
- ExecutionEngine/OMS lifecycle.
- Portfolio projections.

Modes replace only clock/scheduler, data source, execution adapter, endpoint
profile, credential provider, and authorization gate. No mode may create a
parallel strategy, risk, or OMS business path.

## TargetGraph Boundary Anchors

Per-module `TargetGraph/` directories currently hold SwiftPM target boundary
declarations and validation anchors. They are not business modules and must not
own runtime behavior.

The retired path is the former top-level `Sources/TargetGraph/`. Current
per-target anchors may be removed only through a separate target-boundary change
that preserves compile-time dependency validation.

## Compatibility Envelopes

`Core`, `Adapters`, `Persistence`, and `Runtime` are retained compatibility
envelopes. Their permitted role is limited to explicit compatibility or assembly
surfaces.

New implementation ownership belongs in the active module roots above.
Compatibility envelopes must not become default locations for new business
logic.

## Retired Active Paths

The following names may appear in historical audit or contract evidence but are
not current module roots:

- `Sources/Workbench/`
- `Sources/AppCompatibility/`
- top-level `Sources/TargetGraph/`
- `Sources/Strategies/`
- `Sources/Trader/StrategyBindings/`

`Workbench` wording in historical filenames or release evidence remains
unchanged for traceability. The current UI module is `Dashboard`.

## Production Boundary

Demo Network parity does not authorize production:

```text
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

Production requires a separate Human-approved cutover gate, production
credential policy, endpoint preflight, limits, kill switch/no-trade state, OMS,
reconciliation, rollback, incident evidence, and independent validation.

## Validation

Current validation entry points:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

Historical boundary anchors continue to be checked against the immutable
pre-canonicalization snapshot. Current guards must additionally verify this
document's active modules, retired paths, and production defaults.
