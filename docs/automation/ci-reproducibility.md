# CI Reproducibility / CI 可重复性基线

日期：2026-06-07

执行者：Codex

## GH-450-CI-REPRODUCIBILITY-RUNNER-PINNED-SWIFT

MTPRO 当前 CI 可重复性策略是 runner-pinned Swift 6.3.x，而不是在本切片引入额外 Swift setup action。

当前事实：

- GitHub Actions workflow：`.github/workflows/checks.yml`。
- Linux engine runner：`ubuntu-24.04`。
- Swift toolchain gate：workflow 必须验证 runner 提供的 `Swift version 6.3.x`。
- SQLite system dependency gate：workflow 必须显式安装 `libsqlite3-dev`，因为 `Package.swift` 中的 `CSQLite` system library 依赖 `pkgConfig: "sqlite3"`。
- Local validation gate：`checks/run.sh` 必须在任何 SwiftPM build / run / test 前检查 `swift`、`pkg-config` 和 sqlite3 pkg-config metadata。
- Local Swift version gate：`checks/run.sh` 必须要求 Swift 6.3.x 或更新版本，避免本地低版本 toolchain 通过前置检查后再在 SwiftPM 阶段失败。
- Formatter gate boundary：`.swift-format` 可以作为 style configuration evidence 保留，但 `checks/run.sh` 和 GitHub required check `checks` 当前不强制接入 `swift-format` / `swiftformat`。如果未来把 formatter 接入 required check，必须作为独立 issue 更新本文档和 automation readiness anchor。

选择 runner-pinned Swift 6.3.x 的原因：

- 当前 GitHub runner 已稳定提供 Swift 6.3.x，且 PR #449 前后的 required check `checks` 已在该 baseline 上通过。
- 本仓库 `Package.swift` 的 `swift-tools-version` 仍是 6.0；CI 运行版本选择是验证环境 baseline，不改变 package tools-version。
- 本切片目标是降低现有 CI 漂移风险，不新增第三方 setup action、缓存策略或 toolchain 下载路径。
- 本切片不改变 GH-437 已落仓的 Swift style configuration 边界，不把 formatter 升级为 required check。
- 如果未来改为 `swift-actions/setup-swift` 或其他显式 toolchain installer，必须作为独立 hardening issue 修改本文档、workflow 和 automation-readiness anchor。

## GH-738-CI-DASHBOARD-MACOS-REQUIRED-GATE

Release v0.5.0 的 GH-738 历史上将 GitHub required check `checks` 从单一 Ubuntu job 调整为聚合 gate，并引入 Linux full validation 与 macOS Dashboard smoke 证据。该历史事实保留为 release CI evidence，但当前 PR 验证策略已在 `CI-PR-FAST-LANE-RELEASE-MATRIX` 下进一步拆分：

- `pr-fast-checks`：普通 `pull_request` 的 required fast lane，在 `ubuntu-24.04` 上验证 runner-pinned Swift 6.3.x、安装 `libsqlite3-dev`、执行 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/verify-ci-pr-fast-lane-release-matrix.sh`。
- `checks`：保留 required check 的稳定 job name，但只聚合 `pr-fast-checks`。这样分支保护仍要求 `checks`，但普通 PR 不再等待历史 release regression 与 macOS Dashboard smoke。
- `linux-checks`：保留 full Linux validation job name，只在 manual `workflow_dispatch`、`v*` tag push 或 `release/**` branch push 时运行 runner-pinned Swift 6.3.x 检查、安装 `libsqlite3-dev`、执行 `git diff --check` 和 `bash checks/run.sh`。
- `dashboard-macos`：保留 macOS Dashboard evidence job name，只在 manual `workflow_dispatch`、`v*` tag push 或 `release/**` branch push 时运行 Swift 6.x toolchain check、Dashboard focused guards、`swift build --product Dashboard` 和 `DASHBOARD_SMOKE=1 swift run Dashboard`。

该 gate 只加固 CI validation infrastructure，不读取 GitHub secrets，不连接 production endpoint / broker endpoint，不发送真实订单，不授权 production cutover。`checks/run.sh` 仍是本地完整验证入口和 release full lane 的 Linux 入口；macOS Dashboard job 是 release / manual validation coverage，不再拖慢普通 PR required check。

## CI-PR-FAST-LANE-RELEASE-MATRIX

当前 CI 策略把 review feedback loop 分成两条 lane：

- `CI-PR-FAST-LANE-REQUIRED-CHECKS`：普通 PR 的 required `checks` 只聚合 `pr-fast-checks`，覆盖 whitespace、automation readiness 和 shell / Python-only CI lane policy guard；TargetGraph Swift policy test 仍由本地完整验证和 release full lane 覆盖，不在普通 PR fast lane 里触发 SwiftPM build。
- `CI-RELEASE-FULL-LINUX-MACOS-MATRIX`：发布验证使用 manual `workflow_dispatch`、`v*` tag push 或 `release/**` branch push 触发 `linux-checks` 与 `dashboard-macos`，覆盖 `bash checks/run.sh`、Dashboard focused guards、Dashboard build 和 Dashboard smoke。
- `CI-NO-PRODUCTION-CUTOVER`：两条 lane 都不读取 secrets，不连接 production / broker endpoint，不提交真实订单，不授权 production cutover。

该拆分只改变 GitHub Actions 调度策略，不降低本地 release gate 要求；需要发布版本时仍必须显式运行完整本地验证和 release full matrix。

## GH-1201 Release Full Matrix Publication Evidence Gate

`GH-1201-VERIFY-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE` 固定 v0.18.1 patch queue 的 release publication evidence boundary。`TVM-RELEASE-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE`、`V0181-002-RELEASE-FULL-MATRIX-REQUIRED`、`V0181-002-LINUX-CHECKS-JOB-EVIDENCE`、`V0181-002-DASHBOARD-MACOS-JOB-EVIDENCE`、`V0181-002-PR-FAST-NOT-PUBLICATION-EVIDENCE` 和 `V0181-002-NO-PRODUCTION-CUTOVER` 是该 gate 的验证锚点。

release publication evidence must include GitHub Actions workflow run id, run attempt, workflow job ids: pr_fast_checks, linux_checks, dashboard_macos, release_publication_checks, and the evidence artifacts from GitHub Actions run log, job summary, Linux `checks/run.sh` output, and Dashboard macOS build / smoke output.

release publication cannot be represented as complete by pr-fast-checks or checks aggregate alone. linux-checks and dashboard-macos must both be SUCCESS for tag publication evidence, while ordinary PR required `checks` remains fast-lane-only and does not wait for the release full matrix. production cutover not authorized.

## GH-450-CI-REPRODUCIBILITY-VALIDATION

本切片只允许 CI / local validation reproducibility hardening，不授权业务能力。

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## GH-450-CI-REPRODUCIBILITY-NON-AUTHORIZATION

本切片不创建 Linear Project / Issue，不推进 Todo，不进入 L4。

本切片不实现：

- Strategy runtime
- Trader runtime
- Live runtime
- ExecutionClient implementation
- OMS implementation
- broker gateway 或 broker adapter
- signed endpoint、account endpoint / listenKey、private WebSocket runtime
- real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation
- Live PRO Console、trading button、live command、order form
