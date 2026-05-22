# docs/roadmap.md

本文档是 Construction Plan / 施工路线。它是 `BLUEPRINT.md` 的二级权重承接文档，根据蓝图和工程模块定义施工顺序、进度和下一阶段 handoff。

ROADMAP 只定义阶段地图，不授权执行。正式执行必须来自 Linear live-read 中唯一 configured executable issue，并通过 Parent Codex queue preflight、symphony-issue 和 GitHub PR Automation。

完整产品终局和 Future Construction Zones / 未来建设区见 `BLUEPRINT.md`；工程模块细节见 `docs/architecture.md`。

## Roadmap Responsibility / 路线职责

`docs/roadmap.md` 只回答四个问题：

1. 已完成哪些建设阶段。
2. 当前目标切片完成到哪里。
3. 下一轮 planning 应该从哪些未完成切片里选择。
4. Project closure 后如何反写进度和 handoff。

它不定义最终产品终局，不定义工程模块细节，不授权执行。

## Roadmap Inputs / 路线输入

路线更新必须按以下输入顺序读取：

```text
GOAL.md
-> BLUEPRINT.md
-> docs/architecture.md
-> docs/audit/<project-stage-code-audit>.md
-> docs/validation/latest-verification-summary.md
-> Linear Project live state
```

输入解释：

- `GOAL.md` 提供目标切片和硬边界。
- `BLUEPRINT.md` 提供完整产品终局、Current / Future 分界和 Live gates。
- `docs/architecture.md` 提供工程模块地图和模块依赖方向。
- `docs/audit/` 提供已完成 Project 的事实证据。
- `docs/validation/latest-verification-summary.md` 提供最近验证和当前边界。
- Linear live-read 只用于确认 Project / issue 当前状态，不写死到本文档中。

## Completed Project Map / 已完成阶段地图

| 阶段 | 状态 | 结果 |
| --- | --- | --- |
| MTPRO 引导 | Completed | 根文档、contract-first 文档、SwiftPM baseline、自动化基线 |
| MTPRO Runtime Research Workbench v1 | Completed | Core 拆分、read-only market data boundary、event log / replay、SQLite / DuckDB projection、Dashboard shell、Research -> Backtest -> Report path |
| MTPRO Trading Validation and Parity Hardening | Completed | trading validation matrix、EMA / order book parity、fees / slippage assumptions、risk blocker、portfolio exposure、Report / Dashboard evidence |
| MTPRO Paper Session Runtime v1 | Completed | paper session lifecycle、proposal、risk link、paper-only portfolio projection、replay、report evidence |
| MTPRO Paper Execution Workflow v1 | Completed | paper-only execution workflow、paper order lifecycle、simulated fill、event log replay、Report / Dashboard evidence、Stage Code Audit Report |
| MTPRO Paper Workflow Control Shell v1 | Completed | Paper workflow Workbench information architecture、session-level local controls、observability、Event Timeline / Evidence Explorer preview、Dashboard / Workbench shell evidence、Stage Code Audit Report |
| MTPRO Market Data Replay Operations v1 | Completed | public read-only batch / replay boundary、local replay metadata、retention / freshness evidence、fixture parity、event log / projection consistency、Report / Dashboard / Event Timeline evidence、Stage Code Audit Report |
| MTPRO Live Trading Boundary Definition v1 | Completed | Live trading foundation taxonomy、credential endpoint boundary、adapter capability isolation、real order lifecycle terminology、`LiveReadiness` / `LiveBlockedEvidence` blocked read model、Dashboard / Report / Event Timeline blocked evidence surface、Stage Code Audit Report |
| MTPRO Live Monitoring Console v1 | Completed | Live monitoring console information architecture、runtime health / connection read model、market / order stream blocked evidence、latency / error / degraded evidence、Dashboard / Report / Event Timeline read-model-only evidence surface、Stage Code Audit Report |
| MTPRO Live Execution Control Contract v1 | Completed | Live execution control terminology、submit / cancel / replace future gates、execution report / broker fill / reconciliation future gates、paper / real command isolation、read-model-only blocked evidence、Dashboard / Report / Event Timeline blocked evidence surface、Stage Code Audit Report |

Completed Project 的完整证据见 `docs/audit/`。当前 Project、active issue、Todo / In Progress / In Review 状态必须从 Linear 和 Parent Codex queue preview 实时读取，不写死在仓库文档中。

## Progress Model / 进度模型

MTPRO 采用两层进度口径：

1. Current Foundation Progress：当前已批准 paper-only foundation 的完成度。
2. Final Product Goal Progress：最终专业交易工作台产品目标的完成度。

Project Closure Count 只说明当前已批准、已执行、已 closure 的建设阶段 Project 数量，不代表完整产品蓝图或 Future Construction Zones / 未来建设区已经完成。

```text
Phase: MTPRO professional trading workstation
Project Closure Count: 11 / 11 (100%)
Current Foundation Progress: 4 / 4 (100%)
Final Product Goal Progress: 8 / 9 (89%)
Foundation Progress: [##########] 100%
Final Product Progress: [#########-] 89%
```

Current Foundation Progress 基于 `GOAL.md` 的当前 foundation 目标切片计算：

| Foundation 目标切片 | 状态 | 证据 |
| --- | --- | --- |
| Research / Backtest / Report / Paper readiness | Complete | Runtime Research Workbench、Trading Validation、Paper Session Runtime 已完成 |
| Paper-only execution evidence | Complete | Paper Execution Workflow v1 已完成 |
| Paper workflow 可观察性和本地控制壳 | Complete | Paper Workflow Control Shell v1 已完成 |
| 更长周期 market data replay / operations | Complete | Market Data Replay Operations v1 已完成 |

Final Product Goal Progress 基于 `GOAL.md` 的完整产品目标切片计算：

| # | 最终产品目标切片 | 状态 | 证据 / 下一步 |
| --- | --- | --- | --- |
| 1 | 研究 / 回测 / 报告基础能力（Research / Backtest / Report foundation） | Complete | Runtime Research Workbench、Trading Validation 和 Report evidence 已完成 |
| 2 | Paper 模拟执行基础能力（Paper execution foundation） | Complete | Paper Session Runtime 和 Paper Execution Workflow 已完成 |
| 3 | 工作台证据导航与本地控制壳（Workbench evidence navigation and local control shell） | Complete | Paper Workflow Control Shell v1 已完成 |
| 4 | 行情数据回放运营能力（Market data replay operations） | Complete | Market Data Replay Operations v1 已完成 |
| 5 | 实盘交易基础边界（Live trading foundation） | Complete | Live Trading Boundary Definition v1 已完成 boundary taxonomy、credential endpoint boundary、adapter isolation、real order lifecycle terminology、blocked evidence 和只读展示面；真实 Live trading、signed endpoint、broker adapter 和 real order lifecycle 仍未实现 |
| 6 | 实盘监控台（Live monitoring console） | Complete / read-model-only evidence surface | Live Monitoring Console v1 已完成 information architecture、runtime health / connection read model、market / order stream blocked evidence、latency / error / degraded evidence、Dashboard / Report / Event Timeline evidence surface；真实 live runtime、signed/account stream、broker stream 和交易控制仍未实现 |
| 7 | 实盘执行控制（Live execution control） | Complete / contract + blocked evidence | Live Execution Control Contract v1 已完成 terminology、submit / cancel / replace future gates、execution report / broker fill / reconciliation future gates、paper / real command isolation、read-model-only blocked evidence、Dashboard / Report / Event Timeline evidence surface；真实 execution runtime、真实 submit / cancel / replace、broker fill、execution report 和 reconciliation 仍未实现 |
| 8 | 实盘风险控制（Live risk control） | Complete / contract + blocked evidence | Live Risk Gate Contract v1 已完成 risk terminology、exposure / notional / frequency / loss / drawdown / circuit breaker / no-trade future gates、paper / live risk isolation、read-model-only blocked evidence 和 Dashboard / Report / Event Timeline evidence surface；真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command 和 emergency stop 仍未实现 |
| 9 | 实盘审计 / 事故回放 / 停机控制（Live audit / incident replay / stop controls） | Pending / gated | 需要 signal / order / risk decision / fill 审计、incident replay、紧急停止、停机和恢复规划 |

Latest Completed Project：`MTPRO Live Risk Gate Contract v1`

Next Handoff：Human + `@001 / PLN`

本进度条不统计未授权 future capability，不授权下一阶段执行。下一阶段方向、目标、架构路线和优先级仍交给 Human + `@001 / PLN`。

## Product Route / 产品路线

1. 研究 / 回测 / 报告基础能力：Completed。
2. Paper 模拟执行基础能力：Completed。
3. 工作台证据导航与本地控制壳：Completed。
4. 行情数据回放运营能力：Completed。
5. 实盘交易基础边界：Completed；仅完成基础边界、阻断证据和只读展示面，不实现真实 Live trading。
6. 实盘监控台：Completed；仅完成 read-model-only monitoring evidence surface，不实现真实 live runtime、signed/account stream、broker stream 或交易控制。
7. 实盘执行控制：Completed / contract + blocked evidence；不实现真实 execution runtime、真实订单命令、broker fill、execution report 或 reconciliation。
8. 实盘风险控制：Completed / contract + blocked evidence；不实现真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command 或 emergency stop。
9. 实盘审计 / 事故回放 / 停机控制：Pending / gated。

## Construction Slice Selection / 施工切片选择

下一阶段 planning 只能从 `BLUEPRINT.md` 的 Future Construction Zones / 未来建设区中选择一个清晰切片，并把它收敛为 Project Planning Record。选择切片时必须满足：

- 能对应 `GOAL.md` 的某个 Final Product Goal Slice。
- 能落到 `docs/architecture.md` 中可解释的工程模块或模块边界。
- 能被拆成 WIP=1 的 Linear issue queue。
- 能用 deterministic validation、PR evidence、Stage Code Audit 和 Root Docs Refresh 收口。
- 不把多个 future capability 一次性打包成模糊大 Project。

当前自然候选顺序：

```text
实盘监控台
-> 实盘执行控制
-> 实盘风险控制
-> 实盘审计 / 事故回放 / 停机控制
```

其中实盘监控台、实盘执行控制和实盘风险控制已完成各自的 read-model-only / contract + blocked evidence 切片。该顺序不是执行授权。Human + `@001 / PLN` 可以基于最新 Stage Audit、风险和产品优先级调整。

## Live Route Gates / 实盘路线门槛

实盘相关目标切片必须按门槛推进，不能从 paper-only foundation 直接跳到真实订单：

| 目标切片 | 进入前置 | 当前状态 |
| --- | --- | --- |
| 实盘交易基础边界 | Human 独立决策、独立 Project Definition、secret / signed endpoint / account endpoint / broker adapter / real order lifecycle gates | Complete：已定义 foundation taxonomy、credential endpoint boundary、adapter isolation、real order lifecycle terminology、blocked evidence 和只读 evidence surface；未实现真实 Live trading |
| 实盘监控台 | 已定义 live runtime health、connection、market stream、order stream、error、latency 和 operations evidence | Complete / read-model-only evidence surface：已完成 health、connection、stream、latency、error evidence 展示面；真实 live runtime、signed/account stream、broker stream 和交易控制仍未实现 |
| 实盘执行控制 | 已定义 real order submit / cancel / replace、execution report、reconciliation 和 incident fallback | Complete / contract + blocked evidence；真实 execution runtime、真实订单命令、broker fill、execution report 和 reconciliation 仍 gated |
| 实盘风险控制 | 已定义 live pre-trade risk、exposure / order notional / frequency / loss / drawdown / circuit breaker / no-trade gates 和 read-model-only blocked evidence | Complete / contract + blocked evidence；真实 live risk engine、真实账户风控、real pre-trade allow / reject runtime、risk command、stop command 和 emergency stop 仍 gated |
| 实盘审计 / 事故回放 / 停机控制 | 已定义 live event chain、audit trail、incident replay、shutdown / restore policy | Pending / gated |

任何缺少对应 gate 的变更只能停留在蓝图或 planning 草案中，不能进入 Linear execution。

## Project Closure Rule / Project 收口规则

当前 Project 全部有效 issues `Done` 后，必须按顺序关闭：

```text
Linear Project status Completed
-> Stage Code Audit Report
-> Root Docs Refresh Gate
-> Current Phase Progress Bar
-> Next Human Project Planning
```

`@002 / PAR` 只同步已发生事实；下一阶段方向、目标、架构路线和优先级必须由 Human + `@001 / PLN` 决定。

Project closure 后，`docs/roadmap.md` 只更新这些事实：

- Project 是否 Completed。
- Stage Code Audit Report 路径。
- Root Docs Refresh Gate 是否 closure。
- Project Closure Count。
- Current Foundation Progress。
- Final Product Goal Progress。
- Next Handoff。

不把 child issue 细节、PR 流水账或临时 CI 失败详情写入本文档；这些进入 `docs/audit/`、`docs/validation/` 或 `verification.md`。

## Next Handoff Contract / 下一轮交接合同

下一轮交给 Human + `@001 / PLN` 时，必须带上：

- 当前 Final Product Goal Progress。
- 当前 pending / gated 目标切片。
- 最近 Stage Code Audit Report。
- Root Docs Refresh Gate closure 结果。
- 不能触碰的禁止能力。
- 候选 Project 方向，但不创建 Linear Project / Issue。

`@001 / PLN` 输出 Project / Issue draft 后，也仍然不授权执行。只有 Human review / merge、Linear 写入、`@002 / PAR` startup gate 和 queue preflight 全部完成后，唯一 eligible issue 才能进入 `Todo`。

## 非授权边界

- `docs/roadmap.md` 不创建 Linear Project / Issue。
- `docs/roadmap.md` 不修改 Linear status。
- `docs/roadmap.md` 不启动 symphony-issue。
- `docs/roadmap.md` 不运行 Graphify update。
- `docs/roadmap.md` 不解锁下一个 issue。
- `docs/roadmap.md` 不授权任何 Agent 直接把 issue 改为 `Todo`。
