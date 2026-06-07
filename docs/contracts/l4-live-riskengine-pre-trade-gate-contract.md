# L4 Live RiskEngine Pre-trade Gate Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-464-LIVE-RISKENGINE-PRE-TRADE-GATE` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 13/21 个 GitHub fallback queue item 的 live-gated RiskEngine pre-trade allow / reject evidence。

本合同只实现 deterministic local RiskEngine gate：order proposal risk input、APB / margin read-model input、
allow / reject / blocked / incident stop decision evidence，以及 command path 必须经过 RiskEngine 的证据。
它不提交真实订单，不调用 ExecutionClient，不读取真实账户，不执行 reconciliation，也不授权 production enablement。

## GH-464 Order Proposal Risk Input

`GH-464-ORDER-PROPOSAL-RISK-INPUT` 固定：

- proposal 必须携带 symbol、quantity、limit price、command kind 和 GH-461 OMS contract identity。
- proposal 不能标记 risk gate bypass。
- proposal 不能绕过 OMS。
- proposal 不能请求 production trading。

## GH-464 APB / Margin Read-model Gate

`GH-464-APB-MARGIN-READ-MODEL-GATE` 固定：

- RiskEngine 只能接入 GH-457 read-model identity 和 account / position / balance / margin canonical values。
- RiskEngine target 不依赖 ExecutionClient target。
- read-model input 不暴露 raw account payload、broker state、Runtime object 或 Adapter request。

## GH-464 Allow / Reject / Blocked / Incident Evidence

`GH-464-ALLOW-REJECT-BLOCKED-INCIDENT-EVIDENCE` 的 canonical Swift evidence 位于：

- `Sources/RiskEngine/LiveGate/L4LiveRiskPreTradeGate.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

Decision evidence 必须覆盖：

- `allow`：sandbox proposal 通过 deterministic local notional / margin gate。
- `reject`：notional limit exceeded。
- `blocked`：risk gate unavailable / bypass rejected。
- `incident stop`：incident stop active。

## GH-464 Command Path RiskEngine Required

`GH-464-COMMAND-PATH-RISKENGINE-REQUIRED` 固定所有 sandbox command path 必须经过 RiskEngine。无 RiskEngine gate
时 command 不可执行；本 issue 不执行 command，只输出可审计 decision evidence。

## Validation

`TVM-L4-LIVE-RISKENGINE-PRE-TRADE-GATE` 对应验证：

- `testGH464LiveRiskPreTradeGateProducesAllowRejectBlockedIncidentEvidence`
- `testGH464LiveRiskPreTradeGateRejectsBypassAndForbiddenRuntime`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-464-NON-AUTHORIZATION`：本合同不授权 GH-465 kill switch / shutdown gate，不授权 GH-466 reconciliation，
不授权 GH-471 production cutover。合并本 issue 后，MTPRO 仍没有 production trading、real order lifecycle、
broker gateway、Live PRO Console command surface、order form 或 trading button。
