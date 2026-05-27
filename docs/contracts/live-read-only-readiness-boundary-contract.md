# Live Read-only Readiness Boundary Contract

日期：2026-05-27

执行者：Codex

本文档定义 `MTPRO Live Read-only Readiness Boundary v1` 的 MTP-126 合同入口：Live read-only readiness terminology、target engines / layers、L3.0 与后续 L3.1 / L3.2 / L3.3 的 handoff boundary、forbidden capability baseline、first executable candidate non-authorization 和 validation anchors。

本文档只服务 `MTP-126 Define Live read-only readiness terminology and boundary` 的术语 / 边界 / 验证锚点。它不实现 endpoint、secret、adapter、account read model、UI 或 live runtime；不读取本地 secret；不实现 signed endpoint、account endpoint / listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button 或 live command；不运行 Graphify，不修改 Figma。

## MTP-126 Live read-only readiness terminology

`MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY`

MTP-126 只允许定义以下 L3.0 术语，不允许把术语升级为实现：

| 术语 | 当前含义 | 禁止混用 |
| --- | --- | --- |
| `Live read-only readiness` | L3.0 只读准备边界，用来说明靠近真实账户只读能力前需要的 terminology、future gates、validation anchors 和 forbidden baseline | 不等于真实账户读取、private stream、broker connection、Live Monitoring v2 或 Live Production |
| `read-only readiness boundary` | 当前 Project 的边界合同，固定哪些能力只能作为 future gate / forbidden capability 出现 | 不等于 adapter capability implementation、account endpoint runtime 或 Workbench UI surface |
| `target engine / layer boundary` | L3.0 涉及 Connectivity / Adapter Engine、Data Engine / future private stream boundary、Evidence Read Model Layer、Workbench Interface / Live Readiness surface 和 Docs / Validation / Automation readiness layer 的职责地图 | 不等于新增 SwiftPM target、Runtime actor、App read model 或 Dashboard behavior |
| `L3.0 handoff boundary` | 把 L3.0 术语 / 验证锚点交给后续 L3.1 / L3.2 / L3.3 的范围边界 | 不自动授权后续 Linear issue，不推进 Backlog，不实现后续 runtime |
| `read-only future gate` | 后续 account / position / balance read-model-only、private stream / account snapshot simulation gate、Live Monitoring read-only Console v2 进入 planning 前必须满足的 gate | 不等于当前已允许读取真实账户或创建 listenKey |
| `forbidden live capability baseline` | MTP-126 固定本 Project 期间必须持续禁止的 live capability 清单 | 不得写成 partially supported、preview enabled、behind flag available 或 local fallback |

## MTP-126 Target engine / layer boundary

`MTP-126-TARGET-ENGINE-LAYER-BOUNDARY`

MTP-126 只定义以下 target engines / layers 的边界语言，不新增实现：

| Target Engine / Layer | L3.0 允许定义 | L3.0 明确禁止 |
| --- | --- | --- |
| Connectivity / Adapter Engine | public market data allowed、future private read-only gate、forbidden write capability baseline | 不实现 credential provider、signed request、account endpoint、listenKey、broker adapter、exchange execution adapter 或 `LiveExecutionAdapter` |
| Data Engine / future private stream boundary | private stream / account snapshot 只能作为后续 simulation gate input material | 不创建 private WebSocket、不创建 listenKey、不运行 account snapshot runtime、不运行 production stream |
| Evidence Read Model Layer | 只定义后续 read-model-only evidence 的 source boundary 和 validation anchors | 不新增 account / position / balance read model，不读取 real account，不同步 broker position |
| Workbench Interface / Live Readiness surface | 只定义 Workbench 后续只能展示 read-model-only boundary evidence | 不新增 API key 输入、broker connect、order form、Live PRO Console、trading button 或 live command |
| Docs / Validation / Automation readiness layer | 记录 contract、domain terms、validation plan、matrix、latest summary 和 automation readiness anchors | 不运行 Graphify、不修改 Figma、不创建 Stage Code Audit Report、不修改 Linear status |

## MTP-126 L3.0 / L3.1 / L3.2 / L3.3 handoff boundary

`MTP-126-L30-L31-L32-L33-HANDOFF`

MTP-126 固定 L3.0 的 handoff 规则：

1. `L3.0 Live Read-only Readiness Boundary` 只定义 terminology、target engines、future gates、forbidden baseline 和 validation anchors。
2. `L3.1 Account / Position / Balance Read-model-only` 后续才允许定义 account / position / balance read-model-only future gates；MTP-126 不实现 read model、ViewModel、fixture 或 runtime。
3. `L3.2 Private Stream / Account Snapshot Simulation Gate` 后续才允许定义 private stream / account snapshot simulation gate input material；MTP-126 不创建 listenKey、不连接 private WebSocket、不运行 account snapshot runtime。
4. `L3.3 Live Monitoring Read-only Console v2` 后续才允许规划 upgraded monitoring read-only evidence surface；MTP-126 不实现 Live Monitoring v2、不改 Dashboard、不新增 Workbench surface。
5. `L4 Live Production / Trading Commands` 保持 Future Gated；MTP-126 不授权 real execution、OMS、broker fill、reconciliation、live risk runtime、ops / incident / stop 或 Live PRO Console。

L3.0 完成后不得自动推进 MTP-127。MTP-127 至 MTP-132 仍必须分别等待 Parent Codex queue preflight 在 WIP=1、依赖满足、无 active conflict、execution contract 完整时判断。

## MTP-126 forbidden capability baseline

`MTP-126-FORBIDDEN-CAPABILITY-BASELINE`

MTP-126 必须保持以下 forbidden capabilities：

- API key / secret storage implementation
- local secret read
- signed endpoint
- account endpoint
- listenKey user data stream
- private WebSocket runtime
- account snapshot runtime
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
- real account / broker position / margin / leverage runtime
- account / position / balance read model implementation
- Live Monitoring Console v2 implementation
- Live PRO Console
- trading button
- live command
- order form
- emergency stop / shutdown / restore executable action
- Graphify update
- Figma change

这些能力只能作为 forbidden / Future Gated boundary 出现，不能写成当前支持、beta preview、local fallback、behind flag、partially implemented 或后续 issue 自动授权。

## MTP-126 first executable candidate non-authorization

`MTP-126-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`

Project Planning Record 中的 first executable issue candidate 只是候选，不构成执行授权。MTP-126 只有在 Linear live-read 中经 Parent Codex queue preflight 和 symphony-issue 调度后，作为唯一 active configured executable issue 时才可以执行。

该事实不改变以下规则：

- `docs/product/mtpro-live-readiness-roadmap-v1.md` 不授权 execution。
- `docs/planning/projects/mtpro-live-read-only-readiness-boundary-v1-plan.md` 不授权 execution。
- Backlog issue、label、priority、assignee 或 estimate 不授权 execution。
- MTP-126 完成后不得自动推进 MTP-127。
- MTP-127 至 MTP-132 必须继续保持 Backlog / non-executable，直到各自成为 live-read 中唯一 eligible issue。

## MTP-126 validation anchors

`MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION`

Required validation：

- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 MTP-126 terminology、target engine / layer boundary、L3.0 / L3.1 / L3.2 / L3.3 handoff、forbidden capability baseline、first executable candidate non-authorization 和 validation anchors。
- `docs/domain/context.md` 必须包含 Live read-only readiness terms 和 MTP-126 anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-READ-ONLY-READINESS` 和 MTP-126 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-126 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-126 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only Readiness contract anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-126 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。

MTP-126 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 App read model、不新增 Core / Runtime / Dashboard behavior、不新增 stage audit input；Project stage closeout 仍归属 MTP-132。

## MTP-127 credential / secret policy future gate

`MTP-127-CREDENTIAL-SECRET-POLICY-FUTURE-GATE`

MTP-127 固定 L3.0 credential / secret policy 只能作为 future gate 和 forbidden baseline 出现。当前允许输出：

- `LiveReadOnlyCredentialPolicyTerm` 术语。
- `LiveReadOnlyCredentialEndpointTaxonomyBoundary` deterministic fixture。
- contract / domain context / validation matrix / automation readiness / focused XCTest / PR boundary evidence。

当前禁止输出：

- API key / secret storage implementation。
- local secret read。
- env / keychain / config secret path。
- credential provider runtime。
- signed request helper。
- account endpoint runtime。
- listenKey 或 private WebSocket runtime。

该 gate 只定义后续 Project Definition 需要的 policy 输入，不实现任何 secret handling，也不读取本机 secret。

## MTP-127 endpoint capability taxonomy

`MTP-127-ENDPOINT-CAPABILITY-TAXONOMY`

MTP-127 的 endpoint capability taxonomy 必须固定为：

| Taxonomy | 当前状态 | 当前允许证据 | 当前禁止输出 |
| --- | --- | --- | --- |
| `public read-only market data` | Current allowed | contract、Core fixture、focused test、public read-only boundary evidence | 升级为 signed / account / broker capability |
| `signed endpoint forbidden` | Forbidden / future gate | signed endpoint capability contract 输入 | HMAC/signature、timestamp signing、signed REST request |
| `account endpoint forbidden` | Forbidden / future gate | account endpoint capability contract 输入 | `/api/v3/account`、balance / position payload、account sync |
| `listenKey forbidden` | Forbidden / future gate | private stream simulation gate 输入 | listenKey create / keepalive、user data stream |
| `private WebSocket forbidden` | Forbidden / future gate | L3.2 simulation input boundary | private WebSocket runtime、account stream runtime |
| `broker action forbidden` | Forbidden / future gate | broker action non-execution audit 输入 | broker / exchange execution adapter、submit / cancel / replace |

`public read-only market data` 是 MTP-127 唯一当前允许 endpoint capability；其它 taxonomy 值必须保持 forbidden / future gate，不得写成 partially supported、preview enabled、behind flag available 或 local fallback。

## MTP-127 public read-only / private endpoint isolation

`MTP-127-PUBLIC-READ-ONLY-PRIVATE-ENDPOINT-ISOLATION`

MTP-127 将 public read-only market data 与 private / signed / account capability 明确隔离：

- `allowedCurrentEndpointCapabilities == [.publicReadOnlyMarketData]`。
- `forbiddenEndpointCapabilities == [.signedEndpointForbidden, .accountEndpointForbidden, .listenKeyForbidden, .privateWebSocketForbidden, .brokerActionForbidden]`。
- `readsLocalSecret`、`implementsAPIKeyStorage`、`createsSecretConfigurationPath`、`signsRequest`、`callsSignedEndpoint`、`callsAccountEndpoint`、`createsListenKey`、`opensPrivateWebSocket`、`connectsBrokerAdapter`、`performsBrokerAction`、`implementsLiveExecutionAdapter`、`exposesPrivateReadRuntime`、`upgradesPublicReadOnlyAdapter` 和 `requiredValidationDependsOnNetwork` 必须全部为 `false`。

该隔离只定义 L3.0 readiness taxonomy，不实现 MTP-128 adapter capability matrix，不实现 MTP-129 account / position / balance read model，不实现 MTP-130 private stream / account snapshot simulation gate，不实现 MTP-131 Workbench Live readiness surface。

## MTP-127 forbidden capability tests

`MTP-127-FORBIDDEN-CAPABILITY-TESTS`

MTP-127 的 forbidden capability evidence 来自本地 deterministic tests：

- `Sources/Core/LiveTradingBoundary.swift` 中的 `LiveReadOnlyCredentialPolicyTerm`、`LiveReadOnlyEndpointCapabilityTaxonomy`、`LiveReadOnlyCredentialEndpointFutureGate`、`LiveReadOnlyCredentialEndpointEvidenceKind` 和 `LiveReadOnlyCredentialEndpointTaxonomyBoundary`。
- `Tests/CoreTests/CoreTests.swift` 中的 `testLiveReadOnlyCredentialEndpointTaxonomyDefinesMTP127FutureGates`。
- `Tests/CoreTests/CoreTests.swift` 中的 `testLiveReadOnlyCredentialEndpointTaxonomyRejectsSecretEndpointAndBrokerBypass`。

Focused tests 必须证明 fixture 可 Codable 稳定 round-trip，并且初始化或 Codable 解码都不能恢复 secret read、API key storage、signed/account endpoint、listenKey、private WebSocket、broker action、`LiveExecutionAdapter`、private read runtime 或 public adapter upgrade。

## MTP-127 validation anchors

`MTP-127-LIVE-READ-ONLY-CREDENTIAL-ENDPOINT-VALIDATION`

Required validation：

- `swift test --filter LiveReadOnlyCredentialEndpointTaxonomy`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 MTP-127 credential / secret policy future gate、endpoint capability taxonomy、public read-only / private endpoint isolation、forbidden capability tests 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-127 credential / endpoint taxonomy terms。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-127 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-127 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-127 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 MTP-127 Live Read-only credential / endpoint taxonomy anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-127 contract、domain context、matrix、validation plan、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-127 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不新增 stage audit input；Project stage closeout 仍归属 MTP-132。

## MTP-128 adapter capability matrix

`MTP-128-ADAPTER-CAPABILITY-MATRIX`

MTP-128 固定 L3.0 adapter capability matrix，只定义能力分类和验证锚点，不写成 implementation plan：

| Capability | 当前状态 | 当前允许证据 | 当前禁止输出 |
| --- | --- | --- | --- |
| `public market data allowed` | Current allowed | public read-only market data adapter boundary、Core fixture、focused test、contract evidence | 升级为 signed / account / broker / execution adapter |
| `future private account read-only gated` | Future gated | L3.1 / L3.2 输入边界、read-model-only handoff | private account runtime、account endpoint call、listenKey 或 private WebSocket |
| `signed endpoint forbidden` | Forbidden | signed endpoint capability contract 输入 | signing helper、HMAC request、signed REST endpoint |
| `order write forbidden` | Forbidden | order write forbidden validation | real submit / cancel / replace、order form、live command |
| `broker action forbidden` | Forbidden | broker action non-execution audit | broker action、broker session mutation |
| `broker execution adapter forbidden` | Forbidden | broker / exchange adapter future gate | broker execution adapter |
| `exchange execution adapter forbidden` | Forbidden | broker / exchange adapter future gate | exchange execution adapter |
| `LiveExecutionAdapter forbidden` | Forbidden | Core deterministic forbidden test | `LiveExecutionAdapter` implementation |
| `account endpoint / listenKey forbidden` | Forbidden | account / private stream future gate input | account endpoint、listenKey create / keepalive、user data stream |
| `execution report / broker fill / reconciliation forbidden` | Forbidden | future audit / reconciliation gate input | execution report parser、broker fill recorder、reconciliation runtime |
| `real account / broker position / margin / leverage forbidden` | Forbidden | future read-model-only source boundary | real account read、broker position sync、margin / leverage runtime |

`public market data allowed` 是 MTP-128 唯一 current allowed adapter capability；`future private account read-only gated` 只能作为 future gated capability，其余能力必须保持 forbidden。

## MTP-128 public read-only adapter / future private gate isolation

`MTP-128-PUBLIC-READ-ONLY-ADAPTER-PRIVATE-GATE-ISOLATION`

MTP-128 将当前 public read-only adapter 与 future private read-only / broker execution capability 明确隔离：

- `currentAllowedCapabilities == [.publicMarketDataAllowed]`。
- `futureGatedCapabilities == [.futurePrivateAccountReadOnlyGated]`。
- `forbiddenCapabilities == [.signedEndpointForbidden, .orderWriteForbidden, .brokerActionForbidden, .brokerExecutionAdapterForbidden, .exchangeExecutionAdapterForbidden, .liveExecutionAdapterForbidden, .accountEndpointListenKeyForbidden, .executionReportBrokerFillReconciliationForbidden, .realAccountPositionMarginLeverageForbidden]`。
- `createsBrokerAdapter`、`createsExchangeExecutionAdapter`、`implementsLiveExecutionAdapter`、`upgradesPublicReadOnlyAdapterToExecutionAdapter`、`callsSignedEndpoint`、`callsAccountEndpoint`、`createsListenKey`、`exposesOrderWriteCapability`、`submitsRealOrder`、`cancelsRealOrder`、`replacesRealOrder`、`readsExecutionReport`、`recordsBrokerFill`、`runsReconciliation`、`readsRealAccountPositionMarginLeverage` 和 `requiredValidationDependsOnNetwork` 必须全部为 `false`。

该隔离只定义 adapter capability matrix，不新增 Adapters target 类型，不实例化 broker / exchange execution adapter，不实现 private account read runtime，不把 public read-only adapter 升级为 execution adapter。

## MTP-128 forbidden adapter capability tests

`MTP-128-FORBIDDEN-ADAPTER-CAPABILITY-TESTS`

MTP-128 的 forbidden adapter capability evidence 来自本地 deterministic tests：

- `Sources/Core/LiveTradingBoundary.swift` 中的 `LiveReadOnlyAdapterCapabilityMatrixEntry`、`LiveReadOnlyAdapterCapabilityFutureGate`、`LiveReadOnlyAdapterCapabilityEvidenceKind` 和 `LiveReadOnlyAdapterCapabilityMatrixBoundary`。
- `Tests/CoreTests/CoreTests.swift` 中的 `testLiveReadOnlyAdapterCapabilityMatrixDefinesMTP128ReadOnlyBoundary`。
- `Tests/CoreTests/CoreTests.swift` 中的 `testLiveReadOnlyAdapterCapabilityMatrixRejectsWriteAndExecutionAdapterBypass`。

Focused tests 必须证明 fixture 可 Codable 稳定 round-trip，并且初始化或 Codable 解码都不能恢复 signed/account/listenKey、order write、broker adapter、exchange execution adapter、`LiveExecutionAdapter`、execution report、broker fill、reconciliation、real account / broker position / margin / leverage 或 network dependency。

## MTP-128 validation anchors

`MTP-128-LIVE-READ-ONLY-ADAPTER-CAPABILITY-VALIDATION`

Required validation：

- `swift test --filter LiveReadOnlyAdapterCapabilityMatrix`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 MTP-128 adapter capability matrix、public read-only adapter / future private gate isolation、forbidden adapter capability tests 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-128 adapter matrix shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-128 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-128 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-128 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 MTP-128 Live Read-only adapter capability matrix anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-128 contract、domain context、matrix、validation plan、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-128 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不新增 stage audit input；Project stage closeout 仍归属 MTP-132。
