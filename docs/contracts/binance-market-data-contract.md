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

真实 adapter 实现必须在 Human Review、Linear Setup 和 Automation Readiness 之后，作为 configured executable issue 执行。
