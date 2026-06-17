# MTPRO Release v0.9.0 Testnet No-order Observability Runbook

日期：2026-06-17

执行者：Codex

## GH-856-RELEASE-V090-OPERATOR-RUNBOOK-FINAL-AUDIT

`GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK`

`GH-856-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK`

`TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK`

`V090-014-VALIDATION-SUMMARY`

`V090-014-STAGE-CODE-AUDIT`

`V090-014-RELEASE-NOTES`

`V090-014-OPERATOR-RUNBOOK`

`V090-014-ROOT-DOCS-REFRESH`

`V090-014-AGGREGATE-VERIFY`

`V090-014-NO-PRODUCTION-CUTOVER`

本文档是 `MTPRO Release v0.9.0 Testnet No-order Observability` 的 operator runbook。它说明如何运行本地 v0.9.0 testnet read-only no-order observability evidence、monitor session store、snapshot freshness monitor、private stream heartbeat monitor、recovery workflow、Dashboard / CLI observer、alert read-model、Portfolio reconciliation timeline、Risk policy application audit、export bundle、validation lanes 和 production-disabled validation。

本文档不发布 GitHub Release tag，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover，不读取 production secret，不连接 production endpoint 或 broker endpoint，不提交、取消或替换 testnet 或 production 订单。

## Release Scope

| 项 | v0.9.0 closure fact |
| --- | --- |
| GitHub issue range | `GH-843..GH-856` / `V090-001..V090-014` |
| Active venue | Binance only |
| Active product types | Spot + USDⓈ-M Perpetual |
| Active concrete strategies | EMA + RSI |
| Runtime modes | testnet-read-only-observe / snapshot-freshness-monitor / private-stream-heartbeat-monitor / reconciliation-review / alert-read-model-only / recovery-observe / production-blocked |
| Production default | `productionTradingEnabledByDefault=false` |
| Queue source | GitHub fallback issue queue only |
| Linear / Symphony / Graphify / code-index / Figma | not used |

## V090-014-VALIDATION-SUMMARY

Operator 使用以下命令完成 v0.9.0 本地验证：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.9.0.sh
bash checks/run.sh
```

`bash checks/verify-v0.9.0.sh` 串联 GH-843 至 GH-855 的 focused verification scripts，并核对 final Stage Code Audit、release notes、operator runbook、root docs refresh、validation matrix 和 automation readiness anchors。它不连接真实 Binance production endpoint，不读取 secret，不启动 broker gateway，不提交 testnet 或 production 订单。

## V090-014-TESTNET-NO-ORDER-OBSERVABILITY

operator observability evidence 必须覆盖：

- GH-843 testnet no-order observability contract。
- GH-845 persistent TestnetReadOnlyMonitorSession。
- GH-846 signed account snapshot freshness monitor。
- GH-847 private stream heartbeat monitor。
- GH-848 monitor recovery workflow。
- GH-849 Dashboard observability timeline。
- GH-850 alert read-model。
- GH-851 Portfolio reconciliation timeline。
- GH-852 Risk policy application audit。
- GH-853 run monitor export bundle。
- GH-855 Dashboard / CLI operator UX。

这些 evidence 只能解释为 testnet read-only no-order observability proof，不是 broker order、production OMS、testnet order routing、real fill、real account mutation 或 production cutover approval。

## V090-014-CLI-OPERATOR-UX

CLI operator UX 只允许本地 no-order monitor evidence：

```bash
swift run mtpro monitor start <runID>
swift run mtpro monitor status <runID>
swift run mtpro monitor stop <runID>
swift run mtpro monitor recover <runID>
swift run mtpro monitor export <runID>
```

Operator 必须确认输出只表达 local monitor evidence，并保留这些边界：

- `ordersSubmitted=false`
- `testnetOrderRoutingAllowed=false`
- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionCutoverAuthorized=false`
- `tradingButtonEnabled=false`
- `orderFormEnabled=false`
- `liveCommandEnabled=false`

Dashboard smoke 使用：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

Dashboard smoke 只证明 read-model surface 可构建和可启动，不提供 production command surface。

## V090-014-VALIDATION-LANES

v0.9.0 validation lanes 必须保持：

- CI lane deterministic、no-secret、no-network、no-order。
- manual operator testnet lane requires explicit operator confirmation。
- manual proof reference remains redacted。
- manual proof cannot satisfy required checks。
- manual proof cannot be replayed by CI。

Manual lane absence must remain a stop condition or documented residual risk, not a fallback to production endpoint or production secret.

## V090-014-NO-PRODUCTION-CUTOVER

Operator 必须确认：

- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`
- `testnetCancelReplaceAllowed=false`

v0.9.0 是 testnet no-order observability closure。它不是 production cutover，不是 real broker enablement，不是 production approval。

## Operator Checklist

- [ ] 当前仓库来自最新 `main` 或当前 #856 PR branch。
- [ ] open PR / active issue 状态符合 WIP=1。
- [ ] `git diff --check` 通过。
- [ ] `bash checks/automation-readiness.sh` 通过。
- [ ] `bash checks/verify-v0.9.0.sh` 通过。
- [ ] `swift run mtpro monitor status <runID>` 输出 read-only monitor evidence。
- [ ] Dashboard observability timeline 不显示 credential value、raw listenKey 或 raw private payload。
- [ ] alert read-model 没有 notification side effect。
- [ ] Portfolio reconciliation timeline 没有 correction command。
- [ ] Risk policy application audit 没有 broker write path。
- [ ] export bundle 只包含 redacted local evidence。
- [ ] `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 read-model-only Dashboard smoke。
- [ ] `bash checks/run.sh` 通过。
- [ ] production trading remains disabled by default。
- [ ] 没有 Linear / Symphony / Graphify / code-index / Figma evidence。
- [ ] 没有 `.codex/*`、`.build/*` 或 `graphify-out/*` 提交。

## TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK

该 runbook 只证明 operator 能在本地复现 v0.9.0 testnet read-only no-order observability evidence、Dashboard / CLI operator UX evidence、validation lanes evidence 和 production-disabled proof。它不授权 production cutover，不创建下一 Project / Issue，不推进 release v0.9.0 之后的阶段。
