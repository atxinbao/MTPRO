#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

fail() {
  printf 'automation readiness check failed: %s\n' "$1" >&2
  exit 1
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] || fail "missing required file: $file"
}

require_contains() {
  local file="$1"
  local expected="$2"
  grep -Fq "$expected" "$file" || fail "$file must contain: $expected"
}

require_absent() {
  local file="$1"
  local forbidden="$2"
  if grep -Fq "$forbidden" "$file"; then
    fail "$file must not contain: $forbidden"
  fi
}

require_file ".github/workflows/checks.yml"
require_file ".github/pull_request_template.md"
require_file ".gitignore"
require_file ".graphifyignore"
require_file "docs/automation/automation-readiness.md"
require_file "docs/automation/graphify-resource-graph-scope.md"
require_file "docs/automation/parent-codex-supervision.md"
require_file "docs/automation/post-issue-ledger.md"
require_file "docs/validation/validation-plan.md"
require_file "verification.md"

require_contains ".github/workflows/checks.yml" "name: checks"
require_contains ".github/workflows/checks.yml" "bash checks/run.sh"

require_contains ".github/pull_request_template.md" "Linked Linear Issue"
require_contains ".github/pull_request_template.md" "Graphify 上下文和更新状态"
require_contains ".github/pull_request_template.md" "symphony-issue Handoff"
require_contains ".github/pull_request_template.md" ".codex/symphony-issue-handoff.json"
require_contains ".github/pull_request_template.md" "ready_for_review: true"
require_contains ".github/pull_request_template.md" "auto_merge_enabled: true"
require_contains ".github/pull_request_template.md" "Parent Codex Automation Supervision"
require_contains ".github/pull_request_template.md" "Post-Issue Ledger / 施工后记账"
require_contains ".github/pull_request_template.md" "GitHub PR Automation 门槛"
require_contains ".github/pull_request_template.md" 'Required check: `checks`'
require_contains ".github/pull_request_template.md" "Merge method: squash"
require_contains ".github/pull_request_template.md" "WIP=1"

require_contains ".gitignore" ".codex/"
require_contains ".gitignore" "graphify-out/"
require_contains ".graphifyignore" ".codex/"
require_contains ".graphifyignore" "graphify-out/"
require_contains ".graphifyignore" "Sources/"
require_contains ".graphifyignore" "Tests/"

require_contains "docs/automation/automation-readiness.md" "MTP-15"
require_contains "docs/automation/automation-readiness.md" "WIP=1"
require_contains "docs/automation/automation-readiness.md" "symphony-issue handoff marker"
require_contains "docs/automation/automation-readiness.md" "GitHub PR Automation"
require_contains "docs/automation/graphify-resource-graph-scope.md" "resource relationship graph"
require_contains "docs/automation/graphify-resource-graph-scope.md" "Post-Issue Ledger"
require_contains "docs/automation/parent-codex-supervision.md" "host-side fallback"
require_contains "docs/automation/parent-codex-supervision.md" "Human 明确授权"
require_contains "docs/automation/post-issue-ledger.md" "before_remove"
require_contains "docs/automation/post-issue-ledger.md" "read_only"

require_contains "docs/validation/validation-plan.md" "MTP-15 验证矩阵"
require_contains "docs/validation/validation-plan.md" "bash checks/automation-readiness.sh"
require_contains "docs/validation/validation-plan.md" "bash checks/run.sh"

require_absent ".github/workflows/checks.yml" "pull_request_target"

printf 'MTPRO automation readiness checks passed.\n'
