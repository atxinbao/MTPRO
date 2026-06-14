# Release v0.5.0 DataEngine Operational Dry-run Path Contract

执行日期：2026-06-14  
执行者：Codex

## Scope

本文档定义 GH-732 / V050-07 的 DataEngine operational dry-run path。该 path 只把 Binance public market input 经由 DataClient 解码后送入 DataEngine，再发布为 typed `DataEngineMarketEvent` 到 `RuntimeMessageBus`，并投影到 product-aware Cache read model。

## Required Anchors

- `V050-07-DATAENGINE-OPERATIONAL-DRY-RUN-PATH`
- `V050-07-PUBLIC-MARKET-INPUT-DATACLIENT-DATAENGINE`
- `V050-07-TYPED-DATAENGINE-MARKET-EVENTS`
- `V050-07-RUN-SCOPED-MESSAGEBUS-CACHE-PROJECTION`
- `TVM-RELEASE-V050-DATAENGINE-OPERATIONAL-DRY-RUN-PATH`

## Evidence Surface

- Source: `Sources/DataEngine/ReleaseV050DataEngineOperationalDryRunPath.swift`
- Focused validation: `checks/verify-v0.5.0-dataengine.sh`
- Target test: `TargetGraphTests/testGH732DataEngineOperationalDryRunPathPublishesTypedMarketEventsIntoMessageBusAndCache`
- Queue dependencies: GH-728 environment / endpoint / secret policy, GH-730 typed RuntimeMessageBus, GH-731 durable local run journal.

## Runtime Boundary

GH-732 允许：

- Binance-only public market data input。
- Spot + USDⓈ-M Perpetual product identity。
- DataClient public market path into DataEngine。
- Typed `DataEngineMarketEvent` envelope with runID、streamID、correlationID、causationID、sourceModule、payloadType 和 checksum。
- Product-aware Cache projection and replay proof。

GH-732 不允许：

- production endpoint connection。
- production secret read。
- account endpoint / signed endpoint / listenKey / private stream。
- broker adapter、ExecutionClient command、OMS lifecycle、submit / cancel / replace。
- production trading default enablement。
- production cutover authorization。

## Validation

- `swift test --filter TargetGraphTests/testGH732DataEngineOperationalDryRunPathPublishesTypedMarketEventsIntoMessageBusAndCache`
- `bash checks/verify-v0.5.0-dataengine.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Handoff

GH-732 只交付 DataEngine public market operational dry-run bridge。后续 GH-733 / GH-734 / GH-739 可以消费 typed market event 和 Cache projection evidence，但不得把该 path 解释为 testnet network authorization、private account truth、broker execution source 或 production cutover authorization。
