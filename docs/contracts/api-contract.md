# API Contract

API Contract 必须先于真实 API route 或 runtime command 实现。

MTPRO 第一版没有 HTTP API。

这里的 API 指 Swift module 内部的 stable command / query contract。

## 第一版 Command / Query

| Contract | 类型 | 说明 |
| --- | --- | --- |
| MarketDataQuery | Query | 查询 read-only market data projection |
| BacktestCommand | Command | 请求运行回测 |
| PaperSessionCommand | Command | 请求启动 paper session |
| RiskEvaluationQuery | Query | 查询风险判断 |
| PortfolioQuery | Query | 查询组合投影 |
| EventReplayCommand | Command | 请求 replay event log |

## 边界

- 不提供 live order command。
- 不提供 broker account command。
- 不提供 signed endpoint command。
- 不直接返回 runtime object 给 UI。
