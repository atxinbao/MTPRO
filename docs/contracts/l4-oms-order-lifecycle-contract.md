# L4 OMS Order Lifecycle Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-461-OMS-ORDER-LIFECYCLE-STATE-MACHINE` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 10/21 个 GitHub fallback queue item 的 OMS lifecycle state machine 合同。

本合同只定义本地 order state taxonomy、state transition rules、illegal transition evidence、rollback / incident evidence
和 ExecutionEngine / ExecutionClient / Portfolio 边界。它不实现 production order manager，不提交真实订单，
不消费 production broker report，不写真实 order state store，不执行 reconciliation，也不授权 Live command surface。

## GH-461 OMS Order Lifecycle State Machine

`GH-461-OMS-ORDER-LIFECYCLE-STATE-MACHINE` 的 canonical Swift evidence 位于：

- `Sources/ExecutionEngine/OMSFutureGate/L4OMSOrderLifecycleContract.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

`L4OMSOrderLifecycleContract` 固定的 local order states：

- accepted
- submitted
- partially filled
- filled
- cancelled
- rejected

这些 state 只属于 local OMS contract taxonomy。GH-462 才能实现本地 transition evidence；GH-463 才能处理
ExecutionEngine -> ExecutionClient sandbox wiring；GH-466 才能处理 reconciliation。

## GH-461 Local Order / Broker Report Relationship

`GH-461-LOCAL-ORDER-BROKER-REPORT-RELATIONSHIP` 固定：

- `accepted -> submitted` 只能引用 GH-459 deterministic sandbox submit command evidence。
- `submitted -> partiallyFilled` 只能引用 GH-460 partial fill parser evidence。
- `submitted / partiallyFilled -> filled` 只能引用 GH-460 fill parser evidence。
- `submitted / partiallyFilled -> cancelled` 只能引用 GH-460 cancel acknowledgement parser evidence。
- `accepted / submitted -> rejected` 只能引用 GH-460 reject parser evidence。

这些关系不代表真实 broker report ingestion，也不写 Portfolio projection 或 reconciliation。

## GH-461 Illegal Transition Evidence

`GH-461-ILLEGAL-TRANSITION-EVIDENCE` 固定非法转换 evidence 必须覆盖：

- filled -> submitted
- cancelled -> partially filled
- rejected -> filled

非法转换 evidence 必须要求 rollback / incident evidence，但不得直接 mutate order state。

## GH-461 OMS / Engine / Client / Portfolio Boundary

`GH-461-OMS-ENGINE-CLIENT-PORTFOLIO-BOUNDARY` 固定：

- ExecutionEngine 只拥有 local lifecycle coordination contract。
- ExecutionClient 只提供 GH-460 sandbox report evidence。
- Portfolio 只消费后续 projection，不由本合同直接写入。
- RiskEngine pre-trade boundary 仍是必经前置，不允许 bypass。

## GH-461 Rollback / Incident Evidence

`GH-461-ROLLBACK-INCIDENT-EVIDENCE` 固定 rollback / incident evidence 只说明异常和非法转换需要审计证据。
它不执行自动 retry，不恢复订单，不重放 production broker report，不启动 incident automation。

## Forbidden Capabilities

当前 issue 继续禁止：

- production order manager implemented
- real order submission enabled
- direct ExecutionClient bypass
- RiskEngine bypass
- production broker report consumed
- broker gateway touched
- real order state store written
- Portfolio mutation produced
- reconciliation runtime produced
- Live command surface touched

## Validation

`TVM-L4-OMS-ORDER-LIFECYCLE-CONTRACT` 对应验证：

- `testGH461OMSOrderLifecycleContractDefinesStateMachineAndBoundaries`
- `testGH461OMSOrderLifecycleContractRejectsIllegalTransitionAndBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-461-NON-AUTHORIZATION`：本合同不授权 GH-462 local order transition evidence，不授权 GH-463
ExecutionEngine -> ExecutionClient sandbox path，不授权 GH-466 reconciliation，不授权 GH-471 production cutover。合并本 issue
后，MTPRO 仍没有 production OMS、real order lifecycle、broker gateway、Live PRO Console command surface 或 trading button。
