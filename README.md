# MTPRO

MTPRO 是用于重构 `macos-trader` 的新独立 macOS 交易研究工作台项目。

本项目借鉴 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 分层思想，但不引入 NautilusTrader 作为运行依赖，也不复制 `macos-trader` 整仓代码。

## 当前基线

`MTPRO 引导` Project 已完成：

- 项目目标、架构边界、产品面和 contract-first 文档。
- SwiftPM 模块：`Core`、`Adapters`、`Persistence`、`App`。
- 本地验证入口：`bash checks/run.sh`。
- GitHub PR Automation：`checks`、`protect-main`、squash auto-merge、branch cleanup。
- Parent Codex Automation Supervision、symphony-issue、Post-Issue Ledger 和 Graphify resource relationship graph 边界。

当前仓库不固定正在执行的 Linear issue。正式开发只能来自 Linear 中唯一 configured executable issue；`ROADMAP.md`、Linear Draft、Backlog issue、label、priority、assignee 都不授权执行。

## AEP v2 流程

| 阶段 | MTPRO 状态 | 边界 |
| --- | --- | --- |
| Human Project Planning | 下一 Project 规划前置 | Human 决定阶段目标、Linear Project 和 issue 顺序 |
| Parent Codex Automation Supervision | 已作为 Project 级自动调度方案 | queue preview、eligible issue 自动推进、child Codex 监控、代码审查、host-side fallback |
| symphony-issue | 已验证 issue 执行路径 | 调度唯一 `Todo` issue，推进 `Todo -> In Progress -> In Review` |
| GitHub PR Automation | 已验证 | required checks、auto-merge、squash merge、branch cleanup、Linear bot auto Done |
| Next Human Project Planning | 当前下一步 | 基于阶段审计报告决定下一个 Linear Project |

## 第一版产品边界

第一版只做策略研究到 Paper 的一致性闭环：

- UI：最小观察和操作入口。
- Backtest / Paper：第一优先级。
- Live：完全禁止，不保留真实 broker action。
- 数据源：Binance public market data read-only。
- 策略：先 EMA cross，再 order book imbalance。
- 时间粒度：`1m` 和 `5m`。
- 标的：`BTCUSDT`、`ETHUSDT`、`BNBUSDT`、`SOLUSDT`、`XRPUSDT`。

## 模块

```text
Sources/
  Core/          领域模型、事件、Kernel 边界
  Adapters/      外部数据源 adapter 边界
  Persistence/   Event Log / SQLite / DuckDB 边界
  Runtime/       ingest / event log / replay / projection 编排边界
  App/           macOS 产品面和 ViewModel 边界
  MTPRODashboard/ SwiftPM 可构建的 macOS 只读看板 shell

Tests/
  CoreTests/
  AdaptersTests/
  PersistenceTests/
  RuntimeTests/
  AppTests/
```

## 文档入口

- `GOAL.md`：项目目标。
- `ARCHITECTURE.md`：模块地图和边界。
- `ROADMAP.md`：阶段推进顺序，不授权执行。
- `docs/contracts/`：contract-first 输入。
- `docs/planning/project-role-map.md`：Product / Design / Engineering / Finance / Operations / QA 角色边界。
- `docs/validation/validation-plan.md`：验证计划。
- `docs/validation/latest-verification-summary.md`：最近验证摘要，Agent / Graphify 默认读取。
- `docs/automation/`：Parent Codex、symphony-issue、Graphify、Post-Issue Ledger 和 verified operations 边界。
- `docs/audit/mtpro-guidance-stage-code-audit.md`：`MTPRO 引导` 阶段审计报告。
- `verification.md`：append-only 完整验证流水账，仅用于审计、追溯和 debug。

## 本地验证

```bash
bash checks/run.sh
```
