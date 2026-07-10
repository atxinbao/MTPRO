# MTPRO Release v0.29.1 Shadow Acceptance Integrity / Publication Gate Repair Patch Notes

Date: 2026-07-11  
Author: Codex

`TVM-RELEASE-V0291-SHADOW-ACCEPTANCE-INTEGRITY-PUBLICATION-GATE-REPAIR`

v0.29.1 is a no-capability-change patch for v0.29.0 publication and acceptance evidence integrity. v0.29.0 GitHub Release is published at https://github.com/atxinbao/MTPRO/releases/tag/v0.29.0 and points to `2b070ea979adfec5fccf90fcd823512d99ec4c3c`.

## Publication Facts

- Release: v0.29.0
- Release URL: https://github.com/atxinbao/MTPRO/releases/tag/v0.29.0
- Published at: `2026-07-10T14:23:30Z`
- Tag target commit: `2b070ea979adfec5fccf90fcd823512d99ec4c3c`
- Publication PR: PR #1458
- Publication workflow run: `29099609391`
- Workflow conclusion: `success`
- Closed milestones: #48, #49
- Closed issues: #1439-#1456

## Evidence Classification

v0.29.0 is now explicitly classified as contract + deterministic fixture evidence:

- `evidenceOrigin=deterministic-fixture`
- `acceptanceDecision=blocked`
- `acceptanceClassification=contract-deterministic-fixture`
- `observedRunAccepted=false`

Observed-run acceptance is separate and requires artifact validation:

- file exists and is a regular file
- safe relative path
- byte count matches manifest
- SHA-256 (`sha256`) is lowercase 64-hex and matches file contents
- run ID / source commit / `operatorApprovalID` / actor present
- observed timestamp is fresh and not expired
- provenance is `observed-run-artifact`
- redaction and immutable manifest checks are true

## Boundaries

- `productionTradingEnabledByDefault=false`
- `productionCutoverAuthorized=false`
- `productionSecretAutoReadEnabled=false`
- `automaticBrokerConnectionEnabled=false`
- `productionSubmitCancelReplaceEnabled=false`
- `noSubmitTransportMode=true`
- `shadowOnly=true`
- no production endpoint connection
- no broker submit / cancel / replace
- no OKX active runtime
- no new v0.30.0 capability

## Validation

- `swift test --filter TargetGraphTests/testGH1459To1467ReleaseV0291ShadowAcceptanceIntegrityPatch`
- `bash checks/verify-v0.29.1.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
