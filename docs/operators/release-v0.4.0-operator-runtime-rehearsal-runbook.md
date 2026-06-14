# MTPRO Release v0.4.0 Operator Runtime Rehearsal Runbook

日期：2026-06-13

执行者：Codex

## GH-708-RELEASE-V040-OPERATOR-RUNTIME-REHEARSAL-RUNBOOK

本文是 v0.4.0 operator runtime rehearsal runbook 的压缩版。它只描述 dry-run / shadow / guarded testnet / production-blocked rehearsal 操作证据，不授权 production cutover、production secret read、production endpoint、broker endpoint 或真实订单。

## Release Scope

- Binance-only。
- Spot + USDⓈ-M Perpetual。
- EMA + RSI。
- Unified runtime rehearsal pipeline。
- production trading disabled by default。

## Operator Flow

| Anchor | 操作证据 |
| --- | --- |
| V040-15-START-REHEARSAL | 启动 rehearsal 前确认 mode、venue、product、strategy、production-disabled boundary |
| V040-15-OBSERVE-DASHBOARD-CLI-EVIDENCE | 观察 Dashboard / CLI read-model-only evidence |
| V040-15-SHADOW-REPLAY-FLOW | 执行 shadow replay flow，确认 event / projection / report chain |
| V040-15-GUARDED-TESTNET-PROOF | guarded testnet proof 只证明 testnet / dry-run，不授权 production |
| V040-15-STOP-REHEARSAL | 停止 rehearsal，确认 no command leak |
| V040-15-FAILURE-ROLLBACK-NOTRADE-PROOF | failure / rollback / no-trade proof 必须阻断 command |
| V040-15-PRODUCTION-DISABLED-PROOF | production disabled proof：无 secret、无 production endpoint、无 broker connection、无 real order |

## Operator Checklist

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/verify-v0.4.0.sh`
- `swift run mtpro unified-run-status`
- `swift test --filter TargetGraphTests/testGH706ShadowReplayModeUsesUnifiedRunContextWithoutNetworkBrokerCalls`
- `swift test --filter TargetGraphTests/testGH702BinanceTestnetModeBoundaryRequiresExplicitOperatorConfirmation`
- `DASHBOARD_SMOKE=1 swift run Dashboard`
- `bash checks/run.sh`
- Dashboard / CLI evidence 只读。
- kill switch / no-trade / rollback drill evidence 已记录。

## Required Proof Fields

Observe section anchors:

- mtpro unified-run-status blocked
- issue=GH-705
- validationAnchor=TVM-RELEASE-V040-DASHBOARD-CLI-UNIFIED-RUN-SURFACE
- productTypes=spot,usdsPerpetual
- strategies=EMA,RSI
- adapterEvidenceVisible=true
- portfolioProjectionVisible=true
- blockedStatesExplained=true
- rejectedStatesExplained=true
- dashboardConsumesProjectionByRunID=true
- cliConsumesProjectionByRunID=true
- boundaryHeld=true

Shadow replay proof:

- ReleaseV040ShadowReplayMode
- ReleaseV040RehearsalRunMode.shadow
- networkCallsPerformed=false
- brokerConnectionOpened=false
- testnetConnected=false
- productionEndpointConnected=false
- productionSecretRead=false
- productionOrderSubmitted=false
- shadowSuccessTreatedAsProductionApproval=false

Guarded testnet proof:

- Default mode remains `dry-run`
- explicit `testnet-guarded`
- Operator confirmation evidence is required
- networkCallPerformed=false
- Production fallback is blocked

Production disabled proof:

- productionTradingEnabledByDefault=false
- productionEndpointConnected=false
- productionSecretRead=false
- productionOrderSubmitted=false
- productionCutoverAuthorized=false

## TVM-RELEASE-V040-OPERATOR-RUNTIME-REHEARSAL-RUNBOOK

Trading Validation Matrix anchor：v0.4.0 rehearsal evidence 只证明 unified runtime rehearsal pipeline 可验证，production trading 仍默认关闭。

## GH-708-NON-AUTHORIZATION

本文不授权 production trading、production secret read、production endpoint、production broker endpoint、account endpoint、listenKey、real order lifecycle、automatic rollback command、broker emergency API、Live PRO Console runtime、real trading button、order form、non-Binance venue、non-EMA / non-RSI active strategy、real submit / cancel / replace、production OMS、Live PRO Console production command、trading button 或 live command。
