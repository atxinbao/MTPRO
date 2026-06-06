# L4 ExecutionClient Sandbox Submit / Cancel / Replace Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-459-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 08/21 个 GitHub fallback queue item 的 sandbox-only 输出路径。

本合同只实现本地 deterministic sandbox venue adapter、request envelope 和 command evidence。它不连接真实 broker，
不生成 signed request，不调用 account endpoint，不创建 listenKey，不打开 private WebSocket，不推进 OMS，不实现
production venue，也不授权真实 submit / cancel / replace。

## GH-459 ExecutionClient Sandbox Submit / Cancel / Replace

`GH-459-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE` 的 canonical Swift evidence 位于：

- `Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxVenueAdapter.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

`L4ExecutionClientSandboxVenueAdapter` 只支持三类 sandbox command：

- submit
- cancel
- replace

每个 command 都通过 `L4ExecutionClientSandboxRequestEnvelope` 输入，并返回
`L4ExecutionClientSandboxCommandResponse`。该 response 只代表 deterministic sandbox acceptance，不代表交易所确认、
broker fill、execution report、OMS transition 或真实 order lifecycle。

## GH-459 Sandbox Request Envelope

`GH-459-SANDBOX-REQUEST-ENVELOPE` 固定 request envelope 只包含：

- envelope identity
- issue identity `GH-459`
- upstream issue identity `GH-458`
- sandbox command kind
- sandbox venue identity
- client order identity
- symbol / quantity / limit price / reason

Envelope 不包含 HTTP path、header、signature、secret、account payload、broker payload、network URL 或 production endpoint。
`venueMode == production` 必须被拒绝。

## GH-459 Deterministic Command Evidence

`GH-459-DETERMINISTIC-COMMAND-EVIDENCE` 固定 evidence 必须同时覆盖 submit、cancel、replace 三类 command。

Evidence 必须证明：

- request / response identity 可审计。
- 所有 request 和 response 都是 sandbox mode。
- sandbox response 全部 accepted。
- production venue disabled。
- signed endpoint、broker gateway、real order lifecycle、OMS 和 Live command surface 全部未触碰。

## GH-459 Production Venue Disabled

`GH-459-PRODUCTION-VENUE-DISABLED` 固定：

- production venue 默认不可达。
- production trading 默认关闭。
- GH-471 之前不得打开 production cutover。
- 任何 production mode envelope、adapter 或 evidence 都必须被 deterministic tests 拒绝。

## Forbidden Capabilities

当前 issue 继续禁止：

- production venue reachable
- production trading enabled by default
- secret read
- signed request generated
- account endpoint called
- listenKey runtime
- private WebSocket runtime
- broker gateway touched
- real order submitted / canceled / replaced
- execution report runtime parser
- broker fill runtime parser
- OMS implementation
- reconciliation runtime
- Live PRO Console command surface
- order form

## Validation

`TVM-L4-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE` 对应验证：

- `testGH459ExecutionClientSandboxVenueAdapterProducesDeterministicCommandEvidence`
- `testGH459ExecutionClientSandboxVenueAdapterRejectsProductionAndBrokerBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-459-NON-AUTHORIZATION`：本合同不授权 GH-460 execution report / broker fill parser，不授权 GH-461 OMS，
不授权 GH-463 ExecutionEngine -> ExecutionClient wiring，不授权 GH-471 production cutover。合并本 issue 后，
`ExecutionClient` 仍不是 production broker gateway。
