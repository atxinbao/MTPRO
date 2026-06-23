# MTPRO Release v0.15.0 Real Binance Testnet Execution MVP Stage Code Audit

日期：2026-06-23

执行者：Codex

## Scope

本 Stage Code Audit 收口 GitHub fallback queue `release/v0.15.0` 的 #1066 至 #1076。该 release construction scope 从 v0.14.1 的 local execution evidence chain 进入真实 Binance Spot Testnet signed execution MVP：credential / signed request、submit、cancel、cancel-replace、append-only network event log、OMS state sync / reconciliation、CLI operator flow、Dashboard read-only status 和 failure simulation 都已具备可验证 evidence。

本 audit 不创建 `v0.15.0` tag，不创建 GitHub Release，不推进下一阶段。v0.15.0 public release publication 需要 Human 显式触发独立 Release Publication Gate。

Post-publication #1095 hardening clarification：本 audit 中的 `real Binance Spot Testnet signed execution MVP` 指 signed execution runtime contracts、injected Spot Testnet transport protocol evidence、redacted deterministic mock proof 和 operator manual proof workflow；它不是仓库内置 URLSession runner，不是 CLI 默认真实联网 runner，也不是 production broker connector；it is not a bundled URLSession runner。concrete URLSession transport 属于后续 #1096 hardening slice，不由 #1076 audit 自动授权。

## Validation Anchors

- `GH-1076-VERIFY-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT`
- `TVM-RELEASE-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT`
- `V0150-011-STAGE-CODE-AUDIT`
- `V0150-011-MANUAL-TESTNET-WORKFLOW`
- `V0150-011-RELEASE-NOTES`
- `V0150-011-VALIDATION-SUITE`
- `V0150-011-PRODUCTION-DISABLED-PROOF`
- `V0150-011-NO-PRODUCTION-CUTOVER`

## Issue Completion Evidence

| Issue | Scope | PR | Merge commit | Checks |
| --- | --- | --- | --- | --- |
| #1066 | contract / v0.14.1 preflight gate | #1083 | `5f846917e1ae8e347771b8e2061fd0135f67f82f` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1067 | testnet credential / signed request builder | #1084 | `a4ac613a28edea9120cdaf11dde3cf854f7fdd62` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1068 | real Spot Testnet submit runtime | #1085 | `41e3f79248e25b4cf541f01ecba4b45657ab94d8` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1071 | network execution event log | #1086 | `7baf3ab12a5ee62eee1df7677551dc264f435481` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1069 | real Spot Testnet cancel runtime | #1087 | `db538197d1fe4ebdd49714f25797bc614c76b219` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1070 | real Spot Testnet cancel-replace runtime | #1088 | `0016a42c9c715953b0da7a4ca6990636767931ca` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1072 | OMS state sync + reconciliation | #1089 | `288e535da9b947c8d1415095209f621c92ad8a34` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1073 | CLI operator flow | #1090 | `0189d9774fc274bc0b46bef34e2f1d28338f943a` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1074 | Dashboard testnet execution status | #1091 | `85d61f1d6ca22c18e00bdf1efdb4f52154fae73b` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1075 | failure simulation for real signed transport | #1092 | `79367ddc15b8f66cdd9a3da97e450512944dacd6` | `checks` / `linux-checks` / `dashboard-macos` SUCCESS |
| #1076 | release CI / manual testnet workflow / audit evidence | current PR | pending until this PR merges | This PR must pass `checks`, `linux-checks`, `dashboard-macos` before merge |

All #1066..#1075 issues are CLOSED / done before #1076 preflight. #1076 is the final active issue in the queue and must close through this PR.

## Evidence Chain

- `GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT`
- `GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST`
- `GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME`
- `GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG`
- `GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME`
- `GH-1070-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE-RUNTIME`
- `GH-1072-VERIFY-V0150-OMS-STATE-SYNC-RECONCILIATION`
- `GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW`
- `GH-1074-VERIFY-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS`
- `GH-1075-VERIFY-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT`
- `GH-1076-VERIFY-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT`

The release evidence confirms:

- v0.14.1 preflight release fact exists before v0.15.0 construction begins.
- Binance Spot Testnet is the only active execution venue / product scope for this MVP.
- Signed request construction uses testnet credential references and redacted HMAC evidence.
- Submit, cancel and cancel-replace paths are guarded by explicit operator confirmation and injected Spot Testnet transports.
- Injected Spot Testnet transport is a protocol boundary and proof seam; this audit does not prove an out-of-the-box built-in URLSession runner.
- Network action evidence is append-only and checksum chained with redacted request / response identity.
- OMS state sync and expected / observed reconciliation derive from append-only network event evidence.
- CLI operator flow requires explicit testnet confirmation and prints redacted evidence only.
- Dashboard consumes local read-model artifacts only and does not expose trading buttons, order forms or live commands.
- Failure simulation covers rejected request, timeout, rate-limit, stale credential, bad signature, cancel-not-found and reconciliation mismatch.

## Manual Testnet Workflow

The operator workflow is documented in `docs/operators/release-v0.15.0-real-binance-testnet-execution-mvp-runbook.md`.

Manual workflow summary:

1. Confirm local `main == origin/main`, clean worktree, open PR = 0 and no active queue conflict.
2. Run the release validation suite:

   ```bash
   git diff --check
   bash checks/automation-readiness.sh
   bash checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh
   bash checks/run.sh
   ```

3. For any real Spot Testnet execution rehearsal, use testnet-only credentials, Spot Testnet hosts, explicit operator confirmation, injected transports and redacted append-only evidence.
4. Review Dashboard read-only status from local artifacts only.
5. Stop immediately on production host, production secret, broker endpoint, raw secret output, unredacted order identity, missing operator confirmation, kill switch / no-trade blocker, reconciliation mismatch or active queue conflict.

## Boundary Audit

- `productionTradingEnabledByDefault=false`
- `productionSecretAutoRead=false`
- `productionEndpointConnected=false`
- `brokerEndpointConnected=false`
- `productionOrderSubmitted=false`
- `productionCutoverAuthorized=false`
- Binance only.
- Spot Testnet only for v0.15.0 execution MVP.
- No Futures / USDⓈ-M Perpetual execution in v0.15.0 MVP.
- No non-Binance venue.
- No production endpoint fallback.
- No production secret read.
- No production broker connection.
- No production order submit / cancel / replace.
- No Dashboard trading button.
- No Dashboard order form.
- No Dashboard live command.
- No Linear / Symphony / Graphify / code-index / Figma dependency.

## Validation Summary

Required local validation for this issue:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh
bash checks/run.sh
```

The focused verifier must run `swift test --filter TargetGraphTests/testGH1076ReleaseV0150FinalAuditManualWorkflowCloseout` and verify that release notes, operator runbook, Stage Code Audit, latest verification summary, automation readiness, validation plan, trading validation matrix, `checks/run.sh` and `checks/automation-readiness.sh` contain the closeout anchors and production-disabled proof.

## Known Residual Risk

v0.15.0 has a real Binance Spot Testnet execution MVP evidence path through signed runtime contracts and injected transport / manual proof. It still does not represent a bundled URLSession runner, production cutover readiness, or production execution capability. Any concrete network runner and any production cutover must be separately planned, separately authorized, and separately validated with production environment, credential, risk, kill switch, no-trade, incident rollback and operator approval gates.

## Root Docs Delta Input

After #1076 PR merges, a separate root docs refresh may synchronize only completed facts:

- v0.15.0 construction queue #1066..#1076 closed / done.
- PR #1083..#1092 and #1076 closure PR merged with required checks success.
- Stage Code Audit, release notes and operator runbook exist.
- Production trading remains disabled by default.
- v0.15.0 publication still requires a separate Release Publication Gate.

This audit does not modify root strategic direction and does not authorize v0.16.0 or any next Project / Issue.

## Next Handoff

After #1076 PR merges, Parent Codex may confirm queue completion and, only if Human explicitly asks, run a separate Release Publication Gate for `v0.15.0`.

This audit does not create a tag, does not create a GitHub Release, does not create a next Project / Issue, does not promote a next Todo, and does not authorize production cutover.
