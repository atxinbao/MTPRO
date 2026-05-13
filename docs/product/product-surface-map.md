# Product Surface Map

本文档定义 MTPRO 第一版产品面。

## 产品定位

MTPRO 第一版是最小 Trader Workstation Dashboard，用于观察和控制研究到 Paper 的闭环。

UI 第一版只做最小观察和操作入口，不追求完整交易终端。

## 信息架构

| 区域 | 目的 | v1 边界 |
| --- | --- | --- |
| Market | 观察 Binance public market data | 只读 |
| Strategy | 查看策略配置和信号 | EMA cross 优先 |
| Backtest | 运行和查看回测结果 | 第一优先级 |
| Paper | 查看 paper execution 状态 | 不触发 live broker action |
| Risk | 查看风险限制和拦截原因 | 只读投影 |
| Portfolio | 查看组合投影 | 只读投影 |
| Events | 查看事件流水和验证证据 | append-only |

## 禁止项

- 不提供 live order button。
- 不提供真实 broker action。
- 不直接展示数据库表结构。
- 不让 UI 直接消费 ORM model 或 runtime object。
