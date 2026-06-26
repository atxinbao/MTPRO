# MTPRO Release v0.16.1 Operator Beta Evidence Hardening Patch Notes

日期：2026-06-26

执行者：Codex

## Summary

`MTPRO Release v0.16.1 Operator Beta Evidence Hardening Patch` 是 `v0.16.0` 后的 evidence hardening patch queue。v0.16.1 是后续 evidence hardening patch queue。GH-1133 只同步 `v0.16.0` stable GitHub Release 已发布事实，并把后续 v0.16.1 patch 语义固定为文档和验证 guard；它不移动 `v0.16.0` tag，不覆盖 GitHub Release，不创建 `v0.16.1` public release，不授权 production cutover。

`v0.16.0` stable GitHub Release 已由独立 Release Publication Gate 发布：

- Release URL：`https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0`
- tag peeled commit：`28779236262bd7ffaf71e286b27b95854c5cd3e1`
- publication timestamp：`2026-06-26T01:29:21Z`
- release type：stable；非 draft；非 prerelease

后续 #1134..#1138 仍必须按 GitHub fallback queue、WIP=1、dependency order 和各自 issue scope 单独执行。

## Validation Anchors

- `GH-1133-VERIFY-V0161-V0160-RELEASE-FACT-SYNC`
- `V0161-001-V0160-RELEASE-FACT-SYNC-GUARD`
- `TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC`
- `V0161-001-V0160-TAG-FIXED`
- `V0161-001-PATCH-QUEUE-NOT-PUBLICATION`
- `V0161-001-NO-PRODUCTION-CUTOVER`

Focused verifier:

```bash
bash checks/verify-v0.16.1-release-fact-sync.sh
```

Focused test:

```bash
swift test --filter TargetGraphTests/testGH1133ReleaseV0161V0160ReleaseFactSyncGuard
```

Full validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Patch Boundary

- `v0.16.1` 是 v0.16.0 后的 patch queue，不是新的 production cutover gate。
- `v0.16.0` tag remains fixed at `28779236262bd7ffaf71e286b27b95854c5cd3e1`。
- GH-1133 不创建、不移动、不重写任何 tag 或 GitHub Release。
- GH-1133 不推进 #1134..#1138；后续 issue 必须等待当前 issue 完整 Done 后再由 queue preflight 推进。
- production trading 仍默认关闭。
- 不读取 production secret。
- 不连接 production endpoint / broker endpoint。
- 不发送 production submit / cancel / replace。
- 不授权 production cutover。
- production cutover not authorized。
