#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_contains "checks/automation-readiness.sh" 'bash "$ROOT/checks/automation-readiness.d/run-domain-guards.sh"'
require_contains "checks/run.sh" "bash checks/automation-readiness.sh"
require_contains "checks/automation-readiness.d/run-domain-guards.sh" '"l4-boundary"'
require_contains "checks/automation-readiness.d/run-domain-guards.sh" '"target-graph"'
require_contains "checks/automation-readiness.d/run-domain-guards.sh" '"dashboard-read-model"'
require_contains "checks/automation-readiness.d/run-domain-guards.sh" '"forbidden-capability"'
require_contains "checks/automation-readiness.d/run-domain-guards.sh" '"docs-closure"'
require_contains "docs/automation/automation-readiness.md" "GH-498-AUTOMATION-READINESS-DOMAIN-GUARD-SPLIT"
