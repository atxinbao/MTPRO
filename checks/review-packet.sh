#!/usr/bin/env bash
set -euo pipefail

# 该脚本只生成 PR review packet，不修改仓库、不访问网络、不读取 secret。
BASE_REF="${1:-origin/main}"
ROOT="$(git rev-parse --show-toplevel)"

cd "$ROOT"

fail() {
  printf 'review packet failed: %s\n' "$1" >&2
  exit 1
}

git rev-parse --verify "$BASE_REF" >/dev/null 2>&1 || fail "base ref not found: $BASE_REF"

MERGE_BASE="$(git merge-base "$BASE_REF" HEAD)"
BRANCH="$(git branch --show-current)"
if [[ -z "$BRANCH" ]]; then
  BRANCH="detached:$(git rev-parse --short HEAD)"
fi
STATUS="$(git status --short)"

tmp_files="$(mktemp)"
trap 'rm -f "$tmp_files"' EXIT

{
  git diff --name-only "$MERGE_BASE"...HEAD
  git diff --name-only
  git diff --cached --name-only
} | sort -u > "$tmp_files"

changed_count="$(grep -c . "$tmp_files" || true)"

tier="A"
tier_reason="docs / evidence / review tooling only"

if grep -Eq '^(Sources|Tests|Package\.swift|Package\.resolved|\.github/workflows)/' "$tmp_files"; then
  tier="B"
  tier_reason="implementation, test, package, or workflow files changed"
fi

if grep -Eq '(ExecutionClient|RiskEngine|OMS|Credential|Signed|OrderStatus|BinanceSpotTestnet|ProductionCutover|manual-testnet-validation|release-v0\.16\.0-manual-testnet-validation|\.github/workflows)' "$tmp_files"; then
  tier="C"
  tier_reason="sensitive execution / credential / OMS / risk / workflow path changed"
fi

if grep -Eq '^docs/(contracts|operators|release|audit)/' "$tmp_files"; then
  if [[ "$tier" != "C" ]]; then
    tier="B"
    tier_reason="contracts, operator, release, or audit docs changed"
  fi
fi

codex_paths="no"
if grep -Eq '^(\.codex/|graphify-out/)' "$tmp_files"; then
  codex_paths="yes"
fi

printf '# MTPRO PR Review Packet\n\n'
printf -- '- Base ref: `%s`\n' "$BASE_REF"
printf -- '- Merge base: `%s`\n' "$MERGE_BASE"
printf -- '- Branch: `%s`\n' "$BRANCH"
printf -- '- Changed file count: `%s`\n' "$changed_count"
printf -- '- Suggested review tier: `%s`\n' "$tier"
printf -- '- Tier reason: `%s`\n' "$tier_reason"
printf -- '- `.codex/*` or `graphify-out/*` in diff: `%s`\n' "$codex_paths"
printf '\n'

printf '## Worktree Status\n\n'
if [[ -n "$STATUS" ]]; then
  printf '```text\n%s\n```\n\n' "$STATUS"
else
  printf 'clean\n\n'
fi

printf '## Changed Files\n\n'
if [[ "$changed_count" -eq 0 ]]; then
  printf '_No changed files detected against `%s` or working tree._\n\n' "$BASE_REF"
else
  sed 's/^/- `/' "$tmp_files" | sed 's/$/`/'
  printf '\n'
fi

printf '## Sensitive Boundary Keyword Hits\n\n'
if [[ "$changed_count" -eq 0 ]]; then
  printf '_No files to scan._\n\n'
else
  keyword_hits="$(
    while IFS= read -r file; do
      [[ -f "$file" ]] || continue
      grep -nE 'production cutover|production secret|production endpoint|broker endpoint|signed endpoint|account endpoint|listenKey|LiveExecutionAdapter|real submit|real order|broker action|X-MBX-APIKEY|apiKey|apiSecret|secretKey|/api/v3/order|/api/v3/account|userDataStream|trading button|order form|live command|OMS|RiskEngine|submit / cancel / replace' "$file" \
        | sed "s#^#$file:#" || true
    done < "$tmp_files" | head -80
  )"
  if [[ -n "$keyword_hits" ]]; then
    printf '```text\n%s\n```\n\n' "$keyword_hits"
    printf '说明：命中关键词不等于违规；如果文档是在定义 forbidden / gated capability，reviewer 需要确认语义仍是 blocked / not authorized。\n\n'
  else
    printf '_No sensitive boundary keywords found in changed files._\n\n'
  fi
fi

printf '## Reviewer Checklist\n\n'
case "$tier" in
  A)
    cat <<'EOF'
- Confirm diff is docs / evidence / review tooling only.
- Confirm no production behavior, credential, runtime, transport, OMS, RiskEngine, or workflow dispatch change.
- Confirm fast path does not replace WIP=1, required checks, `bash checks/run.sh`, or Stage Code Audit.
- Confirm `.codex/*` and `graphify-out/*` are absent from the diff.
EOF
    ;;
  B)
    cat <<'EOF'
- Confirm the changed module matches the issue scope.
- Confirm focused fixture / module test / Dashboard smoke is recorded.
- Confirm `bash checks/run.sh` result is recorded before merge.
- Confirm paper / read-model / testnet evidence is not upgraded into production capability.
- Confirm boundary keyword hits are intentional and still gated.
EOF
    ;;
  C)
    cat <<'EOF'
- Run full sensitive review.
- Confirm issue contract, endpoint allowlist, credential policy, redaction, fail-closed behavior, audit trail, and manual/operator evidence.
- Confirm production cutover remains not authorized.
- Confirm production secret, production endpoint, broker endpoint, real order, LiveExecutionAdapter, and production OMS remain blocked unless explicitly authorized by the live queue source.
- Wait for focused verifier, `bash checks/run.sh`, and GitHub required checks.
EOF
    ;;
esac

printf '\n## Suggested Validation\n\n'
printf '```bash\n'
printf 'git diff --check\n'
printf 'bash checks/review-packet.sh %q\n' "$BASE_REF"
printf 'bash checks/run.sh\n'
printf '```\n'
