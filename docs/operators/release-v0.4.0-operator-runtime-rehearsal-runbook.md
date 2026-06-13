# MTPRO Release v0.4.0 Operator Runtime Rehearsal Runbook

日期：2026-06-13

执行者：Codex

## GH-708-RELEASE-V040-OPERATOR-RUNTIME-REHEARSAL-RUNBOOK

本文档是 `MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline` 的 operator runtime rehearsal runbook。它只说明如何启动本地 v0.4.0 validation suite、如何观察 Dashboard / CLI evidence、如何停止本地 rehearsal、如何执行 shadow replay proof、如何确认 guarded testnet 仍是显式门控，以及如何证明 production 没有打开。

本文档不授权 production trading，不读取 production secret，不连接 production endpoint，不连接 production broker endpoint，不发送真实 submit / cancel / replace，不授权 production cutover，不创建下一 Project / Issue，不启动下一 milestone。

## Release Scope

| 项 | v0.4.0 rehearsal fact |
| --- | --- |
| GitHub milestone | `MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline` |
| GitHub issue range | `GH-694..GH-709` / `V040-01..V040-16` |
| Active venue | Binance only |
| Active product types | Spot + USDⓈ-M Perpetual |
| Active concrete strategies | EMA + RSI |
| Rehearsal modes | dry-run / shadow / testnet-guarded / production-blocked |
| Production default | `productionTradingEnabledByDefault=false` |
| Queue source | GitHub fallback issue queue only |
| Linear / Symphony / Graphify / code-index / Figma | not used |

## V040-15-START-REHEARSAL

Operator 只能用本地 deterministic command 启动 v0.4.0 rehearsal validation：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.4.0.sh
```

`bash checks/verify-v0.4.0.sh` 必须执行 GH-694 至 GH-706 的 focused TargetGraph tests，并执行 `swift run mtpro unified-run-status`。该命令不连接真实 Binance endpoint，不读取 secret，不启动 broker gateway，不提交真实订单。

完整 release PR 或 stage gate 还必须运行：

```bash
bash checks/run.sh
```

## V040-15-OBSERVE-DASHBOARD-CLI-EVIDENCE

CLI evidence 使用：

```bash
swift run mtpro unified-run-status
```

Operator 必须观察到以下输出片段：

- `mtpro unified-run-status blocked`
- `issue=GH-705`
- `validationAnchor=TVM-RELEASE-V040-DASHBOARD-CLI-UNIFIED-RUN-SURFACE`
- `productTypes=spot,usdsPerpetual`
- `strategies=EMA,RSI`
- `adapterEvidenceVisible=true`
- `portfolioProjectionVisible=true`
- `blockedStatesExplained=true`
- `rejectedStatesExplained=true`
- `dashboardConsumesProjectionByRunID=true`
- `cliConsumesProjectionByRunID=true`
- `boundaryHeld=true`

Dashboard smoke evidence 使用：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

Dashboard smoke 只用于观察 read-model / rehearsal evidence surface，不提供 trading button、live command、order form、secret editor、broker connection 或 production command。

## V040-15-SHADOW-REPLAY-FLOW

Shadow replay proof 使用本地 deterministic evidence，不连接 live feed、不连接 testnet、不连接 production endpoint：

```bash
swift test --filter TargetGraphTests/testGH706ShadowReplayModeUsesUnifiedRunContextWithoutNetworkBrokerCalls
bash checks/verify-v0.4.0.sh
```

Operator 必须确认：

- `ReleaseV040ShadowReplayMode` 使用 `ReleaseV040RehearsalRunMode.shadow`。
- Shadow replay 读取 historical / deterministic market-event 与 run-event input。
- Shadow replay evidence 与 dry-run 使用同一 step shape 和单一 `runID`。
- `networkCallsPerformed=false`。
- `brokerConnectionOpened=false`。
- `testnetConnected=false`。
- `productionEndpointConnected=false`。
- `productionSecretRead=false`。
- `productionOrderSubmitted=false`。
- `shadowSuccessTreatedAsProductionApproval=false`。

这些 evidence 只表示 shadow replay proof 完成，不表示 production approval、operator approval、broker readiness 或 real order authorization。

## V040-15-GUARDED-TESTNET-PROOF

Guarded testnet proof 只通过 deterministic source / test evidence 表示显式门控，没有真实 network call：

```bash
swift test --filter TargetGraphTests/testGH702BinanceTestnetModeBoundaryRequiresExplicitOperatorConfirmation
bash checks/verify-v0.4.0.sh
```

Operator 必须确认：

- Default mode remains `dry-run`。
- Requested testnet mode must be explicit `testnet-guarded`。
- Operator confirmation evidence is required。
- Testnet endpoint references remain testnet-only references。
- `networkCallPerformed=false`。
- `productionEndpointConnected=false`。
- `productionSecretRead=false`。
- `productionOrderSubmitted=false`。
- Production fallback is blocked。

本文档不提供真实 testnet credential 使用步骤，不读取 credential secret value，不签名真实请求，不把 testnet evidence 解释为 production readiness。

## V040-15-STOP-REHEARSAL

v0.4.0 rehearsal 当前没有持久生产进程；`bash checks/verify-v0.4.0.sh`、`swift run mtpro unified-run-status`、`swift test --filter ...` 和 `DASHBOARD_SMOKE=1 swift run Dashboard` 都应在本地命令结束时自然停止。

如果本地命令卡住或失败，operator 只能停止当前本地命令并保持 no-trade state：

1. 停止当前 shell command。
2. 保留 kill switch / no-trade blocked 状态。
3. 不执行 automatic recovery。
4. 不调用 broker emergency API。
5. 不执行 rollback command。
6. 不触发 submit / cancel / replace。
7. 只在当前 issue / PR scope 内修复 docs、tests、readiness guard 或 deterministic evidence。

## V040-15-FAILURE-ROLLBACK-NOTRADE-PROOF

Failure handling proof 必须来自 `mtpro unified-run-status` 或 `bash checks/verify-v0.4.0.sh`：

- `killSwitch=blocked`
- `noTrade=blocked`
- `blockedStatesExplained=true`
- `rejectedStatesExplained=true`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

Rollback proof 在 v0.4.0 只表示本地 rehearsal command 停止、no-trade 状态保持、production command 未授权。它不是 broker rollback API、production cancel-all、position flatten、real order repair 或 incident cutover。

## V040-15-PRODUCTION-DISABLED-PROOF

Operator 必须用 `swift run mtpro unified-run-status` 或 `bash checks/verify-v0.4.0.sh` 证明 production 没有打开。必须观察到：

- `productionTradingEnabledByDefault=false`
- `productionEndpointConnected=false`
- `productionSecretRead=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
- `boundaryHeld=true`

这些输出只证明 production 默认关闭；它们不代表 production cutover readiness、operator approval、risk approval、broker connectivity 或 real order authorization。

## Operator Checklist

- [ ] 当前仓库来自最新 `main` 或当前 PR branch。
- [ ] open PR / active issue 状态符合 WIP=1。
- [ ] `git diff --check` 通过。
- [ ] `bash checks/automation-readiness.sh` 通过。
- [ ] `bash checks/verify-v0.4.0.sh` 通过。
- [ ] `swift run mtpro unified-run-status` 输出 v0.4.0 read-model-only evidence。
- [ ] `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 read-model-only Dashboard smoke。
- [ ] `bash checks/run.sh` 通过。
- [ ] `productionTradingEnabledByDefault=false`。
- [ ] `productionEndpointConnected=false`。
- [ ] `productionSecretRead=false`。
- [ ] `productionOrderSubmitted=false`。
- [ ] `productionCutoverAuthorized=false`。
- [ ] 没有 Linear / Symphony / Graphify / code-index / Figma evidence。
- [ ] 没有 `.codex/*`、`.build/*` 或 `graphify-out/*` 提交。

## TVM-RELEASE-V040-OPERATOR-RUNTIME-REHEARSAL-RUNBOOK

该 runbook 的 trading validation matrix 只证明 operator 能按本地 deterministic command 启动、观察、停止、replay、audit 并证明 production disabled boundary。它不授权 production cutover，不创建下一 Project / Issue，不推进 release v0.4.0 之后的阶段。

## GH-708-NON-AUTHORIZATION

GH-708 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading、production submit / cancel / replace 或 production broker connection。
- production secret read、secret editor、signature value exposure、account endpoint、listenKey 或 production endpoint。
- 真实 Binance testnet network call、production broker gateway、OMS mutation、real order lifecycle、automatic rollback command 或 broker emergency API。
- 绕过 CommandGateway、RiskEngine、ExecutionEngine、OMS、Event Store、kill switch、operator confirmation、dry-run / testnet gate 或 no-trade state。
- Live PRO Console runtime、real trading button、live command、order form 或 production cutover。
- non-Binance venue、non-Spot / non-USDⓈ-M product、non-EMA / non-RSI active strategy、下一 Project / Issue 或 release v0.4.0 之后的阶段。
