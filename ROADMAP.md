# ROADMAP.md

ROADMAP 只定义推进顺序，不授权执行。

正式执行必须等待 Linear 中唯一 configured executable issue，并按 GitHub PR Automation 验证合并。

后续真实 issue PR 使用已验证的 GitHub PR Automation 链路。

## 阶段

| 阶段 | 名称 | 目标 | 状态 |
| --- | --- | --- | --- |
| 1 | Bootstrap Definition and Build Skeleton | 完成根文档、契约文档和 SwiftPM skeleton | active |
| 2 | Core Domain Model and Event Log Contract | 定义核心事件、命令、状态和 append-only event log contract | planned |
| 3 | Binance Read-only Market Data Adapter | 实现 Binance public read-only market data adapter | planned |
| 4 | TradingKernel / DataEngine / Cache | 建立 actor kernel、message bus、cache 和 data engine | planned |
| 5 | EMA Cross Backtest and Paper Parity | 实现 EMA cross backtest / paper 一致性 | planned |
| 6 | Order Book Imbalance Strategy | 实现 order book imbalance 策略研究链路 | planned |
| 7 | SQLite / DuckDB Projections and Replay | 建立运行投影、分析投影和 replay | planned |
| 8 | Trader Workstation Dashboard | 实现 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events | planned |
| 9 | Validation Hardening and Automation Readiness | 完成验证硬化和自动化 readiness | planned |

## 当前下一步

1. 不在 `ROADMAP.md` 中固定当前唯一 configured executable issue。
2. 执行前必须从 Linear 查询当前 Project 的唯一 Todo / configured executable issue。
3. `MTP-8` 和 `MTP-9` 已通过 symphony-issue + GitHub PR Automation 跑通并进入 `Done`。
4. `MTP-10` 仍保持 `Backlog`；本轮暂不启用 symphony-project continuation，是否推进由 Human 明确决定。

`MTP-10` 到 `MTP-15` 保持 `Backlog`，不得由 Codex 解锁。

## AEP v2 流程对应关系

| AEP 阶段 | MTPRO 状态 | 下一动作 |
| --- | --- | --- |
| 1. Human Project Planning | 已完成 | 不再修改当前 Project 目标，除非 Human 重新规划 |
| 2. symphony-project | 暂不接 continuation | 不自动把下一个 Backlog issue 推进为 Todo |
| 3. symphony-issue | 已验证 | Human 明确设置唯一 Todo 后，可继续调度当前 issue |
| 4. GitHub PR Automation | 已验证 | 继续使用 checks / auto-merge / branch cleanup / Linear bot auto Done |
| 5. Next Human Project Planning | 未进入 | 当前 Project 全部 Done 后再进入 |
