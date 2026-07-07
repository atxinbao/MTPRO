# MTPRO Release v0.25.0 Dual-product Production Readiness Contract

Date: 2026-07-07
Author: Codex

## Anchors

- GH-1372-VERIFY-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT
- TVM-RELEASE-V0250-DUAL-PRODUCT-PRODUCTION-READINESS-CONTRACT
- V0250-001-DUAL-PRODUCT-PRODUCTION-READINESS
- V0250-001-NO-DEFAULT-TRADING
- V0250-001-SPOT-CANARY-EVIDENCE-NOT-CUTOVER
- V0250-001-FUTURES-READONLY-EVIDENCE-NOT-EXECUTION
- V0250-001-BLOCKED-BY-V0241-COMPLETION

## Purpose

`v0.25.0` defines the Binance dual-product production readiness / canary hardening contract.
It uses the already completed Spot controlled canary evidence and Futures read-only evidence as
inputs, but it does not convert either input into unrestricted production trading approval.

## Product Roles

| Venue | Product | Role | Source release | Boundary |
| --- | --- | --- | --- | --- |
| Binance | Spot | `spot-controlled-canary-evidence` | `v0.22.0` | Evidence for controlled canary readiness only; it is not production cutover. |
| Binance | USD-M Perpetual | `futures-readonly-evidence` | `v0.23.0` | Read-only evidence only; it is not Futures order execution approval. |

## Required Vocabulary

- `dual-product-readiness`
- `no-default-trading`
- `manual-approval-required`
- `dry-run-or-blocked-evidence`
- `spot-canary-evidence`
- `futures-readonly-evidence`

## Fixed Boundary

- `productionTradingEnabledByDefault=false`
- `productionCutoverAuthorized=false`
- `futuresSubmitCancelReplaceEnabled=false`
- `okxActiveRuntimeEnabled=false`
- `dashboardTradingControlsEnabled=false`
- `orderFormEnabled=false`
- `liveCommandEnabled=false`
- `dryRunOrBlockedEvidenceRequired=true`
- `manualApprovalRequired=true`

## Non-goals

- Do not authorize production cutover.
- Do not enable Futures submit / cancel / replace.
- Do not add OKX active runtime.
- Do not add Dashboard trading button, order form or live command.
- Do not treat Spot canary evidence as unrestricted live trading approval.
- Do not treat Futures read-only evidence as trading authorization.

## Implementation Evidence

- `Sources/ExecutionClient/FutureGate/ReleaseV0250DualProductProductionReadinessContract.swift`
- `Sources/MTPROCLI/main.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`

## Validation

Focused validation:

```bash
swift test --filter TargetGraphTests/testGH1372ReleaseV0250DualProductProductionReadinessContract
git diff --check
bash checks/automation-readiness.sh
```
