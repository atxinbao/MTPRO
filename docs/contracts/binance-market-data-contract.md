# Binance Market Data Contract

日期：2026-05-17

执行者：Codex

## 允许能力

- Binance public read-only market data。
- Spot / USDⓈ-M Perpetual 的 public data 读取和本地 replay evidence。
- `1m` / `5m` 等 release-gated timeframe。
- deterministic batch、fixture parity、event log、projection consistency、Dashboard / Report / Event Timeline read model。

## 标的和时间粒度

| 维度 | 当前边界 |
| --- | --- |
| Venue | Binance-only |
| Product | spot、USDⓈ-M perpetual，按 release gate 激活 |
| Symbols | release / issue contract 指定的 symbol set |
| Timeframe | `1m`、`5m` 等 explicit scope |

## 禁止能力

- signed endpoint。
- account endpoint / listenKey。
- private WebSocket。
- broker / exchange trading action。
- real order lifecycle。
- submit / cancel / replace。
- execution report / broker fill。
- LiveExecutionAdapter。
- production endpoint auto-connect。

## Issue Boundary Table

| Issue anchor | 压缩契约 |
| --- | --- |
| MTP-9 适配器契约 | Binance adapter 只做 public read-only market data，不保存 secret，不触发交易动作 |
| MTP-20 公开只读客户端边界 | `BinancePublicMarketDataClient` 只读取公开行情，禁止 signed / account / listenKey |
| MTP-21 Runtime Ingest 串联边界 | Runtime ingest 只把 public data 转成 local event / projection input |
| MTP-54 Market Data Batch / Replay 边界 | batch / replay 只处理本地可重放 market data，不接 production data platform |
| MTP-55 Market Data Replay Metadata / Batch Replay Contract | replay metadata 必须记录 source、symbol、timeframe、range、freshness 和 batch identity |
| MTP-56 Market Data Replay Retention / Freshness Evidence | retention / freshness 只输出 evidence，不自动补数据或接真实账户 |
| MTP-57 Market Data Replay Fixture Parity / Replay Consistency | fixture parity 必须 deterministic，replay consistency 不依赖网络 side effect |
| MTP-58 Market Data Replay Event Log / Projection Consistency | Event Log 是 facts source，projection 可由 replay deterministic rebuild |
| MTP-59 Market Data Replay Operations Report / Dashboard / Event Timeline Evidence | Report / Dashboard / Event Timeline 只消费 read model，不直接读取 adapter payload |
| MTP-63 Public Read-only Adapter Capability Isolation | public adapter 与 future live adapter capability 隔离 |
| MTP-64 Public Read-only Adapter / Real Order Lifecycle 禁止边界 | public market data adapter 不得升级为 real order lifecycle 或 trading action |

## Validation Contract

- public read-only fixture / live-like evidence 必须可离线复核。
- replay / projection / dashboard evidence 必须保留 source identity 和 freshness。
- 所有 private / signed / trading 能力必须有 forbidden capability test 或 readiness guard。
