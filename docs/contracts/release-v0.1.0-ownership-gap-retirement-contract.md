# Release v0.1.0 Ownership Gap Retirement Contract

日期：2026-06-08

执行者：Codex

本文档服务 GitHub fallback issue `GH-522 Retire remaining Core / Adapters / Persistence / Runtime ownership gaps`。

本文档只收口 `MTPRO Release v0.1.0` 的 release-path ownership gap：哪些 release 能力已经由真实 module source root 承载，哪些 retained compatibility envelope 必须明确 deferred 到后续 issue。本文档不实现 runtime，不移动生产 source，不读取 secret，不连接 production endpoint，不提交真实订单，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma。

## GH-522-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT

`GH-522-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT`

Release v0.1.0 的 active implementation owner 只能是对应 architecture target 的真实 source root；`Core`、`Adapters`、`Persistence` 和 `Runtime` 在本 release queue 中只能作为 retained compatibility envelope 或 deferred bridge 被描述，不能作为 v0.1.0 active runtime owner。

本 issue 的完成标准不是强行删除所有 retained envelope，而是把 release-path gap 全部关闭或明确 deferred：

- 已关闭：Binance public read-only implementation 由 `DataClient` 承载，market-data cache 由 `Cache` 承载，EMA strategy 由 `TraderStrategies` / `Trader` 承载，Risk / Execution future-gate evidence 由各自 targets 承载。
- 已关闭：`Adapters` 只保留 `AdaptersCompatibility.swift` re-export compatibility surface，不拥有 release v0.1.0 active runtime implementation。
- 明确 deferred：`Runtime` 当前仍编译 `Sources/DataEngine/Ingest` 和 `Sources/Database/ReplayProjection` 的 legacy workflow composition；GH-524 / GH-533 必须在各自 scope 内用真实 module APIs 替代或封装，不能继续把 `Runtime` 当作 release runtime owner。
- 明确 deferred：`Persistence` 当前仍编译 SQLite / DuckDB projection adapters；release persistence / reconciliation ownership 只能由 GH-533 或后续明确 issue 收口，不能在 GH-522 越界重连 Database / Portfolio / Execution dependencies。
- 明确 deferred：`Core` 仍保留 legacy live / paper / evidence compatibility surfaces；release v0.1.0 后续 issue 不得把新的 active Binance / EMA / live / order runtime source 落回 `Core`。

## GH-522-RELEASE-OWNERSHIP-AUTHORITY

`GH-522-RELEASE-OWNERSHIP-AUTHORITY`

| Release domain | Active owner for v0.1.0 planning | Current decision | Follow-up issue |
| --- | --- | --- | --- |
| Binance public market data client | `DataClient` | closed | GH-524 consumes it through DataEngine / Cache |
| DataEngine public ingest / replay path | `DataEngine` / `Cache` | deferred legacy `Runtime` composition must not be final owner | GH-524 |
| Signed account read | future `DataClient` / account read boundary under release gate | deferred, no current production secret or endpoint | GH-525 |
| Private stream / account snapshot | future read-only runtime boundary under release gate | deferred, no listenKey or private WebSocket by default | GH-526 |
| Trader lifecycle and EMA strategy | `Trader` + `TraderStrategies` | closed baseline, runtime lifecycle deferred | GH-527 / GH-528 |
| Risk pre-trade gate | `RiskEngine` | closed baseline, live gate implementation deferred | GH-529 |
| Order lifecycle / OMS | `ExecutionEngine` | future-gated, implementation deferred | GH-530 |
| Binance testnet execution client | `ExecutionClient` | future-gated, testnet-only implementation deferred | GH-531 / GH-532 |
| Reconciliation / Portfolio update | `ExecutionEngine` + `Portfolio` + private projection boundary | deferred; `Persistence` remains compatibility envelope only | GH-533 |
| Dashboard monitoring / command split | `Dashboard` | read-model baseline closed, live surface deferred | GH-534 / GH-535 |

## GH-522-COMPATIBILITY-ENVELOPE-MATRIX

`GH-522-COMPATIBILITY-ENVELOPE-MATRIX`

| Envelope | Release v0.1.0 decision | Allowed wording | Forbidden wording |
| --- | --- | --- | --- |
| `Core` | retained compatibility only | legacy / compatibility / deferred bridge | active Binance runtime owner, active EMA runtime owner, production command owner |
| `Adapters` | closed as re-export only | DataClient compatibility re-export | signed endpoint adapter, account adapter, broker adapter, execution adapter |
| `Persistence` | deferred projection adapter envelope | SQLite / DuckDB private projection compatibility | release reconciliation runtime owner, Dashboard schema contract, broker payload store |
| `Runtime` | deferred workflow composition envelope | ingest / replay projection compatibility bridge | release v0.1.0 runtime owner, Live runtime, production operations runtime |

## GH-522-DEFERRED-OWNERSHIP-REGISTER

`GH-522-DEFERRED-OWNERSHIP-REGISTER`

Deferred items are intentionally not implemented in GH-522:

- `Runtime -> DataEngine/Ingest`：GH-524 必须 decide whether to consume, replace, or wrap the legacy workflow through `DataEngine` / `Cache` owner APIs.
- `Runtime -> Database/ReplayProjection`：GH-524 / GH-533 must keep replay projection read-model-only and avoid treating `Runtime` as release owner.
- `Persistence -> Database/Projections`：GH-533 must decide the release reconciliation / portfolio projection update path without exposing SQLite / DuckDB schema.
- `Core -> LiveTradingBoundary / LiveMonitoring*`：GH-525 至 GH-536 may consume terms or evidence, but new release runtime source must live in the appropriate target, not in `Core`.

## GH-522-NO-PRODUCTION-AUTHORIZATION

`GH-522-NO-PRODUCTION-AUTHORIZATION`

GH-522 不授权 production trading，不授权 production secret，不授权 production endpoint，不授权 real order submit / cancel / replace。它只固定 ownership 和 deferred register，避免后续 issue 把 compatibility envelope 误当作 release runtime owner。

Production default remains：

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `productionOrderSubmitEnabledByDefault == false`
- `nonBinanceVenueEnabled == false`
- `nonEMAStrategyEnabled == false`

## GH-522-VALIDATION-ANCHORS

`GH-522-VALIDATION-ANCHORS`

Required anchors：

- `GH-522-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT`
- `GH-522-RELEASE-OWNERSHIP-AUTHORITY`
- `GH-522-COMPATIBILITY-ENVELOPE-MATRIX`
- `GH-522-DEFERRED-OWNERSHIP-REGISTER`
- `GH-522-NO-PRODUCTION-AUTHORIZATION`
- `TVM-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT`

Required validation：

- `swift test --filter TargetGraphTests/testGH522ReleaseV010OwnershipGapsAreRetiredOrExplicitlyDeferred`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-522-NON-AUTHORIZATION

`GH-522-NON-AUTHORIZATION`

GH-522 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- runtime implementation。
- moving production source into a new target graph shape.
- production trading。
- production secret read / print / storage。
- production endpoint connection。
- non-Binance venue。
- non-EMA active strategy。
- RiskEngine bypass。
- ExecutionEngine / OMS bypass。
- kill switch / no-trade bypass。
- real production submit / cancel / replace。
- production Dashboard command surface。
- 下一 Project / Issue 创建或 release v0.1.0 后续阶段推进。
