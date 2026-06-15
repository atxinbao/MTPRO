# MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring Runbook

日期：2026-06-15

执行者：Codex

## GH-820-RELEASE-V080-OPERATOR-RUNBOOK-FINAL-AUDIT

本文档是 `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring` 的 operator runbook。它说明如何运行本地 persistent no-order operator runtime evidence、RunRegistryStore、OperationalRunSessionStore、EventLogWriter recovery、Dashboard / CLI read-only operations、manual testnet signed account proof、manual private stream monitoring proof、Risk policy profile、Portfolio reconciliation review、validation lanes 和 production-disabled validation。

本文档不发布 GitHub Release tag，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover，不读取 production secret，不连接 production endpoint 或 broker endpoint，不提交、取消或替换 testnet 或 production 订单。

## Release Scope

| 项 | v0.8.0 closure fact |
| --- | --- |
| GitHub milestone | `MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring` |
| GitHub issue range | `GH-807..GH-820` / `V080-001..V080-014` |
| Active venue | Binance only |
| Active product types | Spot + USDⓈ-M Perpetual |
| Active concrete strategies | EMA + RSI |
| Runtime modes | local-dry-run / testnet-read-only-monitor / recovery-observe / production-blocked |
| Production default | `productionTradingEnabledByDefault=false` |
| Queue source | GitHub fallback issue queue only |
| Linear / Symphony / Graphify / code-index / Figma | not used |

## V080-014-VALIDATION-SUMMARY

Operator 使用以下命令完成 v0.8.0 本地验证：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.8.0.sh
bash checks/run.sh
```

`bash checks/verify-v0.8.0.sh` 串联 GH-807 至 GH-819 的 focused verification scripts，并核对 final Stage Code Audit、release notes、operator runbook、root docs refresh、validation matrix 和 automation readiness anchors。它不连接真实 Binance production endpoint，不读取 secret，不启动 broker gateway，不提交 testnet 或 production 订单。

## V080-014-PERSISTENT-OPERATOR-RUNTIME-EVIDENCE

operator runtime evidence 必须覆盖：

- GH-807 persistent no-order operator runtime contract。
- GH-809 persistent RunRegistryStore。
- GH-810 top-level CLI local session actions。
- GH-811 OperationalRunSessionStore。
- GH-812 EventLogWriter crash recovery。
- GH-818 Dashboard safe local controls。

这些 evidence 只能解释为 local-first no-order persistent operator runtime proof，不是 broker order、production OMS、testnet order routing、real fill、real account state 或 production cutover approval。

## V080-014-TESTNET-READONLY-MONITORING

testnet read-only monitoring 来自 GH-813、GH-814、GH-815 和 GH-819：

```bash
bash checks/verify-v0.8.0-manual-testnet-signed-account-proof.sh
bash checks/verify-v0.8.0-manual-testnet-private-stream-monitoring.sh
bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh
bash checks/verify-v0.8.0-validation-lanes.sh
```

Operator 必须确认：

- CI lane remains deterministic、no-secret、no-network。
- manual operator network proof lane requires explicit operator confirmation。
- credential references are redacted and never store secret values。
- signed account proof is read-only snapshot evidence only。
- private stream proof observes listenKey lifecycle open / observe / close only。
- Dashboard shows redacted freshness / lifecycle / stale / disconnected / recovered state only。
- no order endpoint, executionReport command path or broker write path is enabled。

本文档不提供真实 credential secret value，不签名 production 请求，不连接 production endpoint。

## V080-014-DASHBOARD-CLI-OBSERVER

CLI / Dashboard observer 只能读取 runtime session、registry、journal、testnet read-only proof status、risk policy profile、Portfolio reconciliation review 和 local safe controls evidence：

```bash
swift run mtpro run --mode dry-run
swift run mtpro status
swift run mtpro stop <runID>
swift run mtpro recover <runID>
```

Operator 必须确认 observer 输出只表达 read-model evidence，并保留这些边界：

- Dashboard / CLI 只消费 runID-scoped observer surface。
- missing / corrupted registry、session or journal state 必须 fail-closed。
- endpoint / secret / production boundary 必须可见。
- start / stop / recover / archive / open-detail 是 safe local run controls，不是 order command、live command 或 production command。
- trading button、order form、live command 和 production command 必须不存在。
- broker / execution write path 必须不存在。

Dashboard smoke 使用：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

Dashboard smoke 只证明 read-model surface 可构建和可启动，不提供 production command surface。

## V080-014-NO-PRODUCTION-CUTOVER

Operator 必须确认：

- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
- `testnetOrderSubmissionAllowed=false`
- `testnetOrderRoutingAllowed=false`

v0.8.0 是 persistent operator runtime + testnet read-only monitoring closure。它不是 production cutover，不是 real broker enablement，不是 production approval。

## Operator Checklist

- [ ] 当前仓库来自最新 `main` 或当前 #820 PR branch。
- [ ] open PR / active issue 状态符合 WIP=1。
- [ ] `git diff --check` 通过。
- [ ] `bash checks/automation-readiness.sh` 通过。
- [ ] `bash checks/verify-v0.8.0.sh` 通过。
- [ ] `swift run mtpro status` 输出 read-only persistent runtime session evidence。
- [ ] manual testnet signed account proof 输出 redacted read-only evidence。
- [ ] manual testnet private stream proof 输出 redacted listenKey lifecycle evidence。
- [ ] Dashboard testnet read-only monitor 不显示 credential value、raw listenKey 或 raw private payload。
- [ ] `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 read-model-only Dashboard smoke。
- [ ] `bash checks/run.sh` 通过。
- [ ] production trading remains disabled by default。
- [ ] 没有 Linear / Symphony / Graphify / code-index / Figma evidence。
- [ ] 没有 `.codex/*`、`.build/*` 或 `graphify-out/*` 提交。

## TVM-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK

该 runbook 只证明 operator 能在本地复现 v0.8.0 persistent no-order runtime evidence、read-only observer evidence、manual Binance testnet read-only monitoring evidence、Portfolio explain-only reconciliation review evidence、validation lanes evidence 和 production-disabled proof。它不授权 production cutover，不创建下一 Project / Issue，不推进 release v0.8.0 之后的阶段。
