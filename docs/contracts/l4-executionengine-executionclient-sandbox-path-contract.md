# L4 ExecutionEngine -> ExecutionClient Sandbox Path Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-463-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 12/21 个 GitHub fallback queue item 的 ExecutionEngine -> ExecutionClient sandbox path evidence。

本合同只实现 deterministic local evidence：RiskEngine-approved command proposal、ExecutionEngine handoff、
sandbox ExecutionClient request / response 和 execution event evidence。它不打开 production execution，不提交真实订单，
不实现真实 broker adapter，不执行 reconciliation，也不授权 Live PRO Console command surface。

## GH-463 RiskEngine-approved Command Proposal

`GH-463-RISKENGINE-APPROVED-COMMAND-PROPOSAL` 固定：

- proposal 来源只能是 `RiskEngine approved command proposal`。
- proposal 必须 routed through ExecutionEngine。
- proposal 必须 routed through OMS local transition evidence。
- direct Trader、direct Strategy 和 Live PRO Console command 都必须被拒绝。

## GH-463 Sandbox ExecutionClient Handoff

`GH-463-SANDBOX-EXECUTIONCLIENT-HANDOFF` 的 canonical Swift evidence 位于：

- `Sources/ExecutionEngine/OMSFutureGate/L4ExecutionEngineSandboxPathEvidence.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

`L4ExecutionEngineSandboxPathCoordinator` 只调用 GH-459 `L4ExecutionClientSandboxVenueAdapter`，且只使用 sandbox mode。
它不会生成 signed request，不读取 secret，不连接 production venue，不触碰 broker gateway。

## GH-463 Command / Response / Event Evidence

`GH-463-COMMAND-RESPONSE-EVENT-EVIDENCE` 固定：

- command evidence 覆盖 submit / cancel / replace。
- response evidence 来自 GH-459 sandbox adapter。
- execution event evidence 覆盖 proposal accepted、request dispatched、response recorded 和 local transition evidence linked。
- event 只作为 deterministic audit evidence，不写 Portfolio，不执行 reconciliation。

## GH-463 No Direct Trader / Strategy -> ExecutionClient

`GH-463-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT` 固定：

- Trader 不能直接调用 ExecutionClient。
- Strategy 不能直接调用 ExecutionClient。
- Live PRO Console 不能直接调用 ExecutionClient。
- ExecutionEngine handoff 必须保留 RiskEngine boundary 和 OMS local transition evidence。

## Validation

`TVM-L4-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH` 对应验证：

- `testGH463ExecutionEngineSandboxPathWiresRiskApprovedCommandEvidence`
- `testGH463ExecutionEngineSandboxPathRejectsDirectAccessAndBoundaryBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-463-NON-AUTHORIZATION`：本合同不授权 GH-464 live RiskEngine runtime，不授权 GH-466 reconciliation，
不授权 GH-471 production cutover。合并本 issue 后，MTPRO 仍没有 production OMS、real order lifecycle、
broker gateway、Live PRO Console command surface、order form 或 trading button。
