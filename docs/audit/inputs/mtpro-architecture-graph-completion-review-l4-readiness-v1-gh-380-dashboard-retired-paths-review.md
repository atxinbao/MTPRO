# MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1 - GH-380 Dashboard Retired Paths Review

Date: 2026-06-05
Executor: Codex

## Scope

GH-380 reviews the active UI surface after Workbench and AppCompatibility retirement. The current active wording is `Dashboard read-model-only boundary`, not `Workbench / Dashboard`.

This review is docs-only input material for the Architecture Graph Completion Review / L4 Readiness Planning stage. It does not authorize L4 execution.

## Evidence Inventory

### Active Dashboard Target

`Package.swift` defines `Dashboard` as an executable target with:

- target path: `Sources/Dashboard`
- dependencies: `Core`, `Persistence`
- source roots:
  - `DashboardApplication.swift`
  - `DashboardTargetBoundary.swift`
  - `DashboardShell.swift`
  - `ReadModels/`
  - `Report/`
  - `Events/`
  - `FutureLiveProConsole/`

This means Dashboard is the only active UI target in the current SwiftPM target graph.

### Retired Active Paths

Current source directory checks confirm these active paths are absent:

- `Sources/Workbench/`
- `Sources/AppCompatibility/`
- top-level `Sources/TargetGraph/`

The remaining module-local `TargetGraph/` directories are per-module boundary anchors, not a top-level active source directory. Their naming cleanup is outside GH-380 and remains a separate candidate cleanup topic.

### Dashboard Read-model-only Boundary

`architecture.md` records the current boundary:

- `Dashboard` executable target owns the read-model-only display surface.
- `Dashboard` depends on `Core` and `Persistence` read-model / ViewModel exports.
- `Dashboard` does not directly depend on `Adapters`, `Runtime`, `ExecutionClient`, broker, OMS, schema, account payload, broker state, or live command.
- `App` product / target, `Sources/AppCompatibility`, `Workbench` product / target, and `Sources/Workbench/` are retired.

`Sources/Dashboard/DashboardTargetBoundary.swift` states that Dashboard:

- reads read model / ViewModel / projection snapshot only;
- must not read Runtime object, Adapter request, SQLite / DuckDB schema, account payload, or broker state;
- must not expose Live PRO Console, trading button, live command, or order form.

## Retired Wording Review

Some source filenames, comments, and smoke fields still include historical `Workbench` wording, for example:

- `WorkbenchBetaAcceptancePath.swift`
- `WorkbenchBetaFirstRunState.swift`
- `PaperWorkflowWorkbenchArchitecture.swift`
- smoke output key `workbenchReadModelOnly`

These are not active `Sources/Workbench` module paths. They are retained historical names for existing dashboard evidence surfaces and should be treated as wording cleanup candidates only. They do not restore Workbench as an active module.

## Completion Matrix

| Check | Result | Evidence |
|---|---|---|
| Active UI target is Dashboard | Pass | `Package.swift` target `Dashboard`, path `Sources/Dashboard` |
| `Sources/Workbench` retired | Pass | directory absent |
| `Sources/AppCompatibility` retired | Pass | directory absent |
| top-level `Sources/TargetGraph` retired | Pass | directory absent |
| Dashboard consumes read model / ViewModel / projection snapshot only | Pass | `DashboardTargetBoundary.swift`, `architecture.md` |
| Dashboard blocks Live PRO Console / trading button / live command / order form | Pass | Dashboard report and shell boundary flags |
| Dashboard still depends on compatibility envelopes | Known retained envelope | `Dashboard -> Core / Persistence` |

## Boundary Evidence

- No Trader runtime added.
- No Strategy runtime added.
- No Live runtime added.
- No ExecutionClient implementation added.
- No OMS or broker gateway added.
- No signed endpoint, account endpoint, listenKey, or private WebSocket runtime added.
- No real order lifecycle, submit / cancel / replace, execution report, broker fill, or reconciliation added.
- No Live PRO Console, trading button, live command, or order form added.
- No SwiftPM target graph change in GH-380.
- No Source movement in GH-380.

## GH-380 Acceptance Criteria

- AC1: Dashboard read-model-only boundary review is documented.
- AC2: Workbench / AppCompatibility active path retirement evidence is recorded.
- AC3: Validation output is recorded in `verification.md`.

