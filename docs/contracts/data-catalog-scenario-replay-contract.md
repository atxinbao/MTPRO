# Data Catalog / Scenario Replay Contract

日期：2026-05-26

执行者：Codex

本文档定义 `MTPRO Data Catalog / Scenario Replay v1` 的 Data Catalog / Scenario Replay terminology、目标引擎职责、local-first deterministic versioned boundary、scenario manifest / scenario id / dataset version contract、single-symbol / single-timeframe deterministic scenario fixture、forbidden capability baseline、source docs anchors 和 validation anchors。

本文档服务 `MTP-103` 的术语 / 边界合同、`MTP-104` 的 scenario manifest 输入身份合同、`MTP-105` 的 first deterministic scenario fixture 合同、`MTP-106` 的 replay window / cursor / checksum / freshness evidence 合同，以及 `MTP-107` 的 data quality gates / report input versioning 合同；它不实现 manifest file parser，不实现 production data quality platform，不实现 production data observability，不新增 production data platform，不做 large-scale ingestion pipeline，不接 signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、trading button，不运行 Graphify，不修改 Figma。

## MTP-103 Data Catalog / Scenario Replay terminology

`MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY`

MTP-103 只允许定义以下术语，不允许把术语升级为实现：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `local data catalog` | 本地 scenario replay 输入身份、版本和证据锚点的目录语言 | 不等于 production data platform、cloud data lake 或大型 ingestion pipeline |
| `scenario replay` | 从本地 versioned inputs 重建 deterministic evidence 的后续路径 | 不等于 production recovery、broker replay、account replay 或 live runtime resume |
| `scenario manifest` | 后续 issue 的输入身份合同名称 | 当前不解析 manifest，不定义最终字段解析器 |
| `scenario id` | 后续 scenario replay 的稳定场景标识 | 不等于数据库主键、运行时 job id 或 broker/order id |
| `dataset version` | 后续 replay 输入数据版本 | 不等于生产 dataset registry 或云端数据湖版本 |
| `fixture version` | 后续 deterministic fixture 的本地版本 | 当前不新增 fixture 数据 |
| `replay window` | 后续 replay 的本地时间 / 序列窗口 | 当前不实现 cursor 或 historical downloader |
| `replay cursor` | 后续回放位置证据 | 当前不实现 cursor runtime |
| `checksum evidence` | 后续完整性 / parity 证据 | 当前不计算新 checksum |
| `freshness evidence` | 后续本地数据新鲜度证据 | 当前不实现 production retention engine |
| `data quality gate` | 后续数据质量判定分类 | 当前不实现数据质量平台 |
| `report input versioning` | 后续 Report / Backtest / future Simulated Exchange 输入追溯合同 | 当前不实现 report input versioning runtime |
| `Workbench scenario replay evidence` | 后续 Workbench / Report / Events 只读展示面输入 | 当前不做 UI redesign，不暴露 schema、adapter request 或 Runtime object |

Core deterministic fixture：`DataCatalogScenarioReplayBoundary`。

Focused Core tests：

- `testMTP103DataCatalogScenarioReplayDefinesTerminologyAndBoundaryAnchors`
- `testMTP103DataCatalogScenarioReplayRejectsImplementationAndLiveBypass`
- `testMTP103DataCatalogScenarioReplayKeepsTargetEnginesLocalFirstAndReadModelOnly`

## MTP-103 target engine responsibility boundary

`MTP-103-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`

MTP-103 固定三类目标引擎职责：

| Target Engine | MTP-103 允许职责 | 当前禁止 |
| --- | --- | --- |
| `Data Engine` | 定义 local data catalog / scenario replay 输入身份、dataset version、fixture version、replay window、checksum、freshness 和 data quality gate 的语言 | 不实现 downloader、production ingestion、data lake、broker feed 或 signed/account source |
| `State & Persistence Engine` | 为后续 append-only / versioned source facts 和 replay evidence 提供边界语言 | 不新增 schema migration、SQL API、cursor runtime、production retention cleanup 或 database console |
| `Workbench Interface` | 后续只消费 read model / ViewModel evidence，展示 scenario id、dataset version、quality verdict 和 replay summary | 不新增 command surface、query language、trading button、live command 或 Live PRO Console |

`DataCatalogScenarioReplayBoundary.targetEngineBoundaryHeld` 必须为 `true`，并且 `buildsProductionDataPlatform`、`buildsLargeScaleIngestionPipeline`、`downloadsRealNetworkData` 必须为 `false`。

## MTP-103 local-first deterministic versioned boundary

`MTP-103-LOCAL-FIRST-DETERMINISTIC-VERSIONED-BOUNDARY`

MTP-103 的边界原则：

- `local-first`：验证和 fixture evidence 只依赖本地 deterministic 数据，不依赖真实网络、secret 或 broker。
- `deterministic scenario replay`：后续 replay 必须能从稳定输入重建同一 evidence。
- `versioned scenario input identity`：后续 scenario id、dataset version、fixture version 和 checksum 必须可追溯。
- `read-model-only Workbench / Report / Events surface`：后续展示面只能消费 read model / ViewModel。
- `no production data platform`：当前不引入 production data platform、cloud data lake 或 large-scale ingestion pipeline。
- `no Live / broker / signed endpoint boundary`：当前不接 signed/account/listenKey/broker/live runtime。

`DataCatalogScenarioReplayBoundary.localFirstDeterministicVersionedBoundaryHeld` 必须为 `true`。

## MTP-103 forbidden capability baseline

`MTP-103-FORBIDDEN-CAPABILITY-BASELINE`

MTP-103 必须保持以下 forbidden capabilities：

- scenario manifest parser
- fixture data
- replay cursor runtime
- report input versioning runtime
- Simulated Exchange / Backtest Parity runtime
- secret read
- signed endpoint
- account endpoint
- listenKey
- broker integration
- broker execution adapter
- exchange execution adapter
- `LiveExecutionAdapter`
- OMS
- real order lifecycle
- real submit / cancel / replace
- execution report
- broker fill
- reconciliation
- real account / broker position read
- live runtime
- live command
- trading button
- production data platform
- large-scale ingestion pipeline
- real network download
- Graphify update
- Figma change

Core fixture 中对应 Boolean flags 必须全部保持 `false`，并且 Codable 解码不能绕过该边界。

## MTP-103 source docs anchors

MTP-103 的 source docs anchors：

- `GOAL.md`
- `BLUEPRINT.md`
- `architecture.md`
- `docs/roadmap.md`
- `docs/domain/context.md`
- `docs/planning/projects/mtpro-data-catalog-scenario-replay-v1-plan.md`
- `docs/validation/latest-verification-summary.md`

这些 anchors 只说明术语和边界来源，不替代 Linear issue body，不授权后续 issue scope。

## MTP-103 validation anchors

`MTP-103-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION`

Required validation：

- `swift test --filter MTP103`
- `bash checks/run.sh`

Validation anchors：

- `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY`
- `MTP-103-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`
- `MTP-103-LOCAL-FIRST-DETERMINISTIC-VERSIONED-BOUNDARY`
- `MTP-103-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION`
- `TVM-DATA-CATALOG-SCENARIO-REPLAY`

MTP-103 不新增 Dashboard smoke handle，不新增 App read model，不新增 stage audit input；Project stage closeout 仍归属 `MTP-109`。

## MTP-104 scenario manifest / scenario id / dataset version contract

`MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS`

MTP-104 在 MTP-103 terminology / boundary 基础上建立最小 scenario manifest 输入身份合同。当前 manifest 只允许以下字段：

| 字段 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `scenario id` | local-first scenario replay 的稳定场景标识 | 不等于 database primary key、runtime job id、broker order id 或真实订单 id |
| `dataset version` | 本地 replay 输入数据版本 | 不等于 production dataset registry、cloud data lake version 或外部 catalog service version |
| `symbol` | first scenario 的单一 Core `Symbol` | 不等于 multi-symbol catalog 或 production market universe |
| `timeframe` | first scenario 的单一 Core `Timeframe` | 不等于 multi-timeframe catalog 或 historical downloader policy |
| `source anchor` | contract / fixture / report input 可追溯锚点 | 不等于 database schema、adapter request、Runtime object 或 broker payload |
| `scope` | `single-symbol / single-timeframe` | 不授权多 symbol / 多 timeframe catalog |

Core deterministic fixture：`ScenarioManifest.deterministicFixture`。

Focused Core tests：

- `testMTP104ScenarioManifestDefinesIdentityVersionAndSerialization`
- `testMTP104ScenarioManifestRejectsMultiSymbolAndLiveBypass`
- `testMTP104ScenarioManifestRoundTripsAsStableSourceIdentity`

## MTP-104 scenario id / dataset version stable identity

`MTP-104-SCENARIO-ID-DATASET-VERSION-STABLE-IDENTITY`

MTP-104 固定 `ScenarioID` 和 `DatasetVersion` 为独立 Core value object。二者复用 `Identifier` 的非空校验，但用不同类型表达语义边界：

- `ScenarioID` 只标识本地 replay scenario，不代表 database primary key、runtime job id、broker order id 或真实订单 id。
- `DatasetVersion` 只标识本地 replay 输入版本，不代表 production dataset registry、cloud data lake version 或外部 catalog service version。
- `ScenarioManifest` 必须同时携带 `scenarioID`、`datasetVersion`、`symbol`、`timeframe` 和 `sourceAnchor`，使后续 fixture / replay / report input 能引用同一稳定 source。

## MTP-104 single-symbol / single-timeframe manifest

`MTP-104-SINGLE-SYMBOL-SINGLE-TIMEFRAME-MANIFEST`

MTP-104 的 first scenario manifest scope 只能是 `single-symbol / single-timeframe`：

- `ScenarioManifest.scope == .singleSymbolSingleTimeframe`。
- `ScenarioManifest.usesMultipleSymbols == false`。
- `ScenarioManifest.usesMultipleTimeframes == false`。
- 多 symbol / 多 timeframe catalog 仍归后续独立 issue 或 Project，不得从 manifest 合同偷渡。

## MTP-104 manifest deterministic serialization

`MTP-104-MANIFEST-DETERMINISTIC-SERIALIZATION`

`ScenarioManifest.deterministicSerialization` 固定以下 canonical field order：

```text
scenarioID
datasetVersion
symbol
timeframe
sourceAnchor
scope
```

`ScenarioManifestDeterministicSerialization.sourceIdentity` 以 deterministic field order 生成稳定 identity string，供后续 fixture、replay、quality gate、report input versioning 和 read-model evidence 消费。该 serialization evidence 不读取文件、不计算 checksum、不解析 manifest 文件、不暴露 persistence schema、adapter request 或 Runtime object。

## MTP-104 manifest no schema / adapter / live capability

`MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY`

`ScenarioManifest` 初始化和 Codable 解码必须拒绝以下绕过：

- database schema exposure。
- adapter request exposure。
- secret read。
- signed endpoint。
- account endpoint。
- listenKey。
- broker integration。
- order command。
- live runtime。
- production dataset registry。
- real network download。
- multi-symbol catalog。
- multi-timeframe catalog。

对应 Boolean flags 必须全部保持 `false`；任何初始化或 Codable payload 试图打开这些能力都必须抛出 `CoreError.dataCatalogScenarioReplayForbiddenCapability`。

## MTP-104 validation anchors

`MTP-104-SCENARIO-MANIFEST-VALIDATION`

Required validation：

- `swift test --filter MTP104`
- `bash checks/run.sh`

Validation anchors：

- `MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS`
- `MTP-104-SCENARIO-ID-DATASET-VERSION-STABLE-IDENTITY`
- `MTP-104-SINGLE-SYMBOL-SINGLE-TIMEFRAME-MANIFEST`
- `MTP-104-MANIFEST-DETERMINISTIC-SERIALIZATION`
- `MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY`
- `MTP-104-SCENARIO-MANIFEST-VALIDATION`
- `TVM-DATA-CATALOG-SCENARIO-REPLAY`

MTP-104 不新增 fixture data、不实现 replay cursor、不实现 report input versioning runtime、不新增 App read model、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 `MTP-109`。

## MTP-105 single-symbol / single-timeframe deterministic scenario fixture

`MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE`

MTP-105 在 MTP-104 manifest 输入身份基础上建立 first scenario fixture。当前 fixture 只允许：

| 字段 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `manifest` | `ScenarioManifest.deterministicFixture`，固定 scenario id、dataset version、BTCUSDT、1m 和 source identity | 不等于 manifest parser、file loader、production dataset registry 或 Runtime job |
| `fixture version` | `fixture-v1`，标识当前仓库内 first deterministic records 版本 | 不等于 dataset version、cloud data lake version 或 external catalog version |
| `source kind` | `Binance public read-only local fixture` | 不等于真实 Binance 网络下载、adapter request、signed endpoint、account endpoint / listenKey 或 broker feed |
| `fixed window` | `1704067200...1704067380` 的本地固定 kline 窗口 | 不等于 historical downloader policy、production retention window 或 replay cursor |
| `fixed record order` | sequence `1,2,3` 且 interval start 严格升序 | 不等于 exchange sequence、broker sequence、event log sequence 或 replay cursor |
| `deterministic summary pre-structure` | canonical record summary、record order identity 和 checksum preimage | 不等于 MTP-106 final checksum evidence、freshness verdict、data quality gate 或 report input versioning |

Core deterministic fixture：`DeterministicScenarioFixture.deterministicFixture`。

Focused Core tests：

- `testMTP105DeterministicScenarioFixtureDefinesSingleSymbolSingleTimeframeRecords`
- `testMTP105ScenarioFixtureBuildsDeterministicSummaryPrestructure`
- `testMTP105ScenarioFixtureRejectsNetworkLiveAndRecordOrderBypass`
- `testMTP105ScenarioFixtureRoundTripsWithoutForbiddenCapabilityText`

## MTP-105 fixture version / source anchor

`MTP-105-FIXTURE-VERSION-SOURCE-ANCHOR`

MTP-105 固定 `FixtureVersion("fixture-v1")` 和 source anchor `MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE`。`FixtureVersion` 是 Core value object，只表达本地 fixture record set 的版本，不替代 `DatasetVersion`，不读取文件、不创建 registry、不接 production dataset catalog。

`DeterministicScenarioFixture.sourceRelationshipAnchors` 必须固定为：

- `MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS`
- `TVM-MARKET-DATA-REPLAY-OPERATIONS`
- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `Binance public read-only local fixture`

这些 anchors 只说明 first scenario fixture 与既有 Binance public read-only / local replay evidence 的关系，不建立 Core -> Adapters 依赖，不调用真实网络，不暴露 adapter request。

## MTP-105 fixed window / record order

`MTP-105-FIXED-WINDOW-RECORD-ORDER`

`ScenarioFixtureRecord` 固定本地 record sequence 和 `MarketBar`。初始化与 Codable 解码必须拒绝：

- 空 records。
- 非 `1...N` 的 record sequence。
- interval start 非严格升序。
- symbol / timeframe 与 MTP-104 manifest 不一致。

当前 first scenario records 为 BTCUSDT / 1m 三条本地 kline：

```text
1: 1704067200...1704067260
2: 1704067260...1704067320
3: 1704067320...1704067380
```

## MTP-105 public read-only local fixture relationship

`MTP-105-PUBLIC-READ-ONLY-LOCAL-FIXTURE-RELATIONSHIP`

MTP-105 只复用 Binance public read-only / local replay 的语义，不导入 `Adapters` target，不调用 `BinanceMarketDataBatchReplay*` runtime，不触发真实 Binance 网络，不读取 secret，不使用 signed/account/listenKey endpoint，也不生成 broker / exchange execution capability。

`DeterministicScenarioFixture.publicReadOnlyLocalFixtureRelationshipHeld` 必须为 `true`，并且 `requiredValidationDependsOnNetwork`、`downloadsRealNetworkData`、`exposesAdapterRequest` 必须为 `false`。

## MTP-105 deterministic summary pre-structure

`MTP-105-DETERMINISTIC-SUMMARY-PRESTRUCTURE`

`ScenarioFixtureDeterministicSummary` 固定以下前置结构：

- `scenarioID`
- `datasetVersion`
- `fixtureVersion`
- `symbol`
- `timeframe`
- `fixedWindow`
- `recordCount`
- `orderedRecordStarts`
- `recordOrderIdentity`
- `canonicalRecordSummary`
- `checksumPreimage`
- `sourceIdentity`

`checksumEvidenceDeferredToMTP106 == true` 必须保持不变。MTP-105 不输出 final checksum evidence、不实现 replay cursor、不实现 freshness evidence、不实现 data quality gate、不实现 report input versioning。

## MTP-105 no network / signed / broker / live capability

`MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE`

`DeterministicScenarioFixture` 初始化和 Codable 解码必须拒绝以下绕过：

- real network download。
- production ingestion pipeline。
- cloud data lake。
- adapter request exposure。
- secret read。
- signed endpoint。
- account endpoint。
- listenKey。
- broker integration。
- broker / exchange execution adapter。
- `LiveExecutionAdapter`。
- OMS。
- real order lifecycle。
- live command。
- trading button。
- multi-symbol / multi-timeframe catalog。

对应 Boolean flags 必须全部保持 `false`；任何初始化或 Codable payload 试图打开这些能力都必须抛出 `CoreError.dataCatalogScenarioReplayForbiddenCapability`。

## MTP-105 validation anchors

`MTP-105-SCENARIO-FIXTURE-VALIDATION`

Required validation：

- `swift test --filter MTP105`
- `bash checks/run.sh`

Validation anchors：

- `MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE`
- `MTP-105-FIXTURE-VERSION-SOURCE-ANCHOR`
- `MTP-105-FIXED-WINDOW-RECORD-ORDER`
- `MTP-105-PUBLIC-READ-ONLY-LOCAL-FIXTURE-RELATIONSHIP`
- `MTP-105-DETERMINISTIC-SUMMARY-PRESTRUCTURE`
- `MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE`
- `MTP-105-SCENARIO-FIXTURE-VALIDATION`
- `TVM-DATA-CATALOG-SCENARIO-REPLAY`

MTP-105 不实现 replay cursor、不实现 final checksum evidence、不实现 freshness evidence、不实现 data quality gate、不实现 report input versioning runtime、不新增 App read model、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 `MTP-109`。

## MTP-106 replay window / cursor / checksum / freshness evidence

`MTP-106-DETERMINISTIC-REPLAY-WINDOW`

MTP-106 在 MTP-104 manifest 和 MTP-105 deterministic fixture 基础上建立 scenario replay evidence。当前 evidence 只允许：

| 字段 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `replay window` | `1704067200...1704067380` 的 deterministic historical replay window，继承 MTP-105 fixed window | 不等于 historical downloader policy、production retention window、runtime job window 或 broker/account replay window |
| `replay cursor` | 本地 fixture record progress，默认 next sequence 为 `1`，completed cursor 为 `4` | 不等于 production scheduler、downloader offset、event log sequence、exchange sequence、broker sequence 或 live runtime resume token |
| `cursor summary` | cursor identity、window identity、next sequence、consumed count、total count 和 state 的稳定摘要 | 不暴露 Runtime object、adapter request、SQLite / DuckDB schema 或 UI command |
| `checksum / parity evidence` | MTP-105 checksum preimage 的 final FNV-1a checksum：`fnv1a64:3c6cd4ff13cd4062` | 不等于 production data quality platform、真实历史下载校验或 broker/account reconciliation |
| `fixture freshness evidence` | 固定 evaluatedAt `1704067500`、age `120s`、status `fresh` 的本地 fixture freshness evidence | 不执行 production retention engine、cloud archive、storage tiering、cleanup job 或 downloader |
| `data quality gate input identity` | replay window、cursor identity、checksum 和 freshness status 的稳定组合 | 只为 MTP-107 后续消费，不在 MTP-106 实现 data quality gate 或 report input versioning |

Core deterministic fixture：`ScenarioReplayEvidence.deterministicFixture`。

Focused Core tests：

- `testMTP106ScenarioReplayEvidenceDefinesWindowCursorChecksumAndFreshness`
- `testMTP106ScenarioReplayCursorIsCodableReproducibleAndComparable`
- `testMTP106ScenarioReplayChecksumAndFreshnessRejectDrift`
- `testMTP106ScenarioReplayEvidenceKeepsForbiddenBoundaryAndNoForbiddenText`

## MTP-106 replay cursor summary

`MTP-106-REPLAY-CURSOR-SUMMARY`

`ScenarioReplayCursor` 必须满足：

- `nextRecordSequence` 只能位于 `1...4`。
- `state` 只能由 fixture sequence 推导为 `at start`、`in progress` 或 `completed`。
- `consumedRecordCount` 必须等于 `nextRecordSequence - 1`。
- Cursor 必须 Codable round-trip 后保持相等，并可通过 `Comparable` 按同一 window 的 sequence 稳定比较。
- Cursor 不得表达 production scheduler、downloader offset、event log sequence、broker/account replay 或 live runtime resume。

`ScenarioReplayCursorSummary` 只复制 cursor 的必要 read-model-like 字段，供后续 MTP-107 quality gate 或 MTP-108 read-model evidence 消费。

## MTP-106 checksum / parity evidence

`MTP-106-CHECKSUM-PARITY-EVIDENCE`

`ScenarioReplayChecksumEvidence` 必须从 `DeterministicScenarioFixture.deterministicSummary.checksumPreimage` 计算 final checksum：

```text
fnv1a64:3c6cd4ff13cd4062
```

Checksum evidence 固定：

- algorithm：`fnv1a64`。
- source identity：MTP-104 manifest deterministic source identity。
- record order identity：`1:1704067200|2:1704067260|3:1704067320`。
- canonical preimage：MTP-105 canonical record summary joined by newline。
- `checksumMatchedCanonicalPreimage == true`。
- `parityEvidenceStable == true`。

初始化和 Codable 解码必须拒绝 checksum drift、canonical preimage drift、record order drift 或 parity flag drift。

## MTP-106 fixture freshness evidence

`MTP-106-FIXTURE-FRESHNESS-EVIDENCE`

`ScenarioReplayFreshnessPolicy` 只定义本地 fixture freshness 阈值：

- policy id：`mtp-106-local-fixture-freshness-policy`。
- stale after：`300` seconds。
- expires after：`900` seconds。
- retain fixture locally：`true`。

`ScenarioReplayFreshnessEvidence` 默认 evaluatedAt 为 `1704067500`，相对 replay window end `1704067380` 的 age 为 `120` seconds，status 为 `fresh`。该 evidence 不执行 production retention engine、不授权 cloud archive、不暴露 storage tiering、不依赖网络。

## MTP-106 no production / network / broker / live capability

`MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE`

`ScenarioReplayEvidence` 初始化和 Codable 解码必须拒绝以下绕过：

- required validation network dependency。
- real network download。
- production retention engine。
- large-scale ingestion pipeline。
- production data platform。
- database schema exposure。
- adapter request exposure。
- secret read。
- signed endpoint。
- account endpoint。
- listenKey。
- broker integration。
- `LiveExecutionAdapter`。
- OMS。
- real order lifecycle。
- report input versioning runtime。
- data quality gate runtime。
- live runtime。
- live command。
- trading button。

对应 Boolean flags 必须全部保持 `false`；任何初始化或 Codable payload 试图打开这些能力都必须抛出 `CoreError.dataCatalogScenarioReplayForbiddenCapability`。

## MTP-106 validation anchors

`MTP-106-SCENARIO-REPLAY-EVIDENCE-VALIDATION`

Required validation：

- `swift test --filter MTP106`
- `bash checks/run.sh`

Validation anchors：

- `MTP-106-DETERMINISTIC-REPLAY-WINDOW`
- `MTP-106-REPLAY-CURSOR-SUMMARY`
- `MTP-106-CHECKSUM-PARITY-EVIDENCE`
- `MTP-106-FIXTURE-FRESHNESS-EVIDENCE`
- `MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE`
- `MTP-106-SCENARIO-REPLAY-EVIDENCE-VALIDATION`
- `TVM-DATA-CATALOG-SCENARIO-REPLAY`

MTP-106 不实现 data quality gate runtime、不实现 report input versioning runtime、不新增 App read model、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 `MTP-109`。

## MTP-107 data quality gate taxonomy / report input versioning

`MTP-107-DATA-QUALITY-GATE-TAXONOMY`

MTP-107 在 MTP-106 replay evidence 基础上定义最小 data quality gate taxonomy。当前 taxonomy 只服务 local scenario replay 和 report reproducibility：

| Gate | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `record order` | 检查 observed record order identity 是否等于 MTP-106 replay window 的 `1:1704067200|2:1704067260|3:1704067320` | 不等于 exchange sequence、broker sequence、event log sequence 或 production ordering service |
| `window coverage` | 检查 observed window 和 record count 是否覆盖 MTP-106 replay window `1704067200...1704067380` / `records=3` | 不等于 historical downloader coverage、production retention coverage 或 cloud data lake partition coverage |
| `checksum match` | 检查 observed checksum 是否等于 MTP-106 final checksum `fnv1a64:3c6cd4ff13cd4062` | 不等于 production data quality platform、真实下载校验服务或 broker/account reconciliation |
| `freshness status` | 检查 MTP-106 freshness status；`fresh` 通过，`stale` 标记，`expired` / `not retained` 拒绝 | 不执行 production retention engine、automatic download、cleanup 或 repair |
| `missing data` | 检查 deterministic fixture record sequence 是否存在缺口 | 不触发自动回补、真实网络下载或 production repair |
| `duplicate data` | 检查 deterministic fixture record sequence 是否存在重复 | 不触发 production dedupe pipeline 或 storage compaction |

Core deterministic fixture：`ScenarioDataQualityReportInputEvidence.deterministicFixture`。

Focused Core tests：

- `testMTP107ScenarioDataQualityGatesDefineTaxonomyAndDeterministicVerdict`
- `testMTP107ReportInputVersioningTracesScenarioReplayEvidence`
- `testMTP107ScenarioDataQualityRejectsBadFixtureChecksumMissingAndDuplicateData`
- `testMTP107ScenarioDataQualityMarksStaleEvidenceAndRejectsForbiddenBypass`

## MTP-107 minimal data quality gates

`MTP-107-MINIMAL-DATA-QUALITY-GATES`

`ScenarioDataQualityGateEvaluation` 必须固定六个 gate 的顺序与判定：

```text
record order
window coverage
checksum match
freshness status
missing data
duplicate data
```

默认 deterministic fixture 全部 `passed`，整体 `qualityVerdict == accepted`。bad fixture、checksum mismatch、missing data、duplicate data 必须产生 `qualityVerdict == rejected`；stale freshness 必须产生 `qualityVerdict == marked`；expired / not retained freshness 必须产生 `qualityVerdict == rejected`。

该 evaluation 可以在 tests 中注入 observed checksum、record order、record count、freshness status、missing sequence 和 duplicate sequence，用于证明错误输入会被 rejected / marked；这些注入不是 runtime repair、自动下载、自动修复或 production observer。

## MTP-107 report input versioning

`MTP-107-REPORT-INPUT-VERSIONING`

`ScenarioReportInputVersion` 是 stable report input versioning contract。Report / Backtest / future Simulated Exchange 只能通过该值对象追溯：

- `scenarioID`
- `datasetVersion`
- `fixtureVersion`
- `symbol`
- `timeframe`
- `replayWindowIdentity`
- `replayWindowDescription`
- `checksum`
- `freshnessStatus`
- `qualityVerdict`
- `qualitySummary`

Canonical field order 必须固定为：

```text
scenarioID
datasetVersion
fixtureVersion
replayWindow
checksum
freshnessStatus
qualityVerdict
```

`versionIdentity` 必须把 scenario id、dataset version、fixture version、replay window、checksum、freshness status 和 quality verdict 串成稳定 identity。该 contract 不暴露 SQLite / DuckDB schema、adapter request 或 Runtime object。

## MTP-107 report reproducibility evidence

`MTP-107-REPORT-REPRODUCIBILITY-EVIDENCE`

`ScenarioDataQualityReportInputEvidence` 必须把 MTP-106 replay evidence、MTP-107 gate evaluation 和 report input version 绑定到同一个 deterministic identity：

- `replayEvidence.dataQualityGateInputIdentity == qualityEvaluation.replayInputIdentity`。
- `reportInputVersion.versionIdentity` 必须包含 MTP-106 checksum 和 MTP-107 quality verdict。
- `reportReproducibilityEvidenceHeld == true`。
- `reportInputVersion.sourceAnchors` 必须引用 MTP-104 manifest、MTP-105 fixture、MTP-106 replay evidence 和 MTP-107 report input versioning anchors。

该 evidence 只作为后续 MTP-108 Workbench / Report / Events read-model surface 的输入，不新增 App read model，不新增 Dashboard smoke handle，不输出 stage audit input。

## MTP-107 no production / live / broker / data platform

`MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM`

`ScenarioDataQualityGateEvaluation`、`ScenarioReportInputVersion` 和 `ScenarioDataQualityReportInputEvidence` 初始化与 Codable 解码必须拒绝以下绕过：

- required validation network dependency。
- production data platform。
- production data observability。
- automatic download。
- automatic repair。
- broker / account reconciliation。
- Simulated Exchange / Backtest Parity implementation。
- database schema exposure。
- adapter request exposure。
- Runtime object read。
- secret read。
- signed endpoint。
- account endpoint。
- listenKey。
- broker integration。
- `LiveExecutionAdapter`。
- OMS。
- real order lifecycle。
- live runtime。
- live command。
- trading button。

对应 Boolean flags 必须全部保持 `false`；任何初始化或 Codable payload 试图打开这些能力都必须抛出 `CoreError.dataCatalogScenarioReplayForbiddenCapability`。

## MTP-107 validation anchors

`MTP-107-DATA-QUALITY-REPORT-INPUT-VALIDATION`

Required validation：

- `swift test --filter MTP107`
- `bash checks/run.sh`

Validation anchors：

- `MTP-107-DATA-QUALITY-GATE-TAXONOMY`
- `MTP-107-MINIMAL-DATA-QUALITY-GATES`
- `MTP-107-REPORT-INPUT-VERSIONING`
- `MTP-107-REPORT-REPRODUCIBILITY-EVIDENCE`
- `MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM`
- `MTP-107-DATA-QUALITY-REPORT-INPUT-VALIDATION`
- `TVM-DATA-CATALOG-SCENARIO-REPLAY`

MTP-107 不实现 manifest file parser、不新增 production data quality platform、不实现 production data observability、不实现 automatic download / repair、不实现 broker / account reconciliation、不实现 Simulated Exchange / Backtest Parity runtime、不新增 App read model、不新增 Dashboard smoke handle、不新增 stage audit input；Project stage closeout 仍归属 `MTP-109`。

## MTP-108 scenario replay read-model evidence

`MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE`

MTP-108 把 MTP-106 scenario replay evidence 与 MTP-107 quality gate / report input versioning evidence 接入 App 层 read model。`ScenarioReplayEvidenceReadModel` 和 `ScenarioReplayEvidenceViewModel` 只能复制 stable fields：

- scenario id。
- dataset version。
- fixture version。
- symbol / timeframe。
- replay window。
- replay cursor。
- checksum。
- freshness status。
- quality verdict。
- report input version identity。
- drill-down entry。
- quality gate timeline entry。

该 read model 只供 Dashboard / Workbench / Report / Events 展示，不读取 Runtime object、不暴露 SQLite / DuckDB schema、不调用 Adapter request、不执行 replay、不提供 query language 或 command surface。

## MTP-108 Report scenario replay evidence

`MTP-108-REPORT-SCENARIO-REPLAY-EVIDENCE`

`ReportReadModel` 必须持有 `scenarioReplayEvidence`；`ReportViewModel` 必须输出 scenario id、dataset version、fixture version、symbol、timeframe、replay window、checksum、freshness status、quality verdict、report input version identity、drill-down entry、timeline count 和 quality gate timeline count。Report 输出仍是可编码 read model / ViewModel snapshot，不新增 report runtime、database schema、adapter request、Runtime object 或 trading action。

## MTP-108 Workbench summary and drill-down

`MTP-108-WORKBENCH-SCENARIO-REPLAY-SUMMARY-DRILLDOWN`

`DashboardShellWorkbenchSnapshot` 必须展示 scenario replay evidence summary 与 drill-down evidence：

- scenarios count。
- quality gate count。
- report input count。
- quality verdict。
- scenario / dataset / fixture identities。
- replay windows。
- checksums。
- freshness。
- drill-down entries。
- command surface / query language / read-model boundary flags。

Workbench 只展示 summary / drill-down string，不新增 UI redesign、Figma change、database console、download console、query editor、command button、Live PRO Console 或交易按钮。

## MTP-108 Events timeline evidence

`MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS`

`PaperWorkflowEvidenceExplorer` 必须新增 `scenario replay evidence` section，并把每个 scenario replay evidence item 展开为 replay window、replay cursor、checksum、freshness 和 quality gates timeline rows。Replay window / cursor / checksum / freshness timeline row 必须引用 MTP-108 Events anchor，quality gate timeline row 必须引用 `MTP-108-QUALITY-GATE-TIMELINE`。

## MTP-108 quality gate timeline

`MTP-108-QUALITY-GATE-TIMELINE`

Events / Evidence Explorer 必须展示 MTP-107 六个最小 quality gates 的 verdict summary：record order、window coverage、checksum match、freshness status、missing data、duplicate data。当前 deterministic fixture 的 quality gates 必须全部 `passed`，整体 quality verdict 必须是 `accepted`。

## MTP-108 read-model-only no command surface

`MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE`

MTP-108 App surface 必须保持以下 flags 为 false：

- required validation network dependency。
- production data platform / observability。
- automatic download / repair。
- broker / account reconciliation。
- Simulated Exchange / Backtest Parity implementation。
- database schema exposure。
- adapter request exposure。
- Runtime object read。
- secret read。
- signed endpoint。
- account endpoint。
- listenKey。
- broker integration。
- `LiveExecutionAdapter`。
- OMS。
- real order lifecycle。
- live runtime。
- command surface。
- order-level command。
- query language。
- live command。
- trading button。
- live trading authorization。
- broker action。
- trading execution authorization。

## MTP-108 validation anchors

`MTP-108-SCENARIO-REPLAY-SURFACE-VALIDATION`

Required validation：

- `swift test --filter MTP108`
- `bash checks/run.sh`

Validation anchors：

- `MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE`
- `MTP-108-REPORT-SCENARIO-REPLAY-EVIDENCE`
- `MTP-108-WORKBENCH-SCENARIO-REPLAY-SUMMARY-DRILLDOWN`
- `MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS`
- `MTP-108-QUALITY-GATE-TIMELINE`
- `MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-108-SCENARIO-REPLAY-SURFACE-VALIDATION`
- `TVM-DATA-CATALOG-SCENARIO-REPLAY`

MTP-108 不实现 manifest parser、不新增 Runtime / Adapter / Persistence schema、不新增 database console 或 query language、不新增 UI redesign 或 Figma change、不实现 production data platform / observability、不实现 automatic download / repair、不实现 broker / account reconciliation、不实现 Simulated Exchange / Backtest Parity runtime、不接 signed endpoint、account endpoint、listenKey、secret、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、live runtime、live command 或交易按钮；Project stage closeout 仍归属 `MTP-109`。

## MTP-109 Data Catalog / Scenario Replay stage closeout

`MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-CLOSEOUT`

MTP-109 只收口 `MTPRO Data Catalog / Scenario Replay v1` 的 Project 级验证证据和 Parent Codex Stage Code Audit 输入材料。它把 MTP-103 至 MTP-108 已落地的 terminology、manifest identity、deterministic fixture、replay window / cursor / checksum / freshness、data quality gates、report input versioning 和 Workbench / Report / Events read-model-only evidence 归入同一个审计输入链。

MTP-109 不新增 production code，不新增 Swift API，不修改 runtime 行为，不实现 scenario manifest parser、Runtime replay job、production data platform、automatic download / repair、Simulated Exchange / Backtest Parity runtime、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、live runtime、live command 或交易按钮。

## MTP-109 stage audit input material

`MTP-109-STAGE-AUDIT-INPUT-MATERIAL`

`docs/audit/inputs/mtpro-data-catalog-scenario-replay-v1-stage-audit-input.md` 是 MTP-109 的唯一阶段审计输入材料。该文件必须覆盖：

- Linear queue evidence：`MTP-103` 至 `MTP-108` Done，`MTP-109` In Progress。
- Issue / PR evidence：PR #201 至 #206，以及 MTP-109 当前 PR 占位。
- `TVM-DATA-CATALOG-SCENARIO-REPLAY` evidence chain。
- `TVM-REPORT-EVIDENCE` / `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 的 read-model-only surface 交叉证据。
- Dashboard smoke handles：`scenarioReplayEvidence`、`scenarioQualityGates`、`timelineItems=42`、`readModelOnly=true` 和 `workbenchReadModelOnly=true`。
- MTP-103 至 MTP-108 forbidden capability evidence。
- no Graphify update、no Figma modification、no unauthorized Linear mutation。
- Parent Codex 最终 Stage Code Audit handoff checklist。

## MTP-109 no final Stage Code Audit

`MTP-109-NO-FINAL-STAGE-CODE-AUDIT`

MTP-109 不能输出最终 Stage Code Audit Report，不能创建 `docs/audit/mtpro-data-catalog-scenario-replay-v1-stage-code-audit.md`，不能设置 Linear Project `Completed`，不能创建下一 Project / Issue，不能推进下一阶段，也不能启动下一阶段 `symphony-issue`。

最终 Stage Code Audit Report 必须在 `MTP-103` 至 `MTP-109` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出。

## MTP-109 validation evidence chain

`MTP-109-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION-EVIDENCE-CHAIN`

MTP-109 的 validation evidence chain 必须确认：

- MTP-103：terminology / target engine / local-first deterministic versioned boundary / forbidden capability baseline 已落地。
- MTP-104：scenario manifest、scenario id、dataset version、single-symbol / single-timeframe identity 和 deterministic serialization 已落地。
- MTP-105：first deterministic scenario fixture、fixture version、fixed window、fixed record order、checksum preimage 已落地。
- MTP-106：replay window、cursor summary、checksum / parity evidence、freshness evidence 和 data quality gate input identity 已落地。
- MTP-107：六个最小 data quality gates、accepted / marked / rejected verdict 和 stable report input versioning 已落地。
- MTP-108：Workbench / Report / Events scenario replay read-model-only evidence surface、quality gate timeline 和 Dashboard smoke handles 已落地。

## MTP-109 forbidden capability evidence chain

`MTP-109-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-103 至 MTP-108 的 forbidden capability evidence 必须保持：

- no manifest parser / no Runtime replay job。
- no production data platform / no large-scale ingestion pipeline / no cloud data lake。
- no automatic download / no automatic repair / no production data observability。
- no database schema exposure / no adapter request exposure / no Runtime object read。
- no signed endpoint / no account endpoint / no listenKey / no secret read。
- no broker / no broker or exchange execution adapter / no `LiveExecutionAdapter`。
- no OMS / no real order lifecycle / no execution report / no broker fill / no reconciliation。
- no real account / broker position read。
- no Simulated Exchange / Backtest Parity runtime。
- no Live PRO Console / no live command / no command surface / no trading button。
- no Graphify update / no Figma change / no unauthorized Linear mutation。

## MTP-109 stage audit input anchor

`MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-AUDIT-INPUT`

该 anchor 只指向 MTP-109 stage audit input material，不代表最终 Stage Code Audit Report 已存在或 Project 已 Completed。

## MTP-109 automation readiness stage closeout

`MTP-109-AUTOMATION-READINESS-STAGE-CLOSEOUT`

`checks/automation-readiness.sh` 必须机械检查 MTP-109 contract anchors、validation plan anchors、trading validation matrix 回填、latest verification summary、stage audit input material、automation readiness doc anchor、MTP-103 至 MTP-108 source / test anchors 和 Dashboard smoke handles。

Required validation：

- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

Validation anchors：

- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-CLOSEOUT`
- `MTP-109-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-109-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-AUDIT-INPUT`
- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION-EVIDENCE-CHAIN`
- `MTP-109-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-109-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
