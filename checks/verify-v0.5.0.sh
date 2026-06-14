#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

# GH-739-VERIFY-V050-FINAL-AUDIT-RELEASE-DOCS
# TVM-RELEASE-V050-FINAL-AUDIT-RELEASE-DOCS
# This aggregate command is the release v0.5.0 local verification entrance.
# It only composes deterministic local guards and read-only observer smoke.
# It does not read secrets, connect endpoints, connect brokers, submit orders,
# publish tags, create issues, or authorize production cutover.
bash checks/verify-v0.5.0-preflight.sh
bash checks/verify-v0.5.0-cli.sh
bash checks/verify-v0.5.0-environment.sh
bash checks/verify-v0.5.0-instrument-catalog.sh
bash checks/verify-v0.5.0-messagebus.sh
bash checks/verify-v0.5.0-run-journal.sh
bash checks/verify-v0.5.0-dataengine.sh
bash checks/verify-v0.5.0-testnet-readonly.sh
bash checks/verify-v0.5.0-riskengine.sh
bash checks/verify-v0.5.0-oms.sh
bash checks/verify-v0.5.0-portfolio.sh
bash checks/verify-v0.5.0-observer.sh
bash checks/verify-v0.5.0-ci-hardening.sh

swift run mtpro run-observer status >/dev/null

echo "MTPRO release v0.5.0 guarded testnet runtime foundation verification passed."
