# Release v0.17.0 Operator Run Resume From Artifact Store Contract

日期：2026-06-27

执行者：Codex

本文档服务 GitHub fallback issue `#1142 / GH-1142 Add operator run resume from artifact store`。

GH-1142 在 GH-1139 的 `MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening` 边界内执行，并依赖 GH-1140 artifact bundle replay validator 与 GH-1141 signed status query failure model 已完成。它只允许从本地 redacted artifact store 恢复 operator run 的审计连续性，输出 append-only resume cursor；不读取 credential value，不连接 testnet / production endpoint，不提交或重提 testnet / production order，不创建 tag / GitHub Release，不授权 production cutover。

## Required Anchors

- `GH-1142-VERIFY-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE`
- `TVM-RELEASE-V0170-OPERATOR-RUN-RESUME-FROM-ARTIFACT-STORE`
- `V0170-004-LOCAL-ARTIFACT-STORE-RESUME`
- `V0170-004-REPLAY-VALIDATION-REQUIRED`
- `V0170-004-AUDIT-CONTINUITY-PRESERVED`
- `V0170-004-NO-RESUBMIT-ON-RESUME`
- `V0170-004-REDACTED-RESUME-EVIDENCE`
- `V0170-004-NO-PRODUCTION-CUTOVER`

## Resume Contract

GH-1142 的 resume cursor 必须来自本地 `ReleaseV0160LocalExecutionArtifactStore` replay，并先通过 `ReleaseV0170OperatorBetaArtifactBundleReplayValidator`：

1. 读取本地 run manifest 和 append-only record chain。
2. 复用 GH-1140 schema / checksum / action sequence / reconciliation validation。
3. 读取 latest record checksum，生成 `nextSequence = recordCount + 1`。
4. 生成 `auditContinuityChecksum`，把 `runID`、manifest checksum、latest record checksum 和 next sequence 绑定在一起。
5. 明确 `noResubmitOnResume=true`，resume 只恢复本地审计位置，不触发 submit / cancel / replace。

## Fail-closed Rules

GH-1142 遇到以下情况必须 fail closed：

- GH-1140 bundle validation failed。
- local replay 读取失败。
- record chain 为空。
- manifest latest checksum 与 replay record checksum 不一致。
- action sequence 不是 `submit -> cancel -> status -> reconciliation`。
- resume evidence 中出现 credential、listenKey、raw order、broker payload 或 production endpoint marker。

Fail-closed result 只能输出分类、字段和脱敏 detail；不能尝试联网、补单、重提订单或自动恢复 broker state。

## Boundary

GH-1142 keeps these flags closed：

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabled == false`
- `productionEndpointConnectionEnabled == false`
- `productionBrokerConnectionEnabled == false`
- `productionOrderSubmitCancelReplaceEnabled == false`
- `productionCutoverAuthorized == false`

GH-1142 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不发送 testnet 或 production order，不打开 Dashboard trading button、order form、Live PRO Console command 或 production OMS。

## Validation

- `swift test --filter TargetGraphTests/testGH1142ReleaseV0170OperatorRunResumeFromArtifactStore`
- `bash checks/verify-v0.17.0-operator-run-resume-from-artifact-store.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
