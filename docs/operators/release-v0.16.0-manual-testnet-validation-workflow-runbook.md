# Release v0.16.0 Manual Testnet Validation Workflow Runbook

日期：2026-06-25  
执行者：Codex

## Purpose

本文档服务 `#1111 / GH-1111`。它定义 Binance Spot Testnet operator beta 的手动验证顺序和 redacted evidence bundle 要求。它不是 production cutover runbook，也不是 GitHub Actions 自动联网执行器。

## Anchors

- `GH-1111-VERIFY-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW`
- `TVM-RELEASE-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW`
- `V0160-011-MANUAL-WORKFLOW-ONLY`
- `V0160-011-SUBMIT-STATUS-CANCEL-STATUS-SEQUENCE`
- `V0160-011-RECONCILIATION-PASSED`
- `V0160-011-REDACTED-EVIDENCE-BUNDLE`
- `V0160-011-CHECKSUM-REFERENCES`
- `V0160-011-NO-PRODUCTION-CREDENTIALS`
- `V0160-011-NO-PRODUCTION-ENDPOINT`
- `V0160-011-NO-PRODUCTION-CUTOVER`

## Preconditions

- #1110 beta safety guards 已 closed / done。
- operator 明确使用 Binance Spot Testnet credential profile。
- raw API key、secret、signature input、raw broker response 和 raw order identity 不进入仓库、CI、Dashboard 或 PR。
- production trading 默认关闭，production cutover 未授权。

## Manual Testnet Sequence

1. `spot-testnet-submit`：operator 本地执行 submit beta flow，保留 redacted artifact path 和 checksum。
2. `spot-testnet-status-query`：operator 查询 submit 后状态，保留 redacted status artifact path 和 checksum。
3. `spot-testnet-cancel`：operator 执行 cancel beta flow，保留 redacted cancel artifact path 和 checksum。
4. `spot-testnet-status-query`：operator 查询 cancel 后状态，保留 redacted status artifact path 和 checksum。
5. `reconciliation-passed`：operator 运行本地 #1107 OMS observed-status reconciliation，确认 passed 并保留 redacted reconciliation artifact path 和 checksum。

## Redacted Evidence Bundle

bundle 必须只包含：

- run id。
- 上述五步 action sequence。
- 每一步的 redacted artifact path。
- 每一步的 `sha256:` checksum reference。
- reconciliation passed flag。
- production boundary flags：`productionTradingEnabledByDefault=false`、`productionSecretAutoRead=false`、`productionEndpointConnected=false`、`brokerEndpointConnected=false`、`productionOrderSubmitted=false`、`productionCutoverAuthorized=false`。

bundle 不得包含 raw API key、secret、listenKey、signature、raw order id、raw broker payload、production endpoint、broker endpoint 或 production cutover approval。

## GH-1134 Content Validation

`GH-1134-VERIFY-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT`

`TVM-RELEASE-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT`

`V0161-002-BUNDLE-SCHEMA-PARSED`

`V0161-002-ACTION-SEQUENCE-CHECKED`

`V0161-002-CHECKSUM-REFERENCES-CHECKED`

`V0161-002-NO-SECRET-NO-PRODUCTION-MARKERS`

`V0161-002-NO-PRODUCTION-CUTOVER`

v0.16.1 patch 要求 workflow 读取 redacted evidence bundle JSON 内容，而不是只检查 path 字符串。operator 提供的 bundle 必须使用 `mtpro.release.v0.16.1.manual-evidence-bundle-content.v1` schema，并由本地命令验证：

```bash
swift run mtpro validate-manual-evidence-bundle ".local/mtpro/v0.16.0/operator-runs/<run-id>/export/redacted-manual-testnet-validation-bundle.json"
```

该命令确认 bundle schema 已解析、action sequence 已检查、checksum references 已检查、reconciliation 已通过、no-secret / no-production markers 已保持。它不读取 secret，不连接 endpoint，不发送 testnet 或 production order。

## GitHub Manual Workflow

`docs/history/workflows/release-v0.16.0-manual-testnet-validation.yml` 只能通过 `workflow_dispatch` 手动触发。该 workflow 先验证 manual-only 输入，再调用 `swift run mtpro validate-manual-evidence-bundle "${{ inputs.evidence_bundle_path }}"` 读取 redacted evidence bundle JSON 内容；不读取 secrets，不连接 network endpoint，不发送 testnet 或 production order。

## Validation

```bash
bash checks/verify-v0.16.0-manual-testnet-validation-workflow.sh
bash checks/verify-v0.16.1-manual-evidence-bundle-content.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Stop Rules

一旦出现以下任一情况，立即停止：

- evidence bundle path 或内容包含 raw credential / raw secret / raw order identity。
- checksum reference 缺失或不是 `sha256:`。
- submit -> status -> cancel -> status -> reconciliation passed 顺序不完整。
- reconciliation 未 passed。
- workflow 尝试读取 secrets 或连接 production endpoint / broker endpoint。
- operator 要求授权 production cutover、production order 或 production trading。
