# MTPRO v0.33.0 Demo Validation Stage Code Audit

Date: 2026-07-19  
Executor: Codex

Anchors: `GH-1549-CLOSE-V0330-DEMO-VALIDATION-AUDIT-RELEASE-NOTES`, `TVM-RELEASE-V0330-DEMO-VALIDATION-PRODUCTION-CLOSURE-BLOCKED`, `V0330-008-DEMO-VALIDATION-AUDIT-RELEASE-NOTES`, `V0330-008-BINANCE-SPOT-USDM-FUTURES-ONLY`, `V0330-008-NO-PRODUCTION-CUTOVER`.

## Scope

This audit closes the v0.33.0 Demo validation queue for Binance Spot and Binance USD-M Futures. It records the successful Demo workflow evidence for issues #1544 and #1545 and the merged local evidence/status implementation for #1546-#1548.

Observed Demo workflow evidence:

- Spot: workflow run [#29653672291](https://github.com/atxinbao/MTPRO/actions/runs/29653672291), submit/status/cancel completed with HTTP 200 and final `CANCELED` state.
- USD-M Futures: workflow run [#29653822831](https://github.com/atxinbao/MTPRO/actions/runs/29653822831), submit/status/cancel completed with HTTP 200 and final `CANCELED` state.
- Both artifacts were redacted and reported `rawSecretPersisted=false` and `rawResponsePersisted=false`.

## Decision

The Demo evidence decision is accepted only when both product artifacts are independently present, provenance-bound, checksum-backed, and boundary-valid:

```text
demoValidationDecision=accepted
backendClosureDecision=blocked
productionCutoverAuthorized=false
defaultProductionTradingEnabled=false
```

The new `ReleaseV0330DemoValidationEvidenceBundle` rejects missing product evidence, mismatched source commits, invalid workflow provenance, unexpected product/action sets, production flag drift, and boundary violations. The status CLI fails with a non-zero exit code for a missing or invalid bundle; the Dashboard surface is read-model-only.

## Boundary

- Active venue: Binance only.
- Active products: Spot and USD-M Futures only.
- Environment: Binance Demo Network for the observed runs.
- No production endpoint, production secret, or production order was used.
- Demo validation does not authorize production backend closure or production cutover.
- No trading control is exposed by the Dashboard status surface.

## Validation

- `swift test --filter ReleaseV0330DemoValidationTests`
- `bash checks/verify-v0.33.0-demo-validation.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

This report is a Demo validation closeout, not a production trading authorization or a claim of observed production canary success.
