# MTPRO Paper Trading Runtime Foundation Blueprint v1

日期：2026-05-21

执行者：Codex

## 1. 文档定位

本文定义 paper trading runtime foundation 的产品 / 架构蓝图。它只作为后续 Project Planning 输入，不创建 Project / Issue，不推进 `Todo`，不授权 signed endpoint、account endpoint、broker adapter、LiveExecutionAdapter、OMS、real order 或 Live PRO Console。

## 2. Paper Runtime 目标边界

Paper runtime 的目标是让 Research -> Backtest -> Report -> Paper 共享同一条本地可审计 evidence chain：

```text
Paper Order Intent
-> Paper Pre-trade Risk
-> Paper Lifecycle Coordinator
-> Simulated Fill / Fee / Slippage
-> Paper Account / Portfolio Projection
-> Event Log / Replay / Report / Dashboard
```

## 3. 核心能力地图

| 能力 | 说明 |
| --- | --- |
| Paper Order Lifecycle | 本地 order intent、accepted / rejected / filled / expired / cancelled evidence |
| Local Order Manager | 只管理 paper lifecycle，不连接 broker |
| Simulated Fill | deterministic fill、latency、fee、slippage evidence |
| Paper Account / Portfolio | paper position、cash、PnL、exposure projection |
| Paper Risk | pre-trade reject / allow evidence |
| Replay / Report / Dashboard | 从 Event Log 重建并展示 causal chain |

## 4. Event / Replay Requirements

- Event Log 是 append-only facts source。
- Paper event 必须能 deterministic replay。
- Report / Dashboard 只消费 read model / ViewModel。
- Paper evidence 不得升级为 real command、broker fill、execution report 或 real reconciliation。

## 5. 与 NautilusTrader 的参考映射

MTPRO 学习的是 order lifecycle、simulated execution、portfolio projection 和 report evidence 组织方式；不复制 NautilusTrader runtime，不把 paper lifecycle 与 live lifecycle 合并。

## 6. Potential Next Project Candidate

Potential Next Project Candidate: MTPRO Event-Driven Paper Trading Runtime v1。

候选 scope 只能包含 paper-only runtime kernel、paper pre-trade risk、paper lifecycle coordinator、simulated fill / fee / slippage、paper portfolio projection、Event Log / Replay / Report / Dashboard evidence。

## 7. Repository Record Boundary

本文是 repository planning record，不授权 implementation。正式施工必须来自 Human 确认后的 Project / Issue contract 和 Parent Codex queue preflight。

## 8. 外部参考来源

- NautilusTrader backtesting / execution / portfolio / reports concepts。
- MTPRO root docs、contracts、validation matrix。
