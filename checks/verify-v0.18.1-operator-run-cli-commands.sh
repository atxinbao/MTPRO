#!/usr/bin/env bash
set -euo pipefail

# GH-1202-VERIFY-V0181-OPERATOR-RUN-CLI-COMMANDS
# TVM-RELEASE-V0181-OPERATOR-RUN-CLI-COMMANDS
# V0181-003-OPERATOR-RUN-HELP-VISIBLE
# V0181-003-RESUME-CLI-ROUTE
# V0181-003-REPLAY-CLI-ROUTE
# V0181-003-EXPLAIN-FAILURE-CLI-ROUTE
# V0181-003-FAILED-EVIDENCE-READ-ONLY-REPORT-PATH
# V0181-003-LOCAL-ONLY-REDACTED-OUTPUT
# V0181-003-NO-PRODUCTION-CUTOVER

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    printf 'Missing required text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for file in \
  "Sources/ExecutionClient/FutureGate/ReleaseV0181OperatorRunCLICommand.swift" \
  "Sources/MTPROCLI/main.swift" \
  "Tests/TargetGraphTests/TargetGraphTests.swift" \
  "checks/verify-v0.18.1-operator-run-cli-commands.sh" \
  "checks/run.sh" \
  "checks/automation-readiness.sh" \
  "docs/automation/automation-readiness.md" \
  "docs/history/validation-pre-canonicalization-2026-07-20/latest-verification-summary.md" \
  "docs/validation/validation-plan.md" \
  "docs/validation/trading-validation-matrix.md" \
  "docs/release/release-publication-policy.md"; do
  require_contains "$file" "GH-1202-VERIFY-V0181-OPERATOR-RUN-CLI-COMMANDS"
  require_contains "$file" "TVM-RELEASE-V0181-OPERATOR-RUN-CLI-COMMANDS"
  require_contains "$file" "V0181-003-OPERATOR-RUN-HELP-VISIBLE"
  require_contains "$file" "V0181-003-RESUME-CLI-ROUTE"
  require_contains "$file" "V0181-003-REPLAY-CLI-ROUTE"
  require_contains "$file" "V0181-003-EXPLAIN-FAILURE-CLI-ROUTE"
  require_contains "$file" "V0181-003-FAILED-EVIDENCE-READ-ONLY-REPORT-PATH"
  require_contains "$file" "V0181-003-LOCAL-ONLY-REDACTED-OUTPUT"
  require_contains "$file" "V0181-003-NO-PRODUCTION-CUTOVER"
done

require_contains "Sources/MTPROCLI/main.swift" "ReleaseV0181OperatorRunCLICommand.commandLineOutput"
require_contains "Sources/MTPROCLI/main.swift" "operatorRunActions="
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0181OperatorRunCLICommand.swift" "ReleaseV0180ResumeAfterInterruptionResult"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0181OperatorRunCLICommand.swift" "ReleaseV0180CancelStatusReconciliationReplayResult"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0181OperatorRunCLICommand.swift" "ReleaseV0180OperatorFailureClassificationNextActionResult"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0181OperatorRunCLICommand.swift" "readOnlyReportPathClassified=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0181OperatorRunCLICommand.swift" "failedEvidenceNonzeroOrReadOnlyReportPath=true"
require_contains "Sources/ExecutionClient/FutureGate/ReleaseV0181OperatorRunCLICommand.swift" "productionCutoverAuthorized=false"
require_contains "docs/automation/automation-readiness.md" "Release v0.18.1 operator-run CLI commands anchor"
require_contains "docs/validation/validation-plan.md" "GH-1202 Release v0.18.1 Operator-run CLI Commands"
require_contains "docs/validation/trading-validation-matrix.md" "TVM-RELEASE-V0181-OPERATOR-RUN-CLI-COMMANDS"
require_contains "docs/release/release-publication-policy.md" "GH-1202 wires operator-run CLI commands"
require_contains "checks/run.sh" "bash checks/verify-v0.18.1-operator-run-cli-commands.sh"
require_contains "checks/automation-readiness.sh" "checks/verify-v0.18.1-operator-run-cli-commands.sh"

swift test --filter TargetGraphTests/testGH1202OperatorRunCLICommandsAreHelpVisibleAndFailClosed

HELP_OUTPUT="$(swift run mtpro help)"
RESUME_OUTPUT="$(swift run mtpro operator-run resume --run-id gh-1202-operator-run-alpha --venue binance --product spot --environment testnet --account-profile operator-beta)"
REPLAY_OUTPUT="$(swift run mtpro operator-run replay --run-id gh-1202-operator-run-alpha --venue binance --product spot --environment testnet --account-profile operator-beta)"
EXPLAIN_OUTPUT="$(swift run mtpro operator-run explain-failure --run-id gh-1202-operator-run-alpha --venue binance --product spot --environment testnet --account-profile operator-beta --stage resume --reason resumeEvidenceMissingOrInvalid --next-action manualReview)"

for needle in \
  "operator-run" \
  "operatorRunFailedEvidenceNonzeroOrReadOnlyReportPath=true"; do
  if [[ "$HELP_OUTPUT" != *"$needle"* ]]; then
    printf 'MTPRO CLI help missing expected operator-run text: %s\n' "$needle" >&2
    exit 1
  fi
done

for output in "$RESUME_OUTPUT" "$REPLAY_OUTPUT" "$EXPLAIN_OUTPUT"; do
  for needle in \
    "issue=GH-1202" \
    "status=failed" \
    "readOnlyReportPathClassified=true" \
    "failedEvidenceNonzeroOrReadOnlyReportPath=true" \
    "localOnlyRedactedOutput=true" \
    "productionTradingEnabledByDefault=false" \
    "productionSecretReadEnabled=false" \
    "productionEndpointConnectionEnabled=false" \
    "productionBrokerConnectionEnabled=false" \
    "productionOrderSubmitCancelReplaceEnabled=false" \
    "productionCutoverAuthorized=false"; do
    if [[ "$output" != *"$needle"* ]]; then
      printf 'MTPRO operator-run output missing expected text: %s\n' "$needle" >&2
      exit 1
    fi
  done
done

printf 'MTPRO v0.18.1 operator-run CLI commands verification passed.\n'
