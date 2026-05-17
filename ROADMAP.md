# ROADMAP.md

ROADMAP 只定义阶段顺序，不授权执行。

正式执行必须等待 Linear 中唯一 configured executable issue，并按 GitHub PR Automation 验证合并。

## 当前基线

`MTPRO 引导` Project 已完成。Human 已确认下一阶段 Project：

- Linear Project：`MTPRO Runtime Research Workbench v1`
- Linear issues：`MTP-16` 到 `MTP-23`
- Project / Issue 描述必须在第一个 `Todo` 前统一为 Codex Execution Agent 执行合同格式，并由父 Codex 做只读核对。
- 当前无 `Todo` issue；`MTP-16` 是 first executable candidate，但仍为 `Backlog`。

仓库文档不得把某个 Linear issue 永久写成 current issue；执行前必须从 Linear / Parent Codex queue preview 读取当前 Project 的唯一 active configured executable issue。

## 阶段顺序

| 顺序 | 阶段 | 目标 |
| --- | --- | --- |
| 1 | Bootstrap Definition and Build Skeleton | 完成根文档、契约文档和 SwiftPM baseline |
| 2 | Core Domain Model and Event Log Contract | 定义核心事件、命令、状态和 append-only event log contract |
| 3 | Binance Read-only Market Data Adapter | 实现 Binance public read-only market data adapter |
| 4 | TradingKernel / DataEngine / Cache | 建立 actor kernel、message bus、cache 和 data engine |
| 5 | EMA Cross Backtest and Paper Parity | 实现 EMA cross backtest / paper 一致性 |
| 6 | Order Book Imbalance Strategy | 实现 order book imbalance 策略研究链路 |
| 7 | SQLite / DuckDB Projections and Replay | 建立运行投影、分析投影和 replay |
| 8 | Trader Workstation Dashboard | 实现 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events |
| 9 | Validation Hardening and Automation Readiness | 完成验证硬化和自动化 readiness |

## 下一步

1. 统一 Linear Project / Issue 描述格式，确认 issue execution contract 完整。
2. 父 Codex 做只读 queue preview，确认 `MTP-16` 仍为 first executable candidate、其他 issue 仍为 `Backlog` 且 WIP=1。
3. 只有 Human 明确授权后，父 Codex 才可将 `MTP-16` 推进为唯一 `Todo`。
4. symphony-issue 只调度唯一 `Todo` issue。

## 非授权边界

- `ROADMAP.md` 不创建 Linear Project / Issue。
- `ROADMAP.md` 不修改 Linear status。
- `ROADMAP.md` 不启动 symphony-issue。
- `ROADMAP.md` 不运行 Graphify update。
- `ROADMAP.md` 不解锁下一个 issue。
- `ROADMAP.md` 不授权任何 Agent 直接把 issue 改为 `Todo`。
