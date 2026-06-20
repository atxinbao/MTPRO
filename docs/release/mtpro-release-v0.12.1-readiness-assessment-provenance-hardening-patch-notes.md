# MTPRO Release v0.12.1 Readiness Assessment Provenance Hardening Patch Notes

日期：2026-06-20

执行者：Codex

## Summary

v0.12.1 是 v0.12.0 public GitHub Release 之后的 readiness assessment provenance hardening patch。它不新增 runtime pipeline，不发布新的 production capability，只把已发生的 v0.12.0 publication fact、readiness source commit provenance、local evidence metadata、compare fail-closed behavior 和 generated JSON inspection 固定为可验证 evidence。

本说明是 #993 patch closeout notes，不创建 `v0.12.1` tag，不创建 `v0.12.1` GitHub Release，不移动既有 `v0.12.0` tag / release，不推进 v0.13.0。

## Completed Queue

- #988：固定 v0.12.0 release publication fact sync / stale wording guard。
- #989：替换 placeholder readiness `sourceCommit`，要求 explicit commit provenance。
- #990：把 readiness `sourceRunIDs`、artifact SHA 和 bytes 绑定到真实本地 evidence。
- #991：让 readiness compare 在缺失 source-run evidence 时 fail closed。
- #992：新增生成后 JSON inspection guard，覆盖 registry、Manifest V2、bundle、bundle manifest、export 和 compare output。
- #993：收口 v0.12.1 Stage Code Audit、release notes、latest verification summary、release publication boundary notes、root-doc patch facts 和 closeout focused test。

## Validation

Validation anchors:

- `GH-993-VERIFY-V0121-PATCH-AUDIT-RELEASE-NOTES`
- `TVM-RELEASE-V0121-PATCH-AUDIT-RELEASE-NOTES`
- `V0121-006-PATCH-AUDIT`
- `V0121-006-RELEASE-NOTES`
- `V0121-006-VALIDATION-SUMMARY`
- `V0121-006-NO-PRODUCTION-CUTOVER`
- `V0121-006-NO-TAG-OR-RELEASE-MOVE`

Carry-forward anchors:

- `GH-988-VERIFY-V0121-RELEASE-FACT-STALE-WORDING-GUARD`
- `GH-989-VERIFY-V0121-SOURCE-COMMIT-PROVENANCE`
- `GH-990-VERIFY-V0121-LOCAL-EVIDENCE-METADATA`
- `GH-991-VERIFY-V0121-COMPARE-FAIL-CLOSED`
- `GH-992-VERIFY-V0121-JSON-INSPECTION-GUARDS`

Focused verifier:

```bash
bash checks/verify-v0.12.1-patch-audit-release-notes.sh
```

Full local validation remains:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.12.1-patch-audit-release-notes.sh
bash checks/verify-v0.12.0.sh
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
- 不创建 `v0.12.1` tag，不移动或重写既有 release tag。
- 不发布 `v0.12.1` GitHub Release。
- 不推进 v0.13.0。

## Operator Meaning

v0.12.1 表示 v0.12.0 release publication 后的 readiness assessment provenance evidence 已收紧：发布事实不会回退成 pending wording，Manifest V2 / bundle 不再接受 placeholder commit，sourceRunID 和 artifact metadata 必须来自本地 redacted evidence，compare 不能伪造缺失 evidence，automation 会直接检查生成后的 JSON。

它仍然不是 production cutover，也不是 production trading runtime。
