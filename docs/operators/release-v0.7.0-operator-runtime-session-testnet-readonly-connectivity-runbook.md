# MTPRO Release v0.7.0 Operator Runtime Session + Testnet Read-only Connectivity Runbook

日期：2026-06-15

执行者：Codex

## GH-792-RELEASE-V070-OPERATOR-RUNBOOK-FINAL-AUDIT

本文档是 `MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity` 的 operator runbook。它说明如何运行本地 no-order runtime session evidence、run registry / supervisor、event log recovery、Dashboard / CLI read-only operations、testnet signed account read-only probe、testnet private stream read-only probe、Portfolio read-only reconciliation 和 production-disabled validation。

本文档不发布 GitHub Release tag，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover，不读取 production secret，不连接 production endpoint 或 broker endpoint，不提交、取消或替换真实订单。

## Release Scope

| 项 | v0.7.0 closure fact |
| --- | --- |
| GitHub milestone | `MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity` |
| GitHub issue range | `GH-779..GH-792` / `V070-001..V070-014` |
| Active venue | Binance only |
| Active product types | Spot + USDⓈ-M Perpetual |
| Active concrete strategies | EMA + RSI |
| Runtime modes | local-dry-run / testnet-read-only-probe / recovery-observe / production-blocked |
| Production default | `productionTradingEnabledByDefault=false` |
| Queue source | GitHub fallback issue queue only |
| Linear / Symphony / Graphify / code-index / Figma | not used |

## V070-014-VALIDATION-SUMMARY

Operator 使用以下命令完成 v0.7.0 本地验证：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.7.0.sh
bash checks/run.sh
```

`bash checks/verify-v0.7.0.sh` 串联 GH-779 至 GH-791 的 focused verification scripts，并核对 final Stage Code Audit、release notes、operator runbook、root docs refresh 和 automation readiness anchors。它不连接真实 Binance production endpoint，不读取 secret，不启动 broker gateway，不提交真实订单。

## V070-014-LOCAL-RUNTIME-SESSION-EVIDENCE

operator runtime session evidence 必须覆盖：

- GH-779 no-order runtime session contract。
- GH-781 top-level CLI run / status / verify。
- GH-783 OperationalRunSession lifecycle。
- GH-784 EventLogWriter runtime append / recovery。
- GH-785 RunRegistry / RunSupervisor。
- GH-788 Dashboard read-only run operations。
- GH-789 local Risk policy config。
- GH-790 Portfolio read-only reconciliation projection。

这些 evidence 只能解释为 local-first no-order runtime session proof，不是 broker order、production OMS、real fill、real account state 或 production cutover approval。

## V070-014-TESTNET-READONLY-CONNECTIVITY

testnet read-only connectivity 来自 GH-780、GH-786 和 GH-787：

```bash
bash checks/verify-v0.7.0-testnet-endpoint-policy.sh
bash checks/verify-v0.7.0-testnet-signed-account-readonly-probe.sh
bash checks/verify-v0.7.0-testnet-private-stream-readonly-probe.sh
```

Operator 必须确认：

- default mode remains production-blocked unless explicitly configured。
- probes require explicit operator confirmation。
- allowed endpoint is canonical testnet-only。
- production endpoint resolution fails closed。
- signed account read-only snapshot artifact stores only approved credential reference and redacted credential reference。
- private stream probe observes listenKey open / observe / close lifecycle only。
- executionReport command path remains rejected。
- no-order proof 必须保持 true。

本文档不提供真实 credential secret value，不签名 production 请求，不连接 production endpoint。

## V070-014-DASHBOARD-CLI-OBSERVER

CLI / Dashboard observer 只能读取 runtime session、registry、journal、probe status、risk policy 和 read-only reconciliation evidence：

```bash
swift run mtpro run --mode dry-run
swift run mtpro status
swift run mtpro verify
```

Operator 必须确认 observer 输出只表达 read-model evidence，并保留这些边界：

- Dashboard / CLI 只消费 runID-scoped observer surface。
- missing / corrupted registry or journal state 必须 fail-closed。
- endpoint / secret / production boundary 必须可见。
- start / stop / recover 是 safe local run controls，不是 order command、live command 或 production command。
- trading button、order form、live command 和 production command 必须不存在。
- broker / execution write path 必须不存在。

Dashboard smoke 使用：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

Dashboard smoke 只证明 read-model surface 可构建和可启动，不提供 production command surface。

## V070-014-NO-PRODUCTION-CUTOVER

Operator 必须确认：

- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
- `testnetOrderSubmissionAllowed=false`

v0.7.0 是 operator runtime session + real testnet read-only connectivity closure。它不是 production cutover，不是 real broker enablement，不是 production approval。

## Operator Checklist

- [ ] 当前仓库来自最新 `main` 或当前 #792 PR branch。
- [ ] open PR / active issue 状态符合 WIP=1。
- [ ] `git diff --check` 通过。
- [ ] `bash checks/automation-readiness.sh` 通过。
- [ ] `bash checks/verify-v0.7.0.sh` 通过。
- [ ] `swift run mtpro status` 输出 read-only runtime session evidence。
- [ ] testnet signed account read-only probe 输出 redacted read-only evidence。
- [ ] testnet private stream read-only probe 输出 redacted listenKey lifecycle evidence。
- [ ] `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 read-model-only Dashboard smoke。
- [ ] `bash checks/run.sh` 通过。
- [ ] production trading remains disabled by default。
- [ ] 没有 Linear / Symphony / Graphify / code-index / Figma evidence。
- [ ] 没有 `.codex/*`、`.build/*` 或 `graphify-out/*` 提交。

## TVM-RELEASE-V070-FINAL-AUDIT-DOCS-RUNBOOK

该 runbook 只证明 operator 能在本地复现 v0.7.0 no-order runtime session evidence、read-only observer evidence、real Binance testnet read-only connectivity evidence、Portfolio explain-only reconciliation evidence 和 production-disabled proof。它不授权 production cutover，不创建下一 Project / Issue，不推进 release v0.7.0 之后的阶段。
