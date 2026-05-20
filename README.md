# MTPRO

MTPRO 是 SwiftPM-first、local-first 的 macOS 原生专业交易工作台，用于重构 `macos-trader` 中已经验证过的产品语义。

项目借鉴 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 分层思想，但不引入 NautilusTrader 作为运行依赖，也不复制 `macos-trader` 整仓代码。

## 默认读取

Agent 进入仓库时按以下顺序读取：

1. `README.md`
2. `AGENTS.md`
3. `GOAL.md`
4. `BLUEPRINT.md`
5. `docs/environment.md`
6. `docs/architecture.md`
7. `docs/roadmap.md`
8. `docs/domain/context.md`
9. `docs/validation/latest-verification-summary.md`

完整 `verification.md` 只在审计、追溯或 debug 时读取。

## 当前定位

MTPRO 当前已经完成 Research -> Backtest -> Report -> Paper readiness / paper-only execution evidence / Paper workflow control shell / Market data replay operations 的 paper-only foundation。

最终产品目标是专业交易工作台：先以可追溯证据链服务个人专业交易者 / 独立策略研究者，后续再通过独立 Human decision、独立 Project Definition、signed endpoint / broker / risk / operations gates，演进到 Live trading、实盘监控台、实盘执行控制、实盘风险控制和实盘审计 / 事故回放 / 停机控制。

当前硬边界：

- Binance 只允许 public market data read-only。
- 当前 execution scope 内，Live trading、signed endpoint、account endpoint、listenKey、broker action 和真实订单全部禁止。
- Event Log 是 append-only facts source。
- SQLite / DuckDB 只作为 projection。
- UI 只消费 ViewModel / Read Model，不直接读取 adapter、database schema 或 runtime object。

## 执行事实源

仓库文档不固定 current issue。

正式开发只能来自 Linear live-read 中唯一 configured executable issue：

```text
Linear Project / Issues
-> Parent Codex queue preflight
-> unique Todo
-> symphony-issue
-> Codex Execution Agent
-> GitHub PR Automation
```

`docs/roadmap.md`、planning record、Backlog issue、label、priority、assignee 或文档摘要都不授权执行。

## 代码结构

```text
Sources/
  Core/          领域模型、事件、策略、paper-only execution contract
  Adapters/      Binance public read-only market data boundary
  Persistence/   append-only Event Log、SQLite / DuckDB projections
  Runtime/       ingest / event log / replay / projection orchestration
  App/           ViewModel / Read Model boundary
  Dashboard/     SwiftPM macOS dashboard shell

Tests/
  CoreTests/
  AdaptersTests/
  PersistenceTests/
  RuntimeTests/
  AppTests/
```

## 文档入口

| 文件 | 作用 |
| --- | --- |
| `GOAL.md` | Project Charter：项目使命、用户、硬边界和成功标准 |
| `BLUEPRINT.md` | Canonical Blueprint：Root Blueprint + Complete Blueprint，项目总览、完整产品 / 系统 / 设计蓝图、Current / Future 边界 |
| `docs/architecture.md` | Engineering Module Map / 工程模块地图：根据蓝图拆工程模块、边界、数据流和不变量 |
| `docs/roadmap.md` | Construction Plan：根据蓝图和工程模块定义施工顺序、目标进度和非授权边界 |
| `docs/environment.md` | 本地环境、验证入口、外部系统边界 |
| `AGENTS.md` | Agent / Codex 行为规则 |
| `docs/domain/context.md` | Shared Language：领域术语和禁止混用词 |
| `docs/automation/agent-engineering-practices.md` | 从 `mattpocock/skills` 吸收的 feedback loop、tracer bullet、diagnose、architecture deepening 方法 |
| `docs/planning/` | Project Planning Record、角色编号和 Linear 草案规则 |
| `docs/automation/` | Parent Codex、symphony-issue、Graphify、GitHub PR Automation、Post-Issue Ledger 边界 |
| `docs/validation/` | 最近验证摘要、长期验证计划、trading validation matrix |
| `docs/audit/` | Project 级 Stage Code Audit Reports 和 stage audit inputs |
| `verification.md` | append-only 完整验证流水账，仅用于审计、追溯和 debug |

## 本地验证

```bash
bash checks/run.sh
```

`checks/run.sh` 串联 whitespace、automation readiness、Dashboard build / smoke 和 Swift tests。

## AEP 方法论

MTPRO 采用 AEP 编号方法论：

```text
0. New Project Initialization
1. Human Project Planning
2. Construction Plan / Linear Draft
3. Linear execution contract
4. Parent Codex project supervision
5. symphony-issue single issue execution
6. GitHub PR Automation
7. Stage Code Audit
8. Root Docs Refresh / Current Phase Progress Bar
9. Next Human Project Planning
```

同时吸收 `mattpocock/skills` 的小而可组合工程实践。落地规则见 `docs/domain/context.md` 和 `docs/automation/agent-engineering-practices.md`。
