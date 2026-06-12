# Production Command Dispatch Gate Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-646 PCHR-04 Harden CommandGateway to RiskEngine to ExecutionEngine to OMS dispatch gate`。

本文档定义 `MTPRO Production Cutover Runtime Hardening v1` 的 CommandGateway -> RiskEngine -> ExecutionEngine -> OMS command dispatch gate 合同。它只固定 submit / cancel / replace command path 必须经过的 gate evidence，不打开 production trading，不连接 production endpoint，不调用 ExecutionClient，不提交真实订单。

## PCHR-04-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE

`PCHR-04-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE`

GH-646 依赖 GH-645 的 production endpoint connection gate。当前权威 source anchor：

- `Sources/ExecutionEngine/OMSFutureGate/ProductionCommandDispatchGate.swift`
- `docs/contracts/production-endpoint-connection-gate-contract.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH646ProductionCommandDispatchGateRequiresCommandRiskExecutionOMSGates`

合同固定：

- upstream issue 固定为 `GH-645`
- downstream issue 固定为 `GH-647`
- queue range 固定为 `GH-643..GH-649`
- `upstreamEndpointConnectionGateHeld == true`
- 唯一允许进入 gate chain 的 command source 是 `CommandGateway`
- submit / cancel / replace 只形成 deterministic evidence，不调用 ExecutionClient。

## PCHR-04-DASHBOARD-CLI-NO-DIRECT-EXECUTIONCLIENT

`PCHR-04-DASHBOARD-CLI-NO-DIRECT-EXECUTIONCLIENT`

Dashboard 和 CLI 不能直达 ExecutionClient。它们只能通过 CommandGateway 进入后续 gate，任何 direct attempt 都必须被记录并阻断。

Required evidence：

- Dashboard direct attempt outcome 为 `blocked: Dashboard direct ExecutionClient`
- CLI direct attempt outcome 为 `blocked: CLI direct ExecutionClient`
- 所有 evidence row 都满足 `callsExecutionClient == false`

## PCHR-04-COMMANDGATEWAY-OPERATOR-APPROVAL

`PCHR-04-COMMANDGATEWAY-OPERATOR-APPROVAL`

CommandGateway 必须检查 operator approval。缺少 operator approval 时，不得进入 RiskEngine、ExecutionEngine 或 OMS。

Required evidence：

- `commandGatewayOperatorApprovalRequired == true`
- missing approval attempt outcome 为 `blocked: missing operator approval`
- `operatorApprovalBypass` 是 forbidden capability。

## PCHR-04-RISKENGINE-KILL-NOTRADE-LIMITS

`PCHR-04-RISKENGINE-KILL-NOTRADE-LIMITS`

RiskEngine 必须检查 kill switch、no-trade state 和 limit checks。任一 gate 失败，command 必须 fail closed。

Required evidence：

- kill switch attempt outcome 为 `blocked: kill switch active`
- no-trade attempt outcome 为 `blocked: no-trade state active`
- limit attempt outcome 为 `blocked: limit rejected`
- `riskEngineKillSwitchRequired == true`
- `riskEngineNoTradeStateRequired == true`
- `riskEngineLimitChecksRequired == true`

## PCHR-04-EXECUTIONENGINE-RISK-APPROVED-ONLY

`PCHR-04-EXECUTIONENGINE-RISK-APPROVED-ONLY`

ExecutionEngine 只能接受 RiskEngine-approved command。缺少 Risk-approved evidence 时必须阻断，不能直接调用 ExecutionClient。

Required evidence：

- missing risk approval attempt outcome 为 `blocked: ExecutionEngine missing Risk-approved command`
- `executionEngineRiskApprovedOnly == true`
- `ExecutionEngine accepts unapproved command` 是 forbidden capability。

## PCHR-04-OMS-LIFECYCLE-BEFORE-HANDOFF

`PCHR-04-OMS-LIFECYCLE-BEFORE-HANDOFF`

OMS lifecycle recording 必须发生在任何 execution handoff evidence 之前。缺少 OMS lifecycle evidence 时，command 必须被阻断。

Required evidence：

- missing OMS lifecycle attempt outcome 为 `blocked: OMS lifecycle missing`
- gated handoff evidence 必须满足 `omsLifecycleRecorded == true`
- `eventStoreAuditRecorded == true`

## PCHR-04-FAILED-GATE-BLOCKS-COMMAND

`PCHR-04-FAILED-GATE-BLOCKS-COMMAND`

任何 failed gate 都必须阻断 command。唯一非 blocked evidence 是 `recorded: gated handoff evidence`，它也不调用 ExecutionClient，不提交真实订单。

Required evidence：

- `failedGateBlocksCommand == true`
- failed outcome rows 都满足 `commandBlocked == true`
- `recordedGatedHandoff` row 满足所有 gate pass，但 `callsExecutionClient == false`

## PCHR-04-NO-PRODUCTION-ORDER-AUTHORIZATION

`PCHR-04-NO-PRODUCTION-ORDER-AUTHORIZATION`

GH-646 不授权真实订单能力，不读取 secret，不连接 production endpoint，不连接 broker gateway。

Required evidence：

- `productionEndpointAutoConnectEnabled == false`
- `productionSecretAutoReadEnabled == false`
- `realBrokerConnectionEnabled == false`
- `realOrderSubmissionEnabled == false`
- 每条 evidence 都满足 `submitsRealOrder == false`
- 每条 evidence 都满足 `cancelsRealOrder == false`
- 每条 evidence 都满足 `replacesRealOrder == false`

## TVM-PCHR-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE

`TVM-PCHR-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE`

Required validation：

- `swift test --filter TargetGraphTests/testGH646ProductionCommandDispatchGateRequiresCommandRiskExecutionOMSGates`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## PCHR-04 Non-authorization

GH-646 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- production secret auto-read。
- production endpoint auto-connect。
- Dashboard / CLI direct ExecutionClient。
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
