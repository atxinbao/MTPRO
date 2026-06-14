# MTPRO Release v0.6.0 Operator Local Operational Runtime + Testnet Read-only Probe Runbook

日期：2026-06-15

执行者：Codex

## GH-766-RELEASE-V060-OPERATOR-RUNBOOK-FINAL-AUDIT

本文档是 `MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening` 的 operator runbook。它说明如何运行本地 local operational runtime evidence、run journal、artifact checksum、Dashboard / CLI run detail observer、testnet read-only probe 和 no-production guard validation。

本文档不发布 GitHub Release tag，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover，不读取 production secret，不连接 production endpoint 或 broker endpoint，不提交、取消或替换真实订单。

## Release Scope

| 项 | v0.6.0 closure fact |
| --- | --- |
| GitHub milestone | `MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening` |
| GitHub issue range | `GH-755..GH-766` / `V060-001..V060-012` |
| Active venue | Binance only |
| Active product types | Spot + USDⓈ-M Perpetual |
| Active concrete strategies | EMA + RSI |
| Runtime modes | dry-run / testnet-read-only-probe / production-blocked |
| Production default | `productionTradingEnabledByDefault=false` |
| Queue source | GitHub fallback issue queue only |
| Linear / Symphony / Graphify / code-index / Figma | not used |

## V060-12-VALIDATION-SUMMARY

Operator 使用以下命令完成 v0.6.0 本地验证：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.6.0.sh
bash checks/run.sh
```

`bash checks/verify-v0.6.0.sh` 串联 GH-755 至 GH-765 的 focused verification scripts，并核对 final Stage Code Audit、release notes、operator runbook、root docs refresh 和 automation readiness anchors。它不连接真实 Binance production endpoint，不读取 secret，不启动 broker gateway，不提交真实订单。

## V060-12-LOCAL-RUNTIME-EVIDENCE

local operational runtime evidence 必须覆盖：

- GH-756 local run journal writer。
- GH-757 run manifest / artifact checksum validator。
- GH-758 sha256 runtime checksum chain。
- GH-759 DataEngine local dry-run runner。
- GH-760 EMA / RSI strategy runtime runner。
- GH-761 RiskEngine runtime runner。
- GH-762 ExecutionEngine / OMS dry-run runner。
- GH-763 Portfolio journal projection。
- GH-764 Dashboard / CLI run detail observer。

这些 evidence 只能解释为 local-first runtime proof，不是 broker order、production OMS、real fill、real account state 或 production cutover approval。

## V060-12-TESTNET-READONLY-PROBE

testnet read-only probe 来自 GH-765：

```bash
bash checks/verify-v0.6.0-testnet-readonly-probe.sh
swift run mtpro testnet-readonly-probe
```

Operator 必须确认：

- default mode remains production-blocked unless explicitly configured。
- probe requires explicit operator confirmation。
- allowed endpoint is testnet-only。
- production endpoint resolution fails closed。
- signed account read-only snapshot artifact stores only approved credential reference and redacted credential reference。
- private stream / account snapshot evidence remains simulated read-model evidence when websocket is out of scope。
- no-order proof 必须保持 true。

本文档不提供真实 credential secret value，不签名 production 请求，不连接 production endpoint。

## V060-12-RUN-DETAIL-OBSERVER

CLI observer 只能读取 run journal / manifest / projection / risk / OMS dry-run evidence：

```bash
swift run mtpro run-detail-observer status
swift run mtpro run-detail-observer events
swift run mtpro run-detail-observer projection
swift run mtpro run-detail-observer risk
```

Operator 必须确认 observer 输出只表达 read-model evidence，并保留这些边界：

- Dashboard / CLI 只消费 runID-scoped observer surface。
- corrupted / missing manifest state 必须 fail-closed。
- endpoint / secret / production boundary 必须可见。
- trading button、order form、live command 和 production command 必须不存在。
- broker / execution write path 必须不存在。

Dashboard smoke 使用：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

Dashboard smoke 只证明 read-model surface 可构建和可启动，不提供 production command surface。

## V060-12-NO-PRODUCTION-CUTOVER

Operator 必须确认：

- `productionTradingEnabledByDefault=false`
- `productionSecretRead=false`
- `productionEndpointConnected=false`
- `productionBrokerConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`

v0.6.0 是 local operational runtime + testnet read-only probe hardening closure。它不是 production cutover，不是 real broker enablement，不是 production approval。

## Operator Checklist

- [ ] 当前仓库来自最新 `main` 或当前 #766 PR branch。
- [ ] open PR / active issue 状态符合 WIP=1。
- [ ] `git diff --check` 通过。
- [ ] `bash checks/automation-readiness.sh` 通过。
- [ ] `bash checks/verify-v0.6.0.sh` 通过。
- [ ] `swift run mtpro run-detail-observer status` 输出 read-only observer evidence。
- [ ] `swift run mtpro testnet-readonly-probe` 输出 redacted testnet read-only evidence。
- [ ] `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 read-model-only Dashboard smoke。
- [ ] `bash checks/run.sh` 通过。
- [ ] production trading remains disabled by default。
- [ ] 没有 Linear / Symphony / Graphify / code-index / Figma evidence。
- [ ] 没有 `.codex/*`、`.build/*` 或 `graphify-out/*` 提交。

## TVM-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS

该 runbook 只证明 operator 能在本地复现 v0.6.0 local operational runtime evidence、read-only observer evidence、testnet read-only probe evidence 和 production-disabled proof。它不授权 production cutover，不创建下一 Project / Issue，不推进 release v0.6.0 之后的阶段。
