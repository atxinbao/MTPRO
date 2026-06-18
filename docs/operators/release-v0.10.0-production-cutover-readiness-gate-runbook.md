# MTPRO Release v0.10.0 Production Cutover Readiness Gate Runbook

日期：2026-06-18

执行者：Codex

## GH-891-RELEASE-V0100-OPERATOR-RUNBOOK-FINAL-AUDIT

`GH-891-VERIFY-V0100-FINAL-AUDIT-DOCS-RUNBOOK`

`GH-891-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK`

`TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK`

`V0100-014-VALIDATION-SUMMARY`

`V0100-014-STAGE-CODE-AUDIT`

`V0100-014-RELEASE-NOTES`

`V0100-014-OPERATOR-RUNBOOK`

`V0100-014-ROOT-DOCS-REFRESH`

`V0100-014-AGGREGATE-VERIFY`

`V0100-014-NO-PRODUCTION-CUTOVER`

本文档是 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 的 final operator runbook。它说明如何复现 production readiness no-authorization contract、environment profile、secret readiness、endpoint policy、capital / exposure limits、kill switch / no-trade、command surface disabled proof、shadow dry-run parity、production readiness bundle、cutover approval workflow、incident / rollback runbook、Dashboard Production Readiness Center 和 production-disabled validation。

本文档不发布 GitHub Release tag，不创建下一 Project / Issue，不推进下一 Todo，不授权 production cutover，不读取 production secret，不连接 production endpoint 或 broker endpoint，不提交、取消或替换 testnet 或 production 订单。

## Release Scope

| 项 | v0.10.0 closure fact |
| --- | --- |
| GitHub issue range | `GH-878..GH-891` / `V0100-001..V0100-014` |
| Active venue | Binance only |
| Active product types | Spot + USDⓈ-M Perpetual |
| Active concrete strategies | EMA + RSI |
| Readiness mode | production-readiness-assessment / production-blocked |
| Production default | `productionTradingEnabledByDefault=false` |
| Queue source | GitHub fallback issue queue only |
| Linear / Symphony / Graphify / code-index / Figma | not used |

## V0100-014-VALIDATION-SUMMARY

Operator 使用以下命令完成 v0.10.0 本地验证：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.10.0.sh
bash checks/run.sh
```

`bash checks/verify-v0.10.0.sh` 串联 GH-878 至 GH-890 的 focused verification scripts，并核对 final Stage Code Audit、release notes、operator runbook、root docs refresh、validation matrix 和 automation readiness anchors。它不连接真实 Binance production endpoint，不读取 secret，不启动 broker gateway，不提交 testnet 或 production 订单。

## V0100-014-READINESS-EVIDENCE

operator readiness evidence 必须覆盖：

- GH-878 production readiness no-authorization contract。
- GH-880 ProductionEnvironmentProfile reference-only policy refs。
- GH-881 SecretProviderReadinessGate redaction evidence。
- GH-882 EndpointPolicyReadinessGate allowlist and no-silent-fallback evidence。
- GH-883 capital / exposure limit readiness evidence。
- GH-884 kill switch / no-trade readiness evidence。
- GH-885 production command surface disabled proof。
- GH-886 shadow dry-run parity assessment。
- GH-887 production readiness audit bundle。
- GH-888 cutover approval workflow evidence。
- GH-889 incident / rollback readiness runbook。
- GH-890 Dashboard Production Readiness Center。

These evidence artifacts can only be interpreted as production cutover readiness posture, not broker order, production OMS, production endpoint connection, real fill, real account mutation or production cutover approval.

## V0100-014-DASHBOARD-READINESS-CENTER

Dashboard readiness center must remain read-model-only:

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

Expected smoke evidence includes:

- `releaseV0100ReadinessCenterCards=10`
- `releaseV0100ReadinessCenterEvidence=bundle+runbook`
- `releaseV0100ReadinessCenterBoundary=confirmed`

Operator 必须确认 Dashboard 不显示这些 control：

- trading button
- order form
- live command
- submit / cancel / replace command
- production command

## V0100-014-NO-PRODUCTION-CUTOVER

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

v0.10.0 是 production cutover readiness closure。它不是 production cutover，不是 real broker enablement，不是 production approval。

## Operator Checklist

- [ ] 当前仓库来自最新 `main` 或当前 #891 PR branch。
- [ ] open PR / active issue 状态符合 WIP=1。
- [ ] `git diff --check` 通过。
- [ ] `bash checks/automation-readiness.sh` 通过。
- [ ] `bash checks/verify-v0.10.0.sh` 通过。
- [ ] Dashboard Production Readiness Center 只显示 readiness evidence。
- [ ] Secret readiness evidence 不包含 secret value。
- [ ] Endpoint policy evidence 不包含 endpoint response。
- [ ] Capital / exposure readiness evidence 不包含 broker or account response。
- [ ] Kill switch / no-trade readiness 仍 blocked cutover。
- [ ] Command surface disabled proof 仍隐藏 trading button、order form 和 live command。
- [ ] Shadow dry-run parity 没有 order payload 或 broker command。
- [ ] Readiness bundle 只包含 redacted local evidence。
- [ ] Cutover approval workflow 的 approved state 仍只是 review evidence。
- [ ] Incident rollback runbook 不触发 broker command。
- [ ] `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 read-model-only Dashboard smoke。
- [ ] `bash checks/run.sh` 通过。
- [ ] production trading remains disabled by default。
- [ ] 没有 Linear / Symphony / Graphify / code-index / Figma evidence。
- [ ] 没有 `.codex/*`、`.build/*` 或 `graphify-out/*` 提交。

## TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK

该 runbook 只证明 operator 能在本地复现 v0.10.0 production cutover readiness evidence、Dashboard readiness center evidence、incident / rollback evidence 和 production-disabled proof。它不授权 production cutover，不创建下一 Project / Issue，不推进 release v0.10.0 之后的阶段。
