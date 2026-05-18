# Validation Plan

本文档定义 MTPRO 当前验证计划。

## 统一入口

```bash
bash checks/run.sh
```

该命令必须串联：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- macOS 本地：`swift build --product MTPRODashboard`
- macOS 本地：`MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard`
- Linux CI：跳过 macOS-only SwiftUI shell build / smoke，并继续运行 SwiftPM tests
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
- Runtime market data ingest -> event log -> replay -> projection snapshots 端到端链路。
- Trader Workstation Dashboard ViewModel contract。
- Trader Workstation Dashboard macOS shell、ViewModel snapshot binding 和 smoke run。
- Research -> Backtest -> Report 最小路径、report artifact / read model 和 Dashboard Report 快照。
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

交易验证矩阵入口：`docs/validation/trading-validation-matrix.md`。

该矩阵记录 EMA parity、order book imbalance parity、fees / slippage、risk blocker、portfolio exposure 和 report evidence 的现有 coverage、验收证据边界和后续 issue 回填规则。

## MTP-24 Trading Validation Matrix Validation

MTP-24 的 required validation：

- `docs/validation/trading-validation-matrix.md` 必须存在。
- Matrix 必须包含 EMA parity、order book imbalance parity、fees / slippage、risk blocker、portfolio exposure、report evidence 和 future issue backfill 的稳定锚点。
- Matrix 必须记录现有 XCTest / fixture coverage 入口。
- Matrix 必须明确 MTP-25 至 MTP-30 如何回填 evidence。
- `checks/automation-readiness.sh` 必须在 matrix 文件或 required anchors 缺失时失败。

## MTP-25 EMA Backtest / Paper Parity Validation

MTP-25 的 required validation：

- EMA Backtest / Paper parity 必须使用 deterministic fixture，不依赖真实 Binance 网络。
- 测试必须覆盖同一 `EMACrossStrategyConfiguration`、同一 `MarketDataQuery`、同一 symbol、同一 timeframe。
- 测试必须锁定 long EMA warm-up 后的首个 signal timestamp、完整 signal direction timeline 和 Backtest / Paper signalSamples 等价。
- Backtest / Paper event flow 必须拒绝超出 `MarketDataQuery.range` 的 bars，避免使用查询窗口外数据生成 parity 假阳性。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-EMA-PARITY` 必须回填新增测试、edge case 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不接 signed endpoint、broker action 或真实订单行为。

## MTP-26 Order Book Imbalance Parity Validation

MTP-26 的 required validation：

- `OrderBookImbalanceSignalSample` 必须记录 snapshot / delta input source，作为 bias evidence 的一部分。
- Core deterministic tests 必须覆盖 bidDominant、neutral、askDominant、depth、bid / ask notional、imbalance ratio、source timestamp、signal direction 和 input source。
- Core parity evidence 必须比较直接 `OrderBookImbalanceStrategyContract` 与 `OrderBookImbalanceResearchEventFlow` 的 signal samples。
- ask dominance 必须保持 research-only：bias 可为 `askDominant`，signal direction 必须仍为 `.flat`，不得引入 short、margin、futures leverage 或真实订单动作。
- Persistence / DuckDB analytical projection 必须保留 order book input source，且仍只输出稳定 read model snapshot，不暴露 schema 或 adapter internals。
- required validation 不依赖真实 Binance 网络、不读取 secret、不连接 broker、不触发真实交易行为。

## MTP-27 Fees / Slippage Validation

MTP-27 的 required validation：

- fees / slippage assumptions 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker 或交易所账户等级。
- Core 测试必须覆盖 maker fee、taker fee、fixed slippage、gross notional、total cost 和统一 rounding scale。
- Backtest / Paper cost evidence 必须在同一 assumption、同一 symbol / timeframe、同一 reference price、同一 quantity 和同一 liquidity role 下保持一致。
- 无效 assumptions 必须被拒绝，包括负数 bps、非有限 bps 或超出允许范围的 rounding scale。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-FEES-SLIPPAGE` 必须回填新增 Core 类型、测试、fixture 和 PR evidence 边界。
- required validation 不引入完整费用模型、不引入交易所费率表、不引入动态滑点模型、不做执行成本优化、不触发 Paper / Live 执行。

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

## MTP-21 Runtime Ingest Validation

MTP-21 的 required validation：

- 使用 mock transport 覆盖 Binance public REST / public depth stream request。
- 使用 fixture parity 验证 workflow ingest events 与 `BinancePublicMarketDataPayloadDecoder` 输出一致。
- 验证 event log sequence 从 1 开始连续递增。
- 验证 replay result 与写入 envelopes 一致，且 market cache projection deterministic。
- 验证 DuckDB analytical snapshot 来自 replay，并包含 market bars、trades、best bid / ask、order book snapshot 和 delta。
- 验证 SQLite runtime snapshot 在 market-only ingest 下保持稳定空 snapshot，且仍由 replay 驱动。
- 断言 request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- required validation 不依赖真实 Binance 网络；真实网络 smoke test 只能作为可选人工证据。

## MTP-22 macOS Dashboard Shell Validation

MTP-22 的 required validation：

- 使用 SwiftUI shell 绑定 `DashboardViewModel` snapshot。
- 验证 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 七个只读区域都来自 ViewModel / Read Model。
- 验证 shell source 不导入 Runtime / Adapters，也不直接引用数据库实现名或 public market data client 类型。
- 验证 `swift build --product MTPRODashboard` 可构建 macOS 看板入口。
- 验证 `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` 可输出 read-model-only smoke summary 并退出。
- 验证 Linux CI 可通过非 SwiftUI fallback 编译 App target、executable target 和 AppTests；真实 SwiftUI shell 只在 macOS 本地构建。
- required validation 不接真实网络、不读取 secret、不连接 broker、不触发真实交易行为。

## MTP-23 Research -> Backtest -> Report Validation

MTP-23 的 required validation：

- 验证 `ReportReadModel` 只能从 projection snapshots / read model 和 append-only event timeline 生成。
- 验证 report artifact 绑定 backtest run、research run、Paper session、event count 和 last applied sequence。
- 验证 projection-level Backtest / Paper parity evidence 保持一致，同时不替代 Core 层完整时间线 parity 测试。
- 验证 Dashboard shell 呈现 Report 快照，且 shell 不导入 Runtime / Adapters、不引用数据库实现名、不调用行情 adapter。
- 验证缺失 Paper projection 时报告标记为 missing paper projection，不回退到 Live、broker、signed endpoint 或真实订单路径。
- 验证 Issue 8 只准备阶段证据材料；Stage Code Audit Report 仍须在 Project 全部 Done 后由父 Codex 单独输出。
- required validation 不接真实网络、不读取 secret、不连接 broker、不触发真实交易行为。

## 禁止

- 不接 Binance signed endpoint。
- 不运行 live execution。
- 不把 eval 框架作为业务实现前置依赖。
- 不把 validation result 当作 Linear 执行授权。
