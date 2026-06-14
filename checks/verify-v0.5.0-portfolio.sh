#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

echo "GH-736-VERIFY-V050-PORTFOLIO-RUN-JOURNAL-PROJECTION"

required_files=(
  "Sources/Portfolio/ReleaseV050PortfolioRunJournalProjection.swift"
  "docs/contracts/release-v0.5.0-portfolio-run-journal-projection-contract.md"
  "docs/validation/validation-plan.md"
  "docs/validation/trading-validation-matrix.md"
  "docs/automation/automation-readiness.md"
  "Tests/TargetGraphTests/TargetGraphTests.swift"
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || {
    echo "missing required GH-736 file: $file" >&2
    exit 1
  }
done

required_anchors=(
  "V050-11-PORTFOLIO-RUN-JOURNAL-PROJECTION"
  "V050-11-JOURNAL-REPLAY-DERIVED-POSITION-EXPOSURE"
  "V050-11-PNL-MARGIN-LIKE-REHEARSAL-METRICS"
  "V050-11-INSTRUMENT-CATALOG-PRECISION-SOURCE"
  "V050-11-NO-BROKER-ACCOUNT-PAYLOAD"
  "TVM-RELEASE-V050-PORTFOLIO-RUN-JOURNAL-PROJECTION"
)

for anchor in "${required_anchors[@]}"; do
  grep -R -Fq "$anchor" \
    Sources/Portfolio/ReleaseV050PortfolioRunJournalProjection.swift \
    docs/contracts/release-v0.5.0-portfolio-run-journal-projection-contract.md \
    docs/validation/validation-plan.md \
    docs/validation/trading-validation-matrix.md \
    checks/automation-readiness.sh || {
      echo "missing GH-736 anchor: $anchor" >&2
      exit 1
    }
done

grep -Fq "ReleaseV050PortfolioRunJournalProjection" Sources/Portfolio/ReleaseV050PortfolioRunJournalProjection.swift
grep -Fq "ReleaseV050DurableLocalRunJournal" Sources/Portfolio/ReleaseV050PortfolioRunJournalProjection.swift
grep -Fq "ReleaseV050InstrumentCatalog" Sources/Portfolio/ReleaseV050PortfolioRunJournalProjection.swift
grep -Fq "PortfolioProjectionEvent" Sources/MessageBus/RuntimeMessageBus.swift
grep -Fq "testGH736PortfolioProjectionDerivesReadModelFromRunJournalAndOMSDryRunEvidence" Tests/TargetGraphTests/TargetGraphTests.swift

for forbidden in "URLSession" "URLRequest" "api.binance.com" "fapi.binance.com" "submitOrder" "cancelOrder" "replaceOrder" "HMAC<"; do
  if grep -Fq "$forbidden" Sources/Portfolio/ReleaseV050PortfolioRunJournalProjection.swift; then
    echo "GH-736 Portfolio projection must not contain forbidden runtime token: $forbidden" >&2
    exit 1
  fi
done

swift test --filter TargetGraphTests/testGH736PortfolioProjectionDerivesReadModelFromRunJournalAndOMSDryRunEvidence

echo "TVM-RELEASE-V050-PORTFOLIO-RUN-JOURNAL-PROJECTION verified"
