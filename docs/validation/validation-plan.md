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
- TradingKernel actor boundary。
- MessageBus monotonic event stream。
- DataEngine read-only market event ingest。
- Cache deterministic replay projection。
- Binance read-only boundary。
- Binance public market data adapter contract。
- Binance public fixture decoding。
- Binance forbidden capability boundary。
- EMA cross strategy contract。
- EMA signal fixture。
- Backtest event flow。
- Paper session event flow。
- Backtest / Paper signal timeline parity。
- Order book snapshot / delta read model input。
- Order book imbalance signal fixture。
- Order book imbalance research event flow。
- Order book imbalance boundary rejection。
- Event Log replay persistence boundary。
- SQLite runtime projection boundary。
- DuckDB analytical projection boundary。
- Persistence projection isolation boundary。
- Top 5 USDT universe。
- `1m` / `5m` timeframe。
- Event Log / SQLite / DuckDB persistence boundary。
- Trader Workstation Dashboard 信息架构。
- Trader Workstation Dashboard ViewModel contract。
- Dashboard read model to ViewModel mapping。
- Dashboard ViewModel state snapshot contract。

## 后续验证

后续必须按阶段增加：

- market data replay tests。
- EMA cross backtest tests。
- paper / backtest parity tests。
- risk decision tests。
- persistence projection rebuild tests。
- UI ViewModel snapshot tests。

## MTP-14 当前验证补充

日期：2026-05-17

执行者：Codex

新增本地 XCTest 覆盖：

- `MTPRODashboardViewModel` 的 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events source contract。
- SQLite runtime projection 和 DuckDB analytical projection 到 Dashboard read model / ViewModel 的字段映射。
- Dashboard ViewModel Codable round-trip 和稳定状态快照。

边界验证：

- ViewModel source contract 明确 `exposesDatabaseTables == false`。
- ViewModel source contract 明确 `exposesORMModels == false`。
- ViewModel source contract 明确 `exposesRuntimeObjects == false`。
- ViewModel source contract 明确 `callsBinanceAdapter == false`。
- ViewModel source contract 明确 `providesLiveOrderAction == false`。

## 当前禁止

当前不接真实 Binance 网络。

当前不写数据库。

当前不运行 live execution。
