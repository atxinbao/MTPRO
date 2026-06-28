#!/usr/bin/env bash
set -euo pipefail

# GH-1201-VERIFY-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE
# TVM-RELEASE-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE
# V0181-002-RELEASE-FULL-MATRIX-REQUIRED
# V0181-002-LINUX-CHECKS-JOB-EVIDENCE
# V0181-002-DASHBOARD-MACOS-JOB-EVIDENCE
# V0181-002-PR-FAST-NOT-PUBLICATION-EVIDENCE
# V0181-002-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'v0.18.1 release full matrix publication gate verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'v0.18.1 release full matrix publication gate verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

WORKFLOW=".github/workflows/checks.yml"
CI_VERIFIER="checks/verify-ci-pr-fast-lane-release-matrix.sh"
FOCUSED_TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUN_SCRIPT="checks/run.sh"
READINESS_SCRIPT="checks/automation-readiness.sh"

for file in \
  "$WORKFLOW" \
  "$CI_VERIFIER" \
  "$0" \
  "$FOCUSED_TESTS" \
  "$RUN_SCRIPT" \
  "$READINESS_SCRIPT" \
  "docs/automation/ci-reproducibility.md" \
  "docs/automation/automation-readiness.md" \
  "docs/release/release-publication-policy.md" \
  "docs/validation/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md"; do
  require_file_contains "$file" "GH-1201-VERIFY-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE"
  require_file_contains "$file" "TVM-RELEASE-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE"
  require_file_contains "$file" "V0181-002-RELEASE-FULL-MATRIX-REQUIRED"
  require_file_contains "$file" "V0181-002-LINUX-CHECKS-JOB-EVIDENCE"
  require_file_contains "$file" "V0181-002-DASHBOARD-MACOS-JOB-EVIDENCE"
  require_file_contains "$file" "V0181-002-PR-FAST-NOT-PUBLICATION-EVIDENCE"
  require_file_contains "$file" "V0181-002-NO-PRODUCTION-CUTOVER"
done

for expected in \
  "release_publication_checks:" \
  "name: release-publication-checks" \
  "always() &&" \
  "needs.linux_checks.result" \
  "needs.dashboard_macos.result" \
  "github.run_id" \
  "github.run_attempt" \
  "GITHUB_STEP_SUMMARY" \
  "MTPRO release publication workflow job ids: pr_fast_checks linux_checks dashboard_macos release_publication_checks" \
  "MTPRO release publication evidence artifacts: GitHub Actions run log, job summary, linux checks/run.sh output, dashboard macOS build/smoke output"; do
  require_file_contains "$WORKFLOW" "$expected"
done

for expected in \
  "release publication evidence must include GitHub Actions workflow run id" \
  "workflow job ids: pr_fast_checks, linux_checks, dashboard_macos, release_publication_checks" \
  "release publication cannot be represented as complete by pr-fast-checks or checks aggregate alone" \
  "linux-checks and dashboard-macos must both be SUCCESS for tag publication evidence" \
  "production cutover not authorized"; do
  require_file_contains "docs/automation/ci-reproducibility.md" "$expected"
  require_file_contains "docs/release/release-publication-policy.md" "$expected"
done

python3 - <<'PY'
from pathlib import Path

workflow = Path(".github/workflows/checks.yml").read_text()
release_condition = "github.event_name == 'workflow_dispatch' || startsWith(github.ref, 'refs/tags/v') || startsWith(github.ref, 'refs/heads/release/')"
release_job = workflow.split("  release_publication_checks:", 1)[1].split("  checks:", 1)[0]
required_job = workflow.split("  checks:", 1)[1]

if release_condition not in release_job:
    raise SystemExit("release_publication_checks must run only for workflow_dispatch, tag, or release branch")
if "always() &&" not in release_job:
    raise SystemExit("release_publication_checks must run even when a needed release lane fails so the gate reports matrix evidence")

for expected in (
    "- pr_fast_checks",
    "- linux_checks",
    "- dashboard_macos",
    'test "${{ needs.pr_fast_checks.result }}" = "success"',
    'test "${{ needs.linux_checks.result }}" = "success"',
    'test "${{ needs.dashboard_macos.result }}" = "success"',
    "github.run_id",
    "github.run_attempt",
    "GITHUB_STEP_SUMMARY",
    "GitHub Actions run log, job summary, linux checks/run.sh output, dashboard macOS build/smoke output",
):
    if expected not in release_job:
        raise SystemExit(f"release_publication_checks missing required evidence or fail-closed check: {expected}")

for forbidden in ("- linux_checks", "- dashboard_macos", "needs.linux_checks.result", "needs.dashboard_macos.result"):
    if forbidden in required_job:
        raise SystemExit(f"ordinary PR required checks must not wait on release matrix: {forbidden}")
PY

for forbidden in \
  "pull_request_target" \
  "secrets." \
  "api.binance.com" \
  "fapi.binance.com" \
  "productionTradingEnabledByDefault=true" \
  "productionEndpointConnected=true" \
  "productionSecretRead=true" \
  "productionOrderSubmitted=true" \
  "productionCutoverAuthorized=true"; do
  reject_file_contains "$WORKFLOW" "$forbidden"
done

swift test --filter TargetGraphTests/testGH1201ReleaseFullMatrixPublicationGateRequiresLinuxAndDashboardEvidence

printf 'MTPRO release v0.18.1 full matrix publication gate verification passed.\n'
