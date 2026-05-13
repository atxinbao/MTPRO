# Validation Plan

本文档定义 MTPRO 当前验证计划。

## 当前验证

```bash
swift test
```

当前测试只验证 skeleton 和已确认边界：

- 项目名。
- Swift-only core。
- paper-only execution mode。
- Binance read-only boundary。
- Top 5 USDT universe。
- `1m` / `5m` timeframe。
- Event Log / SQLite / DuckDB persistence boundary。
- Trader Workstation Dashboard 信息架构。

## 后续验证

后续必须按阶段增加：

- Binance adapter contract tests。
- market data replay tests。
- EMA cross backtest tests。
- paper / backtest parity tests。
- risk decision tests。
- persistence projection rebuild tests。
- UI ViewModel snapshot tests。

## 当前禁止

当前不接真实 Binance 网络。

当前不写数据库。

当前不运行 live execution。
