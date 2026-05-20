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

## MTP-21 Runtime Ingest 串联边界

日期：2026-05-18

执行者：Codex

MTP-21 通过 `Runtime` 模块消费 `BinancePublicMarketDataClient` 的 public read-only 输出，
并把结果转换为 Core `MarketEvent` 写入本地 event log。

新增确认：

- 自动验证必须使用 mock transport / fixture parity。
- Runtime 只允许读取 `klines`、recent trades、best bid / ask、depth snapshot 和 public depth delta。
- transport request 仍必须满足 read-only、`requiresAPIKey == false` 和 public allowlist。
- depth delta 仍只消费 public stream 单条 payload，不创建 listenKey user data stream。
- 真实 Binance 网络 smoke test 只能作为可选人工证据，不得成为 required validation。

边界确认：

- 不接 API key。
- 不接 signed endpoint。
- 不接 account endpoint。
- 不提交、取消或替换订单。
- 不实现 futures leverage / margin action。
- 不实现 LiveExecutionAdapter、真实 broker action 或真实订单行为。

## MTP-54 Market Data Batch / Replay 边界

日期：2026-05-20

执行者：Codex

`Adapters` 在本事项中新增 Binance public market data batch / replay boundary fixture，用于定义更长周期 market data replay operations 的第一层合同。

契约结构：

- `BinanceMarketDataBatchReplayBoundary`：固定 public read-only、local fixture replay、required validation 离线可重复和 production operations 禁区。
- `BinanceMarketDataBatchReplayContractField`：固定最小 metadata 字段集合：batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- `BinanceMarketDataBatchReplayValidationMode`：区分 required mock transport / fixture parity / local batch replay 与 optional manual Binance public network smoke。
- `BinanceMarketDataBatchReplayForbiddenCapability`：显式列出 API key、signed endpoint、account endpoint、listenKey、Live trading、broker action、真实订单、production runtime operations、large-scale historical downloader 和 data platform 禁区。

契约要求：

- batch / replay boundary 只能复用 Binance public read-only market data capability。
- 输入字段只描述 symbol、interval、time window 和 fixture source。
- 输出字段只描述 batch id、replay run id、record count 和 checksum / parity hint。
- metadata 只服务本地 replay operations evidence，不代表 production runtime operations。
- required validation 必须使用 mock transport / fixture parity / local batch replay，不依赖真实 Binance 网络。
- 真实 Binance 网络 smoke test 只能作为 optional manual evidence，不得成为 required validation。

本契约不包含：

- 真实长周期历史下载器。
- production scheduler 或 production runtime operations。
- 多节点运行、云端数据湖或大规模数据平台。
- signed endpoint、account endpoint、listenKey user data stream。
- broker action、Live trading、真实订单提交 / 撤销 / 替换。

## MTP-55 Market Data Replay Metadata / Batch Replay Contract

日期：2026-05-20

执行者：Codex

`Adapters` 在本事项中新增本地 replay operations metadata 和 batch replay contract，用于把 MTP-54 的 boundary 字段落实为可 Codable、可 deterministic equality 验证的 value model。

契约结构：

- `BinanceMarketDataReplayOperationsMetadata`：描述 batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- `BinanceMarketDataBatchReplayContract`：把 metadata 绑定到 `BinanceMarketDataBatchReplayBoundary`，并固定 required fields、required validation mode、optional validation mode 和 forbidden capability。
- `BinanceMarketDataReplayOperationsMetadataError`：只表达本地 metadata 合同错误，例如负数 record count、空 checksum / parity hint 或不完整 boundary。
- `BinanceMarketDataReplayOperationsFixture`：提供 BTCUSDT / 1m / 单条本地 fixture 的 deterministic metadata 和 contract evidence。

契约要求：

- metadata 只描述本地 replay operations evidence，不代表 production runtime operations。
- batch replay contract 必须覆盖 MTP-54 最小字段集合，并保持 public read-only / local fixture replay。
- required validation 固定为 mock transport、fixture parity 和 local batch replay，不依赖真实 Binance 网络。
- optional manual Binance public network smoke 仍只能作为人工证据，不得进入 required validation。
- metadata field values 不得包含 signed endpoint、account endpoint、listenKey、broker、real order 或 production runtime operations 字段。

本契约不包含：

- 真实长周期历史下载器。
- production scheduler、多节点运行或云端数据湖。
- retention engine、freshness read model、fixture parity hardening、event log / projection consistency 或 UI evidence 接入。
- signed endpoint、account endpoint、listenKey user data stream。
- broker action、Live trading、真实订单提交 / 撤销 / 替换。

## MTP-56 Market Data Replay Retention / Freshness Evidence

日期：2026-05-20

执行者：Codex

`Adapters` 在本事项中新增最小 retention policy、freshness status、freshness evidence read model 和 batch freshness summary，用于表达本地 replay batch 是否保留、是否 stale、是否 expired，并为后续 Report / Dashboard / Event Timeline 提供稳定只读 evidence。

契约结构：

- `BinanceMarketDataReplayRetentionPolicy`：描述本地 batch replay retention 的 policy id、stale window、expires window、retention window 和本地保留开关。
- `BinanceMarketDataReplayFreshnessStatus`：固定 `fresh`、`stale`、`expired`、`not retained` 四种状态。
- `BinanceMarketDataReplayFreshnessEvidenceReadModel`：复制 batch / replay metadata、retention policy 摘要、freshness status、retention evidence 和 read-model-only boundary flags。
- `BinanceMarketDataReplayBatchFreshnessSummary`：聚合多个 freshness evidence read model，输出 fresh / stale / expired / not retained / retained batch ids 和稳定 summary line。
- `BinanceMarketDataReplayFreshnessSourceContract`：证明 freshness evidence 不暴露 SQLite / DuckDB schema、ORM、Runtime object、adapter request、storage tiering、cloud archive 或 production deletion job。

契约要求：

- retention policy 只服务本地 replay operations evidence，不执行 production retention cleanup。
- freshness evidence read model 必须从 `BinanceMarketDataBatchReplayContract` 派生，并保持 public read-only、local fixture replay 和 required validation local-only。
- batch freshness summary 只聚合已生成的 freshness read model，不触发 replay、不读取 persistence schema、不调用 adapter / runtime。
- freshness evidence 不得包含 signed endpoint、account endpoint、listenKey、broker、real order 或 production runtime operations surface。
- 后续 Report / Dashboard / Event Timeline 只能消费 read model 字段，不得直接访问 SQLite / DuckDB schema、adapter request 或 runtime object。

本契约不包含：

- 完整 retention engine 或 production 数据清理任务。
- 云端 archive、storage tiering、多节点运行或数据湖。
- event log / projection consistency 串联。
- Dashboard / Event Timeline UI 接入。
- signed endpoint、account endpoint、listenKey user data stream。
- broker action、Live trading、真实订单提交 / 撤销 / 替换。

## MTP-57 Market Data Replay Fixture Parity / Replay Consistency

日期：2026-05-20

执行者：Codex

`Adapters` 在本事项中新增 deterministic fixture parity 和 replay consistency evidence，用于验证本地 batch replay output 与 MTP-55 metadata / contract 完全一致。

契约结构：

- `BinanceMarketDataBatchReplayConsistencyEvidence`：从 `BinanceMarketDataBatchReplayContract` 和本地 replayed `MarketBar` records 派生，复制 replay output summary、record ordering、record count、metadata consistency 和 checksum / parity hint match evidence。
- `BinanceMarketDataBatchReplayDeterministicParity`：生成 deterministic replay output summary 和稳定 FNV-1a parity hint，并提供本地 validation 入口。
- `BinanceMarketDataBatchReplayParityError`：表达 metadata record count、symbol、interval、time window、record ordering、checksum / parity hint 或非本地 replay contract 漂移。
- `BinanceMarketDataReplayOperationsFixture.deterministicReplayRecords()`：提供 BTCUSDT / 1m 的本地 replay output fixture，只用于 XCTest、docs 和 PR evidence。

契约要求：

- replay consistency evidence 必须从本地 `MarketBar` records 和 batch replay contract 生成，不读取真实 Binance 网络。
- record count、symbol、interval、time window 必须与 metadata 一致。
- replay records 必须按 interval start 严格递增，乱序 replay output 必须被拒绝。
- checksum / parity hint 必须从 deterministic replay output summary 计算，并与 metadata checksum / parity hint 一致。
- required validation 固定为 mock transport、fixture parity 和 local batch replay，不依赖真实 Binance 网络。
- consistency evidence 不得包含 signed endpoint、account endpoint、listenKey、broker、real order、Live trading 或 production runtime operations surface。

本契约不包含：

- 真实长周期历史下载器或 production replay job。
- event log / projection consistency 串联。
- Dashboard / Report / Event Timeline UI 接入。
- 生产级数据质量平台、数据修复或多节点运行。
- signed endpoint、account endpoint、listenKey user data stream。
- broker action、Live trading、真实订单提交 / 撤销 / 替换。
