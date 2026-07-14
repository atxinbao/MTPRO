# MTPRO Release v0.31.1 Controlled Enablement Integrity / Publication Gate Repair Stage Code Audit

Date: 2026-07-15
Executor: Codex

## Scope

This patch closes the v0.31.1 integrity repair queue for controlled production enablement. It hardens publication sequencing, endpoint allowlist shape, approval binding, replay protection, evidence-root validation, risk negative cases, and v0.31.0 publication facts. It does not authorize production cutover.

## Anchors

- GH-1499-VERIFY-V0311-RELEASE-PUBLICATION-GATE
- GH-1500-VERIFY-V0311-ENDPOINT-ALLOWLIST-METHOD-HOST-PATH
- GH-1501-VERIFY-V0311-APPROVAL-SCOPE-EXPIRY-POLICY
- GH-1502-VERIFY-V0311-PERSISTENT-RUN-LOCK-REPLAY
- GH-1503-VERIFY-V0311-EVIDENCE-ROOT-ARTIFACT-VALIDATION
- GH-1504-VERIFY-V0311-RISK-GATE-NEGATIVE-INPUTS
- GH-1505-VERIFY-V0311-NEGATIVE-REGRESSION-MATRIX
- GH-1506-VERIFY-V0311-V0310-PUBLICATION-FACTS
- GH-1507-VERIFY-V0311-STAGE-AUDIT-RELEASE-NOTES
- TVM-RELEASE-V0311-CONTROLLED-ENABLEMENT-INTEGRITY-REPAIR
- V0311-001-RELEASE-PUBLICATION-AFTER-FULL-MATRIX
- V0311-002-ENDPOINT-METHOD-HOST-PATH-PRODUCT-FAMILY
- V0311-003-APPROVAL-SCOPE-EXPIRY-SOURCE-POLICY
- V0311-004-PERSISTENT-RUN-LOCK-REPLAY-PROTECTION
- V0311-005-EVIDENCE-ROOT-ARTIFACT-VALIDATION
- V0311-006-RISK-GATE-NEGATIVE-INPUTS
- V0311-007-NEGATIVE-REGRESSION-MATRIX
- V0311-008-V0310-PUBLICATION-FACTS
- V0311-009-STAGE-AUDIT-RELEASE-NOTES

## Evidence

- `ReleaseV0311ControlledEnablementIntegrityRepair` records publication gate evidence requiring PR fast checks, Linux checks, dashboard macOS, and release publication checks before release publication.
- Endpoint candidates are constrained by method, host, path, product, family, and query semantics.
- Approval evidence binds operator identity, scope, source, expiry, policy version, and product scope.
- Run lock evidence rejects replay through persisted run identity, nonce, approval hash, and expiry.
- Evidence-root validation requires release facts, immutable manifest, redaction, approval, run lock, risk, and publication artifacts.
- Risk negative cases reject stale, missing, excessive notional, kill switch, and no-trade inputs.

## Boundary

- productionTradingEnabledByDefault=false
- productionCutoverAuthorized=false
- automaticSecretReadEnabled=false
- automaticBrokerConnectionEnabled=false
- productionSubmitCancelReplaceEnabled=false
- defaultOrderMutationEnabled=false
