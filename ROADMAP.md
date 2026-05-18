# ROADMAP.md

ROADMAP 只定义阶段顺序，不授权执行。

正式执行必须等待 Linear 中唯一 configured executable issue，并按 GitHub PR Automation 验证合并。

## 当前基线

已完成的 Linear Project：

- `MTPRO 引导`
- `MTPRO Runtime Research Workbench v1`，Linear issues：`MTP-16` 到 `MTP-23`
- `MTPRO Trading Validation and Parity Hardening`，Linear issues：`MTP-24` 到 `MTP-30`

最近完成的 Project 为 `MTPRO Trading Validation and Parity Hardening`。Parent Codex Stage Code Audit Report 已落仓到 `docs/audit/mtpro-trading-validation-and-parity-hardening-stage-code-audit.md`。

当前无已授权下一阶段 Project；当前无 `Todo` / `In Progress` / `In Review` issue。下一阶段必须由 Human + `@001 / PLN` 重新规划并写入 Linear 后，才可交给 `@002 / PAR` 执行 Project queue preflight。

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

1. Human + `@001 / PLN` 读取最新 Stage Code Audit Report，决定是否进入 Next Human Project Planning。
2. 如果 Human 确认新 Project / Issue plan，先写入 Linear，并保持所有 issue 初始为 `Backlog` 或等价 non-executable 状态。
3. `@002 / PAR` 只能在新 Project 已写入 Linear 后执行 Project / Issue 格式 Gate、active Project pointer 更新和二次 queue preview。
4. gate 全部通过后，`@002 / PAR` 才能在 WIP=1 下推进唯一 eligible issue 到 `Todo`。
5. symphony-issue 只调度唯一 `Todo` issue。

## 非授权边界

- `ROADMAP.md` 不创建 Linear Project / Issue。
- `ROADMAP.md` 不修改 Linear status。
- `ROADMAP.md` 不启动 symphony-issue。
- `ROADMAP.md` 不运行 Graphify update。
- `ROADMAP.md` 不解锁下一个 issue。
- `ROADMAP.md` 不授权任何 Agent 直接把 issue 改为 `Todo`。
