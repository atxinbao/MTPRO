# Release v0.10.0 Cutover Approval Workflow Contract

日期：2026-06-18

执行者：Codex

## Scope

本合同服务 GH-888 / V0100-011，只定义 production cutover approval workflow 的 reference-only evidence。它允许系统表达 requested、reviewing、approved、rejected、expired、revoked 等审批状态，但这些状态只用于 readiness review 证据，不授权 production cutover，不启用 order submission，不启用 production trading。

## Evidence

- `cutover_approval_workflow.json`
- `workflowChecksum=sha256:7517080ebc392b2a610f4ac56fca227565e810e310529a67af167b819d7c5138`
- `requested`
- `reviewing`
- `approved`
- `rejected`
- `expired`
- `revoked`
- `approvalStateEvidenceCanRepresentApproved=true`
- `approvalStateEvidenceCanRepresentRejected=true`
- `approvedStateIsReviewEvidenceOnly=true`
- `previousProductionReadinessBundleHeld=true`
- `production_cutover_blocked=true`
- `productionCutoverBlocked=true`
- `productionCutoverAuthorized=false`
- `orderSubmissionEnabled=false`
- `productionTradingEnabled=false`
- `no_secret_value=true`
- `noSecretValue=true`
- `no_order_payload=true`
- `noOrderPayload=true`

## Validation Anchors

- `V0100-011-CUTOVER-APPROVAL-WORKFLOW`
- `V0100-011-CUTOVER-APPROVAL-WORKFLOW-JSON`
- `V0100-011-APPROVAL-STATES-REPRESENTED`
- `V0100-011-APPROVED-NOT-CUTOVER-AUTHORIZED`
- `V0100-011-APPROVED-NOT-ORDER-SUBMISSION-ENABLED`
- `V0100-011-APPROVED-NOT-PRODUCTION-TRADING-ENABLED`
- `V0100-011-PRODUCTION-CUTOVER-AUTHORIZED-FALSE`
- `V0100-011-ORDER-SUBMISSION-ENABLED-FALSE`
- `V0100-011-PRODUCTION-TRADING-ENABLED-FALSE`
- `V0100-011-PRODUCTION-CAPABILITIES-DISABLED`
- `GH-888-VERIFY-V0100-CUTOVER-APPROVAL-WORKFLOW`
- `TVM-RELEASE-V0100-CUTOVER-APPROVAL-WORKFLOW`

## Boundary

- `approved` 只代表 approval workflow 的审查状态已记录，不等于 production cutover authorization。
- `approved` 不等于 order submission enablement。
- `approved` 不等于 production trading enablement。
- 不读取 production secret value。
- 不连接 production endpoint。
- 不连接 broker endpoint。
- 不提交、取消或替换 testnet order。
- 不提交、取消或替换 production order。
- 不生成 order payload。
- 不生成 broker command。
- 不启用 production OMS。
- 不显示 trading button。
- 不显示 order form。
- 不启用 live command。
- 不把 readiness approval 转换为 trading permission。
- 不提供 approval workflow bypass。
