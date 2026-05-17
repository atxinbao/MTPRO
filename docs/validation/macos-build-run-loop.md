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

MTP-22 后 `bash checks/run.sh` 已包含：

```bash
swift build --product MTPRODashboard
MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard
```

## UI 阶段前必须补齐

当 Linear issue 进入 Trader Workstation Dashboard 或 macOS App shell 实现时，必须补齐：

- 可运行的 macOS App shell。
- 本地 build 命令。
- 本地 run 命令或明确的运行入口。
- 最小 Logger / telemetry 事件。
- UI smoke check。
- 运行日志或截图证据。

## MTP-22 已补齐内容

- 可运行入口：`MTPRODashboard` SwiftPM executable。
- 本地 build：`swift build --product MTPRODashboard`。
- 本地 run / smoke：`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard`。
- 最小 telemetry：app launch 与 ViewModel snapshot generated 通过 `OSLog.Logger` 记录。
- UI smoke check：smoke run 输出七个 section 和 `readModelOnly=true`。

当前未补截图证据；本事项的 required validation 以 SwiftPM build / smoke run / XCTest snapshot binding 为准。

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
