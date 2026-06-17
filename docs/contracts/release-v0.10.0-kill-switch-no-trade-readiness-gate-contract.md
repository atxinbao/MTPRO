# Release v0.10.0 Kill Switch / No-trade Readiness Gate Contract

日期：2026-06-18

执行者：Codex

本文档服务 GitHub fallback issue `GH-884 V0100-007 Add kill switch / no-trade readiness gate`。

本文档只定义 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的 kill switch / no-trade readiness / 停止交易与禁交易就绪合同。它只证明生产切换前必须可见、可审计且能阻断 production cutover readiness 的 kill switch state、no-trade state、last operator review、risk approval requirement 和 evidence 文件名。它不连接 production endpoint 或 broker endpoint，不读取 production secret value，不提交、取消或替换 testnet / production order，不启用 production OMS、trading button、order form 或 live command，也不授权 production cutover。

## V0100-007-KILL-SWITCH-NO-TRADE-READINESS-GATE

`V0100-007-KILL-SWITCH-NO-TRADE-READINESS-GATE`

GH-884 的 KillSwitchNoTradeReadinessGate schema 固定为：

- `kill_switch_readiness.json`
- `no_trade_readiness.json`
- `killSwitchState=active`
- `noTradeState=active`
- `lastOperatorReview=manual-operator-review-required-before-production-cutover`
- `riskApprovalRequired=true`
- `cutoverBlockedIfKillSwitchActive=true`
- `cutoverBlockedIfNoTradeActive=true`
- `production_cutover_blocked=true`
- `cutoverAuthorized=false`
- `orderSubmissionEnabled=false`
- `testnetOrderSubmissionEnabled=false`

该 gate 只能作为 readiness evidence 输入，不能被解释为 production cutover approval、broker connection permission 或 trading permission。

## V0100-007-KILL-SWITCH-STATE

`V0100-007-KILL-SWITCH-STATE`

Kill switch state 固定为：

- `killSwitchState=active`

该状态只证明 production cutover readiness 必须被 kill switch 阻断，不启用 runtime stop command、broker command 或 order mutation。

## V0100-007-NO-TRADE-STATE

`V0100-007-NO-TRADE-STATE`

No-trade state 固定为：

- `noTradeState=active`

该状态只证明 production cutover readiness 必须被 no-trade gate 阻断，不授权 submit / cancel / replace。

## V0100-007-LAST-OPERATOR-REVIEW

`V0100-007-LAST-OPERATOR-REVIEW`

Operator review marker 固定为：

- `lastOperatorReview=manual-operator-review-required-before-production-cutover`

该 marker 只要求人工复核存在，不等于人工批准，也不授权 production cutover。

## V0100-007-RISK-APPROVAL-REQUIRED

`V0100-007-RISK-APPROVAL-REQUIRED`

Risk approval requirement 固定为：

- `riskApprovalRequired=true`

该 requirement 只证明 risk approval 仍是后续人工 gate，不会自动开启 production trading。

## V0100-007-CUTOVER-BLOCKED-IF-KILL-SWITCH-ACTIVE

`V0100-007-CUTOVER-BLOCKED-IF-KILL-SWITCH-ACTIVE`

Kill switch active 时必须阻断 production cutover readiness：

- `cutoverBlockedIfKillSwitchActive=true`

## V0100-007-CUTOVER-BLOCKED-IF-NO-TRADE-ACTIVE

`V0100-007-CUTOVER-BLOCKED-IF-NO-TRADE-ACTIVE`

No-trade active 时必须阻断 production cutover readiness：

- `cutoverBlockedIfNoTradeActive=true`

## V0100-007-KILL-SWITCH-READINESS-JSON

`V0100-007-KILL-SWITCH-READINESS-JSON`

GH-884 必须定义 kill switch readiness evidence 文件名：

- `kill_switch_readiness.json`
- `kill_switch_readiness_evidence_exists=true`
- `kill_switch_readiness_contains_broker_or_account_response=false`
- `kill_switch_readiness_produced_by_endpoint_connection=false`

## V0100-007-NO-TRADE-READINESS-JSON

`V0100-007-NO-TRADE-READINESS-JSON`

GH-884 必须定义 no-trade readiness evidence 文件名：

- `no_trade_readiness.json`
- `no_trade_readiness_evidence_exists=true`
- `no_trade_readiness_contains_broker_or_account_response=false`
- `no_trade_readiness_produced_by_endpoint_connection=false`

这些 evidence 不包含 broker response、account response、secret、listenKey、endpoint payload 或 order response。

## V0100-007-PRODUCTION-CUTOVER-BLOCKED

`V0100-007-PRODUCTION-CUTOVER-BLOCKED`

Production cutover 在 GH-884 中固定 blocked：

- `production_cutover_blocked=true`
- `productionCutoverBlocked=true`
- `productionCutoverUnblocked=false`

任何 kill switch / no-trade readiness evidence 都不能转换成 production trading permission。

## V0100-007-PRODUCTION-CAPABILITIES-DISABLED

`V0100-007-PRODUCTION-CAPABILITIES-DISABLED`

Production capability 在 GH-884 中固定 disabled：

- `productionEndpointConnectionEnabled=false`
- `productionBrokerConnectionEnabled=false`
- `productionSecretValueRead=false`
- `productionOMSRuntimeEnabled=false`
- `tradingButtonEnabled=false`
- `orderFormEnabled=false`
- `liveCommandEnabled=false`
- `killSwitchBypassEnabled=false`
- `noTradeBypassEnabled=false`

## V0100-007-VALIDATION-MATRIX

`V0100-007-VALIDATION-MATRIX`

本 issue 的最小验证链为：

- `GH-884-VERIFY-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE`
- `TVM-RELEASE-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE`
- `checks/verify-v0.10.0-kill-switch-no-trade-readiness-gate.sh`
- `testGH884KillSwitchNoTradeReadinessGateBlocksCutoverAndOrders`

Validation 必须证明：

- `kill_switch_readiness.json` 和 `no_trade_readiness.json` evidence 文件名存在；
- `killSwitchState=active`、`noTradeState=active`、`lastOperatorReview` 和 `riskApprovalRequired=true`；
- `cutoverBlockedIfKillSwitchActive=true`、`cutoverBlockedIfNoTradeActive=true` 和 `production_cutover_blocked=true`；
- endpoint connection、broker connection、secret read、cutover、order submission、production OMS 和 UI command 全部保持 false。
