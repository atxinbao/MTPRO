# Workbench Beta Acceptance Checklist

日期：2026-05-27

执行者：Codex

## 定位

本文档定义 `MTP-123` 的可复现 beta acceptance checklist / script。它只验证 local macOS Workbench beta readiness，不替代 CI，不创建 production release，不运行 Graphify，不修改 Figma，不进入 production operations，也不授权 execution、Live trading、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button 或 live command。

## MTP-123 reproducible beta acceptance workflow

`MTP-123-REPRODUCIBLE-BETA-ACCEPTANCE-WORKFLOW`

Operator 在仓库根目录运行：

```bash
bash checks/workbench-beta-acceptance.sh
```

该脚本只复用现有本地验证入口：

1. `uname -s`
2. `swift --version`
3. `swift package resolve`
4. `DASHBOARD_SMOKE=1 swift run Dashboard`
5. `bash checks/run.sh`

脚本会把本地执行 transcript 写入 `.codex/beta-acceptance/<run-id>/`。该目录只作为 operator reproducibility evidence，不进入 PR。

## MTP-123 beta acceptance checklist

`MTP-123-BETA-ACCEPTANCE-CHECKLIST`

验收 checklist：

- 环境必须是 `Darwin`，因为本 issue 验证的是 local macOS Workbench beta path。
- Swift toolchain 必须可用，`swift package resolve` 必须成功。
- Dashboard smoke 必须输出 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true` 和 `controls=start,pause,close,reset`。
- Demo scenario 必须保持 `defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`。
- First-run default demo 必须保持 `defaultDemoState=default demo`、`scenarioReplayEvidence=1`、`scenarioQualityGates=6`、`simulatedParityEvidence=1` 和 `betaFirstRunFallbacks=3`。
- Report / Dashboard / Events beta acceptance path 必须保持 `betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。
- Live boundary evidence 必须保持 blocked / read-model-only：`liveBlockedGates=6`、`liveExecutionControlGates=7`、`liveRiskGates=6`、`liveIncidentStopGates=5` 和 `liveMonitoringHealth=blocked`。
- `bash checks/run.sh` 必须完成并输出 `MTPRO checks passed.`。

## MTP-123 local commands and expected outputs

`MTP-123-LOCAL-COMMANDS-EXPECTED-OUTPUTS`

| Step | Command | Expected output / evidence |
| --- | --- | --- |
| Environment | `uname -s` | `Darwin` |
| Toolchain | `swift --version` | Swift 6+ local toolchain available |
| Dependency resolution | `swift package resolve` | SwiftPM dependencies resolve without secret, API key, account endpoint, listenKey or broker credential |
| Dashboard smoke | `DASHBOARD_SMOKE=1 swift run Dashboard` | Includes `betaAcceptancePaths=1`, `betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario`, `betaAcceptanceTrace=5`, `readModelOnly=true`, `workbenchReadModelOnly=true` |
| Required validation | `bash checks/run.sh` | `MTPRO checks passed.` |

## MTP-123 operator reproducibility evidence

`MTP-123-OPERATOR-REPRODUCIBILITY-EVIDENCE`

`checks/workbench-beta-acceptance.sh` writes evidence under `.codex/beta-acceptance/<run-id>/`:

- `summary.log`
- `uname.log`
- `swift-version.log`
- `swift-package-resolve.log`
- `dashboard-smoke.log`
- `mtpro-checks.log`

这些文件只用于本地 handoff、debug 和 PR evidence 摘要，不提交到 GitHub PR。正式 PR 只提交 checklist/script、文档 anchors 和 validation ledger。

## MTP-123 failure triage hints

`MTP-123-FAILURE-TRIAGE-HINTS`

- `uname -s` 不是 `Darwin`：停止；本 checklist 是 local macOS Workbench beta acceptance，不在非 macOS runner 上伪造 UI smoke。
- `swift --version` 或 `swift package resolve` 失败：先定位 SwiftPM toolchain / dependency resolution，不读取 secret，不接 broker，不改 production ops。
- Dashboard smoke 失败：检查 `Sources/Dashboard/DashboardApplication.swift`、`Sources/App/DashboardShell.swift`、`Sources/App/WorkbenchBetaFirstRunState.swift` 和 `Sources/App/WorkbenchBetaAcceptancePath.swift` 的 read-model-only assembly。
- smoke handle 缺失：优先确认 MTP-120 demo fixture、MTP-121 first-run default demo state 和 MTP-122 Report / Dashboard / Events beta acceptance path 是否仍消费同一 scenario `mtp-104-btcusdt-1m-first-scenario`。
- `bash checks/run.sh` 失败：按 `git diff --check`、`checks/automation-readiness.sh`、Dashboard build / smoke、`swift test` 的顺序收窄。

## MTP-123 boundary evidence

`MTP-123-NO-GRAPHIFY-FIGMA-PRODUCTION-OPS`

本 checklist / script 不调用 Graphify，不修改 Figma，不创建 release package，不做 notarization，不创建 App Store / auto-update / production deployment workflow，不读取 API key / secret，不接 signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS，不实现 real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button 或 live command。

`MTP-123-BETA-ACCEPTANCE-SCRIPT-VALIDATION`

Required validation：

```bash
bash checks/workbench-beta-acceptance.sh
bash checks/run.sh
```

第二条命令保留为 PR 前最终 gate，确保 checklist / script evidence 不替代仓库既有统一验证入口。
