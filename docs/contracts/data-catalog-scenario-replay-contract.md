# Data Catalog / Scenario Replay Contract

日期：2026-05-26

执行者：Codex

本文档定义 `MTPRO Data Catalog / Scenario Replay v1` 的 Data Catalog / Scenario Replay terminology、目标引擎职责、local-first deterministic versioned boundary、scenario manifest / scenario id / dataset version contract、forbidden capability baseline、source docs anchors 和 validation anchors。

本文档服务 `MTP-103` 的术语 / 边界合同和 `MTP-104` 的 scenario manifest 输入身份合同；它不实现 manifest file parser，不新增 fixture 数据，不实现 replay cursor，不实现 report input versioning，不新增 production data platform，不做 large-scale ingestion pipeline，不接 signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、trading button，不运行 Graphify，不修改 Figma。

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
- `docs/architecture.md`
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
