# 最近验证摘要

日期：2026-05-20

执行者：Codex

## 定位

本文档是 MTPRO 最近验证和当前边界的轻量入口。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。本文档不替代 PR evidence、Linear evidence、Stage Code Audit Report 或完整验证历史。

完整 `verification.md` 只用于审计、追溯和 debug。

## 当前读序

```text
README.md
-> AGENTS.md
-> GOAL.md
-> BLUEPRINT.md
-> docs/environment.md
-> docs/architecture.md
-> docs/roadmap.md
-> docs/domain/context.md
-> docs/validation/latest-verification-summary.md
```

`BLUEPRINT.md` 是 canonical Root / Complete Blueprint，统一承载项目总览和完整产品 / 系统 / 设计蓝图。`docs/domain/context.md` 是 shared language 入口；`docs/automation/agent-engineering-practices.md` 记录从 `mattpocock/skills` 吸收的 Feedback Loop First、TDD / Tracer Bullet、Diagnose Loop、Architecture Deepening Review 和 Handoff Discipline。

## 当前基线

| 项 | 当前事实 |
| --- | --- |
| Project 状态来源 | 必须从 Linear live-read 获取；仓库文档不固定 current issue、current Todo 或 active Project pointer |
| 最近完成 Project | `MTPRO Market Data Replay Operations v1` |
| Planning record | `docs/planning/projects/mtpro-market-data-replay-operations-v1-plan.md` |
| Linear Project status | Linear Project status `Completed`，`type=completed`，`completedAt=2026-05-20T08:23:20Z` |
| Stage Code Audit Report | `docs/audit/mtpro-market-data-replay-operations-v1-stage-code-audit.md`，已覆盖完整 Linear Project |
| Root Docs Refresh Gate | 已 closure；Root Docs Delta 已同步到 `GOAL.md`、`docs/architecture.md`、`docs/roadmap.md`；后续二级文档整理已补强 `docs/environment.md` 和 `docs/architecture.md` |
| Current Foundation Progress | 4 / 4（100%） |
| Final Product Goal Progress | 4 / 9（44%） |

## Goal / Roadmap Progress Baseline

```text
Phase: MTPRO professional trading workstation
Project Closure Count: 7 / 7 (100%)
Current Foundation Progress: 4 / 4 (100%)
Final Product Goal Progress: 4 / 9 (44%)
Foundation Progress: [##########] 100%
Final Product Progress: [####------] 44%
```

Current Foundation 目标切片：

- Complete：Research / Backtest / Report / Paper readiness。
- Complete：Paper-only execution evidence。
- Complete：Paper workflow 可观察性和本地控制壳。
- Complete：更长周期 market data replay / operations。

Final Product 目标切片：

- Complete：研究 / 回测 / 报告基础能力（Research / Backtest / Report foundation）。
- Complete：Paper 模拟执行基础能力（Paper execution foundation）。
- Complete：工作台证据导航与本地控制壳（Workbench evidence navigation and local control shell）。
- Complete：行情数据回放运营能力（Market data replay operations）。
- Pending / gated：实盘交易基础边界（Live trading foundation）。
- Pending / gated：实盘监控台（Live monitoring console）。
- Pending / gated：实盘执行控制（Live execution control）。
- Pending / gated：实盘风险控制（Live risk control）。
- Pending / gated：实盘审计 / 事故回放 / 停机控制（Live audit / incident replay / stop controls）。

Project Closure Count 只说明当前已批准、已执行、已完成 Project closure、已落仓 Stage Code Audit Report、并已完成 Root Docs Refresh Gate closure 的建设阶段 Project 数量，不代表完整产品蓝图或 Future Construction Zones / 未来建设区已经完成。

## Evidence Pointers

已 closure Project：

- `MTPRO 引导`
- `MTPRO Runtime Research Workbench v1`
- `MTPRO Trading Validation and Parity Hardening`
- `MTPRO Paper Session Runtime v1`
- `MTPRO Paper Execution Workflow v1`
- `MTPRO Paper Workflow Control Shell v1`
- `MTPRO Market Data Replay Operations v1`

Stage audit / input 入口：

- `docs/audit/`
- `docs/audit/inputs/`

历史锚点：

- `MTP-30`：Trading Validation and Parity Hardening 阶段收口。
- `MTP-37`：Paper Session Runtime v1 阶段收口。
- `MTP-53`：Paper Workflow Control Shell v1 阶段收口。
- `MTP-60`：Market Data Replay Operations v1 阶段收口。

## 最近验证

本轮 Environment / Architecture Docs Deepening 已完成：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

结果：

- `git diff --check`：pass。
- `bash checks/automation-readiness.sh`：pass。
- `bash checks/run.sh`：pass。
- Dashboard smoke：`sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`。
- XCTest：121 tests, 0 failures。

本轮 docs-only second-tier docs evidence：

- `docs/architecture.md`
- `docs/environment.md`
- `checks/automation-readiness.sh`
- `docs/validation/latest-verification-summary.md`
- `verification.md`

更新重点：

- `docs/environment.md`：补强 Environment Responsibility、Required Validation、Optional Evidence、Platform Boundary、External System Capability Matrix、Secrets / Local State Boundary、Automation Boundary。
- `docs/architecture.md`：补强 Package Dependency Direction、Module Boundary Contracts、Capability Flow Map、Architecture Invariants、Future Live Isolation、Architecture Update Gate。
- `checks/automation-readiness.sh`：加入上述章节锚点，确保二级承接文档不会退化为松散摘要。

## 当前边界

- Root docs、planning record、Backlog issue、label、priority、assignee 都不授权执行。
- Complete Blueprint Design 不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `@002 / PAR`，不启动 Symphony，不写业务代码。
- `BLUEPRINT.md` 可以描述 Future Construction Zones / 未来建设区，但不能把 future capability 变成当前执行 scope；蓝图本体只维护在根目录 `BLUEPRINT.md`。
- `docs/architecture.md`、`docs/environment.md` 和 `docs/roadmap.md` 是二级权重文档，只能承接并细化 `BLUEPRINT.md`，不能推翻蓝图。
- 当前唯一 configured executable issue 必须从 Linear live-read 和 Parent Codex queue preview 获取。
- Paper execution / order / fill / portfolio 语义全部是 paper-only evidence，不代表真实订单、真实成交、broker fill、account state 或 Live fallback。
- Market data replay operations 自动验证只使用本地 fixture / batch replay evidence，不依赖真实 Binance 网络。
- Binance signed endpoint、account endpoint、listenKey、broker action、real order submit / cancel / replace、OMS 和 real account balance 仍禁止。
- 实盘交易基础边界、实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制属于 Final Product Goal 的 Pending / gated 切片。
- Report / Dashboard / Event Timeline 只展示 read model / ViewModel，不提供交易执行入口。

## Known CI Boundary

临时 CI 平台边界：

- Ubuntu runner 对 SQLite / macOS-only SwiftUI / Darwin / DuckDB Swift wrapper 支持曾出现临时失败。
- 后续 PR 已通过 portable module、platform gating 或 macOS 本地验证覆盖修复。
- 当前 main 没有遗留 failing PR run；最终状态以 GitHub required check `checks` 和 `bash checks/run.sh` 为准。

## 下一步

Next Handoff：Human + `@001 / PLN`

下一阶段方向、目标、架构路线和优先级仍由 Human + `@001 / PLN` 决定。本文档不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 Symphony。
