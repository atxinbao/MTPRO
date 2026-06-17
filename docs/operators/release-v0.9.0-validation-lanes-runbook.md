# MTPRO Release v0.9.0 Validation Lanes Runbook

日期：2026-06-17

执行者：Codex

## GH-854-RELEASE-V090-VALIDATION-LANES-RUNBOOK

本文档服务 GitHub fallback issue `GH-854 V090-012 Split CI and manual lanes further`。它把 v0.9.0 的 deterministic CI lane 和 manual operator testnet read-only lane 再次拆清楚：CI lane 只证明 deterministic / no-network / no-secret / no-order guard；manual lane 只记录 operator 手动完成的 testnet read-only proof reference。

## Anchors

- `GH-854-VERIFY-V090-VALIDATION-LANES`
- `TVM-RELEASE-V090-VALIDATION-LANES`
- `V090-012-VALIDATION-LANES`
- `V090-012-DETERMINISTIC-CI-LANE`
- `V090-012-MANUAL-OPERATOR-TESTNET-LANE`
- `V090-012-MANUAL-PROOF-NOT-CI-REPLAYABLE`
- `V090-012-CI-NO-NETWORK-SECRET-ORDER`
- `V090-012-MANUAL-NO-ORDER-PRODUCTION-CUTOVER`

## Deterministic CI Lane

CI lane 固定为 deterministic fixture 和 source / docs / script anchor checks。它必须保持：

- `ciNetworkRequired=false`
- `ciSecretRead=false`
- `ciOrderSubmissionAllowed=false`
- `workflowDispatchCanInjectSecret=false`

CI lane 的命令是：

- `bash checks/verify-v0.9.0-validation-lanes.sh`
- `swift test --filter TargetGraphTests/testGH854ValidationLanesKeepManualProofOutOfCIReplay`

CI lane 不接收 manual proof reference，不读取 operator credential reference，不读取 testnet secret，不连接 endpoint，也不把 manual proof 当成 required checks evidence。

## Manual Operator Testnet Lane

Manual lane 只允许 operator 明确确认后的 testnet read-only proof reference。它必须保持：

- `manualOperatorConfirmationRequired=true`
- `manualProofRedacted=true`
- `manualOrderSubmissionAllowed=false`
- `manualProofReplayableByCI=false`

Manual lane checklist：

- `explicit-operator-confirmation-id`
- `redacted-credential-reference`
- `redacted-manual-proof-reference`
- `testnet-read-only-source-artifact`
- `no-order-submission-proof`

manual proof cannot be replayed by CI。manual proof 不能满足 required checks，不能被 workflow_dispatch 注入 secret 后自动重放，不能升级为 Dashboard / CLI command source。

## Boundary

本 runbook 不新增 runtime pipeline，不打开 CI network，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order，不授权 production cutover。
