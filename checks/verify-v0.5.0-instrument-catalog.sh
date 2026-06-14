#!/usr/bin/env bash
set -euo pipefail

# GH-729-VERIFY-V050-PRECISION-INSTRUMENT-CATALOG
# TVM-RELEASE-V050-PRECISION-INSTRUMENT-CATALOG

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

require_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'release v0.5.0 instrument catalog verification failed: %s must contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

reject_file_contains() {
  local file="$1"
  local forbidden="$2"

  local matches
  matches="$(grep -F "$forbidden" "$file" | grep -Fv 'reject_file_contains' || true)"

  if [[ -n "$matches" ]]; then
    printf 'release v0.5.0 instrument catalog verification failed: %s must not contain: %s\n' "$file" "$forbidden" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
}

swift test --filter TargetGraphTests/testGH729PrecisionPrimitivesAndInstrumentCatalogAreStrict

require_file_contains \
  "Sources/DomainModel/ReleaseV050PrecisionInstrumentCatalog.swift" \
  "ReleaseV050InstrumentCatalog"
require_file_contains \
  "Sources/DomainModel/ReleaseV050PrecisionInstrumentCatalog.swift" \
  "ReleaseV050FixedPointValue"
require_file_contains \
  "Sources/DomainModel/ProductType.swift" \
  "case \"usdsperpetual\""
require_file_contains \
  "docs/contracts/release-v0.5.0-precision-instrument-catalog-contract.md" \
  "V050-04-PRECISION-PRIMITIVES-INSTRUMENT-CATALOG"
require_file_contains \
  "docs/contracts/release-v0.5.0-precision-instrument-catalog-contract.md" \
  "V050-04-STRICT-PRODUCTTYPE-PARSING"
require_file_contains \
  "docs/contracts/release-v0.5.0-precision-instrument-catalog-contract.md" \
  "TVM-RELEASE-V050-PRECISION-INSTRUMENT-CATALOG"
require_file_contains \
  "checks/run.sh" \
  "bash checks/verify-v0.5.0-instrument-catalog.sh"

reject_file_contains "Sources/DomainModel/ReleaseV050PrecisionInstrumentCatalog.swift" "URLSession"
reject_file_contains "Sources/DomainModel/ReleaseV050PrecisionInstrumentCatalog.swift" "URLRequest"
reject_file_contains "Sources/DomainModel/ReleaseV050PrecisionInstrumentCatalog.swift" "submitOrder"
reject_file_contains "Sources/DomainModel/ReleaseV050PrecisionInstrumentCatalog.swift" "cancelOrder"
reject_file_contains "Sources/DomainModel/ReleaseV050PrecisionInstrumentCatalog.swift" "replaceOrder"
reject_file_contains "Sources/DomainModel/ReleaseV050PrecisionInstrumentCatalog.swift" "HMAC<"

echo "MTPRO release v0.5.0 precision instrument catalog verification passed."
