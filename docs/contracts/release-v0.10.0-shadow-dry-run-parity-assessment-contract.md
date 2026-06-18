# Release v0.10.0 Shadow Dry-run Parity Assessment Contract

日期：2026-06-18

执行者：Codex

## Scope

`GH-886` / `V0100-009-SHADOW-DRY-RUN-PARITY-ASSESSMENT`

本文档只定义 v0.10.0 production cutover readiness queue 的 near-production readiness shadow dry-run parity assessment reference-only contract。它不启动 runtime，不连接 endpoint / broker，不读取 secret，不创建 broker command，不提交 testnet 或 production order，不授权 production cutover。

## Evidence

- `V0100-009-SHADOW-DRY-RUN-PARITY-ASSESSMENT`
- `V0100-009-SHADOW-DRY-RUN-PARITY-JSON`
- `V0100-009-MARKET-READONLY-OBSERVATION`
- `V0100-009-STRATEGY-INTENT`
- `V0100-009-RISK-DECISION-AUDITED`
- `V0100-009-OMS-DRY-RUN-LIFECYCLE`
- `V0100-009-PORTFOLIO-PROJECTION-AUDITED`
- `V0100-009-RECONCILIATION-TIMELINE-AUDITED`
- `V0100-009-READINESS-DIFF-AUDITED`
- `V0100-009-ORDERS-SUBMITTED-FALSE`
- `V0100-009-BROKER-COMMAND-CREATED-FALSE`
- `V0100-009-PRODUCTION-CAPABILITIES-DISABLED`
- `GH-886-VERIFY-V0100-SHADOW-DRY-RUN-PARITY`
- `TVM-RELEASE-V0100-SHADOW-DRY-RUN-PARITY`

## Required Flags

- `shadow_dry_run_parity.json`
- `marketReadOnlyObservationAudited=true`
- `strategyIntentAudited=true`
- `riskDecisionAudited=true`
- `portfolioProjectionAudited=true`
- `reconciliationTimelineAudited=true`
- `readinessDiffAudited=true`
- `ordersSubmitted=false`
- `brokerCommandCreated=false`
- `production_cutover_blocked=true`
- `productionCutoverBlocked=true`
- `productionCutoverUnblocked=false`
- `cutoverAuthorized=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionSecretValueRead=false`
- `testnetOrderSubmissionEnabled=false`
- `productionOrderSubmissionEnabled=false`
- `productionOMSRuntimeEnabled=false`
- `tradingButtonVisible=false`
- `orderFormVisible=false`
- `liveCommandEnabled=false`
- `productionCommandEnabled=false`
- `shadowDryRunBypassEnabled=false`

## Chain Coverage

`shadow_dry_run_parity.json` 必须覆盖以下 reference-only evidence stages：

1. market/read-only observation
2. strategy intent
3. risk decision
4. OMS dry-run lifecycle
5. portfolio projection
6. reconciliation timeline
7. readiness diff

每个 stage 都必须 `audited=true`，且 `createsOrderPayload=false`、`createsBrokerCommand=false`。

## Boundary

本合同只说明 #886 的 shadow dry-run parity assessment 已经能用本地 reference-only evidence 证明 near-production readiness 链路一致性。该 evidence 不包含 broker / account response，不来自 endpoint connection，不包含 order payload。

禁止能力：

- no production cutover authorization
- no production cutover unblock
- no production secret read
- no production endpoint connection
- no production broker endpoint connection
- no testnet order submission
- no production order submission
- no broker command creation
- no production OMS runtime
- no trading button
- no order form
- no live command
- no production command
- no shadow dry-run bypass

Production trading remains disabled by default。
