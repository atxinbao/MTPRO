#!/usr/bin/env bash
set -euo pipefail

# GH-1549-CLOSE-V0330-DEMO-VALIDATION-AUDIT-RELEASE-NOTES
# TVM-RELEASE-V0330-DEMO-VALIDATION-PRODUCTION-CLOSURE-BLOCKED
# V0330-008-DEMO-VALIDATION-AUDIT-RELEASE-NOTES
# V0330-008-BINANCE-SPOT-USDM-FUTURES-ONLY
# V0330-008-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'verify-v0.33.0-demo-validation failed: %s\n' "$1" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq -- "$expected" "$file" || fail "$file must contain: $expected"
}

swift test --filter ReleaseV0330DemoValidationTests

set +e
cli_output="$(swift run mtpro v0.33-demo-validation-status /tmp/mtpro-v0330-missing-bundle.json 2>&1)"
cli_status=$?
set -e
[[ "$cli_status" -eq 1 ]] || fail "missing bundle CLI must exit 1"
grep -Fq 'demoValidationDecision=blocked' <<<"$cli_output" || fail "missing bundle must be blocked"
grep -Fq 'readModelOnly=true' <<<"$cli_output" || fail "blocked status must remain read-only"

for file in \
  Sources/ExecutionClient/FutureGate/ReleaseV0330DemoValidationEvidenceBundle.swift \
  Sources/MTPROCLI/ReleaseV0330DemoValidationStatusCLI.swift \
  Sources/Dashboard/Report/ReleaseV0330DemoValidationStatusReadModel.swift \
  Tests/TargetGraphTests/ReleaseV0330DemoValidationTests.swift \
  docs/audit/mtpro-release-v0.33.0-demo-validation-stage-code-audit.md \
  docs/release/mtpro-release-v0.33.0-demo-validation-notes.md
do
  require_file "$file"
done

for file in \
  checks/verify-v0.33.0-demo-validation.sh \
  docs/audit/mtpro-release-v0.33.0-demo-validation-stage-code-audit.md \
  docs/release/mtpro-release-v0.33.0-demo-validation-notes.md
do
  require_contains "$file" "GH-1549-CLOSE-V0330-DEMO-VALIDATION-AUDIT-RELEASE-NOTES"
  require_contains "$file" "TVM-RELEASE-V0330-DEMO-VALIDATION-PRODUCTION-CLOSURE-BLOCKED"
  require_contains "$file" "V0330-008-NO-PRODUCTION-CUTOVER"
done

require_contains "docs/audit/mtpro-release-v0.33.0-demo-validation-stage-code-audit.md" "demoValidationDecision=accepted"
require_contains "docs/audit/mtpro-release-v0.33.0-demo-validation-stage-code-audit.md" "backendClosureDecision=blocked"
require_contains "docs/audit/mtpro-release-v0.33.0-demo-validation-stage-code-audit.md" "productionCutoverAuthorized=false"
require_contains "docs/release/mtpro-release-v0.33.0-demo-validation-notes.md" "Binance Spot + USD-M Futures"
require_contains "docs/release/mtpro-release-v0.33.0-demo-validation-notes.md" "production trading remains disabled"

echo "MTPRO v0.33.0 Demo validation verification passed."
