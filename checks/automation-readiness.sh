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
require_file "docs/automation/codex-use-cases-alignment.md"
require_file "docs/automation/graphify-resource-graph-scope.md"
require_file "docs/automation/parent-codex-supervision.md"
require_file "docs/automation/post-issue-ledger.md"
require_file "docs/automation/symphony-issue-workflow-template.md"
require_file "docs/automation/verified-operations.md"
require_file "docs/planning/project-role-map.md"
require_file "docs/validation/eval-strategy.md"
require_file "docs/validation/latest-verification-summary.md"
require_file "docs/validation/macos-build-run-loop.md"
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
require_contains ".github/pull_request_template.md" "Pre-PR Codex Code Review"
require_contains ".github/pull_request_template.md" "Verified Operations"
require_contains ".github/pull_request_template.md" "详细中文注释"
require_contains ".github/pull_request_template.md" 'Required check: `checks`'
require_contains ".github/pull_request_template.md" "Merge method: squash"
require_contains ".github/pull_request_template.md" "WIP=1"

require_contains ".gitignore" ".codex/"
require_contains ".gitignore" "graphify-out/"
require_contains ".graphifyignore" ".codex/"
require_contains ".graphifyignore" "graphify-out/"
require_contains ".graphifyignore" "Sources/"
require_contains ".graphifyignore" "Tests/"

require_contains "docs/automation/automation-readiness.md" "WIP=1"
require_contains "docs/automation/automation-readiness.md" "Linear issue execution contract"
require_contains "docs/automation/automation-readiness.md" "不在文档中固定 current issue"
require_contains "docs/automation/automation-readiness.md" "symphony-issue path"
require_contains "docs/automation/automation-readiness.md" "symphony-issue active Project pointer"
require_contains "docs/automation/automation-readiness.md" "GitHub PR Automation"
require_contains "docs/automation/automation-readiness.md" "Codex use-cases alignment"
require_contains "docs/automation/codex-use-cases-alignment.md" "当前不引入独立 eval 框架"
require_contains "docs/automation/codex-use-cases-alignment.md" "代码中文注释规则"
require_contains "docs/automation/graphify-resource-graph-scope.md" "resource relationship graph"
require_contains "docs/automation/graphify-resource-graph-scope.md" "docs/validation/latest-verification-summary.md"
require_contains "docs/automation/graphify-resource-graph-scope.md" '完整 `verification.md` 默认不进入 Graphify context'
require_contains "docs/automation/graphify-resource-graph-scope.md" "Post-Issue Ledger"
require_contains "docs/automation/parent-codex-supervision.md" "host-side fallback"
require_contains "docs/automation/parent-codex-supervision.md" "Linear issue execution contract"
require_contains "docs/automation/parent-codex-supervision.md" "Linear Project / Issue 格式 Gate"
require_contains "docs/automation/parent-codex-supervision.md" "Project Planning Facilitator"
require_contains "docs/automation/parent-codex-supervision.md" "active Project pointer"
require_contains "docs/automation/parent-codex-supervision.md" "mtpro-runtime-research-workbench-v1-222cf4e1965c"
require_contains "docs/automation/parent-codex-supervision.md" '第一个 issue 和后续 issue 的 `Backlog` -> `Todo` 操作都归属父 Codex'
require_contains "docs/automation/parent-codex-supervision.md" "Human 确认 Project / Issue plan"
require_contains "docs/automation/parent-codex-supervision.md" "Stage Code Audit Report 落仓规则"
require_contains "docs/automation/parent-codex-supervision.md" 'docs/audit/<linear-project-slug>-stage-code-audit.md'
require_contains "docs/automation/parent-codex-supervision.md" "报告必须覆盖整个 Linear Project"
require_contains "docs/automation/parent-codex-supervision.md" "Next Human Project Planning 必须读取该文件后才能开始"
require_contains "docs/automation/post-issue-ledger.md" "before_remove"
require_contains "docs/automation/post-issue-ledger.md" "read_only"
require_contains "docs/automation/symphony-issue-workflow-template.md" "稳定 workflow 本体"
require_contains "docs/automation/symphony-issue-workflow-template.md" "当前 active Project pointer"
require_contains "docs/automation/symphony-issue-workflow-template.md" "mtpro-runtime-research-workbench-v1-222cf4e1965c"
require_contains "docs/automation/symphony-issue-workflow-template.md" "Parent Codex 更新规则"
require_contains "docs/automation/symphony-issue-workflow-template.md" "不为每个新 Project 复制一套 workflow"
require_contains "docs/automation/verified-operations.md" "Authorization Source"
require_contains "docs/automation/verified-operations.md" "Evidence Location"
require_contains "docs/planning/project-role-map.md" "系统架构"
require_contains "docs/planning/project-role-map.md" "Product"
require_contains "docs/planning/project-role-map.md" "Design"
require_contains "docs/planning/project-role-map.md" "Engineering"
require_contains "docs/planning/project-role-map.md" "Finance"
require_contains "docs/planning/project-role-map.md" "Operations"
require_contains "docs/planning/project-role-map.md" "QA"
require_contains "docs/planning/project-role-map.md" "Finance / Trading Domain Analyst"
require_contains "docs/planning/project-role-map.md" "Automation / Runtime Operations Engineer"
require_contains "docs/planning/project-role-map.md" "Project Planning Facilitator"
require_contains "docs/planning/project-role-map.md" "前端设计"
require_contains "docs/planning/project-role-map.md" "后端开发"
require_contains "docs/planning/project-role-map.md" "数据 / 持久化"
require_contains "docs/planning/project-role-map.md" "交易语义"
require_contains "docs/planning/project-role-map.md" "部署与运营"
require_contains "docs/planning/project-role-map.md" "不授权执行"

require_contains "docs/validation/validation-plan.md" "Linear issue execution contract"
require_contains "docs/validation/validation-plan.md" "bash checks/automation-readiness.sh"
require_contains "docs/validation/validation-plan.md" "bash checks/run.sh"
require_contains "docs/validation/validation-plan.md" "Codex / Automation Validation"
require_contains "docs/validation/validation-plan.md" "不引入独立 eval 框架"
require_contains "docs/validation/validation-plan.md" "Finance / Trading Validation"
require_contains "docs/validation/validation-plan.md" "fees / slippage"
require_contains "docs/validation/validation-plan.md" "Backtest / Paper parity"
require_contains "docs/validation/eval-strategy.md" "什么时候可以引入独立 eval 框架"
require_contains "docs/validation/latest-verification-summary.md" "Agent / Graphify 默认读取本文档"
require_contains "docs/validation/latest-verification-summary.md" '完整 `verification.md` 只用于审计、追溯和 debug'
require_contains "docs/validation/latest-verification-summary.md" "bash checks/run.sh"
require_contains "docs/validation/latest-verification-summary.md" "临时 CI 平台边界"
require_contains "docs/validation/latest-verification-summary.md" "覆盖完整 Linear Project"
require_contains "docs/validation/macos-build-run-loop.md" "macOS App shell"

require_contains "docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md" "文档路径"
require_contains "docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md" "命名规则"
require_contains "docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md" "本报告审计完整 Linear Project"
require_contains "docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md" "Known CI Boundary / 临时失败说明"
require_contains "docs/audit/mtpro-runtime-research-workbench-v1-stage-code-audit.md" "无当前遗留 failing PR run"

require_contains "AGENTS.md" "Linear issue 中已填写的 Scope / Non-goals / Codex Instructions / Validation / Boundary / PR Requirements 是 Codex Execution Agent 的执行合同"
require_contains "AGENTS.md" "不二次确认 issue scope"
require_contains "AGENTS.md" "Project Planning Facilitator 只负责阶段规划"
require_contains "AGENTS.md" "active Project pointer"
require_contains "AGENTS.md" '第一个 issue 和后续 issue 的 `Backlog` -> `Todo` 操作都只能由父 Codex'
require_contains "AGENTS.md" "docs/validation/latest-verification-summary.md"
require_contains "AGENTS.md" '完整 `verification.md` 只在审计、追溯或 debug 时读取'
require_contains "AGENTS.md" "详细中文注释"
require_contains "AGENTS.md" "Finance / Trading Domain"
require_contains "AGENTS.md" "Trading validation"
require_contains "docs/planning/linear-draft-plan.md" "已写入 Linear 的 issue 内容是 Codex Execution Agent 的执行合同"
require_contains "docs/planning/linear-draft-plan.md" "不二次确认 issue scope"
require_contains "docs/planning/linear-draft-plan.md" "Project / Issue 格式统一 Gate"
require_contains "docs/planning/linear-draft-plan.md" "Project Planning Facilitator"
require_contains "docs/planning/linear-draft-plan.md" '只有父 Codex 可以操作 `Backlog` -> `Todo`'

require_absent ".github/workflows/checks.yml" "pull_request_target"

printf 'MTPRO automation readiness checks passed.\n'
