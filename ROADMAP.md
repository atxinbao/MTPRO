# ROADMAP.md

ROADMAP 只定义推进顺序，不授权执行。

正式执行必须等待 Linear 中唯一 configured executable issue，并按 GitHub PR Automation 验证合并。

MTPRO 不创建单独的 test-mode onboarding Project / Issues。第一次真实 issue PR 将用于验证 GitHub PR Automation 链路。

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

1. 以 `MTP-8` 作为当前唯一 configured executable issue。
2. 执行前确认 scope、validation、evidence 和 Graphify context 状态。
3. 创建真实 PR，并用该 PR 验证 GitHub PR Automation。
4. PR merge / Linear bot auto Done 后，再由 Linear Project Automation 判断下一 issue。

`MTP-9` 到 `MTP-15` 保持 `Backlog`，不得由 Codex 解锁。
