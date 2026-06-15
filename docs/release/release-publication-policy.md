# Release Publication Policy

日期：2026-06-15

执行者：Codex

本文档服务 GitHub fallback issue `GH-808 V080-002 Align v0.7.0/v0.8.0 release publication docs and policy`。

## GH-808-RELEASE-PUBLICATION-POLICY

`GH-808-RELEASE-PUBLICATION-POLICY`

MTPRO release line 必须区分两类 gate：

- construction closeout gate：收口 issue queue、Stage Code Audit、root docs / release docs / runbook、validation command 和 no-default-production-trading evidence。
- public release publication gate：在 construction closeout 完成后，单独确认 tag、GitHub Release、release notes、target commit、source checksum expectation 和 publication boundary。

construction closeout 不等于 public release publication。public release publication 也不等于 production cutover。

## V080-002-V070-ACTUAL-GITHUB-RELEASE

`V080-002-V070-ACTUAL-GITHUB-RELEASE`

v0.7.0 当前存在 stable GitHub Release：

- release tag：`v0.7.0`
- release title：`MTPRO v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.7.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`79bd7309b5d644599b6879e615489562455cd3fe`
- publication timestamp：`2026-06-15T13:36:43Z`

v0.7.0 的 Stage Code Audit、release notes 和 root docs refresh 是 construction closeout evidence；后续 GitHub Release publication 是独立发布动作。文档不得再把 v0.7.0 描述成没有 GitHub Release。

## V080-002-V080-CONSTRUCTION-VS-PUBLICATION

`V080-002-V080-CONSTRUCTION-VS-PUBLICATION`

v0.8.0 当前处于 GitHub fallback queue construction phase。`GH-807..GH-820` 可以逐步完成 persistent local operator runtime、testnet read-only monitoring、manual proof summary、Dashboard read-only monitor、safe local controls、validation split 和 final audit / docs / runbook。

v0.8.0 的 construction closeout 必须先满足：

- `GH-807..GH-820` 全部 closed / done。
- open PR = 0。
- open `todo` / `in-progress` / `in-review` issue = 0。
- `main == origin/main`。
- worktree clean。
- `git diff --check` 通过。
- `bash checks/automation-readiness.sh` 通过。
- `bash checks/run.sh` 通过。

v0.8.0 public release publication 只能在单独 release publication task 明确授权后执行。`GH-808` 不创建 tag，不创建 GitHub Release，不移动任何已有 tag，不把 v0.8.0 标记为 completed，不推进 v0.8.0 之后的阶段。

## V080-002-TAG-NAMING-RULES

`V080-002-TAG-NAMING-RULES`

Release tag 命名规则：

- 正式 release 使用 `vMAJOR.MINOR.PATCH`，例如 `v0.7.0`、`v0.8.0`。
- patch hardening release 使用递增 patch 号，例如 `v0.7.1`。
- tag 必须指向已验证、已同步的 `main` commit。
- tag 必须在 release publication gate 中创建；construction closeout issue 不创建 tag。
- 已存在 tag 不得移动、覆盖或重写；若 tag / release 已存在，只能只读核对并报告。

## V080-002-GITHUB-RELEASE-CHECKLIST

`V080-002-GITHUB-RELEASE-CHECKLIST`

GitHub Release publication checklist：

1. 确认 release target commit 等于 `main` 和 `origin/main`。
2. 确认 worktree clean。
3. 确认 open PR = 0。
4. 确认 open issue = 0，或确认 release task 明确允许的非阻塞 issue。
5. 确认没有 `todo` / `in-progress` / `in-review` label 的 active queue item。
6. 确认 required validation 已通过：`git diff --check`、`bash checks/automation-readiness.sh`、`bash checks/run.sh`。
7. 确认 tag / GitHub Release 尚不存在；若已存在，不移动、不覆盖、不重写。
8. 创建 annotated git tag。
9. push tag。
10. 创建 stable GitHub Release，非 draft，非 prerelease。
11. 发布后复核 release URL、tag target、open PR、open issue 和 clean worktree。

## V080-002-SOURCE-CHECKSUM-EXPECTATIONS

`V080-002-SOURCE-CHECKSUM-EXPECTATIONS`

Source checksum expectation 必须绑定 exact tag，不绑定 mutable branch：

```bash
git fetch --tags origin
git rev-parse v0.8.0^{}
git archive --format=tar --prefix=MTPRO-v0.8.0/ v0.8.0 | shasum -a 256
```

若 release notes 记录 source checksum，必须同时记录 tag、peeled commit、checksum algorithm、checksum command 和执行日期。checksum 只证明 source archive identity，不授权 production trading、production secret read、production endpoint / broker connection 或 real order。

## V080-002-RELEASE-NOTES-PUBLISHING-GATE

`V080-002-RELEASE-NOTES-PUBLISHING-GATE`

Release notes publishing gate 必须覆盖：

- release scope。
- completed issue / PR / checks evidence summary。
- validation summary。
- source checksum expectation 或 actual checksum。
- known residual risk。
- no-default-production-trading boundary。
- production cutover remains separately gated。
- no production secret auto-read。
- no production endpoint / broker auto-connect。
- no testnet or production submit / cancel / replace unless a later issue explicitly authorizes it.
- no next Project / Issue auto-promotion。

## TVM-RELEASE-V080-RELEASE-PUBLICATION-POLICY

`TVM-RELEASE-V080-RELEASE-PUBLICATION-POLICY`

Required validation：

- `bash checks/verify-v0.8.0-release-publication-policy.sh`
- `swift test --filter TargetGraphTests/testGH808ReleasePublicationPolicySeparatesConstructionCloseoutFromGitHubRelease`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

- productionTradingEnabledByDefault=false
- productionSecretRead=false
- productionEndpointConnected=false
- productionBrokerConnected=false
- productionOrderSubmitted=false
- productionCutoverAuthorized=false
- testnetOrderSubmissionAllowed=false
- testnetOrderRoutingAllowed=false

GH-808 不发布 v0.8.0，不创建下一 Project / Issue，不推进下一 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不修改 production capability，不读取 secret，不连接 endpoint，不提交订单。
