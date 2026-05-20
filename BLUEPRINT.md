# BLUEPRINT.md

## 定位

本文档是 MTPRO 的 Root Blueprint 入口。

它让 Agent 从项目总览读到当前阶段，并指向完整产品 / 系统 / 设计蓝图。它不授权执行，不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 Symphony，不运行 Graphify update。

完整蓝图正文位于 `docs/design/mtpro-complete-blueprint.md`。

## 默认读取顺序

1. `README.md`
2. `AGENTS.md`
3. `GOAL.md`
4. `BLUEPRINT.md`
5. `ENVIRONMENT.md`
6. `ARCHITECTURE.md`
7. `ROADMAP.md`
8. `docs/domain/context.md`
9. `docs/validation/latest-verification-summary.md`

执行或验证时，再按当前 Linear issue scope 读取 `docs/contracts/`、`docs/product/`、`docs/validation/`、`docs/automation/agent-engineering-practices.md`、`docs/automation/`、Stage Code Audit Report 和当前 Linear issue body。

完整 `verification.md` 只在审计、追溯或 debug 时读取。

## 图纸分层

| 层 | 文件 | 职责 |
| --- | --- | --- |
| Project Charter | `GOAL.md` | 为什么建、服务谁、硬边界、成功标准 |
| Root Blueprint | `BLUEPRINT.md` | 项目总览、默认读取顺序、完整蓝图入口 |
| Complete Blueprint | `docs/design/mtpro-complete-blueprint.md` | Final Product Blueprint、System Architecture Blueprint、Workbench / UX Blueprint、Current Construction Scope、Future Construction Zones |
| Environment | `ENVIRONMENT.md` | 本地工具、验证入口、外部系统禁区 |
| Architecture Map | `ARCHITECTURE.md` | 当前架构地图 / 设计基线、模块边界、目标数据流和不变量 |
| Construction Plan | `ROADMAP.md` | 当前阶段路线、Project closure、Goal / Roadmap Target Progress |
| Shared Language | `docs/domain/context.md` | MTPRO 领域术语、禁止混用词、paper-only / read-only / future-gated 语义 |
| Agent Engineering Practices | `docs/automation/agent-engineering-practices.md` | shared language、feedback loop、tracer bullet、diagnose、architecture deepening 和 handoff discipline |
| Evidence | `docs/audit/`、`docs/validation/`、`verification.md` | Stage Code Audit、验证摘要和 append-only 历史 |

## Final Product Blueprint

MTPRO 最终目标是 macOS 原生交易研究与执行工作台。

长期完整能力：

- Research
- Backtest
- Report
- Paper
- Portfolio
- Risk
- Events
- Operations
- Future gated Live

这些长期能力不等于当前施工范围。MTPRO 不是 NautilusTrader 的 Swift 复刻，也不是 `macos-trader` 的整仓迁移。

## Current Construction Scope

当前已批准并完成 closure 的 paper-only foundation 已达到 5 / 5（100%）目标切片：

- Research / Backtest / Report / Paper readiness。
- Paper-only execution evidence。
- Live trading 禁区和 future boundary。
- Paper workflow 可观察性和本地 session-level control shell。
- 更长周期 market data replay / operations。

当前阶段完成事实见：

- `ROADMAP.md`
- `docs/validation/latest-verification-summary.md`
- `docs/audit/mtpro-market-data-replay-operations-v1-stage-code-audit.md`

下一阶段方向仍必须由 Human + `@001 / PLN` 基于完整蓝图和 Stage Code Audit 输入确认。

## Future Construction Zones

以下能力不得从本文档直接进入 Linear issue scope：

- Live trading。
- Binance signed endpoint。
- account endpoint / listenKey。
- broker integration。
- real order submit / cancel / replace。
- OMS。
- real account balance / broker position sync。
- deployment / production operations。
- advanced multi-strategy / long-cycle research platform。

这些能力只有在 Human 明确选入 Current Construction Scope、完成新的 Project Planning、写入 Linear，并通过 Parent Codex queue preflight 后，才可能进入执行。

## 执行边界

`BLUEPRINT.md`、`docs/design/mtpro-complete-blueprint.md`、`ROADMAP.md`、Project Planning Record、Backlog issue、label、priority 和 assignee 都不授权执行。

只有 Linear live-read 中唯一 configured executable issue 可以进入正式开发。
