# MTPRO Release v0.3.0 Operator Rehearsal Runbook

日期：2026-06-13

执行者：Codex

## GH-669-RELEASE-V030-OPERATOR-REHEARSAL-RUNBOOK

本文档是 `MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal` 的 operator rehearsal runbook。它只说明如何启动本地 rehearsal validation、如何观察 Dashboard / CLI evidence、如何停止本地 rehearsal、如何证明 production 没有打开。

本文档不授权 production trading，不读取 production secret，不连接 production endpoint，不连接 production broker endpoint，不发送真实 submit / cancel / replace，不授权 production cutover，不创建下一 Project / Issue，不启动下一 milestone。

## GH-687-RELEASE-V031-REHEARSAL-EVIDENCE-DOCS-HANDOFF

v0.3.x 的 release 语义必须按以下口径理解：

- v0.3.0 是 deterministic rehearsal evidence release：它证明本地 evidence chain、dry-run / testnet / shadow / production-blocked taxonomy、Dashboard / CLI rehearsal surface、kill switch / no-trade / rollback drill 和 `checks/verify-v0.3.0.sh` validation suite 已闭环。
- v0.3.1 是 rehearsal evidence hardening patch：它只补强 v0.3.0 evidence 边界、testnet URL policy、文档语义和 patch release closeout，不新增 runtime pipeline、network connector、product type、strategy 或 production cutover。
- v0.3.x 不是 real testnet / shadow runtime runner：本文档中的 `testnet` / `shadow` 表示 deterministic rehearsal mode 和 mapping proof，不表示真实 Binance testnet network loop、shadow production feed、broker connection、secret read、live private stream、real submit / cancel / replace 或 production endpoint。
- v0.4.0 只是 planned unified runtime rehearsal pipeline stage 的 handoff 语义；必须等待 Human + `@001 / PLN` 重新规划和新的 live queue source，不由 v0.3.x 文档自动创建 Project / Issue、推进 Todo 或授权 execution。

## Release Scope

| 项 | v0.3.0 rehearsal fact |
| --- | --- |
| GitHub milestone | `MTPRO Release v0.3.0 Testnet / Shadow Production Rehearsal` |
| GitHub issue range | `GH-657..GH-670` / `V030-01..V030-14` |
| Active venue | Binance only |
| Active product types | Spot + USDⓈ-M Perpetual |
| Active concrete strategies | EMA + RSI |
| Rehearsal modes | dry-run / testnet / shadow / production-blocked |
| Production default | `productionTradingEnabledByDefault=false` |
| Queue source | GitHub fallback issue queue only |
| Linear / Symphony / Graphify / code-index / Figma | not used |

## V030-13-START-REHEARSAL

Operator 只能用本地 deterministic command 启动 rehearsal validation：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.3.0.sh
```

`bash checks/verify-v0.3.0.sh` 必须执行 GH-657 至 GH-667 的 focused TargetGraph tests，并执行 `swift run mtpro rehearsal-status`。该命令不连接真实 Binance endpoint，不读取 secret，不启动 broker gateway，不提交真实订单。

完整 release PR 或 stage gate 还必须运行：

```bash
bash checks/run.sh
```

## V030-13-OBSERVE-DASHBOARD-CLI-EVIDENCE

CLI evidence 使用：

```bash
swift run mtpro rehearsal-status
```

Operator 必须观察到以下输出片段：

- `mtpro rehearsal-status blocked`
- `commandGateway=required`
- `validationAnchor=TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE`
- `productTypes=spot,usdsPerpetual`
- `strategies=ema,rsi`
- `killSwitchStatus=blocked`
- `noTradeStatus=blocked`
- `commandsRouteThroughCommandGateway=true`
- `boundaryHeld=true`

Dashboard smoke evidence 使用：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

Dashboard smoke 只用于观察 read-model / rehearsal evidence surface，不提供 trading button、live command、order form、secret editor、broker connection 或 production command。

## V030-13-STOP-REHEARSAL

v0.3.0 rehearsal 当前没有持久生产进程；`bash checks/verify-v0.3.0.sh`、`swift run mtpro rehearsal-status` 和 `DASHBOARD_SMOKE=1 swift run Dashboard` 都应在本地命令结束时自然停止。

如果本地命令卡住或失败，operator 只能停止当前本地命令并保持 no-trade state：

1. 停止当前 shell command。
2. 保留 kill switch / no-trade blocked 状态。
3. 不执行 automatic recovery。
4. 不调用 broker emergency API。
5. 不执行 rollback command。
6. 不触发 submit / cancel / replace。
7. 只在当前 issue / PR scope 内修复 docs、tests、readiness guard 或 deterministic evidence。

## V030-13-PRODUCTION-DISABLED-PROOF

Operator 必须用 `swift run mtpro rehearsal-status` 或 `bash checks/verify-v0.3.0.sh` 证明 production 没有打开。必须观察到：

- `productionTradingEnabledByDefault=false`
- `productionEndpointAutoConnect=false`
- `productionSecretAutoRead=false`
- `productionOrderSubmission=false`
- `productionCutoverAuthorized=false`

这些输出只证明 production 默认关闭；它们不代表 production cutover readiness、operator approval、risk approval、broker connectivity 或 real order authorization。

## Operator Checklist

- [ ] 当前仓库来自最新 `main` 或当前 PR branch。
- [ ] open PR / active issue 状态符合 WIP=1。
- [ ] `git diff --check` 通过。
- [ ] `bash checks/automation-readiness.sh` 通过。
- [ ] `bash checks/verify-v0.3.0.sh` 通过。
- [ ] `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 read-model-only Dashboard smoke。
- [ ] `bash checks/run.sh` 通过。
- [ ] `productionTradingEnabledByDefault=false`。
- [ ] `productionEndpointAutoConnect=false`。
- [ ] `productionSecretAutoRead=false`。
- [ ] `productionOrderSubmission=false`。
- [ ] `productionCutoverAuthorized=false`。
- [ ] 没有 Linear / Symphony / Graphify / code-index / Figma evidence。
- [ ] 没有 `.codex/*`、`.build/*` 或 `graphify-out/*` 提交。

## TVM-RELEASE-V030-OPERATOR-REHEARSAL-RUNBOOK

该 runbook 的 trading validation matrix 只证明 operator 能按本地 deterministic command 启动、观察、停止和证明 production disabled boundary。它不授权 production cutover，不创建下一 Project / Issue，不推进 release v0.3.0 之后的阶段。

## GH-669-NON-AUTHORIZATION

GH-669 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading、production submit / cancel / replace 或 production broker connection。
- production secret read、secret editor、signature value exposure、account endpoint、listenKey 或 production endpoint。
- 真实 Binance testnet network call、production broker gateway、OMS mutation、real order lifecycle、automatic rollback command 或 broker emergency API。
- 绕过 CommandGateway、RiskEngine、ExecutionEngine、OMS、Event Store、kill switch、operator confirmation、dry-run / testnet gate 或 no-trade state。
- Live PRO Console runtime、real trading button、live command、order form 或 production cutover。
- non-Binance venue、non-Spot / non-USDⓈ-M product、non-EMA / non-RSI active strategy、下一 Project / Issue 或 release v0.3.0 之后的阶段。
