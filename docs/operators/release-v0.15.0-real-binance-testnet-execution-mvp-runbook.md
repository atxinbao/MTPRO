# MTPRO Release v0.15.0 Real Binance Testnet Execution MVP Operator Runbook

日期：2026-06-23

执行者：Codex

Scope: v0.15.0 Real Binance Testnet Execution MVP, issues #1066 至 #1076

Anchor set:

- `GH-1076-VERIFY-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT`
- `TVM-RELEASE-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT`
- `V0150-011-STAGE-CODE-AUDIT`
- `V0150-011-MANUAL-TESTNET-WORKFLOW`
- `V0150-011-RELEASE-NOTES`
- `V0150-011-VALIDATION-SUITE`
- `V0150-011-PRODUCTION-DISABLED-PROOF`
- `V0150-011-NO-PRODUCTION-CUTOVER`

## Purpose

This runbook tells an operator how to review and rehearse the v0.15.0 Binance Spot Testnet execution MVP locally. It is a manual testnet workflow and audit guide only. It is not a production cutover guide.

#1095 hardening note: v0.15.0 provides signed execution runtime contracts, injected Spot Testnet transport protocol evidence, deterministic mock proof and operator manual proof. It does not ship an out-of-the-box built-in URLSession runner, and the CLI is not a default real-network execution runner. Any concrete URLSession transport must be implemented and validated by a later issue, #1096.

## Preconditions

- #1066 through #1076 are closed / done after #1076 PR merge.
- PR #1083 through #1092 and the #1076 closure PR are merged with required checks success.
- Local `main` is fast-forwarded to `origin/main`.
- Worktree is clean.
- Production trading remains disabled by default.
- Operator has testnet-only credential material outside the repository.
- Operator has confirmed that no production secret, production host or broker endpoint is present in the run environment.

## Verification Commands

Run the focused closeout guard first:

```bash
bash checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh
```

Then run the standard local gates:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Manual Testnet Workflow

1. Confirm repository state:

   ```bash
   git status --short --branch
   gh pr list --state open
   gh issue list --state open --label todo
   gh issue list --state open --label in-progress
   gh issue list --state open --label in-review
   ```

2. Confirm release scope:

   - active venue: Binance only.
   - active product type for execution MVP: Spot Testnet only.
   - no Futures / USDⓈ-M Perpetual execution in v0.15.0 MVP.
   - no production endpoint fallback.
   - no Dashboard command surface.

3. Prepare testnet-only credentials:

   - use credential references outside the repository.
   - never persist raw API key, raw secret, raw signature input or raw broker payload.
   - reject production credential names, production hostnames or broker endpoint names.

4. Build signed request evidence:

   - use the #1067 signed request builder.
   - confirm request evidence is redacted.
   - confirm `productionSecretAutoRead=false`.
   - confirm `productionEndpointConnected=false`.

5. Rehearse Spot Testnet submit / cancel / cancel-replace only with explicit operator confirmation:

   - submit uses #1068 evidence path.
   - cancel uses #1069 evidence path.
   - cancel-replace uses #1070 cancel + new submit emulation.
   - transport is injected or represented by documented operator manual proof; do not assume a repository-bundled URLSession runner exists in v0.15.0.
   - native cancel-replace endpoint remains unsupported / fail-closed.

6. Review append-only execution evidence:

   - #1071 event log must contain redacted request / response identity.
   - sequence and checksum chain must be coherent.
   - no raw secret, raw credential, raw order identity or raw broker payload may appear.

7. Review OMS and reconciliation:

   - #1072 state derives from append-only network event evidence.
   - expected / observed reconciliation must pass or fail closed with explicit reason.
   - broker fill remains outside v0.15.0 MVP.

8. Review CLI and Dashboard:

   - #1073 CLI requires explicit testnet confirmation and prints redacted evidence only.
   - #1074 Dashboard reads local artifacts only.
   - Dashboard trading button, order form and live command remain absent.

9. Run failure simulation:

   - #1075 must cover rejected request, timeout, rate-limit, stale credential, bad signature, cancel-not-found and reconciliation mismatch.
   - every failure must produce redacted, deterministic, append-only evidence.
   - every failure must fail closed.

## Stop Rules

Stop and do not proceed if any of the following are observed:

- production trading enabled by default.
- production secret read or raw secret output.
- production endpoint connection.
- broker endpoint connection.
- non-Binance venue.
- Futures / USDⓈ-M execution attempted in v0.15.0 MVP.
- missing explicit operator confirmation.
- Dashboard trading button, order form or live command appears.
- append-only checksum chain mismatch.
- unredacted request / response / credential / order identity.
- reconciliation mismatch without fail-closed evidence.
- active queue conflict or open PR conflict.
- request to authorize production cutover.
- request that would treat v0.15.0 as a built-in URLSession network runner or CLI default real-network executor; do not treat v0.15.0 as either.

## Boundary

`V0150-011-NO-PRODUCTION-CUTOVER` is mandatory. v0.15.0 supports Binance Spot Testnet execution MVP evidence only. Production cutover, production broker connection and production orders remain separately gated and unauthorized.
