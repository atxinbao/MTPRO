# Production Endpoint Connection Gate Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-645 PCHR-03 Harden production endpoint connection gate`。

本文档定义 `MTPRO Production Cutover Runtime Hardening v1` 的 production endpoint connection gate 合同。它只固定 operator approval、endpoint / venue / productType allowlist、connection attempt audit evidence 和 fail-closed / no fallback 规则，不连接 production endpoint，不读取 production secret，不启用真实 broker，不提交真实订单。

## PCHR-03-PRODUCTION-ENDPOINT-CONNECTION-GATE

`PCHR-03-PRODUCTION-ENDPOINT-CONNECTION-GATE`

GH-645 依赖 GH-644 的 credential reference / environment isolation contract。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ProductionEndpointConnectionGate.swift`
- `docs/contracts/production-credential-reference-environment-isolation-contract.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH645ProductionEndpointConnectionGateRequiresApprovalAllowlistAndAudit`

合同固定：

- upstream issue 固定为 `GH-644`
- downstream issue 固定为 `GH-646`
- queue range 固定为 `GH-643..GH-649`
- `upstreamCredentialIsolationContractHeld == true`
- allowed endpoint references 只能是 `binance-production-rest-endpoint-reference` 和 `binance-production-websocket-endpoint-reference`
- allowed venue 只能是 `Binance`
- allowed product types 只能是 `spot` 和 `usdsPerpetual`
- production endpoint 默认不连接，也不会自动连接。

## PCHR-03-OPERATOR-APPROVAL-REQUIRED

`PCHR-03-OPERATOR-APPROVAL-REQUIRED`

任何 production endpoint connection attempt 都必须有显式 operator approval requirement。缺少 approval 时必须记录 audit evidence 并 fail closed，不能 fallback 到另一个 endpoint，也不能 silent continuation。

Required evidence：

- `operatorApprovalRequired == true`
- missing approval attempt outcome 为 `blocked: missing operator approval`
- `operatorApprovalBypass` 是 forbidden capability。

## PCHR-03-ENDPOINT-VENUE-PRODUCT-ALLOWLIST

`PCHR-03-ENDPOINT-VENUE-PRODUCT-ALLOWLIST`

Production endpoint connection gate 必须同时检查 endpoint reference、venue 和 productType allowlist。任一项不在 allowlist 内，attempt 都必须被记录并 fail closed。

Required allowlist：

- endpoint references：`binance-production-rest-endpoint-reference`、`binance-production-websocket-endpoint-reference`
- venue：`Binance`
- product types：`spot`、`usdsPerpetual`

Required evidence：

- endpoint not allowlisted attempt outcome 为 `blocked: endpoint not allowlisted`
- venue not allowlisted attempt outcome 为 `blocked: venue not allowlisted`
- productType not allowlisted attempt outcome 为 `blocked: productType not allowlisted`

## PCHR-03-CONNECTION-ATTEMPT-AUDIT-EVIDENCE

`PCHR-03-CONNECTION-ATTEMPT-AUDIT-EVIDENCE`

每一次 production endpoint connection attempt 都必须生成 audit evidence row。Evidence row 只能记录 identity、reference、allowlist result、operator approval anchor 和 fail-closed outcome，不记录 secret value、signed payload、account payload 或 broker credential。

Required evidence：

- `connectionAttemptAuditRequired == true`
- 每条 `ProductionEndpointConnectionAttemptAuditEvidence` 满足 `connectionAttemptRecorded == true`
- 每条 evidence 都有非空 `attemptID`、`endpointReference`、`venue`、`productType`、`operatorApprovalAnchor` 和 `auditAnchor`。

## PCHR-03-CONNECTION-FAILURE-FAIL-CLOSED

`PCHR-03-CONNECTION-FAILURE-FAIL-CLOSED`

即使 endpoint / venue / productType allowlist 和 operator approval evidence 都存在，只要 connection failure 被观察到，也必须 fail closed。GH-645 不实现连接 runtime，只定义 failure evidence 的 fail-closed 规则。

Required evidence：

- `connectionFailureFailsClosed == true`
- connection failure attempt outcome 为 `blocked: connection failure fail-closed`
- `connectionFailureObserved == true`
- `failureFailsClosed == true`

## PCHR-03-NO-ENDPOINT-FALLBACK-OR-SILENT-CONTINUATION

`PCHR-03-NO-ENDPOINT-FALLBACK-OR-SILENT-CONTINUATION`

连接失败或 allowlist / approval 失败后，系统不能 fallback 到另一个 endpoint，不能继续执行，也不能把失败解释为 testnet、dry-run 或 future production 授权。

Required evidence：

- `noEndpointFallbackRequired == true`
- `noSilentContinuationAfterFailureRequired == true`
- 每条 evidence 都满足 `allowsFallback == false`
- 每条 evidence 都满足 `silentContinuationAllowed == false`

## PCHR-03-NO-PRODUCTION-ENDPOINT-AUTO-CONNECT

`PCHR-03-NO-PRODUCTION-ENDPOINT-AUTO-CONNECT`

GH-645 不连接 production endpoint，不启用真实 broker，不读取 production secret，不提交真实订单。

Required evidence：

- `productionEndpointConnectsByDefault == false`
- `productionEndpointAutoConnectEnabled == false`
- `productionSecretAutoReadEnabled == false`
- `realBrokerConnectionEnabled == false`
- `realOrderSubmissionEnabled == false`
- `commandRiskExecutionOMSBypassAllowed == false`
- `eventStoreBypassAllowed == false`

## TVM-PCHR-PRODUCTION-ENDPOINT-CONNECTION-GATE

`TVM-PCHR-PRODUCTION-ENDPOINT-CONNECTION-GATE`

Required validation：

- `swift test --filter TargetGraphTests/testGH645ProductionEndpointConnectionGateRequiresApprovalAllowlistAndAudit`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## PCHR-03 Non-authorization

GH-645 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- production secret auto-read。
- production endpoint auto-connect。
- broker adapter / real broker connection。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS。
- Event Store bypass。
- CommandGateway / RiskEngine / ExecutionEngine / OMS bypass。
- endpoint fallback。
- silent continuation after failure。
- 非 Binance venue。
- Spot / USDⓈ-M Perpetual 之外的 product type。
- EMA / RSI 之外的 active strategy。
- 下一阶段 Project / Issue 自动启动。
