# Release v0.10.0 Production Readiness Audit Bundle Contract

日期：2026-06-18  
执行者：Codex

## Scope

本文档定义 GH-887 / V0100-010 的 production readiness audit bundle 合同。

该合同只聚合已完成的 reference-only readiness evidence，不授权 production cutover，不读取 secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order。

## Required Evidence

- `production_readiness_bundle.json`
- `production_environment_profile.json`
- `secret_readiness.json`
- `endpoint_policy_readiness.json`
- `capital_exposure_limits.json`
- `kill_switch_readiness.json`
- `no_trade_readiness.json`
- `dashboard_production_surface_disabled.json`
- `cli_production_surface_disabled.json`
- `shadow_dry_run_parity.json`
- `risk_policy_snapshot.json`
- `portfolio_reconciliation_snapshot.json`

## Acceptance Flags

- `production_readiness_bundle.json`
- `bundleChecksum=sha256:60555a74cbcb67f2e1e785db208e97b96e72b2e0e02f2b60d656fcabbc58d62a`
- `redaction_proof=true`
- `redactionProof=true`
- `no_secret_value=true`
- `noSecretValue=true`
- `no_order_payload=true`
- `noOrderPayload=true`
- `riskPolicySnapshotIncluded=true`
- `portfolioReconciliationSnapshotIncluded=true`
- `production_cutover_blocked=true`
- `productionCutoverBlocked=true`
- `productionCutoverUnblocked=false`
- `cutoverAuthorized=false`
- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionSecretValueRead=false`
- `testnetOrderSubmissionEnabled=false`
- `productionOrderSubmissionEnabled=false`
- `orderPayloadCreated=false`
- `brokerCommandCreated=false`
- `productionOMSRuntimeEnabled=false`
- `tradingButtonVisible=false`
- `orderFormVisible=false`
- `liveCommandEnabled=false`
- `productionCommandEnabled=false`
- `readinessApprovalConvertedToTradingPermission=false`
- `bundleBypassEnabled=false`

## Validation Anchors

- `V0100-010-PRODUCTION-READINESS-AUDIT-BUNDLE`
- `V0100-010-PRODUCTION-READINESS-BUNDLE-JSON`
- `V0100-010-BUNDLE-SHA256-CHECKSUM`
- `V0100-010-ENVIRONMENT-SECRET-ENDPOINT-EVIDENCE`
- `V0100-010-CAPITAL-KILL-SWITCH-NO-TRADE-EVIDENCE`
- `V0100-010-COMMAND-SURFACE-SHADOW-DRY-RUN-EVIDENCE`
- `V0100-010-RISK-POLICY-SNAPSHOT`
- `V0100-010-PORTFOLIO-RECONCILIATION-SNAPSHOT`
- `V0100-010-REDACTION-PROOF-TRUE`
- `V0100-010-NO-SECRET-VALUE-TRUE`
- `V0100-010-NO-ORDER-PAYLOAD-TRUE`
- `V0100-010-PRODUCTION-CAPABILITIES-DISABLED`
- `GH-887-VERIFY-V0100-PRODUCTION-READINESS-BUNDLE`
- `TVM-RELEASE-V0100-PRODUCTION-READINESS-BUNDLE`

## Boundary

- 不授权 production cutover。
- 不读取 production secret 或 secret value。
- 不连接 production endpoint / broker endpoint。
- 不连接 testnet endpoint。
- 不提交、取消或替换 testnet / production order。
- 不生成 order payload。
- 不创建 broker command。
- 不启用 production OMS。
- 不暴露 trading button、order form、live command 或 production command。
- 不把 readiness approval 转换成 trading permission。
- Production trading 继续默认关闭。

## Validation

- `bash checks/verify-v0.10.0-production-readiness-bundle.sh`
- `swift test --filter TargetGraphTests/testGH887ProductionReadinessAuditBundleAggregatesRedactedNoOrderEvidence`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
