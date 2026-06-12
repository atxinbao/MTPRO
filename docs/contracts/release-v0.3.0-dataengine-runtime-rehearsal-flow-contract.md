# Release v0.3.0 DataEngine Runtime Rehearsal Flow Contract

日期：2026-06-13

执行者：Codex

本文档是 GitHub issue `GH-659` 的执行合同证据。它只定义 `MTPRO Release v0.3.0 Runtime Rehearsal v1` 中 DataEngine 对 Binance Spot 与 USDⓈ-M Perpetual public market data 的 rehearsal flow，不授权 production trading、production endpoint、secret 读取、broker adapter 或真实订单。

## V030-03-DATAENGINE-RUNTIME-REHEARSAL-FLOW

GH-659 在 `Sources/DataEngine/ReleaseV030DataEngineRuntimeRehearsalFlow.swift` 中新增 `ReleaseV030DataEngineRuntimeRehearsalFlow`、`ReleaseV030DataEngineRuntimeRehearsalEvidence` 和 `ReleaseV030DataEngineRuntimeRehearsalRecord`。

该 flow 只接收已经由 DataClient / fixture 产生的 product-aware public market data event，并把 event 投影到 `Cache.ProductAwareMarketDataCacheSnapshot` 与 `MessageBus.MessageBusAppendOnlyJournal`。它不创建网络 connector，不读取环境变量，不连接 production endpoint，不生成 signed request，不提交 / 撤销 / 替换订单。

## V030-03-SPOT-REHEARSAL-PRODUCT-IDENTITY

Spot rehearsal event 必须满足：

- venue 固定为 `binance`。
- product type 固定为 `spot`。
- symbol 必须保留在 `InstrumentIdentity` 与 `MarketEvent` 中。
- cache key 必须使用 `ProductAwareMarketDataSeriesKey(instrument:timeframe:)`，不能退回 symbol-only key。
- MessageBus payload type 必须包含 `dataengine.release-v0.3.0.binance.spot`。

## V030-03-USDM-PERP-REHEARSAL-PRODUCT-IDENTITY

USDⓈ-M Perpetual rehearsal event 必须满足：

- venue 固定为 `binance`。
- product type 固定为 `usdsPerpetual`。
- symbol 必须保留在 `InstrumentIdentity` 与 `MarketEvent` 中。
- cache key 必须使用 `ProductAwareMarketDataSeriesKey(instrument:timeframe:)`，与 Spot 同 symbol 时仍保持不同 key。
- MessageBus payload type 必须包含 `dataengine.release-v0.3.0.binance.usdsPerpetual`。

## V030-03-TRACEABLE-DATAENGINE-REHEARSAL-EVIDENCE

GH-659 evidence 必须同时覆盖：

- issue id `GH-659`。
- upstream issue `GH-658`。
- downstream issue `GH-660`。
- canonical queue range `GH-657..GH-670`。
- release version `v0.3.0`。
- upstream environment config anchor `TVM-RELEASE-V030-RUNTIME-ENVIRONMENT-CONFIG`。
- `ProductAwareMarketDataCacheSnapshot.productAwareBoundaryHeld == true`。
- MessageBus append-only journal replay 与原始 envelope 一致。

DataEngine target 不依赖 ExecutionClient target；它只通过稳定 anchor 证明已承接 GH-658 的 environment config 合同，避免 DataEngine 反向获得 ExecutionClient、broker 或 order command 能力。

## V030-03-NO-PRODUCTION-ENDPOINT-DEPENDENCY

GH-659 明确保持以下能力关闭：

- production endpoint auto-connect。
- production secret auto-read。
- production order submission。
- production cutover authorization。
- CommandGateway bypass。
- Strategy direct ExecutionClient access。
- next milestone auto-start。

任一能力被置为 true 时，Swift evidence 必须以 `CoreError.liveTradingBoundaryForbiddenCapability` fail closed。

## Validation

必跑验证：

- `swift test --filter TargetGraphTests/testGH659DataEngineRuntimeRehearsalFlowPreservesSpotPerpProductIdentity`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Trading Matrix Anchor

`TVM-RELEASE-V030-DATAENGINE-RUNTIME-REHEARSAL-FLOW`

该矩阵锚点只覆盖 GH-659 DataEngine rehearsal flow。它不授权真实 Binance production endpoint、signed endpoint、account endpoint、listenKey、private WebSocket、ExecutionClient implementation、OMS、broker fill、reconciliation runtime、Dashboard command 或 production cutover。
