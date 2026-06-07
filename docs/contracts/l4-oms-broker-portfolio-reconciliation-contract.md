# L4 OMS / Broker / Portfolio Reconciliation Contract

日期：2026-06-07  
执行者：Codex

## Scope

`GH-466-OMS-BROKER-PORTFOLIO-RECONCILIATION` 固定 `MTPRO L4 Live Production / Trading Commands v1`
第 15/21 个 GitHub fallback queue item 的 OMS / sandbox broker report / portfolio projection reconciliation evidence。

本合同只实现 deterministic local reconciliation evidence：它比较 GH-462 OMS local transition、GH-460 normalized
sandbox broker report 和本地 portfolio projection snapshot，并输出 matched / mismatched / stale / missing 证据。
它不实现 production reconciliation runtime，不读取真实 broker account，不计算 real PnL，不写 Portfolio runtime，
不调用 ExecutionClient，也不暴露 Live PRO Console command surface。

## GH-466 Reconciliation Field Matrix

`GH-466-RECONCILIATION-FIELD-MATRIX` 固定允许比较的字段：

- client order id。
- OMS lifecycle state。
- broker report status。
- filled quantity。
- remaining quantity。
- projection sequence。

字段只能来自 normalized sandbox report、local OMS transition 和本地 projection snapshot。字段集合不包含 raw broker
payload、account endpoint payload、secret、真实账户余额、broker position 或 production broker statement。

## GH-466 Matched / Mismatched / Stale / Missing Evidence

`GH-466-MATCHED-MISMATCHED-STALE-MISSING-EVIDENCE` 固定四类对账状态：

- `matched`：OMS state、broker filled / remaining quantity 和 projection snapshot 完全一致。
- `mismatched`：projection state 或 quantity 与 OMS / broker report 不一致，输出可审计 mismatch reason。
- `stale`：projection sequence 落后于 OMS transition sequence，输出 stale reason。
- `missing`：broker report 和 OMS transition 存在，但 portfolio projection snapshot 缺失。

这些 evidence 只作为后续 audit trail / incident replay 输入，不执行 repair，不触发 broker read，不自动修复 Portfolio。

## GH-466 Partial Fill / Cancel / Reject Paths

`GH-466-PARTIAL-CANCEL-REJECT-PATHS` 固定必须覆盖：

- partial fill：绑定 GH-460 `partialFill` report 和 GH-462 `sandboxPartialFillReport` transition。
- cancel：绑定 GH-460 `cancelAcknowledgement` report 和 GH-462 `sandboxCancelAcknowledgement` transition。
- reject：绑定 GH-460 `reject` report 和 GH-462 `sandboxRejectReport` transition。

fill path 可以作为 additional missing evidence 使用，但不能替代 partial fill / cancel / reject 的必备覆盖。

## GH-466 Portfolio Projection No Broker Payload

`GH-466-PORTFOLIO-PROJECTION-NO-BROKER-PAYLOAD` 固定 portfolio projection snapshot 只能由 normalized sandbox report
和 OMS transition evidence 派生。Projection 不能读取 raw broker payload、不能读取真实账户、不能计算 real PnL、
不能写 Portfolio runtime、不能调用 broker gateway，也不能生产 repair command。

## Validation

`TVM-L4-OMS-BROKER-PORTFOLIO-RECONCILIATION` 对应验证：

- `testGH466OMSBrokerPortfolioReconciliationBuildsDeterministicEvidence`
- `testGH466OMSBrokerPortfolioReconciliationRejectsProductionBrokerPayloadAndCoverageBypass`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Non-authorization

`GH-466-NON-AUTHORIZATION`：本合同不授权 GH-467 audit trail / incident replay，不授权 GH-468 Dashboard /
Live PRO Console split，不授权 GH-469 guarded submit / cancel / replace UI，不授权 GH-470 sandbox validation matrix
closure，不授权 GH-471 production cutover。合并本 issue 后，MTPRO 仍没有 production reconciliation、production
trading、real PnL、real broker gateway、Live PRO Console command surface、order form、trading button 或 real submit /
cancel / replace。
