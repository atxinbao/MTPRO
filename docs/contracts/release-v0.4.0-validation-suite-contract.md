# Release v0.4.0 Validation Suite Contract

日期：2026-06-13

执行者：Codex

## 目标

GH-707 / V040-14 定义 release v0.4.0 unified runtime rehearsal pipeline 的 one-command validation suite。该 suite 串联 GH-694 至 GH-706 focused TargetGraph tests，并执行 `mtpro unified-run-status` CLI smoke，证明 dry-run pipeline、shadow replay、testnet disabled-by-default 与 production-disabled guard 都仍保持可验证。

该合同不新增 runtime pipeline，不连接 testnet / production endpoint，不读取 secret，不调用 signed endpoint、account endpoint、broker gateway，不发送真实订单，不授权 production cutover。

## Anchors

- `GH-707-VERIFY-V040-RELEASE-VALIDATION-SUITE`
- `V040-14-VERIFY-RELEASE-VALIDATION-SUITE`
- `V040-14-COMPLETE-UNIFIED-RUNTIME-CHAIN`
- `V040-14-SHADOW-REPLAY-SMOKE`
- `V040-14-TESTNET-DISABLED-BY-DEFAULT`
- `V040-14-PRODUCTION-DISABLED-BOUNDARY`
- `TVM-RELEASE-V040-VERIFY-VALIDATION-SUITE`

## Scope

- `checks/verify-v0.4.0.sh` owns the release v0.4.0 validation entrypoint.
- `checks/run.sh` invokes `bash checks/verify-v0.4.0.sh`.
- The suite covers GH-694 through GH-706 focused TargetGraph tests.
- The suite executes `swift run mtpro unified-run-status` and checks production-disabled CLI evidence.
- GH-708 may consume this suite for the operator runbook, but validation success is not production cutover approval.
- `Tests/TargetGraphTests/TargetGraphTests.swift` must include `testGH707VerifyV040ReleaseValidationSuiteCoversUnifiedRuntimeShadowAndGuards`.

## Acceptance

- `checks/verify-v0.4.0.sh` exists and contains `GH-707-VERIFY-V040-RELEASE-VALIDATION-SUITE`.
- The suite includes GH-694 through GH-706 focused tests.
- The suite checks `mtpro unified-run-status blocked`.
- The suite checks `productionTradingEnabledByDefault=false`, `productionEndpointConnected=false`, `productionSecretRead=false`, `productionOrderSubmitted=false`, `productionCutoverAuthorized=false` and `boundaryHeld=true`.
- The suite checks dry-run guard source anchors, testnet guarded mode defaults and shadow replay non-approval semantics.

## Boundary

- No production trading enabled by default.
- No production secret read.
- No production endpoint connection.
- No production broker connection.
- No account endpoint / listenKey / private WebSocket runtime.
- No real submit / cancel / replace.
- No production cutover authorization.
- No next milestone auto-start.

## Required Validation

- `bash checks/verify-v0.4.0.sh`
- `swift test --filter TargetGraphTests/testGH707VerifyV040ReleaseValidationSuiteCoversUnifiedRuntimeShadowAndGuards`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
