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

Release v0.5.0 的 GH-738 将 GitHub required check `checks` 从单一 Ubuntu job 调整为聚合 gate：

- `linux-checks`：继续在 `ubuntu-24.04` 上运行 runner-pinned Swift 6.3.x 检查、安装 `libsqlite3-dev`、执行 `git diff --check` 和 `bash checks/run.sh`。
- `dashboard-macos`：在 `macos-15` 上验证 Swift 6.x toolchain，并执行 `git diff --check`、`bash checks/verify-v0.5.0-preflight.sh`、`swift build --product Dashboard` 和 `DASHBOARD_SMOKE=1 swift run Dashboard`。
- `checks`：保留 required check 的稳定 job name，只聚合 `linux-checks` 与 `dashboard-macos` 的结果；任一 upstream job 失败时 required check 失败。
- Workflow triggers：`pull_request`、manual `workflow_dispatch` 和 `v*` tag push 均可运行同一验证链路，用于 release / tag validation coverage。

该 gate 只加固 CI validation infrastructure，不读取 GitHub secrets，不连接 production endpoint / broker endpoint，不发送真实订单，不授权 production cutover。`checks/run.sh` 仍是本地完整验证入口；macOS Dashboard job 是 required-check coverage 的补充，不替代本地验证。

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
