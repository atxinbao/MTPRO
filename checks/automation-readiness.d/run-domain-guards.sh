#!/usr/bin/env bash
set -euo pipefail

DOMAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

domain_scripts=(
  "entrypoint-contract"
  "l4-boundary"
  "target-graph"
  "dashboard-read-model"
  "forbidden-capability"
  "docs-closure"
  "release-v010-no-default-production-trading"
  "release-v0.2.0-boundary"
)

for domain in "${domain_scripts[@]}"; do
  bash "$DOMAIN_DIR/$domain.sh"
done
