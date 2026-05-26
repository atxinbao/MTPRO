# Workbench Beta Operator Guide

日期：2026-05-27

执行者：Codex

## 定位

`MTP-124-OPERATOR-GUIDE`

本文档是 `MTPRO Workbench Beta Readiness v1` 的 local operator guide。它只服务本机 macOS Workbench beta：帮助 Human / operator 完成环境确认、SwiftPM 本地构建、Dashboard smoke、demo workflow、acceptance checklist 和失败排查。

本文档不是 marketing landing page，不是 Live PRO Console 文档，不是 production deployment guide，不是 notarization / App Store / auto-update guide，不授权下一阶段 execution，不创建 Linear Project / Issue，不修改 Linear status，不启动 Symphony，不运行 Graphify，不修改 Figma。

## 前置边界

`MTP-124-BETA-NOT-LIVE-READINESS`

Workbench beta readiness 的含义：

- 只表示 local macOS Workbench demo / acceptance path 可以在本机复现。
- 只消费 Read Model / ViewModel 和 deterministic fixture evidence。
- 只展示 Research -> Backtest -> Report -> Paper -> Events evidence chain。
- 不表示 production release、notarization、App Store distribution、auto-update、production operations 或 cloud deployment。
- 不表示 live readiness、真实账户准备、broker readiness、Live PRO Console 或真实交易授权。

## Operator Quick Path

在仓库根目录执行：

```bash
bash checks/workbench-beta-acceptance.sh
```

该脚本按 MTP-123 固定顺序执行：

1. `uname -s`
2. `swift --version`
3. `swift package resolve`
4. `DASHBOARD_SMOKE=1 swift run Dashboard`
5. `bash checks/run.sh`

脚本会把 transcript 写入 `.codex/beta-acceptance/<run-id>/`。这些文件只用于本地 handoff 和 debug，不进入 GitHub PR。

## Manual Runbook

`MTP-124-ACCEPTANCE-WORKFLOW-REFERENCE`

如果需要手动分步定位，可以按以下顺序运行：

| Step | Command | Operator 判断 |
| --- | --- | --- |
| Environment | `uname -s` | 必须为 `Darwin`；完整 Dashboard build / smoke path 是 macOS-only |
| Toolchain | `swift --version` | 必须显示 Swift 6+ toolchain |
| Dependency resolution | `swift package resolve` | SwiftPM dependency 可解析；不需要 secret、API key、account endpoint、listenKey 或 broker credential |
| Local build artifact | `swift build --product Dashboard` | 只生成 `.build` 下本地 artifact，不创建 production installer |
| Dashboard smoke | `DASHBOARD_SMOKE=1 swift run Dashboard` | 输出稳定 smoke handles |
| Acceptance script | `bash checks/workbench-beta-acceptance.sh` | 生成 operator reproducibility transcript |
| Required validation | `bash checks/run.sh` | 输出 `MTPRO checks passed.` |

## Expected Smoke Handles

operator 只需要确认稳定 handles，不需要复制完整 build log：

```text
sections=8
readModelOnly=true
workbenchReadModelOnly=true
controls=start,pause,close,reset
defaultDemoState=default demo
defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario
scenarioReplayEvidence=1
scenarioQualityGates=6
simulatedParityEvidence=1
betaFirstRunFallbacks=3
betaAcceptancePaths=1
betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario
betaAcceptanceTrace=5
liveBlockedGates=6
liveExecutionControlGates=7
liveRiskGates=6
liveIncidentStopGates=5
liveMonitoringHealth=blocked
```

这些 handles 的含义是 Workbench beta demo evidence 可复现、read-model-only boundary 未漂移、Live 相关能力仍保持 blocked evidence。它们不表示真实订单、真实成交、真实账户、broker、OMS 或 Live PRO Console 已实现。

## Known Limitations

`MTP-124-KNOWN-LIMITATIONS`

- 本 guide 只覆盖 local macOS Workbench beta，不覆盖 Linux UI smoke、不覆盖 production packaging。
- `local install` 只表示 `swift package resolve` 和 `swift build --product Dashboard` 生成本地 SwiftPM artifact。
- Dashboard smoke 是命令行 smoke summary，不是截图验收、UI 自动点击验收或 notarized app 验收。
- Demo scenario 固定为 `mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`，不提供 scenario selector、remote catalog、download action 或 repair command。
- Acceptance transcript 写入 `.codex/beta-acceptance/<run-id>/`，不进入 PR。
- MTP-125 才能收口 automation readiness / validation evidence / stage audit input；本文档不输出最终 Stage Code Audit Report。

## Forbidden Capabilities

`MTP-124-FORBIDDEN-CAPABILITY-BOUNDARY`

本 guide 明确禁止把以下能力写成当前支持、beta preview、partially supported 或 behind flag available：

- production release、notarization、App Store distribution、auto-update、production deployment、cloud operations。
- API key / secret read、signed endpoint、account endpoint、listenKey。
- broker adapter、exchange execution adapter、`LiveExecutionAdapter`。
- OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation。
- real account balance、broker position sync、margin、leverage、real PnL。
- live readiness、live runtime、Live PRO Console、trading button、live command、order-level command UI。
- emergency stop、shutdown、restore、production operations command。
- Graphify update、Figma change。

## Troubleshooting

`MTP-124-TROUBLESHOOTING-POINTERS`

| Symptom | First check | Boundary |
| --- | --- | --- |
| `uname -s` 不是 `Darwin` | 切回 macOS 本地运行 | 不在非 macOS 环境伪造 SwiftUI Dashboard smoke |
| `swift --version` 失败 | 检查本机 Swift toolchain / Xcode command line tools | 不新增 release automation |
| `swift package resolve` 失败 | 检查 SwiftPM dependency resolution 和本地网络 / cache | 不读取 secret，不接 broker |
| `swift build --product Dashboard` 失败 | 定位第一处编译错误和 SwiftPM target 依赖 | 不改成 production installer |
| Dashboard smoke handle 缺失 | 检查 MTP-120 / MTP-121 / MTP-122 evidence 是否仍消费同一 demo scenario | 不新增 scenario download / repair command |
| `bash checks/run.sh` 失败 | 按 `git diff --check`、`checks/automation-readiness.sh`、Dashboard build / smoke、`swift test` 顺序收窄 | 不通过 live command、trading button 或 external service 绕过 |

## Evidence Handoff

PR evidence 应摘要记录：

- `bash checks/workbench-beta-acceptance.sh` 是否通过。
- `bash checks/run.sh` 是否通过。
- smoke handles 是否包含 `defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。
- `.codex/*` 和 `graphify-out/*` 未进入 PR。

handoff marker 仍由 symphony-issue / Codex Execution Agent 在 PR ready-for-review 和 auto-merge handoff 后写入 `.codex/symphony-issue-handoff.json`。
