# API Contract

日期：2026-06-14

执行者：Codex

API Contract 必须先于真实 API route 或 runtime command 实现。MTPRO 第一版没有 HTTP API；这里的 API 指 Swift module 内部 stable command / query / event contract。

## 第一版 Command / Query

| Contract | 类型 | 说明 |
| --- | --- | --- |
| `MarketDataQuery` | Query | 查询 read-only market data projection |
| `BacktestCommand` | Command | 请求运行本地回测 |
| `PaperSessionCommand` | Command | 请求启动 paper session |
| `PaperSessionLocalControlCommand` | Command | 请求本地控制 paper session |
| `OrderBookImbalanceResearchCommand` | Command | 请求运行订单簿失衡研究 |
| `RiskEvaluationQuery` | Query | 查询风险判断 |
| `PortfolioQuery` | Query | 查询组合投影 |
| `EventReplayCommand` | Command | 请求 replay event log |

## 统一边界

- 不提供 live order command。
- 不提供 broker account command。
- 不提供 signed endpoint command。
- 不提供 submit / cancel / replace production command。
- 不直接返回 runtime object、database schema、adapter request 或 raw broker payload 给 UI。

## Contract 索引

| 阶段 | Contract | 压缩结论 |
| --- | --- | --- |
| MTP-11 / MTP-25 | Backtest / Paper command + parity | `BacktestCommand` 和 `PaperSessionCommand` 绑定 EMA config 与 `MarketDataQuery`；query range 必须覆盖输入 bars。 |
| MTP-12 | OrderBookImbalance research command | 只授权本地研究链路，不代表可交易命令。 |
| MTP-13 / MTP-17..MTP-21 | Replay / projection / ingest | `EventReplayCommand`、file event log、SQLite / DuckDB projection、Binance public client 和 runtime ingest 只输出 replay / projection facts。 |
| MTP-23 / MTP-27..MTP-29 | Report / cost / risk / exposure | Report artifact、cost evidence、risk blocker、portfolio exposure 只进入 read model。 |
| MTP-31..MTP-36 | Paper lifecycle / proposal / risk / portfolio / replay | Paper-only internal events and value contracts；allowed / blocked 不代表真实风控或订单授权。 |
| MTP-38..MTP-42 | Paper execution workflow | Paper order intent、simulated fill、decision 和 replay projection 不连接 broker、不生成 real order lifecycle。 |
| MTP-47..MTP-51 | Workbench control / observability / evidence explorer | 只允许 session-level local controls 和 read-model-only observation。 |

Machine guard anchors:

- MTP-48 Paper Session Local Control Command Model
- MTP-49 Paper Session Local Control Event Boundary

## Non-goals

- 不新增 HTTP API、database API 或 production command API。
- 不新增 live order command、broker account command、signed endpoint command、order submit / cancel / replace command。
- 不把 proposal、risk decision、paper order intent 或 simulated fill 解释为真实订单、真实成交、broker fill、portfolio mutation 或 execution authorization。
- 不启用 production trading。
