#!/usr/bin/env bash
set -euo pipefail

# GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING
# V0151-002-INJECTED-TRANSPORT-NOT-BUILTIN-RUNNER
# V0151-002-MOCK-MANUAL-PROOF-SPLIT
# V0151-002-FUTURE-URLSESSION-RUNNER-DEFERRED
# TVM-RELEASE-V0151-INJECTED-TRANSPORT-WORDING

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.15.1 injected transport wording guard failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

require_file_absent() {
  local file="$1"
  local forbidden="$2"

  if grep -Fq "$forbidden" "$file"; then
    printf 'release v0.15.1 injected transport wording guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    exit 1
  fi
}

reject_unqualified_builtin_runner_claims() {
  local file="$1"

  local matches
  matches="$(grep -En 'v0[.]15[.]0.{0,240}(built-in URLSession runner|builtin URLSession runner|out-of-the-box URLSession runner|CLI default real-network|default real-network execution runner|内置 URLSession|默认真实联网|默认联网执行器)|(built-in URLSession runner|builtin URLSession runner|out-of-the-box URLSession runner|CLI default real-network|default real-network execution runner|内置 URLSession|默认真实联网|默认联网执行器).{0,240}v0[.]15[.]0' "$file" \
    | grep -Evi 'not|does not|do not|不是|不把|不表示|不等于|不得|不能|拒绝|without|must not|不具备|不应' \
    | grep -Fv 'reject_unqualified_builtin_runner_claims' \
    || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.15.1 injected transport wording guard failed: %s contains unqualified built-in runner wording\n' "$file" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
POLICY="docs/release/release-publication-policy.md"
NOTES="docs/release/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-notes.md"
AUDIT="docs/audit/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-stage-code-audit.md"
RUNBOOK="docs/operators/release-v0.15.0-real-binance-testnet-execution-mvp-runbook.md"
READINESS="docs/automation/automation-readiness.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

for anchor in \
  "GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING" \
  "V0151-002-INJECTED-TRANSPORT-NOT-BUILTIN-RUNNER" \
  "V0151-002-MOCK-MANUAL-PROOF-SPLIT" \
  "V0151-002-FUTURE-URLSESSION-RUNNER-DEFERRED" \
  "TVM-RELEASE-V0151-INJECTED-TRANSPORT-WORDING"; do
  require_file_contains "$POLICY" "$anchor"
  require_file_contains "$PLAN" "$anchor"
  require_file_contains "$MATRIX" "$anchor"
  require_file_contains "$READINESS" "$anchor"
  require_file_contains "$LATEST" "$anchor"
  require_file_contains "$TESTS" "$anchor"
done

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$POLICY" "$NOTES" "$AUDIT" "$RUNBOOK" "$READINESS" "$PLAN" "$MATRIX"; do
  require_file_contains "$file" "v0.15.0"
  require_file_contains "$file" "injected Spot Testnet transport"
  require_file_contains "$file" "#1096"
  reject_unqualified_builtin_runner_claims "$file"
done

for file in "$POLICY" "$NOTES" "$AUDIT" "$RUNBOOK" "$READINESS"; do
  require_file_contains "$file" "deterministic mock"
  require_file_contains "$file" "operator manual proof"
  require_file_contains "$file" "concrete URLSession transport"
done

for file in "$PLAN" "$MATRIX"; do
  require_file_contains "$file" "deterministic mock"
  require_file_contains "$file" "operator manual proof"
  require_file_contains "$file" "concrete network transport"
done

require_file_contains "$README" "#1095 closed / done"
require_file_contains "$README" "#1096 已通过 \`GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT\`"
require_file_contains "$README" "#1097 已通过 \`GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME\`"
require_file_contains "$README" "#1099 deterministic client order identity chain closed / done"
require_file_contains "$README" "GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING"
require_file_contains "$GOAL" "#1095 injected transport wording guard is closed / done"
require_file_contains "$BLUEPRINT" "mock/manual proof split"
require_file_contains "$ROADMAP" "future URLSession runner split"
require_file_contains "$LATEST" "v0.15.1 injected transport wording guard"
require_file_contains "$POLICY" "out-of-the-box built-in URLSession runner"
require_file_contains "$NOTES" "CLI 默认具备真实联网执行器"
require_file_contains "$AUDIT" "not a bundled URLSession runner"
require_file_contains "$RUNBOOK" "Any concrete URLSession transport must be implemented and validated by a later issue"
require_file_contains "$READINESS" "Release v0.15.1 injected transport wording guard anchor"
require_file_contains "$PLAN" "GH-1095 Release v0.15.1 Injected Transport / Built-in Runner Wording Guard"
require_file_contains "$MATRIX" "TVM-RELEASE-V0151-INJECTED-TRANSPORT-WORDING"
require_file_contains "checks/automation-readiness.sh" "GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING"
require_file_contains "checks/automation-readiness.sh" "checks/verify-v0.15.1-transport-wording.sh"
require_file_contains "checks/run.sh" "bash checks/verify-v0.15.1-transport-wording.sh"
require_file_contains "$TESTS" "testGH1095ReleaseV0151InjectedTransportWordingRejectsBuiltinRunnerClaims"

for file in "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST"; do
  require_file_absent "$file" "current issue #1094 is release fact sync"
  require_file_absent "$file" "current issue \`#1094\`"
  require_file_absent "$file" "current issue \`#1095\`"
  require_file_absent "$file" "current issue \`#1096\`"
  require_file_absent "$file" "current issue \`#1097\`"
  require_file_absent "$file" "#1095 injected transport wording guard is current WIP=1"
  require_file_absent "$file" "#1095..#1100 remain backlog / non-executable"
done

swift test --filter TargetGraphTests/testGH1095ReleaseV0151InjectedTransportWordingRejectsBuiltinRunnerClaims

echo "MTPRO release v0.15.1 injected transport wording guard verification passed."
