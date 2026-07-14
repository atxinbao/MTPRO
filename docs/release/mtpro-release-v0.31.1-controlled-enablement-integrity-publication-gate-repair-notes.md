# MTPRO v0.31.1 Controlled Enablement Integrity / Publication Gate Repair

Date: 2026-07-15
Executor: Codex

v0.31.1 is a repair patch for the v0.31.0 controlled production enablement gate. It does not add trading capability and does not authorize production cutover.

## Fixed Scope

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

## Release Notes

The patch requires release publication to wait for the full publication matrix, records v0.31.0 publication facts, and makes controlled enablement evidence reject invalid endpoints, approvals, run locks, artifact roots, and risk inputs. `v0.32.0` can only proceed after this patch closeout.

Production trading remains disabled by default. Automatic secret read, automatic broker connection, unrestricted trading, submit, cancel, replace, and production cutover remain unavailable.
