# Release v0.14.0 Failure Simulation Suite Contract

日期：2026-06-22  
执行者：Codex

## Scope

GH-1039 增加 `ReleaseV0140FailureSimulationSuite`，用于在 v0.14.0 testnet trading closed loop 中生成本地、确定性的失败路径审计证据。

覆盖范围：

- adapter rejection
- risk rejection
- invalid lifecycle transition
- reconciliation mismatch
- timeout
- kill switch

## Contract

`ReleaseV0140FailureSimulationEvidence` 必须满足：

- 每个 failure mode 都有唯一 `evidenceID`。
- 每个 failure mode 都必须 `failClosed == true`。
- 每个 failure mode 都必须 `auditEvidenceEmitted == true`。
- 不允许 fallback 到 production endpoint。
- 不允许读取 production secret。
- 不允许连接 production / broker endpoint。
- 不允许 production submit / cancel / replace。

`ReleaseV0140FailureSimulationSuiteReport` 必须覆盖全部六类 mode，并保留以下 validation anchors：

- `GH-1039-FAILURE-SIMULATION-SUITE`
- `GH-1039-FAIL-CLOSED-AUDIT-EVIDENCE`
- `GH-1039-NO-PRODUCTION-FALLBACK`
- `TVM-RELEASE-V0140-FAILURE-SIMULATION-SUITE`

## Failure Semantics

adapter rejection 通过现有 Binance testnet adapter boundary 的 fail-closed constructor 证明 forbidden adapter capability 不会继续进入 request / OMS / reconciliation。

risk rejection 通过现有 `ReleaseV0140SignalToExecutionPipeline` 证明 over-limit intent 在 RiskEngine 被 rejected，且 adapter submit evidence / OMS / reconciliation 均未触达。

invalid transition 通过 `OrderLifecycleTransition` 的状态机校验证明非法状态迁移抛错并 fail closed。

reconciliation mismatch 通过现有 `ReleaseV0140ReconciliationEngine` 生成 failed report，并显式包含 `lifecycleStateMismatch`。该 mode 只允许 `adapterSubmitEvidenceCreated=true` 表示本地 adapter evidence 已创建，仍必须保持 `networkSubmitAttempted=false` 和 `networkCancelReplaceAttempted=false`。

timeout 是本地 deterministic timeout evidence，只表示 testnet acknowledgement timeout 被记录并 fail closed，不触发 retry fallback 或 production endpoint。

kill switch 通过现有 pipeline 的 `killSwitchActive` path 证明 submit 在 RiskEngine 阶段 blocked，且不会进入 adapter / OMS / reconciliation。

## Non-goals

- 不实现真实网络 timeout runtime。
- 不连接 Binance production endpoint。
- 不读取 production secret。
- 不发送真实订单。
- 不授权 production cutover。
- 不新增非 Binance venue。
- 不新增 EMA / RSI 之外的 active strategy。
- 不新增 Dashboard command surface 或交易按钮。

## Validation

```bash
bash checks/verify-v0.14.0-failure-simulation-suite.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Boundary Evidence

该 suite 只生成本地 Codex / CI 可复放证据。它不创建 `URLSession` / `URLRequest`，不保存 API key / secret，不使用 HMAC / signature，不创建 listenKey，不包含 Binance production host，也不执行 submit / cancel / replace 网络动作；`networkSubmitAttempted` 与 `networkCancelReplaceAttempted` 必须始终为 false。
