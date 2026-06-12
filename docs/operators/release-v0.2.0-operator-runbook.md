# MTPRO Release v0.2.0 Operator Runbook

日期：2026-06-12

执行者：Codex

## GH-596-RELEASE-V020-OPERATOR-RUNBOOK

本文档是 `MTPRO Release v0.2.0` 的 operator runbook。它只说明 Binance Spot + Binance USDⓈ-M Perpetual + EMA/RSI release closure 后如何本地验证、如何读取证据、如何保持 no-default-production-trading 边界。

本文档不授权 production trading，不读取 production secret，不连接 production endpoint，不连接 production broker endpoint，不自动连接 broker，不执行真实 submit / cancel / replace，不创建下一 Project / Issue，不推进 release v0.2.0 之后的阶段。

## Release Scope

| 项 | v0.2.0 closure fact |
| --- | --- |
| GitHub milestone | `MTPRO Release v0.2.0` |
| GitHub issue range | `GH-563..GH-596` / `V020-01..V020-34` |
| Active venue | Binance only |
| Active product types | Spot + USDⓈ-M Perpetual |
| Active concrete strategies | EMA + RSI |
| Production default | `productionTradingEnabledByDefault == false` |
| Queue source | GitHub fallback issue queue only |
| Linear / Symphony / Graphify / Figma | not used |

## Local Acceptance Commands

Operator 接手 release v0.2.0 evidence 时，使用以下本地命令作为最小验收入口：

```bash
swift run mtpro verify-fast
swift run mtpro verify-release
DASHBOARD_SMOKE=1 swift run Dashboard
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

`swift run mtpro verify-fast` 必须输出：

- `verificationIssue=GH-595`
- `verifyCoverage=foundation,sample-traces`
- `verifyTraceCount=6`
- `verifyCatalogTraceCount=15`
- `verifyGateBoundaryHeld=true`

`swift run mtpro verify-release` 必须输出：

- `verificationIssue=GH-595`
- `verifyCoverage=foundation,sample-traces,full-gates,all-traces`
- `verifyTraceCount=15`
- `verifyCatalogTraceCount=15`
- `verifyGateBoundaryHeld=true`

`DASHBOARD_SMOKE=1 swift run Dashboard` 必须保持 read-model-only / command-gated surface，并输出 `releaseV020DashboardSurface=7`。

## Operator Checklist

1. 确认当前分支来自 `main` 或已 fast-forward 到最新 `origin/main`。
2. 确认 open PR = 0，open `todo` / `in-progress` / `in-review` issue = 0，除非正在执行唯一 closure issue `GH-596`。
3. 运行 `swift run mtpro verify-fast`，确认 fast gate 只覆盖 foundation + sample traces。
4. 运行 `swift run mtpro verify-release`，确认 release gate 覆盖 full gates + all 15 traces。
5. 运行 Dashboard smoke，确认 Dashboard 只展示 Spot / Perp / EMA / RSI / Risk / OMS / Portfolio panels，所有 panel 均通过 CommandGateway gate，production command disabled by default。
6. 运行完整本地验证命令。
7. 确认 GitHub required check `checks` SUCCESS 后才允许 squash merge closure PR。
8. 合并后确认 `main == origin/main`、worktree clean、`GH-563..GH-596` 全部 closed / done、open PR = 0、open active issue = 0。

## Credential And Endpoint Policy

Release v0.2.0 的 operator procedure 不读取、打印、保存或推导 production secret。testnet / dry-run / deterministic local evidence 不能 fallback 到 production credential。

禁止默认启用：

- production secret read
- production endpoint connection
- production broker endpoint connection
- account endpoint / listenKey production fallback
- broker gateway
- production OMS
- real submit / cancel / replace
- production Dashboard command
- Live PRO Console production command
- trading button / live command / order form

## Rollback And No-trade Procedure

验证失败时，operator 只能在当前 issue scope 内修复 deterministic evidence、docs、tests 或 guard。失败不能触发 production order、automatic recovery、rollback command、broker emergency API、sandbox-to-production command promotion 或真实 submit / cancel / replace。

No-trade state 仍是默认状态：

- `productionTradingEnabledByDefault == false`
- `productionEndpointEnabledByDefault == false`
- `productionSecretReadEnabledByDefault == false`
- `productionSubmitEnabledByDefault == false`
- `productionCancelEnabledByDefault == false`
- `productionReplaceEnabledByDefault == false`

## Evidence Map

| Evidence | Location |
| --- | --- |
| Release v0.2.0 contract | `docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md` |
| Stage Code Audit Report | `docs/audit/mtpro-release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-stage-code-audit.md` |
| Latest verification summary | `docs/validation/latest-verification-summary.md` |
| Trading validation matrix | `docs/validation/trading-validation-matrix.md` |
| Validation plan | `docs/validation/validation-plan.md` |
| Domain terms | `docs/domain/context.md` |
| Automation readiness guard | `checks/automation-readiness.d/release-v0.2.0-boundary.sh` |
| Focused closure test | `TargetGraphTests/testGH596ReleaseV020ClosureDocsRecordCompletedFactsWithoutNextPhaseAuthorization` |

## Stop Rule

`GH-596` closure 不创建下一 Project / Issue，不推进下一 Todo，不授权 release v0.2.0 之后的阶段。下一阶段只能由 Human + `@001 / PLN` 重新规划，经 approved live queue source 写入后，再由 Parent Codex queue preflight 推进唯一 eligible issue。
