# MTPRO

MTPRO 是一个 SwiftPM-first 的 macOS 交易研究工作台，用于重构 `macos-trader` 中已经验证过的产品语义。

项目借鉴 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 分层思想，但不引入 NautilusTrader 作为运行依赖，也不复制 `macos-trader` 整仓代码。

## 当前定位

第一版产品只做 Research -> Backtest -> Report -> Paper readiness / paper-only execution evidence。

硬边界：

- Binance 只允许 public market data read-only。
- Live trading、signed endpoint、account endpoint、listenKey、broker action 和真实订单全部禁止。
- Event Log 是 append-only facts source。
- SQLite / DuckDB 只作为 projection。
- UI 只消费 ViewModel / Read Model，不直接读取 adapter、database schema 或 runtime object。

## 当前执行事实源

仓库文档不固定 current issue。

正式开发必须来自 Linear live-read 中唯一 configured executable issue：

```text
Linear Project / Issues
-> Parent Codex queue preflight
-> unique Todo
-> symphony-issue
-> Codex Execution Agent
-> GitHub PR Automation
```

`ROADMAP.md`、planning record、Backlog issue、label、priority、assignee 或文档摘要都不授权执行。

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
| `GOAL.md` | 项目目标和非目标 |
| `ENVIRONMENT.md` | 本地环境、验证入口、外部系统边界 |
| `ARCHITECTURE.md` | 模块地图、数据流、不变量 |
| `ROADMAP.md` | 阶段地图和非授权边界 |
| `AGENTS.md` | Agent / Codex 行为规则 |
| `docs/planning/linear-draft-plan.md` | Project Planning Record 索引和规则 |
| `docs/planning/project-role-map.md` | `@000` 到 `@007` 角色边界 |
| `docs/design/mtpro-complete-blueprint.md` | Human + `@000 / AIE` 维护的完整产品 / 系统 / 设计蓝图 |
| `docs/validation/latest-verification-summary.md` | Agent / Graphify 默认读取的最近验证摘要 |
| `docs/validation/validation-plan.md` | 长期验证计划 |
| `docs/validation/trading-validation-matrix.md` | trading validation evidence map |
| `docs/automation/` | Parent Codex、symphony-issue、Graphify、GitHub PR Automation、Post-Issue Ledger 边界 |
| `docs/audit/` | Project 级 Stage Code Audit Reports |
| `verification.md` | append-only 完整验证流水账，仅用于审计、追溯和 debug |

## 本地验证

```bash
bash checks/run.sh
```

`checks/run.sh` 是统一入口，包含 whitespace、automation readiness、Dashboard build / smoke 和 Swift tests。
