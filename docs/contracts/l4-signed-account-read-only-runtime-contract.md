# L4 Signed Account Read-only Runtime Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-455 L4: 04/21 Implement signed account read-only runtime behind disabled production gate`。

本文档定义 disabled-by-default 的 signed account read-only runtime。该 runtime 只在 sandbox / local fixture gate 满足时返回 canonical account evidence；它不读取真实 secret，不连接 signed endpoint、account endpoint 或 production endpoint，不暴露 raw signed payload 给 Dashboard，不实现 private stream、ExecutionClient adapter、OMS、trading command 或 order lifecycle。

## GH-455-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME

`GH-455-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME`

GH-455 runtime 依赖 GH-453 credential environment gate 和 GH-454 signed/private boundary。当前实现位于：

- `Sources/ExecutionClient/FutureGate/L4SignedAccountReadOnlyRuntime.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH455SignedAccountReadOnlyRuntimeDefaultsDisabledAndReturnsCanonicalEvidence`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH455SignedAccountReadOnlyRuntimeRejectsProductionSecretAndPayloadBypass`

Runtime 固定：

- 默认 disabled，未配置时不可触发 signed read。
- 只有 sandbox / local fixture gate 可返回 deterministic canonical evidence。
- production gate 默认关闭。
- validation 不依赖网络、secret、broker 或人工验收。

## GH-455-DISABLED-BY-DEFAULT-RUNTIME-GATE

`GH-455-DISABLED-BY-DEFAULT-RUNTIME-GATE`

`L4SignedAccountReadOnlyRuntimeConfiguration.disabled()` 是默认配置。调用 `readAccountEvidence` 会被拒绝：

```text
mode = disabled
-> no signed account read
-> no evidence output
```

可读取路径必须显式使用 `sandboxFixture`，并同时满足 credential reference identity、sandbox gate、fixture read gate 和 production disabled gate。

## GH-455-SANDBOX-FIXTURE-FIRST-READ

`GH-455-SANDBOX-FIXTURE-FIRST-READ`

Sandbox / fixture-first read 只返回 deterministic evidence：

| Component | Canonical evidence |
| --- | --- |
| account | sandbox-read-only-account |
| balance | USDT available fixture value |
| position | BTCUSDT net fixture value |
| margin | fixture-only margin interpretation |

这些值不是 account endpoint response、broker payload、private stream event、real balance、real position、margin / leverage runtime 或 real PnL。

## GH-455-CANONICAL-ACCOUNT-EVIDENCE

`GH-455-CANONICAL-ACCOUNT-EVIDENCE`

`L4SignedAccountReadOnlyEvidence` 只能暴露 canonical records：

- `readModelOnly == true`
- `rawSignedPayloadExposed == false`
- `dashboardRawPayloadExposed == false`
- `brokerStateExposed == false`
- `productionGateEnabled == false`
- `commandRuntimeEnabled == false`

Dashboard / Report / Events 后续只能消费 canonical evidence，不得消费 raw signed payload。

## GH-455-FORBIDDEN-PRODUCTION-DEFAULT-TESTS

`GH-455-FORBIDDEN-PRODUCTION-DEFAULT-TESTS`

Focused tests 必须拒绝：

- production mode
- production gate enabled
- production trading enabled by default
- secret material available
- raw payload exposure
- network connection
- missing credential reference under sandbox mode
- raw signed payload evidence

## GH-455-NON-AUTHORIZATION

`GH-455-NON-AUTHORIZATION`

GH-455 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- 真实 API key / secret 读取、保存、打印或提交。
- API-key header construction 或 request signature generation。
- signed endpoint、account endpoint 或 production endpoint call。
- listenKey、private WebSocket 或 private stream runtime。
- raw signed payload、account endpoint payload、broker state 或 Dashboard raw payload exposure。
- ExecutionClient adapter implementation。
- OMS implementation。
- trading command、submit / cancel / replace 或 order lifecycle。
- execution report、broker fill 或 reconciliation。
- Live PRO Console command surface。
- order form / trading button。
- production cutover 或 real trading enablement。
