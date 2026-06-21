#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "release v0.14.0 global kill switch verification failed: $*" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local needle="$2"
  [[ -f "$file" ]] || fail "missing file: $file"
  grep -Fq "$needle" "$file" || fail "$file missing: $needle"
}

require_file_not_contains_regex() {
  local file="$1"
  local pattern="$2"
  [[ -f "$file" ]] || fail "missing file: $file"
  if grep -Eq "$pattern" "$file"; then
    fail "$file contains forbidden pattern: $pattern"
  fi
}

SOURCE="Sources/RiskEngine/LiveGate/ReleaseV0140GlobalKillSwitch.swift"
DOC="docs/contracts/release-v0.14.0-global-kill-switch.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"
RUNNER="checks/run.sh"

for anchor in \
  "GH-1035-GLOBAL-KILL-SWITCH" \
  "GH-1035-SUBMIT-CANCEL-REPLACE-BLOCKED" \
  "GH-1035-AUDIT-EVIDENCE" \
  "TVM-RELEASE-V0140-GLOBAL-KILL-SWITCH"; do
  require_file_contains "$SOURCE" "$anchor"
  require_file_contains "$DOC" "$anchor"
done

for needle in \
  "public struct ReleaseV0140GlobalKillSwitch" \
  "public struct ReleaseV0140GlobalKillSwitchDecision" \
  "public struct ReleaseV0140GlobalKillSwitchEvidence" \
  "requestMappingAllowed == false" \
  "adapterActionAllowed == false" \
  "auditEvidenceEmitted"; do
  require_file_contains "$SOURCE" "$needle"
done

require_file_contains "$TESTS" "testGH1035ReleaseV0140GlobalKillSwitchBlocksSubmitCancelReplaceAndAudits"
require_file_contains "$RUNNER" "bash checks/verify-v0.14.0-global-kill-switch.sh"

for forbidden in \
  "URLSession" \
  "URLRequest" \
  "CryptoKit" \
  "HMAC" \
  "API_KEY" \
  "SECRET" \
  "signature" \
  "listenKey" \
  "api\\.binance\\.com" \
  "fapi\\.binance\\.com" \
  "dapi\\.binance\\.com"; do
  require_file_not_contains_regex "$SOURCE" "$forbidden"
done

swift test --filter TargetGraphTests/testGH1035ReleaseV0140GlobalKillSwitchBlocksSubmitCancelReplaceAndAudits

echo "MTPRO release v0.14.0 global kill switch verification passed."
