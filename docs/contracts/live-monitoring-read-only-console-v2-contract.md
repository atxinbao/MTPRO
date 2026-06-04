# Live Monitoring Read-only Console v2 Contract

日期：2026-05-30

执行者：Codex

本文档定义 `MTPRO Live Monitoring Read-only Console v2` 的 MTP-147 合同入口：L3.3 Live Monitoring Read-only Console v2 terminology、monitoring evidence source boundary、Read Model / ViewModel consumption boundary、L3.3 handoff boundary、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。

本文档只服务 `MTP-147 Define Live Monitoring Read-only Console v2 terminology and boundary` 的术语 / 边界 / 验证锚点。它不实现 monitoring evidence surface，不实现 live readiness runtime，不接 signed endpoint、account endpoint / listenKey，不实现 private WebSocket runtime、private stream runtime、account snapshot runtime，不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL；不连接 broker，不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form；不运行 Graphify，不修改 Figma。

## MTP-147 Live Monitoring Read-only Console v2 terminology

`MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-TERMINOLOGY`

MTP-147 只允许定义以下 L3.3 术语，不允许把术语升级为 runtime、connection 或 UI command：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `Live Monitoring Read-only Console v2` | L3.3 只读 monitoring evidence console 的合同名称，用来组织 L3.0 / L3.1 / L3.2 已完成 evidence 的 monitoring 解释层 | 不等于 Live Monitoring runtime、Live readiness runtime、Live PRO Console、broker console 或交易控制台 |
| `monitoring evidence` | 由已完成 read-model-only、fixture、paper、simulated 或 future-gated source label 派生的只读观察证据 | 不等于 runtime telemetry、account endpoint payload、private stream event、broker state 或 production monitoring agent |
| `monitoring source boundary` | 说明 monitoring evidence 只能来自 L3.0 / L3.1 / L3.2 已完成证据链的来源边界 | 不等于 source adapter、connection manager、private stream runtime 或 account snapshot runtime |
| `read-only monitoring state` | blocked、stale、missing、simulated、fixture、future-gated 等只读状态解释 | 不等于实时连接状态、自动恢复动作、交易授权或 live command enablement |
| `monitoring boundary entry` | Workbench / Report / Events 后续可引用的 boundary anchor、source anchor 和 validation anchor | 不等于 Dashboard surface、Swift ViewModel implementation 或 Event Timeline item implementation |
| `L3.3 monitoring handoff` | MTP-147 把 terminology / boundary 交给 MTP-148 至 MTP-153 的范围边界 | 不自动推进后续 issue，不授权 monitoring source identity、health evidence、connection explanation、forbidden tests、surface 或 stage closeout |

## MTP-147 monitoring evidence source boundary

`MTP-147-MONITORING-EVIDENCE-SOURCE-BOUNDARY`

MTP-147 固定 Live Monitoring Read-only Console v2 的 source boundary：

1. L3.0 `Live Read-only Readiness Boundary` 是 monitoring evidence 的 readiness / endpoint / adapter capability baseline。它只提供 future gates、forbidden capability baseline 和 read-model-only boundary，不提供 live runtime 或 real connection。
2. L3.1 `Account / Position / Balance Read-model-only` 是 monitoring evidence 的 account / position / balance vocabulary input。它只提供 fixture / paper / simulated / future-gated real source label、snapshot identity、freshness / stale / blocked / missing 解释和 read-model-only surface，不读取真实账户。
3. L3.2 `Private Stream / Account Snapshot Simulation Gate` 是 monitoring evidence 的 private stream / account snapshot simulation input。它只提供 local fixture / simulated source identity、snapshot input、update fixture、freshness evidence 和 read-model-only surface，不创建 listenKey、不连接 private WebSocket、不运行 account snapshot runtime。
4. L3.3 只能在后续 issue 中把上述 evidence 组织为 monitoring source identity、health / freshness evidence、connection readiness explanation、forbidden runtime / endpoint / UI command tests、Workbench / Report / Events read-model-only surface 和 stage closeout。

MTP-147 不新增 source implementation，不新增 fixture payload，不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle。

## MTP-147 Read Model / ViewModel consumption boundary

`MTP-147-READ-MODEL-VIEWMODEL-CONSUMPTION-BOUNDARY`

MTP-147 固定后续 Workbench / Report / Events 的消费边界：

- Workbench 只能消费后续 MTP-152 允许的 Read Model / ViewModel，不直接读取 adapter request、Runtime object、SQLite / DuckDB schema、account payload、broker payload、secret config 或 broker state。
- Report 只能汇总 monitoring evidence、source anchors、validation anchors 和 boundary notes，不生成 live readiness runtime report。
- Events 只能展示 read-model-only evidence trace，不打开 query console、runtime inspector、connection debugger 或 production operations panel。
- Dashboard / App 不得提供 API key input、secret storage、account connect、broker connect、private stream connect、reconnect command、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore command。

## MTP-147 L3.3 handoff boundary

`MTP-147-L33-HANDOFF-BOUNDARY`

MTP-147 的 handoff 只交付 terminology / boundary input：

1. MTP-148 才能定义 monitoring source identity from L3.0 / L3.1 / L3.2 evidence。
2. MTP-149 才能定义 account snapshot / private stream simulation gate health and freshness evidence。
3. MTP-150 才能定义 connection readiness / stale / blocked / missing explanation without runtime connection。
4. MTP-151 才能定义 forbidden Live Monitoring runtime / endpoint / UI command tests。
5. MTP-152 才能 add Workbench / Report / Events Live Monitoring v2 read-model-only evidence surface。
6. MTP-153 才能 close validation matrix / automation readiness / stage audit input。
7. L3.4 Strategy / Trader Instance Readiness 和 L4 Live Production / Trading Commands 保持 Future Gated；MTP-147 不授权 strategy-to-broker command path、broker command、OMS、Live PRO Console 或 live command。

MTP-147 完成后不得自动推进 MTP-148。MTP-148 至 MTP-153 必须继续保持 Backlog / non-executable，直到各自成为 Linear live-read 中唯一 eligible issue。

## MTP-147 first executable candidate non-authorization

`MTP-147-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record、Linear Project issue order、next eligible candidate、Backlog issue、label、priority、assignee 或 estimate 都不构成执行授权。MTP-147 只有在 Linear live-read 中经 Parent Codex queue preflight 和 symphony-issue 调度后，作为唯一 active configured executable issue 时才可以执行。

该事实不改变以下规则：

- `docs/product/mtpro-live-readiness-roadmap-v1.md` 不授权 execution。
- `docs/planning/projects/*` 不授权 execution。
- MTP-147 完成后不得自动推进 MTP-148。
- MTP-148 至 MTP-153 必须继续保持 Backlog / non-executable，直到各自成为 live-read 中唯一 eligible issue。

## MTP-147 forbidden capability baseline

`MTP-147-FORBIDDEN-CAPABILITY-BASELINE`

MTP-147 必须保持以下 forbidden capabilities：

- signed endpoint
- account endpoint / listenKey
- listenKey create / keepalive
- private WebSocket runtime
- private stream runtime
- account snapshot runtime
- live readiness runtime
- Live Monitoring runtime
- account / position / balance runtime
- real account read
- broker position sync
- real account balance
- real position
- margin / leverage
- real PnL runtime
- broker action
- broker integration
- broker adapter
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
- production operations command
- Graphify update
- Figma change

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成当前支持、beta preview、local fallback、behind flag、partially implemented 或后续 issue 自动授权。

## MTP-147 validation anchors

`MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 MTP-147 terminology、monitoring evidence source boundary、Read Model / ViewModel consumption boundary、L3.3 handoff boundary、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-147 Live Monitoring Read-only Console v2 shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2` 和 MTP-147 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-147 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-147 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring Read-only Console v2 terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-147 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。

MTP-147 不新增 Swift production code，不新增 focused XCTest，不新增 Dashboard smoke handle，不新增 App read model，不新增 Core / Runtime / Dashboard behavior，不新增 stage audit input；Project stage closeout 仍归属 MTP-153。

## MTP-148 monitoring source identity

`MTP-148-MONITORING-SOURCE-IDENTITY`

MTP-148 固定 `LiveMonitoringSourceIdentityContract`、`LiveMonitoringSourceIdentityRecord`、`LiveMonitoringSourceEvidenceLayer`、`LiveMonitoringSourceEvidenceOrigin`、`LiveMonitoringSourceStatus`、`LiveMonitoringSourceFreshnessSemantics` 和 `LiveMonitoringSourceIdentityForbiddenCapability` 为 Core 层 deterministic source identity 合同。

该合同只把 L3.0 / L3.1 / L3.2 已完成 evidence 解释为 monitoring source identity：

| Evidence layer | Source identity | Evidence origin | Status / freshness |
| --- | --- | --- | --- |
| L3.0 Live read-only readiness boundary | `boundary:l3.0:live-read-only-readiness` | boundary | blocked / blocked |
| L3.1 account / position / balance read-model-only | `fixture:mtp-137-account-position-balance-read-model-only` | fixture + read-model-only | available / fresh |
| L3.2 private stream / account snapshot simulation gate | `simulated:private-stream:mtp-141-scenario-replay-private-account-event` | fixture + simulated + read-model-only | available / fresh |
| future real account unavailable label | `unavailable:future-real-account-source-label-only` | boundary | unavailable / unavailable |

## MTP-148 evidence origin boundary

`MTP-148-EVIDENCE-ORIGIN-BOUNDARY-FIXTURE-SIMULATED-READ-MODEL-ONLY`

MTP-148 只允许 `boundary evidence`、`fixture evidence`、`simulated evidence` 和 `read-model-only evidence` 四类 origin。任何 source identity 都不得包含 API key、secret、listenKey、signed endpoint、account endpoint、private WebSocket、adapter request、Runtime object、account payload、broker payload、broker state、Live PRO Console、trading button、live command 或 order form。

## MTP-148 source freshness status unavailable semantics

`MTP-148-SOURCE-FRESHNESS-STATUS-UNAVAILABLE-SEMANTICS`

MTP-148 的 source freshness / status 只描述 evidence 解释层：

- `available` / `fresh` 表示 deterministic fixture、simulated 或 read-model-only evidence 当前可用于展示。
- `blocked` 表示 source 被 L3.0 / L3.3 forbidden capability boundary 阻断。
- `unavailable` 表示 future real account source 当前不可用，不触发 endpoint call、listenKey、private stream、broker sync 或 reconnect action。

这些状态不等于 live connection state、broker connectivity、private stream health、account snapshot runtime health 或 production monitoring agent 状态。

## MTP-148 simulated fixture not real account guard

`MTP-148-SIMULATED-FIXTURE-NOT-REAL-ACCOUNT-GUARD`

MTP-148 必须防止 simulated / fixture evidence 被解释为真实账户或真实 broker state。`LiveMonitoringSourceIdentityContract` 的 forbidden flags 必须全部为 false：不创建 real source adapter，不读取 real account / position / balance，不调用 signed endpoint / account endpoint，不创建 listenKey，不打开 private WebSocket，不运行 private stream runtime 或 account snapshot runtime，不读取 API key / secret，不暴露 account payload、broker payload、broker state、adapter request、Runtime object 或 database schema，不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、live command、trading button 或 order form。

## MTP-148 validation anchors

`MTP-148-LIVE-MONITORING-SOURCE-IDENTITY-VALIDATION`

Required validation：

- `swift test --filter LiveMonitoringSourceIdentity`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Core/LiveMonitoringSourceIdentity.swift` 必须包含 `LiveMonitoringSourceIdentityContract`、`LiveMonitoringSourceIdentityRecord`、`LiveMonitoringSourceEvidenceLayer`、`LiveMonitoringSourceEvidenceOrigin`、`LiveMonitoringSourceStatus`、`LiveMonitoringSourceFreshnessSemantics` 和 `LiveMonitoringSourceIdentityForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringSourceIdentityDefinesMTP148DeterministicSource` 和 `testLiveMonitoringSourceIdentityRejectsMTP148RealSourceEndpointAndPayloadBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 MTP-148 source identity、origin boundary、freshness / status / unavailable semantics、simulated / fixture not real account guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-148 monitoring source identity shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-148 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-148 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-148 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring source identity anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-148 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。

MTP-148 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 monitoring surface；MTP-152 才能接入 Workbench / Report / Events read-model-only surface。Project stage closeout 仍归属 MTP-153。

## MTP-149 simulation gate health / freshness evidence

`MTP-149-SIMULATION-GATE-HEALTH-FRESHNESS-EVIDENCE`

MTP-149 固定 `LiveMonitoringSimulationGateHealthContract`、`LiveMonitoringSimulationGateHealthEvidenceItem`、`LiveMonitoringSimulationGateHealthStatus`、`LiveMonitoringSimulationGateFreshnessExplanation` 和 `LiveMonitoringSimulationGateHealthForbiddenCapability` 为 Core 层 deterministic health evidence 合同。

该合同只复用 MTP-148 monitoring source identity 和 MTP-144 simulated freshness fixture：

| MTP-144 freshness status | MTP-149 health status | Freshness explanation | Display semantics |
| --- | --- | --- | --- |
| `fresh` | `nominal` | `withinThreshold` | nominal read-only evidence |
| `stale` | `stale` | `thresholdExceeded` | stale read-only evidence |
| `blocked` | `blocked` | `blockedByBoundary` | boundary-held read-only evidence without reconnect or recovery action |
| `missing` | `missing` | `fixtureInputMissing` | absent read-only evidence without fallback action |

## MTP-149 health / freshness not real account health

`MTP-149-HEALTH-FRESHNESS-NOT-REAL-ACCOUNT-HEALTH`

MTP-149 的 health / freshness 只解释 simulated gate 状态，不代表真实账户、真实 broker 连接或真实私有流状态。`LiveMonitoringSimulationGateHealthContract` 不创建 source adapter，不读取真实 account / position / balance，不调用 signed endpoint / account endpoint，不创建 listenKey，不打开 private WebSocket，不运行 private stream runtime 或 account snapshot runtime。

## MTP-149 read-model-only non-exposure

`MTP-149-READ-MODEL-ONLY-NON-EXPOSURE`

MTP-149 evidence 只允许 fixture / simulated / read-model-only source，且不得暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、broker payload 或 account endpoint payload。blocked evidence 只能作为展示语义，不触发 reconnect、recovery、incident command、live command、trading button、order form 或 real order write。

## MTP-149 validation anchors

`MTP-149-LIVE-MONITORING-SIMULATION-GATE-HEALTH-VALIDATION`

Required validation：

- `swift test --filter LiveMonitoringSimulationGateHealth`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Core/LiveMonitoringSimulationGateHealth.swift` 必须包含 `LiveMonitoringSimulationGateHealthContract`、`LiveMonitoringSimulationGateHealthEvidenceItem`、`LiveMonitoringSimulationGateHealthStatus`、`LiveMonitoringSimulationGateFreshnessExplanation` 和 `LiveMonitoringSimulationGateHealthForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringSimulationGateHealthDefinesMTP149DeterministicEvidence` 和 `testLiveMonitoringSimulationGateHealthRejectsMTP149RuntimeEndpointPayloadAndSchemaBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 MTP-149 health / freshness evidence、not real account health、read-model-only non-exposure 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-149 simulation gate health shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-149 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-149 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-149 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring simulation gate health evidence anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-149 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。

MTP-149 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 monitoring surface；MTP-152 才能接入 Workbench / Report / Events read-model-only surface。Project stage closeout 仍归属 MTP-153。

## MTP-150 connection readiness explanation

`MTP-150-CONNECTION-READINESS-EXPLANATION`

MTP-150 固定 `LiveMonitoringConnectionReadinessExplanationContract`、`LiveMonitoringConnectionReadinessExplanationItem`、`LiveMonitoringConnectionReadinessExplanationState`、`LiveMonitoringConnectionReadinessDisplaySemantics` 和 `LiveMonitoringConnectionReadinessForbiddenCapability` 为 Core 层 deterministic explanation 合同。

该合同只从 MTP-148 source identity 和 MTP-149 simulation gate health evidence 派生 readiness / stale / blocked / missing explanation：

| MTP-149 health status | MTP-150 readiness state | UI display semantics | Report semantics |
| --- | --- | --- | --- |
| `nominal` | `readiness` | readiness read-only explanation | readiness explanation derived from simulated evidence |
| `stale` | `stale` | stale read-only explanation | stale readiness explanation derived from simulated evidence |
| `blocked` | `blocked` | blocked boundary-held explanation | blocked readiness explanation from boundary evidence |
| `missing` | `missing` | missing absent-evidence explanation | missing readiness explanation from absent evidence |

## MTP-150 stale / blocked / missing UI / report semantics

`MTP-150-STALE-BLOCKED-MISSING-UI-REPORT-SEMANTICS`

MTP-150 的 stale / blocked / missing 语义只服务后续 MTP-152 Workbench / Report / Events read-model-only surface：

- Workbench 只能展示 readiness explanation、health evidence id、readiness state、display semantics、report semantics、boundary semantics 和 checksum。
- Report 只能把 readiness / stale / blocked / missing 作为 issue evidence chain 的解释字段汇总。
- Events 只能展示 read-model-only trace，不打开 runtime inspector、connection debugger、reconnect、recovery、fallback source、account connect、broker connect 或 private stream connect。

这些语义不得写成真实 live readiness、真实 connection status、broker connectivity、private stream health、account endpoint health、production monitoring runtime 或 incident action。

## MTP-150 no runtime connection boundary

`MTP-150-NO-RUNTIME-CONNECTION-BOUNDARY`

MTP-150 必须保持 no-runtime-connection boundary：`LiveMonitoringConnectionReadinessExplanationContract` 的 forbidden flags 必须全部为 false，不调用 signed endpoint / account endpoint，不创建 listenKey，不打开 private WebSocket，不运行 private stream runtime 或 account snapshot runtime，不实现 connection manager，不打开 runtime connection，不实现 live readiness implementation 或 Live Monitoring runtime。

MTP-150 不读取真实 account / position / balance，不消费或暴露 account payload、account endpoint payload、broker payload、broker state、Adapter request、Runtime object 或 SQLite / DuckDB schema；不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 real order write。

## MTP-150 readiness explanation not live readiness

`MTP-150-READINESS-EXPLANATION-NOT-LIVE-READINESS`

MTP-150 中的 `readiness` 只表示 deterministic simulated evidence 可被解释并展示。它不是 live readiness implementation，不表示真实连接已建立，不授权 source adapter、private stream runtime、account snapshot runtime、broker connector、Live PRO Console、trading button、live command 或 order form。

## MTP-150 validation anchors

`MTP-150-LIVE-MONITORING-CONNECTION-READINESS-VALIDATION`

Required validation：

- `swift test --filter LiveMonitoringConnectionReadiness`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Core/LiveMonitoringConnectionReadinessExplanation.swift` 必须包含 `LiveMonitoringConnectionReadinessExplanationContract`、`LiveMonitoringConnectionReadinessExplanationItem`、`LiveMonitoringConnectionReadinessExplanationState`、`LiveMonitoringConnectionReadinessDisplaySemantics` 和 `LiveMonitoringConnectionReadinessForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringConnectionReadinessExplanationDefinesMTP150DeterministicEvidence` 和 `testLiveMonitoringConnectionReadinessExplanationRejectsMTP150RuntimeEndpointAndCommandBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 MTP-150 connection readiness explanation、stale / blocked / missing UI / report semantics、no runtime connection boundary、not live readiness 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-150 connection readiness explanation shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-150 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-150 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-150 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring connection readiness explanation anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-150 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。

MTP-150 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 monitoring surface；MTP-152 才能接入 Workbench / Report / Events read-model-only surface。Project stage closeout 仍归属 MTP-153。

## MTP-151 forbidden Live Monitoring capability tests

`MTP-151-FORBIDDEN-LIVE-MONITORING-CAPABILITY-TESTS`

MTP-151 固定 `LiveMonitoringForbiddenCapabilityTestContract`、`LiveMonitoringForbiddenCapabilityTestCase`、`LiveMonitoringForbiddenCapabilityTestDomain` 和 `LiveMonitoringForbiddenCapabilityTestAssertion` 为 Core 层 deterministic forbidden test matrix。

该合同只从 MTP-148 source identity、MTP-149 simulation gate health evidence 和 MTP-150 connection readiness explanation 派生检查覆盖：

| Test domain | Required assertions |
| --- | --- |
| `endpoint` | signed endpoint、account endpoint、listenKey |
| `streamRuntime` | private WebSocket runtime、private stream runtime、account snapshot runtime |
| `liveRuntime` | connection manager、runtime connection、live readiness runtime、Live Monitoring runtime |
| `brokerExecution` | broker adapter、exchange execution adapter、`LiveExecutionAdapter`、OMS |
| `uiCommand` | Live PRO Console、trading button、live command、order form、stop / shutdown / restore command |

## MTP-151 forbidden endpoint / runtime / broker / UI coverage

`MTP-151-FORBIDDEN-ENDPOINT-RUNTIME-BROKER-UI-COVERAGE`

MTP-151 的 coverage 必须通过 focused Core tests 证明 forbidden matrix 覆盖 endpoint、listenKey、private stream、broker、Live PRO Console、trading button、live command、order form 和 stop / shutdown / restore command。检查必须保持 deterministic local-only、read-model-only、no-network，不依赖真实网络、真实账户或真实 broker。

## MTP-151 monitoring evidence not live runtime guard

`MTP-151-MONITORING-EVIDENCE-NOT-LIVE-RUNTIME-GUARD`

MTP-151 必须防止 MTP-147 至 MTP-150 的 monitoring evidence 被升级为 live readiness runtime、Live Monitoring runtime、connection manager 或 runtime connection。`LiveMonitoringForbiddenCapabilityTestContract` 的 runtime / endpoint / broker / UI command flags 必须全部为 false，且 Codable payload 不能绕过。

## MTP-151 validation anchors

`MTP-151-LIVE-MONITORING-FORBIDDEN-CAPABILITY-VALIDATION`

Required validation：

- `swift test --filter LiveMonitoringForbiddenCapability`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Core/LiveMonitoringForbiddenCapabilityTests.swift` 必须包含 `LiveMonitoringForbiddenCapabilityTestContract`、`LiveMonitoringForbiddenCapabilityTestCase`、`LiveMonitoringForbiddenCapabilityTestDomain` 和 `LiveMonitoringForbiddenCapabilityTestAssertion`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringForbiddenCapabilityTestsDefineMTP151CoverageMatrix` 和 `testLiveMonitoringForbiddenCapabilityTestsRejectMTP151RuntimeEndpointAndUIBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 MTP-151 forbidden capability tests、endpoint / runtime / broker / UI coverage、monitoring evidence not live runtime guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-151 forbidden capability tests shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-151 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-151 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-151 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring forbidden capability tests anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-151 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。

MTP-151 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 monitoring surface 或完整实盘监控台页面重设计；MTP-152 才能接入 Workbench / Report / Events read-model-only surface。Project stage closeout 仍归属 MTP-153。

## MTP-152 Workbench / Report / Events read-model-only surface

`MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`

MTP-152 固定 `LiveMonitoringReadOnlyConsoleV2SurfaceReadModel`、`LiveMonitoringReadOnlyConsoleV2SurfaceViewModel` 和 `LiveMonitoringReadOnlyConsoleV2TraceItem` 为 App 层 read-model-only surface。该 surface 只消费 MTP-148 `LiveMonitoringSourceIdentityContract`、MTP-149 `LiveMonitoringSimulationGateHealthContract`、MTP-150 `LiveMonitoringConnectionReadinessExplanationContract` 和 MTP-151 `LiveMonitoringForbiddenCapabilityTestContract` 的 deterministic evidence。

Workbench / Report / Events 只能展示 source identity、source freshness、health / freshness evidence、readiness / stale / blocked / missing explanation、forbidden capability test coverage、dashboard panel summary 和 Event Timeline trace。该 surface 不新增或修改 Core semantics，不读取 Persistence adapter，不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload 或 broker state。

## MTP-152 monitoring source freshness explanation surface

`MTP-152-MONITORING-SOURCE-FRESHNESS-EXPLANATION-SURFACE`

MTP-152 的 Report / Workbench 文案只能把 MTP-148 至 MTP-151 的 source freshness、health freshness、readiness explanation 和 forbidden capability coverage 表达为只读 evidence summary：

| Evidence input | MTP-152 surface output | Boundary |
| --- | --- | --- |
| MTP-148 source identity | source identities、source layers、source status、source freshness、evidence origins | 不创建 real source adapter，不读取真实 account / position / balance |
| MTP-149 simulation gate health | health evidence IDs、health status、freshness status、freshness explanation | 不表示真实账户健康、broker connectivity 或 production monitoring runtime |
| MTP-150 readiness explanation | readiness / stale / blocked / missing state、display semantics、explanation rows | 不表示真实连接已建立，不实现 live readiness |
| MTP-151 forbidden capability tests | forbidden test IDs、domains、assertions、no-network guard | 不实现 endpoint、runtime、broker adapter 或 UI command |

## MTP-152 no runtime / adapter / schema / payload / broker state surface

`MTP-152-NO-RUNTIME-ADAPTER-SCHEMA-PAYLOAD-BROKER-STATE-SURFACE`

MTP-152 必须证明 Workbench / Report / Events surface 的 forbidden flags 全部保持 false：不暴露 Live PRO Console、trading button、live command、order form、Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、signed endpoint、account endpoint、listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、connection manager、runtime connection、live readiness runtime、Live Monitoring runtime、broker adapter、exchange execution adapter、`LiveExecutionAdapter`、OMS、real account、real position、real balance 或 real order command。

`DashboardShellSnapshot.smokeSummary` 可以新增 `liveMonitoringReadOnlyConsoleV2Surface=4` 作为 read-model-only evidence handle；该 handle 不是 Dashboard command、Live PRO Console、connection control、order form 或 trading button。

## MTP-152 validation anchors

`MTP-152-LIVE-MONITORING-V2-SURFACE-VALIDATION`

Required validation：

- `swift test --filter LiveMonitoringReadOnlyConsoleV2`
- `swift test --filter AppTests`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

Focused validation anchors：

- `Sources/Dashboard/Report/LiveMonitoringReadOnlyConsoleV2Surface.swift` 必须包含 `LiveMonitoringReadOnlyConsoleV2SurfaceReadModel`、`LiveMonitoringReadOnlyConsoleV2SurfaceViewModel` 和 `LiveMonitoringReadOnlyConsoleV2TraceItem`。
- `Sources/Dashboard/ReadModels/App.swift` 必须把 `liveMonitoringReadOnlyConsoleV2Surface` 接入 Report / Dashboard read model 和 view model。
- `Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift` 必须包含 `liveMonitoringReadOnlyConsoleV2Surface` section，并输出 MTP-152 Event Timeline read-model-only evidence item。
- `Sources/Dashboard/DashboardShell.swift` 必须包含 Workbench / Report metrics、details 和 smoke handle `liveMonitoringReadOnlyConsoleV2Surface=4`。
- `Tests/AppTests/AppTests.swift` 必须包含 `testLiveMonitoringReadOnlyConsoleV2SurfaceAggregatesMTP152WorkbenchReportEventsEvidence`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 MTP-152 Workbench / Report / Events surface、source freshness explanation surface、no runtime / adapter / schema / payload / broker state surface 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-152 Workbench / Report / Events shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-152 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-152 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-152 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring Workbench / Report / Events read-model-only surface anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-152 App source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。

MTP-152 不新增 Adapters、Runtime、Core semantics、Persistence schema、真实 endpoint、真实 network validation、完整实盘监控台页面重设计或任何 trading command。Project stage closeout 仍归属 MTP-153。

## MTP-153 validation matrix / automation readiness / stage audit input closeout

`MTP-153-LIVE-MONITORING-V2-STAGE-CLOSEOUT`

MTP-153 只收口 `MTPRO Live Monitoring Read-only Console v2` 的 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence、Workbench / Report / Events Live Monitoring v2 surface evidence 和 Stage Code Audit 输入材料。

`MTP-153-STAGE-AUDIT-INPUT-MATERIAL`

MTP-153 的 stage audit input material 落仓于 `docs/audit/inputs/mtpro-live-monitoring-read-only-console-v2-stage-audit-input.md`，用于汇总 MTP-147 至 MTP-152 的 issue / PR / merge / required check evidence、`TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2` evidence chain、forbidden capability evidence chain、Dashboard smoke `liveMonitoringReadOnlyConsoleV2Surface=4` handle 和 Parent Codex final Stage Code Audit handoff checklist。

`MTP-153-NO-FINAL-STAGE-CODE-AUDIT`

MTP-153 不是最终 Stage Code Audit Report，不创建 `docs/audit/mtpro-live-monitoring-read-only-console-v2-stage-code-audit.md`，不设置 Linear Project `Completed`，不启动下一阶段 planning / execution，不创建下一 Project / Issue，不推进下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

最终 Stage Code Audit Report 必须由 Parent Codex 在 MTP-147 至 MTP-153 全部 Linear `Done`，且 Linear Project `Completed/type=completed/completedAt` evidence 齐备后单独输出。

`MTP-153-VALIDATION-EVIDENCE-CHAIN`

MTP-153 validation evidence chain 必须覆盖 MTP-147 terminology / boundary、MTP-148 monitoring source identity、MTP-149 simulation gate health / freshness、MTP-150 connection readiness explanation、MTP-151 forbidden capability tests、MTP-152 Workbench / Report / Events read-model-only surface，以及 MTP-153 自身的 stage audit input、automation readiness 和 matrix backfill。

`MTP-153-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-153 必须确认 signed endpoint、account endpoint / listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、live readiness runtime、Live Monitoring runtime、source adapter、connection manager、runtime connection、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button、live command、order form、stop / shutdown / restore、Graphify update 和 Figma change 在当前 Project 中仍全部禁止。

`MTP-153-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`

MTP-153 必须确认 Live Monitoring v2 的 Workbench / Report / Events evidence 只来自 deterministic Core contract 和 App Read Model / ViewModel，不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload、broker state、signed endpoint、account endpoint、listenKey、private WebSocket 或 real account state。

`MTP-153-AUTOMATION-READINESS-STAGE-CLOSEOUT`

MTP-153 automation readiness stage closeout 要求 `checks/automation-readiness.sh` 机械检查 stage audit input、contract anchors、domain context anchors、validation plan anchors、Trading Validation Matrix backfill、latest verification summary、automation readiness doc anchor、MTP-147 至 MTP-152 source / test / surface anchors、PR #264 至 PR #269 evidence 和 Dashboard smoke `liveMonitoringReadOnlyConsoleV2Surface=4` handle。

`MTP-153-STAGE-CLOSEOUT-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-153 不修改 production code，不实现 live runtime、endpoint、adapter、broker、Live PRO Console、command surface、stop、shutdown 或 restore。
