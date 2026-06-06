# L4 OMS Local Order Transition Evidence Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-462-OMS-LOCAL-ORDER-STATE-RECORD` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 11/21 个 GitHub fallback queue item 的 OMS local order transition evidence。

本合同只实现 deterministic sandbox local state record、transition evidence、fill / cancel / reject evidence 和 illegal
transition rejection。它不提交真实订单，不写 production order state store，不消费 production broker report，不更新 Portfolio，
不执行 reconciliation，也不授权 UI command surface。

## GH-462 OMS Local Order State Record

`GH-462-OMS-LOCAL-ORDER-STATE-RECORD` 的 canonical Swift evidence 位于：

- `Sources/ExecutionEngine/OMSFutureGate/L4OMSLocalOrderTransitionEvidence.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

`L4OMSLocalOrderStateRecord` 只保存 local-only order identity、state、sequence 和 source evidence identity。它不是
production state store record，也不代表真实 broker state。

## GH-462 Deterministic Transition Evidence

`GH-462-DETERMINISTIC-TRANSITION-EVIDENCE` 固定：

- local transition 必须由 GH-461 `L4OMSOrderLifecycleContract` 判定允许。
- `accepted -> submitted` 只引用 GH-459 sandbox submit evidence。
- fill / partial fill / cancel / reject transition 必须引用 GH-460 parsed report event。
- transition evidence 必须 deterministic，不提交订单、不联网、不写 production store。

## GH-462 Sandbox Fill / Cancel / Reject Evidence

`GH-462-SANDBOX-FILL-CANCEL-REJECT-EVIDENCE` 固定三条 deterministic lifecycle：

- fill path: accepted -> submitted -> partially filled -> filled
- cancel path: accepted -> submitted -> cancelled
- reject path: accepted -> rejected

这些 path 只证明 sandbox lifecycle evidence 完整，不代表 production OMS runtime。

## GH-462 Illegal Transition Rejection

`GH-462-ILLEGAL-TRANSITION-REJECTION` 固定非法转换必须被拒绝且不产生 state mutation。非法转换 rejection 必须保留
rollback / incident evidence，但不得 retry、cancel broker order 或执行 reconciliation。

## GH-462 Broker Independent Local State

`GH-462-BROKER-INDEPENDENT-LOCAL-STATE` 固定：

- local state evidence 不依赖真实 broker。
- 不读取 API key / secret。
- 不消费 production broker report。
- 不写 real order state store。
- 不更新 Portfolio，不执行 reconciliation。

## Validation

`TVM-L4-OMS-LOCAL-ORDER-TRANSITION-EVIDENCE` 对应验证：

- `testGH462OMSLocalOrderTransitionEvidenceBuildsDeterministicSandboxLifecycle`
- `testGH462OMSLocalOrderTransitionEvidenceRejectsIllegalTransitionAndRuntimeBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-462-NON-AUTHORIZATION`：本合同不授权 GH-463 ExecutionEngine -> ExecutionClient sandbox path，不授权 GH-466
reconciliation，不授权 GH-471 production cutover。合并本 issue 后，MTPRO 仍没有 production OMS、real order lifecycle、
broker gateway、Live PRO Console command surface、order form 或 trading button。
