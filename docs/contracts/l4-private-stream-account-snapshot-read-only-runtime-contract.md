# L4 Private Stream / Account Snapshot Read-only Runtime Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-456 L4: 05/21 Implement private stream / account snapshot read-only runtime`。

本文档定义 private stream / account snapshot 的 read-only runtime gate。该 runtime 只在 GH-455 signed account read-only evidence 已成立，且 sandbox / fixture stream / account snapshot mapping gate 同时满足时，生成 deterministic private stream source identity、freshness 和 account snapshot read-model evidence。它不创建 listenKey，不打开 private WebSocket，不消费真实 broker payload，不暴露 raw private payload，不实现 ExecutionClient adapter、OMS、Live PRO Console、trading command 或 real order lifecycle。

## GH-456-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME

`GH-456-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME`

GH-456 runtime 依赖 GH-454 signed/private boundary 和 GH-455 signed account read-only runtime。当前实现位于：

- `Sources/ExecutionClient/FutureGate/L4PrivateStreamAccountSnapshotReadOnlyRuntime.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH456PrivateStreamAccountSnapshotReadOnlyRuntimeProducesFreshnessEvidence`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH456PrivateStreamAccountSnapshotReadOnlyRuntimeRejectsListenKeyPayloadAndCommandBypass`

Runtime 固定：

- 默认 disabled，未配置时不可触发 private stream / account snapshot evidence。
- 只允许 sandbox / local fixture gate 生成 deterministic read-model-only evidence。
- 必须引用 GH-455 canonical signed account evidence。
- validation 不依赖网络、secret、listenKey、private WebSocket、broker 或人工验收。

## GH-456-PRIVATE-STREAM-SOURCE-IDENTITY

`GH-456-PRIVATE-STREAM-SOURCE-IDENTITY`

Private stream source identity 只描述 read-only evidence 来源：

| Source identity | Meaning |
| --- | --- |
| signed account snapshot source | GH-455 canonical account evidence 进入 snapshot mapping |
| private balance update source | fixture-only balance update evidence |
| private position update source | fixture-only position update evidence |
| private margin update source | fixture-only margin update evidence |
| listenKey session source identity | lifecycle 状态标签，不是 listenKey value |

这些值不是 listenKey value、WebSocket session、broker payload、execution report payload 或真实账户端点响应。

## GH-456-ACCOUNT-SNAPSHOT-READ-MODEL-UPDATE

`GH-456-ACCOUNT-SNAPSHOT-READ-MODEL-UPDATE`

Account snapshot update 只能写入 canonical read model：

- `readModelOnly == true`
- `dashboardReadModelOnly == true`
- `listenKeyValueExposed == false`
- `privateWebSocketOpened == false`
- `rawBrokerPayloadExposed == false`
- `rawPrivatePayloadExposed == false`
- `commandSurfaceEnabled == false`
- `productionGateEnabled == false`

Dashboard / Report / Events 后续只能消费 read-model-only evidence，不得消费 raw private stream payload 或 broker state。

## GH-456-FRESHNESS-STALE-BLOCKED-MISSING-DISCONNECT-EVIDENCE

`GH-456-FRESHNESS-STALE-BLOCKED-MISSING-DISCONNECT-EVIDENCE`

GH-456 必须提供可验证的 freshness evidence：

| Freshness status | Boundary meaning |
| --- | --- |
| fresh | fixture account snapshot / update 正常进入 read model |
| stale | stale evidence 只阻断 command inference，不触发 reconnect |
| blocked | blocked evidence 保持 Dashboard read-only |
| missing | missing evidence 不回退到 broker 或 account endpoint |
| disconnected | disconnect evidence 不执行 reconnect、retry 或 command path |

这些状态不驱动 listenKey keep-alive、private WebSocket reconnect、order retry 或 trading command。

## GH-456-LISTENKEY-LIFECYCLE-NO-COMMAND-SURFACE

`GH-456-LISTENKEY-LIFECYCLE-NO-COMMAND-SURFACE`

Focused tests 必须拒绝：

- production mode
- listenKey lifecycle allowed
- private WebSocket allowed
- raw payload exposure
- command runtime allowed
- missing credential reference under sandbox mode
- raw private payload record
- raw broker payload evidence

## GH-456-NON-AUTHORIZATION

`GH-456-NON-AUTHORIZATION`

GH-456 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- 真实 API key / secret 读取、保存、打印或提交。
- API-key header construction 或 request signature generation。
- signed endpoint、account endpoint 或 production endpoint call。
- listenKey create / keep-alive / close。
- private WebSocket open / reconnect。
- real private event consumption。
- raw private payload、account endpoint payload、broker payload、broker state 或 Dashboard raw payload exposure。
- ExecutionClient adapter implementation。
- OMS implementation。
- trading command、submit / cancel / replace 或 order lifecycle。
- execution report、broker fill 或 reconciliation。
- Live PRO Console command surface。
- order form / trading button。
- production cutover 或 real trading enablement。
