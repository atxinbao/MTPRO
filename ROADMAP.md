# ROADMAP.md

ROADMAP 只定义阶段地图，不授权执行。

正式执行必须来自 Linear live-read 中唯一 configured executable issue，并通过 Parent Codex queue preflight、symphony-issue 和 GitHub PR Automation。

## 阶段地图

| 阶段 | 状态 | 结果 |
| --- | --- | --- |
| MTPRO 引导 | Completed | 根文档、contract-first 文档、SwiftPM baseline、自动化基线 |
| MTPRO Runtime Research Workbench v1 | Completed | Core 拆分、read-only market data boundary、event log / replay、SQLite / DuckDB projection、Dashboard shell、Research -> Backtest -> Report path |
| MTPRO Trading Validation and Parity Hardening | Completed | trading validation matrix、EMA / order book parity、fees / slippage assumptions、risk blocker、portfolio exposure、Report / Dashboard evidence |
| MTPRO Paper Session Runtime v1 | Completed | paper session lifecycle、proposal、risk link、paper-only portfolio projection、replay、report evidence |
| MTPRO Paper Execution Workflow v1 | Completed | paper-only execution workflow、paper order lifecycle、simulated fill、event log replay、Report / Dashboard evidence、Stage Code Audit Report |

Completed Project 的完整证据见 `docs/audit/`。

当前 Project、active issue、Todo / In Progress / In Review 状态必须从 Linear 和 Parent Codex queue preview 实时读取，不写死在仓库文档中。

## Current Phase Progress

Phase：`MTPRO paper-only research / validation / execution foundation`

Completed Projects：5 / 5（100%）

Progress：`[##########] 100%`

Completed Projects 是计算依据，Progress 是视觉展示。本进度条只统计当前已 Human-approved、已执行、已 closure 的建设阶段 Project：

- `MTPRO 引导`
- `MTPRO Runtime Research Workbench v1`
- `MTPRO Trading Validation and Parity Hardening`
- `MTPRO Paper Session Runtime v1`
- `MTPRO Paper Execution Workflow v1`

Latest Completed Project：`MTPRO Paper Execution Workflow v1`

Next Handoff：Human + `@001 / PLN`

本进度条不统计 `docs/design/mtpro-complete-blueprint.md` 中的 Future Construction Zones，不统计未授权 future capability，不授权下一阶段执行。下一阶段方向、目标、架构路线和优先级仍交给 Human + `@001 / PLN`。

## 产品路线

1. Research / Backtest / Report / Paper readiness。
2. Paper-only execution evidence。
3. Paper workflow 可观察性和本地控制壳。
4. 更长周期 market data replay / operations。
5. Live trading 仍保持禁止，除非未来 Human 明确开启新的安全边界和 Project。

## 下一步规则

当前 Project 全部有效 issues `Done` 后，必须按顺序关闭：

```text
Linear Project status Completed
-> Stage Code Audit Report
-> Root Docs Refresh Gate
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
