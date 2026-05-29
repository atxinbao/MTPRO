# Private Stream / Account Snapshot Simulation Gate Contract

日期：2026-05-29

执行者：Codex

本文档定义 `MTPRO Private Stream / Account Snapshot Simulation Gate v1` 的合同入口：L3.2 private stream / account snapshot simulation gate terminology、account snapshot simulation gate terminology、fixture / simulated / future real private stream 语义分界、simulated private account event source identity、simulated account snapshot input contract、simulated account snapshot update fixture semantics、freshness / stale / blocked / missing evidence、L3.1 APB read-model-only evidence 与 L3.2 simulation gate 的关系、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。

本文档只服务当前 L3.2 issue chain 的术语 / 边界 / 验证锚点。它不实现 private WebSocket runtime，不实现 private stream runtime，不实现 account snapshot runtime，不创建 listenKey，不调用 signed endpoint 或 account endpoint，不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL；不实现 broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command 或 order form；不运行 Graphify，不修改 Figma。

## MTP-140 private stream simulation gate terminology

`MTP-140-PRIVATE-STREAM-SIMULATION-GATE-TERMINOLOGY`

MTP-140 只允许定义以下 L3.2 private stream simulation gate 术语，不允许把术语升级为 runtime：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `private stream simulation gate` | 本地 deterministic fixture / simulated event 进入后续 L3.2 evidence chain 前的语义门禁 | 不等于 listenKey、private WebSocket、user data stream runtime 或 broker stream |
| `simulated private account event` | 本地 fixture 描述的账户相关事件语义，用来支撑后续 source identity / snapshot input / update fixture | 不等于真实 Binance user data event、account endpoint payload、execution report 或 broker account event |
| `private stream fixture source` | 只读 fixture source label，说明 event 来自本地模拟输入 | 不等于 exchange connection、broker connection、secret-backed session 或 private account stream |
| `fixture replay cursor` | 本地 fixture / scenario replay 可复现 cursor，用于说明 deterministic ordering | 不等于 live stream offset、listenKey lifecycle、production stream watermark 或 network checkpoint |
| `future real private stream label` | 未来真实 private stream 进入独立 Project 前的门禁标签 | 不等于当前已实现真实 private stream、secret storage、signed request 或 account stream |

## MTP-140 account snapshot simulation gate terminology

`MTP-140-ACCOUNT-SNAPSHOT-SIMULATION-GATE-TERMINOLOGY`

MTP-140 只允许定义以下 account snapshot simulation gate 术语：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `account snapshot simulation gate` | 本地 simulated account snapshot 输入进入后续 L3.2 evidence chain 前的语义门禁 | 不等于 account snapshot runtime、account endpoint client、real account sync 或 broker portfolio sync |
| `simulated account snapshot input` | 后续 MTP-142 才能深化的本地模拟快照输入 shape | 不等于真实 account endpoint response、broker account payload、SQLite / DuckDB schema 或 Runtime object |
| `account snapshot fixture` | deterministic local fixture 中的 account snapshot evidence | 不等于真实账户余额、margin、leverage、buying power、real PnL 或可交易账户状态 |
| `snapshot observedAt` | fixture 观察时间语义，用于 freshness / stale 判断 | 不等于 exchange server time、broker account state timestamp 或 live stream last event |
| `source watermark` | fixture / replay source 的本地 watermark 语义 | 不等于 private stream watermark、listenKey keepalive state 或 production checkpoint |
| `freshness / stale / blocked / missing evidence` | 后续 MTP-144 才能深化的 simulation gate 状态分类 | 不等于真实账户健康状态、broker connectivity 或 live monitoring runtime |

## MTP-140 fixture / simulated / future real private stream boundary

`MTP-140-FIXTURE-SIMULATED-FUTURE-REAL-PRIVATE-STREAM-BOUNDARY`

MTP-140 将 L3.2 source semantics 固定为术语层：

1. `fixture private stream source` 表示 deterministic local fixture；它不等于真实 private stream payload。
2. `simulated private stream source` 表示 scenario replay / simulated input 产生的本地事件语义；它不等于 listenKey user data stream、execution report、broker fill 或 reconciliation。
3. `future real private stream label` 只能作为未来门禁标签出现；当前不读取 secret，不创建 listenKey，不调用 signed endpoint，不打开 private WebSocket，不运行 account snapshot runtime。
4. `account snapshot fixture` 只能表达 simulation gate 输入，不得被解释为真实 account snapshot、broker account object 或 real account balance。

后续 MTP-141 / MTP-142 / MTP-143 / MTP-144 可以分别深化 source identity、snapshot input contract、balance / position update fixture semantics 和 freshness / blocked / forbidden tests，但必须继续保持 fixture / simulated / future real label 与 live runtime implementation 隔离。

## MTP-141 simulated private account event source identity

`MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`

MTP-141 固定 simulated private account event 的 source identity 只能来自三类本地 / 模拟 / future-gated label：

| source kind | source identity | 当前含义 | 禁止混用 |
| --- | --- | --- | --- |
| `fixture private stream source` | `fixture:private-stream:mtp-141-local-private-account-event` | 本地 fixture source label，说明 event 来自仓库内 deterministic fixture | 不等于 exchange private stream、listenKey session、secret-backed session 或真实 account stream |
| `simulated private stream source` | `simulated:private-stream:mtp-141-scenario-replay-private-account-event` | scenario replay / simulated input 产生的本地事件 source label | 不等于 Binance user data stream、execution report、broker fill 或 reconciliation |
| `future real private stream label` | `future-gated:private-stream:label-only` | 未来真实 private stream 进入独立 Project 前的门禁标签 | 不等于当前可用真实 private stream、private WebSocket runtime、signed request 或 account endpoint |

MTP-141 的 Core evidence 入口是 `SimulatedPrivateAccountEventSourceIdentityContract` 和 `SimulatedPrivateAccountEventSourceIdentityRecord`。这些类型只保存 source kind、source identity、scenario / dataset / fixture version、fixture replay cursor、source watermark、freshness status 和 checksum；它们不保存 account payload、broker payload、adapter request、schema 或 Runtime object。

## MTP-141 fixture scenario version checksum freshness linkage

`MTP-141-FIXTURE-SCENARIO-VERSION-CHECKSUM-FRESHNESS-LINKAGE`

MTP-141 source identity 必须绑定 deterministic linkage：

- `scenarioID`: `mtp-141-private-account-event-source-scenario`
- `datasetVersion`: `dataset-v1`
- `fixtureVersion`: `fixture-v1`
- `fixtureReplayCursor`: `fixture-replay-cursor:mtp-141:private-account-event:001`
- `sourceWatermark`: `fixture-watermark:mtp-141:2024-01-01T00:06:00Z`
- `freshnessStatus`: `fresh`
- `checksum`: 由三条 source identity record 的 canonical preimage 计算，作为 deterministic evidence，不代表 exchange checksum、broker checkpoint 或 private stream watermark。

这些字段只证明 source identity 可重复、可测试、可追溯，不授权读取真实账户、不连接 private stream、不运行 account snapshot runtime。

## MTP-141 future real private stream label gate

`MTP-141-FUTURE-REAL-PRIVATE-STREAM-LABEL-GATE`

`future-gated:private-stream:label-only` 只能用于说明未来真实 private stream source 需要独立 Human decision、独立 Project Definition、credential / endpoint / adapter / operations gates 和 forbidden capability audit。它不能作为当前 issue 的 source implementation、fallback path、behind-flag runtime、beta preview、adapter capability 或 endpoint descriptor。

## MTP-141 forbidden live stream source tests

`MTP-141-FORBIDDEN-LIVE-STREAM-SOURCE-TESTS`

MTP-141 的 forbidden live stream source tests 必须拒绝：

- signed endpoint call
- account endpoint call
- listenKey creation
- private WebSocket runtime
- private stream runtime
- account snapshot runtime
- secret read
- real account payload consumption
- broker payload import
- adapter request exposure
- adapter capability matrix bypass
- broker / exchange execution adapter connection
- `LiveExecutionAdapter` implementation
- OMS implementation
- real order write

这些 forbidden tests 来自本地 focused XCTest：`testSimulatedPrivateAccountEventSourceIdentityDefinesMTP141DeterministicSource` 和 `testSimulatedPrivateAccountEventSourceIdentityRejectsMTP141ForbiddenLiveSourceBypass`。

## MTP-141 adapter capability matrix bypass guard

`MTP-141-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`

MTP-141 source identity 不能绕过 `LiveReadOnlyAdapterCapabilityMatrixBoundary` 已固定的 adapter capability matrix。Source identity 只说明 local fixture / simulated / future-gated label，不得表达 adapter request、private endpoint capability、broker connection、execution adapter 或 account payload importer。

## MTP-142 simulated account snapshot input shape

`MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-SHAPE`

MTP-142 固定 `SimulatedAccountSnapshotInputContract` 和 `SimulatedAccountSnapshotInputRecord` 为 Core 层 deterministic value contract。该 input shape 只包含：

- `snapshotID`
- `sourceKind`
- `sourceIdentity`
- `observedAt`
- `sourceWatermark`
- `freshnessStatus`
- `inputState`
- `fixtureReplayCursor`
- `deterministicReplayLinkage`
- `readModelFields`
- `checksum`

这些字段只描述 local fixture / simulated source 的 account snapshot input，不是 account endpoint response、broker account payload、SQLite / DuckDB schema、Adapter request 或 Runtime object。

## MTP-142 snapshot id source observedAt freshness state

`MTP-142-SNAPSHOT-ID-SOURCE-OBSERVEDAT-FRESHNESS-STATE`

MTP-142 的 deterministic fixture 固定：

- `snapshotID`: `simulated-account-snapshot|fixture|mtp-142-local-account-snapshot|1704067620|fresh`
- `sourceKind`: `fixture private stream source`
- `sourceIdentity`: `fixture:private-stream:mtp-141-local-private-account-event`
- `observedAt`: `1704067620`
- `sourceWatermark`: `fixture-watermark:mtp-142:2024-01-01T00:07:00Z`
- `freshnessStatus`: `fresh`
- `inputState`: `available fixture input`

`SimulatedAccountSnapshotInputState` 只允许 `available fixture input`、`missing fixture input` 和 `blocked fixture input` 三类状态。`missing` / `blocked` 是 input contract 状态分类，后续 MTP-144 才能深化 stale / blocked / forbidden endpoint evidence；它们不等于真实账户健康状态、broker connectivity 或 live monitoring runtime。

## MTP-142 fixture version checksum deterministic replay linkage

`MTP-142-FIXTURE-VERSION-CHECKSUM-DETERMINISTIC-REPLAY-LINKAGE`

MTP-142 snapshot input 复用 `fixture-v1`，并把 deterministic linkage 固定到 MTP-141 source identity：

- `sourceIdentityLinkage`: `MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`
- `fixtureReplayCursor`: `fixture-replay-cursor:mtp-142:simulated-account-snapshot:001`
- `deterministicReplayLinkage`: `mtp-141-private-account-event-source-scenario|dataset-v1|fixture-v1|fixture-replay-cursor:mtp-142:simulated-account-snapshot:001|MTP-141-source-identity|MTP-142-snapshot-input`
- `checksum`: 由 `SimulatedAccountSnapshotInputRecord.canonicalLine` 的 FNV-1a canonical preimage 计算。

该 checksum 只证明本地 fixture input 可重复、可测试、可追溯，不是 exchange checksum、listenKey checkpoint、broker watermark 或 production stream offset。

## MTP-142 fixture-to-read-model mapping boundary

`MTP-142-FIXTURE-TO-READ-MODEL-MAPPING-BOUNDARY`

MTP-142 只允许 snapshot input 映射到稳定 Read Model 字段：

- `accountSnapshotId`
- `sourceIdentity`
- `observedAt`
- `sourceWatermark`
- `freshnessStatus`
- `inputState`
- `fixtureReplayCursor`
- `deterministicReplayLinkage`
- `checksum`

Mapping 不得包含 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema、listenKey、secret、margin、leverage、real PnL、Live PRO Console、trading button、live command 或 order form。

## MTP-142 account payload isolation tests

`MTP-142-ACCOUNT-PAYLOAD-ISOLATION-TESTS`

MTP-142 的 account payload isolation tests 必须拒绝：

- signed endpoint call
- account endpoint call
- listenKey creation
- private WebSocket runtime
- private stream runtime
- account snapshot runtime
- real account read
- real balance read
- margin / leverage read
- real PnL read
- real account payload exposure
- broker payload import
- adapter request exposure
- Runtime object exposure
- SQLite / DuckDB schema exposure
- account endpoint payload exposure
- fixture-to-read-model mapping bypass
- broker / exchange execution adapter connection
- `LiveExecutionAdapter` implementation
- OMS implementation
- real order write
- Live PRO Console / trading button / live command / order form surface

这些 forbidden tests 来自本地 focused XCTest：`testSimulatedAccountSnapshotInputDefinesMTP142DeterministicContract`、`testSimulatedAccountSnapshotInputRejectsMTP142EndpointRuntimeAndPayloadBypass` 和 `testSimulatedAccountSnapshotInputRejectsMTP142PayloadSchemaRuntimeMapping`。

## MTP-143 simulated account snapshot update fixture semantics

`MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-SEMANTICS`

MTP-143 固定 `SimulatedAccountSnapshotUpdateFixture` 和 `SimulatedAccountSnapshotUpdateFixtureRecord` 为 Core 层 deterministic value contract。该 update fixture 只允许表达三类本地 fixture update：

| update kind | update id | 当前含义 | 禁止混用 |
| --- | --- | --- | --- |
| `account snapshot event fixture` | `simulated-account-snapshot-update|fixture|mtp-143-account-event|001` | MTP-141 source identity 与 MTP-142 snapshot input 的 account snapshot event fixture summary | 不等于真实 account endpoint event、private WebSocket event、execution report 或 broker account event |
| `balance update fixture` | `simulated-account-snapshot-update|fixture|mtp-143-balance-update|001` | 本地 fixture-only balance update summary，只供 read-model 字段命名和 checksum evidence 使用 | 不等于真实余额、broker cash statement、margin、leverage、buying power 或 real PnL |
| `position update fixture` | `simulated-account-snapshot-update|fixture|mtp-143-position-update|001` | 本地 fixture-only position update summary，只供 read-model 字段命名和 checksum evidence 使用 | 不等于 broker position sync、真实持仓、margin position、leverage position 或 reconciliation |

每条 record 必须固定 `fixtureOnlySourceSemantics=fixture-only simulated account snapshot update`、`sourceKind=fixture private stream source`、`sourceIdentity=fixture:private-stream:mtp-141-local-private-account-event`、`snapshotInputID=simulated-account-snapshot|fixture|mtp-142-local-account-snapshot|1704067620|fresh` 和 `fixtureVersion=fixture-v1`。这些字段只证明本地 fixture update 可重复、可测试、可追溯，不授权读取真实账户、不连接 private stream、不运行 account snapshot runtime。

## MTP-143 MTP141 MTP142 linkage checksum boundary

`MTP-143-MTP141-MTP142-LINKAGE-CHECKSUM-BOUNDARY`

MTP-143 update fixture 必须把 deterministic summary linkage 固定到 MTP-141 与 MTP-142：

- `sourceIdentityLinkage`: `MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`
- `snapshotInputID`: `simulated-account-snapshot|fixture|mtp-142-local-account-snapshot|1704067620|fresh`
- `fixtureVersion`: `fixture-v1`
- `matrixID`: `TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE`
- `checksum`: 由三条 update fixture record 的 canonical preimage 计算。

该 checksum 只服务本地 deterministic fixture evidence；它不是 exchange checksum、listenKey checkpoint、private stream watermark、broker reconciliation marker 或 production stream offset。

## MTP-143 balance position update read-model-only boundary

`MTP-143-BALANCE-POSITION-UPDATE-READ-MODEL-ONLY-BOUNDARY`

MTP-143 只允许 update fixture 映射到稳定 Read Model 字段：

- `accountSnapshotUpdateFixtureId`
- `balanceUpdateFixtureId`
- `positionUpdateFixtureId`
- `sourceIdentity`
- `snapshotInputId`
- `fixtureVersion`
- `fixtureOnlySourceSemantics`
- `deterministicSummaryLinkage`
- `checksum`

Mapping 不得包含真实 account payload、broker payload、broker position、real balance、margin、leverage、real PnL、execution report、broker fill、reconciliation、Adapter request、Runtime object、SQLite / DuckDB schema、Live PRO Console、trading button、live command 或 order form。

## MTP-143 update fixture interpretation isolation tests

`MTP-143-UPDATE-FIXTURE-INTERPRETATION-ISOLATION-TESTS`

MTP-143 的 interpretation isolation tests 必须拒绝：

- signed endpoint call
- account endpoint call
- listenKey creation
- private WebSocket runtime
- private stream runtime
- account snapshot runtime
- real account read / update
- broker position sync
- real balance / margin / leverage / real PnL read
- broker / exchange execution adapter connection
- `LiveExecutionAdapter` implementation
- execution report consumption
- broker fill consumption
- reconciliation runtime
- OMS implementation
- real order lifecycle / real order write
- Live PRO Console / trading button / live command / order form surface

这些 forbidden tests 来自本地 focused XCTest：`testSimulatedAccountSnapshotUpdateFixtureDefinesMTP143DeterministicContract` 和 `testSimulatedAccountSnapshotUpdateFixtureRejectsMTP143RealAccountBrokerPnLBypass`。

## MTP-144 freshness stale blocked missing evidence

`MTP-144-FRESHNESS-STALE-BLOCKED-MISSING-EVIDENCE`

MTP-144 固定 `SimulatedAccountSnapshotFreshnessEvidenceContract` 和 `SimulatedAccountSnapshotFreshnessEvidenceItem` 为 Core 层 deterministic value contract。该 freshness evidence 只允许表达四类本地 fixture evidence：

| status | ageSeconds | inputState | boundaryReasonCode | 禁止混用 |
| --- | ---: | --- | --- | --- |
| `fresh simulated freshness evidence` | 60 | `available fixture input` | `fixture-freshness-within-threshold` | 不等于真实账户健康、live stream heartbeat 或 broker connectivity |
| `stale simulated freshness evidence` | 960 | `available fixture input` | `fixture-freshness-threshold-exceeded` | 不等于 exchange delay、listenKey expiry、broker outage 或 production incident |
| `blocked simulated freshness evidence` | 0 | `blocked fixture input` | `forbidden-capability-boundary-held` | 不等于真实 account endpoint blocked、broker risk block 或 OMS reject |
| `missing simulated freshness evidence` | 0 | `missing fixture input` | `fixture-input-absent` | 不等于真实账户缺失、broker payload missing 或 persistence corruption |

## MTP-144 MTP141 MTP142 MTP143 freshness checksum boundary

`MTP-144-MTP141-MTP142-MTP143-FRESHNESS-CHECKSUM-BOUNDARY`

MTP-144 freshness evidence 必须同时绑定：

- `sourceIdentityLinkage`: `MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`
- `snapshotInputID`: `simulated-account-snapshot|fixture|mtp-142-local-account-snapshot|1704067620|fresh`
- `updateFixtureChecksum`: `SimulatedAccountSnapshotUpdateFixture.requiredChecksum`
- `matrixID`: `TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE`
- `checksum`: 由四条 freshness evidence item 的 canonical preimage 计算。

该 checksum 只服务本地 deterministic freshness evidence；它不是 exchange checksum、listenKey checkpoint、private stream watermark、broker reconciliation marker、account endpoint payload hash 或 production health status。

## MTP-144 forbidden endpoint runtime tests

`MTP-144-FORBIDDEN-ENDPOINT-RUNTIME-TESTS`

MTP-144 的 forbidden endpoint/runtime tests 必须拒绝：

- signed endpoint call
- account endpoint call
- listenKey creation / keepalive
- private WebSocket runtime
- private stream runtime
- account snapshot runtime
- broker / exchange execution adapter connection
- `LiveExecutionAdapter` implementation
- OMS implementation
- real order write

## MTP-144 payload schema runtime non-exposure tests

`MTP-144-PAYLOAD-SCHEMA-RUNTIME-NON-EXPOSURE-TESTS`

MTP-144 的 read-model-only evidence 只允许输出 `freshnessEvidenceId`、`sourceIdentity`、`snapshotInputId`、`updateFixtureChecksum`、`freshnessStatus`、`inputState`、`ageSeconds`、`staleAfterSeconds`、`boundaryReasonCode` 和 `checksum`。它必须拒绝 account endpoint payload、real account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 和 broker state 暴露。

## MTP-144 validation anchors

`MTP-144-SIMULATED-ACCOUNT-SNAPSHOT-FRESHNESS-EVIDENCE-VALIDATION`

Required validation：

- `swift test --filter SimulatedAccountSnapshotFreshnessEvidence`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedAccountSnapshotFreshnessEvidenceContract`、`SimulatedAccountSnapshotFreshnessEvidenceItem`、`SimulatedAccountSnapshotFreshnessEvidenceStatus` 和 `SimulatedAccountSnapshotFreshnessEvidenceForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-144 focused tests。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-144 freshness / stale / blocked / missing evidence、MTP-141 / MTP-142 / MTP-143 freshness checksum boundary、forbidden endpoint/runtime tests、payload/schema/runtime non-exposure tests 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-144 simulated account snapshot freshness evidence shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-144 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-144 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-144 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate freshness evidence anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-144 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。

MTP-144 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、freshness runtime 或 Workbench / Report / Events surface；MTP-145 才能深化 read-model-only surface。Project stage closeout 仍归属 MTP-146。

## MTP-140 L3.1 APB / L3.2 simulation gate relationship

`MTP-140-L31-APB-L32-SIMULATION-GATE-RELATIONSHIP`

MTP-140 固定 L3.1 APB read-model-only evidence 与 L3.2 simulation gate 的关系：

- L3.1 APB 已完成 account / position / balance read-model-only terminology、snapshot identity、source / freshness evidence、deterministic fixture、forbidden real account tests 和 Workbench / Report / Events read-model-only surface。
- L3.2 simulation gate 可以复用 L3.1 APB 的 read-model-only vocabulary，例如 evidence id、source identity、freshness / stale / blocked / missing 状态和 fixture-to-read-model mapping boundary。
- L3.2 不得把 L3.1 APB read-model-only evidence 反向升级为 account snapshot runtime、private stream runtime、real account read、broker position sync、real balance、margin、leverage 或 real PnL。
- L3.2 不得把 Workbench / Report / Events APB surface 写成 account connect、broker connect、Live PRO Console、trading button、live command 或 order form。

## MTP-140 first executable candidate non-authorization

`MTP-140-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record、Linear Project issue order、next eligible candidate、Backlog issue、label、priority、assignee 或 estimate 都不构成执行授权。MTP-140 只有在 Linear live-read 中经 Parent Codex queue preflight 推进为唯一 active issue 后才可执行。

该事实不改变以下规则：

- `docs/product/mtpro-live-readiness-roadmap-v1.md` 不授权 execution。
- `docs/planning/projects/*` 不授权 execution。
- MTP-140 完成后不得自动推进 MTP-141。
- MTP-141 至 MTP-146 必须继续保持 Backlog / non-executable，直到各自成为 live-read 中唯一 eligible issue。

## MTP-140 forbidden capability baseline

`MTP-140-FORBIDDEN-CAPABILITY-BASELINE`

MTP-140 必须保持以下 forbidden capabilities：

- signed endpoint
- account endpoint / listenKey
- listenKey create / keepalive
- private WebSocket runtime
- private stream runtime
- account snapshot runtime
- account / position / balance runtime
- real account read
- broker position sync
- real account balance
- margin / leverage
- real PnL runtime
- broker / exchange execution adapter
- `LiveExecutionAdapter`
- OMS
- real order lifecycle
- real submit / cancel / replace
- execution report
- broker fill
- reconciliation
- Live PRO Console
- trading button
- live command
- order form
- emergency stop / shutdown / restore executable action
- Graphify update
- Figma change

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成当前支持、beta preview、local fallback、behind flag、partially implemented 或后续 issue 自动授权。

## MTP-140 validation anchors

`MTP-140-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-140 private stream terminology、account snapshot terminology、fixture / simulated / future real boundary、L3.1 APB / L3.2 relationship、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-140 private stream / account snapshot simulation gate shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE` 和 MTP-140 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-140 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-140 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-140 contract、matrix、validation plan、domain context、latest summary、automation readiness doc 和 forbidden capability boundary strings。

MTP-140 不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle，不新增 stage audit input；Project stage closeout 仍归属 MTP-146。

## MTP-141 validation anchors

`MTP-141-SOURCE-IDENTITY-VALIDATION`

Required validation：

- `swift test --filter SimulatedPrivateAccountEventSourceIdentity`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedPrivateAccountEventSourceIdentityContract`、`SimulatedPrivateAccountEventSourceIdentityRecord`、`SimulatedPrivateAccountEventSourceKind` 和 `SimulatedPrivateAccountEventSourceForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-141 focused tests。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-141 source identity、fixture scenario version checksum freshness linkage、future real private stream label gate、forbidden live stream source tests、adapter capability matrix bypass guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-141 source identity shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-141 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-141 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-141 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate source identity anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-141 source / test / docs / validation anchors。

MTP-141 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 simulated account snapshot input contract；MTP-142 才能深化 snapshot input shape。Project stage closeout 仍归属 MTP-146。

## MTP-142 validation anchors

`MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-VALIDATION`

Required validation：

- `swift test --filter SimulatedAccountSnapshotInput`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedAccountSnapshotInputContract`、`SimulatedAccountSnapshotInputRecord`、`SimulatedAccountSnapshotInputState` 和 `SimulatedAccountSnapshotInputForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-142 focused tests。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-142 snapshot input shape、snapshot id / source / observedAt / freshness / state、fixture version / checksum / replay linkage、fixture-to-read-model mapping boundary、account payload isolation tests 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-142 simulated account snapshot input shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-142 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-142 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-142 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate snapshot input anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-142 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。

MTP-142 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 account snapshot runtime、private stream runtime、balance / position update fixture semantics、freshness runtime 或 Workbench / Report / Events surface；MTP-143 至 MTP-145 才能分别深化这些后续 scope。Project stage closeout 仍归属 MTP-146。

## MTP-143 validation anchors

`MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-VALIDATION`

Required validation：

- `swift test --filter SimulatedAccountSnapshotUpdateFixture`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedAccountSnapshotUpdateFixture`、`SimulatedAccountSnapshotUpdateFixtureRecord`、`SimulatedAccountSnapshotUpdateFixtureKind`、`SimulatedAccountSnapshotUpdateInterpretationBoundary` 和 `SimulatedAccountSnapshotUpdateFixtureForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-143 focused tests。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-143 update fixture semantics、MTP-141 / MTP-142 linkage checksum boundary、balance / position update read-model-only boundary、update fixture interpretation isolation tests 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-143 simulated account snapshot update fixture shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-143 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-143 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-143 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate update fixture anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-143 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。

MTP-143 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、freshness runtime 或 Workbench / Report / Events surface；MTP-144 / MTP-145 才能分别深化后续 freshness / forbidden tests 和 read-model-only surface。Project stage closeout 仍归属 MTP-146。
