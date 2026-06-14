# MTPRO Release v0.5.0 Operator Guarded Testnet Runtime Foundation Runbook

日期：2026-06-14

执行者：Codex

## GH-739-RELEASE-V050-OPERATOR-RUNBOOK-FINAL-AUDIT

本文档是 `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge` 的 operator runbook。它说明如何运行本地 dry-run、testnet-guarded read-only gate、run journal、Dashboard / CLI run observer、RiskEngine decision、OMS dry-run lifecycle、Portfolio projection 和 CI hardening validation。

本文档不发布 GitHub Release tag，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover，不读取 production secret，不连接 production endpoint 或 broker endpoint，不提交、取消或替换真实订单。

## Release Scope

| 项 | v0.5.0 closure fact |
| --- | --- |
| GitHub milestone | `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge` |
| GitHub issue range | `GH-726..GH-739` / `V050-01..V050-14` |
| Active venue | Binance only |
| Active product types | Spot + USDⓈ-M Perpetual |
| Active concrete strategies | EMA + RSI |
| Runtime modes | dry-run / testnet-guarded / production-blocked |
| Production default | `productionTradingEnabledByDefault=false` |
| Queue source | GitHub fallback issue queue only |
| Linear / Symphony / Graphify / code-index / Figma | not used |

## V050-14-VALIDATION-SUMMARY

Operator 使用以下命令完成 v0.5.0 本地验证：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.5.0.sh
bash checks/run.sh
```

`bash checks/verify-v0.5.0.sh` 串联 GH-726 至 GH-738 的 focused verification scripts，并执行 read-only `mtpro run-observer status` smoke。它不连接真实 Binance endpoint，不读取 secret，不启动 broker gateway，不提交真实订单。

## V050-14-RUN-JOURNAL-OBSERVER

CLI observer 只能读取 run journal / projection / risk / OMS dry-run evidence：

```bash
swift run mtpro run-observer status
swift run mtpro run-observer list
swift run mtpro run-observer events
swift run mtpro run-observer projection
swift run mtpro run-observer risk
```

Operator 必须确认 observer 输出只表达 read-model evidence，并保留这些边界：

- Dashboard / CLI 只消费 runID-scoped observer surface。
- blocked / rejected reasons 必须可见。
- endpoint / secret / production boundary 必须可见。
- trading button、order form、live command 和 production command 必须不存在。
- broker / execution write path 必须不存在。

Dashboard smoke 使用：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

Dashboard smoke 只证明 read-model surface 可构建和可启动，不提供 production command surface。

## V050-14-DRYRUN-FOUNDATION

dry-run foundation 必须覆盖：

- GH-730 typed `RuntimeMessageBus` envelope。
- GH-731 durable local run journal shape。
- GH-732 DataEngine public market input -> typed RuntimeMessageBus -> Cache projection。
- GH-734 RiskEngine runtime runner allow / reject / blocked evidence。
- GH-735 ExecutionEngine / OMS dry-run lifecycle。
- GH-736 Portfolio run journal projection。
- GH-737 Dashboard / CLI run observer。

dry-run evidence 不能解释为 broker order、production OMS、real fill、real account state 或 production cutover approval。

## V050-14-TESTNET-GUARDED-PROOF

testnet-guarded proof 来自 GH-728 / GH-733 的 policy 和 read-only integration gate：

```bash
bash checks/verify-v0.5.0-environment.sh
bash checks/verify-v0.5.0-testnet-readonly.sh
```

Operator 必须确认：

- default mode remains dry-run。
- testnet requires explicit profile and redacted evidence。
- signed account read-only / private stream account snapshot 只作为 read-model source identity。
- no-submit proof 必须为 true。
- production endpoint resolution 必须 fail-closed。
- production secret value read 必须为 false。

本文档不提供真实 testnet credential 使用步骤，不读取 credential secret value，不签名真实请求。

## V050-14-NO-PRODUCTION-CUTOVER

Operator 必须确认：

- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

v0.5.0 是 guarded testnet runtime foundation / deterministic-to-operational bridge closure。它不是 production cutover，不是 real broker enablement，不是 production approval。

## Operator Checklist

- [ ] 当前仓库来自最新 `main` 或当前 #739 PR branch。
- [ ] open PR / active issue 状态符合 WIP=1。
- [ ] `git diff --check` 通过。
- [ ] `bash checks/automation-readiness.sh` 通过。
- [ ] `bash checks/verify-v0.5.0.sh` 通过。
- [ ] `swift run mtpro run-observer status` 输出 read-only observer evidence。
- [ ] `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 read-model-only Dashboard smoke。
- [ ] `bash checks/run.sh` 通过。
- [ ] production trading remains disabled by default。
- [ ] 没有 Linear / Symphony / Graphify / code-index / Figma evidence。
- [ ] 没有 `.codex/*`、`.build/*` 或 `graphify-out/*` 提交。

## TVM-RELEASE-V050-FINAL-AUDIT-RELEASE-DOCS

该 runbook 只证明 operator 能在本地复现 v0.5.0 guarded runtime foundation evidence、read-only observer evidence 和 production-disabled proof。它不授权 production cutover，不创建下一 Project / Issue，不推进 release v0.5.0 之后的阶段。
