# Release v0.16.0 Manual Testnet Validation Workflow Contract

日期：2026-06-25  
执行者：Codex

## #1111 / GH-1111

`GH-1111-VERIFY-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW`

## GH-1134 / V0161-002

`GH-1134-VERIFY-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT`

`TVM-RELEASE-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT`

`V0161-002-BUNDLE-SCHEMA-PARSED`

`V0161-002-ACTION-SEQUENCE-CHECKED`

`V0161-002-CHECKSUM-REFERENCES-CHECKED`

`V0161-002-NO-SECRET-NO-PRODUCTION-MARKERS`

`V0161-002-NO-PRODUCTION-CUTOVER`

GH-1134 是 v0.16.1 evidence hardening patch 的第二个切片。它不改变 #1111 手动 workflow 的执行边界，只要求 workflow 读取 `evidence_bundle_path` 指向的 redacted bundle JSON 内容，并校验 schema、submit -> status -> cancel -> status -> reconciliation passed 顺序、`sha256:` checksum references、reconciliation passed flag 和 no-secret / no-production markers。

## Scope

GH-1111 只为 `MTPRO Release v0.16.0 Binance Spot Testnet Operator Execution Beta` 增加手动 testnet validation workflow 和 redacted evidence bundle 合同。它要求 operator 在本地手动完成：

- `TVM-RELEASE-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW`
- `V0160-011-MANUAL-WORKFLOW-ONLY`
- `V0160-011-SUBMIT-STATUS-CANCEL-STATUS-SEQUENCE`
- `V0160-011-RECONCILIATION-PASSED`
- `V0160-011-REDACTED-EVIDENCE-BUNDLE`
- `V0160-011-CHECKSUM-REFERENCES`
- `V0160-011-NO-PRODUCTION-CREDENTIALS`
- `V0160-011-NO-PRODUCTION-ENDPOINT`
- `V0160-011-NO-PRODUCTION-CUTOVER`

## Contract

`ReleaseV0160ManualTestnetValidationWorkflow` 是唯一的本地报告验证入口。`ReleaseV0160ManualTestnetValidationReport` 必须固定以下顺序：

```text
submit -> status-after-submit -> cancel -> status-after-cancel -> reconciliation-passed
```

每一步必须提供 redacted artifact path、`sha256:` checksum reference 和 artifact record id。任何缺失步骤、顺序漂移、非 redacted path、checksum 非 SHA256、production marker 或 credential value 都必须 fail closed。

## GitHub Workflow

`docs/history/workflows/release-v0.16.0-manual-testnet-validation.yml` 只能通过 `workflow_dispatch` 手动触发。它只验证 operator 提供的 redacted bundle path 和本地 deterministic guard，不读取 GitHub secrets，不接受 production credential name，不连接 endpoint，不发送 submit / cancel / replace。

GH-1134 后，该 workflow 还必须运行：

```bash
swift run mtpro validate-manual-evidence-bundle "${{ inputs.evidence_bundle_path }}"
```

该命令只读取本地 redacted bundle JSON 内容，并通过 `ReleaseV0161ManualTestnetValidationEvidenceBundle` fail-closed 校验。它不读取 GitHub secrets，不连接 testnet / production endpoint，不发送 testnet 或 production order，不授权 production cutover。

## Evidence

`ReleaseV0160ManualTestnetValidationReport` 只保存 run id、workflow path、required action sequence、evidence entries、checksum references 和 no-production boundary flags。它不得保存 API key、secret、raw order identity、raw broker payload、signed payload、raw response、production endpoint 或 production cutover authorization。

## Validation

Focused verifier：

```bash
bash checks/verify-v0.16.0-manual-testnet-validation-workflow.sh
```

Focused test：

```bash
swift test --filter TargetGraphTests/testGH1111ReleaseV0160ManualTestnetValidationWorkflowRequiresRedactedBundle
```

Full validation：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Boundary

GH-1111 不授权 production cutover，不读取 production secret，不连接 production endpoint / broker endpoint，不提交 production order，不新增 Dashboard trading button、order form 或 live command，不扩大到非 Binance venue，不扩大到 Binance Futures / USDⓈ-M execution。
