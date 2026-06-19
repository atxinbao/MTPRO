# MTPRO Release v0.11.1 Readiness Runtime Guard Patch Notes

日期：2026-06-19

执行者：Codex

## Summary

v0.11.1 是 v0.11.0 public GitHub Release 之后的 readiness runtime guard hardening patch。它不新增 runtime pipeline，不发布新的 production capability，只把已发生的 v0.11.0 publication fact、Dashboard readiness state、local artifact filesystem guard 和 v0.11.1 aggregate verifier 固定为可验证 evidence。

本说明是 #951 patch closeout notes，不创建 tag，不创建 GitHub Release，不移动既有 `v0.11.0` tag / release，不推进 v0.12.0。

## Completed Queue

- #945：固定 v0.11.0 release publication fact sync / stale wording guard。
- #946：加入 Dashboard macOS v0.11 focused guard。
- #947：强化 Dashboard SHA-256 和 readiness state invariants。
- #948：约束 readiness artifact root / path / target symlink escape。
- #949：强制 readiness artifact directories / files owner-only permissions。
- #950：新增 `checks/verify-v0.11.1.sh` aggregate validation guard。
- #951：收口 v0.11.1 Stage Code Audit、release notes、latest verification summary、release publication boundary notes 和 closeout focused test。

## Validation

Validation anchors:

- `GH-951-VERIFY-V0111-PATCH-AUDIT-RELEASE-NOTES`
- `TVM-RELEASE-V0111-PATCH-AUDIT-RELEASE-NOTES`
- `V0111-007-PATCH-AUDIT`
- `V0111-007-RELEASE-NOTES`
- `V0111-007-VALIDATION-SUMMARY`
- `V0111-007-AGGREGATE-VERIFY`
- `V0111-007-NO-PRODUCTION-CUTOVER`
- `V0111-007-NO-TAG-OR-RELEASE-MOVE`

```bash
bash checks/verify-v0.11.1.sh
```

The aggregate verifier covers:

- `checks/verify-v0.11.1-release-fact-sync.sh`
- `checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh`
- `checks/verify-v0.11.1-readiness-artifact-symlink-root.sh`
- `checks/verify-v0.11.1-readiness-artifact-permissions.sh`
- `TargetGraphTests/testGH950ReleaseV0111PatchAggregateVerifierAnchors`
- `TargetGraphTests/testGH951ReleaseV0111PatchAuditReleaseNotesCloseout`

Full local validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.11.1.sh
bash checks/verify-v0.11.0.sh
bash checks/run.sh
```

## Boundaries

- production trading 仍默认关闭。
- production cutover 仍未授权。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 testnet 或 production order。
- 不授权 real order submit / cancel / replace。
- 不实现或启用 production OMS。
- 不启用 trading button、order form 或 live command。
- 不创建、不移动、不重写 `v0.11.0` 或任何 release tag。
- 不发布新的 GitHub Release。
- 不推进 v0.12.0。

## Operator Meaning

v0.11.1 表示 v0.11.0 release publication 后的 guard evidence 已收紧：发布事实不会回退成 pending wording，Dashboard / macOS guard 路径会持续执行 v0.11 focused checks，本地 readiness artifact path / permission guard 会继续由 aggregate verifier 覆盖。

它仍然不是 production cutover，也不是 production trading runtime。
