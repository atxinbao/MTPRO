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

`MTPROAdapters` 在本事项中只定义 Binance public market data 的内部 Swift 契约，不建立真实网络客户端。

契约结构：

- `BinancePublicMarketDataCapability`：列举 `exchangeInfo`、`klines`、近期成交、最优买卖价、有限深度快照和深度增量。
- `BinancePublicMarketDataEndpoint`：描述每个 public endpoint / stream 的输入参数。
- `BinancePublicMarketDataContract.request(for:)`：把 endpoint 映射为只读 request contract，包含 transport、path、query items、`isReadOnly` 和 `requiresAPIKey`。
- `BinancePublicMarketDataPayloadDecoder`：只用于把测试夹具或未来 adapter 收到的 public payload 转换为 `MTPROCore` market event model。

契约要求：

- 所有 request contract 必须是 read-only。
- 所有 request contract 必须 `requiresAPIKey == false`。
- 只允许 `BTCUSDT`、`ETHUSDT`、`BNBUSDT`、`SOLUSDT`、`XRPUSDT`。
- 只允许 `1m` 和 `5m` kline timeframe。
- `klines` 和 recent trades 的 `limit` 必须在 `1...1000`。
- 深度快照只允许 Binance public depth limit 枚举值。
- fixture decoding 必须复用 `MTPROCore` 的 symbol、timeframe、price、quantity 和 order book event 约束。

本契约不包含：

- URLSession 客户端。
- WebSocket 生命周期管理。
- API key、signature、listenKey 或 account payload。
- 订单 submit / cancel / replace。
- 策略、内核、缓存、持久化或 UI 行为。
