# Validation Plan

本文档定义 MTPRO 当前验证计划。

## 统一入口

```bash
bash checks/run.sh
```

该命令必须串联：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `swift test`

## 当前覆盖

当前测试覆盖：

- Swift-only core。
- paper-only execution mode。
- TradingKernel actor boundary。
- MessageBus monotonic event stream。
- DataEngine read-only market event ingest。
- Cache deterministic replay projection。
- Binance public read-only contract 和 fixture decoding。
- Binance public read-only client boundary、mock transport、fixture parity 和 public stream path 断言。
- EMA cross strategy contract。
- Backtest / Paper signal timeline parity。
- Order book imbalance research contract。
- Event Log replay persistence boundary。
- File-backed append-only event log persistence boundary。
- SQLite runtime projection boundary。
- SQLite runtime projection adapter 最小 rebuild / query snapshot 闭环。
- DuckDB analytical projection boundary。
- DuckDB analytical projection adapter 最小 rebuild / query snapshot 闭环。
- Trader Workstation Dashboard ViewModel contract。
- GitHub workflow / PR evidence / WIP=1 / handoff marker / Graphify 边界。
- Linear issue execution contract。
- `.codex/*` 与 `graphify-out/*` 本地输出排除契约。

## Finance / Trading Validation

策略、market data、Backtest、Paper、risk 或 portfolio 相关 issue 必须补充交易语义验证：

- 策略假设。
- market data 时间粒度和 symbol universe。
- fees / slippage 是否进入当前 scope。
- Backtest / Paper parity 验收方式。
- risk metric 或 risk blocker。
- 不触碰 Live trading、signed endpoint 和真实 broker action。

当前继续使用 XCTest + fixtures 表达交易语义验证，不引入独立 eval 框架。

## Codex / Automation Validation

- Codex use-cases 对齐：`docs/automation/codex-use-cases-alignment.md`。
- Verified operations：`docs/automation/verified-operations.md`。
- Eval 引入策略：`docs/validation/eval-strategy.md`。
- macOS build / run / telemetry 闭环：`docs/validation/macos-build-run-loop.md`。

新增或修改 production code 时，验证前必须检查详细中文注释是否覆盖业务目的、输入输出、领域不变量、外部系统边界和交易能力禁区。

## 后续验证方向

后续按 Linear issue 增加：

- market data replay tests。
- EMA cross backtest tests。
- paper / backtest parity tests。
- risk decision tests。
- persistence projection rebuild tests。
- file event log corruption / recovery tests。
- UI ViewModel snapshot tests。
- macOS App shell build / run / telemetry tests。

## MTP-20 Binance Client Validation

MTP-20 的 required validation：

- 使用 mock transport 覆盖 REST public endpoint request。
- 使用 mock transport 覆盖 public depth stream request path。
- 使用 fixture parity 验证 client decode 结果与 `BinancePublicMarketDataPayloadDecoder` 一致。
- 断言 transport request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- 断言 mutable 或 `requiresAPIKey == true` 的 request contract 在 transport 前被拒绝。
- 断言非 public market data allowlist 的 Binance path 在 transport 前被拒绝。
- required validation 不依赖真实 Binance 网络；真实网络 smoke test 只能作为可选人工证据。

## 禁止

- 不接 Binance signed endpoint。
- 不运行 live execution。
- 不把 eval 框架作为业务实现前置依赖。
- 不把 validation result 当作 Linear 执行授权。
