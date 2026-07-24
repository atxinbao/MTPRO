#!/usr/bin/env bash
set -euo pipefail

# CI-PR-FAST-LANE-RELEASE-MATRIX
# CI-PR-FAST-LANE-REQUIRED-CHECKS
# CI-RELEASE-FULL-LINUX-MACOS-MATRIX
# GH-1201-VERIFY-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE
# TVM-RELEASE-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE
# V0181-002-RELEASE-FULL-MATRIX-REQUIRED
# V0181-002-LINUX-CHECKS-JOB-EVIDENCE
# V0181-002-DASHBOARD-MACOS-JOB-EVIDENCE
# V0181-002-PR-FAST-NOT-PUBLICATION-EVIDENCE
# V0181-002-NO-PRODUCTION-CUTOVER
# CI-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'CI PR fast lane / release full matrix verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'CI PR fast lane / release full matrix verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

WORKFLOW=".github/workflows/checks.yml"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
READINESS_DOC="docs/automation/automation-readiness.md"
CI_DOC="docs/automation/ci-reproducibility.md"
READINESS_SCRIPT="checks/automation-readiness.sh"
RUN_SCRIPT="checks/run.sh"

for anchor in \
  "CI-PR-FAST-LANE-RELEASE-MATRIX" \
  "CI-PR-FAST-LANE-REQUIRED-CHECKS" \
  "CI-RELEASE-FULL-LINUX-MACOS-MATRIX" \
  "GH-1201-VERIFY-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE" \
  "TVM-RELEASE-V0181-RELEASE-FULL-MATRIX-PUBLICATION-GATE" \
  "V0181-002-RELEASE-FULL-MATRIX-REQUIRED" \
  "V0181-002-LINUX-CHECKS-JOB-EVIDENCE" \
  "V0181-002-DASHBOARD-MACOS-JOB-EVIDENCE" \
  "V0181-002-PR-FAST-NOT-PUBLICATION-EVIDENCE" \
  "V0181-002-NO-PRODUCTION-CUTOVER" \
  "CI-NO-PRODUCTION-CUTOVER"; do
  require_file_contains "$0" "$anchor"
  require_file_contains "$WORKFLOW" "$anchor"
  require_file_contains "$TESTS" "$anchor"
  require_file_contains "$READINESS_DOC" "$anchor"
  require_file_contains "$CI_DOC" "$anchor"
  require_file_contains "$READINESS_SCRIPT" "$anchor"
  require_file_contains "$RUN_SCRIPT" "$anchor"
done

require_file_contains "$WORKFLOW" "pull_request:"
require_file_contains "$WORKFLOW" "workflow_dispatch:"
require_file_contains "$WORKFLOW" "contents: read"
require_file_contains "$WORKFLOW" "contents: write"
require_file_contains "$WORKFLOW" "persist-credentials: false"
require_file_contains "$WORKFLOW" "cancel-in-progress: \${{ github.event_name == 'pull_request' }}"
require_file_contains "$WORKFLOW" "branches:"
require_file_contains "$WORKFLOW" "\"release/**\""
require_file_contains "$WORKFLOW" "\"v*\""
require_file_contains "$WORKFLOW" "pr_fast_checks:"
require_file_contains "$WORKFLOW" "name: pr-fast-checks"
require_file_contains "$WORKFLOW" "Run automation readiness"
require_file_contains "$WORKFLOW" "bash checks/automation-readiness.sh"
require_file_contains "$WORKFLOW" "bash checks/verify-ci-pr-fast-lane-release-matrix.sh"
require_file_contains "$WORKFLOW" "linux_checks:"
require_file_contains "$WORKFLOW" "name: linux-checks"
require_file_contains "$WORKFLOW" "dashboard_macos:"
require_file_contains "$WORKFLOW" "name: dashboard-macos"
require_file_contains "$WORKFLOW" "release_publication_checks:"
require_file_contains "$WORKFLOW" "name: release-publication-checks"
require_file_contains "$WORKFLOW" "always() &&"
require_file_contains "$WORKFLOW" "MTPRO release publication matrix: workflow="
require_file_contains "$WORKFLOW" "run_id="
require_file_contains "$WORKFLOW" "run_attempt="
require_file_contains "$WORKFLOW" "MTPRO release publication workflow job ids: pr_fast_checks linux_checks dashboard_macos release_publication_checks"
require_file_contains "$WORKFLOW" "MTPRO release publication job results: pr-fast-checks="
require_file_contains "$WORKFLOW" "linux-checks="
require_file_contains "$WORKFLOW" "dashboard-macos="
require_file_contains "$WORKFLOW" "MTPRO release publication evidence artifacts: GitHub Actions run log, job summary, linux checks/run.sh output, dashboard macOS build/smoke output"
require_file_contains "$WORKFLOW" "GITHUB_STEP_SUMMARY"
require_file_contains "$WORKFLOW" "needs.linux_checks.result"
require_file_contains "$WORKFLOW" "needs.dashboard_macos.result"
require_file_contains "$WORKFLOW" "if: \${{ github.event_name == 'workflow_dispatch' || startsWith(github.ref, 'refs/tags/v') || startsWith(github.ref, 'refs/heads/release/') }}"
require_file_contains "$WORKFLOW" "bash checks/run.sh"
require_file_contains "$WORKFLOW" "swift build --product Dashboard"
require_file_contains "$WORKFLOW" "DASHBOARD_SMOKE=1 swift run Dashboard"
require_file_contains "$WORKFLOW" "MTPRO required checks aggregate: event="
require_file_contains "$WORKFLOW" "needs.pr_fast_checks.result"
require_file_contains "$WORKFLOW" "needs.release_publication_checks.result"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-ci-pr-fast-lane-release-matrix.sh"
require_file_contains "$READINESS_SCRIPT" "checks/verify-ci-pr-fast-lane-release-matrix.sh"
require_file_contains "$TESTS" "testCIRequiredChecksUsePRFastLaneAndReleaseFullMatrix"

python3 - <<'PY'
from pathlib import Path

workflow = Path(".github/workflows/checks.yml").read_text()
workflow_header = workflow.split("jobs:", 1)[0]
if "permissions:\n  contents: read" not in workflow_header:
    raise SystemExit("workflow default permissions must be contents: read")
if "contents: write" in workflow_header:
    raise SystemExit("workflow-level contents: write must not grant PR jobs repository write access")

required_job = workflow.split("  checks:", 1)[1]
for expected in (
    "if: ${{ always() }}",
    "- pr_fast_checks",
    "- linux_checks",
    "- dashboard_macos",
    "- release_publication_checks",
    "needs.pr_fast_checks.result",
    "needs.linux_checks.result",
    "needs.dashboard_macos.result",
    "needs.release_publication_checks.result",
    'if [[ "${{ github.event_name }}" == "pull_request" ]]',
    'test "${{ needs.linux_checks.result }}" = "skipped"',
    'test "${{ needs.dashboard_macos.result }}" = "skipped"',
    'test "${{ needs.release_publication_checks.result }}" = "skipped"',
    'test "${{ needs.linux_checks.result }}" = "success"',
    'test "${{ needs.dashboard_macos.result }}" = "success"',
    'test "${{ needs.release_publication_checks.result }}" = "success"',
):
    if expected not in required_job:
        raise SystemExit(f"required checks aggregate must enforce event-aware full matrix result: {expected}")

linux_job = workflow.split("  linux_checks:", 1)[1].split("  dashboard_macos:", 1)[0]
dashboard_job = workflow.split("  dashboard_macos:", 1)[1].split("  release_publication_checks:", 1)[0]
release_publication_job = workflow.split("  release_publication_checks:", 1)[1].split("  checks:", 1)[0]
release_condition = "github.event_name == 'workflow_dispatch' || startsWith(github.ref, 'refs/tags/v') || startsWith(github.ref, 'refs/heads/release/')"
for name, job in (("linux_checks", linux_job), ("dashboard_macos", dashboard_job)):
    if release_condition not in job:
        raise SystemExit(f"{name} must be release/manual only")
    if "pull_request" in job:
        raise SystemExit(f"{name} must not add pull_request-specific execution")

if release_condition not in release_publication_job:
    raise SystemExit("release_publication_checks must be release/manual only")
if "always() &&" not in release_publication_job:
    raise SystemExit("release_publication_checks must run after failed release lanes and report fail-closed evidence")
if "permissions:\n      contents: write" not in release_publication_job:
    raise SystemExit("only release_publication_checks may receive contents: write")
for expected in (
    "- pr_fast_checks",
    "- linux_checks",
    "- dashboard_macos",
    "needs.pr_fast_checks.result",
    "needs.linux_checks.result",
    "needs.dashboard_macos.result",
    "github.run_id",
    "github.run_attempt",
    "GITHUB_STEP_SUMMARY",
):
    if expected not in release_publication_job:
        raise SystemExit(f"release_publication_checks must record or require {expected}")
for expected in (
    'test "${{ needs.pr_fast_checks.result }}" = "success"',
    'test "${{ needs.linux_checks.result }}" = "success"',
    'test "${{ needs.dashboard_macos.result }}" = "success"',
):
    if expected not in release_publication_job:
        raise SystemExit(f"release_publication_checks must fail closed on missing/failed matrix result: {expected}")

fast_job = workflow.split("  pr_fast_checks:", 1)[1].split("  linux_checks:", 1)[0]
if "contents: write" in fast_job:
    raise SystemExit("pr_fast_checks must not receive contents: write")
for expected in (
    "git diff --check",
    "bash checks/automation-readiness.sh",
    "bash checks/verify-ci-pr-fast-lane-release-matrix.sh",
):
    if expected not in fast_job:
        raise SystemExit(f"pr_fast_checks must run {expected}")
if "bash checks/run.sh" in fast_job or "swift build --product Dashboard" in fast_job or "DASHBOARD_SMOKE=1 swift run Dashboard" in fast_job:
    raise SystemExit("pr_fast_checks must not run full historical release regression or Dashboard smoke")
if workflow.count("uses: actions/checkout@v4") != workflow.count("persist-credentials: false"):
    raise SystemExit("every checkout in checks.yml must disable persisted credentials")
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

echo "MTPRO CI PR fast lane / release full matrix verification passed."
