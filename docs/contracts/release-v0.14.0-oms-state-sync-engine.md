# Release v0.14.0 OMS State Sync Engine Contract

日期：2026-06-21
执行者：Codex

## 范围

`ReleaseV0140OMSStateSyncEngine` 是 GH-1033 的本地 OMS state sync engine。它只消费 GH-1032 `ReleaseV0140OrderEventSourcingStream` 或 append-only order events，并通过 replay 得到当前本地订单状态 snapshot。

本合同覆盖：

- 从 event-sourced order lifecycle evidence 推导 current local order state。
- 校验 stream projection 与 replay projection 完全一致。
- 对空事件、缺失 append、缺失中间 lifecycle event、projection 漂移 fail closed。
- 输出 `ReleaseV0140OMSStateSyncSnapshot` 和 `ReleaseV0140OMSStateSyncRecord`，保留 event / correlation / causation / risk / execution / OMS / adapter evidence ID 链路。

## 非目标

- 不实现 production OMS。
- 不实现 broker adapter。
- 不实现 signed endpoint、account endpoint、listenKey 或 private stream runtime。
- 不连接 production endpoint 或 broker endpoint。
- 不读取 production secret。
- 不执行 submit / cancel / replace。
- 不保存原始 broker payload。
- 不解析 broker fill。
- 不实现 reconciliation runtime。
- 不授权 production cutover。

## 状态来源

state sync 的唯一来源是 `ReleaseV0140OrderEventSourcingStream.events`。

`ReleaseV0140OMSStateSyncEngine.sync(stream:)` 必须：

1. 要求 source stream 非空。
2. 使用 `ReleaseV0140OrderEventSourcingStream.replay(events:)` 重放事件。
3. 要求 replay 后 projections 与 source stream projections 完全一致。
4. 只从 replay projections 生成当前 state records。
5. 拒绝任何隐藏 runtime mutable state。

## Fail-closed 规则

以下情况必须失败：

- event list 为空。
- lifecycle event 出现在 append event 之前。
- 中间 lifecycle event 缺失，导致 event.fromState 与当前 projection state 不一致。
- source stream projections 与 replay projections 不一致。
- snapshot 或 record 尝试声明 hidden runtime state 已被修改。
- snapshot 或 record 包含 broker payload、broker fill、reconciliation runtime、network order action 或 production capability。

## 验证锚点

- `GH-1033-OMS-STATE-SYNC-ENGINE`
- `GH-1033-STATE-DERIVED-FROM-EVENTS`
- `GH-1033-FAIL-CLOSED-MISSING-EVENTS`
- `TVM-RELEASE-V0140-OMS-STATE-SYNC`

## 验证命令

- focused guard：`bash checks/verify-v0.14.0-oms-state-sync-engine.sh`
- focused test：`TargetGraphTests/testGH1033ReleaseV0140OMSStateSyncEngineDerivesCurrentStateFromEvents`
- aggregate：`bash checks/run.sh`

## 边界证据

该合同不授权真实交易。`productionTradingEnabledByDefault` 必须保持 `false`；production secret、production endpoint、broker endpoint、真实 order、broker fill、reconciliation runtime 和 production cutover 均保持关闭。
