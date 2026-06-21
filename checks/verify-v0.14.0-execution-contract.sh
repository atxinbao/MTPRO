#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "verify-v0.14.0-execution-contract failed: $file must contain: $expected" >&2
    exit 1
  fi
}

SOURCE="Sources/ExecutionClient/ExecutionContract/ExecutionContractInterface.swift"
DOC="docs/contracts/release-v0.14.0-execution-contract-interface.md"
TESTS="Tests/TargetGraphTests/TargetGraphTests.swift"

require_file_contains "$SOURCE" "public protocol ExecutionContractAdapter"
require_file_contains "$SOURCE" "public struct ExecutionContractRequestMapping"
require_file_contains "$SOURCE" "public struct ExecutionContractSubmissionResult"
require_file_contains "$SOURCE" "public struct ExecutionContractAcknowledgement"
require_file_contains "$SOURCE" "public struct ExecutionContractRejection"
require_file_contains "$SOURCE" "public struct ExecutionContractCancel"
require_file_contains "$SOURCE" "public struct ExecutionContractReplace"
require_file_contains "$SOURCE" "public struct ExecutionContractAuditEvidence"
require_file_contains "$SOURCE" "productionAdapterImplementationPresent: Bool = false"
require_file_contains "$SOURCE" "GH-1027-EXECUTION-CONTRACT-INTERFACE"
require_file_contains "Package.swift" "\"ExecutionContract\""
require_file_contains "$DOC" "GH-1027-EXECUTION-CONTRACT-INTERFACE"
require_file_contains "$DOC" "GH-1027-EXECUTION-CONTRACT-STAGE-SEPARATION"
require_file_contains "$DOC" "GH-1027-EXECUTION-CONTRACT-NO-PRODUCTION-ADAPTER"
require_file_contains "$TESTS" "testGH1027ReleaseV0140ExecutionContractInterfaceSeparatesAdapterStages"
require_file_contains "checks/run.sh" "bash checks/verify-v0.14.0-execution-contract.sh"

if grep -Fq "ProductionExecutionContractAdapter" "$SOURCE"; then
  echo "verify-v0.14.0-execution-contract failed: production adapter implementation must remain absent" >&2
  exit 1
fi

swift test --filter TargetGraphTests/testGH1027ReleaseV0140ExecutionContractInterfaceSeparatesAdapterStages

echo "MTPRO release v0.14.0 ExecutionContract interface verification passed."
