# L4 Live Account Read-model Mapping Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-457 L4: 06/21 Add live account / position / balance / margin read-model mapping`。

本文档定义 L4 live account / position / balance / margin evidence 的 canonical read model mapping。该 mapping 只解释 GH-455 signed account read-only evidence 和 GH-456 private stream / account snapshot read-only evidence，不读取真实账户 payload，不消费 broker state，不读取 Runtime object、Adapter request 或 schema，不实现 real PnL runtime、reconciliation、ExecutionClient adapter、OMS、Live PRO Console、trading command 或 real order lifecycle。

## GH-457-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING

`GH-457-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING`

GH-457 mapper 依赖 GH-455 canonical signed account evidence 和 GH-456 private stream account snapshot evidence。当前实现位于：

- `Sources/ExecutionClient/FutureGate/L4LiveAccountReadModelMapping.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH457LiveAccountReadModelMappingMapsAPBMarginEvidenceReadOnly`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH457LiveAccountReadModelMappingRejectsRawPayloadBrokerStateAndRuntimeBypass`

Mapper 固定：

- 只输出 canonical read-model records。
- 不触碰 Dashboard runtime object、Adapter request、schema 或 UI command surface。
- 不引入 real PnL runtime、reconciliation 或 broker state。
- validation 不依赖网络、secret、listenKey、private WebSocket、broker、production credential 或人工验收。

## GH-457-APB-MARGIN-CANONICAL-COMPONENTS

`GH-457-APB-MARGIN-CANONICAL-COMPONENTS`

GH-457 read model 必须覆盖四类 component：

| Component | Current value source |
| --- | --- |
| account | GH-455 signed account canonical evidence + GH-456 snapshot evidence |
| position | GH-455 position evidence + GH-456 private position update source |
| balance | GH-455 balance evidence + GH-456 private balance update source |
| margin | GH-455 margin evidence + GH-456 private margin update source |

这些 component 是 read model 解释维度，不是真实 account endpoint JSON、broker state、real PnL、margin / leverage runtime 或 order command state。

## GH-457-FRESHNESS-SOURCE-EVIDENCE-IDENTITY

`GH-457-FRESHNESS-SOURCE-EVIDENCE-IDENTITY`

Read model 必须保留：

- GH-455 signed account evidence identity。
- GH-456 private stream evidence identity。
- private stream source identity。
- freshness statuses：fresh、stale、blocked、missing、disconnected。

Freshness 只作为 read-model status，不触发 reconnect、listenKey keep-alive、broker fallback、order retry、reconciliation 或 trading command。

## GH-457-DASHBOARD-READ-MODEL-ONLY-CONSUMPTION

`GH-457-DASHBOARD-READ-MODEL-ONLY-CONSUMPTION`

Dashboard / Report / Events 只能消费 `L4LiveAccountReadModel` 这样的 canonical read model：

- `dashboardReadModelOnly == true`
- `runtimeObjectExposed == false`
- `adapterRequestExposed == false`
- `schemaExposed == false`
- `rawAccountPayloadExposed == false`
- `brokerStateExposed == false`
- `commandSurfaceEnabled == false`

GH-457 不修改 Dashboard UI，也不接入 command-capable console。

## GH-457-FIXTURE-SANDBOX-REAL-ACCOUNT-INTERPRETATION-SEPARATION

`GH-457-FIXTURE-SANDBOX-REAL-ACCOUNT-INTERPRETATION-SEPARATION`

当前 record 的 `interpretationMode` 必须是 `sandbox fixture interpretation`。Future real account read-only interpretation 只能作为后续受门禁语义，不得把 fixture / sandbox value 伪装成真实账户数据，也不得读取真实账户 payload。

## GH-457-FORBIDDEN-RAW-PAYLOAD-BROKER-STATE-TESTS

`GH-457-FORBIDDEN-RAW-PAYLOAD-BROKER-STATE-TESTS`

Focused tests 必须拒绝：

- raw account payload exposure
- raw private payload exposure
- broker state exposure
- Runtime object exposure
- Adapter request exposure
- schema exposure
- real PnL runtime
- command surface
- reconciliation runtime
- ExecutionClient adapter implementation
- OMS implementation

## GH-457-NON-AUTHORIZATION

`GH-457-NON-AUTHORIZATION`

GH-457 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- 真实 API key / secret 读取、保存、打印或提交。
- API-key header construction 或 request signature generation。
- signed endpoint、account endpoint 或 production endpoint call。
- listenKey create / keep-alive / close。
- private WebSocket open / reconnect。
- raw account payload、raw private payload、account endpoint payload、broker payload、broker state 或 Dashboard raw payload exposure。
- Runtime object、Adapter request 或 schema exposure。
- real PnL runtime、margin / leverage runtime 或 real account read。
- ExecutionClient adapter implementation。
- OMS implementation。
- trading command、submit / cancel / replace 或 order lifecycle。
- execution report、broker fill 或 reconciliation。
- Live PRO Console command surface。
- order form / trading button。
- production cutover 或 real trading enablement。
