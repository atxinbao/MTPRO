# Production Audit Trail Gate Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-647 PCHR-05 Harden OMS and Event Store production audit trail`。

本文档定义 `MTPRO Production Cutover Runtime Hardening v1` 的 OMS / Event Store production audit trail 合同。它只固定 command、risk decision、OMS transition 和 execution intent 的 append-only evidence、idempotency、replay 和 rollback / repair 证据，不实现 production Event Store runtime，不提交真实订单。

## PCHR-05-OMS-EVENT-STORE-PRODUCTION-AUDIT-TRAIL

`PCHR-05-OMS-EVENT-STORE-PRODUCTION-AUDIT-TRAIL`

GH-647 依赖 GH-646 的 command dispatch gate。当前权威 source anchor：

- `Sources/ExecutionEngine/OMSFutureGate/ProductionAuditTrailGate.swift`
- `docs/contracts/production-command-dispatch-gate-contract.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH647ProductionAuditTrailRequiresAppendOnlyReplayAndRepairEvidence`

合同固定：

- upstream issue 固定为 `GH-646`
- downstream issue 固定为 `GH-648`
- queue range 固定为 `GH-643..GH-649`
- `upstreamCommandDispatchGateHeld == true`
- command、risk decision、OMS transition、execution intent 都必须作为 append-only event 存在。

## PCHR-05-APPEND-ONLY-COMMAND-RISK-OMS-EXECUTION-EVENTS

`PCHR-05-APPEND-ONLY-COMMAND-RISK-OMS-EXECUTION-EVENTS`

Command、risk decision、OMS transition 和 execution intent 必须写成 append-only audit events。Event row 只记录 deterministic identity 和 replay metadata，不包含 secret、broker payload、account payload、production endpoint response 或真实 order state mutation。

Required evidence：

- `appendOnlyEvidenceRequired == true`
- 每条 event 满足 `appendOnly == true`
- 每条 event 满足 `mutableWriteAllowed == false`
- event sequence 固定为 `1, 2, 3, 4`

## PCHR-05-EVENT-IDEMPOTENCY

`PCHR-05-EVENT-IDEMPOTENCY`

Audit event 必须有 idempotency key，重复 event 不能破坏 replay 或进入执行 handoff。

Required evidence：

- `eventIdempotencyRequired == true`
- 每条 event 满足 `idempotent == true`
- 每条 event 有唯一 `idempotencyKey`

## PCHR-05-REPLAY-RESTORES-COMMAND-STATE

`PCHR-05-REPLAY-RESTORES-COMMAND-STATE`

Replay 必须能恢复关键 command state，至少覆盖 command recorded、risk approved、OMS transition recorded 和 execution intent pending。

Required evidence：

- `replayRestoresKeyCommandState == true`
- `replayRepairEvidence.replayRestoresKeyState == true`
- replayed event ids 与 append-only event ids 一致。

## PCHR-05-ROLLBACK-REPAIR-EVIDENCE

`PCHR-05-ROLLBACK-REPAIR-EVIDENCE`

Audit trail 必须能输出 rollback / repair evidence identity，但不得自动修复、自动重试或提交真实订单。

Required evidence：

- `rollbackRepairEvidenceRequired == true`
- `rollbackRepairEvidenceProduced == true`
- `automaticRepairEnabled == false`

## PCHR-05-MISSING-AUDIT-BLOCKS-HANDOFF

`PCHR-05-MISSING-AUDIT-BLOCKS-HANDOFF`

缺少 audit trail write 时，command 不能进入 execution handoff。

Required evidence：

- `missingAuditTrailBlocksExecutionHandoff == true`
- `executionHandoffAllowedWithoutAuditTrail == false`
- `eventStoreBypassAllowed == false`

## PCHR-05-NO-PRODUCTION-ORDER-AUTHORIZATION

`PCHR-05-NO-PRODUCTION-ORDER-AUTHORIZATION`

GH-647 不授权真实订单能力，不读取 secret，不连接 production endpoint，不连接 broker gateway。

Required evidence：

- `productionEndpointAutoConnectEnabled == false`
- `productionSecretAutoReadEnabled == false`
- `realBrokerConnectionEnabled == false`
- `realOrderSubmissionEnabled == false`
- events 不包含 secret、broker payload 或 production order state mutation。

## TVM-PCHR-OMS-EVENT-STORE-AUDIT-TRAIL

`TVM-PCHR-OMS-EVENT-STORE-AUDIT-TRAIL`

Required validation：

- `swift test --filter TargetGraphTests/testGH647ProductionAuditTrailRequiresAppendOnlyReplayAndRepairEvidence`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## PCHR-05 Non-authorization

GH-647 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- production secret auto-read。
- production endpoint auto-connect。
- Dashboard / CLI direct ExecutionClient。
- broker adapter / real broker connection。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS runtime。
- production Event Store runtime。
- automatic rollback / repair execution。
- Event Store bypass。
- CommandGateway / RiskEngine / ExecutionEngine / OMS bypass。
- 非 Binance venue。
- Spot / USDⓈ-M Perpetual 之外的 product type。
- EMA / RSI 之外的 active strategy。
- 下一阶段 Project / Issue 自动启动。
