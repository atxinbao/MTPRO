# Release v0.14.0 Order Event Sourcing Contract

日期：2026-06-21
执行者：Codex

## Scope

GH-1032 为 v0.14.0 增加 order event sourcing evidence。该合同只把 GH-1031 本地 OMS store event 转成 append-only、可重放的 order event stream，用于审计：

- `Strategy Signal -> OrderIntent -> Risk Check -> Binance testnet Execution -> OMS Event Log -> Reconciliation -> Read-only Dashboard`
- 本地订单 append event。
- 本地 lifecycle transition event。
- correlation / causation / OrderIntent / risk / execution / OMS / adapter evidence ID 链路。

## GH-1032-ORDER-EVENT-SOURCING

`ReleaseV0140OrderEventSourcingStream` 是纯本地 event sourcing container。它只消费 `ReleaseV0140OMSLocalOrderStoreEvent`，不连接 broker，不读取 credential，不生成 URL request，不保存原始 broker payload，也不表示 production OMS 或 production Event Store 已启用。

每条 `ReleaseV0140OrderEventSourcingEvent` 必须保留：

- `correlationID`
- `causationID`
- `orderIntentID`
- `riskEvidenceID`
- `executionEvidenceID`
- `omsEvidenceID`
- `adapterEvidenceID`
- `localOrderID`
- `fromState` / `toState`

`orderAppended` event 必须包含 risk / execution / adapter evidence ID。`lifecycleChanged` event 可按当前 step 的证据可用性保留可选 ID，但必须始终保留 causation 和 OMS evidence。

## GH-1032-APPEND-ONLY-REPLAY

Event stream 的行为必须满足：

- event sequence 必须从 1 连续递增。
- event ID 必须 deterministic。
- 同一个 local order 只能出现一个 append event。
- lifecycle event 必须先存在本地订单 projection。
- lifecycle event 必须符合 `OrderLifecycleStateMachine`。
- replay 必须用已排序 event 重建同一 projection。
- out-of-order event replay 必须 fail closed。

## GH-1032-CORRELATION-CAUSATION-EVIDENCE

GH-1032 只做 evidence link，不做真实执行：

- correlation ID 来自 Strategy Signal / OrderIntent correlation。
- causation ID 来自 source evidence ID。
- OrderIntent ID 来自本地 OMS event。
- risk evidence ID 来自当前 testnet / dry-run risk gate evidence。
- execution evidence ID 来自 submit / cancel / replace evidence。
- OMS evidence ID 来自 GH-1031 store event。
- adapter evidence ID 来自 testnet adapter boundary / path evidence。

这些 ID 只用于审计和 replay，不允许升级成 production command。

## TVM-RELEASE-V0140-ORDER-EVENT-SOURCING

Validation matrix anchor：

- focused test：`TargetGraphTests/testGH1032ReleaseV0140OrderEventSourcingAppendsAndReplaysCorrelatedLifecycleEvidence`
- verifier：`checks/verify-v0.14.0-order-event-sourcing.sh`
- aggregate：`checks/run.sh`

## Non-goals

- 不实现 production Event Store。
- 不实现 production OMS。
- 不实现 broker adapter。
- 不发送 submit / cancel / replace。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不保存 raw broker payload。
- 不解析 broker fill。
- 不执行 reconciliation runtime。
- 不创建 Dashboard trading button、live command 或 production order form。
