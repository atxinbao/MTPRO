# Release v0.14.0 Execution Event Log Contract

日期：2026-06-22  
执行者：Codex

## Goal

GH-1040 / V140-016 为 v0.14.0 testnet trading closed loop 增加 read-optimized execution event log surface。

该 surface 只用于检查和展示 Strategy Signal -> OrderIntent -> RiskEngine -> Binance testnet adapter -> OMS local order -> order event log -> reconciliation 的 evidence ID 链路。

## Scope

- `GH-1040-EXECUTION-EVENT-LOG`
- `GH-1040-RUN-ORDER-INTENT-LINKAGE`
- `GH-1040-REDACTED-READONLY-SURFACE`
- `TVM-RELEASE-V0140-EXECUTION-EVENT-LOG`

实现文件：

- `Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140ExecutionEventLog.swift`

验证文件：

- `checks/verify-v0.14.0-execution-event-log.sh`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

## Event Coverage

Execution event log 必须覆盖七类只读事件：

1. `strategySignal`
2. `orderIntent`
3. `riskDecision`
4. `adapterSubmit`
5. `omsLocalOrder`
6. `orderEventLog`
7. `reconciliation`

每条 entry 必须保留：

- `runID`
- `signalID`
- `orderIntentID`
- `sourcePipelineReportID`
- 对应阶段的 risk / adapter / OMS / event stream / state sync / reconciliation evidence ID

## Non-goals

- 不实现 production trading。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送真实 submit / cancel / replace。
- 不创建 Dashboard trading button 或 production order form。
- 不扩展非 Binance venue。
- 不扩展非 EMA / RSI active strategy。

## Boundary

Execution event log 是 read-only evidence surface：

- `readOptimized == true`
- `independentlyInspectable == true`
- `redactedEvidenceOnly == true`
- `testnetEvidenceOnly == true`
- `productionTradingEnabledByDefault == false`
- `productionSecretRead == false`
- `productionEndpointConnected == false`
- `productionSubmitCancelReplace == false`
- `productionCutoverAuthorized == false`

## Validation

必须通过：

- `bash checks/verify-v0.14.0-execution-event-log.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Rollback

可回滚本 issue commit，并从 `checks/run.sh` 移除 `checks/verify-v0.14.0-execution-event-log.sh` 调用，恢复到 GH-1039 failure simulation suite 之后的 v0.14.0 状态。
