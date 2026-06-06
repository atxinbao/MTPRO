# L4 ExecutionClient Venue Adapter Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-458-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 07/21 个 GitHub fallback queue item 的合同边界。

本合同只定义 `ExecutionClient/<venue>` 是未来外部交易所 / broker venue adapter contract，
`ExecutionEngine` 是内部 order lifecycle / handoff / local state coordination 边界。当前 issue 不实现
broker gateway、真实订单、signed request、account endpoint、listenKey、private WebSocket、OMS、reconciliation、
Live PRO Console、order form 或 production trading。

## GH-458 ExecutionClient Venue Adapter Contract

`GH-458-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT` 的 canonical Swift evidence 位于：

- `Sources/ExecutionClient/FutureGate/L4ExecutionClientVenueAdapterContract.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

合同覆盖六类 operation family：

- submit
- cancel
- replace
- status / report query
- execution report parsing
- broker fill parsing

这些 operation 只是 adapter contract 行，不是 runtime。每一行都必须满足：

- 由 `ExecutionEngine` 完成内部 lifecycle / handoff / local state coordination。
- 由 `ExecutionClient/<venue>` 只表达 future external venue adapter responsibility。
- 进入 sandbox 前必须经过 sandbox venue gate。
- 进入 production 前必须经过 production venue gate。
- 当前 `implementsRuntime == false`。

## GH-458 ExecutionEngine Internal Lifecycle Boundary

`GH-458-EXECUTIONENGINE-INTERNAL-LIFECYCLE-BOUNDARY` 固定职责拆分：

- `ExecutionEngine` 是内部生命周期协调者，负责 order identity、risk-approved handoff、local state transition、
  audit evidence、后续 OMS gate 之后的 parsed evidence consumption。
- `ExecutionClient` 是外部 venue adapter contract，负责把已授权 intent 映射为 venue request shape，以及把
  status/report/fill evidence 映射为 contract evidence。
- `ExecutionClient` 不拥有内部 order state machine。
- `ExecutionEngine` 不直接连接交易所、不创建 broker gateway、不处理 production endpoint。

## GH-458 Sandbox / Production Venue Gate

`GH-458-SANDBOX-PRODUCTION-VENUE-GATE` 固定：

- sandbox venue gate 必须存在，后续 GH-459 才能在 sandbox scope 内继续实现 submit / cancel / replace。
- production venue 默认关闭。
- production cutover 在 GH-471 前保持 blocked。
- 本合同不允许把 sandbox gate 写成 production shortcut。

## GH-458 No Direct Trader / Strategy To ExecutionClient

`GH-458-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT` 固定：

- `TraderStrategies` / concrete strategy 只能产出 signal / proposal evidence。
- `Trader` 是 Accounts + Strategies/EMA + Coordination 容器。
- `Trader` 和 `Strategy` 都不得 direct import、依赖或调用 `ExecutionClient`。
- order intent 必须先经过 RiskEngine / ExecutionEngine 边界，再由未来 gated handoff 到 ExecutionClient。

## Forbidden Capabilities

当前 issue 继续禁止：

- direct Strategy / Trader to ExecutionClient
- broker gateway implementation
- signed request runtime
- account endpoint runtime
- listenKey runtime
- private WebSocket runtime
- sandbox submit / cancel / replace runtime
- production venue enabled
- production trading enabled by default
- real submit / cancel / replace
- execution report runtime parser
- broker fill runtime parser
- OMS implementation
- reconciliation runtime
- Live PRO Console command surface
- order form

## Validation

`TVM-L4-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT` 对应验证：

- `testGH458ExecutionClientVenueAdapterContractDefinesEngineClientBoundary`
- `testGH458ExecutionClientVenueAdapterContractRejectsDirectAccessAndRuntimeBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

本合同不授权 GH-459 之前的 sandbox submit / cancel / replace，不授权 GH-461 之前的 OMS，不授权 GH-471
之前的 production cutover。合并本 issue 后，`ExecutionClient` 仍不是 production broker gateway。
