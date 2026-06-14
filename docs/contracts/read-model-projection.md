# Read Model Projection

日期：2026-06-14

执行者：Codex

Read Model Projection 是 UI 的稳定输入层。它把 Event Log、Replay、SQLite runtime projection、DuckDB analytical projection 和 deterministic fixture evidence 收敛为 ViewModel 可消费的只读结构；前端不得直接读取 database schema、ORM model、runtime object、adapter request 或 raw broker payload。

## 第一版 Projection

| Projection | 来源 | 消费者 |
| --- | --- | --- |
| `MarketReadModel` | market events / DuckDB projection | `MarketViewModel` |
| `StrategyReadModel` | signal events | `StrategyViewModel` |
| `BacktestReadModel` | backtest result events | `BacktestViewModel` |
| `ReportReadModel` | projection snapshots / event timeline | `ReportViewModel` |
| `PaperReadModel` | paper execution events | `PaperViewModel` |
| `RiskReadModel` | risk decision events | `RiskViewModel` |
| `PortfolioReadModel` | portfolio events | `PortfolioViewModel` |
| `EventTimelineReadModel` | append-only event log | `EventLogViewModel` |

## 统一边界

- Read Model 可以引用 projection 结果，不能暴露 SQLite / DuckDB schema。
- ViewModel 只能消费稳定 Read Model，不能直接读 Event Log、Persistence adapter、Runtime object 或 exchange adapter。
- Paper evidence、paper order intent、simulated fill、risk blocker 和 portfolio projection 都不能升级为真实订单、真实成交、broker fill、account update 或 Live execution。
- Live / command / broker / signed endpoint / account endpoint / listenKey / real order lifecycle 只能作为 blocked 或 future-gated evidence 出现。

## 观察面索引

| 阶段 | Read Model 关注点 | 当前结论 |
| --- | --- | --- |
| MTP-11 | EMA backtest / paper parity signal timeline | 本地 signal timeline，只读一致性观察面 |
| MTP-12 / MTP-26 | OrderBookImbalance snapshot / delta evidence | research bias，不映射 short / margin / broker action |
| MTP-13 / MTP-18 / MTP-19 / MTP-21 | SQLite / DuckDB / runtime ingest projection | projection adapter evidence，不暴露 schema |
| MTP-14 / MTP-22 / MTP-23 | Dashboard shell、Report、read model projection | Dashboard 只消费 ViewModel |
| MTP-27 / MTP-28 / MTP-29 | cost / slippage、risk blocker、portfolio exposure、trading validation summary | deterministic evidence，不授权交易 |
| MTP-31..MTP-36 | Paper session lifecycle、proposal、risk link、portfolio update、replay、runtime report | paper-only evidence chain |
| MTP-38..MTP-44 | Paper execution workflow、order intent、simulated fill、decision、replay projection、report | decision -> order -> simulated fill -> portfolio projection 只读链路 |
| MTP-47 / MTP-50 / MTP-51 | Paper Workflow Workbench IA、observability、Event Timeline / Evidence Explorer | read-model-only aggregation，不新增 command |
| MTP-58 | Market Data Replay Projection Consistency | event log / projection consistency evidence |

## 可观察字段族

| 字段族 | 示例 |
| --- | --- |
| Identity | strategyID、symbol、timeframe、sessionID、proposalID、decisionID、paperOrderID、simulatedFillID |
| Time / sequence | generatedAt、proposedAt、evaluatedAt、recordedAt、sourceSequence、replay sequence |
| Market / strategy | close、shortEMA、longEMA、inputSource、bidNotional、askNotional、imbalanceRatio、bias |
| Paper lifecycle | session state、paper-only side、executionMode、executionAuthorization、paper-only boundary flag |
| Risk / portfolio | decision status、blocker reason、portfolio update ID、gross exposure notional、exposure symbols |
| Report / dashboard | evidence count、parity status、coverage flags、artifact IDs、read-only summary |

## Non-goals

- 不定义新的 persistence schema。
- 不新增 SwiftUI command surface。
- 不读取真实账户、真实仓位、margin、leverage、PnL 或 broker state。
- 不调用 signed endpoint、account endpoint、listenKey、ExecutionClient、broker gateway 或 production endpoint。
- 不提交、取消或替换真实订单。
