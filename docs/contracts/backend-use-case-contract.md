# Backend Use Case Contract

日期：2026-06-14

执行者：Codex

Backend Use Case Contract 必须先于 route / controller / runtime implementation。MTPRO 当前没有服务端 API；本文里的 backend 指 Swift module 内部 Core / engine use case。

## 第一版 Use Case

| Use Case | 输入 | 输出 | 状态 |
| --- | --- | --- | --- |
| `LoadMarketData` | symbol / timeframe / date range | market events | planned / evolved through DataClient + DataEngine evidence |
| `RunBacktest` | strategy config / market range | backtest result events | local deterministic |
| `StartPaperSession` | strategy config / risk config | paper session events | paper-only |
| `RunOrderBookImbalanceResearch` | order book config / read model input | research signal events | research-only |
| `EvaluateRisk` | paper proposal | risk decision event | paper / future-gated |
| `ProjectPortfolio` | execution / fill events | portfolio projection | projection-only |
| `ReplayEvents` | event log range | read model rebuild result | append-only replay |

## 统一边界

- Use Case 不得直接返回 runtime object、database schema、adapter request 或 raw broker payload 给前端。
- Use Case 输出必须先进入 Event Log / Projection / Read Model，再供 UI 使用。
- Paper proposal、risk decision、paper order intent、simulated fill 和 portfolio projection 不代表真实订单授权。
- signed endpoint、account endpoint、listenKey、broker gateway、ExecutionClient implementation、OMS、real order lifecycle、Live PRO Console command 和 production trading 必须保持 forbidden / future-gated。

## MTP Use Case 索引

| 阶段 | Use Case / contract | 压缩结论 |
| --- | --- | --- |
| MTP-10 | 内核契约 | `MessageBus`、`MarketDataCache`、`DataEngine`、`TradingKernel` 形成只读 market event -> cache -> append-only stream 的 actor boundary。 |
| MTP-11 / MTP-25 | EMA 回测与 Paper 一致性 | Backtest / Paper 复用 EMA contract；query range 必须覆盖实际 bars，range 过窄必须拒绝。 |
| MTP-12 / MTP-26 | OrderBookImbalance 研究 | 只处理本地 order book read model、snapshot / delta evidence 和 research bias。 |
| MTP-13 / MTP-17..MTP-21 | Persistence / replay / ingest | ReplayEvents、SQLite runtime projection、DuckDB analytical projection、Binance public read-only client、runtime ingest 串联为 deterministic projection boundary。 |
| MTP-23 / MTP-27..MTP-29 | Report / cost / risk / portfolio evidence | Report artifact、fees / slippage、risk blocker、portfolio exposure 只形成只读 validation evidence。 |
| MTP-31..MTP-36 | Paper session lifecycle / proposal / risk / portfolio / replay | Paper-only lifecycle facts、proposal、risk link、portfolio update 和 replay evidence，均不代表真实订单。 |
| MTP-38..MTP-42 | Paper execution workflow | Paper execution contract、order intent、simulated fill、decision、event replay projection 只闭合本地 paper chain。 |
| MTP-47..MTP-49 | Paper Workbench controls | Workbench IA、session local control command model、event boundary 只允许 session-level `start` / `pause` / `close` / `reset`。 |

Machine guard anchors:

- MTP-48 Paper Session Local Control Command Model Use Case 边界
- MTP-49 Paper Session Local Control Event Boundary Use Case 边界

## Non-goals

- 不提供 HTTP API。
- 不新增 live order command。
- 不新增 broker account command。
- 不新增 signed endpoint command。
- 不暴露 ORM / SQL / database table API。
- 不实现 real broker action、real submit / cancel / replace 或 production trading。
