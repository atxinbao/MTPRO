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

## MTP-10 内核契约

日期：2026-05-16

执行者：Codex

`MTPROCore` 在本事项中建立最小 actor 内核边界，用于把只读行情事件转入 cache 和 append-only event stream。

契约结构：

- `MTPROMessageBus`：基于 `AppendOnlyEventLog` 发布 `MTPRODomainEvent`，并按 `EventReplayCommand` 重放。
- `MTPROMarketDataCache`：只接收 `MTPROMarketEvent`，投影 bars、trades、best bid / ask、order book snapshot 和 order book delta。
- `MTPRODataEngine`：把只读 market event 同步写入 cache 和 MessageBus。
- `MTPROTradingKernel`：Swift actor 边界，串行管理 DataEngine、MessageBus 和 Cache。

契约要求：

- 所有 market event 必须来自 `MTPROCore` 已定义的只读行情事件模型。
- MessageBus 必须保持 monotonic sequence。
- Cache 必须能从 replay envelope 确定性重建。
- TradingKernel actor 必须在并发 ingest 时保持事件流和 cache 状态一致。

本契约不包含：

- 策略实现。
- Backtest engine。
- Paper execution engine。
- Live execution。
- 数据库适配器。
- SwiftUI 页面。
- Binance 网络客户端。
