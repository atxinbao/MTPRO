# Release v0.14.0 Reconciliation Engine Contract

日期：2026-06-21
执行者：Codex

## 范围

`ReleaseV0140ReconciliationEngine` 是 GH-1036 的本地 reconciliation evidence engine。它只消费：

- GH-1033 `ReleaseV0140OMSStateSyncSnapshot`
- GH-1032 `ReleaseV0140OrderEventSourcingStream`
- GH-1036 `ReleaseV0140TestnetExecutionObservation`

该 engine 对齐本地 OMS current state、append-only event log、redacted testnet acknowledgement / fill summary evidence，并输出 `ReleaseV0140ReconciliationReport`。

## 非目标

- 不实现 production OMS。
- 不实现 broker adapter。
- 不实现 signed endpoint、account endpoint、listenKey 或 private stream runtime。
- 不连接 production endpoint 或 broker endpoint。
- 不读取 production secret。
- 不执行 submit / cancel / replace。
- 不保存原始 execution payload。
- 不实现真实 broker fill runtime。
- 不授权 production cutover。

## Reconciliation 规则

`ReleaseV0140ReconciliationEngine.reconcile(snapshot:stream:observations:)` 必须：

1. 要求 snapshot、stream 和 observations 均保持 boundary。
2. 要求 snapshot 的 source stream / event IDs 与输入 stream 完全一致。
3. 要求每条 observation 能找到对应 state sync record。
4. 要求每条 observation 能找到对应 source order event。
5. 要求 observation 的 local order、product、symbol、OrderIntent、lifecycle state、execution evidence、adapter evidence 与 source event / record 对齐。
6. 要求 accepted、partially filled、filled、cancelled、replaced 等 testnet acknowledgement / fill state 都被 observation 覆盖。
7. 对 mismatch 输出 failed `ReleaseV0140ReconciliationReport`，而不是静默接受。

## Fail-closed 规则

以下情况必须进入 failed report 或直接拒绝构造：

- snapshot 与 stream 的 source event IDs 不一致。
- observation 缺少对应 state sync record。
- observation 缺少对应 source event。
- observation identity 与 source event 不一致。
- observation lifecycle state 与 source event to-state 不一致。
- execution evidence ID 或 adapter evidence ID 不一致。
- acknowledgement / fill observation coverage 不完整。
- report 尝试声明 raw execution payload、network order action、production secret、production endpoint 或 production cutover。

## 验证锚点

- `GH-1036-RECONCILIATION-ENGINE`
- `GH-1036-MISMATCH-FAILURE-SURFACE`
- `GH-1036-TESTNET-DRYRUN-SCOPED`
- `TVM-RELEASE-V0140-RECONCILIATION-ENGINE`

## 验证命令

- focused guard：`bash checks/verify-v0.14.0-reconciliation-engine.sh`
- focused test：`TargetGraphTests/testGH1036ReleaseV0140ReconciliationEngineSurfacesMismatchesAsFailures`
- aggregate：`bash checks/run.sh`

## 边界证据

该合同不授权真实交易。`productionTradingEnabledByDefault` 必须保持 `false`；production secret、production endpoint、broker endpoint、真实 order、原始 execution payload、network order action 和 production cutover 均保持关闭。
