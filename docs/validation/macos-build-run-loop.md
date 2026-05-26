# macOS Build / Run / Telemetry Loop

日期：2026-05-18

执行者：Codex

## 定位

本文档定义 MTPRO 进入 macOS UI 阶段前需要补齐的本地运行验证闭环。

当前 MTPRO 仍以 SwiftPM package 和 XCTest 为 baseline validation。

## 当前 baseline

当前必须通过：

```bash
swift test
bash checks/run.sh
```

MTP-22 后 `bash checks/run.sh` 在 macOS 本地包含：

```bash
swift build --product Dashboard
DASHBOARD_SMOKE=1 swift run Dashboard
```

Linux CI 不提供 SwiftUI；`checks/run.sh` 在非 Darwin runner 上跳过 macOS executable build / smoke，
并继续执行 `swift test` 验证 snapshot binding、source boundary 和 executable fallback 编译。

## UI 阶段前必须补齐

当 Linear issue 进入 Trader Workstation Dashboard 或 macOS App shell 实现时，必须补齐：

- 可运行的 macOS App shell。
- 本地 build 命令。
- 本地 run 命令或明确的运行入口。
- 最小 Logger / telemetry 事件。
- UI smoke check。
- 运行日志或截图证据。

## MTP-22 已补齐内容

- 可运行入口：`Dashboard` SwiftPM executable。
- 本地 build：`swift build --product Dashboard`。
- 本地 run / smoke：`DASHBOARD_SMOKE=1 swift run Dashboard`。
- 最小 telemetry：app launch 与 ViewModel snapshot generated 通过 `OSLog.Logger` 记录。
- UI smoke check：smoke run 输出七个 section 和 `readModelOnly=true`。
- CI 兼容：App target 和 executable target 在非 macOS 环境使用 non-SwiftUI fallback 保留 snapshot binding contract。

当前未补截图证据；本事项的 required validation 以 SwiftPM build / smoke run / XCTest snapshot binding 为准。

## MTP-119 local beta launch / install / environment verification

日期：2026-05-27

执行者：Codex

`MTP-119-LOCAL-LAUNCH-INSTALL-ENVIRONMENT-PATH`

MTP-119 把既有 macOS / SwiftPM / Dashboard 路径固定为 Workbench beta 的本地启动、安装和环境验证入口。这里的 install 只表示 SwiftPM dependency resolution 与 `.build` 下本地构建产物，不表示 production installer、notarization、App Store distribution、auto-update、production deployment 或 cloud operations。

### 环境验证

`MTP-119-LOCAL-ENVIRONMENT-VERIFICATION`

在仓库根目录执行：

```bash
uname -s
swift --version
swift package resolve
```

验收条件：

- `uname -s` 输出 `Darwin`。
- `swift --version` 显示 Swift 6 或更高版本。
- `swift package resolve` 能解析 SwiftPM dependencies；该步骤不需要 secret、API key、account endpoint、listenKey、broker credential 或生产配置。

### 本地安装和启动

`MTP-119-LOCAL-INSTALL-RUN-NOTES`

本地 build artifact：

```bash
swift build --product Dashboard
```

交互启动入口：

```bash
swift run Dashboard
```

自动 smoke 启动入口：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

MTP-119 不创建 `.app` installer、`.pkg`、`.dmg`、notarized artifact、App Store build、auto-update channel、production deployment 或 cloud operations workflow。

### 启动 runbook

`MTP-119-LAUNCH-COMMAND-RUNBOOK`

1. 执行 `swift package resolve`。
2. 执行 `swift build --product Dashboard`。
3. 执行 `DASHBOARD_SMOKE=1 swift run Dashboard`。
4. 执行 `bash checks/run.sh`。

第 4 步仍是 PR 前 required validation；前 1-3 步只用于 operator 快速定位 local launch / install / smoke path。

### Dashboard smoke expectation

`MTP-119-DASHBOARD-SMOKE-EXPECTATION`

当前 MTP-119 smoke expectation：

```text
Dashboard smoke: sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=42; scenarioReplayEvidence=0; scenarioQualityGates=0; simulatedParityEvidence=0; paperRuntimeEvidence=0; paperWorkflowEvidence=0; paperPortfolioImpact=0.00; liveBlockedGates=6; liveExecutionControlGates=7; liveRiskGates=6; liveIncidentStopGates=5; liveMonitoringHealth=blocked; liveMonitoringErrors=3; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events
```

该 output 证明 Dashboard shell 可从 SwiftPM 本地启动，且仍保持 `readModelOnly=true` / `workbenchReadModelOnly=true`。`controls=start,pause,close,reset` 只表示 session-level local paper controls，不表示 order-level command、live command 或 trading button。

### 可复现启动证据

`MTP-119-REPRODUCIBLE-LAUNCH-EVIDENCE`

MTP-119 PR evidence 和 `verification.md` 应记录：

- `uname -s` / `swift --version` 环境摘要。
- `swift build --product Dashboard` 结果。
- `DASHBOARD_SMOKE=1 swift run Dashboard` smoke output。
- `bash checks/run.sh` final validation output。

### 失败排查入口

`MTP-119-TROUBLESHOOTING-BOUNDARY`

- `swift package resolve` 失败：检查 SwiftPM dependency resolution 和本地网络 / cache。
- `swift build --product Dashboard` 失败：检查第一个编译错误、SwiftUI macOS availability、SwiftPM target 依赖。
- `DASHBOARD_SMOKE=1 swift run Dashboard` 失败：检查 Dashboard executable、App ViewModel assembly 和 smoke summary。
- `bash checks/run.sh` 失败：按 `git diff --check`、`checks/automation-readiness.sh`、Dashboard build / smoke、`swift test` 顺序收窄。

排查不得通过读取 secret、连接 signed endpoint / account endpoint / listenKey、接入 broker / exchange execution adapter、实现 `LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、live command 或 trading button 来绕过本地验证失败。

`MTP-119-LOCAL-LAUNCH-VALIDATION`

MTP-119 required validation：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
bash checks/run.sh
```

## telemetry 规则

telemetry 只记录开发和验证所需的运行事实：

- app launch。
- dashboard data source loaded。
- ViewModel snapshot generated。
- validation error。
- paper readiness blocker。

不得记录：

- API key。
- broker credential。
- account endpoint response。
- 真实交易行为。

## 进入条件

只有当前 Linear issue 明确要求 macOS App shell、UI 或 runtime validation 时，才需要扩展本文件和验证命令。
