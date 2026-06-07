#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_file "docs/audit/mtpro-l4-live-production-trading-commands-v1-stage-code-audit.md"
require_file "docs/audit/mtpro-core-envelope-retirement-real-module-ownership-completion-v1-stage-code-audit.md"
require_contains "docs/automation/automation-readiness.md" "L4 Live Production / Trading Commands Stage Code Audit Report anchor"
require_contains "docs/automation/automation-readiness.md" "Core Envelope Retirement / Real Module Ownership Completion Stage Code Audit Report anchor"
require_contains "docs/validation/latest-verification-summary.md" "GH-413 Core envelope retirement contract"
require_contains "docs/validation/latest-verification-summary.md" "GH-422 Core envelope retirement matrix / L4 readiness closeout"
require_contains "verification.md" "GH-413 Core envelope retirement contract"
require_contains "verification.md" "GH-422 Core envelope retirement matrix / L4 readiness closeout"
require_absent "docs/validation/validation-plan.md" 'Root docs 必须使用 `Trader = Accounts + Strategies + StrategyBindings + Coordination`'
require_absent "docs/validation/validation-plan.md" '`Sources/Trader/StrategyBindings/` 必须包含 proposal-to-risk binding'
require_absent "docs/validation/validation-plan.md" '只使用 `"Trader/Strategies/EMA"` 和 `"Trader/StrategyBindings"`'
require_absent "docs/validation/validation-plan.md" "Validation 必须覆盖 StrategyBindings as non-concrete-strategy landing area"
