# Binance Market Data Contract

本文档定义 Binance 第一版 read-only market data contract。

## 允许能力

- `exchangeInfo`
- `klines`
- recent trades
- best bid / ask
- limited depth snapshot
- depth delta

## 标的

- `BTCUSDT`
- `ETHUSDT`
- `BNBUSDT`
- `SOLUSDT`
- `XRPUSDT`

## 时间粒度

- `1m`
- `5m`

## 禁止能力

- API key
- signed endpoint
- account endpoint
- order submit
- order cancel
- order replace
- listenKey user data stream
- futures leverage / margin action

## 第一版边界

第一版只做 read-only public market data。

真实 adapter 实现必须作为 Linear 中唯一 configured executable issue 执行，并通过 GitHub PR Automation 验证合并。

## MTP-9 适配器契约

日期：2026-05-16

执行者：Codex

`Adapters` 在本事项中只定义 Binance public market data 的内部 Swift 契约，不建立真实网络客户端。

契约结构：

- `BinancePublicMarketDataCapability`：列举 `exchangeInfo`、`klines`、近期成交、最优买卖价、有限深度快照和深度增量。
- `BinancePublicMarketDataEndpoint`：描述每个 public endpoint / stream 的输入参数。
- `BinancePublicMarketDataContract.request(for:)`：把 endpoint 映射为只读 request contract，包含 transport、path、query items、`isReadOnly` 和 `requiresAPIKey`。
- `BinancePublicMarketDataPayloadDecoder`：只用于把测试夹具或未来 adapter 收到的 public payload 转换为 `Core` market event model。

契约要求：

- 所有 request contract 必须是 read-only。
- 所有 request contract 必须 `requiresAPIKey == false`。
- 只允许 `BTCUSDT`、`ETHUSDT`、`BNBUSDT`、`SOLUSDT`、`XRPUSDT`。
- 只允许 `1m` 和 `5m` kline timeframe。
- `klines` 和 recent trades 的 `limit` 必须在 `1...1000`。
- 深度快照只允许 Binance public depth limit 枚举值。
- fixture decoding 必须复用 `Core` 的 symbol、timeframe、price、quantity 和 order book event 约束。

本契约不包含：

- URLSession 客户端。
- WebSocket 生命周期管理。
- API key、signature、listenKey 或 account payload。
- 订单 submit / cancel / replace。
- 策略、内核、缓存、持久化或 UI 行为。

## MTP-20 公开只读客户端边界

日期：2026-05-18

执行者：Codex

`Adapters` 在本事项中新增 Binance public market data client boundary，用于把既有 endpoint contract
和 fixture decoder 串成可测试的真实网络客户端边界。

契约结构：

- `BinancePublicMarketDataClientConfiguration`：只保存 public REST base URL 和 public WebSocket base URL。
- `BinancePublicTransportRequest`：封装 transport 前的 method、URL、headers 和原始 public request contract；headers 默认为空。
- `BinancePublicMarketDataTransport`：抽象 public payload 读取能力，允许 required validation 使用 mock transport。
- `URLSessionBinancePublicMarketDataTransport`：真实网络边界实现，只接受已校验的 public read-only request。
- `BinancePublicMarketDataClient`：复用 `BinancePublicMarketDataContract.request(for:)` 和
  `BinancePublicMarketDataPayloadDecoder`，提供 exchangeInfo、klines、recent trades、best bid / ask、
  depth snapshot 和 depth delta 的只读读取入口。

契约要求：

- client 发起 transport 前必须重新校验 `isReadOnly == true`。
- client 发起 transport 前必须重新校验 `requiresAPIKey == false`。
- client 发起 transport 前必须校验 path 属于 Binance public market data allowlist。
- transport request 不得携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- REST endpoint 使用 public GET 路径。
- depth delta 只支持 public depth stream 单条 payload 读取边界，不创建 listenKey user data stream。
- required validation 必须使用 mock transport 和 fixture parity，不依赖真实 Binance 网络。

本契约不包含：

- MTP-21 ingest 串联。
- Event Log 写入。
- DataEngine / TradingKernel 接入。
- 真实网络 smoke test 作为 required validation。
- API key、signed endpoint、account endpoint、listenKey user data stream。
- 订单提交、取消、替换。
- futures leverage / margin action。
- LiveExecutionAdapter、真实 broker action 或真实订单行为。
