# Release v0.21.0 Binance Spot Canary Credential Secret-read Approval

日期：2026-07-02  
执行者：Codex

## Scope

GH-1275 固定 `MTPRO Release v0.21.0 Binance Spot Controlled Production Canary`
的 credential secret-read approval path。该 path 只表达 Human operator 已明确批准
后续 Binance Spot canary gate 可以读取所需 credential secret，并要求所有审批证据
脱敏、可审计、append-only、fail-closed。

验证锚点：

- `GH-1275-VERIFY-V0210-CREDENTIAL-SECRET-READ-APPROVAL`
- `TVM-RELEASE-V0210-CREDENTIAL-SECRET-READ-APPROVAL`
- `V0210-003-CREDENTIAL-SECRET-READ-APPROVAL`
- `V0210-003-EXPLICIT-OPERATOR-APPROVAL`
- `V0210-003-REDACTED-AUDIT-EVIDENCE`
- `V0210-003-NO-AUTOMATIC-SECRET-DISCOVERY`
- `V0210-003-NO-SECRET-LOGGING`
- `V0210-003-NO-ENDPOINT-ORDER-CUTOVER`

## Contract

GH-1275 依赖 GH-1274 的 Binance Spot canary environment profile，并为 GH-1276
之后的 signed account read-only preflight 提供唯一可消费的审批证据。审批通过不等于
本 issue 读取 secret；本 issue 只记录 approval path、redacted credential reference 和
fail-closed audit evidence。

| Field | Required Value |
| --- | --- |
| Issue | `GH-1275` |
| Upstream | `GH-1274` |
| Downstream | `GH-1276` |
| Queue | `GH-1273..GH-1286` |
| Venue | Binance |
| Product | Spot |
| Environment identity | `productionLive` identity only |
| Operator approval | explicit Human operator approval evidence required |
| Secret read | approved for downstream canary gate only |
| This issue reads secret value | no |
| Production cutover | not authorized |

## Fail-closed Rules

- `ReleaseV0210SpotCanaryCredentialSecretReadApprovalPath` defaults to
  `approvedForScopedSecretRead` only when redacted Human operator approval evidence is present.
- Missing operator approval produces fail-closed audit evidence and keeps
  `credentialSecretReadApproved == false`.
- Approval evidence must keep `operatorApprovalEvidenceRedacted == true`.
- The audit summary must contain `<redacted>` and must not contain secret material.
- No automatic secret discovery or fallback secret provider is allowed.
- No credential value is read, logged, stored or persisted by GH-1275.

## Forbidden Capabilities

GH-1275 does not read secret value, does not log API key / secret key / listenKey, does not
store raw credential material, does not discover fallback secrets, does not connect production
endpoint / broker endpoint, does not implement signed account endpoint runtime, does not
implement private stream runtime, does not submit / cancel / replace orders, does not add
Dashboard trading button / order form / live command, does not include Futures or OKX active
implementation, does not create tag / GitHub Release and does not authorize production cutover.

This document intentionally contains no credential value and no production endpoint connection
instruction.

## Validation

Required commands:

- `swift test --filter TargetGraphTests/testGH1275ReleaseV0210CredentialSecretReadApprovalPath`
- `bash checks/verify-v0.21.0-credential-secret-read-approval.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
