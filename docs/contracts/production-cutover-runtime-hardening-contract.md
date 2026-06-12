# Production Cutover Runtime Hardening Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-643 PCHR-01 Define production cutover runtime hardening contract`。

本文档定义 `MTPRO Production Cutover Runtime Hardening v1` 的第一层运行时加固合同。它只固定 release v0.2.0 之后仍然保持的 fail-closed 生产边界，不打开 production trading，不读取 production secret，不连接 production endpoint，不提交真实订单，也不启动下一阶段。

## PCHR-01-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT

`PCHR-01-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT`

GH-643 是 PCHR queue `GH-643..GH-649` 的第一个 gate。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ProductionCutoverRuntimeHardeningContract.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH643ProductionCutoverRuntimeHardeningContractFailsClosedWithoutProductionCutover`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PCHR-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT`

合同固定：

- active venue 只能是 `Binance`
- active product types 只能是 `spot` 和 `usdsPerpetual`
- active strategies 只能是 `EMA` 和 `RSI`
- queue range 固定为 `GH-643..GH-649`
- downstream issue 固定为 `GH-644`
- production capability defaults 必须关闭
- CommandGateway / RiskEngine / ExecutionEngine / OMS / Event Store gate pass 必须全部存在。

## PCHR-01-PRODUCTION-TRADING-DEFAULT-DISABLED

`PCHR-01-PRODUCTION-TRADING-DEFAULT-DISABLED`

Production trading 默认关闭，并且不是可由本地验证、CI、环境变量、隐藏 flag、脚本或 UI shortcut 自动打开的能力。

Required evidence：

- `productionTradingEnabledByDefault == false`
- `realOrderSubmissionEnabled == false`
- `startsNextMilestone == false`

## PCHR-01-REAL-BROKER-PRODUCTION-ENDPOINT-DEFAULT-OFF

`PCHR-01-REAL-BROKER-PRODUCTION-ENDPOINT-DEFAULT-OFF`

Real broker 和 production endpoint 默认关闭。GH-643 不实现 broker adapter，不连接 production REST / WebSocket，不启用真实订单生命周期。

Required evidence：

- `realBrokerEnabledByDefault == false`
- `productionEndpointAutoConnectEnabled == false`
- `realOrderSubmissionEnabled == false`

## PCHR-01-OPERATOR-APPROVAL-AND-GATE-PASS-REQUIRED

`PCHR-01-OPERATOR-APPROVAL-AND-GATE-PASS-REQUIRED`

任何 production-capable path 都必须先满足 operator approval 和全部 gate pass。GH-643 只定义 gate pass requirement，不创建 approval runtime 或 production cutover path。

Required gate pass anchors：

- `PCHR-01-COMMANDGATEWAY-REQUIRED`
- `PCHR-01-RISKENGINE-REQUIRED`
- `PCHR-01-EXECUTIONENGINE-REQUIRED`
- `PCHR-01-OMS-REQUIRED`
- `PCHR-01-EVENT-STORE-REQUIRED`

每个 gate pass 必须满足：

- `requiredBeforeProductionCapablePath == true`
- `bypassAllowed == false`

## PCHR-01-NO-SECRET-AUTO-READ

`PCHR-01-NO-SECRET-AUTO-READ`

GH-643 不读取、探测、打印、保存或推导 production secret。后续任何 secret reference hardening 必须由 GH-644 单独处理，仍不得读取 secret value。

Required evidence：

- `productionSecretAutoReadEnabled == false`
- no API key / secret storage
- no signed request builder
- no account endpoint / listenKey side effect

## PCHR-01-NO-ENDPOINT-AUTO-CONNECT

`PCHR-01-NO-ENDPOINT-AUTO-CONNECT`

GH-643 不连接 production endpoint，也不允许 dry-run、sandbox、Dashboard、CLI 或 hidden flag 自动切换到 production endpoint。

Required evidence：

- `productionEndpointAutoConnectEnabled == false`
- no automatic broker connection
- no production REST / WebSocket connection

## PCHR-01-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-NO-BYPASS

`PCHR-01-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-NO-BYPASS`

任何 production-capable command path 都不得绕过 CommandGateway / RiskEngine / ExecutionEngine / OMS / Event Store。GH-643 不实现该 path，只固定不可绕过的合同。

Required evidence：

- `commandGatewayBypassAllowed == false`
- `riskEngineBypassAllowed == false`
- `executionEngineBypassAllowed == false`
- `omsBypassAllowed == false`
- `eventStoreBypassAllowed == false`

## TVM-PCHR-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT

`TVM-PCHR-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT`

Required validation：

- `swift test --filter TargetGraphTests/testGH643ProductionCutoverRuntimeHardeningContractFailsClosedWithoutProductionCutover`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## PCHR-01 Non-authorization

GH-643 不授权：

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
- Live PRO Console production command。
- trading button / live command / order form。
- 非 Binance venue。
- Spot / USDⓈ-M Perpetual 之外的 product type。
- EMA / RSI 之外的 active strategy。
- 下一阶段 Project / Issue 自动启动。

## PCHR-07-PRODUCTION-HARDENING-READINESS-CLOSEOUT

`PCHR-07-PRODUCTION-HARDENING-READINESS-CLOSEOUT`

GH-649 收口 GH-643 至 GH-648 的 production runtime hardening readiness matrix。收口后，PCHR queue 只能解释为 release v0.2.0 之后的 fail-closed production cutover evidence，不授权 production trading、production secret read、production endpoint connection、real broker、real order 或下一阶段自动启动。

## PCHR-07-ISSUE-PR-EVIDENCE-CHAIN

`PCHR-07-ISSUE-PR-EVIDENCE-CHAIN`

GH-649 的 evidence chain 以 `docs/audit/inputs/mtpro-production-cutover-runtime-hardening-v1-stage-audit-input.md` 为 Stage Code Audit 输入材料，覆盖：

- GH-643 / PR #650 / merge `485a8a93a7de13d98e174345b9eddc53e2eb6c84`;
- GH-644 / PR #651 / merge `d29d557bdda1abbe71338cfe8c4204cb1c63feaa`;
- GH-645 / PR #652 / merge `5a64abfea38b482d8e5da87e83fbee785dd6ef8b`;
- GH-646 / PR #653 / merge `9e250ec3b46feb7074de55f3651e3e5fa3dc817d`;
- GH-647 / PR #654 / merge `eee1f3e18ee545507f4b4d4be1d6fcb19b499e05`;
- GH-648 / PR #655 / merge `d73ab662a2193bdf99944a4cd733519bf1978986`.

## PCHR-07-PRODUCTION-DEFAULTS-REMAIN-CLOSED

`PCHR-07-PRODUCTION-DEFAULTS-REMAIN-CLOSED`

Production defaults remain closed:

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionEndpointConnectionEnabledByDefault == false`
- `productionBrokerConnectionEnabledByDefault == false`
- `productionOrderSubmitEnabledByDefault == false`
- `productionCutoverAuthorized == false`

## PCHR-07-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-GATES-COMPLETE

`PCHR-07-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-GATES-COMPLETE`

The completed gate chain covers credential reference, endpoint connection, CommandGateway / RiskEngine / ExecutionEngine / OMS dispatch, OMS / Event Store audit trail, replay / repair evidence and broker shadow / dry-run proof. This chain remains evidence-only and cannot be treated as production order authorization.

## PCHR-07-AUTOMATION-READINESS-CLOSEOUT

`PCHR-07-AUTOMATION-READINESS-CLOSEOUT`

Automation readiness must mechanically require the GH-649 stage audit input file, the PCHR-07 contract anchors, the final trading validation matrix row and the focused TargetGraph test `testGH649ProductionHardeningReadinessCloseoutDocumentsCompleteEvidenceWithoutCutover`.

## PCHR-07-NO-PRODUCTION-CUTOVER-AUTHORIZATION

`PCHR-07-NO-PRODUCTION-CUTOVER-AUTHORIZATION`

GH-649 does not authorize production trading, production secret read, production endpoint connection, signed endpoint, account endpoint, listenKey, private WebSocket runtime, broker gateway, broker adapter, automatic broker connection, real submit / cancel / replace, production OMS, production Event Store runtime, execution report runtime, broker fill runtime, reconciliation runtime, Live PRO Console command, trading button, live command, order form, non-Binance venue, non-Spot / non-USDⓈ-M product type, non-EMA / non-RSI active strategy, production cutover, next Project / Issue creation or next-stage Todo promotion.

## PCHR-07-STAGE-CODE-AUDIT-HANDOFF

`PCHR-07-STAGE-CODE-AUDIT-HANDOFF`

After GH-649 PR merge, Parent Codex must verify GH-643..GH-649 closed / done, PR #650..#656 merged with `checks` SUCCESS, open PR = 0, open issue = 0 before formal release tagging, no active issue conflict, `main == origin/main`, worktree clean and no next-stage mutation.

## TVM-PCHR-PRODUCTION-HARDENING-READINESS-CLOSEOUT

`TVM-PCHR-PRODUCTION-HARDENING-READINESS-CLOSEOUT`

Required validation：

- `swift test --filter TargetGraphTests/testGH649ProductionHardeningReadinessCloseoutDocumentsCompleteEvidenceWithoutCutover`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
