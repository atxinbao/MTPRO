# MTPRO Release v0.1.0 Binance EMA Operator Runbook

日期：2026-06-08

执行者：Codex

本文档服务 GitHub fallback issue `GH-539 Add release docs and operator runbook`。

## GH-539-RELEASE-DOCS-OPERATOR-RUNBOOK

`GH-539-RELEASE-DOCS-OPERATOR-RUNBOOK`

Release v0.1.0 operator runbook 是 Binance + EMA 最小真实交易运行时验证阶段的操作边界说明。它只指导本地 deterministic validation、dry-run / Binance testnet evidence、operator review 和 no-trade / rollback procedure，不授权 production trading、不读取 production secret、不连接 production endpoint、不连接 production broker endpoint，也不创建下一 release scope。

Release v0.1.0 当前 active scope：

- active venue：`Binance`
- active concrete strategy：`EMA`
- dry-run / testnet-first：必须先完成本地 deterministic evidence、dry-run evidence 和 Binance testnet evidence。
- production disabled by default：production trading、production endpoint、production secret、production submit / cancel / replace、production OMS 和 production Dashboard command surface 均默认关闭。

## GH-539-DRYRUN-TESTNET-ACCEPTANCE-PROCEDURE

`GH-539-DRYRUN-TESTNET-ACCEPTANCE-PROCEDURE`

Operator 只能按以下顺序收集 release v0.1.0 验收证据：

1. 确认本地仓库在目标 release branch 或 `main`，且 `git status --short` 无非本轮改动。
2. 运行 `git diff --check`，确认 whitespace / patch hygiene 通过。
3. 运行 `bash checks/automation-readiness.sh`，确认 required readiness、#538 no-default-production-trading guard 和 release evidence anchors 通过。
4. 运行 `bash checks/release-v0.1.0-dryrun-testnet.sh`，确认 GH-537 dry-run / testnet validation suite 可重复执行。
5. 运行 `bash checks/run.sh`，确认 Dashboard smoke、release guard、focused tests 和全量 Swift tests 通过。
6. 只在当前 issue / PR 明确授权时，记录 Binance testnet credential reference 或 mock transport evidence；缺少 testnet credential 时停止并报告，不回退到 production secret 或 production endpoint。

验收输出必须记录：

- command 名称。
- pass / fail 状态。
- Dashboard smoke 中的 `releaseLiveMonitoringSurface=7`、`releaseCommandSurface=3` 和 `releaseKillSwitch=3`。
- `MTPRO release v0.1.0 no-default-production-trading guard passed.`。
- `MTPRO release v0.1.0 dry-run/testnet validation suite passed.`。
- Swift XCTest 总数和 0 failures 结果。

## GH-539-CREDENTIAL-HANDLING-INSTRUCTIONS

`GH-539-CREDENTIAL-HANDLING-INSTRUCTIONS`

Release v0.1.0 credential handling 只允许 testnet / local fixture / redacted reference 语义：

- 允许：testnet credential reference identity、local fixture identity、mock transport identity、redacted listenKey reference。
- 禁止：读取、打印、保存或推导 production secret。
- 禁止：把 testnet credential reference 升级为 production credential。
- 禁止：把缺失的 testnet credential 回退为 production secret、production endpoint 或 production broker endpoint。
- 禁止：在 PR、logs、docs、verification 或 issue comment 中写入 API key、secret、signature value、raw listenKey、account endpoint payload 或 broker payload。

如果 release validation 需要真实 testnet 环境而当前环境缺少凭证，operator 必须停止当前 issue gate，并报告 `missing testnet credential / environment`。该状态不允许通过 production credential、production endpoint 或真实 broker 连接绕过。

## GH-539-PRODUCTION-DISABLED-BOUNDARY

`GH-539-PRODUCTION-DISABLED-BOUNDARY`

Production trading 在 release v0.1.0 中默认禁止。以下条件即使全部满足，也不代表 production authorization：

- GH-537 dry-run / testnet validation suite passed。
- GH-538 no-default-production-trading automation guard passed。
- Binance testnet submit / cancel / replace evidence passed。
- Dashboard controlled command surface 显示 command entry。
- Operator 完成 dry-run / testnet checklist。

Production trading 仍需要后续显式 release gate、operator confirmation、risk approval、kill switch pass、capital / exposure limits 和 production cutover authorization。GH-539 不提供这些授权。

## GH-539-ROLLBACK-NO-TRADE-PROCEDURE

`GH-539-ROLLBACK-NO-TRADE-PROCEDURE`

当 dry-run / testnet validation、readiness guard、Dashboard smoke 或 full checks 失败时，operator 必须执行 no-trade procedure：

1. 保持 no-trade state，不发出 submit / cancel / replace。
2. 保持 kill switch active，不执行 automatic recovery。
3. 记录失败 command、失败摘要和当前 issue / PR。
4. 只在当前 issue scope 内修复 readiness、docs、test 或 deterministic evidence。
5. 如果失败需要 production secret、production endpoint、production broker、real submit / cancel / replace 或非 Binance / 非 EMA scope，立即停止并报告。
6. 回滚只允许通过 Git revert / PR revert / branch reset 到未合并本地 commit 的方式进行，不调用 broker emergency API，不触发 production rollback command。

## GH-539-OPERATOR-CHECKLIST

`GH-539-OPERATOR-CHECKLIST`

Operator 在 release v0.1.0 PR 或 issue 收口前必须确认：

- [ ] `git diff --check` 通过。
- [ ] `bash checks/automation-readiness.sh` 通过，并包含 #538 guard passed 输出。
- [ ] `bash checks/release-v0.1.0-dryrun-testnet.sh` 通过。
- [ ] `bash checks/run.sh` 通过。
- [ ] `productionTradingEnabledByDefault == false`。
- [ ] `productionEndpointConnectionEnabledByDefault == false`。
- [ ] `productionSecretReadEnabledByDefault == false`。
- [ ] `productionOrderSubmitEnabledByDefault == false`。
- [ ] `productionOrderCancelEnabledByDefault == false`。
- [ ] `productionOrderReplaceEnabledByDefault == false`。
- [ ] `productionOMSRuntimeEnabledByDefault == false`。
- [ ] `productionDashboardCommandEnabledByDefault == false`。
- [ ] Binance 是唯一 active venue。
- [ ] EMA 是唯一 active concrete strategy。
- [ ] 没有 Linear / Symphony / Graphify / code-index / Figma evidence。
- [ ] 没有 `.codex/*` 或 `graphify-out/*` 提交。

## TVM-RELEASE-V010-OPERATOR-RUNBOOK

`TVM-RELEASE-V010-OPERATOR-RUNBOOK`

Release v0.1.0 operator runbook matrix 必须证明 runbook 覆盖 dry-run / testnet acceptance procedure、credential handling instructions、production disabled boundary、rollback / no-trade procedure、operator checklist 和 forbidden capability audit。该 matrix 只能作为 #540 validation matrix closeout 和 #541 final audit 的输入，不授权 production cutover、不创建下一 Project / Issue、不推进 release v0.1.0 之后的阶段。

## GH-539-NON-AUTHORIZATION

`GH-539-NON-AUTHORIZATION`

GH-539 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading、production submit / cancel / replace 或 production broker connection。
- production secret read、secret editor、signature value exposure、account endpoint、listenKey 或 production endpoint。
- 真实 Binance testnet network call、production broker gateway、OMS mutation、real order lifecycle、automatic rollback command 或 broker emergency API。
- 绕过 RiskEngine、ExecutionEngine、OMS、kill switch、operator confirmation、dry-run / testnet gate 或 no-trade state。
- Live PRO Console runtime、real trading button、live command、order form 或 production cutover。
- non-Binance venue、non-EMA active strategy、下一 Project / Issue 或 release v0.1.0 之后的阶段。
