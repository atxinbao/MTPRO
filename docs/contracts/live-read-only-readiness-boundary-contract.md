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

## MTP-129 account / position / balance read-model-only future gates

`MTP-129-ACCOUNT-POSITION-BALANCE-FUTURE-GATES`

MTP-129 固定 L3.1 所需的 account / position / balance read-model-only future gates。当前只定义进入后续 L3.1 planning 前必须补齐的合同输入，不实现 read model runtime：

| Future Gate | 当前含义 | 当前禁止 |
| --- | --- | --- |
| `account read-model-only contract` | 后续 L3.1 必须独立定义 account read-model-only 的输入、字段、source identity 和 validation | 不读取 real account，不调用 account endpoint |
| `position read-model-only contract` | 后续 L3.1 必须独立定义 position read-model-only 的输入、broker position source identity 和 isolation | 不同步 broker position，不把 paper portfolio projection 升级为 broker position |
| `balance read-model-only contract` | 后续 L3.1 必须独立定义 balance read-model-only 的 freshness、evidence identity 和 stale boundary | 不读取 real account balance、margin、leverage 或 real PnL |
| `source identity required` | 后续 evidence 必须声明 future account / position / balance source identity，并保留 fixture source identity isolation | 不允许 paper / simulated / fixture evidence 伪装成真实账户数据 |
| `snapshot freshness required` | 后续 snapshot 必须声明 observedAt、source watermark 和 stale boundary | 不运行 account snapshot runtime 或 private stream runtime |
| `evidence identity required` | 后续 evidence 必须可追溯到 read-model-only source，不得复用 broker payload identity | 不创建 signed/account/listenKey payload |
| `Workbench / Dashboard ViewModel boundary` | 后续 Workbench / Dashboard 只能消费 ViewModel/read model evidence | 不新增 Live PRO Console、trading button、live command 或 order form |
| `paper / simulated / fixture evidence isolation` | paper portfolio、simulated fill 和 fixture evidence 必须保持非真实账户语义 | 不解释为 broker fill、broker position、real account balance 或 real PnL |

## MTP-129 source identity / freshness / evidence identity boundary

`MTP-129-SOURCE-FRESHNESS-EVIDENCE-IDENTITY-BOUNDARY`

MTP-129 将未来只读账户证据拆成三个不可省略的 identity 层：

- `source identity`：后续 L3.1 必须区分 future account source identity、future position source identity、future balance source identity 和 fixture source identity isolation。
- `snapshot freshness`：后续 L3.1 必须声明 snapshot observedAt、source watermark 和 stale boundary；MTP-129 不运行 snapshot runtime。
- `evidence identity`：后续 L3.1 必须证明 evidence identity 来自 read-model-only boundary，而不是 broker payload、signed endpoint response、listenKey stream 或 private WebSocket runtime。

当前 `LiveReadOnlyAccountPositionBalanceFutureGateBoundary` 中以下 flags 必须全部为 `false`：

- `implementsAccountReadModelRuntime`
- `implementsPositionReadModelRuntime`
- `implementsBalanceReadModelRuntime`
- `readsRealAccount`
- `syncsBrokerPosition`
- `readsRealAccountBalance`
- `readsMargin`
- `readsLeverage`
- `readsRealPnL`
- `callsSignedEndpoint`
- `callsAccountEndpoint`
- `createsListenKey`
- `connectsBrokerAdapter`
- `implementsLiveExecutionAdapter`
- `implementsOMS`
- `representsPaperEvidenceAsRealAccountData`
- `representsSimulatedFillAsBrokerPosition`
- `representsFixtureEvidenceAsRealAccountSnapshot`
- `exposesTradingButton`
- `exposesLiveCommand`
- `requiredValidationDependsOnNetwork`

## MTP-129 paper / simulated / fixture evidence forbidden interpretation tests

`MTP-129-FORBIDDEN-ACCOUNT-DATA-INTERPRETATION-TESTS`

MTP-129 的 forbidden interpretation evidence 来自本地 deterministic tests：

- `Sources/Core/LiveTradingBoundary.swift` 中的 `LiveReadOnlyAccountPositionBalanceFutureGate`、`LiveReadOnlyAccountPositionBalanceSourceIdentity`、`LiveReadOnlyAccountPositionBalanceFreshnessBoundary`、`LiveReadOnlyAccountPositionBalanceEvidenceKind`、`LiveReadOnlyAccountPositionBalanceForbiddenInterpretation` 和 `LiveReadOnlyAccountPositionBalanceFutureGateBoundary`。
- `Tests/CoreTests/CoreTests.swift` 中的 `testLiveReadOnlyAccountPositionBalanceFutureGatesDefineMTP129Boundary`。
- `Tests/CoreTests/CoreTests.swift` 中的 `testLiveReadOnlyAccountPositionBalanceFutureGatesRejectRealAccountAndFixtureBypass`。

Focused tests 必须证明 fixture 可 Codable 稳定 round-trip，并且初始化或 Codable 解码都不能恢复 real account read、broker position sync、margin / leverage / real PnL read、signed/account/listenKey、broker adapter、`LiveExecutionAdapter`、OMS、paper evidence -> real account data、simulated fill -> broker position、fixture evidence -> real account snapshot、trading button、live command 或 network dependency。

## MTP-129 validation anchors

`MTP-129-LIVE-READ-ONLY-ACCOUNT-POSITION-BALANCE-VALIDATION`

Required validation：

- `swift test --filter LiveReadOnlyAccountPositionBalance`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 MTP-129 account / position / balance future gates、source identity / freshness / evidence identity boundary、forbidden account-data interpretation tests 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-129 account / position / balance shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-129 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-129 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-129 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 MTP-129 Live Read-only account / position / balance future gate anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-129 contract、domain context、matrix、validation plan、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-129 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 L3.1，不新增 stage audit input；Project stage closeout 仍归属 MTP-132。

## MTP-130 private stream / account snapshot simulation gate input material

`MTP-130-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE`

MTP-130 固定后续 L3.2 所需的 private stream / account snapshot simulation gate input material。当前只定义进入后续 L3.2 planning 前必须补齐的 simulation 输入，不实现 listenKey、private WebSocket 或 account snapshot runtime：

| Input Material | 当前含义 | 当前禁止 |
| --- | --- | --- |
| `private stream source identity` | 后续 L3.2 必须声明 private stream simulation source identity | 不创建 listenKey，不连接 private WebSocket |
| `account snapshot fixture identity` | 后续 fixture 必须声明 account snapshot fixture identity | 不读取真实 account endpoint 或 broker account payload |
| `snapshot observedAt` | 后续 simulation snapshot 必须包含 observedAt 时间 | 不运行 account snapshot runtime |
| `source watermark` | 后续 fixture 必须声明 source watermark / replay watermark | 不消费 live private stream watermark |
| `freshness boundary` | 后续 simulation gate 必须声明 stale / freshness 边界 | 不依赖真实网络 freshness |
| `account event shape` | 后续 fixture 可描述 account event shape | 不解析真实 account endpoint payload |
| `position event shape` | 后续 fixture 可描述 position event shape | 不同步 broker position |
| `balance event shape` | 后续 fixture 可描述 balance event shape | 不读取 real account balance、margin、leverage 或 real PnL |
| `fixture replay cursor` | 后续 simulation gate 必须可用本地 fixture replay cursor 复现 | 不运行 production stream |
| `simulation gate boundary` | 后续只允许验证 simulation input 与 live stream implementation 隔离 | 不实现 live stream implementation |

## MTP-130 future fixture requirements

`MTP-130-FUTURE-FIXTURE-REQUIREMENTS`

MTP-130 将 L3.2 future fixture requirements 固定为 contract 输入：

- `deterministic account snapshot fixture`：后续 L3.2 必须使用 deterministic fixture，不读取真实账户。
- `private stream event fixture`：后续 L3.2 可定义 private stream event fixture shape，但不得创建 private WebSocket。
- `fixture source identity declared`：fixture 必须声明 source identity，不能伪装成真实 exchange / broker payload。
- `fixture freshness declared`：fixture 必须声明 observedAt、watermark 和 stale boundary。
- `replay cursor declared`：fixture 必须声明本地 replay cursor，不能依赖 production stream。
- `live stream implementation separated`：simulation gate input 与 live private stream implementation 必须保持隔离。
- `listenKey forbidden validation`：focused tests 必须证明 listenKey create / keepalive 均被拒绝。
- `network independent validation`：required validation 不依赖真实 Binance 网络、account endpoint、listenKey 或 broker。

## MTP-130 simulation gate / live stream isolation

`MTP-130-SIMULATION-GATE-LIVE-STREAM-ISOLATION`

当前 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary` 中以下 flags 必须全部为 `false`：

- `createsListenKey`
- `keepsListenKeyAlive`
- `opensPrivateWebSocket`
- `runsPrivateStreamRuntime`
- `runsAccountSnapshotRuntime`
- `callsSignedEndpoint`
- `callsAccountEndpoint`
- `readsRealAccount`
- `consumesRealAccountPayload`
- `syncsBrokerPosition`
- `readsMargin`
- `readsLeverage`
- `connectsBrokerAdapter`
- `implementsLiveExecutionAdapter`
- `implementsOMS`
- `writesRealOrder`
- `representsSimulationGateAsLiveStreamImplementation`
- `representsFixtureSnapshotAsRealAccountSnapshot`
- `exposesTradingButton`
- `exposesLiveCommand`
- `requiredValidationDependsOnNetwork`

该隔离只定义 L3.2 handoff material，不新增 Adapters、Runtime、App 或 Dashboard behavior，不把 simulation gate 写成 private stream implementation，也不把 fixture account snapshot 写成真实 account snapshot。

## MTP-130 listenKey forbidden tests

`MTP-130-LISTENKEY-FORBIDDEN-TESTS`

MTP-130 的 forbidden capability evidence 来自本地 deterministic tests：

- `Sources/Core/LiveTradingBoundary.swift` 中的 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationInputMaterial`、`LiveReadOnlyPrivateStreamAccountSnapshotFutureFixtureRequirement`、`LiveReadOnlyPrivateStreamAccountSnapshotForbiddenCapability`、`LiveReadOnlyPrivateStreamAccountSnapshotEvidenceKind` 和 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary`。
- `Tests/CoreTests/CoreTests.swift` 中的 `testLiveReadOnlyPrivateStreamAccountSnapshotDefinesMTP130SimulationGateInput`。
- `Tests/CoreTests/CoreTests.swift` 中的 `testLiveReadOnlyPrivateStreamAccountSnapshotRejectsListenKeyAndRuntimeBypass`。

Focused tests 必须证明 fixture 可 Codable 稳定 round-trip，并且初始化或 Codable 解码都不能恢复 listenKey create / keepalive、private WebSocket、private stream runtime、account snapshot runtime、signed/account endpoint、real account read、broker position sync、margin / leverage、broker adapter、`LiveExecutionAdapter`、OMS、real order write、simulation gate -> live stream implementation、fixture snapshot -> real account snapshot、trading button、live command 或 network dependency。

## MTP-130 validation anchors

`MTP-130-LIVE-READ-ONLY-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-VALIDATION`

Required validation：

- `swift test --filter LiveReadOnlyPrivateStreamAccountSnapshot`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

Focused validation anchors：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 MTP-130 private stream / account snapshot simulation gate input material、future fixture requirements、simulation gate / live stream isolation、listenKey forbidden tests 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-130 private stream / account snapshot simulation gate shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-130 issue backfill。
- `docs/validation/validation-plan.md` 必须包含 MTP-130 required validation。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-130 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 MTP-130 Live Read-only private stream / account snapshot simulation gate anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-130 contract、domain context、matrix、validation plan、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-130 不新增 Adapters、Runtime、App、Dashboard behavior，不新增 Dashboard smoke handle，不实现 L3.2，不新增 stage audit input；Project stage closeout 仍归属 MTP-132。
