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
