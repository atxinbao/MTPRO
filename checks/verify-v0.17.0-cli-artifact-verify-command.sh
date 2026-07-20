#!/usr/bin/env bash
set -euo pipefail

# GH-1145-VERIFY-V0170-CLI-ARTIFACT-VERIFY-COMMAND
# TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND
# V0170-007-LOCAL-ARTIFACT-BUNDLE-VERIFY
# V0170-007-LOCAL-ONLY-NO-NETWORK
# V0170-007-DETERMINISTIC-VALIDATION-REPLAY-OUTPUT
# V0170-007-REDACTED-OUTPUT
# V0170-007-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'release v0.17.0 CLI artifact verify command guard failed: %s\n' "$1" >&2
  exit 1
}

require_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F -- "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.17.0 CLI artifact verify command guard failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/FutureGate/ReleaseV0170CLIArtifactVerifyCommand.swift"
CLI="Sources/MTPROCLI/main.swift"
CONTRACT="docs/contracts/release-v0.17.0-cli-artifact-verify-command-contract.md"
README="docs/history/root-docs-pre-canonicalization-2026-07-20/README.md"
GOAL="docs/history/root-docs-pre-canonicalization-2026-07-20/GOAL.md"
BLUEPRINT="docs/history/root-docs-pre-canonicalization-2026-07-20/BLUEPRINT.md"
ROADMAP="docs/history/root-docs-pre-canonicalization-2026-07-20/roadmap.md"
READINESS="docs/automation/automation-readiness.md"
LATEST="docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md"
PLAN="docs/validation/validation-plan.md"
MATRIX="docs/validation/trading-validation-matrix.md"
RUN_SCRIPT="checks/run.sh"
AUTOMATION_SCRIPT="checks/automation-readiness.sh"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

swift test --filter TargetGraphTests/testGH1145ReleaseV0170CLIArtifactVerifyCommand

for file in "$SOURCE" "$CLI" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$READINESS" "$LATEST" "$PLAN" "$MATRIX" "$AUTOMATION_SCRIPT" "$TESTS"; do
  for anchor in \
    "GH-1145-VERIFY-V0170-CLI-ARTIFACT-VERIFY-COMMAND" \
    "TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND" \
    "V0170-007-LOCAL-ARTIFACT-BUNDLE-VERIFY" \
    "V0170-007-LOCAL-ONLY-NO-NETWORK" \
    "V0170-007-DETERMINISTIC-VALIDATION-REPLAY-OUTPUT" \
    "V0170-007-REDACTED-OUTPUT" \
    "V0170-007-NO-PRODUCTION-CUTOVER"; do
    require_file_contains "$file" "$anchor"
  done
done

for required_string in \
  "cliArtifactVerifyCommand=ReleaseV0170CLIArtifactVerifyCommand" \
  "localArtifactBundleVerify=true" \
  "localOnlyNoNetwork=true" \
  "deterministicValidationReplayOutput=true" \
  "redactedOutputOnly=true" \
  "ReleaseV0170CLIArtifactVerifyCommandOutput" \
  "ReleaseV0170OperatorBetaArtifactBundleReplayValidator().validate" \
  "productionTradingEnabledByDefault == false" \
  "productionSecretReadEnabled == false" \
  "productionEndpointConnectionEnabled == false" \
  "productionBrokerConnectionEnabled == false" \
  "productionOrderSubmitCancelReplaceEnabled == false" \
  "productionCutoverAuthorized == false"; do
  require_file_contains "$SOURCE" "$required_string"
done

require_file_contains "$CLI" "ReleaseV0170CLIArtifactVerifyCommand.commandLineOutput"
require_file_contains "$CLI" "verify-operator-beta-artifact-bundle"
require_file_contains "$CONTRACT" "#1145 / GH-1145"
require_file_contains "$CONTRACT" "CLI artifact verify command"
require_file_contains "$CONTRACT" "不授权 production cutover"
require_file_contains "$RUN_SCRIPT" "bash checks/verify-v0.17.0-cli-artifact-verify-command.sh"
require_file_contains "$AUTOMATION_SCRIPT" "checks/verify-v0.17.0-cli-artifact-verify-command.sh"
require_file_contains "$TESTS" "testGH1145ReleaseV0170CLIArtifactVerifyCommand"
require_file_contains "$READINESS" "Release v0.17.0 CLI artifact verify command anchor"
require_file_contains "$LATEST" "v0.17.0 CLI artifact verify command"
require_file_contains "$PLAN" "GH-1145 Release v0.17.0 CLI Artifact Verify Command"
require_file_contains "$MATRIX" "TVM-RELEASE-V0170-CLI-ARTIFACT-VERIFY-COMMAND"

for file in "$SOURCE" "$CLI" "$CONTRACT" "$README" "$GOAL" "$BLUEPRINT" "$ROADMAP" "$LATEST" "$PLAN" "$MATRIX"; do
  reject_file_contains "$file" "productionTradingEnabledByDefault""=true"
  reject_file_contains "$file" "productionCutoverAuthorized""=true"
  reject_file_contains "$file" "productionEndpointConnectionEnabled""=true"
  reject_file_contains "$file" "productionBrokerConnectionEnabled""=true"
  reject_file_contains "$file" "productionOrderSubmitCancelReplaceEnabled""=true"
  reject_file_contains "$file" "API ""Key:"
  reject_file_contains "$file" "Secret ""Key:"
done

printf 'MTPRO release v0.17.0 CLI artifact verify command verification passed.\n'
