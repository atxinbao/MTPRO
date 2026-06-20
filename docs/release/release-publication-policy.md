# Release Publication Policy

日期：2026-06-16

执行者：Codex

本文档服务 GitHub fallback issue `GH-808 V080-002 Align v0.7.0/v0.8.0 release publication docs and policy`。

后续维护记录：

- `GH-879 V0100-002 Align v0.9.1 / v0.10.0 release publication docs and version policy`
- `v0.11.0 Release Publication Gate fact sync`
- `GH-953 V0120-002 Align v0.11.x release publication and patch facts`
- `v0.12.0 Release Publication Gate fact sync`
- `GH-993 V0121-006 Close v0.12.1 patch audit and release notes`

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

## GH-835-V081-V080-ACTUAL-GITHUB-RELEASE

`GH-835-V081-V080-ACTUAL-GITHUB-RELEASE`

v0.8.0 当前存在 stable GitHub Release：

- release tag：`v0.8.0`
- release title：`MTPRO v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`d83b3b564096a5427db15a437921fc797b22564d`
- publication timestamp：`2026-06-16T11:56:09Z`

v0.8.0 的 Stage Code Audit、release notes 和 root docs refresh 是 construction closeout evidence；后续 GitHub Release publication 已通过独立 stable GitHub Release gate 完成。文档不得再把 v0.8.0 描述成 publication pending，也不得把 GitHub Release publication 当作 production cutover authorization。

## V090-ACTUAL-GITHUB-RELEASE

`V090-ACTUAL-GITHUB-RELEASE`

v0.9.0 当前存在 stable GitHub Release：

- release tag：`v0.9.0`
- release title：`MTPRO v0.9.0 Testnet No-order Observability`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`4296bf73673fe0fd8f09e34c40ef2a3a9ba7e55c`
- publication timestamp：`2026-06-17T17:09:19Z`

v0.9.0 的 Stage Code Audit、release notes、operator runbook 和 root docs refresh 是 construction closeout evidence；后续 GitHub Release publication 已通过独立 stable GitHub Release gate 完成。文档不得再把 v0.9.0 描述成 publication pending，也不得把 GitHub Release publication 当作 production cutover authorization。

## GH-879-V0100-V091-ACTUAL-GITHUB-RELEASE

`GH-879-V0100-V091-ACTUAL-GITHUB-RELEASE`

`GH-879-VERIFY-V0100-V091-PUBLICATION-POLICY`

`V0100-002-V091-PUBLICATION-FACT`

`TVM-RELEASE-V0100-V091-PUBLICATION-POLICY`

v0.9.1 当前存在 stable GitHub Release：

- release tag：`v0.9.1`
- release title：`MTPRO v0.9.1 Audit Hardening Patch`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`d041f0dd304075562a85e494695697290972288f`
- publication timestamp：`2026-06-17T19:45:42Z`

v0.9.1 的 Stage Code Audit 和 release notes 是 audit hardening patch closeout evidence；后续 GitHub Release publication 已通过独立 stable GitHub Release gate 完成。文档不得再把 v0.9.1 描述成 tagless patch、没有 tag 或没有 GitHub Release，也不得把 GitHub Release publication 当作 production cutover authorization。

## V0100-002-V0100-RELEASE-POLICY-ANCHOR

`V0100-002-V0100-RELEASE-POLICY-ANCHOR`

v0.10.0 使用 `MTPRO Release v0.10.0 Production Cutover Readiness Gate` 作为 release construction queue。该 queue 只能评估 production cutover readiness，不授权 production cutover。

v0.10.0 release fact flow 在 v0.10.1 patch 中固定为四段 gate：

1. construction closeout gate（也称 construction / readiness closeout gate）：收口 GitHub fallback queue `GH-878..GH-891`、Stage Code Audit、release docs、runbook、validation command 和 no-default-production-trading evidence。
2. release publication gate：只有在 construction closeout 完成后，才能通过显式发布指令创建或核对 tag / GitHub Release。
3. release fact sync gate：publication 完成后同步 root docs、release docs、validation summary、automation readiness 和 audit / runbook 里的已发生事实。
4. stale wording guard gate：通过 `GH-907-VERIFY-V0101-RELEASE-FACT-STALE-WORDING-GUARD` / `V0101-002-RELEASE-FACT-SYNC-GUARD` / `V0101-002-FOUR-GATE-RELEASE-FLOW` / `TVM-RELEASE-V0101-RELEASE-FACT-SYNC-GUARD` 阻止 v0.10.0 文档保留过期 publication wording。

Production cutover remains a separate non-release gate；production cutover gate 保持独立，不能由 construction closeout、release publication、release fact sync 或 stale wording guard 自动触发。

v0.10.0 当前存在 stable GitHub Release：

- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`
- tag target commit：`7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`
- release title：`MTPRO v0.10.0 Production Cutover Readiness Gate`
- publication timestamp：`2026-06-18T05:19:46Z`
- release type：stable；非 draft；非 prerelease

v0.10.0 的 construction / readiness closeout 已通过 `GH-878..GH-891` 完成，public GitHub Release publication 已通过独立 gate 完成。文档不得再保留与当前 publication fact 冲突的旧 wording；也不得把 GitHub Release publication 当作 production cutover authorization。

v0.10.0 readiness evidence 允许记录 approval workflow、manual confirmation checklist、operator runbook、Dashboard readiness center 和 audit bundle；这些 evidence 仍不授权 production trading，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order。

## V0110-ACTUAL-GITHUB-RELEASE

`V0110-ACTUAL-GITHUB-RELEASE`

`GH-945-VERIFY-V0111-RELEASE-FACT-STALE-WORDING-GUARD`

`V0111-001-RELEASE-FACT-SYNC-GUARD`

`V0111-001-FOUR-GATE-RELEASE-FLOW`

`TVM-RELEASE-V0111-RELEASE-FACT-SYNC-GUARD`

v0.11.0 使用 `MTPRO Release v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening` 作为 release construction queue。#924 construction closeout 本身只收口 Stage Code Audit、release notes、root docs refresh、aggregate verifier guard 和 focused closeout test；它不创建 tag，也不发布 GitHub Release。

v0.11.0 当前存在 public GitHub Release：

- release tag：`v0.11.0`
- release title：`MTPRO v0.11.0 Production Readiness Evidence Runtime + Integrity Hardening`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`13f592d0710de91351286e5c5490bfacb63c19b0`
- publication timestamp：`2026-06-19T01:20:58Z`

v0.11.0 的 construction closeout、Release Publication Gate、release fact sync / stale wording guard 和 production cutover 仍是独立 gate。已发布事实不授权 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送真实订单，不创建下一 Project / Issue，也不推进 v0.12.0。

GH-945 / v0.11.1 stale wording guard 固定该 release fact：所有未限定为 #924 历史 closeout 的 v0.11.0 文档不得继续描述为 publication pending、tag pending、release not created、没有 GitHub Release、未创建 release 或待发布。

## V0120-ACTUAL-GITHUB-RELEASE

`V0120-ACTUAL-GITHUB-RELEASE`

`GH-988-VERIFY-V0121-RELEASE-FACT-STALE-WORDING-GUARD`

`V0121-001-RELEASE-FACT-SYNC-GUARD`

`V0121-001-FOUR-GATE-RELEASE-FLOW`

`TVM-RELEASE-V0121-RELEASE-FACT-SYNC-GUARD`

v0.12.0 使用 `MTPRO Release v0.12.0 Readiness Assessment Sessions` 作为 release construction queue。#965 construction closeout 本身只收口 Stage Code Audit、release notes、operator runbook、root docs refresh、aggregate verifier guard 和 focused closeout test；它不授权 production cutover。

v0.12.0 当前存在 public GitHub Release：

- release tag：`v0.12.0`
- release title：`MTPRO v0.12.0 Readiness Assessment Sessions`
- release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`
- release type：stable release；非 draft；非 prerelease
- tag peeled commit：`25e31afd351db9a372db62222226b0a3db26c93a`
- publication timestamp：`2026-06-20T01:11:22Z`

v0.12.0 的 construction closeout、Release Publication Gate、release fact sync / stale wording guard 和 production cutover 仍是独立 gate。已发布事实不授权 production trading，不读取 production secret，不连接 production endpoint / broker endpoint，不发送真实订单，不创建下一 Project / Issue，也不推进 v0.13.0。

GH-988 / v0.12.1 stale wording guard 固定该 release fact：所有未限定为 #965 历史 closeout 的 v0.12.0 文档不得继续描述为 publication pending、tag pending、release not created、no public tag、no GitHub Release、未创建 release 或待发布。

## V0121-006-PATCH-AUDIT-RELEASE-NOTES

`GH-993-VERIFY-V0121-PATCH-AUDIT-RELEASE-NOTES`

`TVM-RELEASE-V0121-PATCH-AUDIT-RELEASE-NOTES`

`V0121-006-PATCH-AUDIT`

`V0121-006-RELEASE-NOTES`

`V0121-006-VALIDATION-SUMMARY`

`V0121-006-NO-PRODUCTION-CUTOVER`

`V0121-006-NO-TAG-OR-RELEASE-MOVE`

v0.12.1 Readiness Assessment Provenance Hardening Patch 是 v0.12.0 public Release 后的 provenance hardening closeout。它只收口 #988..#993 的 release fact sync、source commit provenance、local evidence metadata、compare fail-closed behavior、generated JSON inspection、Stage Code Audit、release notes 和 root-doc patch facts。

GH-993 is not a release publication gate:

- 不创建 `v0.12.1` tag。
- 不创建 `v0.12.1` GitHub Release。
- 不移动、不覆盖、不重写 `v0.12.0` tag 或 GitHub Release。
- 不推进 v0.13.0。
- 不授权 production cutover。

v0.12.0 public GitHub Release 仍保持为 `https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`，tag peeled commit `25e31afd351db9a372db62222226b0a3db26c93a`，publication timestamp `2026-06-20T01:11:22Z`。v0.12.1 patch closeout 不改变该 release identity。

## V0111-007-PATCH-AUDIT-RELEASE-NOTES

`GH-951-VERIFY-V0111-PATCH-AUDIT-RELEASE-NOTES`

`TVM-RELEASE-V0111-PATCH-AUDIT-RELEASE-NOTES`

`V0111-007-PATCH-AUDIT`

`V0111-007-RELEASE-NOTES`

`V0111-007-VALIDATION-SUMMARY`

`V0111-007-AGGREGATE-VERIFY`

`V0111-007-NO-PRODUCTION-CUTOVER`

`V0111-007-NO-TAG-OR-RELEASE-MOVE`

v0.11.1 Readiness Runtime Guard Patch 是 v0.11.0 public Release 后的 guard hardening closeout。它只收口 #945..#951 的 release fact sync、Dashboard macOS focused guard、Dashboard SHA-256 / readiness state invariants、readiness artifact symlink root confinement、readiness artifact owner-only permissions、aggregate verifier、Stage Code Audit 和 release notes。

GH-951 不是 release publication gate：

- 不创建 `v0.11.1` tag。
- 不创建 `v0.11.1` GitHub Release。
- 不移动、不覆盖、不重写 `v0.11.0` tag 或 GitHub Release。
- 不推进 v0.12.0。
- 不授权 production cutover。

v0.11.0 public GitHub Release 仍保持为 `https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`，tag peeled commit `13f592d0710de91351286e5c5490bfacb63c19b0`，publication timestamp `2026-06-19T01:20:58Z`。v0.11.1 patch closeout 不改变该 release identity。

## V0120-002-V011X-RELEASE-PATCH-FACT-BASELINE

`GH-953-VERIFY-V0120-V011X-RELEASE-PATCH-FACTS`

`TVM-RELEASE-V0120-V011X-RELEASE-PATCH-FACTS`

`V0120-002-V0110-PUBLICATION-FACT`

`V0120-002-V0111-PATCH-FACT`

`V0120-002-CONSTRUCTION-PUBLICATION-CUTOVER-SEPARATION`

`V0120-002-NO-PRODUCTION-CUTOVER`

v0.12.0 readiness assessment sessions must inherit these v0.11.x publication / patch facts as baseline evidence:

- v0.11.0 public GitHub Release exists at `https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`.
- v0.11.0 tag peeled commit remains `13f592d0710de91351286e5c5490bfacb63c19b0`.
- v0.11.0 publication timestamp remains `2026-06-19T01:20:58Z`.
- #924 remains the v0.11.0 construction closeout, not the publication gate.
- v0.11.1 Readiness Runtime Guard Patch 是 v0.11.0 public Release 后的 guard hardening closeout，覆盖 #945..#951。
- v0.11.1 patch closeout does not create a `v0.11.1` tag or GitHub Release, and it does not move, rewrite or replace the `v0.11.0` tag / GitHub Release.

This baseline only supports local readiness assessment provenance. It does not authorize production cutover, production trading, production secret reads, production endpoint / broker endpoint connections, testnet orders or production orders.

## V080-002-V080-CONSTRUCTION-VS-PUBLICATION

`V080-002-V080-CONSTRUCTION-VS-PUBLICATION`

v0.8.0 GitHub fallback queue construction phase 已完成。`GH-807..GH-820` 已收口 persistent local operator runtime、testnet read-only monitoring、manual proof summary、Dashboard read-only monitor、safe local controls、validation split 和 final audit / docs / runbook。

v0.8.0 的 construction closeout 必须先满足：

- `GH-807..GH-820` 全部 closed / done。
- open PR = 0。
- open `todo` / `in-progress` / `in-review` issue = 0。
- `main == origin/main`。
- worktree clean。
- `git diff --check` 通过。
- `bash checks/automation-readiness.sh` 通过。
- `bash checks/run.sh` 通过。

v0.8.0 public release publication 已在 construction closeout 之后通过独立 release publication task 明确授权并完成。`GH-808` 本身不创建 tag，不创建 GitHub Release，不移动任何已有 tag，不推进 v0.8.0 之后的阶段；后续 `GH-835` 只把已发生的 v0.8.0 stable GitHub Release 事实同步回文档和验证 guard。

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
- `bash checks/verify-v0.10.0-release-policy.sh`
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
