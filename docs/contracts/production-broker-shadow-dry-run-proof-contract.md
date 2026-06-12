# Production Broker Shadow / Dry-Run Proof Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-648 PCHR-06 Harden broker adapter shadow / dry-run production cutover proof`。

本文档定义 `MTPRO Production Cutover Runtime Hardening v1` 的 broker adapter shadow / dry-run production cutover proof 合同。它只生成 production-like request mapping evidence，不连接 broker，不读取 secret，不发送真实订单，不向 Dashboard 暴露 raw broker payload。

## PCHR-06-BROKER-SHADOW-DRY-RUN-PRODUCTION-CUTOVER-PROOF

`PCHR-06-BROKER-SHADOW-DRY-RUN-PRODUCTION-CUTOVER-PROOF`

GH-648 依赖 GH-647 的 production audit trail gate。当前权威 source anchor：

- `Sources/ExecutionEngine/OMSFutureGate/ProductionBrokerShadowDryRunProof.swift`
- `docs/contracts/production-audit-trail-gate-contract.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH648BrokerShadowDryRunProofKeepsProductionOrdersBlocked`

合同固定：

- upstream issue 固定为 `GH-647`
- downstream issue 固定为 `GH-649`
- queue range 固定为 `GH-643..GH-649`
- `upstreamAuditTrailGateHeld == true`
- submit / cancel / replace 都有 auditable payload construction evidence。

## PCHR-06-PRODUCTION-LIKE-REQUEST-MAPPING-EVIDENCE

`PCHR-06-PRODUCTION-LIKE-REQUEST-MAPPING-EVIDENCE`

Production-like request mapping evidence 只描述 payload shape / identity，不是 signed request，不是 broker payload，不是真实订单。

Required evidence：

- `productionLikeRequestMappingRequired == true`
- 每条 payload evidence 满足 `productionLikeRequestMappingPresent == true`
- 每条 payload evidence 满足 `upstreamAuditTrailLinked == true`

## PCHR-06-NO-REAL-ORDER-SENT

`PCHR-06-NO-REAL-ORDER-SENT`

GH-648 不发送真实订单，不连接真实 broker。

Required evidence：

- `realOrderSubmissionEnabled == false`
- 每条 payload evidence 满足 `sendsRealOrder == false`
- 每条 payload evidence 满足 `connectsBroker == false`

## PCHR-06-DRY-RUN-SHADOW-MODE-MARKED

`PCHR-06-DRY-RUN-SHADOW-MODE-MARKED`

Dry-run、shadow 和 production blocked mode 必须显式标记，不能把 dry-run / shadow 解释成 production order authorization。

Required evidence：

- `dryRunAndShadowModeMarked == true`
- payload mode 覆盖 `dry-run`、`shadow` 和 `production blocked`
- 每条 payload evidence 满足 `modeExplicitlyMarked == true`

## PCHR-06-SUBMIT-CANCEL-REPLACE-PAYLOAD-AUDIT

`PCHR-06-SUBMIT-CANCEL-REPLACE-PAYLOAD-AUDIT`

Submit、cancel、replace payload construction 必须可审计。

Required evidence：

- `submitCancelReplacePayloadAuditRequired == true`
- command kind 覆盖 submit / cancel / replace
- 每条 payload evidence 满足 `payloadConstructionAuditable == true`

## PCHR-06-PRODUCTION-ORDER-PATH-BLOCKED-BY-DEFAULT

`PCHR-06-PRODUCTION-ORDER-PATH-BLOCKED-BY-DEFAULT`

Production order path 默认保持 blocked，不能由 shadow / dry-run proof 自动打开。

Required evidence：

- `productionOrderPathBlockedByDefault == true`
- 每条 payload evidence 满足 `productionOrderPathBlocked == true`
- `productionEndpointAutoConnectEnabled == false`
- `productionSecretAutoReadEnabled == false`

## PCHR-06-NO-RAW-BROKER-PAYLOAD-DASHBOARD

`PCHR-06-NO-RAW-BROKER-PAYLOAD-DASHBOARD`

Dashboard 只能消费 read-model / mapped evidence，不能暴露 raw broker payload。

Required evidence：

- `rawBrokerPayloadNotExposedToDashboard == true`
- 每条 payload evidence 满足 `exposesRawBrokerPayloadToDashboard == false`

## TVM-PCHR-BROKER-SHADOW-DRY-RUN-PROOF

`TVM-PCHR-BROKER-SHADOW-DRY-RUN-PROOF`

Required validation：

- `swift test --filter TargetGraphTests/testGH648BrokerShadowDryRunProofKeepsProductionOrdersBlocked`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## PCHR-06 Non-authorization

GH-648 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- production secret auto-read。
- production endpoint auto-connect。
- real broker connection。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS runtime。
- production Event Store runtime。
- raw broker payload exposed to Dashboard。
- 下一阶段 Project / Issue 自动启动。
