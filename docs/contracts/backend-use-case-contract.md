# Backend Use Case Contract

Backend Use Case Contract 必须先于 route / controller / runtime implementation。

MTPRO 当前没有服务端 API；这里的 backend 指 Core runtime use case。

## 第一版 Use Case

| Use Case | 输入 | 输出 | 状态 |
| --- | --- | --- | --- |
| LoadMarketData | symbol / timeframe / date range | market events | planned |
| RunBacktest | strategy config / market data range | backtest result events | planned |
| StartPaperSession | strategy config / risk config | paper session events | planned |
| EvaluateRisk | proposed paper order | risk decision event | planned |
| ProjectPortfolio | execution / fill events | portfolio projection | planned |
| ReplayEvents | event log range | read model rebuild result | planned |

## 边界

Use Case 不得直接返回内部 runtime object 给前端。

Use Case 输出必须先进入 read model projection，再供 UI 使用。
