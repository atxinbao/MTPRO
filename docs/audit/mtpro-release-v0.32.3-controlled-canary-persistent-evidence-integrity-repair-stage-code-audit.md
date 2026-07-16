# MTPRO Release v0.32.3 Controlled Canary Persistent Evidence Integrity Repair Stage Code Audit

日期：2026-07-17  
执行者：Codex

## Result

v0.32.3 repairs the persistent evidence-integrity findings from the v0.32.2 audit. The repair is accepted as a prerequisite for a later observed canary, but it does not accept backend closure and does not authorize production cutover.

Anchors: `GH-1541-CLOSE-V0323-STAGE-AUDIT-RELEASE-NOTES`, `TVM-RELEASE-V0323-CONTROLLED-CANARY-PERSISTENT-EVIDENCE-INTEGRITY-REPAIR`, `V0323-007-STAGE-AUDIT-RELEASE-NOTES`, `V0323-007-BACKEND-CLOSURE-BLOCKED`, `V0323-007-BINANCE-SPOT-USDM-FUTURES-ONLY`, `V0323-007-V0330-BLOCKED-UNTIL-V0323-PUBLISHED`, `V0323-007-NO-PRODUCTION-CUTOVER`.

## Evidence Chain

| Issue | Evidence | Result |
| --- | --- | --- |
| #1535 | v0.32.3 integrity repair contract | required repairs and blocked boundaries fixed |
| #1536 | trusted GitHub provenance loader | forged identity, checksum drift, incomplete jobs/operations, and self-report fail closed |
| #1537 | persistent run-lock store | atomic acquire, durable registry, owner/nonce/replay/stale recovery validation |
| #1538 | independent artifact graph | six operations bind twenty-four OMS/reconciliation/rollback/incident artifacts |
| #1539 | evidence-root containment | canonical real-path and symlink/traversal escape rejection |
| #1540 | complete negative matrix | every audit P1/P2 negative case is required by aggregate validation |
| #1541 | aggregate verifier, release notes, root docs, and publication workflow | v0.32.3 closeout remains fail closed |

## Required Facts

```text
trustedGitHubProvenanceRequired=true
manifestSelfReportTrusted=false
atomicPersistentRunLock=true
replayRegistryRequired=true
independentArtifactGraphRequired=true
realpathContainmentRequired=true
negativeMatrixComplete=true
observedProductionCanary=false
backendClosureDecision=blocked
productionCutoverAuthorized=false
productionTradingEnabledByDefault=false
activeVenue=binance
activeProducts=spot,usdsPerpetual
okxActiveRuntime=false
```

## Closure Decision

The v0.32.3 integrity repair can be released after the hosted full matrix passes. Backend closure remains blocked; v0.33.0 must independently collect Human-approved observed canary evidence and pass its own Stage Audit.

## Validation Commands

```bash
swift test --filter TargetGraphTests/testGH1541ReleaseV0323StageAuditReleaseDocsCloseout
bash checks/verify-v0.32.3.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```
