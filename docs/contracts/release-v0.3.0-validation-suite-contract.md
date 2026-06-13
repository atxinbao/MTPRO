# Release v0.3.0 Validation Suite Contract

日期：2026-06-13

执行者：Codex

## Goal

`V030-12-VERIFY-RELEASE-VALIDATION-SUITE` 固定 GH-668 的 release v0.3.0 验证入口：`bash checks/verify-v0.3.0.sh` 必须在本地和 `checks/run.sh` 中重复执行，覆盖 GH-657 至 GH-667 的完整 rehearsal chain，并保持 production trading 默认关闭。

## Scope

- `V030-12-COMPLETE-REHEARSAL-CHAIN`：验证入口必须串联 runtime rehearsal contract、environment config、DataEngine、Trader、RiskEngine、ExecutionEngine / OMS、Binance adapter、Event Store、Portfolio、Dashboard / CLI surface 和 kill switch / no-trade / rollback drill 的 focused TargetGraph tests。
- `V030-12-CLI-REHEARSAL-SMOKE`：验证入口必须执行 `swift run mtpro rehearsal-status`，并断言 CLI 输出仍为 blocked rehearsal status、CommandGateway required、kill switch blocked、no-trade blocked 和 `boundaryHeld=true`。
- `V030-12-PRODUCTION-DISABLED-BOUNDARY`：验证入口必须断言 production trading、production endpoint auto-connect、production secret auto-read、production order submission 和 production cutover authorization 仍为 false。
- `TVM-RELEASE-V030-VERIFY-VALIDATION-SUITE`：trading validation matrix 必须记录该验证入口、覆盖范围、边界和后续 GH-669 handoff。

## Non-goals

- 不打开 production trading。
- 不读取 production secret。
- 不连接 production endpoint。
- 不连接真实 broker gateway。
- 不发送真实 submit / cancel / replace。
- 不授权 production cutover。
- 不新增非 Binance venue。
- 不新增 Spot / USDⓈ-M Perpetual 以外的 active product。
- 不新增 EMA / RSI 以外的 active strategy。
- 不让 Dashboard / CLI 绕过 CommandGateway。
- 不创建或启动下一 milestone。

## Validation

- `bash checks/verify-v0.3.0.sh`
- `swift test --filter TargetGraphTests/testGH668VerifyV030ReleaseValidationSuiteCoversFullRehearsalChain`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Acceptance Criteria

- `checks/verify-v0.3.0.sh` 存在，并包含 `GH-668-VERIFY-V030-RELEASE-VALIDATION-SUITE` 和 `TVM-RELEASE-V030-VERIFY-VALIDATION-SUITE`。
- `checks/run.sh` 必须调用 `bash checks/verify-v0.3.0.sh`。
- `checks/automation-readiness.sh` 必须机械检查该脚本、contract、matrix、validation plan、automation readiness 文档和 focused TargetGraph test。
- 验证入口必须覆盖 GH-657 至 GH-667 的 focused tests。
- 验证入口必须执行 `mtpro rehearsal-status` 并检查 production-disabled boundary 输出。

## Boundary

GH-668 只新增 release v0.3.0 rehearsal validation suite，不实现新 runtime，不改变 SwiftPM target graph，不接入真实 network / testnet network，不读取 secret，不连接 broker，不提交真实订单，不授权 production cutover。GH-669 后续只能消费该验证入口编写 operator rehearsal runbook，不得把 verification pass 解释成 production readiness 或 operator approval。
