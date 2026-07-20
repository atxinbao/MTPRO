# MTPRO Environment

Date: 2026-07-20

Executor: Codex

Status: Canonical

## 本地基线

| 项目 | 当前要求 |
| --- | --- |
| macOS | 14+ |
| Swift | 6.3+ |
| 构建 | SwiftPM |
| UI | SwiftUI |
| 并发 | Swift concurrency / actor |
| 网络 | URLSession / URLSessionWebSocketTask |
| 加密 | swift-crypto |
| 本地存储 | SQLite、DuckDB |
| shell | Bash / zsh |

Linux GitHub runner 用于 SwiftPM、文档和验证脚本；macOS runner 负责 Dashboard build / smoke。

## 依赖预检

本地完整验证前需要：

```bash
swift --version
pkg-config --exists sqlite3
```

Swift 必须满足项目脚本声明的最低版本。SQLite development metadata 必须可被 `pkg-config` 发现。

## 开发命令

```bash
swift build
swift test
swift run mtpro help
swift run Dashboard
```

Dashboard smoke：

```bash
DASHBOARD_SMOKE=1 swift run Dashboard
```

## 必跑验证

每个 PR 至少运行：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

`checks/run.sh` 是本地聚合入口，负责 SwiftPM build / test、Dashboard smoke 和版本 guard。GitHub required checks 是合并证据，不能替代本地失败调查。

## 外部系统

| 系统 | 当前用途 | 规则 |
| --- | --- | --- |
| GitHub | issue、PR、Actions、Release、artifact provenance | required checks 必须通过 |
| Binance public API | 明确任务下的数据读取或 probe | 不需要 secret |
| Binance Demo Network | Human-approved 验证 | 只使用隔离 credential；artifact 必须脱敏 |
| Binance production | 独立 cutover future gate | 默认不连接、不执行 |
| Linear | 当前不使用 | GitHub issue queue 是当前任务来源 |
| Symphony / Graphify | 不使用 | 不作为运行、调度或文档依赖 |

## Secret 与凭证

- Secret 只允许通过本地环境或 GitHub encrypted secret 注入。
- 不得写入 Git、文档、日志、CLI 输出或 artifact。
- 只记录 credential reference、redacted fingerprint 和审批证据。
- 缺失、过期、环境不匹配或未经授权的 credential 必须 fail closed。
- 任何已经出现在聊天或日志中的 credential 都应视为泄露并轮换。

## 网络与交易边界

当前权威事实：

```text
backendClosureDecision=accepted-demo-network-parity
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

Demo submit / status / cancel 能力已验证，但 production 不自动继承：

- 不自动读取 production secret。
- 不自动连接 production endpoint。
- 不自动发送 production submit / cancel / replace。
- production profile 必须由独立 Human approval 和 cutover gate 显式启用。

## 本地状态

- `.build/`、`.codex/`、本地 evidence、credential 文件和编辑器状态不得提交。
- Demo / test artifact 使用任务规定的本地目录或 GitHub artifact；提交前必须验证脱敏。
- 不保留 Symphony workspace、Graphify output 或其他已退休服务状态。
