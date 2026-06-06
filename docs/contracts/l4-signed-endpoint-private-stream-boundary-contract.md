# L4 Signed Endpoint Private Stream Boundary Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-454 L4: 03/21 Define signed endpoint and private stream runtime boundary`。

本文档定义 signed endpoint、account endpoint、listenKey、private stream runtime 的 L4 边界。它只固定 signed request capability taxonomy、listenKey / private WebSocket future lifecycle contract、account snapshot / private event source identity 和 forbidden endpoint path，不实现连接、不读取真实账户、不创建 listenKey、不启动 private stream、不实现 command runtime。

## GH-454-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY

`GH-454-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY`

GH-454 依赖 GH-452 L4 command contract 和 GH-453 credential environment gate。它把后续能力分成三类：

| Runtime kind | 当前状态 | 后续 issue |
| --- | --- | --- |
| signed read-only | boundary only | GH-455 |
| private stream | boundary only | GH-456 / GH-457 |
| command runtime | isolated / forbidden in GH-454 | GH-458 / GH-459 / GH-461 / GH-463 / GH-469 |

当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/L4SignedEndpointPrivateStreamBoundaryContract.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH454L4SignedEndpointPrivateStreamBoundarySeparatesRuntimeKinds`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH454L4SignedEndpointPrivateStreamBoundaryRejectsEndpointRuntimeBypass`

## GH-454-SIGNED-REQUEST-CAPABILITY-TAXONOMY

`GH-454-SIGNED-REQUEST-CAPABILITY-TAXONOMY`

Signed request capability taxonomy 只允许保留下列语义身份：

- credential reference
- timestamp identity
- recvWindow identity
- API-key header identity
- request signature identity
- signed account read-only
- listenKey lifecycle
- private event source
- command runtime boundary

这些 identity 不授权 request builder，不生成 HMAC，不构造 API-key header，不调用 signed endpoint。

## GH-454-LISTENKEY-PRIVATE-WEBSOCKET-FUTURE-CONTRACT

`GH-454-LISTENKEY-PRIVATE-WEBSOCKET-FUTURE-CONTRACT`

listenKey / private WebSocket future lifecycle 必须拆成独立 gate：

```text
credential / environment gate
-> signed endpoint boundary
-> listenKey create future gate
-> listenKey keep-alive future gate
-> private WebSocket open future gate
-> account snapshot source identity
-> private event source identity
-> private WebSocket close future gate
```

GH-454 不创建 listenKey，不 keep-alive，不 close listenKey，不打开 WebSocket，不 reconnect，不消费真实 private event。

## GH-454-ACCOUNT-SNAPSHOT-PRIVATE-EVENT-SOURCE-IDENTITY

`GH-454-ACCOUNT-SNAPSHOT-PRIVATE-EVENT-SOURCE-IDENTITY`

Account snapshot / private event source identity 只能描述未来 evidence 来源：

- signed account snapshot source
- private balance update source
- private position update source
- private margin state source
- private execution report source
- listenKey session source

这些 source identity 不包含 real account payload、listenKey value、signed request payload、broker payload、execution report payload 或订单命令。

## GH-454-FORBIDDEN-ENDPOINT-PATHS

`GH-454-FORBIDDEN-ENDPOINT-PATHS`

GH-454 明确禁止：

- credential value read
- API-key header construction
- request signature generation
- signed endpoint call
- account endpoint call
- listenKey creation / keep-alive / close
- private WebSocket open / reconnect
- real account snapshot read
- real private event consumption
- command runtime
- ExecutionClient adapter implementation
- OMS implementation
- real submit / cancel / replace
- production trading enabled by default
- Live PRO Console command surface
- order form

这些 forbidden paths 由 `L4SignedEndpointPrivateStreamBoundaryContract` 的 false flags 和 TargetGraph focused tests 机械验证。

## GH-454-NON-AUTHORIZATION

`GH-454-NON-AUTHORIZATION`

GH-454 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- 真实 API key / secret 读取、保存、打印或提交。
- signed endpoint client。
- account endpoint read。
- listenKey 创建、续期或关闭。
- private WebSocket runtime。
- 真实账户快照读取。
- private event 消费。
- ExecutionClient adapter implementation。
- OMS implementation。
- submit / cancel / replace。
- execution report / broker fill production ingestion。
- reconciliation production runtime。
- Live PRO Console command surface。
- order form / trading button。
- production cutover 或 real trading enablement。
