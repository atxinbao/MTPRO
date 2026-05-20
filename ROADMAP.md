# ROADMAP.md

ROADMAP 只定义阶段地图，不授权执行。

正式执行必须来自 Linear live-read 中唯一 configured executable issue，并通过 Parent Codex queue preflight、symphony-issue 和 GitHub PR Automation。

本文档是 Construction Plan。完整产品终局和 Future Construction Zones 见 canonical `BLUEPRINT.md`；本文档只记录当前已批准阶段、目标切片进度和下一轮 planning handoff。

## 阶段地图

| 阶段 | 状态 | 结果 |
| --- | --- | --- |
| MTPRO 引导 | Completed | 根文档、contract-first 文档、SwiftPM baseline、自动化基线 |
| MTPRO Runtime Research Workbench v1 | Completed | Core 拆分、read-only market data boundary、event log / replay、SQLite / DuckDB projection、Dashboard shell、Research -> Backtest -> Report path |
| MTPRO Trading Validation and Parity Hardening | Completed | trading validation matrix、EMA / order book parity、fees / slippage assumptions、risk blocker、portfolio exposure、Report / Dashboard evidence |
| MTPRO Paper Session Runtime v1 | Completed | paper session lifecycle、proposal、risk link、paper-only portfolio projection、replay、report evidence |
| MTPRO Paper Execution Workflow v1 | Completed | paper-only execution workflow、paper order lifecycle、simulated fill、event log replay、Report / Dashboard evidence、Stage Code Audit Report |
| MTPRO Paper Workflow Control Shell v1 | Completed | Paper workflow Workbench information architecture、session-level local controls、observability、Event Timeline / Evidence Explorer preview、Dashboard / Workbench shell evidence、Stage Code Audit Report |
| MTPRO Market Data Replay Operations v1 | Completed | public read-only batch / replay boundary、local replay metadata、retention / freshness evidence、fixture parity、event log / projection consistency、Report / Dashboard / Event Timeline evidence、Stage Code Audit Report |

Completed Project 的完整证据见 `docs/audit/`。

当前 Project、active issue、Todo / In Progress / In Review 状态必须从 Linear 和 Parent Codex queue preview 实时读取，不写死在仓库文档中。

## Progress

MTPRO 采用两层进度口径：

1. Current Foundation Progress：当前已批准 paper-only foundation 的完成度。
2. Final Product Goal Progress：最终专业交易工作台产品目标的完成度。

Project Closure Count 只说明当前已批准、已执行、已 closure 的建设阶段 Project 数量，不代表完整产品蓝图或 Future Construction Zones 已经完成。

```text
Phase: MTPRO professional trading workstation
Project Closure Count: 7 / 7 (100%)
Current Foundation Progress: 4 / 4 (100%)
Final Product Goal Progress: 4 / 9 (44%)
Foundation Progress: [##########] 100%
Final Product Progress: [####------] 44%
```

已 closure Project：

- `MTPRO 引导`
- `MTPRO Runtime Research Workbench v1`
- `MTPRO Trading Validation and Parity Hardening`
- `MTPRO Paper Session Runtime v1`
- `MTPRO Paper Execution Workflow v1`
- `MTPRO Paper Workflow Control Shell v1`
- `MTPRO Market Data Replay Operations v1`

Current Foundation Progress 基于 `GOAL.md` 的当前 foundation 目标切片计算：

| Foundation 目标切片 | 状态 | 证据 |
| --- | --- | --- |
| Research / Backtest / Report / Paper readiness | Complete | Runtime Research Workbench、Trading Validation、Paper Session Runtime 已完成 |
| Paper-only execution evidence | Complete | Paper Execution Workflow v1 已完成 |
| Paper workflow 可观察性和本地控制壳 | Complete | Paper Workflow Control Shell v1 已完成，形成本地 session-level controls、observability、Event Timeline / Evidence Explorer preview 和 Dashboard / Workbench shell evidence |
| 更长周期 market data replay / operations | Complete | Market Data Replay Operations v1 已完成，形成 public read-only batch / replay boundary、local replay metadata、retention / freshness、fixture parity、event log / projection consistency 和 Report / Dashboard read-model-only evidence |

Final Product Goal Progress 基于 `GOAL.md` 的完整产品目标切片计算：

| # | 最终产品目标切片 | 状态 | 证据 / 下一步 |
| --- | --- | --- | --- |
| 1 | 研究 / 回测 / 报告基础能力（Research / Backtest / Report foundation） | Complete | Runtime Research Workbench、Trading Validation 和 Report evidence 已完成 |
| 2 | Paper 模拟执行基础能力（Paper execution foundation） | Complete | Paper Session Runtime 和 Paper Execution Workflow 已完成 |
| 3 | 工作台证据导航与本地控制壳（Workbench evidence navigation and local control shell） | Complete | Paper Workflow Control Shell v1 已完成 |
| 4 | 行情数据回放运营能力（Market data replay operations） | Complete | Market Data Replay Operations v1 已完成 |
| 5 | 实盘交易基础边界（Live trading foundation） | Pending / gated | 需要 Human 独立决策、独立 Project Definition、API key / signed endpoint / account endpoint / broker adapter / real order lifecycle gates |
| 6 | 实盘监控台（Live monitoring console） | Pending / gated | 需要 live runtime health、连接、行情流、订单流、错误、延迟和运行健康状态规划 |
| 7 | 实盘执行控制（Live execution control） | Pending / gated | 需要真实订单 submit / cancel / replace、成交回报、订单状态和执行失败处理规划 |
| 8 | 实盘风险控制（Live risk control） | Pending / gated | 需要真实 pre-trade risk、仓位、订单金额、频率、亏损、熔断和禁交易状态规划 |
| 9 | 实盘审计 / 事故回放 / 停机控制（Live audit / incident replay / stop controls） | Pending / gated | 需要 signal / order / risk decision / fill 审计、incident replay、紧急停止、停机和恢复规划 |

Latest Completed Project：`MTPRO Market Data Replay Operations v1`

Next Handoff：Human + `@001 / PLN`

本进度条不统计未授权 future capability，不授权下一阶段执行。下一阶段方向、目标、架构路线和优先级仍交给 Human + `@001 / PLN`。

## 产品路线

1. 研究 / 回测 / 报告基础能力：Completed。
2. Paper 模拟执行基础能力：Completed。
3. 工作台证据导航与本地控制壳：Completed。
4. 行情数据回放运营能力：Completed。
5. 实盘交易基础边界：Pending / gated。
6. 实盘监控台：Pending / gated。
7. 实盘执行控制：Pending / gated。
8. 实盘风险控制：Pending / gated。
9. 实盘审计 / 事故回放 / 停机控制：Pending / gated。

## 下一步规则

当前 Project 全部有效 issues `Done` 后，必须按顺序关闭：

```text
Linear Project status Completed
-> Stage Code Audit Report
-> Root Docs Refresh Gate
-> Current Phase Progress Bar
-> Next Human Project Planning
```

`@002 / PAR` 只同步已发生事实；下一阶段方向、目标、架构路线和优先级必须由 Human + `@001 / PLN` 决定。

## 非授权边界

- `ROADMAP.md` 不创建 Linear Project / Issue。
- `ROADMAP.md` 不修改 Linear status。
- `ROADMAP.md` 不启动 symphony-issue。
- `ROADMAP.md` 不运行 Graphify update。
- `ROADMAP.md` 不解锁下一个 issue。
- `ROADMAP.md` 不授权任何 Agent 直接把 issue 改为 `Todo`。
